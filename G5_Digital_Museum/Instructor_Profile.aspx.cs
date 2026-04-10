using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace G5_Digital_Museum
{
    public partial class Instructor_Profile : System.Web.UI.Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadProfile();
        }

        private void LoadProfile()
        {
            // Use session UserID if available, else default to seeded instructor ID 1
            int userID = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT FullName,Email,CreatedAt FROM Users WHERE UserID=@ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", userID);
                conn.Open();
                SqlDataReader r = cmd.ExecuteReader();
                if (!r.Read()) return;

                string name = r["FullName"].ToString();
                string email = r["Email"].ToString();

                txtName.Text = name;
                txtEmail.Text = email;

                lblDisplayName.Text = name;
                lblInitial.Text = name.Length > 0 ? name[0].ToString().ToUpper() : "I";
                lblDisplayEmail.Text = email;
                lblMemberSince.Text = r["CreatedAt"] != DBNull.Value
                    ? Convert.ToDateTime(r["CreatedAt"]).ToString("MMM yyyy") : "—";
            }
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtName.Text))
            { ShowMsg("Full name is required.", false); return; }
            if (string.IsNullOrWhiteSpace(txtEmail.Text))
            { ShowMsg("Email is required.", false); return; }

            int userID = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;

            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Check email not taken by another user
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Users WHERE Email=@Email AND UserID<>@ID", conn))
                {
                    cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                    cmd.Parameters.AddWithValue("@ID", userID);
                    if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                    { ShowMsg("That email is already in use by another account.", false); return; }
                }

                // Update name + email
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE Users SET FullName=@Name,Email=@Email WHERE UserID=@ID", conn))
                {
                    cmd.Parameters.AddWithValue("@Name", txtName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                    cmd.Parameters.AddWithValue("@ID", userID);
                    cmd.ExecuteNonQuery();
                }

                // Password change — only if any password field is filled
                bool wantsPasswordChange =
                    !string.IsNullOrWhiteSpace(txtCurrentPassword.Text) ||
                    !string.IsNullOrWhiteSpace(txtNewPassword.Text);

                if (wantsPasswordChange)
                {
                    if (string.IsNullOrWhiteSpace(txtCurrentPassword.Text))
                    { ShowMsg("Enter your current password to change it.", false); return; }
                    if (string.IsNullOrWhiteSpace(txtNewPassword.Text))
                    { ShowMsg("New password cannot be empty.", false); return; }
                    if (txtNewPassword.Text != txtConfirmPassword.Text)
                    { ShowMsg("New passwords do not match.", false); return; }
                    if (txtNewPassword.Text.Length < 6)
                    { ShowMsg("Password must be at least 6 characters.", false); return; }

                    string currentHash = HashSHA256(txtCurrentPassword.Text);
                    string storedHash = "";

                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT PasswordHash FROM Users WHERE UserID=@ID", conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", userID);
                        storedHash = cmd.ExecuteScalar()?.ToString() ?? "";
                    }

                    if (!currentHash.Equals(storedHash, StringComparison.OrdinalIgnoreCase))
                    { ShowMsg("Current password is incorrect.", false); return; }

                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Users SET PasswordHash=@Hash WHERE UserID=@ID", conn))
                    {
                        cmd.Parameters.AddWithValue("@Hash", HashSHA256(txtNewPassword.Text));
                        cmd.Parameters.AddWithValue("@ID", userID);
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            // Update session + live avatar
            if (Session["FullName"] != null)
                Session["FullName"] = txtName.Text.Trim();

            lblDisplayName.Text = txtName.Text.Trim();
            lblInitial.Text = txtName.Text.Trim()[0].ToString().ToUpper();
            lblDisplayEmail.Text = txtEmail.Text.Trim();
            txtCurrentPassword.Text = txtNewPassword.Text = txtConfirmPassword.Text = "";

            ShowMsg("Profile updated successfully.", true);
        }

        // Must match Main_LoginPage.HashPassword() — both use Base64 encoding.
        private string HashSHA256(string plain)
        {
            using (SHA256 sha = SHA256.Create())
            {
                byte[] hash = sha.ComputeHash(Encoding.UTF8.GetBytes(plain));
                return Convert.ToBase64String(hash);
            }
        }

        private void ShowMsg(string msg, bool ok)
        {
            lblMsg.Text = msg;
            lblMsg.ForeColor = ok
                ? System.Drawing.Color.FromArgb(94, 203, 138)
                : System.Drawing.Color.FromArgb(201, 76, 76);
        }
    }
}