using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace G5_Digital_Museum
{
    public partial class Guest_Gallery : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadGalleryItems();
            }
        }

        private void LoadGalleryItems()
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = @"
                        SELECT GalleryID, Title, Description, ImagePath, Category, YearTaken, Source
                        FROM GalleryItems
                        WHERE IsPublished = 1
                        ORDER BY YearTaken ASC";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    conn.Open();

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        dlGallery.DataSource = dt;
                        dlGallery.DataBind();
                    }
                    else
                    {
                        lblGalleryMsg.Text = "Gallery items will appear here once added by administrators.";
                        lblGalleryMsg.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                dlGallery.Visible = false;
                lblGalleryMsg.Text = "DB Error: " + ex.Message;
                lblGalleryMsg.Visible = true;
                System.Diagnostics.Debug.WriteLine("Gallery DB Error: " + ex.Message);
            }
        }
    }
}
