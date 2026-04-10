using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace G5_Digital_Museum.Admin_ASPX
{
    public partial class Admin_Master : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string fullName = Session["AdminName"] as string ?? "Admin";
            string role = Session["AdminRole"] as string ?? "Administrator";
            string initial = fullName.Length > 0 ? fullName.Substring(0, 1).ToUpper() : "A";

            var lblName = FindControl("lblAdminName") as Label;
            var lblRole = FindControl("lblAdminRole") as Label;
            var lblInitial = FindControl("lblAdminInitial") as Label;

            if (lblName != null) lblName.Text = fullName;
            if (lblRole != null) lblRole.Text = role;
            if (lblInitial != null) lblInitial.Text = initial;
        }
    }
}