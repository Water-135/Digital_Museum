using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace G5_Digital_Museum
{
    public partial class Guest_Homepage : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadRecentFeedback();
            }
        }

        /// <summary>
        /// Loads the 3 most recent approved guestbook entries from the database.
        /// Demonstrates: SELECT (Display records) with ORDER BY and TOP clause.
        /// </summary>
        private void LoadRecentFeedback()
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = @"
                        SELECT TOP 3 FeedbackID, VisitorName, Email, Message, Rating, SubmittedDate
                        FROM Feedback
                        WHERE IsApproved = 1
                        ORDER BY SubmittedDate DESC";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    conn.Open();

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptRecentFeedback.DataSource = dt;
                        rptRecentFeedback.DataBind();
                        lblNoFeedback.Visible = false;
                    }
                    else
                    {
                        rptRecentFeedback.Visible = false;
                        lblNoFeedback.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                rptRecentFeedback.Visible = false;
                lblNoFeedback.Text = "DB Error: " + ex.Message;
                lblNoFeedback.Visible = true;
                System.Diagnostics.Debug.WriteLine("DB Error on Homepage: " + ex.Message);
            }
        }

        protected string GetStarRating(int rating)
        {
            string stars = "";
            for (int i = 0; i < 5; i++)
            {
                stars += (i < rating) ? "&#9733; " : "&#9734; ";
            }
            return stars;
        }
    }
}
