using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Net;
using System.Net.Mail;

namespace G5_Digital_Museum
{
    public partial class Member_ForgotPassword : System.Web.UI.Page
    {
        private readonly string _cs =
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnSendOtp_Click(object sender, EventArgs e)
        {
            lblMsg.Text = "";
            lblMsg.CssClass = "";

            string email = (txtEmail.Text ?? "").Trim().ToLower();

            if (string.IsNullOrWhiteSpace(email))
            {
                ShowError("Please enter your email.");
                return;
            }

            try
            {
                bool exists = false;

                using (SqlConnection con = new SqlConnection(_cs))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Users WHERE Email=@Email AND IsActive=1", con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    con.Open();
                    exists = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }

                if (!exists)
                {
                    ShowError("Email not found.");
                    return;
                }

                string otp = GenerateOtp();

                using (SqlConnection con = new SqlConnection(_cs))
                using (SqlCommand cmd = new SqlCommand(@"
INSERT INTO PasswordResetOtp (Email, OtpCode, ExpireAt, IsUsed)
VALUES (@Email, @OtpCode, DATEADD(MINUTE, 5, GETDATE()), 0)", con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@OtpCode", otp);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                SendOtpEmail(email, otp);

                lblMsg.CssClass = "success-msg";
                lblMsg.Text = "OTP sent successfully. Please check your email.";
            }
            catch (Exception ex)
            {
                ShowError("Send OTP failed: " + ex.Message);
            }
        }

        protected void btnVerifyOtp_Click(object sender, EventArgs e)
        {
            lblMsg.Text = "";
            lblMsg.CssClass = "";

            string email = (txtEmail.Text ?? "").Trim().ToLower();
            string otp = (txtOtp.Text ?? "").Trim();

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(otp))
            {
                ShowError("Please enter both email and OTP.");
                return;
            }

            try
            {
                int userId = 0;
                string fullName = "";
                string role = "";

                using (SqlConnection con = new SqlConnection(_cs))
                {
                    con.Open();

                    // 1. Check OTP valid
                    using (SqlCommand cmdOtp = new SqlCommand(@"
SELECT TOP 1 OtpID
FROM PasswordResetOtp
WHERE Email=@Email
  AND OtpCode=@OtpCode
  AND IsUsed=0
  AND ExpireAt >= GETDATE()
ORDER BY OtpID DESC", con))
                    {
                        cmdOtp.Parameters.AddWithValue("@Email", email);
                        cmdOtp.Parameters.AddWithValue("@OtpCode", otp);

                        object otpResult = cmdOtp.ExecuteScalar();
                        if (otpResult == null)
                        {
                            ShowError("Invalid or expired OTP.");
                            return;
                        }
                    }

                    // 2. Get user info
                    using (SqlCommand cmdUser = new SqlCommand(@"
SELECT TOP 1 UserID, FullName, Role
FROM Users
WHERE Email=@Email AND IsActive=1", con))
                    {
                        cmdUser.Parameters.AddWithValue("@Email", email);

                        using (SqlDataReader dr = cmdUser.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                userId = Convert.ToInt32(dr["UserID"]);
                                fullName = dr["FullName"].ToString();
                                role = dr["Role"].ToString();
                            }
                            else
                            {
                                ShowError("User not found.");
                                return;
                            }
                        }
                    }

                    // 3. Mark OTP as used
                    using (SqlCommand cmdUseOtp = new SqlCommand(@"
UPDATE PasswordResetOtp
SET IsUsed=1
WHERE Email=@Email AND OtpCode=@OtpCode AND IsUsed=0", con))
                    {
                        cmdUseOtp.Parameters.AddWithValue("@Email", email);
                        cmdUseOtp.Parameters.AddWithValue("@OtpCode", otp);
                        cmdUseOtp.ExecuteNonQuery();
                    }
                }

                // 4. Login with Session
                Session["UserID"] = userId;
                Session["FullName"] = fullName;
                Session["Role"] = role;

                Response.Redirect("Member_HomePage.aspx");
            }
            catch (Exception ex)
            {
                ShowError("OTP verification failed: " + ex.Message);
            }
        }

        private void ShowError(string msg)
        {
            lblMsg.CssClass = "aspnet-validator";
            lblMsg.Text = msg;
        }

        private string GenerateOtp()
        {
            Random rnd = new Random();
            return rnd.Next(100000, 999999).ToString();
        }

        private void SendOtpEmail(string toEmail, string otp)
        {
            string fromEmail = "jensonteh0702@gmail.com";
            string appPassword = "ehflawtbisgwmcdu";

            using (MailMessage mail = new MailMessage())
            {
                mail.From = new MailAddress(fromEmail, "Digital Museum");
                mail.To.Add(toEmail);
                mail.Subject = "Digital Museum OTP Login";
                mail.Body =
                    "Your OTP code is: " + otp +
                    "\n\nThis code will expire in 5 minutes." +
                    "\n\nIf you did not request this, please ignore this email.";

                using (SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587))
                {
                    smtp.EnableSsl = true;
                    smtp.UseDefaultCredentials = false;
                    smtp.Credentials = new NetworkCredential(fromEmail, appPassword);
                    smtp.DeliveryMethod = SmtpDeliveryMethod.Network;
                    smtp.Send(mail);
                }
            }
        }
    }
}