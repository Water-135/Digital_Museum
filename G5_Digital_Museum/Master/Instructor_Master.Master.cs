using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace G5_Digital_Museum.Master
{
    public partial class Instructor_Master : System.Web.UI.MasterPage
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {

            if (!IsPostBack)
            {
                string name = Session["FullName"]?.ToString() ?? "Instructor";
                string initial = name.Length > 0 ? name[0].ToString().ToUpper() : "I";

                lblTopbarName.Text = Server.HtmlEncode(name);
                lblTopbarInitial.Text = initial;

                try
                {
                    using (SqlConnection conn = new SqlConnection(ConnStr))
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Feedback WHERE Status='Pending'", conn))
                    {
                        conn.Open();
                        int pending = Convert.ToInt32(cmd.ExecuteScalar());
                        if (pending > 0)
                        {
                            lblFeedbackBadge.Text = pending.ToString();
                            lblFeedbackBadge.Visible = true;
                        }
                    }
                }
                catch { /* badge is non-critical */ }
            }
        }

        // ── Sign Out──
        protected void btnSignOut_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Guest_Homepage.aspx");
        }

        public string GetNavClass(string pageName)
        {
            string current = System.IO.Path.GetFileNameWithoutExtension(
                Request.AppRelativeCurrentExecutionFilePath ?? "");
            return current.Equals(pageName, StringComparison.OrdinalIgnoreCase)
                ? "active" : "";
        }
    }
}