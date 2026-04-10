using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace G5_Digital_Museum
{
    public partial class Instructor_Quiz_Manage : System.Web.UI.Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        // ═══════════════════════════════════════════════════════
        //  PAGE LOAD
        // ═══════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAllModuleDDLs();
                LoadAllBanks();
            }
        }

        // ═══════════════════════════════════════════════════════
        //  POPULATE ALL MODULE DROP-DOWNS
        //  (no ExhibitionID / SeqOrder in schema — fixed)
        // ═══════════════════════════════════════════════════════
        private void LoadAllModuleDDLs()
        {
            string sql = @"
                SELECT ModuleID, Title
                FROM   Modules
                WHERE  IsActive = 1
                ORDER  BY SortOrder, Title";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            { conn.Open(); da.Fill(dt); }

            foreach (DropDownList ddl in new DropDownList[] {
                ddlMCQModule, ddlTFModule, ddlFillModule, ddlIMModule, ddlSAModule })
            {
                ddl.Items.Clear();
                ddl.Items.Add(new ListItem("-- Select Module --", "0"));
                foreach (DataRow r in dt.Rows)
                    ddl.Items.Add(new ListItem(r["Title"].ToString(), r["ModuleID"].ToString()));
            }
        }

        // ═══════════════════════════════════════════════════════
        //  LOAD ALL 5 BANKS
        // ═══════════════════════════════════════════════════════
        private void LoadAllBanks()
        {
            // Standard bank query for MCQ / TF / Fill / Image
            string stdSql = @"
                SELECT qq.QuestionID, qq.QuestionText,
                       qq.CorrectAnswer, qq.CorrectLabel, qq.Points,
                       ISNULL(m.Title, '—') AS ModuleTitle
                FROM   QuizQuestions qq
                LEFT   JOIN Quizzes  qz ON qq.QuizID    = qz.QuizID
                LEFT   JOIN Modules  m  ON qz.ModuleID  = m.ModuleID
                WHERE  qq.QuestionType = @Type
                ORDER  BY qq.CreatedAt DESC";

            BindBank(rptMCQ, stdSql, "MCQ");
            BindBank(rptTF, stdSql, "TrueFalse");
            BindBank(rptFill, stdSql, "FillBlank");
            BindBank(rptIM, stdSql, "ImageMatch");

            // Events: CorrectAnswer=E1, OptionA=E2, OptionB=E3, OptionC=E4, OptionD=E5, ModelAnswer=E6|E7|E8
            string seqSql = @"
                SELECT qq.QuestionID, qq.QuestionText,
                       ISNULL(m.Title,'—') AS ModuleTitle,
                       (CASE WHEN qq.CorrectAnswer IS NOT NULL AND qq.CorrectAnswer<>'' THEN 1 ELSE 0 END +
                        CASE WHEN qq.OptionA       IS NOT NULL AND qq.OptionA<>''       THEN 1 ELSE 0 END +
                        CASE WHEN qq.OptionB       IS NOT NULL AND qq.OptionB<>''       THEN 1 ELSE 0 END +
                        CASE WHEN qq.OptionC       IS NOT NULL AND qq.OptionC<>''       THEN 1 ELSE 0 END +
                        CASE WHEN qq.OptionD       IS NOT NULL AND qq.OptionD<>''       THEN 1 ELSE 0 END +
                        CASE WHEN qq.ModelAnswer   IS NOT NULL AND qq.ModelAnswer<>''
                             THEN LEN(qq.ModelAnswer) - LEN(REPLACE(qq.ModelAnswer,'|','')) + 1
                             ELSE 0 END) AS EventCount
                FROM   QuizQuestions qq
                LEFT   JOIN Quizzes  qz ON qq.QuizID   = qz.QuizID
                LEFT   JOIN Modules  m  ON qz.ModuleID = m.ModuleID
                WHERE  qq.QuestionType = 'ShortAnswer'
                ORDER  BY qq.CreatedAt DESC";

            BindBank(rptSA, seqSql, null); // null = no @Type param, sql already filtered
        }

        private void BindBank(Repeater rpt, string sql, string type)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                if (type != null) cmd.Parameters.AddWithValue("@Type", type);
                conn.Open();
                da.Fill(dt);
            }
            rpt.DataSource = dt;
            rpt.DataBind();
        }

        // ═══════════════════════════════════════════════════════
        //  ENSURE QUIZ ROW  (one quiz per module+type)
        // ═══════════════════════════════════════════════════════
        private int EnsureQuiz(SqlConnection conn, int moduleID, string quizType)
        {
            object modParam = moduleID == 0 ? (object)DBNull.Value : moduleID;

            using (SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 1 QuizID FROM Quizzes
                WHERE ((@M IS NULL AND ModuleID IS NULL) OR ModuleID = @M)
                  AND QuizType = @T", conn))
            {
                cmd.Parameters.AddWithValue("@M", modParam);
                cmd.Parameters.AddWithValue("@T", quizType);
                object ex = cmd.ExecuteScalar();
                if (ex != null && ex != DBNull.Value) return Convert.ToInt32(ex);
            }

            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO Quizzes (ModuleID, Title, QuizType, Status, CreatedAt)
                VALUES (@M, @Title, @T, 'Draft', GETDATE());
                SELECT SCOPE_IDENTITY()", conn))
            {
                cmd.Parameters.AddWithValue("@M", modParam);
                cmd.Parameters.AddWithValue("@Title", quizType + " Quiz");
                cmd.Parameters.AddWithValue("@T", quizType);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private int NextSortOrder(SqlConnection conn, int quizID)
        {
            using (SqlCommand cmd = new SqlCommand(
                "SELECT ISNULL(MAX(SortOrder),0)+1 FROM QuizQuestions WHERE QuizID=@Q", conn))
            {
                cmd.Parameters.AddWithValue("@Q", quizID);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        // ═══════════════════════════════════════════════════════
        //  TAB 1 — MULTIPLE CHOICE
        // ═══════════════════════════════════════════════════════
        protected void btnMCQEdit_Click(object sender, EventArgs e)
        {
            int qid = int.Parse(((Button)sender).CommandArgument);
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT qq.*, qz.ModuleID FROM QuizQuestions qq
                JOIN Quizzes qz ON qq.QuizID = qz.QuizID
                WHERE qq.QuestionID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", qid);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return;
                    txtMCQQuestion.Text = r["QuestionText"].ToString();
                    txtA.Text = r["OptionA"].ToString();
                    txtB.Text = r["OptionB"].ToString();
                    txtC.Text = r["OptionC"].ToString();
                    txtD.Text = r["OptionD"].ToString();
                    txtMCQExpl.Text = r["Explanation"].ToString();
                    SetDDL(ddlMCQAnswer, r["CorrectAnswer"].ToString());
                    string modID = r["ModuleID"] == DBNull.Value ? "0" : r["ModuleID"].ToString();
                    SetDDL(ddlMCQModule, modID);
                }
            }
            hfEditMCQ.Value = qid.ToString();
            hfActiveTab.Value = "mcq";
            btnMCQSave.Text = "Update Question";
            lblMCQEditBadge.Visible = true;
            LoadAllBanks();
            // Scroll to MCQ form via JS
            ScriptManager.RegisterStartupScript(this, GetType(), "scrollMCQ",
                "showTab('mcq', document.getElementById('cardMCQ')); " +
                "document.getElementById('cardMCQ').scrollIntoView({behavior:'smooth'});", true);
        }

        protected void btnMCQSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtMCQQuestion.Text))
            { ShowMsg(lblMCQMsg, "Question is required.", false); return; }
            if (string.IsNullOrWhiteSpace(txtA.Text) || string.IsNullOrWhiteSpace(txtB.Text) ||
                string.IsNullOrWhiteSpace(txtC.Text) || string.IsNullOrWhiteSpace(txtD.Text))
            { ShowMsg(lblMCQMsg, "All four options are required.", false); return; }

            if (ddlMCQModule.SelectedValue == "0")
            { ShowMsg(lblMCQMsg, "Please select a linked module.", false); return; }
            int modID = int.Parse(ddlMCQModule.SelectedValue);
            int editID = int.Parse(hfEditMCQ.Value);

            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                if (editID > 0)
                {
                    // UPDATE existing question
                    int quizID = EnsureQuiz(conn, modID, "MCQ");
                    using (SqlCommand cmd = new SqlCommand(@"
                        UPDATE QuizQuestions SET
                            QuizID = @QID, QuestionText = @QText,
                            OptionA = @A, OptionB = @B, OptionC = @C, OptionD = @D,
                            CorrectAnswer = @Ans, Explanation = @Expl
                        WHERE QuestionID = @ID", conn))
                    {
                        cmd.Parameters.AddWithValue("@QID", quizID);
                        cmd.Parameters.AddWithValue("@QText", txtMCQQuestion.Text.Trim());
                        cmd.Parameters.AddWithValue("@A", txtA.Text.Trim());
                        cmd.Parameters.AddWithValue("@B", txtB.Text.Trim());
                        cmd.Parameters.AddWithValue("@C", txtC.Text.Trim());
                        cmd.Parameters.AddWithValue("@D", txtD.Text.Trim());
                        cmd.Parameters.AddWithValue("@Ans", ddlMCQAnswer.SelectedValue);
                        cmd.Parameters.AddWithValue("@Expl", NullOr(txtMCQExpl.Text));
                        cmd.Parameters.AddWithValue("@ID", editID);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMsg(lblMCQMsg, "✓ MCQ question updated.", true);
                }
                else
                {
                    // INSERT new question
                    int quizID = EnsureQuiz(conn, modID, "MCQ");
                    using (SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO QuizQuestions
                            (QuizID, QuestionType, QuestionText,
                             OptionA, OptionB, OptionC, OptionD,
                             CorrectAnswer, Explanation, Points, SortOrder, CreatedAt)
                        VALUES
                            (@QID, 'MCQ', @QText,
                             @A, @B, @C, @D,
                             @Ans, @Expl, 1, @Ord, GETDATE())", conn))
                    {
                        cmd.Parameters.AddWithValue("@QID", quizID);
                        cmd.Parameters.AddWithValue("@QText", txtMCQQuestion.Text.Trim());
                        cmd.Parameters.AddWithValue("@A", txtA.Text.Trim());
                        cmd.Parameters.AddWithValue("@B", txtB.Text.Trim());
                        cmd.Parameters.AddWithValue("@C", txtC.Text.Trim());
                        cmd.Parameters.AddWithValue("@D", txtD.Text.Trim());
                        cmd.Parameters.AddWithValue("@Ans", ddlMCQAnswer.SelectedValue);
                        cmd.Parameters.AddWithValue("@Expl", NullOr(txtMCQExpl.Text));
                        cmd.Parameters.AddWithValue("@Ord", NextSortOrder(conn, quizID));
                        cmd.ExecuteNonQuery();
                    }
                    ShowMsg(lblMCQMsg, "✓ MCQ question saved.", true);
                }
            }
            btnMCQClear_Click(null, null);
            LoadAllBanks();
        }

        protected void btnMCQDelete_Click(object sender, EventArgs e) =>
            DeleteQ(((Button)sender).CommandArgument, lblMCQMsg);

        protected void btnMCQClear_Click(object sender, EventArgs e)
        {
            txtMCQQuestion.Text = txtA.Text = txtB.Text = txtC.Text = txtD.Text = txtMCQExpl.Text = "";
            ddlMCQAnswer.SelectedIndex = ddlMCQModule.SelectedIndex = 0;
            hfEditMCQ.Value = "0";
            btnMCQSave.Text = "Save Question";
            lblMCQEditBadge.Visible = false;
        }

        // ═══════════════════════════════════════════════════════
        //  TAB 2 — TRUE / FALSE
        // ═══════════════════════════════════════════════════════
        protected void btnTFEdit_Click(object sender, EventArgs e)
        {
            int qid = int.Parse(((Button)sender).CommandArgument);
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT qq.*, qz.ModuleID FROM QuizQuestions qq
                JOIN Quizzes qz ON qq.QuizID = qz.QuizID
                WHERE qq.QuestionID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", qid);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return;
                    txtTFQuestion.Text = r["QuestionText"].ToString();
                    txtTFExpl.Text = r["Explanation"].ToString();
                    txtTFPoints.Text = r["Points"].ToString();
                    hfTFAnswer.Value = r["CorrectAnswer"].ToString();
                    string modID = r["ModuleID"] == DBNull.Value ? "0" : r["ModuleID"].ToString();
                    SetDDL(ddlTFModule, modID);
                }
            }
            hfEditTF.Value = qid.ToString();
            hfActiveTab.Value = "tf";
            btnTFSave.Text = "Update Question";
            lblTFEditBadge.Visible = true;
            LoadAllBanks();
            ScriptManager.RegisterStartupScript(this, GetType(), "scrollTF",
                "showTab('tf', document.getElementById('cardTF')); " +
                "setTF('" + (hfTFAnswer.Value) + "', null); " +
                "document.getElementById('cardTF').scrollIntoView({behavior:'smooth'});", true);
        }

        protected void btnTFSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTFQuestion.Text))
            { ShowMsg(lblTFMsg, "Statement is required.", false); return; }

            if (ddlTFModule.SelectedValue == "0")
            { ShowMsg(lblTFMsg, "Please select a linked module.", false); return; }
            int modID = int.Parse(ddlTFModule.SelectedValue);
            int pts = int.TryParse(txtTFPoints.Text, out int p) ? p : 1;
            string ans = hfTFAnswer.Value == "False" ? "False" : "True";
            int editID = int.Parse(hfEditTF.Value);

            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                if (editID > 0)
                {
                    int quizID = EnsureQuiz(conn, modID, "TrueFalse");
                    using (SqlCommand cmd = new SqlCommand(@"
                        UPDATE QuizQuestions SET
                            QuizID = @QID, QuestionText = @QText,
                            CorrectAnswer = @Ans, Explanation = @Expl, Points = @Pts
                        WHERE QuestionID = @ID", conn))
                    {
                        cmd.Parameters.AddWithValue("@QID", quizID);
                        cmd.Parameters.AddWithValue("@QText", txtTFQuestion.Text.Trim());
                        cmd.Parameters.AddWithValue("@Ans", ans);
                        cmd.Parameters.AddWithValue("@Expl", NullOr(txtTFExpl.Text));
                        cmd.Parameters.AddWithValue("@Pts", pts);
                        cmd.Parameters.AddWithValue("@ID", editID);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMsg(lblTFMsg, "✓ True/False question updated.", true);
                }
                else
                {
                    int quizID = EnsureQuiz(conn, modID, "TrueFalse");
                    using (SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO QuizQuestions
                            (QuizID, QuestionType, QuestionText,
                             CorrectAnswer, Explanation, Points, SortOrder, CreatedAt)
                        VALUES
                            (@QID, 'TrueFalse', @QText,
                             @Ans, @Expl, @Pts, @Ord, GETDATE())", conn))
                    {
                        cmd.Parameters.AddWithValue("@QID", quizID);
                        cmd.Parameters.AddWithValue("@QText", txtTFQuestion.Text.Trim());
                        cmd.Parameters.AddWithValue("@Ans", ans);
                        cmd.Parameters.AddWithValue("@Expl", NullOr(txtTFExpl.Text));
                        cmd.Parameters.AddWithValue("@Pts", pts);
                        cmd.Parameters.AddWithValue("@Ord", NextSortOrder(conn, quizID));
                        cmd.ExecuteNonQuery();
                    }
                    ShowMsg(lblTFMsg, "✓ True/False question saved.", true);
                }
            }
            btnTFClear_Click(null, null);
            LoadAllBanks();
        }

        protected void btnTFDelete_Click(object sender, EventArgs e) =>
            DeleteQ(((Button)sender).CommandArgument, lblTFMsg);

        protected void btnTFClear_Click(object sender, EventArgs e)
        {
            txtTFQuestion.Text = txtTFExpl.Text = "";
            txtTFPoints.Text = "1";
            hfTFAnswer.Value = "True";
            ddlTFModule.SelectedIndex = 0;
            hfEditTF.Value = "0";
            btnTFSave.Text = "Save Question";
            lblTFEditBadge.Visible = false;
        }

        // ═══════════════════════════════════════════════════════
        //  TAB 3 — FILL IN THE BLANK
        // ═══════════════════════════════════════════════════════
        protected void btnFillEdit_Click(object sender, EventArgs e)
        {
            int qid = int.Parse(((Button)sender).CommandArgument);
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT qq.*, qz.ModuleID FROM QuizQuestions qq
                JOIN Quizzes qz ON qq.QuizID = qz.QuizID
                WHERE qq.QuestionID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", qid);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return;
                    txtFillQuestion.Text = r["QuestionText"].ToString();
                    txtFillAnswer.Text = r["CorrectAnswer"].ToString();
                    txtFillPoints.Text = r["Points"].ToString();
                    // Extract alt answers from Explanation (stored as "ALT:xxx")
                    string expl = r["Explanation"].ToString();
                    txtFillAlt.Text = expl.StartsWith("ALT:") ? expl.Substring(4) : "";
                    string modID = r["ModuleID"] == DBNull.Value ? "0" : r["ModuleID"].ToString();
                    SetDDL(ddlFillModule, modID);
                }
            }
            hfEditFill.Value = qid.ToString();
            hfActiveTab.Value = "fill";
            btnFillSave.Text = "Update Question";
            lblFillEditBadge.Visible = true;
            LoadAllBanks();
            ScriptManager.RegisterStartupScript(this, GetType(), "scrollFill",
                "showTab('fill', document.getElementById('cardFill')); " +
                "document.getElementById('cardFill').scrollIntoView({behavior:'smooth'});", true);
        }

        protected void btnFillSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtFillQuestion.Text))
            { ShowMsg(lblFillMsg, "Sentence is required.", false); return; }
            if (string.IsNullOrWhiteSpace(txtFillAnswer.Text))
            { ShowMsg(lblFillMsg, "Correct answer is required.", false); return; }
            if (!txtFillQuestion.Text.Contains("___"))
            { ShowMsg(lblFillMsg, "Use ___ (three underscores) to mark the blank.", false); return; }

            if (ddlFillModule.SelectedValue == "0")
            { ShowMsg(lblFillMsg, "Please select a linked module.", false); return; }
            int modID = int.Parse(ddlFillModule.SelectedValue);
            int pts = int.TryParse(txtFillPoints.Text, out int p) ? p : 1;
            string alts = txtFillAlt.Text.Trim();
            string expl = string.IsNullOrWhiteSpace(alts) ? null : "ALT:" + alts;
            int editID = int.Parse(hfEditFill.Value);

            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                if (editID > 0)
                {
                    int quizID = EnsureQuiz(conn, modID, "FillBlank");
                    using (SqlCommand cmd = new SqlCommand(@"
                        UPDATE QuizQuestions SET
                            QuizID = @QID, QuestionText = @QText,
                            CorrectAnswer = @Ans, Explanation = @Expl, Points = @Pts
                        WHERE QuestionID = @ID", conn))
                    {
                        cmd.Parameters.AddWithValue("@QID", quizID);
                        cmd.Parameters.AddWithValue("@QText", txtFillQuestion.Text.Trim());
                        cmd.Parameters.AddWithValue("@Ans", txtFillAnswer.Text.Trim());
                        cmd.Parameters.AddWithValue("@Expl", NullOr(expl));
                        cmd.Parameters.AddWithValue("@Pts", pts);
                        cmd.Parameters.AddWithValue("@ID", editID);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMsg(lblFillMsg, "✓ Fill-in-blank question updated.", true);
                }
                else
                {
                    int quizID = EnsureQuiz(conn, modID, "FillBlank");
                    using (SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO QuizQuestions
                            (QuizID, QuestionType, QuestionText,
                             CorrectAnswer, Explanation, Points, SortOrder, CreatedAt)
                        VALUES
                            (@QID, 'FillBlank', @QText,
                             @Ans, @Expl, @Pts, @Ord, GETDATE())", conn))
                    {
                        cmd.Parameters.AddWithValue("@QID", quizID);
                        cmd.Parameters.AddWithValue("@QText", txtFillQuestion.Text.Trim());
                        cmd.Parameters.AddWithValue("@Ans", txtFillAnswer.Text.Trim());
                        cmd.Parameters.AddWithValue("@Expl", NullOr(expl));
                        cmd.Parameters.AddWithValue("@Pts", pts);
                        cmd.Parameters.AddWithValue("@Ord", NextSortOrder(conn, quizID));
                        cmd.ExecuteNonQuery();
                    }
                    ShowMsg(lblFillMsg, "✓ Fill-in-blank question saved.", true);
                }
            }
            btnFillClear_Click(null, null);
            LoadAllBanks();
        }

        protected void btnFillDelete_Click(object sender, EventArgs e) =>
            DeleteQ(((Button)sender).CommandArgument, lblFillMsg);

        protected void btnFillClear_Click(object sender, EventArgs e)
        {
            txtFillQuestion.Text = txtFillAnswer.Text = txtFillAlt.Text = "";
            txtFillPoints.Text = "1";
            ddlFillModule.SelectedIndex = 0;
            hfEditFill.Value = "0";
            btnFillSave.Text = "Save Question";
            lblFillEditBadge.Visible = false;
        }

        // ═══════════════════════════════════════════════════════
        //  TAB 4 — IMAGE MATCH
        // ═══════════════════════════════════════════════════════
        protected void btnIMEdit_Click(object sender, EventArgs e)
        {
            int qid = int.Parse(((Button)sender).CommandArgument);
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT qq.*, qz.ModuleID FROM QuizQuestions qq
                JOIN Quizzes qz ON qq.QuizID = qz.QuizID
                WHERE qq.QuestionID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", qid);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return;
                    txtIMQuestion.Text = r["QuestionText"].ToString();
                    txtIMLabel.Text = r["CorrectLabel"].ToString();
                    txtIMCorrectUrl.Text = r["ImageUrl"] == DBNull.Value ? "" : r["ImageUrl"].ToString();
                    txtIMD1Url.Text = r["Distractor1Url"] == DBNull.Value ? "" : r["Distractor1Url"].ToString();
                    txtIMD2Url.Text = r["Distractor2Url"] == DBNull.Value ? "" : r["Distractor2Url"].ToString();
                    txtIMD3Url.Text = r["Distractor3Url"] == DBNull.Value ? "" : r["Distractor3Url"].ToString();
                    txtIMPoints.Text = r["Points"].ToString();
                    string modID = r["ModuleID"] == DBNull.Value ? "0" : r["ModuleID"].ToString();
                    SetDDL(ddlIMModule, modID);
                }
            }
            hfEditIM.Value = qid.ToString();
            hfActiveTab.Value = "image";
            btnIMSave.Text = "Update Question";
            lblIMEditBadge.Visible = true;
            LoadAllBanks();

            // Build JS: switch every slot that has a URL to URL mode and fire preview
            var slots = new[]
            {
                new { key = "correct", url = txtIMCorrectUrl.Text },
                new { key = "d1",      url = txtIMD1Url.Text },
                new { key = "d2",      url = txtIMD2Url.Text },
                new { key = "d3",      url = txtIMD3Url.Text }
            };
            var sb = new System.Text.StringBuilder();
            sb.Append("showTab('image', document.getElementById('cardImage')); ");
            sb.Append("document.getElementById('cardImage').scrollIntoView({behavior:'smooth'}); ");
            foreach (var s in slots)
            {
                if (!string.IsNullOrWhiteSpace(s.url))
                {
                    string safeUrl = s.url.Replace("'", "\\'");
                    string sKey = s.key;
                    string capKey = char.ToUpper(sKey[0]) + sKey.Substring(1);
                    // Switch slot to URL mode (hide upload div, show url div, fix tab buttons)
                    sb.Append("(function(){" +
                              "var up=document.getElementById('slot" + capKey + "Upload');" +
                              "var ur=document.getElementById('slot" + capKey + "Url');" +
                              "if(up) up.style.display='none';" +
                              "if(ur){ur.style.display='block';" +
                              "var tabs=ur.parentElement.querySelectorAll('.im-stab');" +
                              "tabs[0].classList.remove('im-stab--active');" +
                              "tabs[1].classList.add('im-stab--active');}" +
                              "applyImPreview('" + sKey + "','" + safeUrl + "');" +
                              "})(); ");
                }
            }
            // Also sync the label into the drop target
            sb.Append("syncNewLabel(document.getElementById('" + txtIMLabel.ClientID + "').value); ");
            ScriptManager.RegisterStartupScript(this, GetType(), "editIM", sb.ToString(), true);
        }

        protected void btnIMSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtIMQuestion.Text))
            { ShowMsg(lblIMMsg, "Instruction is required.", false); return; }
            if (string.IsNullOrWhiteSpace(txtIMLabel.Text))
            { ShowMsg(lblIMMsg, "Correct label is required.", false); return; }
            if (ddlIMModule.SelectedValue == "0")
            { ShowMsg(lblIMMsg, "Please select a linked module.", false); return; }

            string correctUrl = ResolveImgSource(fuIMCorrect, txtIMCorrectUrl.Text);
            string d1Url = ResolveImgSource(fuIMD1, txtIMD1Url.Text);
            string d2Url = ResolveImgSource(fuIMD2, txtIMD2Url.Text);
            string d3Url = ResolveImgSource(fuIMD3, txtIMD3Url.Text);

            int modID = int.Parse(ddlIMModule.SelectedValue);
            int pts = int.TryParse(txtIMPoints.Text, out int p) ? p : 2;
            int editID = int.Parse(hfEditIM.Value);

            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                if (editID > 0)
                {
                    int quizID = EnsureQuiz(conn, modID, "ImageMatch");
                    using (SqlCommand cmd = new SqlCommand(@"
                        UPDATE QuizQuestions SET
                            QuizID = @QID, QuestionText = @QText, CorrectLabel = @CLabel,
                            ImageUrl = ISNULL(@Img, ImageUrl),
                            Distractor1Url = ISNULL(@D1, Distractor1Url),
                            Distractor2Url = ISNULL(@D2, Distractor2Url),
                            Distractor3Url = ISNULL(@D3, Distractor3Url),
                            Points = @Pts
                        WHERE QuestionID = @ID", conn))
                    {
                        cmd.Parameters.AddWithValue("@QID", quizID);
                        cmd.Parameters.AddWithValue("@QText", txtIMQuestion.Text.Trim());
                        cmd.Parameters.AddWithValue("@CLabel", txtIMLabel.Text.Trim());
                        cmd.Parameters.AddWithValue("@Img", (object)correctUrl ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@D1", (object)d1Url ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@D2", (object)d2Url ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@D3", (object)d3Url ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Pts", pts);
                        cmd.Parameters.AddWithValue("@ID", editID);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMsg(lblIMMsg, "✓ Image Match question updated.", true);
                }
                else
                {
                    int quizID = EnsureQuiz(conn, modID, "ImageMatch");
                    using (SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO QuizQuestions
                            (QuizID, QuestionType, QuestionText,
                             ImageUrl, CorrectLabel,
                             Distractor1Url, Distractor2Url, Distractor3Url,
                             Points, SortOrder, CreatedAt)
                        VALUES
                            (@QID, 'ImageMatch', @QText,
                             @Img,  @CLabel,
                             @D1,   @D2,   @D3,
                             @Pts, @Ord, GETDATE())", conn))
                    {
                        cmd.Parameters.AddWithValue("@QID", quizID);
                        cmd.Parameters.AddWithValue("@QText", txtIMQuestion.Text.Trim());
                        cmd.Parameters.AddWithValue("@CLabel", txtIMLabel.Text.Trim());
                        cmd.Parameters.AddWithValue("@Img", NullOr(correctUrl));
                        cmd.Parameters.AddWithValue("@D1", NullOr(d1Url));
                        cmd.Parameters.AddWithValue("@D2", NullOr(d2Url));
                        cmd.Parameters.AddWithValue("@D3", NullOr(d3Url));
                        cmd.Parameters.AddWithValue("@Pts", pts);
                        cmd.Parameters.AddWithValue("@Ord", NextSortOrder(conn, quizID));
                        cmd.ExecuteNonQuery();
                    }
                    ShowMsg(lblIMMsg, "✓ Image Match question saved.", true);
                }
            }
            btnIMClear_Click(null, null);
            LoadAllBanks();
        }

        protected void btnIMDelete_Click(object sender, EventArgs e) =>
            DeleteQ(((Button)sender).CommandArgument, lblIMMsg);

        protected void btnIMClear_Click(object sender, EventArgs e)
        {
            txtIMQuestion.Text = txtIMLabel.Text = "";
            txtIMCorrectUrl.Text = txtIMD1Url.Text = txtIMD2Url.Text = txtIMD3Url.Text = "";
            txtIMPoints.Text = "2";
            ddlIMModule.SelectedIndex = 0;
            hfEditIM.Value = "0";
            btnIMSave.Text = "Save Question";
            lblIMEditBadge.Visible = false;
        }

        // ═══════════════════════════════════════════════════════
        //  TAB 5 — TIMELINE ORDER
        //  Stores events in OptionA-D (events 2-5) + CorrectAnswer (event 1)
        //  QuestionType = 'ShortAnswer' (reuses the existing CHECK constraint)
        // ═══════════════════════════════════════════════════════
        protected void btnSAEdit_Click(object sender, EventArgs e)
        {
            int qid = int.Parse(((Button)sender).CommandArgument);
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT qq.*, qz.ModuleID FROM QuizQuestions qq
                JOIN Quizzes qz ON qq.QuizID = qz.QuizID
                WHERE qq.QuestionID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", qid);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return;
                    txtSAQuestion.Text = r["QuestionText"].ToString();
                    txtSAModel.Text = r["CorrectAnswer"].ToString();
                    txtSeq2.Text = r["OptionA"] == DBNull.Value ? "" : r["OptionA"].ToString();
                    txtSeq3.Text = r["OptionB"] == DBNull.Value ? "" : r["OptionB"].ToString();
                    txtSeq4.Text = r["OptionC"] == DBNull.Value ? "" : r["OptionC"].ToString();
                    txtSeq5.Text = r["OptionD"] == DBNull.Value ? "" : r["OptionD"].ToString();
                    // Events 6-8 stored as "E6|E7|E8" in ModelAnswer
                    string extra = r["ModelAnswer"] == DBNull.Value ? "" : r["ModelAnswer"].ToString();
                    string[] extras = extra.Length > 0 ? extra.Split('|') : new string[0];
                    txtSeq6.Text = ""; txtSeq7.Text = ""; txtSeq8.Text = "";
                    txtSAWords.Text = r["Points"].ToString();
                    string modID = r["ModuleID"] == DBNull.Value ? "0" : r["ModuleID"].ToString();
                    SetDDL(ddlSAModule, modID);
                }
            }
            hfEditSA.Value = qid.ToString();
            hfActiveTab.Value = "sa";
            btnSASave.Text = "Update Question";
            lblSAEditBadge.Visible = true;
            LoadAllBanks();

            // Count how many events were loaded (max 5 — matches DB columns)
            int loadedCount = 2; // rows 1+2 always visible
            if (!string.IsNullOrWhiteSpace(txtSeq3.Text)) loadedCount = 3;
            if (!string.IsNullOrWhiteSpace(txtSeq4.Text)) loadedCount = 4;
            if (!string.IsNullOrWhiteSpace(txtSeq5.Text)) loadedCount = 5;

            // Build JS: show rows 3..N, update seqVisible, rebuild preview
            var sbJS = new System.Text.StringBuilder();
            sbJS.Append("showTab('sa', document.getElementById('cardSA')); ");
            sbJS.Append("document.getElementById('cardSA').scrollIntoView({behavior:'smooth'}); ");
            for (int row = 3; row <= loadedCount; row++)
            {
                sbJS.Append("(function(){var r=document.getElementById('seqRow" + row + "');if(r)r.style.display='';})(); ");
            }
            sbJS.Append("seqVisible = " + loadedCount + "; ");
            sbJS.Append("updateSeqCount(); ");
            sbJS.Append("buildSeqPreview(); ");

            ScriptManager.RegisterStartupScript(this, GetType(), "scrollSA", sbJS.ToString(), true);
        }

        protected void btnSASave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtSAQuestion.Text))
            { ShowMsg(lblSAMsg, "Instruction is required.", false); return; }
            if (string.IsNullOrWhiteSpace(txtSAModel.Text))
            { ShowMsg(lblSAMsg, "At least the first event is required.", false); return; }
            if (string.IsNullOrWhiteSpace(txtSeq2.Text))
            { ShowMsg(lblSAMsg, "At least two events are required.", false); return; }
            if (ddlSAModule.SelectedValue == "0")
            { ShowMsg(lblSAMsg, "Please select a linked module.", false); return; }

            int modID = int.Parse(ddlSAModule.SelectedValue);
            int pts = int.TryParse(txtSAWords.Text, out int p) ? p : 3;
            int editID = int.Parse(hfEditSA.Value);

            // ModelAnswer not used for events (max 5 events fit in CorrectAnswer + OptionA-D)
            object modelAnswer = DBNull.Value;

            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                if (editID > 0)
                {
                    int quizID = EnsureQuiz(conn, modID, "ShortAnswer");
                    using (SqlCommand cmd = new SqlCommand(@"
                        UPDATE QuizQuestions SET
                            QuizID = @QID, QuestionText = @QText,
                            CorrectAnswer = @E1, OptionA = @E2, OptionB = @E3,
                            OptionC = @E4, OptionD = @E5, ModelAnswer = @MA, Points = @Pts
                        WHERE QuestionID = @ID", conn))
                    {
                        cmd.Parameters.AddWithValue("@QID", quizID);
                        cmd.Parameters.AddWithValue("@QText", txtSAQuestion.Text.Trim());
                        cmd.Parameters.AddWithValue("@E1", txtSAModel.Text.Trim());
                        cmd.Parameters.AddWithValue("@E2", NullOr(txtSeq2.Text.Trim()));
                        cmd.Parameters.AddWithValue("@E3", NullOr(txtSeq3.Text.Trim()));
                        cmd.Parameters.AddWithValue("@E4", NullOr(txtSeq4.Text.Trim()));
                        cmd.Parameters.AddWithValue("@E5", NullOr(txtSeq5.Text.Trim()));
                        cmd.Parameters.AddWithValue("@MA", modelAnswer);
                        cmd.Parameters.AddWithValue("@Pts", pts);
                        cmd.Parameters.AddWithValue("@ID", editID);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMsg(lblSAMsg, "✓ Timeline question updated.", true);
                }
                else
                {
                    int quizID = EnsureQuiz(conn, modID, "ShortAnswer");
                    using (SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO QuizQuestions
                            (QuizID, QuestionType, QuestionText,
                             CorrectAnswer, OptionA, OptionB, OptionC, OptionD, ModelAnswer,
                             Points, SortOrder, CreatedAt)
                        VALUES
                            (@QID, 'ShortAnswer', @QText,
                             @E1, @E2, @E3, @E4, @E5, @MA,
                             @Pts, @Ord, GETDATE())", conn))
                    {
                        cmd.Parameters.AddWithValue("@QID", quizID);
                        cmd.Parameters.AddWithValue("@QText", txtSAQuestion.Text.Trim());
                        cmd.Parameters.AddWithValue("@E1", txtSAModel.Text.Trim());
                        cmd.Parameters.AddWithValue("@E2", NullOr(txtSeq2.Text.Trim()));
                        cmd.Parameters.AddWithValue("@E3", NullOr(txtSeq3.Text.Trim()));
                        cmd.Parameters.AddWithValue("@E4", NullOr(txtSeq4.Text.Trim()));
                        cmd.Parameters.AddWithValue("@E5", NullOr(txtSeq5.Text.Trim()));
                        cmd.Parameters.AddWithValue("@MA", modelAnswer);
                        cmd.Parameters.AddWithValue("@Pts", pts);
                        cmd.Parameters.AddWithValue("@Ord", NextSortOrder(conn, quizID));
                        cmd.ExecuteNonQuery();
                    }
                    ShowMsg(lblSAMsg, "✓ Timeline question saved.", true);
                }
            }
            btnSAClear_Click(null, null);
            LoadAllBanks();
        }

        protected void btnSADelete_Click(object sender, EventArgs e) =>
            DeleteQ(((Button)sender).CommandArgument, lblSAMsg);

        protected void btnSAClear_Click(object sender, EventArgs e)
        {
            txtSAQuestion.Text = txtSAModel.Text = "";
            txtSeq2.Text = txtSeq3.Text = txtSeq4.Text = txtSeq5.Text = "";
            txtSeq6.Text = txtSeq7.Text = txtSeq8.Text = ""; // stubs, kept for compile
            txtSAWords.Text = "3";
            ddlSAModule.SelectedIndex = 0;
            hfEditSA.Value = "0";
            btnSASave.Text = "Save Question";
            lblSAEditBadge.Visible = false;
        }

        // ═══════════════════════════════════════════════════════
        //  SHARED DELETE
        // ═══════════════════════════════════════════════════════
        private void DeleteQ(string idStr, Label lbl)
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "DELETE FROM QuizQuestions WHERE QuestionID=@ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", int.Parse(idStr));
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            ShowMsg(lbl, "Question deleted.", true);
            LoadAllBanks();
        }

        // ═══════════════════════════════════════════════════════
        //  HELPERS
        // ═══════════════════════════════════════════════════════
        private string ResolveImgSource(FileUpload fu, string urlText)
        {
            if (fu != null && fu.HasFile)
            {
                string ext = System.IO.Path.GetExtension(fu.FileName).ToLower();
                if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" ||
                    ext == ".gif" || ext == ".webp")
                {
                    string dir = Server.MapPath("~/Image/Quiz/");
                    if (!System.IO.Directory.Exists(dir))
                        System.IO.Directory.CreateDirectory(dir);
                    string name = Guid.NewGuid().ToString("N") + ext;
                    fu.SaveAs(System.IO.Path.Combine(dir, name));
                    return ResolveUrl("~/Image/Quiz/" + name);
                }
            }
            if (!string.IsNullOrWhiteSpace(urlText)) return urlText.Trim();
            return null;
        }

        private object NullOr(string s) =>
            string.IsNullOrWhiteSpace(s) ? (object)DBNull.Value : s.Trim();

        private static void SetDDL(DropDownList ddl, string val)
        {
            if (ddl.Items.FindByValue(val) != null)
                ddl.SelectedValue = val;
        }

        private void ShowMsg(Label lbl, string msg, bool ok)
        {
            lbl.Text = msg;
            lbl.ForeColor = ok
                ? System.Drawing.Color.FromArgb(94, 203, 138)
                : System.Drawing.Color.FromArgb(201, 76, 76);
        }
    }
}