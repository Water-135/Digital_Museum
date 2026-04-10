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
    public partial class Instructor_Homepage : System.Web.UI.Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadDashboard();
        }

        private void LoadDashboard()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Metric counts
                    lblTotalExhibitions.Text = Scalar(conn, "SELECT COUNT(*) FROM Exhibitions WHERE IsActive=1");
                    lblPublishedExh.Text = Scalar(conn, "SELECT COUNT(*) FROM Exhibitions WHERE IsActive=1 AND Status='Published'");
                    lblDraftExh.Text = Scalar(conn, "SELECT COUNT(*) FROM Exhibitions WHERE IsActive=1 AND Status='Draft'");
                    lblTotalModules.Text = Scalar(conn, "SELECT COUNT(*) FROM Modules WHERE IsActive=1");
                    lblPublishedMod.Text = Scalar(conn, "SELECT COUNT(*) FROM Modules WHERE IsActive=1 AND Status='Published'");
                    lblTotalQuizzes.Text = Scalar(conn, "SELECT COUNT(*) FROM Quizzes WHERE IsActive=1");

                    int pending = Convert.ToInt32(Scalar(conn, "SELECT COUNT(*) FROM Feedback WHERE Status='Pending'"));
                    lblPendingFeedback.Text = pending.ToString();
                    lblPendingBadge.Text = pending.ToString();
                    lblSnapPending.Text = pending.ToString();
                    lblSnapPublished.Text = lblPublishedExh.Text;
                    lblSnapDraft.Text = lblDraftExh.Text;
                    lblSnapQuizzes.Text = lblTotalQuizzes.Text;

                    // Recent exhibitions 
                    DataTable dtExh = Fill(conn, @"
                        SELECT TOP 3
                            ExhibitionID,
                            Title,
                            Category,
                            Status,
                            ISNULL(ImageUrl,'')                        AS ImageUrl,
                            ISNULL(LEFT(Description,90)+'...','')      AS Preview,
                            ISNULL(Timeline,'')                        AS Timeline,
                            CONVERT(VARCHAR(10),CreatedAt,103)         AS CreatedDate
                        FROM  Exhibitions
                        WHERE IsActive=1
                        ORDER BY CreatedAt DESC");
                    rptRecentExhibitions.DataSource = dtExh;
                    rptRecentExhibitions.DataBind();
                    lblNoExh.Visible = dtExh.Rows.Count == 0;

                    // Recent modules 
                    rptRecentModules.DataSource = Fill(conn, @"
                        SELECT TOP 5
                            ModuleID,
                            Title,
                            Status,
                            SortOrder,
                            CONVERT(VARCHAR(10),CreatedAt,103) AS CreatedDate
                        FROM  Modules
                        WHERE IsActive=1
                        ORDER BY CreatedAt DESC");
                    rptRecentModules.DataBind();

                    // Pending feedback 
                    DataTable dtFb = Fill(conn, @"
                        SELECT TOP 5
                            ISNULL(GuestName,'Anonymous')           AS VisitorName,
                            ISNULL(Subject,'No Subject')            AS Subject,
                            ISNULL(LEFT(Message,70)+'...','')       AS Preview,
                            ISNULL(CAST(Rating AS VARCHAR(2)),'-')  AS Rating,
                            CONVERT(VARCHAR(10),SubmittedAt,103)    AS SubmitDate
                        FROM  Feedback
                        WHERE Status='Pending'
                        ORDER BY SubmittedAt DESC");
                    rptRecentFeedback.DataSource = dtFb;
                    rptRecentFeedback.DataBind();
                    lblNoFeedback.Visible = dtFb.Rows.Count == 0;
                }
            }
            catch (Exception ex)
            {
                lblNoExh.Text = "Dashboard error: " + ex.Message;
                lblNoExh.Visible = true;
            }
        }

        private string Scalar(SqlConnection conn, string sql)
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn))
                return cmd.ExecuteScalar()?.ToString() ?? "0";
        }

        private DataTable Fill(SqlConnection conn, string sql)
        {
            DataTable dt = new DataTable();
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                da.Fill(dt);
            return dt;
        }
    }
}
