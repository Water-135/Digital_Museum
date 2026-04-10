using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Drawing;

namespace G5_Digital_Museum
{
    public partial class Admin_Registration : System.Web.UI.Page
    {
        private readonly string cs =
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();
            string confirmPassword = txtConfirmPassword.Text.Trim();

            if (name == "" || email == "" || password == "" || confirmPassword == "")
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
                using (SqlConnection con = new SqlConnection(cs))
                {
                    con.Open();

                    // check email exists
                    string checkSql = "SELECT COUNT(*) FROM Users WHERE Email=@Email";
                    SqlCommand checkCmd = new SqlCommand(checkSql, con);
                    checkCmd.Parameters.AddWithValue("@Email", email);

                    int count = (int)checkCmd.ExecuteScalar();

                    if (count > 0)
                    {
                        lblMsg.Text = "Email already exists.";
                        lblMsg.ForeColor = Color.IndianRed;
                        return;
                    }

                    // insert admin
                    string insertSql = @"
                        INSERT INTO Users 
                        (FullName, Email, PasswordHash, Role, IsActive, CreatedAt)
                        VALUES 
                        (@Name, @Email, @Password, @Role, @IsActive, @CreatedAt)";

                    SqlCommand cmd = new SqlCommand(insertSql, con);

                    cmd.Parameters.AddWithValue("@Name", name);
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@Password", password);
                    cmd.Parameters.AddWithValue("@Role", "Admin");
                    cmd.Parameters.AddWithValue("@IsActive", true);
                    cmd.Parameters.AddWithValue("@CreatedAt", DateTime.Now);

                    cmd.ExecuteNonQuery();

                    lblMsg.Text = "Admin account created successfully.";
                    lblMsg.ForeColor = Color.Goldenrod;

                    txtName.Text = "";
                    txtEmail.Text = "";
                    txtPassword.Text = "";
                    txtConfirmPassword.Text = "";
                }
            }
            catch (Exception ex)
            {
                lblMsg.Text = ex.Message;
                lblMsg.ForeColor = Color.IndianRed;
            }
        }
    }
}