using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using G5_Digital_Museum.Helpers;

namespace G5_Digital_Museum.Admin_ASPX
{
    public partial class Admin_ManageUsers : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadUsers();
        }

        private void LoadUsers(string search = "", string role = "", string dateFrom = "", string dateTo = "")
        {
            var dt = DataAccess.GetFilteredUsers(search, role, dateFrom, dateTo);
            gvUsers.DataSource = dt;
            gvUsers.DataBind();
            lblResultCount.Text = $"Showing {dt.Rows.Count} user(s)";
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadUsers(txtSearch.Text.Trim(), ddlFilterRole.SelectedValue,
                      txtDateFrom.Text.Trim(), txtDateTo.Text.Trim());
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlFilterRole.SelectedIndex = 0;
            txtDateFrom.Text = "";
            txtDateTo.Text = "";
            LoadUsers();
        }

        protected void btnAddUser_Click(object sender, EventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();
            string role = ddlRole.SelectedValue;

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                lblModalError.Text = "All fields are required.";
                lblModalError.Visible = true;
                ScriptManager.RegisterStartupScript(this, GetType(), "showModal",
                    "new bootstrap.Modal(document.getElementById('addUserModal')).show();", true);
                return;
            }

            if (DataAccess.EmailExists(email))
            {
                lblModalError.Text = "A user with this email already exists.";
                lblModalError.Visible = true;
                ScriptManager.RegisterStartupScript(this, GetType(), "showModal",
                    "new bootstrap.Modal(document.getElementById('addUserModal')).show();", true);
                return;
            }

            DataAccess.CreateUser(fullName, email, password, role);
            lblModalError.Visible = false;
            txtFullName.Text = ""; txtEmail.Text = ""; txtPassword.Text = "";
            ddlRole.SelectedIndex = 0;
            ShowMessage("User added successfully!", "alert-success");
            LoadUsers();
        }

        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int userId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteUser")
            {
                DataAccess.DeleteUser(userId);
                ShowMessage("User deleted.", "alert-success");
                pnlEditUser.Visible = false;
                LoadUsers();
            }
            else if (e.CommandName == "EditUser")
            {
                LoadUserProfile(userId);
            }
        }

        private void LoadUserProfile(int userId)
        {
            DataRow user = DataAccess.GetUserById(userId);
            if (user == null) return;

            hdnUserId.Value = userId.ToString();
            txtEditFullName.Text = user["FullName"].ToString();
            txtEditEmail.Text = user["Email"].ToString();
            ddlEditRole.SelectedValue = user["Role"].ToString();
            lblDateJoined.Text = Convert.ToDateTime(user["CreatedAt"]).ToString("dd/MM/yyyy");
            lblCurrentPassword.Text = user["PasswordHash"].ToString();
            txtNewPassword.Text = "";

            pnlEditUser.Visible = true;
            lblEditMessage.Visible = false;

            ScriptManager.RegisterStartupScript(this, GetType(), "scrollEdit",
                "document.getElementById('editPanel').scrollIntoView({behavior:'smooth'});", true);
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hdnUserId.Value)) return;

            int userId = Convert.ToInt32(hdnUserId.Value);
            string fullName = txtEditFullName.Text.Trim();
            string email = txtEditEmail.Text.Trim();
            string role = ddlEditRole.SelectedValue;

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email))
            {
                ShowEditMessage("Full Name and Email are required.", "alert-danger");
                return;
            }

            bool ok = DataAccess.UpdateUser(userId, fullName, email, role);
            ShowEditMessage(ok ? "Profile updated successfully!" : "Update failed.", ok ? "alert-success" : "alert-danger");
            if (ok) LoadUsers(txtSearch.Text.Trim(), ddlFilterRole.SelectedValue,
                              txtDateFrom.Text.Trim(), txtDateTo.Text.Trim());
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hdnUserId.Value)) return;

            int userId = Convert.ToInt32(hdnUserId.Value);
            string newPassword = txtNewPassword.Text.Trim();

            if (string.IsNullOrEmpty(newPassword))
            {
                ShowEditMessage("Please enter a new password.", "alert-danger");
                return;
            }

            if (newPassword.Length < 6)
            {
                ShowEditMessage("Password must be at least 6 characters.", "alert-danger");
                return;
            }

            bool ok = DataAccess.UpdatePassword(userId, newPassword);
            if (ok)
            {
                txtNewPassword.Text = "";
                LoadUserProfile(userId);
            }
            ShowEditMessage(ok ? "Password changed successfully!" : "Failed to change password.",
                            ok ? "alert-success" : "alert-danger");
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            pnlEditUser.Visible = false;
            hdnUserId.Value = "";
        }

        private void ShowMessage(string message, string cssClass)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "alert d-block mb-3 " + cssClass;
            lblMessage.Visible = true;
        }

        private void ShowEditMessage(string message, string cssClass)
        {
            lblEditMessage.Text = message;
            lblEditMessage.CssClass = "alert d-block mb-3 " + cssClass;
            lblEditMessage.Visible = true;
        }
    }
}