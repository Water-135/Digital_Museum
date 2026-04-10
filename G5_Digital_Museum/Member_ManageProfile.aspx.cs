using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;

namespace G5_Digital_Museum
{
    public partial class Member_ManageProfile : System.Web.UI.Page
    {
        private readonly string _cs =
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Main_LoginPage.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadProfile();
            }
        }

        private void LoadProfile()
        {
            int userId = Convert.ToInt32(Session["UserID"]);

            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT FullName, Email FROM Users WHERE UserID=@UserID", con))
            {
                cmd.Parameters.AddWithValue("@UserID", userId);

                con.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        txtName.Text = dr["FullName"].ToString();
                        txtEmail.Text = dr["Email"].ToString();
                    }
                }
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            int userId = Convert.ToInt32(Session["UserID"]);

            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string pw = txtNewPassword.Text.Trim();
            string confirm = txtConfirmPassword.Text.Trim();

            if (string.IsNullOrWhiteSpace(name) || string.IsNullOrWhiteSpace(email))
            {
                lblMsg.CssClass = "error-msg";
                lblMsg.Text = "Name and email cannot be empty.";
                return;
            }

            if (pw != confirm)
            {
                lblMsg.CssClass = "error-msg";
                lblMsg.Text = "Passwords do not match.";
                return;
            }

            using (SqlConnection con = new SqlConnection(_cs))
            {
                con.Open();

                if (string.IsNullOrWhiteSpace(pw))
                {
                    string sql = @"UPDATE Users
                                   SET FullName=@Name, Email=@Email
                                   WHERE UserID=@UserID";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@Name", name);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    string hash = HashPassword(pw);

                    string sql = @"UPDATE Users
                                   SET FullName=@Name,
                                       Email=@Email,
                                       PasswordHash=@Hash
                                   WHERE UserID=@UserID";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@Name", name);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@Hash", hash);
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            lblMsg.CssClass = "success-msg";
            lblMsg.Text = "Profile updated successfully.";

            LoadProfile();
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