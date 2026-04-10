using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace G5_Digital_Museum
{
    public partial class Member_BrowseAndSearch : System.Web.UI.Page
    {
        private readonly string _cs =
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Member_Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                pnlResults.Visible = false;
                pnlResultsContent.Visible = false;
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            SearchAll();
        }

        protected void btnViewAll_Click(object sender, EventArgs e)
        {
            txtKeyword.Text = "";
            SearchAll();
        }

        private void SearchAll()
        {
            string keyword = txtKeyword.Text.Trim();

            DataTable dtExhibitions = SearchExhibitions(keyword);
            DataTable dtModules = SearchModules(keyword);
            DataTable dtQuizzes = SearchQuizzes(keyword);

            rptExhibitions.DataSource = dtExhibitions;
            rptExhibitions.DataBind();

            rptModules.DataSource = dtModules;
            rptModules.DataBind();

            rptQuizzes.DataSource = dtQuizzes;
            rptQuizzes.DataBind();

            pnlNoExhibitions.Visible = dtExhibitions.Rows.Count == 0;
            pnlNoModules.Visible = dtModules.Rows.Count == 0;
            pnlNoQuizzes.Visible = dtQuizzes.Rows.Count == 0;

            int total = dtExhibitions.Rows.Count + dtModules.Rows.Count + dtQuizzes.Rows.Count;

            lblSummary.Text = total + " result(s) found.";

            pnlResults.Visible = true;
            pnlResultsContent.Visible = true;
        }

        private DataTable SearchExhibitions(string keyword)
        {
            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(@"
        SELECT ExhibitionID, Title, Description
        FROM Exhibitions
        WHERE IsActive = 1
        AND Status = 'Published'
        AND (
            @Keyword = ''
            OR Title LIKE '%' + @Keyword + '%'
            OR Category LIKE '%' + @Keyword + '%'
            OR Description LIKE '%' + @Keyword + '%'
        )
        ORDER BY CreatedAt DESC", con))
            {
                cmd.Parameters.AddWithValue("@Keyword", keyword);

                DataTable dt = new DataTable();

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }

                return dt;
            }
        }

        private DataTable SearchModules(string keyword)
        {
            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(@"
        SELECT ModuleID, Title, Description
        FROM Modules
        WHERE IsActive = 1
        AND Status = 'Published'
        AND (
            @Keyword = ''
            OR Title LIKE '%' + @Keyword + '%'
            OR Description LIKE '%' + @Keyword + '%'
        )
        ORDER BY SortOrder, CreatedAt DESC", con))
            {
                cmd.Parameters.AddWithValue("@Keyword", keyword);

                DataTable dt = new DataTable();

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }

                return dt;
            }
        }

        private DataTable SearchQuizzes(string keyword)
        {
            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT QuizID, Title, QuizType, PassMark
                FROM Quizzes
                WHERE IsActive = 1
                AND (
                    @Keyword = ''
                    OR Title LIKE '%' + @Keyword + '%'
                    OR QuizType LIKE '%' + @Keyword + '%'
                )
                ORDER BY CreatedAt DESC", con))
            {
                cmd.Parameters.AddWithValue("@Keyword", keyword);

                DataTable dt = new DataTable();

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }

                return dt;
            }
        }

        protected string GetShortText(string text, int maxLength)
        {
            if (string.IsNullOrWhiteSpace(text))
                return "";

            if (text.Length <= maxLength)
                return text;

            return text.Substring(0, maxLength) + "...";
        }
    }
}