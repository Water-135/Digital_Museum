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
    public partial class Admin_ManageModules : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadModules();
        }

        private void LoadModules()
        {
            var dt = DataAccess.GetAllModules();
            gvModules.DataSource = dt;
            gvModules.DataBind();
            lblCount.Text = $"{dt.Rows.Count} module(s)";
        }

        private void LoadQuizzesForModule(int moduleId)
        {
            var dt = DataAccess.GetAllQuizzesWithAttempts();
            var filtered = dt.Clone();
            foreach (DataRow row in dt.Rows)
                if (row["ModuleTitle"].ToString() != "No Module")
                {
                    // filter by moduleId via second query
                }
            // Use direct filtered query
            var qt = DataAccess.GetQuizzesByModule(moduleId);
            gvQuizzes.DataSource = qt;
            gvQuizzes.DataBind();
            lblQuizCount.Text = $"{qt.Rows.Count} quiz(es) in this module";
        }

        protected void btnAddModule_Click(object sender, EventArgs e)
        {
            string title = txtAddTitle.Text.Trim();
            string desc = txtAddDescription.Text.Trim();
            if (string.IsNullOrEmpty(title))
            {
                lblAddError.Text = "Title is required.";
                lblAddError.Visible = true;
                ScriptManager.RegisterStartupScript(this, GetType(), "showAdd",
                    "new bootstrap.Modal(document.getElementById('addModuleModal')).show();", true);
                return;
            }
            int sortOrder = 0;
            int.TryParse(txtAddSortOrder.Text.Trim(), out sortOrder);
            bool ok = DataAccess.AddModule(title, desc, ddlAddStatus.SelectedValue, sortOrder);
            if (ok) { ShowMessage("Module added successfully!", "alert-success"); ClearAddForm(); LoadModules(); }
            else ShowMessage("Failed to add module.", "alert-danger");
        }

        protected void gvModules_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int moduleId = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "DeleteModule")
            {
                DataAccess.DeleteModule(moduleId);
                ShowMessage("Module deleted.", "alert-success");
                pnlEdit.Visible = false;
                LoadModules();
            }
            else if (e.CommandName == "EditModule")
            {
                LoadEditPanel(moduleId);
            }
        }

        protected void gvQuizzes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int quizId = Convert.ToInt32(e.CommandArgument);
            int moduleId = Convert.ToInt32(hdnModuleId.Value);
            if (e.CommandName == "EnableQuiz")
            {
                DataAccess.ToggleQuizActive(quizId, true);
                ShowEditMessage("Quiz enabled.", "alert-success");
            }
            else if (e.CommandName == "DisableQuiz")
            {
                DataAccess.ToggleQuizActive(quizId, false);
                ShowEditMessage("Quiz disabled.", "alert-warning");
            }
            LoadQuizzesForModule(moduleId);
        }

        private void LoadEditPanel(int moduleId)
        {
            DataRow row = DataAccess.GetModuleById(moduleId);
            if (row == null) return;
            hdnModuleId.Value = moduleId.ToString();
            txtEditTitle.Text = row["Title"].ToString();
            txtEditDescription.Text = row["Description"].ToString();
            ddlEditStatus.SelectedValue = row["Status"].ToString();
            txtEditSortOrder.Text = row["SortOrder"].ToString();
            pnlEdit.Visible = true;
            lblEditMessage.Visible = false;
            LoadQuizzesForModule(moduleId);
            ScriptManager.RegisterStartupScript(this, GetType(), "scrollEdit",
                "document.getElementById('editPanel').scrollIntoView({behavior:'smooth'});", true);
        }

        protected void btnSaveEdit_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hdnModuleId.Value)) return;
            int moduleId = Convert.ToInt32(hdnModuleId.Value);
            string title = txtEditTitle.Text.Trim();
            if (string.IsNullOrEmpty(title)) { ShowEditMessage("Title is required.", "alert-danger"); return; }
            int sortOrder = 0;
            int.TryParse(txtEditSortOrder.Text.Trim(), out sortOrder);
            bool ok = DataAccess.UpdateModule(moduleId, title, txtEditDescription.Text.Trim(),
                                              ddlEditStatus.SelectedValue, sortOrder);
            ShowEditMessage(ok ? "Module updated!" : "Update failed.", ok ? "alert-success" : "alert-danger");
            if (ok) LoadModules();
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            pnlEdit.Visible = false;
            hdnModuleId.Value = "";
        }

        private void ClearAddForm()
        {
            txtAddTitle.Text = "";
            txtAddDescription.Text = "";
            txtAddSortOrder.Text = "0";
            ddlAddStatus.SelectedIndex = 0;
            lblAddError.Visible = false;
        }

        private void ShowMessage(string msg, string css)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = "alert d-block mb-3 " + css;
            lblMessage.Visible = true;
        }

        private void ShowEditMessage(string msg, string css)
        {
            lblEditMessage.Text = msg;
            lblEditMessage.CssClass = "alert d-block mb-3 " + css;
            lblEditMessage.Visible = true;
        }

        protected string RenderStatusBadge(object status)
        {
            string s = status?.ToString() ?? "";
            string color = s == "Published" ? "#2ecc71" : s == "Draft" ? "#c4a44a" : "#777";
            return $"<span style='color:{color};font-weight:600;'>● {s}</span>";
        }

        protected string RenderAttemptBadge(object attempts)
        {
            int n = attempts == null || attempts == DBNull.Value ? 0 : Convert.ToInt32(attempts);
            string color = n == 0 ? "#e74c3c" : n < 5 ? "#c4a44a" : "#2ecc71";
            return $"<span style='color:{color};font-weight:700;'>{n}</span>";
        }

        protected bool GetIsActive(object val)
        {
            return val != null && val != DBNull.Value && Convert.ToBoolean(val);
        }
    }
}