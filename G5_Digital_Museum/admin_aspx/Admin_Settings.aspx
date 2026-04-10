<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_Settings.aspx.cs" Inherits="G5_Digital_Museum.Admin_ASPX.Admin_Settings" MasterPageFile="~/Admin_ASPX/Admin_Master.Master" %>

<asp:Content ContentPlaceHolderID="PageTitle" runat="server">
    <h2 class="mb-0">CONFIGURE SETTINGS</h2>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert d-block mb-3"></asp:Label>

    <div class="row g-4 mb-4">

        <%-- LEFT: General Settings --%>
        <div class="col-md-6">
            <div class="settings-section h-100">
                <div class="settings-section-header">
                    <span class="settings-icon">🌐</span>
                    <div>
                        <div class="settings-section-title">General Settings</div>
                        <div class="settings-section-sub">Site identity and visibility</div>
                    </div>
                </div>
                <div class="settings-body">
                    <div class="settings-field">
                        <label class="settings-label">Site Title *</label>
                        <asp:TextBox ID="txtSiteTitle" runat="server" CssClass="form-control"></asp:TextBox>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtSiteTitle"
                            ValidationGroup="SaveSettings" CssClass="val-msg"
                            ErrorMessage="Site title is required." Display="Dynamic" />
                    </div>
                    <div class="settings-field">
                        <label class="settings-label">Site Description</label>
                        <asp:TextBox ID="txtSiteDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                    </div>
                    <div class="settings-field">
                        <label class="settings-label">Contact Email *</label>
                        <asp:TextBox ID="txtContactEmail" runat="server" CssClass="form-control" TextMode="Email" Placeholder="admin@museum.com"></asp:TextBox>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtContactEmail"
                            ValidationGroup="SaveSettings" CssClass="val-msg"
                            ErrorMessage="Contact email is required." Display="Dynamic" />
                        <asp:RegularExpressionValidator runat="server" ControlToValidate="txtContactEmail"
                            ValidationGroup="SaveSettings" CssClass="val-msg"
                            ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                            ErrorMessage="Enter a valid email address." Display="Dynamic" />
                    </div>
                    <div class="settings-field">
                        <label class="settings-label">Content Visibility</label>
                        <asp:DropDownList ID="ddlVisibility" runat="server" CssClass="form-select">
                            <asp:ListItem Text="🌍 Public (All Users)"        Value="Public"></asp:ListItem>
                            <asp:ListItem Text="🔒 Private (Registered Only)" Value="Private"></asp:ListItem>
                            <asp:ListItem Text="🔧 Maintenance Mode"          Value="Maintenance"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
        </div>

        <%-- RIGHT: Security Settings --%>
        <div class="col-md-6">
            <div class="settings-section h-100">
                <div class="settings-section-header">
                    <span class="settings-icon">🔐</span>
                    <div>
                        <div class="settings-section-title">Security &amp; Access</div>
                        <div class="settings-section-sub">Authentication and registration control</div>
                    </div>
                </div>
                <div class="settings-body">
                    <div class="settings-field">
                        <label class="settings-label">Default New User Role</label>
                        <asp:DropDownList ID="ddlDefaultRole" runat="server" CssClass="form-select">
                            <asp:ListItem Text="Guest"  Value="Guest"></asp:ListItem>
                            <asp:ListItem Text="Member" Value="Member"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="settings-field">
                        <label class="settings-label">Max Login Attempts</label>
                        <asp:DropDownList ID="ddlMaxLoginAttempts" runat="server" CssClass="form-select">
                            <asp:ListItem Text="3 Attempts"  Value="3"></asp:ListItem>
                            <asp:ListItem Text="5 Attempts"  Value="5"></asp:ListItem>
                            <asp:ListItem Text="10 Attempts" Value="10"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="settings-field">
                        <label class="settings-label">Minimum Password Length</label>
                        <asp:DropDownList ID="ddlMinPassword" runat="server" CssClass="form-select">
                            <asp:ListItem Text="6 Characters"  Value="6"></asp:ListItem>
                            <asp:ListItem Text="8 Characters"  Value="8"></asp:ListItem>
                            <asp:ListItem Text="12 Characters" Value="12"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="settings-toggle-row">
                        <div class="toggle-info">
                            <div class="toggle-label">Allow Public Registration</div>
                            <div class="toggle-hint">Anyone can register for a new account</div>
                        </div>
                        <label class="toggle-switch">
                            <input type="checkbox" id="chkAllowRegistration" runat="server" />
                            <span class="toggle-slider"></span>
                        </label>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="text-end mb-4">
        <asp:Button ID="btnSaveAll" runat="server" Text="💾  Save All Settings"
            CssClass="btn btn-primary px-5 py-2" OnClick="btnSaveAll_Click"
            ValidationGroup="SaveSettings" />
    </div>

    <%-- Summary --%>
    <div class="settings-summary">
        <div class="settings-summary-title">Current Configuration</div>
        <div class="summary-grid">
            <div class="summary-item">
                <div class="summary-key">Site Title</div>
                <div class="summary-val"><asp:Label ID="lblCurrentSiteTitle" runat="server"></asp:Label></div>
            </div>
            <div class="summary-item">
                <div class="summary-key">Contact Email</div>
                <div class="summary-val"><asp:Label ID="lblCurrentEmail" runat="server"></asp:Label></div>
            </div>
            <div class="summary-item">
                <div class="summary-key">Content Visibility</div>
                <div class="summary-val"><asp:Label ID="lblCurrentVisibility" runat="server"></asp:Label></div>
            </div>
            <div class="summary-item">
                <div class="summary-key">Default Role</div>
                <div class="summary-val"><asp:Label ID="lblCurrentRole" runat="server"></asp:Label></div>
            </div>
            <div class="summary-item">
                <div class="summary-key">Max Login Attempts</div>
                <div class="summary-val"><asp:Label ID="lblCurrentMaxLogin" runat="server"></asp:Label></div>
            </div>
            <div class="summary-item">
                <div class="summary-key">Min Password Length</div>
                <div class="summary-val"><asp:Label ID="lblCurrentMinPassword" runat="server"></asp:Label></div>
            </div>
            <div class="summary-item">
                <div class="summary-key">Public Registration</div>
                <div class="summary-val"><asp:Label ID="lblCurrentRegistration" runat="server"></asp:Label></div>
            </div>
        </div>
    </div>

    <style>
        .settings-section        { background:#1a1a1a; border:1px solid rgba(196,164,74,0.12); border-radius:6px; overflow:hidden; }
        .settings-section-header { display:flex; align-items:center; gap:14px; padding:18px 22px; background:rgba(196,164,74,0.05); border-bottom:1px solid rgba(196,164,74,0.1); }
        .settings-icon           { font-size:24px; }
        .settings-section-title  { font-size:14px; font-weight:700; color:#c4a44a; text-transform:uppercase; letter-spacing:1px; }
        .settings-section-sub    { font-size:12px; color:#555; margin-top:2px; }
        .settings-body           { padding:20px 22px; }
        .settings-field          { margin-bottom:18px; }
        .settings-label          { font-size:12px; color:#777; text-transform:uppercase; letter-spacing:1px; margin-bottom:6px; display:block; }

        .settings-toggle-row  { display:flex; justify-content:space-between; align-items:center; padding:12px 0; border-top:1px solid rgba(255,255,255,0.04); }
        .toggle-info          { flex:1; }
        .toggle-label         { font-size:14px; color:#ccc; font-weight:500; }
        .toggle-hint          { font-size:11px; color:#444; margin-top:2px; }
        .toggle-switch        { position:relative; display:inline-block; width:44px; height:24px; flex-shrink:0; cursor:pointer; }
        .toggle-switch input  { opacity:0; width:0; height:0; }
        .toggle-slider        { position:absolute; top:0; left:0; right:0; bottom:0; background:#2a2a2a; border-radius:24px; transition:0.3s; border:1px solid rgba(255,255,255,0.08); }
        .toggle-slider:before { content:''; position:absolute; height:16px; width:16px; left:3px; bottom:3px; background:#555; border-radius:50%; transition:0.3s; }
        .toggle-switch input:checked + .toggle-slider               { background:rgba(196,164,74,0.25); border-color:#c4a44a; }
        .toggle-switch input:checked + .toggle-slider:before        { transform:translateX(20px); background:#c4a44a; }

        .settings-summary       { background:#1a1a1a; border:1px solid rgba(196,164,74,0.12); border-radius:6px; padding:24px; margin-bottom:24px; }
        .settings-summary-title { font-size:11px; font-weight:700; color:#555; text-transform:uppercase; letter-spacing:2px; margin-bottom:18px; }
        .summary-grid           { display:grid; grid-template-columns:repeat(auto-fill, minmax(220px,1fr)); gap:12px; }
        .summary-item           { background:rgba(255,255,255,0.02); border:1px solid rgba(255,255,255,0.04); border-radius:4px; padding:12px 16px; }
        .summary-key            { font-size:11px; color:#555; text-transform:uppercase; letter-spacing:1px; margin-bottom:4px; }
        .summary-val            { font-size:14px; color:#e8e0d0; font-weight:500; }
        .val-msg                { display:block; font-size:11px; color:#e74c3c; margin-top:4px; font-weight:500; }
    </style>

</asp:Content>