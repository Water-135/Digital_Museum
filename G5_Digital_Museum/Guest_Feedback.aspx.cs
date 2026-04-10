using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace G5_Digital_Museum
{
    public partial class Guest_Feedback : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadFeedbackEntries();
            }
        }

        /// <summary>
        /// Handles the guestbook form submission.
        /// Demonstrates: INSERT (Insert new records) with parameterized queries.
        /// </summary>
        protected void btnSubmitFeedback_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            string visitorName = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string message = txtMessage.Text.Trim();
            string country = ddlCountry.SelectedValue;
            int rating = 0;

            if (string.IsNullOrEmpty(visitorName) || visitorName.Length < 2)
            {
                ShowError("Name must be at least 2 characters.");
                return;
            }

            if (string.IsNullOrEmpty(email) || !IsValidEmail(email))
            {
                ShowError("Please enter a valid email address.");
                return;
            }

            if (string.IsNullOrEmpty(message) || message.Length < 10)
            {
                ShowError("Message must be at least 10 characters long.");
                return;
            }

            if (message.Length > 1000)
            {
                ShowError("Message cannot exceed 1000 characters.");
                return;
            }

            if (!int.TryParse(hfRating.Value, out rating) || rating < 1 || rating > 5)
            {
                ShowError("Please select a valid rating.");
                return;
            }

            visitorName = HttpUtility.HtmlEncode(visitorName);
            message = HttpUtility.HtmlEncode(message);

            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = @"
                        INSERT INTO Feedback (GuestName, GuestEmail, Subject, Message, Rating, Status, SubmittedAt)
                        VALUES (@GuestName, @GuestEmail, @Subject, @Message, @Rating, @Status, @SubmittedAt)";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@GuestName", visitorName);
                    cmd.Parameters.AddWithValue("@GuestEmail", email);
                    cmd.Parameters.AddWithValue("@Subject", "Guest Reflection");
                    cmd.Parameters.AddWithValue("@Rating", rating);
                    cmd.Parameters.AddWithValue("@Message", message);
                    cmd.Parameters.AddWithValue("@SubmittedAt", DateTime.Now);
                    cmd.Parameters.AddWithValue("@Status", "Pending");

                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        ClearForm();
                        lblSuccess.Text = "Thank you for your message! Your guestbook entry has been submitted and will appear after review.";
                        lblSuccess.Visible = true;
                        lblError.Visible = false;

                        LoadFeedbackEntries();
                    }
                    else
                    {
                        ShowError("There was an issue saving your entry. Please try again.");
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("Unable to connect to the database. Your message could not be saved at this time.");
                System.Diagnostics.Debug.WriteLine("Feedback INSERT Error: " + ex.Message);
            }
        }

        /// <summary>
        /// Loads approved feedback entries. Demonstrates: SELECT (Display records).
        /// </summary>
        private void LoadFeedbackEntries()
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = @"
                        SELECT FeedbackID, GuestName AS VisitorName, GuestEmail AS Email, ISNULL(Subject,'') AS Country, Rating, Message, SubmittedAt AS SubmittedDate
                        FROM Feedback
                        ORDER BY SubmittedAt DESC";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    conn.Open();

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptFeedback.DataSource = dt;
                        rptFeedback.DataBind();
                        lblNoEntries.Visible = false;
                    }
                    else
                    {
                        rptFeedback.Visible = false;
                        lblNoEntries.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                rptFeedback.Visible = false;
                lblNoEntries.Text = "DB Error: " + ex.Message;
                lblNoEntries.Visible = true;
                System.Diagnostics.Debug.WriteLine("Feedback SELECT Error: " + ex.Message);
            }
        }

        protected string GetStarRating(int rating)
        {
            string stars = "";
            for (int i = 0; i < 5; i++)
            {
                stars += (i < rating) ? "&#9733; " : "&#9734; ";
            }
            return stars;
        }

        private bool IsValidEmail(string email)
        {
            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            lblError.Visible = true;
            lblSuccess.Visible = false;
        }

        private void ClearForm()
        {
            txtName.Text = "";
            txtEmail.Text = "";
            txtMessage.Text = "";
            ddlCountry.SelectedIndex = 0;
            hfRating.Value = "";
        }
    }
}
