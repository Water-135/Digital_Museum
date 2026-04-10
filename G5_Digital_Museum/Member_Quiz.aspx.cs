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
    public partial class Member_Quiz : System.Web.UI.Page
    {
        private readonly string _cs =
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        private int CurrentQuizID
        {
            get { return ViewState["CurrentQuizID"] == null ? 0 : Convert.ToInt32(ViewState["CurrentQuizID"]); }
            set { ViewState["CurrentQuizID"] = value; }
        }

        private int CurrentQuestionIndex
        {
            get { return ViewState["CurrentQuestionIndex"] == null ? 0 : Convert.ToInt32(ViewState["CurrentQuestionIndex"]); }
            set { ViewState["CurrentQuestionIndex"] = value; }
        }

        private DataTable CurrentQuestions
        {
            get { return Session["MemberQuiz_Questions"] as DataTable; }
            set { Session["MemberQuiz_Questions"] = value; }
        }

        private Dictionary<int, string> Answers
        {
            get
            {
                if (Session["MemberQuiz_Answers"] == null)
                    Session["MemberQuiz_Answers"] = new Dictionary<int, string>();

                return (Dictionary<int, string>)Session["MemberQuiz_Answers"];
            }
            set { Session["MemberQuiz_Answers"] = value; }


        }

        private bool IsReviewMode
        {
            get { return ViewState["IsReviewMode"] == null ? false : Convert.ToBoolean(ViewState["IsReviewMode"]); }
            set { ViewState["IsReviewMode"] = value; }
        }

        private int LastScorePercent
        {
            get { return ViewState["LastScorePercent"] == null ? 0 : Convert.ToInt32(ViewState["LastScorePercent"]); }
            set { ViewState["LastScorePercent"] = value; }
        }

        private bool LastPassed
        {
            get { return ViewState["LastPassed"] == null ? false : Convert.ToBoolean(ViewState["LastPassed"]); }
            set { ViewState["LastPassed"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindQuizList();
                mvQuiz.ActiveViewIndex = 0;
            }
        }

        private void BindQuizList()
        {
            DataTable dt = GetAllQuizList();

            BindQuizType(dt, "MCQ", rptMCQ, pnlNoMCQ);
            BindQuizType(dt, "TrueFalse", rptTrueFalse, pnlNoTrueFalse);
            BindQuizType(dt, "FillBlank", rptFillBlank, pnlNoFillBlank);
            BindQuizType(dt, "ImageMatch", rptImageMatch, pnlNoImageMatch);
            BindQuizType(dt, "ShortAnswer", rptShortAnswer, pnlNoShortAnswer);

            bool hasAnyQuiz = dt.Rows.Count > 0;
            pnlNoQuiz.Visible = !hasAnyQuiz;
        }

        protected void rptQuizzes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "start")
            {
                int quizId;
                if (int.TryParse(e.CommandArgument.ToString(), out quizId))
                {
                    StartQuiz(quizId);
                }
            }
        }

        private void StartQuiz(int quizId)
        {
            if (!IsQuizPublished(quizId))
            {
                ShowMessage("This quiz is not available.");
                BindQuizList();
                mvQuiz.ActiveViewIndex = 0;
                return;
            }

            DataTable dtQuiz = GetQuizById(quizId);
            DataTable dtQuestions = GetQuizQuestions(quizId);

            if (dtQuestions.Rows.Count == 0)
            {
                ShowMessage("This quiz has no questions yet.");
                return;
            }

            CurrentQuizID = quizId;
            CurrentQuestionIndex = 0;
            CurrentQuestions = dtQuestions;
            Answers = new Dictionary<int, string>();
            IsReviewMode = false;

            RenderCurrentQuestion();
        }

        private DataTable GetQuizById(int quizId)
        {
            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(@"
        ;WITH FirstQuestionType AS
        (
            SELECT TOP 1
                qq.QuestionType
            FROM QuizQuestions qq
            WHERE qq.QuizID = @QuizID
            ORDER BY qq.QuestionID
        )
        SELECT
            q.QuizID,
            COALESCE(NULLIF(q.Title, ''), 'Quiz #' + CAST(q.QuizID AS NVARCHAR(20))) AS Title,
            COALESCE(NULLIF(q.QuizType, ''), (SELECT TOP 1 QuestionType FROM FirstQuestionType), 'General') AS QuizType,
            ISNULL(q.PassMark, 60) AS PassMark
        FROM Quizzes q
        INNER JOIN Modules m ON q.ModuleID = m.ModuleID
        WHERE q.QuizID = @QuizID
          AND m.Status = 'Published';", con))
            {
                cmd.Parameters.AddWithValue("@QuizID", quizId);

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    return dt;
                }
            }
        }

        private DataTable GetQuizQuestions(int quizId)
        {
            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(@"
        SELECT 
            qq.QuestionID, qq.QuizID, qq.QuestionType, qq.QuestionText,
            qq.OptionA, qq.OptionB, qq.OptionC, qq.OptionD,
            qq.CorrectAnswer,
            qq.ImageUrl, qq.CorrectLabel,
            qq.Distractor1Url, qq.Label1,
            qq.Distractor2Url, qq.Label2,
            qq.Distractor3Url, qq.Label3,
            qq.ModelAnswer, qq.MaxWords,
            qq.Explanation, qq.Points, qq.SortOrder
        FROM QuizQuestions qq
        INNER JOIN Quizzes q ON qq.QuizID = q.QuizID
        INNER JOIN Modules m ON q.ModuleID = m.ModuleID
        WHERE qq.QuizID = @QuizID
          AND m.Status = 'Published'
        ORDER BY 
            CASE WHEN qq.SortOrder IS NULL THEN 999999 ELSE qq.SortOrder END,
            qq.QuestionID;", con))
            {
                cmd.Parameters.AddWithValue("@QuizID", quizId);

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    return dt;
                }
            }
        }

        private void RenderCurrentQuestion()
        {
            if (CurrentQuestions == null || CurrentQuestions.Rows.Count == 0)
            {
                ShowMessage("No questions found for this quiz.");
                mvQuiz.ActiveViewIndex = 0;
                return;
            }

            if (CurrentQuestionIndex < 0) CurrentQuestionIndex = 0;
            if (CurrentQuestionIndex >= CurrentQuestions.Rows.Count)
                CurrentQuestionIndex = CurrentQuestions.Rows.Count - 1;

            DataRow row = CurrentQuestions.Rows[CurrentQuestionIndex];
            int questionId = Convert.ToInt32(row["QuestionID"]);
            string qType = Convert.ToString(row["QuestionType"]);
            string questionText = Convert.ToString(row["QuestionText"]);

            string existingAnswer = Answers.ContainsKey(questionId) ? Answers[questionId] : "";

            hfCurrentQuestion.Value = (CurrentQuestionIndex + 1).ToString();
            hfTotalQuestions.Value = CurrentQuestions.Rows.Count.ToString();

            litProgressText.Text = "Question " + (CurrentQuestionIndex + 1) + " of " + CurrentQuestions.Rows.Count;
            litQuestionType.Text = GetReadableType(row);
            litQuestionTitle.Text = "Answer the following question";
            litQuestionText.Text = Server.HtmlEncode(questionText).Replace("\n", "<br />");

            phQuestionInput.Controls.Clear();

            if (qType == "MCQ")
            {
                RenderMcq(row, existingAnswer);
            }
            else if (qType == "TrueFalse")
            {
                RenderTrueFalse(existingAnswer);
            }
            else if (qType == "FillBlank")
            {
                RenderFillBlank(existingAnswer);
            }
            else if (qType == "ImageMatch")
            {
                RenderImageMatch(row, existingAnswer);
            }
            else if (qType == "ShortAnswer")
            {
                bool looksLikeTimeline =
                    !string.IsNullOrWhiteSpace(Convert.ToString(row["OptionA"])) &&
                    !string.IsNullOrWhiteSpace(Convert.ToString(row["OptionB"]));

                if (looksLikeTimeline)
                    RenderTimeline(row, existingAnswer);
                else
                    RenderShortAnswer(existingAnswer, row);
            }
            else
            {
                phQuestionInput.Controls.Add(new LiteralControl(
                    "<div class='quiz-empty'>Unsupported question type.</div>"));
            }

            btnPrev.Visible = CurrentQuestionIndex > 0;
            btnNext.Visible = CurrentQuestionIndex < CurrentQuestions.Rows.Count - 1;
            btnSubmitQuiz.Visible = CurrentQuestionIndex == CurrentQuestions.Rows.Count - 1 && !IsReviewMode;

            pnlReviewFeedback.Visible = IsReviewMode;
            if (IsReviewMode)
            {
                litReviewFeedback.Text = BuildReviewFeedback(row, existingAnswer);
            }
            else
            {
                litReviewFeedback.Text = "";
            }

            mvQuiz.ActiveViewIndex = 1;
        }

        private string GetReadableType(DataRow row)
        {
            string qType = Convert.ToString(row["QuestionType"]);

            if (qType == "MCQ") return "Multiple Choice";
            if (qType == "TrueFalse") return "True / False";
            if (qType == "FillBlank") return "Fill in the Blank";
            if (qType == "ImageMatch") return "Image Match";

            if (qType == "ShortAnswer")
            {
                bool looksLikeTimeline =
                    !string.IsNullOrWhiteSpace(Convert.ToString(row["OptionA"])) &&
                    !string.IsNullOrWhiteSpace(Convert.ToString(row["OptionB"]));

                return looksLikeTimeline ? "Timeline Order" : "Short Answer";
            }

            return qType;
        }

        private void RenderMcq(DataRow row, string existingAnswer)
        {
            string html = "<div class='quiz-options'>";

            html += BuildRadioOption("rblMCQ", "A", Convert.ToString(row["OptionA"]), existingAnswer == "A");
            html += BuildRadioOption("rblMCQ", "B", Convert.ToString(row["OptionB"]), existingAnswer == "B");
            html += BuildRadioOption("rblMCQ", "C", Convert.ToString(row["OptionC"]), existingAnswer == "C");
            html += BuildRadioOption("rblMCQ", "D", Convert.ToString(row["OptionD"]), existingAnswer == "D");

            html += "</div>";

            phQuestionInput.Controls.Add(new LiteralControl(html));
        }

        private void RenderTrueFalse(string existingAnswer)
        {
            string html = "<div class='quiz-options'>";
            html += BuildRadioOption("rblTF", "True", "True", existingAnswer == "True");
            html += BuildRadioOption("rblTF", "False", "False", existingAnswer == "False");
            html += "</div>";

            phQuestionInput.Controls.Add(new LiteralControl(html));
        }

        private void RenderFillBlank(string existingAnswer)
        {
            string html = "<input type='text' name='txtFillBlank' class='quiz-textbox' " +
                          "value='" + HtmlAttr(existingAnswer) + "' " +
                          "placeholder='Type your answer here...' />";

            phQuestionInput.Controls.Add(new LiteralControl(html));
        }

        private void RenderShortAnswer(string existingAnswer, DataRow row)
        {
            string helper = "<div class='quiz-empty' style='margin-bottom:12px;'>Write your answer in your own words.</div>";

            if (row["MaxWords"] != DBNull.Value)
            {
                helper += "<div class='quiz-empty' style='margin-bottom:12px;'>Suggested max words: " +
                          Convert.ToString(row["MaxWords"]) + "</div>";
            }

            string html = helper +
                          "<textarea name='txtShortAnswer' class='quiz-textarea' " +
                          "placeholder='Write your answer here...'>" +
                          Server.HtmlEncode(existingAnswer) +
                          "</textarea>";

            phQuestionInput.Controls.Add(new LiteralControl(html));
        }

        private void RenderTimeline(DataRow row, string existingAnswer)
        {
            List<string> events = new List<string>();
            if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionA"]))) events.Add(Convert.ToString(row["OptionA"]));
            if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionB"]))) events.Add(Convert.ToString(row["OptionB"]));
            if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionC"]))) events.Add(Convert.ToString(row["OptionC"]));
            if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionD"]))) events.Add(Convert.ToString(row["OptionD"]));

            Dictionary<string, string> savedRanks = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

            if (!string.IsNullOrWhiteSpace(existingAnswer))
            {
                string[] parts = existingAnswer.Split(new[] { '|' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (string part in parts)
                {
                    string[] pair = part.Split('~');
                    if (pair.Length == 2)
                    {
                        savedRanks[pair[0]] = pair[1];
                    }
                }
            }

            string html = "<div class='timeline-grid'>";

            for (int i = 0; i < events.Count; i++)
            {
                string ev = events[i];
                string selectedRank = savedRanks.ContainsKey(ev) ? savedRanks[ev] : "";

                html += "<div class='timeline-item'>";
                html += "<div class='event-text'>" + Server.HtmlEncode(ev) + "</div>";
                html += "<input type='hidden' name='timeline_event_" + i + "' value='" + HtmlAttr(ev) + "' />";
                html += "<select class='quiz-select' name='timeline_rank_" + i + "'>";
                html += "<option value=''>-- Select Order --</option>";

                for (int j = 1; j <= events.Count; j++)
                {
                    html += "<option value='" + j + "'" + (selectedRank == j.ToString() ? " selected='selected'" : "") + ">" + j + "</option>";
                }

                html += "</select>";
                html += "</div>";
            }

            html += "</div>";

            phQuestionInput.Controls.Add(new LiteralControl(html));
        }

        private void RenderImageMatch(DataRow row, string existingAnswer)
        {
            List<ImageChoice> items = new List<ImageChoice>();

            if (!string.IsNullOrWhiteSpace(Convert.ToString(row["ImageUrl"])))
            {
                items.Add(new ImageChoice
                {
                    Value = "CORRECT",
                    Label = Convert.ToString(row["CorrectLabel"]),
                    ImageUrl = Convert.ToString(row["ImageUrl"])
                });
            }

            if (!string.IsNullOrWhiteSpace(Convert.ToString(row["Distractor1Url"])))
            {
                items.Add(new ImageChoice
                {
                    Value = "D1",
                    Label = Convert.ToString(row["Label1"]),
                    ImageUrl = Convert.ToString(row["Distractor1Url"])
                });
            }

            if (!string.IsNullOrWhiteSpace(Convert.ToString(row["Distractor2Url"])))
            {
                items.Add(new ImageChoice
                {
                    Value = "D2",
                    Label = Convert.ToString(row["Label2"]),
                    ImageUrl = Convert.ToString(row["Distractor2Url"])
                });
            }

            if (!string.IsNullOrWhiteSpace(Convert.ToString(row["Distractor3Url"])))
            {
                items.Add(new ImageChoice
                {
                    Value = "D3",
                    Label = Convert.ToString(row["Label3"]),
                    ImageUrl = Convert.ToString(row["Distractor3Url"])
                });
            }

            items = items.OrderBy(x => Guid.NewGuid()).ToList();

            string html = "<div class='quiz-empty' style='margin-bottom:12px;'>Choose the image that best matches the question.</div>";
            html += "<div class='image-match-grid'>";

            foreach (var item in items)
            {
                bool isSelected = existingAnswer == item.Value;

                html += "<div class='image-choice" + (isSelected ? " selected" : "") + "'>";
                html += "<input type='radio' name='rblImageMatch' value='" + item.Value + "'" +
                        (isSelected ? " checked='checked'" : "") + " />";
                html += "<img src='" + ResolveClientUrl(item.ImageUrl) + "' alt='quiz image' />";
                html += "<label>" + Server.HtmlEncode(item.Label) + "</label>";
                html += "</div>";
            }

            html += "</div>";

            phQuestionInput.Controls.Add(new LiteralControl(html));
        }

        private string BuildRadioOption(string name, string value, string text, bool isChecked)
        {
            if (string.IsNullOrWhiteSpace(text)) return "";

            return "<div class='quiz-option" + (isChecked ? " selected" : "") + "'>" +
                   "<input type='radio' name='" + name + "' value='" + value + "'" + (isChecked ? " checked='checked'" : "") + " />" +
                   "<label>" + Server.HtmlEncode(text) + "</label>" +
                   "</div>";
        }

        private string HtmlAttr(string value)
        {
            return HttpUtility.HtmlAttributeEncode(value ?? "");
        }

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer();

            if (CurrentQuestionIndex > 0)
            {
                CurrentQuestionIndex--;
                RenderCurrentQuestion();
            }
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer();

            if (CurrentQuestionIndex < CurrentQuestions.Rows.Count - 1)
            {
                CurrentQuestionIndex++;
                RenderCurrentQuestion();
            }
        }

        protected void btnSubmitQuiz_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer();
            SubmitQuiz();
        }

        protected void btnBackToList_Click(object sender, EventArgs e)
        {
            CurrentQuizID = 0;
            CurrentQuestionIndex = 0;
            CurrentQuestions = null;
            Answers = new Dictionary<int, string>();

            BindQuizList();
            mvQuiz.ActiveViewIndex = 0;
        }

        protected void btnReviewAnswers_Click(object sender, EventArgs e)
        {
            if (CurrentQuestions == null || CurrentQuestions.Rows.Count == 0)
            {
                ShowMessage("No submitted quiz is available to review.");
                return;
            }

            IsReviewMode = true;
            CurrentQuestionIndex = 0;
            RenderCurrentQuestion();
        }

        protected void btnReattemptQuiz_Click(object sender, EventArgs e)
        {
            if (CurrentQuizID <= 0)
            {
                ShowMessage("No quiz is available for re-attempt.");
                return;
            }

            DataTable dtQuestions = GetQuizQuestions(CurrentQuizID);

            if (dtQuestions.Rows.Count == 0)
            {
                ShowMessage("This quiz has no questions yet.");
                return;
            }

            CurrentQuestionIndex = 0;
            CurrentQuestions = dtQuestions;
            Answers = new Dictionary<int, string>();
            IsReviewMode = false;

            RenderCurrentQuestion();
        }
        private void SaveCurrentAnswer()
        {
            if (IsReviewMode)
                return;
            if (CurrentQuestions == null || CurrentQuestions.Rows.Count == 0)
                return;

            DataRow row = CurrentQuestions.Rows[CurrentQuestionIndex];
            int questionId = Convert.ToInt32(row["QuestionID"]);
            string qType = Convert.ToString(row["QuestionType"]);
            string answer = "";

            if (qType == "MCQ")
            {
                answer = Request.Form["rblMCQ"] ?? "";
            }
            else if (qType == "TrueFalse")
            {
                answer = Request.Form["rblTF"] ?? "";
            }
            else if (qType == "FillBlank")
            {
                answer = (Request.Form["txtFillBlank"] ?? "").Trim();
            }
            else if (qType == "ImageMatch")
            {
                answer = Request.Form["rblImageMatch"] ?? "";
            }
            else if (qType == "ShortAnswer")
            {
                bool looksLikeTimeline =
                    !string.IsNullOrWhiteSpace(Convert.ToString(row["OptionA"])) &&
                    !string.IsNullOrWhiteSpace(Convert.ToString(row["OptionB"]));

                if (looksLikeTimeline)
                {
                    List<string> events = new List<string>();
                    if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionA"]))) events.Add(Convert.ToString(row["OptionA"]));
                    if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionB"]))) events.Add(Convert.ToString(row["OptionB"]));
                    if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionC"]))) events.Add(Convert.ToString(row["OptionC"]));
                    if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionD"]))) events.Add(Convert.ToString(row["OptionD"]));

                    List<string> parts = new List<string>();

                    for (int i = 0; i < events.Count; i++)
                    {
                        string ev = Request.Form["timeline_event_" + i] ?? "";
                        string rank = Request.Form["timeline_rank_" + i] ?? "";
                        parts.Add(ev + "~" + rank);
                    }

                    answer = string.Join("|", parts);
                }
                else
                {
                    answer = (Request.Form["txtShortAnswer"] ?? "").Trim();
                }
            }

            if (Answers.ContainsKey(questionId))
                Answers[questionId] = answer;
            else
                Answers.Add(questionId, answer);
        }

        private void SubmitQuiz()
        {
            if (CurrentQuestions == null || CurrentQuestions.Rows.Count == 0)
            {
                ShowMessage("Unable to submit the quiz.");
                return;
            }

            int totalPoints = 0;
            int earnedPoints = 0;

            foreach (DataRow row in CurrentQuestions.Rows)
            {
                int questionId = Convert.ToInt32(row["QuestionID"]);
                string qType = Convert.ToString(row["QuestionType"]);
                int points = row["Points"] == DBNull.Value ? 1 : Convert.ToInt32(row["Points"]);
                string userAnswer = Answers.ContainsKey(questionId) ? Answers[questionId] : "";

                totalPoints += points;

                if (IsAnswerCorrect(row, qType, userAnswer))
                {
                    earnedPoints += points;
                }
            }

            int percent = totalPoints > 0
                ? (int)Math.Round((earnedPoints * 100.0) / totalPoints)
                : 0;

            int passMark = GetPassMark(CurrentQuizID);
            bool passed = percent >= passMark;

            LastScorePercent = percent;
            LastPassed = passed;
            IsReviewMode = false;

            SaveAttemptIfPossible(CurrentQuizID, percent, passed);

            DataTable dtQuiz = GetQuizById(CurrentQuizID);
            string quizTitle = dtQuiz.Rows.Count > 0 ? Convert.ToString(dtQuiz.Rows[0]["Title"]) : "Quiz";

            litResultTitle.Text = Server.HtmlEncode(quizTitle);
            litScore.Text = percent + "%";
            litResultSummary.Text = "You scored " + percent + "% and " +
                                    (passed ? "passed" : "did not pass") +
                                    ". Pass mark: " + passMark + "%.";

            mvQuiz.ActiveViewIndex = 2;
        }

        private bool IsAnswerCorrect(DataRow row, string qType, string userAnswer)
        {
            if (string.IsNullOrWhiteSpace(userAnswer))
                return false;

            if (qType == "MCQ")
            {
                return string.Equals(
                    userAnswer.Trim(),
                    Convert.ToString(row["CorrectAnswer"]).Trim(),
                    StringComparison.OrdinalIgnoreCase);
            }

            if (qType == "TrueFalse")
            {
                return string.Equals(
                    userAnswer.Trim(),
                    Convert.ToString(row["CorrectAnswer"]).Trim(),
                    StringComparison.OrdinalIgnoreCase);
            }

            if (qType == "FillBlank")
            {
                string correct = Convert.ToString(row["CorrectAnswer"]).Trim();
                return string.Equals(userAnswer.Trim(), correct, StringComparison.OrdinalIgnoreCase);
            }

            if (qType == "ImageMatch")
            {
                return string.Equals(userAnswer.Trim(), "CORRECT", StringComparison.OrdinalIgnoreCase);
            }

            if (qType == "ShortAnswer")
            {
                bool looksLikeTimeline =
                    !string.IsNullOrWhiteSpace(Convert.ToString(row["OptionA"])) &&
                    !string.IsNullOrWhiteSpace(Convert.ToString(row["OptionB"]));

                if (looksLikeTimeline)
                {
                    return CheckTimelineCorrect(row, userAnswer);
                }
                else
                {
                    string correct = Convert.ToString(row["CorrectAnswer"]).Trim();
                    string model = Convert.ToString(row["ModelAnswer"]).Trim();

                    if (!string.IsNullOrWhiteSpace(correct))
                        return string.Equals(userAnswer.Trim(), correct, StringComparison.OrdinalIgnoreCase);

                    if (!string.IsNullOrWhiteSpace(model))
                        return string.Equals(userAnswer.Trim(), model, StringComparison.OrdinalIgnoreCase);

                    return false;
                }
            }

            return false;
        }

        private string BuildReviewFeedback(DataRow row, string userAnswer)
        {
            string qType = Convert.ToString(row["QuestionType"]);
            bool correct = IsAnswerCorrect(row, qType, userAnswer);

            string html = "";

            html += "<div class='review-line'><strong>Your Answer:</strong> " +
                    Server.HtmlEncode(FormatAnswerForDisplay(row, userAnswer)) +
                    "</div>";

            html += "<div class='review-line'><strong>Correct Answer:</strong> " +
                    Server.HtmlEncode(GetCorrectAnswerDisplay(row)) +
                    "</div>";

            html += "<div class='review-line'><strong>Status:</strong> " +
                    "<span class='" + (correct ? "review-correct" : "review-wrong") + "'>" +
                    (correct ? "Correct" : "Incorrect") +
                    "</span></div>";

            string explanation = Convert.ToString(row["Explanation"]).Trim();
            if (!string.IsNullOrWhiteSpace(explanation))
            {
                html += "<div class='review-line'><strong>Explanation:</strong> " +
                        Server.HtmlEncode(explanation) +
                        "</div>";
            }

            return html;
        }

        private string GetCorrectAnswerDisplay(DataRow row)
        {
            string qType = Convert.ToString(row["QuestionType"]);

            if (qType == "MCQ")
            {
                string key = Convert.ToString(row["CorrectAnswer"]).Trim().ToUpper();

                if (key == "A") return "A - " + Convert.ToString(row["OptionA"]);
                if (key == "B") return "B - " + Convert.ToString(row["OptionB"]);
                if (key == "C") return "C - " + Convert.ToString(row["OptionC"]);
                if (key == "D") return "D - " + Convert.ToString(row["OptionD"]);

                return key;
            }

            if (qType == "TrueFalse")
            {
                return Convert.ToString(row["CorrectAnswer"]).Trim();
            }

            if (qType == "FillBlank")
            {
                return Convert.ToString(row["CorrectAnswer"]).Trim();
            }

            if (qType == "ImageMatch")
            {
                string label = Convert.ToString(row["CorrectLabel"]).Trim();
                return string.IsNullOrWhiteSpace(label) ? "Correct image" : label;
            }

            if (qType == "ShortAnswer")
            {
                bool looksLikeTimeline =
                    !string.IsNullOrWhiteSpace(Convert.ToString(row["OptionA"])) &&
                    !string.IsNullOrWhiteSpace(Convert.ToString(row["OptionB"]));

                if (looksLikeTimeline)
                {
                    List<string> events = new List<string>();
                    if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionA"]))) events.Add(Convert.ToString(row["OptionA"]).Trim());
                    if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionB"]))) events.Add(Convert.ToString(row["OptionB"]).Trim());
                    if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionC"]))) events.Add(Convert.ToString(row["OptionC"]).Trim());
                    if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionD"]))) events.Add(Convert.ToString(row["OptionD"]).Trim());

                    return string.Join(" -> ", events);
                }

                string correct = Convert.ToString(row["CorrectAnswer"]).Trim();
                if (!string.IsNullOrWhiteSpace(correct))
                    return correct;

                string model = Convert.ToString(row["ModelAnswer"]).Trim();
                if (!string.IsNullOrWhiteSpace(model))
                    return model;
            }

            return "-";
        }

        private string FormatAnswerForDisplay(DataRow row, string userAnswer)
        {
            if (string.IsNullOrWhiteSpace(userAnswer))
                return "(No answer)";

            string qType = Convert.ToString(row["QuestionType"]);

            if (qType == "MCQ")
            {
                string key = userAnswer.Trim().ToUpper();

                if (key == "A") return "A - " + Convert.ToString(row["OptionA"]);
                if (key == "B") return "B - " + Convert.ToString(row["OptionB"]);
                if (key == "C") return "C - " + Convert.ToString(row["OptionC"]);
                if (key == "D") return "D - " + Convert.ToString(row["OptionD"]);

                return userAnswer;
            }

            if (qType == "ImageMatch")
            {
                if (userAnswer.Equals("CORRECT", StringComparison.OrdinalIgnoreCase))
                    return Convert.ToString(row["CorrectLabel"]);

                if (userAnswer.Equals("D1", StringComparison.OrdinalIgnoreCase))
                    return Convert.ToString(row["Label1"]);

                if (userAnswer.Equals("D2", StringComparison.OrdinalIgnoreCase))
                    return Convert.ToString(row["Label2"]);

                if (userAnswer.Equals("D3", StringComparison.OrdinalIgnoreCase))
                    return Convert.ToString(row["Label3"]);
            }

            if (qType == "ShortAnswer")
            {
                bool looksLikeTimeline =
                    !string.IsNullOrWhiteSpace(Convert.ToString(row["OptionA"])) &&
                    !string.IsNullOrWhiteSpace(Convert.ToString(row["OptionB"]));

                if (looksLikeTimeline)
                {
                    string[] parts = userAnswer.Split(new[] { '|' }, StringSplitOptions.RemoveEmptyEntries);
                    List<string> ordered = new List<string>();

                    foreach (string part in parts)
                    {
                        string[] pair = part.Split('~');
                        if (pair.Length == 2)
                        {
                            ordered.Add(pair[0] + " = " + pair[1]);
                        }
                    }

                    return ordered.Count > 0 ? string.Join(", ", ordered) : userAnswer;
                }
            }

            return userAnswer;
        }
        private bool CheckTimelineCorrect(DataRow row, string userAnswer)
        {
            if (string.IsNullOrWhiteSpace(userAnswer))
                return false;

            List<string> correctEvents = new List<string>();
            if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionA"]))) correctEvents.Add(Convert.ToString(row["OptionA"]).Trim());
            if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionB"]))) correctEvents.Add(Convert.ToString(row["OptionB"]).Trim());
            if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionC"]))) correctEvents.Add(Convert.ToString(row["OptionC"]).Trim());
            if (!string.IsNullOrWhiteSpace(Convert.ToString(row["OptionD"]))) correctEvents.Add(Convert.ToString(row["OptionD"]).Trim());

            string[] parts = userAnswer.Split(new[] { '|' }, StringSplitOptions.RemoveEmptyEntries);
            Dictionary<string, int> ranked = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);

            foreach (string part in parts)
            {
                string[] pair = part.Split('~');
                if (pair.Length == 2)
                {
                    int rank;
                    if (int.TryParse(pair[1], out rank))
                    {
                        ranked[pair[0].Trim()] = rank;
                    }
                }
            }

            if (ranked.Count != correctEvents.Count)
                return false;

            for (int i = 0; i < correctEvents.Count; i++)
            {
                string ev = correctEvents[i];
                int expectedRank = i + 1;

                if (!ranked.ContainsKey(ev) || ranked[ev] != expectedRank)
                    return false;
            }

            return true;
        }
        private bool IsQuizPublished(int quizId)
        {
            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(@"
        SELECT COUNT(*)
        FROM Quizzes q
        INNER JOIN Modules m ON q.ModuleID = m.ModuleID
        WHERE q.QuizID = @QuizID
          AND m.Status = 'Published';", con))
            {
                cmd.Parameters.AddWithValue("@QuizID", quizId);
                con.Open();
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }
        private int GetPassMark(int quizId)
        {
            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(@"
        SELECT ISNULL(q.PassMark, 60)
        FROM Quizzes q
        INNER JOIN Modules m ON q.ModuleID = m.ModuleID
        WHERE q.QuizID = @QuizID
          AND m.Status = 'Published';", con))
            {
                cmd.Parameters.AddWithValue("@QuizID", quizId);
                con.Open();

                object obj = cmd.ExecuteScalar();
                if (obj == null || obj == DBNull.Value) return 60;

                return Convert.ToInt32(obj);
            }
        }

        private void SaveAttemptIfPossible(int quizId, int score, bool passed)
        {
            if (Session["UserID"] == null)
                return;

            if (!QuizExistsInMainTable(quizId))
                return;

            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO QuizAttempts (QuizID, UserID, Score, Passed, AttemptedAt)
                VALUES (@QuizID, @UserID, @Score, @Passed, GETDATE());", con))
            {
                cmd.Parameters.AddWithValue("@QuizID", quizId);
                cmd.Parameters.AddWithValue("@UserID", Convert.ToInt32(Session["UserID"]));
                cmd.Parameters.AddWithValue("@Score", score);
                cmd.Parameters.AddWithValue("@Passed", passed);

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private bool QuizExistsInMainTable(int quizId)
        {
            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(@"
        SELECT COUNT(*)
        FROM Quizzes q
        INNER JOIN Modules m ON q.ModuleID = m.ModuleID
        WHERE q.QuizID = @QuizID
          AND m.Status = 'Published';", con))
            {
                cmd.Parameters.AddWithValue("@QuizID", quizId);
                con.Open();
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }

        private void ShowMessage(string message)
        {
            lblMsg.Text = message;
            lblMsg.Visible = true;
        }

        private class ImageChoice
        {
            public string Value { get; set; }
            public string Label { get; set; }
            public string ImageUrl { get; set; }
        }

        private DataTable GetAllQuizList()
        {
            using (SqlConnection con = new SqlConnection(_cs))
            using (SqlCommand cmd = new SqlCommand(@"
        ;WITH QuizBase AS
        (
            SELECT DISTINCT qq.QuizID
            FROM QuizQuestions qq
        ),
        FirstQuestionType AS
        (
            SELECT 
                qq.QuizID,
                MIN(qq.QuestionID) AS FirstQuestionID
            FROM QuizQuestions qq
            GROUP BY qq.QuizID
        )
        SELECT
            qb.QuizID,
            COALESCE(NULLIF(q.Title, ''), 'Quiz #' + CAST(qb.QuizID AS NVARCHAR(20))) AS Title,
            COALESCE(NULLIF(q.QuizType, ''), qq1.QuestionType, 'General') AS QuizType,
            ISNULL(q.PassMark, 60) AS PassMark,
            COALESCE(NULLIF(m.Title, ''), 'General Quiz') AS ModuleTitle
        FROM QuizBase qb
        LEFT JOIN Quizzes q
            ON qb.QuizID = q.QuizID
        INNER JOIN Modules m
            ON q.ModuleID = m.ModuleID
        LEFT JOIN FirstQuestionType fqt
            ON qb.QuizID = fqt.QuizID
        LEFT JOIN QuizQuestions qq1
            ON fqt.FirstQuestionID = qq1.QuestionID
        WHERE m.Status = 'Published'
        ORDER BY qb.QuizID;", con))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }
        private void BindQuizType(DataTable dtAll, string quizType, Repeater rpt, Panel pnlEmpty)
        {
            DataView dv = new DataView(dtAll);
            dv.RowFilter = "QuizType = '" + quizType.Replace("'", "''") + "'";

            DataTable dtFiltered = dv.ToTable();

            rpt.DataSource = dtFiltered;
            rpt.DataBind();

            pnlEmpty.Visible = dtFiltered.Rows.Count == 0;
        }
    }
}