using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using G5_Digital_Museum.Helpers;

namespace G5_Digital_Museum
{
    public partial class Admin_Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadDashboard();
        }

        private void LoadDashboard()
        {
            int totalUsers = DataAccess.GetUsersCount();
            int totalExhibits = DataAccess.GetExhibitsCount();
            int totalQuizzes = DataAccess.GetQuizzesCount();
            int totalAttempts = DataAccess.GetQuizAttemptsCount();

            hdnTotalUsers.Value = totalUsers.ToString();
            hdnTotalExhibits.Value = totalExhibits.ToString();
            hdnTotalQuizzes.Value = totalQuizzes.ToString();
            hdnTotalAttempts.Value = totalAttempts.ToString();

            hdnPendingFeedback.Value = DataAccess.GetPendingFeedbackCount().ToString();
            hdnDraftExhibits.Value = DataAccess.GetDraftExhibitsCount().ToString();
            hdnInactiveUsers.Value = DataAccess.GetInactiveUsersCount().ToString();
            hdnTotalModules.Value = DataAccess.GetModulesCount().ToString();
            hdnQuizzesNoAttempts.Value = DataAccess.GetQuizzesWithNoAttempts().ToString();
            hdnNeverLoggedIn.Value = DataAccess.GetNeverLoggedInUsers().ToString();

            double avgScore = DataAccess.GetAverageQuizScore();
            double quizRate = DataAccess.GetQuizCompletionRate();
            double userScore = Math.Min(totalUsers / 100.0, 1) * 40;
            double quizScore = avgScore * 0.3;
            double exhibitScore = Math.Min(totalExhibits / 20.0, 1) * 30;
            double healthScore = Math.Round(userScore + quizScore + exhibitScore, 1);

            hdnAvgScore.Value = Math.Round(avgScore, 1).ToString();
            hdnQuizRate.Value = Math.Round(quizRate, 1).ToString();
            hdnHealthScore.Value = healthScore.ToString();
            hdnUserScore.Value = Math.Round(userScore, 1).ToString();
            hdnQuizScorePts.Value = Math.Round(quizScore, 1).ToString();
            hdnExhibitScore.Value = Math.Round(exhibitScore, 1).ToString();

            var roleTable = DataAccess.GetUsersByRole();
            var rl = new StringBuilder("[");
            var rd = new StringBuilder("[");
            foreach (DataRow row in roleTable.Rows)
            {
                rl.Append($"\"{row["Role"]}\",");
                rd.Append($"{row["TotalUsers"]},");
            }
            if (roleTable.Rows.Count > 0) { rl.Length--; rd.Length--; }
            hdnRoleLabels.Value = rl.Append("]").ToString();
            hdnRoleData.Value = rd.Append("]").ToString();

            hdnTopCategory.Value = DataAccess.GetMostPopularCategory();
            hdnNewestUser.Value = DataAccess.GetNewestUser();

            var exhibits = DataAccess.GetPublishedExhibits(6);
            rptExhibits.DataSource = exhibits;
            rptExhibits.DataBind();
            lblNoExhibits.Visible = exhibits.Rows.Count == 0;
        }

        protected string RenderExhibitThumb(object imageUrl)
        {
            string url = (imageUrl == null || imageUrl == DBNull.Value) ? "" : imageUrl.ToString().Trim();
            if (string.IsNullOrEmpty(url))
                return "<div class='exhibit-no-img'>No Image</div>";
            if (!url.StartsWith("http://") && !url.StartsWith("https://") && !url.StartsWith("/"))
                url = "https://" + url;
            return "<img src='" + url + "' class='exhibit-thumb' onerror=\"this.parentElement.innerHTML='<div class=\\'exhibit-no-img\\'>No Image</div>';\" />";
        }
    }
}