using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using G5_Digital_Museum.Helpers;

namespace G5_Digital_Museum.Admin_ASPX
{
    public partial class Admin_SystemReports : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadChartData();
                LoadRecentAttempts();
            }
        }

        private void LoadChartData()
        {
            // Users by Role
            var roleTable = DataAccess.GetUsersByRole();
            var roleLabels = new StringBuilder("[");
            var roleValues = new StringBuilder("[");
            int totalUsers = 0;
            string dominantRole = "-";
            int dominantCount = 0;
            foreach (DataRow row in roleTable.Rows)
            {
                roleLabels.Append($"\"{row["Role"]}\",");
                roleValues.Append($"{row["TotalUsers"]},");
                int count = Convert.ToInt32(row["TotalUsers"]);
                totalUsers += count;
                if (count > dominantCount) { dominantCount = count; dominantRole = row["Role"].ToString(); }
            }
            if (roleTable.Rows.Count > 0) { roleLabels.Length--; roleValues.Length--; }
            hdnRoleLabels.Value = roleLabels.Append("]").ToString();
            hdnRoleData.Value = roleValues.Append("]").ToString();
            lblRoleDesc.Text = $"There are <strong>{totalUsers}</strong> registered users. The largest group is <strong>{dominantRole}</strong> with <strong>{dominantCount}</strong> accounts.";

            // Exhibits by Category
            var catTable = DataAccess.GetExhibitsByCategory();
            var catLabels = new StringBuilder("[");
            var catValues = new StringBuilder("[");
            string topCat = "-";
            int topCatCount = 0;
            int totalExhibits = 0;
            foreach (DataRow row in catTable.Rows)
            {
                catLabels.Append($"\"{row["Category"].ToString().Replace("\"", "'")}\",");
                catValues.Append($"{row["TotalExhibits"]},");
                int count = Convert.ToInt32(row["TotalExhibits"]);
                totalExhibits += count;
                if (count > topCatCount) { topCatCount = count; topCat = row["Category"].ToString(); }
            }
            if (catTable.Rows.Count > 0) { catLabels.Length--; catValues.Length--; }
            hdnCatLabels.Value = catLabels.Append("]").ToString();
            hdnCatData.Value = catValues.Append("]").ToString();
            lblCatDesc.Text = $"The museum has <strong>{totalExhibits}</strong> active exhibitions across <strong>{catTable.Rows.Count}</strong> categories. The most covered category is <strong>{topCat}</strong> with <strong>{topCatCount}</strong> exhibitions.";

            // Quiz Pass vs Fail
            var pf = DataAccess.GetQuizPassFail();
            int passed = 0, failed = 0;
            if (pf.Rows.Count > 0)
            {
                passed = pf.Rows[0]["Passed"] == DBNull.Value ? 0 : Convert.ToInt32(pf.Rows[0]["Passed"]);
                failed = pf.Rows[0]["Failed"] == DBNull.Value ? 0 : Convert.ToInt32(pf.Rows[0]["Failed"]);
            }
            hdnPassed.Value = passed.ToString();
            hdnFailed.Value = failed.ToString();
            int totalPF = passed + failed;
            double passRate = totalPF > 0 ? Math.Round((double)passed / totalPF * 100, 1) : 0;
            string pfMsg = passRate >= 70 ? "Learners are performing well overall." : passRate >= 50 ? "Performance is moderate — consider reviewing quiz difficulty." : "Pass rate is low. Quiz content or learner engagement may need attention.";
            lblPassFailDesc.Text = $"Out of <strong>{totalPF}</strong> total attempts, <strong>{passed}</strong> passed and <strong>{failed}</strong> failed — a pass rate of <strong>{passRate}%</strong>. {pfMsg}";

            // Exhibitions by Status
            var statusTable = DataAccess.GetExhibitionsByStatus();
            var statusLabels = new StringBuilder("[");
            var statusValues = new StringBuilder("[");
            int published = 0, draft = 0;
            foreach (DataRow row in statusTable.Rows)
            {
                statusLabels.Append($"\"{row["Status"]}\",");
                statusValues.Append($"{row["Total"]},");
                if (row["Status"].ToString() == "Published") published = Convert.ToInt32(row["Total"]);
                if (row["Status"].ToString() == "Draft") draft = Convert.ToInt32(row["Total"]);
            }
            if (statusTable.Rows.Count > 0) { statusLabels.Length--; statusValues.Length--; }
            hdnStatusLabels.Value = statusLabels.Append("]").ToString();
            hdnStatusData.Value = statusValues.Append("]").ToString();
            lblStatusDesc.Text = $"<strong>{published}</strong> exhibitions are live and visible to visitors. <strong>{draft}</strong> are still in draft and not yet published.";

            // Top 5 Quizzes
            var quizTable = DataAccess.GetTopQuizzesByAttempts(5);
            var quizLabels = new StringBuilder("[");
            var quizValues = new StringBuilder("[");
            string topQuiz = "-";
            int topQuizCount = 0;
            foreach (DataRow row in quizTable.Rows)
            {
                quizLabels.Append($"\"{row["Title"].ToString().Replace("\"", "'")}\",");
                quizValues.Append($"{row["TotalAttempts"]},");
                int count = Convert.ToInt32(row["TotalAttempts"]);
                if (count > topQuizCount) { topQuizCount = count; topQuiz = row["Title"].ToString(); }
            }
            if (quizTable.Rows.Count > 0) { quizLabels.Length--; quizValues.Length--; }
            hdnQuizLabels.Value = quizLabels.Append("]").ToString();
            hdnQuizData.Value = quizValues.Append("]").ToString();
            lblQuizDesc.Text = quizTable.Rows.Count > 0
                ? $"The most attempted quiz is <strong>{topQuiz}</strong> with <strong>{topQuizCount}</strong> attempts. Showing the top <strong>{quizTable.Rows.Count}</strong> quizzes by engagement."
                : "No quiz attempts have been recorded yet.";

            // User Growth by Month
            var growthTable = DataAccess.GetUserGrowthByMonth();
            var growthLabels = new StringBuilder("[");
            var growthValues = new StringBuilder("[");
            string peakMonth = "-";
            int peakCount = 0;
            foreach (DataRow row in growthTable.Rows)
            {
                growthLabels.Append($"\"{row["Month"]}\",");
                growthValues.Append($"{row["Total"]},");
                int count = Convert.ToInt32(row["Total"]);
                if (count > peakCount) { peakCount = count; peakMonth = row["Month"].ToString(); }
            }
            if (growthTable.Rows.Count > 0) { growthLabels.Length--; growthValues.Length--; }
            hdnGrowthLabels.Value = growthLabels.Append("]").ToString();
            hdnGrowthData.Value = growthValues.Append("]").ToString();
            lblGrowthDesc.Text = growthTable.Rows.Count > 0
                ? $"User registrations span <strong>{growthTable.Rows.Count}</strong> month(s). The peak registration month was <strong>{peakMonth}</strong> with <strong>{peakCount}</strong> new users."
                : "No user registration data available yet.";
            // Build CSV export data
            var csv = new System.Text.StringBuilder();
            csv.AppendLine("Digital Museum - System Reports Export");
            csv.AppendLine("Generated:," + DateTime.Now.ToString("dd/MM/yyyy HH:mm"));
            csv.AppendLine();

            csv.AppendLine("USERS BY ROLE");
            csv.AppendLine("Role,Count");
            foreach (DataRow row in DataAccess.GetUsersByRole().Rows)
                csv.AppendLine($"{row["Role"]},{row["TotalUsers"]}");
            csv.AppendLine();

            csv.AppendLine("EXHIBITIONS BY CATEGORY");
            csv.AppendLine("Category,Count");
            foreach (DataRow row in DataAccess.GetExhibitsByCategory().Rows)
                csv.AppendLine($"\"{row["Category"]}\",{row["TotalExhibits"]}");
            csv.AppendLine();

            csv.AppendLine("QUIZ PASS VS FAIL");
            csv.AppendLine("Result,Count");
            var pf2 = DataAccess.GetQuizPassFail();
            if (pf2.Rows.Count > 0)
            {
                int p2 = pf2.Rows[0]["Passed"] == DBNull.Value ? 0 : Convert.ToInt32(pf2.Rows[0]["Passed"]);
                int f2 = pf2.Rows[0]["Failed"] == DBNull.Value ? 0 : Convert.ToInt32(pf2.Rows[0]["Failed"]);
                csv.AppendLine($"Passed,{p2}");
                csv.AppendLine($"Failed,{f2}");
            }
            csv.AppendLine();

            csv.AppendLine("TOP 5 QUIZZES BY ATTEMPTS");
            csv.AppendLine("Quiz Title,Attempts");
            foreach (DataRow row in DataAccess.GetTopQuizzesByAttempts(5).Rows)
                csv.AppendLine($"\"{row["Title"]}\",{row["TotalAttempts"]}");
            csv.AppendLine();

            csv.AppendLine("USER GROWTH BY MONTH");
            csv.AppendLine("Month,New Users");
            foreach (DataRow row in DataAccess.GetUserGrowthByMonth().Rows)
                csv.AppendLine($"{row["Month"]},{row["Total"]}");
            csv.AppendLine();

            csv.AppendLine("RECENT QUIZ ATTEMPTS");
            csv.AppendLine("AttemptID,User,Quiz,Score,Passed,Date");
            foreach (DataRow row in DataAccess.GetRecentQuizAttempts(50).Rows)
                csv.AppendLine($"{row["AttemptID"]},\"{row["UserName"]}\",\"{row["QuizTitle"]}\",{row["Score"]},{row["Passed"]},{Convert.ToDateTime(row["AttemptedAt"]):dd/MM/yyyy}");

            hdnExportData.Value = csv.ToString();
        }

        private void LoadRecentAttempts()
        {
            gvRecentAttempts.DataSource = DataAccess.GetRecentQuizAttempts(10);
            gvRecentAttempts.DataBind();
        }
    }
}