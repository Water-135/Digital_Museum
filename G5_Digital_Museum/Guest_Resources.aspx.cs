using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace G5_Digital_Museum
{
    public partial class Guest_Resources : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadResources();
            }
        }

        private void LoadResources()
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = @"
                        SELECT ResourceID, ResourceTitle, ResourceType, Author, YearPublished, ResourceURL, Description
                        FROM LearningResources
                        WHERE IsPublished = 1
                        ORDER BY YearPublished DESC";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    conn.Open();

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        gvResources.DataSource = dt;
                        gvResources.DataBind();
                    }
                    else
                    {
                        lblResourcesMsg.Text = "Additional resources will appear here once added to the database.";
                        lblResourcesMsg.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                gvResources.Visible = false;
                lblResourcesMsg.Text = "DB Error: " + ex.Message;
                lblResourcesMsg.Visible = true;
                System.Diagnostics.Debug.WriteLine("Resources DB Error: " + ex.Message);
            }
        }
    }
}
