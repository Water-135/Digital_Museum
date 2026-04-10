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
    public partial class Instructor_Feedback : System.Web.UI.Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        private int OpenFeedbackID
        {
            get => ViewState["OpenFBID"] is int i ? i : 0;
            set => ViewState["OpenFBID"] = value;
        }

        // ═══════════════════════════════════════════════════
        //  PAGE LOAD
        // ═══════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadFeedback();
                LoadComments();
            }
            else if (OpenFeedbackID > 0)
                PopulateModal(OpenFeedbackID);
        }

        // ═══════════════════════════════════════════════════
        //  LOAD FEEDBACK TABLE
        // ═══════════════════════════════════════════════════
        private void LoadFeedback(string status = "", string rating = "")
        {
            string sql = @"
                SELECT f.FeedbackID,
                       ISNULL(f.GuestName,'Anonymous') AS VisitorName,
                       ISNULL(f.GuestEmail,'')          AS GuestEmail,
                       f.Subject, f.Rating, f.Status,
                       f.InstructorNote, f.InstructorReply,
                       LEFT(f.Message,100) + CASE WHEN LEN(f.Message)>100
                           THEN '...' ELSE '' END        AS Preview,
                       CONVERT(VARCHAR(10),f.SubmittedAt,103) AS SubmitDate
                FROM   Feedback f
                WHERE  (@Status = '' OR f.Status = @Status)
                  AND  (@Rating IS NULL OR f.Rating = @Rating)
                ORDER  BY f.SubmittedAt DESC";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.Parameters.AddWithValue("@Status", status ?? "");
                cmd.Parameters.AddWithValue("@Rating",
                    string.IsNullOrEmpty(rating)
                        ? (object)DBNull.Value
                        : (object)int.Parse(rating));
                conn.Open();
                da.Fill(dt);
            }

            rptFeedback.DataSource = dt;
            rptFeedback.DataBind();

            int pending = 0, reviewed = 0, rejected = 0;
            foreach (DataRow r in dt.Rows)
                switch (r["Status"].ToString())
                {
                    case "Pending": pending++; break;
                    case "Reviewed": reviewed++; break;
                    case "Rejected": rejected++; break;
                }

            lblCountPending.Text = pending.ToString();
            lblCountReviewed.Text = reviewed.ToString();
            lblCountRejected.Text = rejected.ToString();
            lblCount.Text = $"{dt.Rows.Count} submission(s) — " +
                            $"{pending} pending · {reviewed} reviewed · {rejected} rejected";
        }

        // ═══════════════════════════════════════════════════
        //  LOAD COMMENTS TABLE
        // ═══════════════════════════════════════════════════
        private void LoadComments(string ratingFilter = "")
        {
            string sql = @"
                SELECT c.CommentID,
                       u.FullName                               AS UserName,
                       u.Email                                  AS UserEmail,
                       e.Title                                  AS ExhibitionTitle,
                       c.Rating,
                       LEFT(c.CommentText,120) + CASE WHEN LEN(c.CommentText)>120
                           THEN '...' ELSE '' END               AS Preview,
                       c.CommentText,
                       CONVERT(VARCHAR(10),c.CreatedAt,103)     AS CreatedDate
                FROM   Comments c
                INNER JOIN Users       u ON u.UserID       = c.UserID
                INNER JOIN Exhibitions e ON e.ExhibitionID = c.ExhibitionID
                WHERE  (@Rating IS NULL OR c.Rating = @Rating)
                ORDER  BY c.CreatedAt DESC";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.Parameters.AddWithValue("@Rating",
                    string.IsNullOrEmpty(ratingFilter)
                        ? (object)DBNull.Value
                        : (object)int.Parse(ratingFilter));
                conn.Open();
                da.Fill(dt);
            }

            rptComments.DataSource = dt;
            rptComments.DataBind();

            lblCommentCount.Text = $"{dt.Rows.Count} comment(s) across all exhibitions";
        }

        // ═══════════════════════════════════════════════════
        //  FILTER — FEEDBACK
        // ═══════════════════════════════════════════════════
        protected void btnApply_Click(object sender, EventArgs e)
        {
            LoadFeedback(ddlStatus.SelectedValue, ddlRating.SelectedValue);
            LoadComments(); // keep comments refreshed
        }

        // ═══════════════════════════════════════════════════
        //  FILTER — COMMENTS
        // ═══════════════════════════════════════════════════
        protected void btnApplyComment_Click(object sender, EventArgs e)
        {
            LoadComments(ddlCommentRating.SelectedValue);
            LoadFeedback(ddlStatus.SelectedValue, ddlRating.SelectedValue);
        }

        // ═══════════════════════════════════════════════════
        //  DELETE COMMENT
        // ═══════════════════════════════════════════════════
        protected void btnDeleteComment_Click(object sender, EventArgs e)
        {
            int id = Convert.ToInt32(((Button)sender).CommandArgument);

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "DELETE FROM Comments WHERE CommentID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", id);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            lblCommentActionMsg.Text = "✓ Comment deleted.";
            lblCommentActionMsg.ForeColor = System.Drawing.Color.FromArgb(94, 203, 138);
            LoadComments(ddlCommentRating.SelectedValue);
            LoadFeedback(ddlStatus.SelectedValue, ddlRating.SelectedValue);
        }

        // ═══════════════════════════════════════════════════
        //  TABLE: VIEW FEEDBACK
        // ═══════════════════════════════════════════════════
        protected void btnView_Click(object sender, EventArgs e)
        {
            int id = Convert.ToInt32(((Button)sender).CommandArgument);
            OpenFeedbackID = id;
            hfViewID.Value = id.ToString();
            PopulateModal(id);
            LoadFeedback(ddlStatus.SelectedValue, ddlRating.SelectedValue);
            LoadComments(ddlCommentRating.SelectedValue);
        }

        // ═══════════════════════════════════════════════════
        //  TABLE: QUICK APPROVE / REJECT
        // ═══════════════════════════════════════════════════
        protected void btnReview_Click(object sender, EventArgs e) =>
            UpdateStatus(((Button)sender).CommandArgument, "Reviewed");

        protected void btnReject_Click(object sender, EventArgs e) =>
            UpdateStatus(((Button)sender).CommandArgument, "Rejected");

        // ═══════════════════════════════════════════════════
        //  MODAL FOOTER: APPROVE / REJECT
        // ═══════════════════════════════════════════════════
        protected void btnModalApprove_Click(object sender, EventArgs e)
        {
            if (OpenFeedbackID > 0) UpdateStatus(OpenFeedbackID.ToString(), "Reviewed");
        }
        protected void btnModalReject_Click(object sender, EventArgs e)
        {
            if (OpenFeedbackID > 0) UpdateStatus(OpenFeedbackID.ToString(), "Rejected");
        }

        // ═══════════════════════════════════════════════════
        //  SAVE PRIVATE NOTE
        // ═══════════════════════════════════════════════════
        protected void btnSaveNote_Click(object sender, EventArgs e)
        {
            if (OpenFeedbackID == 0) return;
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(@"
                UPDATE Feedback
                SET    InstructorNote = @Note,
                       ReviewedAt     = GETDATE()
                WHERE  FeedbackID     = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@Note", txtNote.Text.Trim());
                cmd.Parameters.AddWithValue("@ID", OpenFeedbackID);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            ShowMsg(lblNoteMsg, "✓ Private note saved.", true);
            PopulateModal(OpenFeedbackID);
            LoadFeedback(ddlStatus.SelectedValue, ddlRating.SelectedValue);
            LoadComments(ddlCommentRating.SelectedValue);
        }

        protected void btnClearNote_Click(object sender, EventArgs e)
        {
            if (OpenFeedbackID == 0) return;
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE Feedback SET InstructorNote=NULL WHERE FeedbackID=@ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", OpenFeedbackID);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            txtNote.Text = "";
            ShowMsg(lblNoteMsg, "Note cleared.", false);
            PopulateModal(OpenFeedbackID);
            LoadFeedback(ddlStatus.SelectedValue, ddlRating.SelectedValue);
            LoadComments(ddlCommentRating.SelectedValue);
        }

        // ═══════════════════════════════════════════════════
        //  SAVE PUBLIC REPLY
        // ═══════════════════════════════════════════════════
        protected void btnSaveReply_Click(object sender, EventArgs e)
        {
            if (OpenFeedbackID == 0) return;
            if (string.IsNullOrWhiteSpace(txtReply.Text))
            { ShowMsg(lblReplyMsg, "Reply cannot be empty.", false); return; }

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(@"
                UPDATE Feedback
                SET    InstructorReply = @Reply,
                       ReplyAt         = GETDATE(),
                       Status          = CASE WHEN Status = 'Pending'
                                              THEN 'Reviewed' ELSE Status END
                WHERE  FeedbackID      = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@Reply", txtReply.Text.Trim());
                cmd.Parameters.AddWithValue("@ID", OpenFeedbackID);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            ShowMsg(lblReplyMsg, "✓ Reply published — guests can now see it.", true);
            PopulateModal(OpenFeedbackID);
            LoadFeedback(ddlStatus.SelectedValue, ddlRating.SelectedValue);
            LoadComments(ddlCommentRating.SelectedValue);
        }

        protected void btnDeleteReply_Click(object sender, EventArgs e)
        {
            if (OpenFeedbackID == 0) return;
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(@"
                UPDATE Feedback
                SET    InstructorReply = NULL,
                       ReplyAt         = NULL
                WHERE  FeedbackID      = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", OpenFeedbackID);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            txtReply.Text = "";
            ShowMsg(lblReplyMsg, "Reply removed from public view.", false);
            PopulateModal(OpenFeedbackID);
            LoadFeedback(ddlStatus.SelectedValue, ddlRating.SelectedValue);
            LoadComments(ddlCommentRating.SelectedValue);
        }

        // ═══════════════════════════════════════════════════
        //  POPULATE MODAL
        // ═══════════════════════════════════════════════════
        private void PopulateModal(int id)
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT *,
                       CONVERT(VARCHAR(20),SubmittedAt,113) AS SubmitFmt,
                       CONVERT(VARCHAR(20),ReviewedAt, 113) AS ReviewFmt,
                       CONVERT(VARCHAR(20),ReplyAt,    113) AS ReplyFmt
                FROM   Feedback
                WHERE  FeedbackID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", id);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return;

                    string name = r["GuestName"] == DBNull.Value ? "Anonymous" : r["GuestName"].ToString();
                    string email = r["GuestEmail"] == DBNull.Value ? "" : r["GuestEmail"].ToString();
                    string subject = r["Subject"] == DBNull.Value ? "" : r["Subject"].ToString();
                    string status = r["Status"].ToString();
                    int? rating = r["Rating"] == DBNull.Value ? (int?)null : Convert.ToInt32(r["Rating"]);
                    string message = r["Message"].ToString();
                    string note = r["InstructorNote"] == DBNull.Value ? "" : r["InstructorNote"].ToString();
                    string reply = r["InstructorReply"] == DBNull.Value ? "" : r["InstructorReply"].ToString();
                    string subDate = r["SubmitFmt"].ToString();
                    string revDate = r["ReviewFmt"] == DBNull.Value ? "" : r["ReviewFmt"].ToString();
                    string repDate = r["ReplyFmt"] == DBNull.Value ? "" : r["ReplyFmt"].ToString();

                    lblDetailName.Text =
                        Server.HtmlEncode(name) +
                        (!string.IsNullOrEmpty(email)
                            ? $" <span style='font-size:12px;color:#666;font-weight:400;'>({Server.HtmlEncode(email)})</span>"
                            : "");

                    lblDetailMeta.Text =
                        (string.IsNullOrEmpty(subject) ? "" :
                            $"Subject: <strong>{Server.HtmlEncode(subject)}</strong> &nbsp;·&nbsp; ") +
                        $"Status: <strong style='color:#c4a44a;'>{status}</strong>";

                    lblDetailDate.Text = $"Submitted: {subDate}";
                    lblDetailRating.Text = rating.HasValue
                        ? new string('★', rating.Value) +
                          $"<span style='color:#222;'>{new string('★', 5 - rating.Value)}</span>"
                        : "";
                    lblDetailMessage.Text = Server.HtmlEncode(message);

                    if (!string.IsNullOrEmpty(note))
                    {
                        pnlExistingNote.Visible = true;
                        lblExistingNote.Text = Server.HtmlEncode(note);
                        lblNoteDate.Text = string.IsNullOrEmpty(revDate) ? "" : $"Last updated: {revDate}";
                        txtNote.Text = note;
                    }
                    else { pnlExistingNote.Visible = false; txtNote.Text = ""; }

                    if (!string.IsNullOrEmpty(reply))
                    {
                        pnlExistingReply.Visible = true;
                        lblExistingReply.Text = Server.HtmlEncode(reply);
                        lblReplyDate.Text = string.IsNullOrEmpty(repDate) ? "" : $"Published: {repDate}";
                        txtReply.Text = reply;
                    }
                    else { pnlExistingReply.Visible = false; txtReply.Text = ""; }
                }
            }
        }

        // ═══════════════════════════════════════════════════
        //  UPDATE STATUS
        // ═══════════════════════════════════════════════════
        private void UpdateStatus(string idStr, string newStatus)
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(@"
                UPDATE Feedback
                SET    Status     = @Status,
                       ReviewedAt = GETDATE()
                WHERE  FeedbackID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@Status", newStatus);
                cmd.Parameters.AddWithValue("@ID", int.Parse(idStr));
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            lblActionMsg.Text = $"✓ Marked as {newStatus}.";
            lblActionMsg.ForeColor = System.Drawing.Color.FromArgb(94, 203, 138);
            if (OpenFeedbackID > 0) PopulateModal(OpenFeedbackID);
            LoadFeedback(ddlStatus.SelectedValue, ddlRating.SelectedValue);
            LoadComments(ddlCommentRating.SelectedValue);
        }

        // ═══════════════════════════════════════════════════
        //  HELPERS
        // ═══════════════════════════════════════════════════
        private void ShowMsg(Label lbl, string msg, bool ok)
        {
            lbl.Text = msg;
            lbl.ForeColor = ok
                ? System.Drawing.Color.FromArgb(94, 203, 138)
                : System.Drawing.Color.FromArgb(196, 164, 74);
        }
    }
}