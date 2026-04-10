using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace G5_Digital_Museum
{
    public partial class Member_ModulesContent : System.Web.UI.Page
    {
        private readonly string _cs =
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int moduleId;

                if (!int.TryParse(Request.QueryString["id"], out moduleId))
                {
                    ShowNotFound();
                    return;
                }

                LoadModule(moduleId);
                LoadContents(moduleId);
            }
        }

        private void LoadModule(int moduleId)
        {
            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT Title, Description
                  FROM Modules
                  WHERE ModuleID=@ModuleID AND IsActive=1", con))
            {
                cmd.Parameters.AddWithValue("@ModuleID", moduleId);

                con.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (!dr.Read())
                    {
                        ShowNotFound();
                        return;
                    }

                    pnlModule.Visible = true;
                    pnlNotFound.Visible = false;

                    lblTitle.Text = dr["Title"].ToString();
                    lblDescription.Text = dr["Description"].ToString();
                }
            }
        }

        private void LoadContents(int moduleId)
        {
            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT ContentType, Body, ImageUrl, Caption
                  FROM ModuleContents
                  WHERE ModuleID=@ModuleID
                  ORDER BY SortOrder", con))
            {
                cmd.Parameters.AddWithValue("@ModuleID", moduleId);

                DataTable dt = new DataTable();

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }

                rptContents.DataSource = dt;
                rptContents.DataBind();
            }
        }

        private void ShowNotFound()
        {
            pnlModule.Visible = false;
            pnlNotFound.Visible = true;
        }
    }
}