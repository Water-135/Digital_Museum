using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace G5_Digital_Museum
{
    public partial class Member_SaveToFavourite : System.Web.UI.Page
    {
        private readonly string _cs = ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            RequireLogin();
            if (!IsPostBack) BindFav();
        }

        private void RequireLogin()
        {
            if (Session["UserID"] == null)
                Response.Redirect("Member_Login.aspx");
        }

        private void BindFav()
        {
            int userId = Convert.ToInt32(Session["UserID"]);

            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(@"
SELECT f.ExhibitionID, e.Title, e.Location, f.SavedAt
FROM Favourites f
INNER JOIN Exhibitions e ON e.ExhibitionID = f.ExhibitionID
WHERE f.UserID=@UserID
ORDER BY f.SavedAt DESC", con))
            {
                cmd.Parameters.AddWithValue("@UserID", userId);

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvFav.DataSource = dt;
                    gvFav.DataBind();
                }
            }
        }

        protected void gvFav_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName != "RemoveFav") return;

            int userId = Convert.ToInt32(Session["UserID"]);
            int exhibitionId = Convert.ToInt32(e.CommandArgument);

            try
            {
                using (SqlConnection con = new SqlConnection(_cs))
                using (SqlCommand cmd = new SqlCommand(
                    "DELETE FROM Favourites WHERE UserID=@UserID AND ExhibitionID=@ExhibitionID", con))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@ExhibitionID", exhibitionId);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                lblMsg.CssClass = "success-msg";
                lblMsg.Text = "Removed from favourite.";
                BindFav();
            }
            catch (Exception ex)
            {
                lblMsg.CssClass = "aspnet-validator";
                lblMsg.Text = "Remove failed: " + ex.Message;
            }
        }
    }
}