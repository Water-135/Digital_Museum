using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using G5_Digital_Museum.Helpers;

namespace G5_Digital_Museum.Admin_ASPX
{
    public partial class Admin_Settings : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadSettings();
            UpdateSummary();
        }

        private void LoadSettings()
        {
            var s = DataAccess.GetAllSettings();

            txtSiteTitle.Text = Get(s, "SiteTitle", "Digital Museum");
            txtSiteDescription.Text = Get(s, "SiteDescription", "History of Nanjing Massacre");
            txtContactEmail.Text = Get(s, "ContactEmail", "admin@museum.com");

            TrySet(ddlVisibility, s, "ContentVisibility", "Public");
            TrySet(ddlDefaultRole, s, "DefaultRole", "Guest");
            TrySet(ddlMaxLoginAttempts, s, "MaxLoginAttempts", "5");
            TrySet(ddlMinPassword, s, "MinPasswordLength", "6");

            chkAllowRegistration.Checked = !s.ContainsKey("AllowRegistration")
                || s["AllowRegistration"] == "true";
        }

        protected void btnSaveAll_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtSiteTitle.Text.Trim()))
            { ShowMessage("Site title cannot be empty.", "alert-danger"); return; }

            if (string.IsNullOrEmpty(txtContactEmail.Text.Trim()))
            { ShowMessage("Contact email cannot be empty.", "alert-danger"); return; }

            DataAccess.SaveSetting("SiteTitle", txtSiteTitle.Text.Trim());
            DataAccess.SaveSetting("SiteDescription", txtSiteDescription.Text.Trim());
            DataAccess.SaveSetting("ContactEmail", txtContactEmail.Text.Trim());
            DataAccess.SaveSetting("ContentVisibility", ddlVisibility.SelectedValue);
            DataAccess.SaveSetting("DefaultRole", ddlDefaultRole.SelectedValue);
            DataAccess.SaveSetting("MaxLoginAttempts", ddlMaxLoginAttempts.SelectedValue);
            DataAccess.SaveSetting("MinPasswordLength", ddlMinPassword.SelectedValue);
            DataAccess.SaveSetting("AllowRegistration", chkAllowRegistration.Checked ? "true" : "false");

            ShowMessage("All settings saved and persisted to database!", "alert-success");
        }

        private void UpdateSummary()
        {
            var s = DataAccess.GetAllSettings();

            lblCurrentSiteTitle.Text = Get(s, "SiteTitle", "Digital Museum");
            lblCurrentEmail.Text = Get(s, "ContactEmail", "admin@museum.com");
            lblCurrentVisibility.Text = Get(s, "ContentVisibility", "Public");
            lblCurrentRole.Text = Get(s, "DefaultRole", "Guest");
            lblCurrentMaxLogin.Text = Get(s, "MaxLoginAttempts", "5") + " attempts";
            lblCurrentMinPassword.Text = Get(s, "MinPasswordLength", "6") + " characters";
            lblCurrentRegistration.Text = !s.ContainsKey("AllowRegistration")
                || s["AllowRegistration"] == "true" ? "✅ Enabled" : "❌ Disabled";
        }

        private string Get(Dictionary<string, string> s, string key, string fallback)
        {
            return s.ContainsKey(key) ? s[key] : fallback;
        }

        private void TrySet(DropDownList ddl, Dictionary<string, string> s, string key, string fallback)
        {
            string val = s.ContainsKey(key) ? s[key] : fallback;
            try { ddl.SelectedValue = val; } catch { ddl.SelectedIndex = 0; }
        }

        private void ShowMessage(string message, string cssClass)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "alert d-block mb-3 " + cssClass;
            lblMessage.Visible = true;
        }
    }
}