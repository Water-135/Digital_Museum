using System;

namespace G5_Digital_Museum
{
    public partial class Member_HomePage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Member_Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string fullName = Session["FullName"] != null
                    ? Session["FullName"].ToString()
                    : "Member";

                lblWelcome.Text = "Welcome, " + fullName;
            }
        }
    }
}