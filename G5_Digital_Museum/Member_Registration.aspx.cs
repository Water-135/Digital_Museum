using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Drawing;
using System.Security.Cryptography;
using System.Text;

namespace G5_Digital_Museum
{
    public partial class Member_Registration : System.Web.UI.Page
    {
        private readonly string _cs =
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text.Trim();
            string confirmPassword = txtConfirm.Text.Trim();

            if (string.IsNullOrWhiteSpace(fullName) ||
                string.IsNullOrWhiteSpace(email) ||
                string.IsNullOrWhiteSpace(password) ||
                string.IsNullOrWhiteSpace(confirmPassword))
            {
                lblMsg.Text = "Please fill in all fields.";
                lblMsg.ForeColor = Color.IndianRed;
                return;
            }

            if (password != confirmPassword)
            {
                lblMsg.Text = "Passwords do not match.";
                lblMsg.ForeColor = Color.IndianRed;
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(_cs))
                {
                    con.Open();

                    string checkSql = "SELECT COUNT(*) FROM Users WHERE Email=@Email";
                    using (SqlCommand checkCmd = new SqlCommand(checkSql, con))
                    {
                        checkCmd.Parameters.AddWithValue("@Email", email);

                        int count = Convert.ToInt32(checkCmd.ExecuteScalar());
                        if (count > 0)
                        {
                            lblMsg.Text = "This email is already registered.";
                            lblMsg.ForeColor = Color.IndianRed;
                            return;
                        }
                    }

                    string hash = HashPassword(password);

                    string insertSql = @"
                        INSERT INTO Users
                        (FullName, Email, PasswordHash, Role, IsActive, CreatedAt, LastLoginAt)
                        VALUES
                        (@FullName, @Email, @PasswordHash, @Role, @IsActive, @CreatedAt, @LastLoginAt)";

                    using (SqlCommand cmd = new SqlCommand(insertSql, con))
                    {
                        cmd.Parameters.AddWithValue("@FullName", fullName);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@PasswordHash", hash);
                        cmd.Parameters.AddWithValue("@Role", "Member");
                        cmd.Parameters.AddWithValue("@IsActive", true);
                        cmd.Parameters.AddWithValue("@CreatedAt", DateTime.Now);
                        cmd.Parameters.AddWithValue("@LastLoginAt", DBNull.Value);

                        int rows = cmd.ExecuteNonQuery();

                        if (rows > 0)
                        {
                            lblMsg.Text = "Member account created successfully.";
                            lblMsg.ForeColor = Color.Goldenrod;

                            txtFullName.Text = "";
                            txtEmail.Text = "";
                            txtPassword.Text = "";
                            txtConfirm.Text = "";
                        }
                        else
                        {
                            lblMsg.Text = "Registration failed.";
                            lblMsg.ForeColor = Color.IndianRed;
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