using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace G5_Digital_Museum
{
    public partial class Member_MasterPage : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                UpdateLoginButton();
            }
            if (Session["UserID"] == null)
            {
                lnkManageProfile.Visible = false;
            }
            else
            {
                lnkManageProfile.Visible = true;
            }
        }

        private void UpdateLoginButton()
        {
            if (Session["UserID"] != null)
            {
                btnLoginLogout.Text = "Logout";
            }
            else
            {
                btnLoginLogout.Text = "Login";
            }
        }

        protected void btnLoginLogout_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] != null)
            {
                // Logout
                Session.Clear();
                Session.Abandon();

                Response.Redirect("Main_LoginPage.aspx");
            }
            else
            {
                // Go to login
                Response.Redirect("Main_LoginPage.aspx");
            }
        }
    }
}