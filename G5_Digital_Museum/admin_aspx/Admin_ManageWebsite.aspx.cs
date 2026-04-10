using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using G5_Digital_Museum.Helpers;

namespace G5_Digital_Museum.Admin_ASPX
{
    public partial class Admin_ManageWebsite : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadExhibits();
                LoadBannerSettings();
            }
        }

        private void LoadExhibits()
        {
            gvExhibits.DataSource = DataAccess.GetAllExhibits();
            gvExhibits.DataBind();
        }

        private void LoadBannerSettings()
        {
            txtBannerHeadline.Text = Session["BannerHeadline"] != null ? Session["BannerHeadline"].ToString() : "";
            txtBannerImageUrl.Text = Session["BannerImageUrl"] != null ? Session["BannerImageUrl"].ToString() : "";
            txtBannerSubtext.Text = Session["BannerSubtext"] != null ? Session["BannerSubtext"].ToString() : "";
        }

        protected void btnSaveBanner_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtBannerHeadline.Text.Trim()))
            {
                ShowMessage("Banner headline cannot be empty.", "alert-danger");
                return;
            }
            Session["BannerHeadline"] = txtBannerHeadline.Text.Trim();
            Session["BannerImageUrl"] = txtBannerImageUrl.Text.Trim();
            Session["BannerSubtext"] = txtBannerSubtext.Text.Trim();
            ShowMessage("Banner settings saved successfully!", "alert-success");
        }

        protected void btnAddExhibit_Click(object sender, EventArgs e)
        {
            string title = txtAddTitle.Text.Trim();
            string description = txtAddDescription.Text.Trim();
            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(description))
            {
                lblAddError.Text = "Title and description are required.";
                lblAddError.Visible = true;
                ScriptManager.RegisterStartupScript(this, GetType(), "showAdd",
                    "new bootstrap.Modal(document.getElementById('addExhibitModal')).show();", true);
                return;
            }
            int displayOrder = 0;
            int.TryParse(txtAddDisplayOrder.Text.Trim(), out displayOrder);
            bool success = DataAccess.AddExhibit(
                title, description, txtAddPeriod.Text.Trim(),
                txtAddImageUrl.Text.Trim(), "", "",
                ddlAddCategory.SelectedValue, displayOrder, 1);
            if (success) { ShowMessage("Exhibit added successfully!", "alert-success"); ClearAddForm(); LoadExhibits(); }
            else ShowMessage("Failed to add exhibit.", "alert-danger");
        }

        protected void gvExhibits_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int exhibitId = Convert.ToInt32(e.CommandArgument);
            switch (e.CommandName)
            {
                case "DeleteExhibit":
                    DataAccess.DeleteExhibit(exhibitId);
                    ShowMessage("Exhibit deleted.", "alert-success");
                    break;
                case "PublishExhibit":
                    DataAccess.UpdateExhibitStatus(exhibitId, "Published");
                    ShowMessage("Exhibit published.", "alert-success");
                    break;
                case "ArchiveExhibit":
                    DataAccess.UpdateExhibitStatus(exhibitId, "Archived");
                    ShowMessage("Exhibit archived.", "alert-warning");
                    break;
                case "RestoreExhibit":
                    DataAccess.UpdateExhibitStatus(exhibitId, "Draft");
                    ShowMessage("Exhibit restored to Draft.", "alert-success");
                    break;
                case "FeatureExhibit":
                    DataAccess.ToggleExhibitFeatured(exhibitId, true);
                    ShowMessage("Exhibit marked as featured.", "alert-success");
                    break;
                case "UnfeatureExhibit":
                    DataAccess.ToggleExhibitFeatured(exhibitId, false);
                    ShowMessage("Exhibit unfeatured.", "alert-success");
                    break;
            }
            LoadExhibits();
        }

        protected void btnSaveEdit_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hdnEditExhibitId.Value)) return;
            int exhibitId = Convert.ToInt32(hdnEditExhibitId.Value);
            string title = txtEditTitle.Text.Trim();
            string description = txtEditDescription.Text.Trim();
            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(description))
            {
                lblEditError.Text = "Title and description are required.";
                lblEditError.Visible = true;
                ScriptManager.RegisterStartupScript(this, GetType(), "showEditModal2",
                    "new bootstrap.Modal(document.getElementById('editExhibitModal')).show();", true);
                return;
            }
            int displayOrder = 0;
            int.TryParse(txtEditDisplayOrder.Text.Trim(), out displayOrder);
            bool success = DataAccess.UpdateExhibit(
                exhibitId, title, description, txtEditPeriod.Text.Trim(),
                txtEditImageUrl.Text.Trim(), "", "",
                ddlEditCategory.SelectedValue, displayOrder);
            if (success)
            {
                ShowMessage("Exhibit updated successfully!", "alert-success");
                LoadExhibits();
            }
            else
            {
                lblEditError.Text = "Failed to update exhibit.";
                lblEditError.Visible = true;
                ScriptManager.RegisterStartupScript(this, GetType(), "showEditModal2",
                    "new bootstrap.Modal(document.getElementById('editExhibitModal')).show();", true);
            }
        }

        private void ClearAddForm()
        {
            txtAddTitle.Text = "";
            txtAddDescription.Text = "";
            txtAddPeriod.Text = "";
            txtAddImageUrl.Text = "";
            txtAddDisplayOrder.Text = "0";
            ddlAddCategory.SelectedIndex = 0;
            lblAddError.Visible = false;
        }

        private void ShowMessage(string message, string cssClass)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "alert d-block mb-3 " + cssClass;
            lblMessage.Visible = true;
        }

        protected string EncodeForJs(object val)
        {
            if (val == null || val == DBNull.Value) return "";
            return val.ToString()
                .Replace("\\", "\\\\").Replace("'", "\\'")
                .Replace("\"", "&quot;").Replace("\r\n", "\\n")
                .Replace("\n", "\\n").Replace("\r", "\\n");
        }

        protected bool IsLocked(object status, object createdDate)
        {
            if (status == null || status == DBNull.Value) return false;
            return status.ToString() == "Published";
        }

        protected bool GetIsFeatured(object val)
        {
            return val != null && val != DBNull.Value && Convert.ToBoolean(val);
        }

        protected string RenderStatusBadge(object status)
        {
            string s = status?.ToString() ?? "Draft";
            string color = s == "Published" ? "#2ecc71" : s == "Draft" ? "#c4a44a" : "#777";
            return $"<span style='color:{color};font-weight:600;font-size:12px;'>● {s}</span>";
        }

        protected string RenderThumb(object imageUrl)
        {
            string url = (imageUrl == null || imageUrl == DBNull.Value) ? "" : imageUrl.ToString().Trim();
            if (string.IsNullOrEmpty(url)) return "<span class='no-img'>No image</span>";
            if (!url.StartsWith("http://") && !url.StartsWith("https://") && !url.StartsWith("/"))
                url = "https://" + url;
            return "<img src='" + url + "' class='thumb-img' onerror=\"this.style.display='none';\" />";
        }

        protected string RenderEditButton(object id, object title, object category, object period,
                                          object displayOrder, object imageUrl, object videoUrl,
                                          object audioUrl, object description, object status, object createdDate)
        {
            if (IsLocked(status, createdDate))
                return "<span class='btn btn-sm btn-secondary action-btn' title='Published over 3 months ago'>🔒 Locked</span>";
            string js = "openEditModal("
                + "'" + EncodeForJs(id) + "',"
                + "'" + EncodeForJs(title) + "',"
                + "'" + EncodeForJs(category) + "',"
                + "'" + EncodeForJs(period) + "',"
                + "'" + EncodeForJs(displayOrder) + "',"
                + "'" + EncodeForJs(imageUrl) + "',"
                + "'" + EncodeForJs(videoUrl) + "',"
                + "'" + EncodeForJs(audioUrl) + "',"
                + "'" + EncodeForJs(description) + "'"
                + ")";
            return "<button type='button' class='btn btn-sm btn-primary action-btn' onclick=\"" + js + "\">Edit</button>";
        }
    }
}