using System;
using System.Data;
using G5_Digital_Museum.Helpers;

namespace G5_Digital_Museum.Admin_ASPX
{
    public partial class Admin_Profile : System.Web.UI.Page
    {
        private int AdminUserId
        {
            get { return Session["AdminID"] != null ? Convert.ToInt32(Session["AdminID"]) : 1; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadProfile();
        }

        private void LoadProfile()
        {
            DataRow user = DataAccess.GetUserById(AdminUserId);
            if (user == null) return;

            string fullName = user["FullName"].ToString();

            txtEditFullName.Text = fullName;
            txtEditEmail.Text = user["Email"].ToString();
            lblDisplayName.Text = fullName;
            lblRole.Text = user["Role"].ToString();
            lblDateJoined.Text = Convert.ToDateTime(user["CreatedAt"]).ToString("dd MMMM yyyy");
            lblUserID.Text = user["UserID"].ToString();
            lblInitial.Text = fullName.Length > 0 ? fullName.Substring(0, 1).ToUpper() : "A";

            Session["AdminName"] = fullName;
            Session["AdminRole"] = user["Role"].ToString();
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            string fullName = txtEditFullName.Text.Trim();
            string email = txtEditEmail.Text.Trim();

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email))
            {
                ShowMessage("Full name and email are required.", "alert-danger");
                return;
            }

            bool saved = DataAccess.UpdateAdminProfile(AdminUserId, fullName, email);
            if (saved)
            {
                Session["AdminName"] = fullName;
                LoadProfile();
            }
            ShowMessage(saved ? "Profile updated successfully!" : "Update failed.",
                        saved ? "alert-success" : "alert-danger");
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            string newPass = txtNewPassword.Text.Trim();

            if (string.IsNullOrEmpty(newPass))
            { ShowMessage("Please enter a new password.", "alert-danger"); return; }

            if (newPass.Length < 6)
            { ShowMessage("Password must be at least 6 characters.", "alert-danger"); return; }

            bool changed = DataAccess.UpdatePassword(AdminUserId, newPass);
            if (changed) txtNewPassword.Text = "";
            ShowMessage(changed ? "Password changed successfully!" : "Failed to change password.",
                        changed ? "alert-success" : "alert-danger");
        }

        private void ShowMessage(string message, string cssClass)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "alert d-block mb-4 " + cssClass;
            lblMessage.Visible = true;
        }
    }
}