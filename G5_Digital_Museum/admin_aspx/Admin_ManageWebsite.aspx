<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_ManageWebsite.aspx.cs" Inherits="G5_Digital_Museum.Admin_ASPX.Admin_ManageWebsite" MasterPageFile="~/Admin_ASPX/Admin_Master.Master" %>

<asp:Content ContentPlaceHolderID="PageTitle" runat="server">
    <h2 class="mb-0">MANAGE WEBSITE</h2>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert d-block mb-3"></asp:Label>

    <div class="card p-4 mb-4">
        <h5 class="mb-3">Homepage Banner Settings</h5>
        <div class="row">
            <div class="col-md-4 mb-3">
                <label class="form-label">Banner Headline</label>
                <asp:TextBox ID="txtBannerHeadline" runat="server" CssClass="form-control" Placeholder="Enter main headline"></asp:TextBox>
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtBannerHeadline"
                    ValidationGroup="SaveBanner" CssClass="val-msg"
                    ErrorMessage="Banner headline is required." Display="Dynamic" />
            </div>
            <div class="col-md-4 mb-3">
                <label class="form-label">Banner Image URL</label>
                <asp:TextBox ID="txtBannerImageUrl" runat="server" CssClass="form-control" Placeholder="https://..."></asp:TextBox>
            </div>
            <div class="col-md-4 mb-3">
                <label class="form-label">Banner Subtext</label>
                <asp:TextBox ID="txtBannerSubtext" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="1"></asp:TextBox>
            </div>
        </div>
        <asp:Button ID="btnSaveBanner" runat="server" Text="Save Banner"
            CssClass="btn btn-primary" OnClick="btnSaveBanner_Click"
            ValidationGroup="SaveBanner" />
    </div>

    <div class="card p-4 mb-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5 class="mb-0">Exhibits Management</h5>
            <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addExhibitModal">
                + Add New Exhibit
            </button>
        </div>
        <div class="table-responsive">
            <asp:GridView ID="gvExhibits" runat="server" AutoGenerateColumns="False"
                CssClass="table table-hover align-middle mb-0" GridLines="None" BorderStyle="None"
                OnRowCommand="gvExhibits_RowCommand">
                <Columns>
                    <asp:BoundField DataField="ExhibitionID" HeaderText="ID" />
                    <asp:TemplateField HeaderText="Image">
                        <ItemTemplate><%# RenderThumb(Eval("ImageUrl")) %></ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Title"       HeaderText="Title" />
                    <asp:BoundField DataField="Category"    HeaderText="Category" />
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate><%# RenderStatusBadge(Eval("Status")) %></ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="CreatedDate" HeaderText="Created" DataFormatString="{0:dd/MM/yyyy}" />
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <div style="display:flex;flex-wrap:wrap;gap:4px;max-width:300px;">
                                <asp:Button runat="server" Text="Publish"
                                    CommandName="PublishExhibit"
                                    CommandArgument='<%# Eval("ExhibitionID") %>'
                                    CssClass="btn btn-sm btn-success action-btn"
                                    CausesValidation="false"
                                    Visible='<%# Eval("Status").ToString() == "Draft" %>' />
                                <asp:Button runat="server" Text="Archive"
                                    CommandName="ArchiveExhibit"
                                    CommandArgument='<%# Eval("ExhibitionID") %>'
                                    CssClass="btn btn-sm btn-secondary action-btn"
                                    CausesValidation="false"
                                    Visible='<%# Eval("Status").ToString() == "Published" %>'
                                    OnClientClick="return confirm('Archive this exhibit?');" />
                                <asp:Button runat="server" Text="Restore"
                                    CommandName="RestoreExhibit"
                                    CommandArgument='<%# Eval("ExhibitionID") %>'
                                    CssClass="btn btn-sm btn-warning action-btn"
                                    CausesValidation="false"
                                    Visible='<%# Eval("Status").ToString() == "Archived" %>' />
                                <asp:Button runat="server" Text="★ Unfeature"
                                    CommandName="UnfeatureExhibit"
                                    CommandArgument='<%# Eval("ExhibitionID") %>'
                                    CssClass="btn btn-sm btn-warning action-btn"
                                    CausesValidation="false"
                                    Visible='<%# GetIsFeatured(Eval("IsFeatured")) %>' />
                                <asp:Button runat="server" Text="☆ Feature"
                                    CommandName="FeatureExhibit"
                                    CommandArgument='<%# Eval("ExhibitionID") %>'
                                    CssClass="btn btn-sm btn-outline-secondary action-btn"
                                    CausesValidation="false"
                                    Visible='<%# !GetIsFeatured(Eval("IsFeatured")) %>' />
                                <%# RenderEditButton(
                                    Eval("ExhibitionID"), Eval("Title"), Eval("Category"),
                                    Eval("Period"), Eval("DisplayOrder"), Eval("ImageUrl"),
                                    Eval("VideoUrl"), Eval("AudioUrl"), Eval("Description"),
                                    Eval("Status"), Eval("CreatedDate")) %>
                                <asp:Button runat="server" Text="Delete"
                                    CommandName="DeleteExhibit"
                                    CommandArgument='<%# Eval("ExhibitionID") %>'
                                    CssClass="btn btn-sm btn-danger action-btn"
                                    CausesValidation="false"
                                    OnClientClick="return confirm('Delete this exhibit?');" />
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <%-- Add Modal --%>
    <div class="modal fade" id="addExhibitModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add New Exhibit</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Title *</label>
                            <asp:TextBox ID="txtAddTitle" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddTitle"
                                ValidationGroup="AddExhibit" CssClass="val-msg"
                                ErrorMessage="Title is required." Display="Dynamic" />
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Category</label>
                            <asp:DropDownList ID="ddlAddCategory" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Background &amp; Causes"  Value="Background &amp; Causes"></asp:ListItem>
                                <asp:ListItem Text="The Massacre"             Value="The Massacre"></asp:ListItem>
                                <asp:ListItem Text="Survivor Testimonies"     Value="Survivor Testimonies"></asp:ListItem>
                                <asp:ListItem Text="International Response"   Value="International Response"></asp:ListItem>
                                <asp:ListItem Text="War Crimes &amp; Trials"  Value="War Crimes &amp; Trials"></asp:ListItem>
                                <asp:ListItem Text="Remembrance &amp; Legacy" Value="Remembrance &amp; Legacy"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-12 mb-3">
                            <label class="form-label">Description *</label>
                            <asp:TextBox ID="txtAddDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddDescription"
                                ValidationGroup="AddExhibit" CssClass="val-msg"
                                ErrorMessage="Description is required." Display="Dynamic" />
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Period</label>
                            <asp:TextBox ID="txtAddPeriod" runat="server" CssClass="form-control" Placeholder="e.g. 1937 - 1938"></asp:TextBox>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Display Order</label>
                            <asp:TextBox ID="txtAddDisplayOrder" runat="server" CssClass="form-control" Text="0"></asp:TextBox>
                            <asp:RangeValidator runat="server" ControlToValidate="txtAddDisplayOrder"
                                ValidationGroup="AddExhibit" CssClass="val-msg"
                                MinimumValue="0" MaximumValue="9999" Type="Integer"
                                ErrorMessage="Display order must be a number between 0 and 9999." Display="Dynamic" />
                        </div>
                        <div class="col-md-12 mb-3">
                            <label class="form-label">Image URL</label>
                            <asp:TextBox ID="txtAddImageUrl" runat="server" CssClass="form-control" Placeholder="https://..."></asp:TextBox>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Video URL</label>
                            <asp:TextBox ID="txtAddVideoUrl" runat="server" CssClass="form-control" Placeholder="https://..."></asp:TextBox>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Audio URL</label>
                            <asp:TextBox ID="txtAddAudioUrl" runat="server" CssClass="form-control" Placeholder="https://..."></asp:TextBox>
                        </div>
                    </div>
                    <asp:Label ID="lblAddError" runat="server" Visible="false" CssClass="alert alert-danger d-block"></asp:Label>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnAddExhibit" runat="server" Text="Add Exhibit"
                        CssClass="btn btn-primary" OnClick="btnAddExhibit_Click"
                        ValidationGroup="AddExhibit" />
                </div>
            </div>
        </div>
    </div>

    <%-- Edit Modal --%>
    <div class="modal fade" id="editExhibitModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Edit Exhibit</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hdnEditExhibitId" runat="server" />
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Title *</label>
                            <asp:TextBox ID="txtEditTitle" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditTitle"
                                ValidationGroup="EditExhibit" CssClass="val-msg"
                                ErrorMessage="Title is required." Display="Dynamic" />
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Category</label>
                            <asp:DropDownList ID="ddlEditCategory" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Background &amp; Causes"  Value="Background &amp; Causes"></asp:ListItem>
                                <asp:ListItem Text="The Massacre"             Value="The Massacre"></asp:ListItem>
                                <asp:ListItem Text="Survivor Testimonies"     Value="Survivor Testimonies"></asp:ListItem>
                                <asp:ListItem Text="International Response"   Value="International Response"></asp:ListItem>
                                <asp:ListItem Text="War Crimes &amp; Trials"  Value="War Crimes &amp; Trials"></asp:ListItem>
                                <asp:ListItem Text="Remembrance &amp; Legacy" Value="Remembrance &amp; Legacy"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-12 mb-3">
                            <label class="form-label">Description *</label>
                            <asp:TextBox ID="txtEditDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditDescription"
                                ValidationGroup="EditExhibit" CssClass="val-msg"
                                ErrorMessage="Description is required." Display="Dynamic" />
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Period</label>
                            <asp:TextBox ID="txtEditPeriod" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Display Order</label>
                            <asp:TextBox ID="txtEditDisplayOrder" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RangeValidator runat="server" ControlToValidate="txtEditDisplayOrder"
                                ValidationGroup="EditExhibit" CssClass="val-msg"
                                MinimumValue="0" MaximumValue="9999" Type="Integer"
                                ErrorMessage="Must be a number between 0 and 9999." Display="Dynamic" />
                        </div>
                        <div class="col-md-12 mb-3">
                            <label class="form-label">Image URL</label>
                            <asp:TextBox ID="txtEditImageUrl" runat="server" CssClass="form-control"></asp:TextBox>
                            <div id="editImgPreview" style="display:none;margin-top:10px;padding:10px;background:rgba(255,255,255,0.03);border:1px solid rgba(196,164,74,0.25);border-radius:4px;text-align:center;">
                                <div style="font-size:11px;color:#c4a44a;text-transform:uppercase;letter-spacing:1px;margin-bottom:8px;">Image Preview</div>
                                <img id="editImgTag" src="" alt="" style="max-height:180px;max-width:100%;border-radius:3px;object-fit:cover;" />
                            </div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Video URL</label>
                            <asp:TextBox ID="txtEditVideoUrl" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Audio URL</label>
                            <asp:TextBox ID="txtEditAudioUrl" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                    <asp:Label ID="lblEditError" runat="server" Visible="false" CssClass="alert alert-danger d-block"></asp:Label>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSaveEdit" runat="server" Text="Save Changes"
                        CssClass="btn btn-primary" OnClick="btnSaveEdit_Click"
                        ValidationGroup="EditExhibit" />
                </div>
            </div>
        </div>
    </div>

    <script>
        function openEditModal(id, title, category, period, displayOrder, imageUrl, videoUrl, audioUrl, description) {
            document.getElementById('<%= hdnEditExhibitId.ClientID %>').value   = id;
            document.getElementById('<%= txtEditTitle.ClientID %>').value        = title;
            document.getElementById('<%= txtEditDescription.ClientID %>').value  = description.replace(/\\n/g, '\n');
            document.getElementById('<%= txtEditPeriod.ClientID %>').value       = period;
            document.getElementById('<%= txtEditDisplayOrder.ClientID %>').value = displayOrder;
            document.getElementById('<%= txtEditImageUrl.ClientID %>').value     = imageUrl;
            document.getElementById('<%= txtEditVideoUrl.ClientID %>').value     = videoUrl;
            document.getElementById('<%= txtEditAudioUrl.ClientID %>').value     = audioUrl;
            var preview = document.getElementById('editImgPreview');
            var img     = document.getElementById('editImgTag');
            if (imageUrl && imageUrl.trim() !== '') {
                if (!imageUrl.startsWith('http') && !imageUrl.startsWith('/')) imageUrl = 'https://' + imageUrl;
                img.src = imageUrl;
                preview.style.display = 'block';
                img.onerror = function() { preview.style.display = 'none'; };
            } else { preview.style.display = 'none'; }
            var ddl = document.getElementById('<%= ddlEditCategory.ClientID %>');
            for (var i = 0; i < ddl.options.length; i++) {
                if (ddl.options[i].value === category) { ddl.selectedIndex = i; break; }
            }
            new bootstrap.Modal(document.getElementById('editExhibitModal')).show();
        }
    </script>

    <style>
        .action-btn { min-width:75px; text-align:center; }
        .thumb-img  { width:60px; height:44px; object-fit:cover; border-radius:3px; border:1px solid rgba(196,164,74,0.2); }
        .no-img     { font-size:11px; color:#444; }
        .val-msg    { display:block; font-size:11px; color:#e74c3c; margin-top:4px; font-weight:500; }
    </style>

</asp:Content>