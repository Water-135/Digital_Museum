using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace G5_Digital_Museum
{
    public partial class Login_MasterPage : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected string GetHomeUrl()
        {
            if (Session["Role"] == null)
                return "~/Guest_Homepage.aspx";

            string role = Session["Role"].ToString();

            if (role == "Admin")
                return "~/admin_aspx/Admin_Dashboard.aspx";
            else if (role == "Instructor")
                return "~/Instructor_Homepage.aspx";
            else
                return "~/Member_HomePage.aspx";
        }
    }
}