using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace G5_Digital_Museum
{
    public partial class Member_Modules : System.Web.UI.Page
    {
        private readonly string _cs = ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindModules();
            }
        }

        private void BindModules()
        {
            List<ModuleViewModel> list = new List<ModuleViewModel>();

            using (SqlConnection con = new SqlConnection(_cs))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT 
                        m.ModuleID,
                        m.Title,
                        m.Description,
                        m.SortOrder,
                        (SELECT COUNT(*) FROM ModuleContents mc WHERE mc.ModuleID = m.ModuleID) AS BlockCount,
                        CASE 
                            WHEN EXISTS (
                                SELECT 1 FROM Quizzes q
                                WHERE q.ModuleID = m.ModuleID
                                  AND q.Status = 'Published'
                                  AND q.IsActive = 1
                            ) THEN 1 ELSE 0
                        END AS HasQuiz
                    FROM Modules m
                    WHERE m.Status = 'Published'
                      AND m.IsActive = 1
                    ORDER BY m.SortOrder, m.ModuleID;", con))
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        ModuleViewModel item = new ModuleViewModel
                        {
                            ModuleID = Convert.ToInt32(dr["ModuleID"]),
                            Title = dr["Title"].ToString(),
                            Description = dr["Description"].ToString(),
                            SortOrder = Convert.ToInt32(dr["SortOrder"]),
                            BlockCount = Convert.ToInt32(dr["BlockCount"]),
                            HasQuiz = Convert.ToInt32(dr["HasQuiz"]) == 1,
                            PreviewContents = new List<string>()
                        };

                        list.Add(item);
                    }
                }

                foreach (var module in list)
                {
                    using (SqlCommand cmdPreview = new SqlCommand(@"
                        SELECT TOP 3
                            CASE
                                WHEN ContentType = 'text' THEN
                                    CASE
                                        WHEN LEN(ISNULL(Body, '')) > 90 THEN LEFT(Body, 90) + '...'
                                        ELSE ISNULL(Body, '')
                                    END
                                WHEN ContentType = 'image' THEN
                                    ISNULL(Caption, 'Image content')
                                ELSE 'Content block'
                            END AS PreviewText
                        FROM ModuleContents
                        WHERE ModuleID = @ModuleID
                        ORDER BY SortOrder, ContentID;", con))
                    {
                        cmdPreview.Parameters.AddWithValue("@ModuleID", module.ModuleID);

                        using (SqlDataReader drPreview = cmdPreview.ExecuteReader())
                        {
                            while (drPreview.Read())
                            {
                                module.PreviewContents.Add(drPreview["PreviewText"].ToString());
                            }
                        }
                    }
                }
            }

            rptModules.DataSource = list;
            rptModules.DataBind();
            pnlEmpty.Visible = list.Count == 0;
        }

        protected void rptModules_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int moduleId;
            if (!int.TryParse(e.CommandArgument.ToString(), out moduleId))
                return;

            if (e.CommandName == "open")
            {
                Response.Redirect("Member_ModulesContent.aspx?id=" + moduleId);
            }
            else if (e.CommandName == "quiz")
            {
                Response.Redirect("Member_Quiz.aspx?moduleId=" + moduleId);
            }
        }

        public class ModuleViewModel
        {
            public int ModuleID { get; set; }
            public string Title { get; set; }
            public string Description { get; set; }
            public int SortOrder { get; set; }
            public int BlockCount { get; set; }
            public bool HasQuiz { get; set; }
            public List<string> PreviewContents { get; set; }
        }
    }
}