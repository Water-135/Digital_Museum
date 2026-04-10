<%@ Page Title="Instructor_Profile" Language="C#" MasterPageFile="~/Master/Instructor_Master.Master" AutoEventWireup="true" CodeBehind="Instructor_Profile.aspx.cs" Inherits="G5_Digital_Museum.Instructor_Profile" %>

<asp:Content ID="MainP" ContentPlaceHolderID="MainContent" runat="server">

    <div class="pagehead">
        <div class="pagehead-left">
            <div class="pagehead-kicker">Account Settings</div>
            <h1>My Profile</h1>
            <p>Update your instructor account details and manage your password.</p>
        </div>
    </div>

    <div class="profile-shell">

        <!-- AVATAR CARD -->
        <aside class="panel profile-avatar-card">
            <div class="avatar-circle">
                <asp:Label ID="lblInitial" runat="server" Text="I" />
            </div>
            <div class="avatar-name">
                <asp:Label ID="lblDisplayName" runat="server" Text="Instructor" />
            </div>
            <div class="avatar-role">Instructor &mdash; Digital Museum</div>
            <div class="avatar-divider"></div>
            <ul class="avatar-meta">
                <li>
                    <span class="avatar-meta__key">Email</span>
                    <asp:Label ID="lblDisplayEmail" runat="server" CssClass="avatar-meta__val" Text="—" />
                </li>
                <li>
                    <span class="avatar-meta__key">Role</span>
                    <span class="avatar-meta__val chip chip--live" style="font-size:11px;">Instructor</span>
                </li>
                <li>
                    <span class="avatar-meta__key">Member since</span>
                    <asp:Label ID="lblMemberSince" runat="server" CssClass="avatar-meta__val" Text="—" />
                </li>
            </ul>
            <div class="avatar-divider"></div>
            <div style="font-size:11px;color:#555;letter-spacing:1px;text-align:center;">
                To sign out, click Sign Out in the sidebar.
            </div>
        </aside>

        <!-- FORM CARD -->
        <section class="panel profile-form-card">
            <div class="panel-header">
                <div>
                    <h2 class="panel-title">Account Details</h2>
                    <p class="panel-subtitle">Changes are applied immediately on submission.</p>
                </div>
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Full Name <span class="req">*</span></label>
                    <asp:TextBox ID="txtName" runat="server" CssClass="form-control"
                        placeholder="e.g. Dr. Ahmad Razif" />
                </div>
                <div class="form-group">
                    <label class="form-label">Email Address <span class="req">*</span></label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control"
                        placeholder="e.g. instructor@museum.edu.my" />
                </div>
            </div>

            <div class="panel-section-divider"><span>Change Password</span></div>
            <p style="font-size:12px;color:#666;margin:0 0 16px;">Leave all three fields blank to keep your current password.</p>

            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Current Password</label>
                    <asp:TextBox ID="txtCurrentPassword" runat="server"
                        TextMode="Password" CssClass="form-control" placeholder="••••••••" />
                </div>
                <div class="form-group">
                    <label class="form-label">New Password</label>
                    <asp:TextBox ID="txtNewPassword" runat="server"
                        TextMode="Password" CssClass="form-control" placeholder="••••••••" />
                </div>
                <div class="form-group">
                    <label class="form-label">Confirm New Password</label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server"
                        TextMode="Password" CssClass="form-control" placeholder="••••••••" />
                </div>
            </div>

            <asp:Label ID="lblMsg" runat="server" CssClass="form-feedback" />

            <div class="form-actions">
                <asp:Button ID="btnSaveProfile" runat="server" Text="Save Changes"
                    CssClass="btn" OnClick="btnSaveProfile_Click" />
            </div>
        </section>

    </div>
</asp:Content>
