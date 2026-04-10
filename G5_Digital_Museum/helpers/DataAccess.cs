using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace G5_Digital_Museum.Helpers
{
    public class DataAccess
    {
        private static string ConnectionString =>
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        private static SqlConnection GetConnection() =>
            new SqlConnection(ConnectionString);

        // ─────────────────────────────────────────────────────────────────────
        // Generic Helpers
        // ─────────────────────────────────────────────────────────────────────

        public static DataTable ExecuteQuery(string sql, List<SqlParameter> parameters = null)
        {
            var dt = new DataTable();
            using (var conn = GetConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.CommandType = CommandType.Text;
                if (parameters != null) cmd.Parameters.AddRange(parameters.ToArray());
                conn.Open();
                using (var adapter = new SqlDataAdapter(cmd))
                    adapter.Fill(dt);
            }
            return dt;
        }

        public static int ExecuteNonQuery(string sql, List<SqlParameter> parameters = null)
        {
            using (var conn = GetConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.CommandType = CommandType.Text;
                if (parameters != null) cmd.Parameters.AddRange(parameters.ToArray());
                conn.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        public static object ExecuteScalar(string sql, List<SqlParameter> parameters = null)
        {
            using (var conn = GetConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.CommandType = CommandType.Text;
                if (parameters != null) cmd.Parameters.AddRange(parameters.ToArray());
                conn.Open();
                return cmd.ExecuteScalar();
            }
        }

        // ─────────────────────────────────────────────────────────────────────
        // Users
        // ─────────────────────────────────────────────────────────────────────



        public static DataRow GetUserById(int userId)
        {
            const string sql = @"
                SELECT UserID, FullName, Email, Role, CreatedAt, IsActive, PasswordHash 
                FROM Users WHERE UserID = @UserID";
            var p = new List<SqlParameter> { new SqlParameter("@UserID", SqlDbType.Int) { Value = userId } };
            var dt = ExecuteQuery(sql, p);
            return dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }



        public static bool EmailExists(string email)
        {
            const string sql = "SELECT COUNT(1) FROM Users WHERE Email = @Email";
            var p = new List<SqlParameter> { new SqlParameter("@Email", SqlDbType.NVarChar, 200) { Value = email } };
            return Convert.ToInt32(ExecuteScalar(sql, p)) > 0;
        }

        public static int CreateUser(string fullName, string email, string passwordHash, string role = "Member")
        {
            const string sql = @"
                INSERT INTO Users (FullName, Email, PasswordHash, Role)
                OUTPUT INSERTED.UserID
                VALUES (@FullName, @Email, @PasswordHash, @Role)";

            var p = new List<SqlParameter>
            {
                new SqlParameter("@FullName",     SqlDbType.NVarChar, 100) { Value = fullName },
                new SqlParameter("@Email",        SqlDbType.NVarChar, 150) { Value = email },
                new SqlParameter("@PasswordHash", SqlDbType.NVarChar, 255) { Value = HashPassword(passwordHash) },
                new SqlParameter("@Role",         SqlDbType.NVarChar, 20)  { Value = role }
            };
            return Convert.ToInt32(ExecuteScalar(sql, p));
        }

        public static bool UpdateUser(int userId, string fullName, string email, string role)
        {
            const string sql = @"
                UPDATE Users 
                SET FullName = @FullName, Email = @Email, Role = @Role
                WHERE UserID = @UserID";

            var p = new List<SqlParameter>
            {
                new SqlParameter("@FullName", SqlDbType.NVarChar, 100) { Value = fullName },
                new SqlParameter("@Email",    SqlDbType.NVarChar, 150) { Value = email },
                new SqlParameter("@Role",     SqlDbType.NVarChar, 20)  { Value = role },
                new SqlParameter("@UserID",   SqlDbType.Int)           { Value = userId }
            };
            return ExecuteNonQuery(sql, p) > 0;
        }

        public static bool DeleteUser(int userId)
        {
            const string sql = "DELETE FROM Users WHERE UserID = @UserID";
            var p = new List<SqlParameter> { new SqlParameter("@UserID", SqlDbType.Int) { Value = userId } };
            return ExecuteNonQuery(sql, p) > 0;
        }

        public static bool UpdatePassword(int userId, string newPasswordHash)
        {
            const string sql = "UPDATE Users SET PasswordHash = @PasswordHash WHERE UserID = @UserID";
            var p = new List<SqlParameter>
    {
        new SqlParameter("@PasswordHash", SqlDbType.NVarChar, 255) { Value = HashPassword(newPasswordHash) },
        new SqlParameter("@UserID",       SqlDbType.Int)           { Value = userId }
    };
            return ExecuteNonQuery(sql, p) > 0;
        }



        public static int GetUsersCount()
        {
            const string sql = "SELECT COUNT(1) FROM Users";
            return Convert.ToInt32(ExecuteScalar(sql));
        }



        public static DataTable GetFilteredUsers(string search = "", string role = "", string dateFrom = "", string dateTo = "")
        {
            string sql = "SELECT UserID, FullName, Email, Role, CreatedAt, IsActive FROM Users WHERE 1=1";
            var p = new List<SqlParameter>();

            if (!string.IsNullOrWhiteSpace(search))
            {
                sql += " AND FullName LIKE @Search";
                p.Add(new SqlParameter("@Search", SqlDbType.NVarChar, 200) { Value = "%" + search + "%" });
            }
            if (!string.IsNullOrWhiteSpace(role))
            {
                sql += " AND Role = @Role";
                p.Add(new SqlParameter("@Role", SqlDbType.NVarChar, 20) { Value = role });
            }
            if (!string.IsNullOrWhiteSpace(dateFrom))
            {
                sql += " AND CreatedAt >= @DateFrom";
                p.Add(new SqlParameter("@DateFrom", SqlDbType.DateTime) { Value = Convert.ToDateTime(dateFrom) });
            }
            if (!string.IsNullOrWhiteSpace(dateTo))
            {
                sql += " AND CreatedAt <= @DateTo";
                p.Add(new SqlParameter("@DateTo", SqlDbType.DateTime) { Value = Convert.ToDateTime(dateTo + " 23:59:59") });
            }
            sql += " ORDER BY CreatedAt ASC";
            return ExecuteQuery(sql, p);
        }

        public static DataTable GetUsersByRole()
        {
            const string sql = @"
                SELECT Role, COUNT(*) AS TotalUsers 
                FROM Users 
                GROUP BY Role 
                ORDER BY TotalUsers DESC";
            return ExecuteQuery(sql);
        }

        public static string GetNewestUser()
        {
            const string sql = "SELECT TOP 1 FullName FROM Users ORDER BY CreatedAt DESC";
            var result = ExecuteScalar(sql);
            return result == null || result == DBNull.Value ? "No users yet" : result.ToString();
        }

        // ─────────────────────────────────────────────────────────────────────
        // Exhibitions
        // ─────────────────────────────────────────────────────────────────────

        public static DataTable GetAllExhibits()
        {
            const string sql = @"
        SELECT ExhibitionID, Title, Description, Category,
               Timeline AS Period, ImageUrl, Status, IsFeatured,
               CreatedAt AS CreatedDate,
               0 AS DisplayOrder, '' AS VideoUrl, '' AS AudioUrl
        FROM Exhibitions
        WHERE IsActive = 1
        ORDER BY CreatedAt DESC";
            return ExecuteQuery(sql);
        }



        public static int GetExhibitsCount()
        {
            const string sql = "SELECT COUNT(1) FROM Exhibitions WHERE IsActive = 1";
            return Convert.ToInt32(ExecuteScalar(sql));
        }

        public static bool AddExhibit(string title, string description, string period, string imageUrl, string videoUrl, string audioUrl, string category, int displayOrder, int createdByUserId)
        {
            const string sql = @"
                INSERT INTO Exhibitions (Title, Description, Timeline, ImageUrl, Category, Status, IsActive, CreatedByID)
                VALUES (@Title, @Description, @Timeline, @ImageUrl, @Category, 'Published', 1, @CreatedByID)";

            var p = new List<SqlParameter>
            {
                new SqlParameter("@Title",       SqlDbType.NVarChar, 200) { Value = title },
                new SqlParameter("@Description", SqlDbType.NVarChar, -1)  { Value = description },
                new SqlParameter("@Timeline",    SqlDbType.NVarChar, 100) { Value = (object)period    ?? DBNull.Value },
                new SqlParameter("@ImageUrl",    SqlDbType.NVarChar, 500) { Value = (object)imageUrl  ?? DBNull.Value },
                new SqlParameter("@Category",    SqlDbType.NVarChar, 50)  { Value = category },
                new SqlParameter("@CreatedByID", SqlDbType.Int)           { Value = createdByUserId }
            };
            return ExecuteNonQuery(sql, p) > 0;
        }

        public static bool UpdateExhibit(int exhibitId, string title, string description, string period, string imageUrl, string videoUrl, string audioUrl, string category, int displayOrder)
        {
            const string sql = @"
                UPDATE Exhibitions 
                SET Title = @Title, Description = @Description, Timeline = @Timeline,
                    ImageUrl = @ImageUrl, Category = @Category, UpdatedAt = GETDATE()
                WHERE ExhibitionID = @ExhibitionID";

            var p = new List<SqlParameter>
            {
                new SqlParameter("@Title",        SqlDbType.NVarChar, 200) { Value = title },
                new SqlParameter("@Description",  SqlDbType.NVarChar, -1)  { Value = description },
                new SqlParameter("@Timeline",     SqlDbType.NVarChar, 100) { Value = (object)period   ?? DBNull.Value },
                new SqlParameter("@ImageUrl",     SqlDbType.NVarChar, 500) { Value = (object)imageUrl ?? DBNull.Value },
                new SqlParameter("@Category",     SqlDbType.NVarChar, 50)  { Value = category },
                new SqlParameter("@ExhibitionID", SqlDbType.Int)           { Value = exhibitId }
            };
            return ExecuteNonQuery(sql, p) > 0;
        }

        public static bool DeleteExhibit(int exhibitId)
        {
            const string sql = "UPDATE Exhibitions SET IsActive = 0 WHERE ExhibitionID = @ExhibitionID";
            var p = new List<SqlParameter> { new SqlParameter("@ExhibitionID", SqlDbType.Int) { Value = exhibitId } };
            return ExecuteNonQuery(sql, p) > 0;
        }

        public static DataTable GetExhibitsByCategory()
        {
            const string sql = @"
                SELECT Category, COUNT(*) AS TotalExhibits 
                FROM Exhibitions 
                WHERE IsActive = 1
                GROUP BY Category 
                ORDER BY TotalExhibits DESC";
            return ExecuteQuery(sql);
        }

        public static string GetMostPopularCategory()
        {
            const string sql = @"
                SELECT TOP 1 Category 
                FROM Exhibitions 
                WHERE IsActive = 1
                GROUP BY Category 
                ORDER BY COUNT(*) DESC";
            var result = ExecuteScalar(sql);
            return result == null || result == DBNull.Value ? "No data yet" : result.ToString();
        }

        // ─────────────────────────────────────────────────────────────────────
        // Quizzes
        // ─────────────────────────────────────────────────────────────────────


        public static int GetQuizzesCount()
        {
            const string sql = "SELECT COUNT(1) FROM Quizzes WHERE IsActive = 1";
            return Convert.ToInt32(ExecuteScalar(sql));
        }

        public static DataTable GetTopQuizzesByAttempts(int count)
        {
            const string sql = @"
                SELECT TOP (@Count) q.Title, COUNT(qa.AttemptID) AS TotalAttempts
                FROM Quizzes q
                LEFT JOIN QuizAttempts qa ON qa.QuizID = q.QuizID
                GROUP BY q.Title
                ORDER BY TotalAttempts DESC";
            var p = new List<SqlParameter> { new SqlParameter("@Count", SqlDbType.Int) { Value = count } };
            return ExecuteQuery(sql, p);
        }



        // ─────────────────────────────────────────────────────────────────────
        // Quiz Attempts
        // ─────────────────────────────────────────────────────────────────────

        public static int GetQuizAttemptsCount()
        {
            const string sql = "SELECT COUNT(1) FROM QuizAttempts";
            return Convert.ToInt32(ExecuteScalar(sql));
        }

        public static DataTable GetRecentQuizAttempts(int count)
        {
            const string sql = @"
                SELECT TOP (@Count)
                    qa.AttemptID, u.FullName AS UserName, q.Title AS QuizTitle,
                    qa.Score, qa.Passed, qa.AttemptedAt
                FROM QuizAttempts qa
                JOIN Users u  ON u.UserID  = qa.UserID
                JOIN Quizzes q ON q.QuizID = qa.QuizID
                ORDER BY qa.AttemptedAt DESC";
            var p = new List<SqlParameter> { new SqlParameter("@Count", SqlDbType.Int) { Value = count } };
            return ExecuteQuery(sql, p);
        }

        public static double GetAverageQuizScore()
        {
            const string sql = "SELECT AVG(CAST(Score AS FLOAT)) FROM QuizAttempts";
            var result = ExecuteScalar(sql);
            return result == null || result == DBNull.Value ? 0 : Math.Round(Convert.ToDouble(result), 1);
        }

        public static double GetQuizCompletionRate()
        {
            const string sql = @"
                SELECT 
                    CASE WHEN COUNT(DISTINCT u.UserID) = 0 THEN 0
                    ELSE CAST(COUNT(DISTINCT qa.UserID) AS FLOAT) / COUNT(DISTINCT u.UserID) * 100
                    END
                FROM Users u
                LEFT JOIN QuizAttempts qa ON qa.UserID = u.UserID";
            var result = ExecuteScalar(sql);
            return result == null || result == DBNull.Value ? 0 : Math.Round(Convert.ToDouble(result), 1);
        }

        // ─────────────────────────────────────────────────────────────────────
        // Feedback
        // ─────────────────────────────────────────────────────────────────────

        public static DataTable GetAllFeedback()
        {
            const string sql = @"
                SELECT FeedbackID, 
                       ISNULL(GuestName, 'Registered User') AS GuestName,
                       ISNULL(GuestEmail, '') AS GuestEmail,
                       ISNULL(Subject, '') AS Subject,
                       Message, Rating, Status, SubmittedAt
                FROM Feedback
                ORDER BY SubmittedAt DESC";
            return ExecuteQuery(sql);
        }



        public static bool UpdateFeedbackStatus(int feedbackId, string status, string note = "")
        {
            const string sql = @"
                UPDATE Feedback 
                SET Status = @Status, InstructorNote = @Note, ReviewedAt = GETDATE()
                WHERE FeedbackID = @FeedbackID";
            var p = new List<SqlParameter>
            {
                new SqlParameter("@Status",     SqlDbType.NVarChar, 20)  { Value = status },
                new SqlParameter("@Note",       SqlDbType.NVarChar, -1)  { Value = (object)note ?? DBNull.Value },
                new SqlParameter("@FeedbackID", SqlDbType.Int)           { Value = feedbackId }
            };
            return ExecuteNonQuery(sql, p) > 0;
        }

        public static bool DeleteFeedback(int feedbackId)
        {
            const string sql = "DELETE FROM Feedback WHERE FeedbackID = @FeedbackID";
            var p = new List<SqlParameter> { new SqlParameter("@FeedbackID", SqlDbType.Int) { Value = feedbackId } };
            return ExecuteNonQuery(sql, p) > 0;
        }

        // ─────────────────────────────────────────────────────────────────────
        // Modules
        // ─────────────────────────────────────────────────────────────────────



        public static int GetModulesCount()
        {
            const string sql = "SELECT COUNT(1) FROM Modules WHERE IsActive = 1";
            return Convert.ToInt32(ExecuteScalar(sql));
        }

        public static DataTable GetQuizPassFail()
        {
            const string sql = @"
        SELECT 
            SUM(CASE WHEN Passed = 1 THEN 1 ELSE 0 END) AS Passed,
            SUM(CASE WHEN Passed = 0 THEN 1 ELSE 0 END) AS Failed
        FROM QuizAttempts";
            return ExecuteQuery(sql);
        }

        public static DataTable GetExhibitionsByStatus()
        {
            const string sql = @"
        SELECT Status, COUNT(*) AS Total 
        FROM Exhibitions 
        WHERE IsActive = 1
        GROUP BY Status";
            return ExecuteQuery(sql);
        }

        public static DataTable GetUserGrowthByMonth()
        {
            const string sql = @"
        SELECT FORMAT(CreatedAt, 'MMM yyyy') AS Month,
               COUNT(*) AS Total
        FROM Users
        GROUP BY FORMAT(CreatedAt, 'MMM yyyy'), YEAR(CreatedAt), MONTH(CreatedAt)
        ORDER BY YEAR(CreatedAt), MONTH(CreatedAt)";
            return ExecuteQuery(sql);
        }
        public static int GetDraftExhibitsCount()
        {
            const string sql = "SELECT COUNT(1) FROM Exhibitions WHERE Status='Draft' AND IsActive=1";
            return Convert.ToInt32(ExecuteScalar(sql));
        }

        public static int GetInactiveUsersCount()
        {
            const string sql = "SELECT COUNT(1) FROM Users WHERE IsActive=0";
            return Convert.ToInt32(ExecuteScalar(sql));
        }
        public static int GetPendingFeedbackCount()
        {
            const string sql = "SELECT COUNT(1) FROM Feedback WHERE Status = 'Pending'";
            return Convert.ToInt32(ExecuteScalar(sql));
        }
        public static DataTable GetPublishedExhibits(int count = 6)
        {
            string sql = @"
        SELECT TOP (@Count) ExhibitionID, Title, Category, Timeline, ImageUrl, CreatedAt
        FROM Exhibitions
        WHERE Status = 'Published' AND IsActive = 1
        ORDER BY CreatedAt DESC";
            var p = new System.Collections.Generic.List<SqlParameter>
    {
        new SqlParameter("@Count", SqlDbType.Int) { Value = count }
    };
            return ExecuteQuery(sql, p);
        }

        public static int GetQuizzesWithNoAttempts()
        {
            const string sql = @"
        SELECT COUNT(1) FROM Quizzes q
        WHERE q.IsActive = 1
        AND (SELECT COUNT(1) FROM QuizAttempts qa WHERE qa.QuizID = q.QuizID) < 1";
            return Convert.ToInt32(ExecuteScalar(sql));
        }

        public static int GetNeverLoggedInUsers()
        {
            const string sql = "SELECT COUNT(1) FROM Users WHERE LastLoginAt IS NULL AND IsActive = 1";
            return Convert.ToInt32(ExecuteScalar(sql));
        }
        public static DataRow GetModuleById(int moduleId)
        {
            const string sql = "SELECT * FROM Modules WHERE ModuleID=@ModuleID";
            var p = new System.Collections.Generic.List<SqlParameter>
    {
        new SqlParameter("@ModuleID", SqlDbType.Int) { Value = moduleId }
    };
            var dt = ExecuteQuery(sql, p);
            return dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }

        public static bool AddModule(string title, string description, string status, int sortOrder)
        {
            const string sql = @"
        INSERT INTO Modules (Title, Description, Status, SortOrder, IsActive, CreatedAt)
        VALUES (@Title, @Description, @Status, @SortOrder, 1, GETDATE())";
            var p = new System.Collections.Generic.List<SqlParameter>
    {
        new SqlParameter("@Title",       SqlDbType.NVarChar, 200) { Value = title },
        new SqlParameter("@Description", SqlDbType.NVarChar, -1)  { Value = (object)description ?? DBNull.Value },
        new SqlParameter("@Status",      SqlDbType.NVarChar, 20)  { Value = status },
        new SqlParameter("@SortOrder",   SqlDbType.Int)            { Value = sortOrder }
    };
            return ExecuteNonQuery(sql, p) > 0;
        }

        public static bool UpdateModule(int moduleId, string title, string description, string status, int sortOrder)
        {
            const string sql = @"
        UPDATE Modules
        SET Title=@Title, Description=@Description, Status=@Status, SortOrder=@SortOrder
        WHERE ModuleID=@ModuleID";
            var p = new System.Collections.Generic.List<SqlParameter>
    {
        new SqlParameter("@ModuleID",    SqlDbType.Int)            { Value = moduleId },
        new SqlParameter("@Title",       SqlDbType.NVarChar, 200) { Value = title },
        new SqlParameter("@Description", SqlDbType.NVarChar, -1)  { Value = (object)description ?? DBNull.Value },
        new SqlParameter("@Status",      SqlDbType.NVarChar, 20)  { Value = status },
        new SqlParameter("@SortOrder",   SqlDbType.Int)            { Value = sortOrder }
    };
            return ExecuteNonQuery(sql, p) > 0;
        }

        public static bool DeleteModule(int moduleId)
        {
            const string sql = "UPDATE Modules SET IsActive=0 WHERE ModuleID=@ModuleID";
            var p = new System.Collections.Generic.List<SqlParameter>
    {
        new SqlParameter("@ModuleID", SqlDbType.Int) { Value = moduleId }
    };
            return ExecuteNonQuery(sql, p) > 0;
        }

        public static DataTable GetAllQuizzesWithAttempts()
        {
            const string sql = @"
        SELECT q.QuizID, q.Title, q.QuizType, q.PassMark, q.IsActive, q.CreatedAt,
               ISNULL(m.Title, 'No Module') AS ModuleTitle,
               COUNT(qa.AttemptID) AS AttemptCount
        FROM Quizzes q
        LEFT JOIN Modules m  ON m.ModuleID  = q.ModuleID
        LEFT JOIN QuizAttempts qa ON qa.QuizID = q.QuizID
        GROUP BY q.QuizID, q.Title, q.QuizType, q.PassMark, q.IsActive, q.CreatedAt, m.Title
        ORDER BY q.CreatedAt DESC";
            return ExecuteQuery(sql);
        }

        public static bool ToggleQuizActive(int quizId, bool isActive)
        {
            const string sql = "UPDATE Quizzes SET IsActive=@IsActive WHERE QuizID=@QuizID";
            var p = new System.Collections.Generic.List<SqlParameter>
    {
        new SqlParameter("@IsActive", SqlDbType.Bit) { Value = isActive },
        new SqlParameter("@QuizID",   SqlDbType.Int) { Value = quizId }
    };
            return ExecuteNonQuery(sql, p) > 0;
        }

        public static bool UpdateExhibitStatus(int exhibitId, string status)
        {
            const string sql = "UPDATE Exhibitions SET Status=@Status, UpdatedAt=GETDATE() WHERE ExhibitionID=@ExhibitionID";
            var p = new System.Collections.Generic.List<SqlParameter>
    {
        new SqlParameter("@Status",       SqlDbType.NVarChar, 20) { Value = status },
        new SqlParameter("@ExhibitionID", SqlDbType.Int)           { Value = exhibitId }
    };
            return ExecuteNonQuery(sql, p) > 0;
        }

        public static bool ToggleExhibitFeatured(int exhibitId, bool isFeatured)
        {
            const string sql = "UPDATE Exhibitions SET IsFeatured=@IsFeatured, UpdatedAt=GETDATE() WHERE ExhibitionID=@ExhibitionID";
            var p = new System.Collections.Generic.List<SqlParameter>
    {
        new SqlParameter("@IsFeatured",   SqlDbType.Bit) { Value = isFeatured },
        new SqlParameter("@ExhibitionID", SqlDbType.Int) { Value = exhibitId }
    };
            return ExecuteNonQuery(sql, p) > 0;
        }

        public static DataTable GetFilteredFeedback(string status = "", string sortBy = "newest")
        {
            string sql = @"SELECT FeedbackID, GuestName, GuestEmail, Subject, Message, Rating, Status, SubmittedAt
                   FROM Feedback WHERE 1=1";
            var p = new System.Collections.Generic.List<SqlParameter>();
            if (!string.IsNullOrEmpty(status))
            {
                sql += " AND Status = @Status";
                p.Add(new SqlParameter("@Status", SqlDbType.NVarChar, 20) { Value = status });
            }
            sql += sortBy == "rating" ? " ORDER BY Rating DESC, SubmittedAt DESC" : " ORDER BY SubmittedAt DESC";
            return ExecuteQuery(sql, p);
        }
        public static DataTable GetAllModules()
        {
            const string sql = @"
        SELECT ModuleID, Title, Description, Status, SortOrder, IsActive, CreatedAt
        FROM Modules
        WHERE IsActive = 1
        ORDER BY SortOrder ASC";
            return ExecuteQuery(sql);
        }
        public static DataTable GetQuizzesByModule(int moduleId)
        {
            const string sql = @"
        SELECT q.QuizID, q.Title, q.QuizType, q.PassMark, q.IsActive, q.CreatedAt,
               COUNT(qa.AttemptID) AS AttemptCount
        FROM Quizzes q
        LEFT JOIN QuizAttempts qa ON qa.QuizID = q.QuizID
        WHERE q.ModuleID = @ModuleID
        GROUP BY q.QuizID, q.Title, q.QuizType, q.PassMark, q.IsActive, q.CreatedAt
        ORDER BY q.CreatedAt DESC";
            var p = new System.Collections.Generic.List<SqlParameter>
    {
        new SqlParameter("@ModuleID", SqlDbType.Int) { Value = moduleId }
    };
            return ExecuteQuery(sql, p);
        }
        public static bool UpdateAdminProfile(int userId, string fullName, string email)
        {
            const string sql = "UPDATE Users SET FullName=@FullName, Email=@Email WHERE UserID=@UserID";
            var p = new System.Collections.Generic.List<SqlParameter>
    {
        new SqlParameter("@FullName", SqlDbType.NVarChar, 100) { Value = fullName },
        new SqlParameter("@Email",    SqlDbType.NVarChar, 150) { Value = email },
        new SqlParameter("@UserID",   SqlDbType.Int)            { Value = userId }
    };
            return ExecuteNonQuery(sql, p) > 0;
        }
        public static System.Collections.Generic.Dictionary<string, string> GetAllSettings()
        {
            const string sql = "SELECT SettingKey, SettingValue FROM SiteSettings";
            var dt = ExecuteQuery(sql);
            var result = new System.Collections.Generic.Dictionary<string, string>();
            foreach (DataRow row in dt.Rows)
                result[row["SettingKey"].ToString()] = row["SettingValue"].ToString();
            return result;
        }

        public static bool SaveSetting(string key, string value)
        {
            const string sql = @"
        IF EXISTS (SELECT 1 FROM SiteSettings WHERE SettingKey=@Key)
            UPDATE SiteSettings SET SettingValue=@Value WHERE SettingKey=@Key
        ELSE
            INSERT INTO SiteSettings (SettingKey, SettingValue) VALUES (@Key, @Value)";
            var p = new System.Collections.Generic.List<SqlParameter>
    {
        new SqlParameter("@Key",   SqlDbType.NVarChar, 100) { Value = key },
        new SqlParameter("@Value", SqlDbType.NVarChar, 500) { Value = value }
    };
            return ExecuteNonQuery(sql, p) > 0;
        }
        public static string HashPassword(string plainText)
        {
            using (var sha256 = System.Security.Cryptography.SHA256.Create())
            {
                byte[] bytes = System.Text.Encoding.UTF8.GetBytes(plainText);
                byte[] hash = sha256.ComputeHash(bytes);
                return Convert.ToBase64String(hash);
            }
        }
    }
}