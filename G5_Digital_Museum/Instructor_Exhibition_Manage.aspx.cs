using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace G5_Digital_Museum
{
    public partial class Instructor_Exhibition_Manage : System.Web.UI.Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        private static readonly string[] Categories = {
            "Background & Causes",
            "The Massacre",
            "Survivor Testimonies",
            "International Response",
            "War Crimes & Trials",
            "Remembrance & Legacy"
        };

        private int EditingID
        {
            get => ViewState["EditExhID"] is int i ? i : 0;
            set => ViewState["EditExhID"] = value;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadGallery();
        }

        // ── LOAD ─────────────────────────────────────────────────────
        private void LoadGallery(string search = "", string cat = "", string status = "")
        {
            string sql = @"
                SELECT ExhibitionID, Title, Category, Status,
                       ISNULL(CAST(IsFeatured AS INT), 0)   AS IsFeatured,
                       ISNULL(ImageUrl, '')                 AS ImageUrl,
                       ISNULL(Description, '')              AS Description,
                       ISNULL(Timeline, '')                 AS Timeline,
                       CONVERT(VARCHAR(10), IncidentDate, 103) AS IncidentDate
                FROM   Exhibitions
                WHERE  IsActive = 1
                  AND  (@Search = '' OR Title LIKE '%'+@Search+'%')
                  AND  (@Cat    = '' OR Category = @Cat)
                  AND  (@Status = '' OR Status   = @Status)
                ORDER  BY Category, CreatedAt DESC";

            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    cmd.Parameters.AddWithValue("@Search", search ?? "");
                    cmd.Parameters.AddWithValue("@Cat", cat ?? "");
                    cmd.Parameters.AddWithValue("@Status", status ?? "");
                    conn.Open();
                    da.Fill(dt);
                }
            }
            catch (Exception ex)
            {
                phGallery.Controls.Clear();
                phGallery.Controls.Add(new LiteralControl(
                    "<p style='color:#c94c4c;padding:20px;'>Error loading exhibitions: "
                    + HttpUtility.HtmlEncode(ex.Message) + "</p>"));
                lblExhCount.Text = "0 exhibition(s)";
                return;
            }

            lblExhCount.Text = dt.Rows.Count + " exhibition(s)";
            lblNoResults.Visible = dt.Rows.Count == 0;
            phGallery.Controls.Clear();
            if (dt.Rows.Count == 0) return;

            var allCategories = new List<string>(Categories);
            foreach (DataRow r in dt.Rows)
            {
                string c = r["Category"].ToString().Trim();
                if (!allCategories.Contains(c)) allCategories.Add(c);
            }

            foreach (string category in allCategories)
            {
                DataRow[] rows = dt.Select("Category = '" + category.Replace("'", "''") + "'");
                if (rows.Length == 0) continue;

                string safeId = category
                    .Replace(" ", "_").Replace("&", "and")
                    .Replace(";", "").Replace("'", "");

                var sb = new StringBuilder();
                sb.Append($@"
                <div class='cat-group'>
                    <div class='cat-group__header' onclick='toggleCatGroup(""{safeId}"")'>
                        <div class='cat-group__left'>
                            <span class='cat-group__icon' id='catIcon_{safeId}'>&#9660;</span>
                            <span class='cat-group__name'>{HttpUtility.HtmlEncode(category)}</span>
                            <span class='cat-group__count'>{rows.Length}</span>
                        </div>
                        <div class='cat-group__bar'></div>
                    </div>
                    <div class='exh-gallery' id='catGrid_{safeId}'>");

                foreach (DataRow r in rows)
                {
                    string id = r["ExhibitionID"].ToString();
                    string title = HttpUtility.HtmlEncode(r["Title"].ToString());
                    string rawDesc = r["Description"].ToString();
                    string desc = HttpUtility.HtmlEncode(
                        rawDesc.Length > 120 ? rawDesc.Substring(0, 120) + "…" : rawDesc);
                    string imgUrl = r["ImageUrl"].ToString();
                    if (string.IsNullOrWhiteSpace(imgUrl))
                        imgUrl = "https://images.unsplash.com/photo-1503152394-c571994fd383?w=600";
                    string stat = r["Status"].ToString();
                    bool isPub = stat == "Published";
                    string statCls = isPub ? "exh-card__status--live" : "exh-card__status--draft";
                    string timeline = HttpUtility.HtmlEncode(r["Timeline"].ToString());
                    string idate = r["IncidentDate"].ToString();
                    bool featured = r["IsFeatured"].ToString() == "1";

                    // ── Action buttons ──
                    string actionButtons = isPub
                        ? $@"<span style='font-size:10px;color:#555;letter-spacing:1.5px;font-weight:700;
                                         text-transform:uppercase;padding:8px 10px;
                                         border:1px solid rgba(255,255,255,0.07);
                                         background:rgba(255,255,255,0.02);'>
                                &#128274;&nbsp;Published — Read Only</span>
                             <button type='button' class='btn btn-xs btn-danger'
                                 onclick='if(confirm(""Remove this exhibition?"")) __doPostBack(""btnDeleteHidden"",""{id}"")'>Delete</button>"
                        : $@"<button type='button' class='btn btn-xs'
                                 onclick='__doPostBack(""btnEditHidden"",""{id}"")'>Edit</button>
                             <button type='button' class='btn btn-xs btn-danger'
                                 onclick='if(confirm(""Remove this exhibition?"")) __doPostBack(""btnDeleteHidden"",""{id}"")'>Delete</button>";

                    sb.Append($@"
                    <div class='exh-card{(featured ? " exh-card--featured" : "")}'>
                        <div class='exh-card__img-wrap'>
                            <img src='{imgUrl}' alt='{title}' loading='lazy'
                                 onerror=""this.src='https://images.unsplash.com/photo-1503152394-c571994fd383?w=600'"" />
                            <span class='exh-card__status {statCls}'>{stat}</span>
                            {(featured ? "<span class='exh-card__featured'>&#9733; Featured</span>" : "")}
                        </div>
                        <div class='exh-card__body'>
                            <div class='exh-card__kicker'>{HttpUtility.HtmlEncode(category)}</div>
                            <h3 class='exh-card__title'>{title}</h3>
                            <p class='exh-card__desc'>{desc}</p>
                            <div class='exh-card__meta'>
                                {(string.IsNullOrEmpty(idate) ? "" : $"<span class='chip'>&#128197;&nbsp;{idate}</span>")}
                                {(string.IsNullOrEmpty(timeline) ? "" : $"<span class='chip'>&#128336;&nbsp;{timeline}</span>")}
                            </div>
                        </div>
                        <div class='exh-card__actions'>{actionButtons}</div>
                    </div>");
                }

                sb.Append("</div></div>");
                phGallery.Controls.Add(new LiteralControl(sb.ToString()));
            }
        }

        // ── Handle ──
        protected void Page_PreLoad(object sender, EventArgs e)
        {
            string target = Request.Form["__EVENTTARGET"];
            string arg = Request.Form["__EVENTARGUMENT"];

            if (target == "btnEditHidden" && int.TryParse(arg, out int editId))
            {
                // Block edit if already Published
                using (SqlConnection chk = new SqlConnection(ConnStr))
                using (SqlCommand chkCmd = new SqlCommand(
                    "SELECT Status FROM Exhibitions WHERE ExhibitionID=@ID", chk))
                {
                    chkCmd.Parameters.AddWithValue("@ID", editId);
                    chk.Open();
                    if (chkCmd.ExecuteScalar()?.ToString() == "Published")
                    {
                        LoadGallery(txtSearch.Text, ddlFilterCat.SelectedValue, ddlFilterStatus.SelectedValue);
                        return;
                    }
                }
                LoadForEdit(editId);
                LoadGallery(txtSearch.Text, ddlFilterCat.SelectedValue, ddlFilterStatus.SelectedValue);
            }
            else if (target == "btnDeleteHidden" && int.TryParse(arg, out int delId))
            {
                DoDelete(delId);
                LoadGallery(txtSearch.Text, ddlFilterCat.SelectedValue, ddlFilterStatus.SelectedValue);
            }
        }

        // ── SAVE ───
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTitle.Text))
            { ShowMsg("Title is required.", false); return; }
            if (string.IsNullOrWhiteSpace(txtDesc.Text))
            { ShowMsg("Narrative description is required.", false); return; }

            string imgUrl = null;
            string imgSource = "url";

            if (fuCover.HasFile)
            {
                imgUrl = SaveUploadedImage();
                if (imgUrl == null) return;
                imgSource = "file";
            }
            else if (!string.IsNullOrWhiteSpace(txtImageUrl.Text))
            {
                imgUrl = txtImageUrl.Text.Trim();
                imgSource = "url";
            }

            // Block save if editing a Published exhibition
            if (EditingID != 0)
            {
                using (SqlConnection chk = new SqlConnection(ConnStr))
                using (SqlCommand chkCmd = new SqlCommand(
                    "SELECT Status FROM Exhibitions WHERE ExhibitionID=@ID", chk))
                {
                    chkCmd.Parameters.AddWithValue("@ID", EditingID);
                    chk.Open();
                    if (chkCmd.ExecuteScalar()?.ToString() == "Published")
                    {
                        ShowMsg("Cannot edit — this exhibition is already Published.", false);
                        return;
                    }
                }
            }

            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                if (EditingID == 0)
                {
                    string sql = @"
                        INSERT INTO Exhibitions
                            (Title, Category, Description, IncidentDate, Timeline,
                             ImageUrl, ImageSource, Status, IsFeatured,
                             CreatedByID, IsActive, CreatedAt)
                        VALUES
                            (@Title, @Cat, @Desc, @IncidentDate, @Timeline,
                             @Img, @ImgSrc, @Status, @Featured,
                             @By, 1, GETDATE())";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Title", txtTitle.Text.Trim());
                        cmd.Parameters.AddWithValue("@Cat", ddlCategory.SelectedValue);
                        cmd.Parameters.AddWithValue("@Desc", txtDesc.Text.Trim());
                        cmd.Parameters.AddWithValue("@IncidentDate", ParseDate(txtIncidentDate.Text));
                        cmd.Parameters.AddWithValue("@Timeline", txtTimeline.Text.Trim());
                        cmd.Parameters.AddWithValue("@Img", (object)imgUrl ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ImgSrc", imgSource);
                        cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);
                        cmd.Parameters.AddWithValue("@Featured", ddlFeatured.SelectedValue == "1");
                        cmd.Parameters.AddWithValue("@By", Session["UserID"] ?? (object)DBNull.Value);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMsg("Exhibition created successfully.", true);
                }
                else
                {
                    string imgPart = imgUrl != null ? ", ImageUrl=@Img, ImageSource=@ImgSrc" : "";
                    string sql = $@"
                        UPDATE Exhibitions
                        SET Title=@Title, Category=@Cat, Description=@Desc,
                            IncidentDate=@IncidentDate, Timeline=@Timeline{imgPart},
                            Status=@Status, IsFeatured=@Featured, UpdatedAt=GETDATE()
                        WHERE ExhibitionID=@ID AND Status='Draft'";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Title", txtTitle.Text.Trim());
                        cmd.Parameters.AddWithValue("@Cat", ddlCategory.SelectedValue);
                        cmd.Parameters.AddWithValue("@Desc", txtDesc.Text.Trim());
                        cmd.Parameters.AddWithValue("@IncidentDate", ParseDate(txtIncidentDate.Text));
                        cmd.Parameters.AddWithValue("@Timeline", txtTimeline.Text.Trim());
                        cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);
                        cmd.Parameters.AddWithValue("@Featured", ddlFeatured.SelectedValue == "1");
                        cmd.Parameters.AddWithValue("@ID", EditingID);
                        if (imgUrl != null)
                        {
                            cmd.Parameters.AddWithValue("@Img", imgUrl);
                            cmd.Parameters.AddWithValue("@ImgSrc", imgSource);
                        }
                        cmd.ExecuteNonQuery();
                    }
                    ShowMsg("Exhibition updated successfully.", true);
                }
            }

            ClearForm();
            LoadGallery();
            hfPanelOpen.Value = "0";
            hfPanelEditing.Value = "0";
        }

        // ── EDIT load ─────────────────────────────────────────────────
        private void LoadForEdit(int id)
        {
            EditingID = id;
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT * FROM Exhibitions WHERE ExhibitionID=@ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", id);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return;
                    txtTitle.Text = r["Title"].ToString();
                    txtDesc.Text = r["Description"].ToString();
                    txtTimeline.Text = r["Timeline"].ToString();
                    txtIncidentDate.Text = r["IncidentDate"] != DBNull.Value
                        ? Convert.ToDateTime(r["IncidentDate"]).ToString("yyyy-MM-dd") : "";
                    SetDDL(ddlCategory, r["Category"].ToString());
                    SetDDL(ddlStatus, r["Status"].ToString());
                    ddlFeatured.SelectedValue =
                        r["IsFeatured"] != DBNull.Value && Convert.ToBoolean(r["IsFeatured"]) ? "1" : "0";
                    string img = r["ImageUrl"].ToString();
                    if (!string.IsNullOrEmpty(img))
                    {
                        imgPreview.ImageUrl = img;
                        imgPreview.Visible = true;
                        txtImageUrl.Text = img;
                    }
                }
            }
            hfPanelOpen.Value = "1";
            hfPanelEditing.Value = "1";
        }

        // ── DELETE ────────────────────────────────────────────────────
        private void DoDelete(int id)
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE Exhibitions SET IsActive=0 WHERE ExhibitionID=@ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", id);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            ShowMsg("Exhibition removed.", true);
        }

        // ── FILTER / SEARCH ───────────────────────────────────────────
        protected void btnSearch_Click(object sender, EventArgs e) =>
            LoadGallery(txtSearch.Text.Trim(), ddlFilterCat.SelectedValue, ddlFilterStatus.SelectedValue);

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlFilterCat.SelectedIndex = ddlFilterStatus.SelectedIndex = 0;
            LoadGallery();
        }

        protected void ddlFilterCat_Changed(object sender, EventArgs e) =>
            LoadGallery(txtSearch.Text.Trim(), ddlFilterCat.SelectedValue, ddlFilterStatus.SelectedValue);

        protected void ddlFilterStatus_Changed(object sender, EventArgs e) =>
            LoadGallery(txtSearch.Text.Trim(), ddlFilterCat.SelectedValue, ddlFilterStatus.SelectedValue);

        protected void btnClear_Click(object sender, EventArgs e) => ClearForm();

        // ── HELPERS ───────────────────────────────────────────────────
        private void ClearForm()
        {
            EditingID = 0;
            txtTitle.Text = txtDesc.Text = txtTimeline.Text =
            txtIncidentDate.Text = txtImageUrl.Text = "";
            ddlCategory.SelectedIndex = ddlStatus.SelectedIndex =
            ddlFeatured.SelectedIndex = 0;
            imgPreview.Visible = false;
            lblMsg.Text = "";
        }

        private string SaveUploadedImage()
        {
            string ext = Path.GetExtension(fuCover.FileName).ToLower();
            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png")
            { ShowMsg("Only JPG/PNG allowed.", false); return null; }
            if (fuCover.PostedFile.ContentLength > 2 * 1024 * 1024)
            { ShowMsg("Image must be under 2 MB.", false); return null; }
            string dir = Server.MapPath("~/Image/Exhibitions/");
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
            string name = Guid.NewGuid().ToString("N") + ext;
            fuCover.SaveAs(Path.Combine(dir, name));
            return ResolveUrl("~/Image/Exhibitions/" + name);
        }

        private object ParseDate(string s) =>
            DateTime.TryParse(s, out DateTime d) ? (object)d : DBNull.Value;

        private void ShowMsg(string msg, bool ok)
        {
            lblMsg.Text = msg;
            lblMsg.ForeColor = ok
                ? System.Drawing.Color.FromArgb(94, 203, 138)
                : System.Drawing.Color.FromArgb(201, 76, 76);
        }

        private static void SetDDL(DropDownList ddl, string val)
        {
            if (ddl.Items.FindByValue(val) != null)
                ddl.SelectedValue = val;
        }
    }
}