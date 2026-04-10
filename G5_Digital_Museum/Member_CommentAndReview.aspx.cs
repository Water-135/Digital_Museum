using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using System.Xml.Linq;

namespace G5_Digital_Museum
{
    public partial class Member_CommentAndReview : System.Web.UI.Page
    {
        private readonly string _cs = ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            RequireLogin();

            if (!IsPostBack)
            {
                BindExhibitionDropdown();
                BindComments();
            }
        }

        private void RequireLogin()
        {
            if (Session["UserID"] == null)
                Response.Redirect("Member_Login.aspx");
        }

        private void BindExhibitionDropdown()
        {
            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(@"
SELECT ExhibitionID, Title
FROM Exhibitions
WHERE IsActive = 1
ORDER BY ExhibitionID", con))
            {
                con.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    ddlExhibition.DataSource = dr;
                    ddlExhibition.DataValueField = "ExhibitionID";
                    ddlExhibition.DataTextField = "Title";
                    ddlExhibition.DataBind();
                }
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            lblMsg.Text = "";
            lblMsg.CssClass = "";

            int userId = Convert.ToInt32(Session["UserID"]);
            int exhibitionId = Convert.ToInt32(ddlExhibition.SelectedValue);
            int rating = Convert.ToInt32(ddlRating.SelectedValue);
            string comment = (txtComment.Text ?? "").Trim();

            if (comment.Length < 3)
            {
                lblMsg.CssClass = "aspnet-validator";
                lblMsg.Text = "Please write a meaningful comment.";
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(_cs))
                using (SqlCommand cmd = new SqlCommand(@"
INSERT INTO Comments(UserID, ExhibitionID, Rating, CommentText)
VALUES(@UserID, @ExhibitionID, @Rating, @CommentText)", con))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@ExhibitionID", exhibitionId);
                    cmd.Parameters.AddWithValue("@Rating", rating);
                    cmd.Parameters.AddWithValue("@CommentText", comment);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                lblMsg.CssClass = "success-msg";
                lblMsg.Text = "Comment submitted successfully.";
                txtComment.Text = "";

                BindComments();
            }
            catch (Exception ex)
            {
                lblMsg.CssClass = "aspnet-validator";
                lblMsg.Text = "Submit failed: " + ex.Message;
            }
        }

        private void BindComments()
        {
            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(@"
SELECT TOP 50
    c.CommentID,
    c.UserID,
    e.Title AS Exhibition,
    u.FullName AS UserName,
    c.Rating,
    c.CommentText,
    c.CreatedAt
FROM Comments c
INNER JOIN Exhibitions e ON e.ExhibitionID = c.ExhibitionID
INNER JOIN Users u ON u.UserID = c.UserID
ORDER BY c.CreatedAt DESC", con))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvComments.DataSource = dt;
                gvComments.DataBind();
            }
        }

        protected void gvComments_RowEditing(object sender, System.Web.UI.WebControls.GridViewEditEventArgs e)
        {
            gvComments.EditIndex = e.NewEditIndex;
            BindComments();
        }
        protected void gvComments_RowCancelingEdit(object sender, System.Web.UI.WebControls.GridViewCancelEditEventArgs e)
        {
            gvComments.EditIndex = -1;
            BindComments();
        }

        protected void gvComments_RowUpdating(object sender, System.Web.UI.WebControls.GridViewUpdateEventArgs e)
        {
            lblMsg.Text = "";
            lblMsg.CssClass = "";

            int currentUserId = Convert.ToInt32(Session["UserID"]);
            int commentId = Convert.ToInt32(gvComments.DataKeys[e.RowIndex].Values["CommentID"]);
            int commentUserId = Convert.ToInt32(gvComments.DataKeys[e.RowIndex].Values["UserID"]);

            if (currentUserId != commentUserId)
            {
                lblMsg.CssClass = "aspnet-validator";
                lblMsg.Text = "You can only edit your own comment.";
                gvComments.EditIndex = -1;
                BindComments();
                return;
            }

            GridViewRow row = gvComments.Rows[e.RowIndex];

            TextBox txtEditComment = (TextBox)row.FindControl("txtEditComment");
            string updatedComment = (txtEditComment.Text ?? "").Trim();

            int updatedRating;
            if (!int.TryParse(e.NewValues["Rating"]?.ToString(), out updatedRating))
            {
                updatedRating = 5;
            }

            if (updatedComment.Length < 3)
            {
                lblMsg.CssClass = "aspnet-validator";
                lblMsg.Text = "Please write a meaningful comment.";
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(_cs))
                using (SqlCommand cmd = new SqlCommand(@"
UPDATE Comments
SET Rating = @Rating,
    CommentText = @CommentText
WHERE CommentID = @CommentID
  AND UserID = @UserID", con))
                {
                    cmd.Parameters.AddWithValue("@Rating", updatedRating);
                    cmd.Parameters.AddWithValue("@CommentText", updatedComment);
                    cmd.Parameters.AddWithValue("@CommentID", commentId);
                    cmd.Parameters.AddWithValue("@UserID", currentUserId);

                    con.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        lblMsg.CssClass = "success-msg";
                        lblMsg.Text = "Comment updated successfully.";
                    }
                    else
                    {
                        lblMsg.CssClass = "aspnet-validator";
                        lblMsg.Text = "Update failed.";
                    }
                }

                gvComments.EditIndex = -1;
                BindComments();
            }
            catch (Exception ex)
            {
                lblMsg.CssClass = "aspnet-validator";
                lblMsg.Text = "Update failed: " + ex.Message;
            }
        }
        protected void gvComments_RowDeleting(object sender, System.Web.UI.WebControls.GridViewDeleteEventArgs e)
        {
            lblMsg.Text = "";
            lblMsg.CssClass = "";

            int currentUserId = Convert.ToInt32(Session["UserID"]);
            int commentId = Convert.ToInt32(gvComments.DataKeys[e.RowIndex].Values["CommentID"]);
            int commentUserId = Convert.ToInt32(gvComments.DataKeys[e.RowIndex].Values["UserID"]);

            if (currentUserId != commentUserId)
            {
                lblMsg.CssClass = "aspnet-validator";
                lblMsg.Text = "You can only delete your own comment.";
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(_cs))
                using (SqlCommand cmd = new SqlCommand(@"
DELETE FROM Comments
WHERE CommentID = @CommentID
  AND UserID = @UserID", con))
                {
                    cmd.Parameters.AddWithValue("@CommentID", commentId);
                    cmd.Parameters.AddWithValue("@UserID", currentUserId);

                    con.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        lblMsg.CssClass = "success-msg";
                        lblMsg.Text = "Comment deleted successfully.";
                    }
                    else
                    {
                        lblMsg.CssClass = "aspnet-validator";
                        lblMsg.Text = "Delete failed.";
                    }
                }

                gvComments.EditIndex = -1;
                BindComments();
            }
            catch (Exception ex)
            {
                lblMsg.CssClass = "aspnet-validator";
                lblMsg.Text = "Delete failed: " + ex.Message;
            }
        }

        protected void gvComments_RowDataBound(object sender, System.Web.UI.WebControls.GridViewRowEventArgs e)
        {
            if (e.Row.RowType == System.Web.UI.WebControls.DataControlRowType.DataRow)
            {
                if (Session["UserID"] == null) return;

                int currentUserId = Convert.ToInt32(Session["UserID"]);
                int rowUserId = Convert.ToInt32(gvComments.DataKeys[e.Row.RowIndex].Values["UserID"]);

                if (currentUserId != rowUserId)
                {
                    e.Row.Cells[e.Row.Cells.Count - 1].Controls.Clear();
                    e.Row.Cells[e.Row.Cells.Count - 1].Text = "<span style='color:#888;'>View Only</span>";
                }
            }
        }
    }
}