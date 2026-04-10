using System;
using System.Configuration;
using System.Data.SqlClient;

namespace G5_Digital_Museum
{
    public partial class Member_ExhibitionDetails : System.Web.UI.Page
    {
        private readonly string _cs =
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int exhibitionId;
                if (!int.TryParse(Request.QueryString["id"], out exhibitionId))
                {
                    ShowNotFound();
                    return;
                }

                LoadExhibition(exhibitionId);
            }
        }

        private void LoadExhibition(int exhibitionId)
        {
            string sql = @"
                SELECT ExhibitionID, Title, Category, Description, IncidentDate, Timeline,
                       StartDate, EndDate, Location, ImageUrl, Status, IsActive
                FROM Exhibitions
                WHERE ExhibitionID = @ExhibitionID
                  AND IsActive = 1";

            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@ExhibitionID", exhibitionId);
                con.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (!dr.Read())
                    {
                        ShowNotFound();
                        return;
                    }

                    pnlDetail.Visible = true;
                    pnlNotFound.Visible = false;

                    lblTitle.Text = dr["Title"].ToString();
                    lblCategory.Text = dr["Category"].ToString();

                    lblTimeline.Text = string.IsNullOrWhiteSpace(dr["Timeline"].ToString())
                        ? "-"
                        : dr["Timeline"].ToString();

                    lblLocation.Text = string.IsNullOrWhiteSpace(dr["Location"].ToString())
                        ? "Nanjing, China"
                        : dr["Location"].ToString();

                    if (dr["IncidentDate"] != DBNull.Value)
                    {
                        DateTime incidentDate = Convert.ToDateTime(dr["IncidentDate"]);
                        lblDate.Text = incidentDate.ToString("dd MMMM yyyy");
                    }
                    else if (dr["StartDate"] != DBNull.Value && dr["EndDate"] != DBNull.Value)
                    {
                        DateTime startDate = Convert.ToDateTime(dr["StartDate"]);
                        DateTime endDate = Convert.ToDateTime(dr["EndDate"]);
                        lblDate.Text = startDate.ToString("dd MMM yyyy") + " - " + endDate.ToString("dd MMM yyyy");
                    }
                    else
                    {
                        lblDate.Text = "-";
                    }

                    string imageUrl = dr["ImageUrl"] == DBNull.Value ? "" : dr["ImageUrl"].ToString();
                    if (string.IsNullOrWhiteSpace(imageUrl))
                    {
                        imgExhibition.ImageUrl = "https://via.placeholder.com/1200x650?text=No+Image";
                    }
                    else
                    {
                        imgExhibition.ImageUrl = imageUrl;
                    }

                    string description = dr["Description"] == DBNull.Value ? "" : dr["Description"].ToString();
                    litDescription.Text = "<p>" + Server.HtmlEncode(description).Replace("\n", "<br />") + "</p>";
                }
            }
        }

        private void ShowNotFound()
        {
            pnlDetail.Visible = false;
            pnlNotFound.Visible = true;
        }
    }
}