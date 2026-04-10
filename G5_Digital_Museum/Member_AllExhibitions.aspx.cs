using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace G5_Digital_Museum
{
    public partial class Member_AllExhibitions : System.Web.UI.Page
    {
        private readonly string _cs =
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCategories();
                LoadStatus();
                LoadExhibitions();
            }
        }

        private void LoadCategories()
        {
            ddlCategory.Items.Clear();
            ddlCategory.Items.Add(new ListItem("All Categories", ""));

            using (SqlConnection con = new SqlConnection(_cs))
            {
                string sql = @"
SELECT DISTINCT Category
FROM Exhibitions
WHERE Status = 'Published'
ORDER BY Category";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            ddlCategory.Items.Add(
                                new ListItem(
                                    dr["Category"].ToString(),
                                    dr["Category"].ToString()
                                )
                            );
                        }
                    }
                }
            }
        }

        private void LoadStatus()
        {
            ddlStatus.Items.Clear();
            ddlStatus.Items.Add(new ListItem("All Status", ""));
            ddlStatus.Items.Add(new ListItem("Published", "Published"));


        }

        private void LoadExhibitions()
        {
            using (SqlConnection con = new SqlConnection(_cs))
            {
                string sql = @"
SELECT *
FROM Exhibitions
WHERE Status = 'Published'
AND (@Category = '' OR Category = @Category)";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@Category", ddlCategory.SelectedValue);

                    DataTable dt = new DataTable();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }

                    rptExhibitions.DataSource = dt;
                    rptExhibitions.DataBind();

                    lblCount.Text = dt.Rows.Count + " exhibition(s)";
                    pnlEmpty.Visible = (dt.Rows.Count == 0);
                }
            }
        }

        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadExhibitions();
        }

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
  
            LoadExhibitions();
        }

        protected string GetShortText(string text, int maxLength)
        {
            if (string.IsNullOrWhiteSpace(text))
                return "";

            if (text.Length <= maxLength)
                return text;

            return text.Substring(0, maxLength) + "...";
        }

        protected void btnSaveFavourite_Command(object sender, CommandEventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Member_Login.aspx");
                return;
            }

            int userId = Convert.ToInt32(Session["UserID"]);
            int exhibitionId = Convert.ToInt32(e.CommandArgument);

            using (SqlConnection con = new SqlConnection(_cs))
            {
                string checkSql = @"SELECT COUNT(*) FROM Favourites
                                    WHERE UserID = @UserID AND ExhibitionID = @ExhibitionID";

                using (SqlCommand checkCmd = new SqlCommand(checkSql, con))
                {
                    checkCmd.Parameters.AddWithValue("@UserID", userId);
                    checkCmd.Parameters.AddWithValue("@ExhibitionID", exhibitionId);

                    con.Open();
                    int exists = Convert.ToInt32(checkCmd.ExecuteScalar());
                    con.Close();

                    if (exists == 0)
                    {
                        string insertSql = @"INSERT INTO Favourites (UserID, ExhibitionID, SavedAt)
                                             VALUES (@UserID, @ExhibitionID, GETDATE())";

                        using (SqlCommand insertCmd = new SqlCommand(insertSql, con))
                        {
                            insertCmd.Parameters.AddWithValue("@UserID", userId);
                            insertCmd.Parameters.AddWithValue("@ExhibitionID", exhibitionId);

                            con.Open();
                            insertCmd.ExecuteNonQuery();
                            con.Close();
                        }
                    }
                }
            }
        }
    }
}