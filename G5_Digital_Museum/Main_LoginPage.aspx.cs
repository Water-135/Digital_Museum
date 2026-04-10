using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Drawing;
using System.Security.Cryptography;
using System.Text;

namespace G5_Digital_Museum
{
    public partial class Main_LoginPage : System.Web.UI.Page
    {
        private readonly string cs =
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
            {
                lblMsg.Text = "Please enter email and password.";
                lblMsg.ForeColor = Color.IndianRed;
                return;
            }

            string hash = HashPassword(password);

            try
            {
                using (SqlConnection con = new SqlConnection(cs))
                {
                    string sql = @"
                        SELECT TOP 1 UserID, FullName, Role
                        FROM Users
                        WHERE Email = @Email
                          AND PasswordHash = @Password
                          AND IsActive = 1";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@Password", hash);

                        con.Open();

                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                int userId = Convert.ToInt32(dr["UserID"]);
                                string fullName = dr["FullName"].ToString();
                                string role = dr["Role"].ToString();

                                Session["UserID"] = userId;
                                Session["FullName"] = fullName;
                                Session["Role"] = role;

                                if (role == "Admin")
                                {
                                    Session["AdminID"] = userId;
                                    Session["AdminName"] = fullName;
                                    Response.Redirect("~/admin_aspx/Admin_Dashboard.aspx");
                                }
                                else if (role == "Instructor")
                                {
                                    Session["InstructorID"] = userId;
                                    Session["InstructorName"] = fullName;
                                    Response.Redirect("~/Instructor_HomePage.aspx");
                                }
                                else if (role == "Member")
                                {
                                    Session["MemberID"] = userId;
                                    Session["MemberName"] = fullName;
                                    Response.Redirect("~/Member_HomePage.aspx");
                                }
                                else
                                {
                                    lblMsg.Text = "Unknown user role.";
                                    lblMsg.ForeColor = Color.IndianRed;
                                }
                            }
                            else
                            {
                                lblMsg.Text = "Invalid email or password.";
                                lblMsg.ForeColor = Color.IndianRed;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblMsg.Text = "Error: " + ex.Message;
                lblMsg.ForeColor = Color.IndianRed;
            }
        }

        private string HashPassword(string pw)
        {
            using (SHA256 sha = SHA256.Create())
            {
                byte[] bytes = Encoding.UTF8.GetBytes(pw);
                byte[] hash = sha.ComputeHash(bytes);
                return Convert.ToBase64String(hash);
            }
        }
    }
}