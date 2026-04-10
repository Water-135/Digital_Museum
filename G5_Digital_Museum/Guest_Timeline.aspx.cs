using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace G5_Digital_Museum
{
    public partial class Guest_Timeline : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadTimelineEvents();
            }
        }

        private void LoadTimelineEvents()
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = @"
                        SELECT EventID, EventDate, EventTitle, EventDescription, Source
                        FROM TimelineEvents
                        WHERE IsPublished = 1
                        ORDER BY EventDate ASC";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    conn.Open();

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        gvTimelineEvents.DataSource = dt;
                        gvTimelineEvents.DataBind();
                    }
                    else
                    {
                        lblTimelineMsg.Text = "Additional timeline events will be displayed here once added to the database.";
                        lblTimelineMsg.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                gvTimelineEvents.Visible = false;
                lblTimelineMsg.Text = "DB Error: " + ex.Message;
                lblTimelineMsg.Visible = true;
                System.Diagnostics.Debug.WriteLine("Timeline DB Error: " + ex.Message);
            }
        }
    }
}
