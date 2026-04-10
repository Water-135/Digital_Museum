using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using G5_Digital_Museum.Helpers;

namespace G5_Digital_Museum.Admin_ASPX
{
    public partial class Admin_Feedback : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadFeedback();
        }

        private void LoadFeedback()
        {
            var dt = DataAccess.GetFilteredFeedback(
                ddlFilterStatus.SelectedValue,
                ddlSortBy.SelectedValue);
            rptFeedback.DataSource = dt;
            rptFeedback.DataBind();
            lblCount.Text = $"{dt.Rows.Count} feedback record(s)";
            lblNoFeedback.Visible = dt.Rows.Count == 0;
        }

        protected void btnFilter_Click(object sender, EventArgs e) { LoadFeedback(); }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ddlFilterStatus.SelectedIndex = 0;
            ddlSortBy.SelectedIndex = 0;
            LoadFeedback();
        }

        protected void rptFeedback_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "Approve")
            {
                DataAccess.UpdateFeedbackStatus(id, "Reviewed", "");
                ShowMessage("Feedback marked as reviewed.", "alert-success");
            }
            else if (e.CommandName == "Delete")
            {
                DataAccess.DeleteFeedback(id);
                ShowMessage("Feedback deleted.", "alert-success");
            }
            LoadFeedback();
        }

        private void ShowMessage(string message, string cssClass)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "alert d-block mb-3 " + cssClass;
            lblMessage.Visible = true;
        }
    }
}