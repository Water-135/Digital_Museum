<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_Profile.aspx.cs"
    Inherits="G5_Digital_Museum.Admin_ASPX.Admin_Profile" MasterPageFile="~/Admin_ASPX/Admin_Master.Master" %>

<asp:Content ContentPlaceHolderID="PageTitle" runat="server">
    <h2 class="mb-0">MY PROFILE</h2>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert d-block mb-4"></asp:Label>

    <div class="row g-4">

        <%-- LEFT: Profile Card --%>
        <div class="col-md-4">
            <div class="profile-card text-center">
                <div class="profile-avatar">
                    <asp:Label ID="lblInitial" runat="server" Text="A"></asp:Label>
                </div>
                <div class="profile-name">
                    <asp:Label ID="lblDisplayName" runat="server"></asp:Label>
                </div>
                <div class="profile-role-badge">
                    <asp:Label ID="lblRole" runat="server"></asp:Label>
                </div>
                <div class="profile-meta">
                    <div class="profile-meta-row">
                        <span class="profile-meta-key">User ID</span>
                        <span class="profile-meta-val">#<asp:Label ID="lblUserID" runat="server"></asp:Label></span>
                    </div>
                    <div class="profile-meta-row">
                        <span class="profile-meta-key">Member Since</span>
                        <span class="profile-meta-val"><asp:Label ID="lblDateJoined" runat="server"></asp:Label></span>
                    </div>
                    <div class="profile-meta-row">
                        <span class="profile-meta-key">Access Level</span>
                        <span class="profile-meta-val" style="color:#e74c3c;">Full Admin</span>
                    </div>
                </div>
            </div>
        </div>

        <%-- RIGHT: Edit Forms --%>
        <div class="col-md-8 d-flex flex-column gap-4">

            <div class="card p-4">
                <h5 class="form-section-title">✏️ Edit Profile Information</h5>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Full Name</label>
                        <asp:TextBox ID="txtEditFullName" runat="server" CssClass="form-control"></asp:TextBox>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditFullName"
                            ValidationGroup="SaveProfile" CssClass="val-msg"
                            ErrorMessage="Full name is required." Display="Dynamic" />
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Email Address</label>
                        <asp:TextBox ID="txtEditEmail" runat="server" CssClass="form-control" TextMode="Email"></asp:TextBox>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditEmail"
                            ValidationGroup="SaveProfile" CssClass="val-msg"
                            ErrorMessage="Email is required." Display="Dynamic" />
                        <asp:RegularExpressionValidator runat="server" ControlToValidate="txtEditEmail"
                            ValidationGroup="SaveProfile" CssClass="val-msg"
                            ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                            ErrorMessage="Enter a valid email." Display="Dynamic" />
                    </div>
                </div>
                <asp:Button ID="btnSaveProfile" runat="server" Text="Save Changes"
                    CssClass="btn btn-primary" OnClick="btnSaveProfile_Click"
                    ValidationGroup="SaveProfile" />
            </div>

            <div class="card p-4">
                <h5 class="form-section-title">🔐 Change Password</h5>
                <div class="row">
                    <div class="col-md-8 mb-3">
                        <label class="form-label">New Password</label>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control"
                            TextMode="Password" Placeholder="Min. 6 characters"></asp:TextBox>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNewPassword"
                            ValidationGroup="ChangePass" CssClass="val-msg"
                            ErrorMessage="Please enter a new password." Display="Dynamic" />
                        <asp:RegularExpressionValidator runat="server" ControlToValidate="txtNewPassword"
                            ValidationGroup="ChangePass" CssClass="val-msg"
                            ValidationExpression=".{6,}"
                            ErrorMessage="Password must be at least 6 characters." Display="Dynamic" />
                    </div>
                    <div class="col-md-4 mb-3 d-flex align-items-end">
                        <asp:Button ID="btnChangePassword" runat="server" Text="Change Password"
                            CssClass="btn btn-danger w-100" OnClick="btnChangePassword_Click"
                            ValidationGroup="ChangePass" />
                    </div>
                </div>
                <div style="font-size:12px;color:#555;margin-top:4px;">
                    ⚠️ You will need to log in again after changing your password.
                </div>
            </div>

        </div>
    </div>

    <style>
        .profile-card        { background:#1a1a1a; border:1px solid rgba(196,164,74,0.15); border-radius:6px; padding:32px 24px; }
        .profile-avatar      { width:80px; height:80px; background:rgba(196,164,74,0.15); border:2px solid #c4a44a; border-radius:50%; display:flex; align-items:center; justify-content:center; margin:0 auto 16px; font-family:'Playfair Display',serif; font-size:32px; font-weight:700; color:#c4a44a; }
        .profile-name        { font-size:18px; font-weight:700; color:#e8e0d0; margin-bottom:6px; }
        .profile-role-badge  { display:inline-block; background:rgba(196,164,74,0.12); color:#c4a44a; font-size:11px; font-weight:700; letter-spacing:1px; text-transform:uppercase; padding:4px 14px; border-radius:12px; margin-bottom:20px; }
        .profile-meta        { text-align:left; border-top:1px solid rgba(255,255,255,0.05); padding-top:16px; }
        .profile-meta-row    { display:flex; justify-content:space-between; padding:8px 0; border-bottom:1px solid rgba(255,255,255,0.04); }
        .profile-meta-key    { font-size:12px; color:#555; text-transform:uppercase; letter-spacing:1px; }
        .profile-meta-val    { font-size:13px; color:#c4a44a; font-weight:600; }
        .form-section-title  { font-size:14px; color:#c4a44a; font-weight:600; margin-bottom:16px; }
        .val-msg             { display:block; font-size:11px; color:#e74c3c; margin-top:4px; font-weight:500; }
    </style>

</asp:Content>