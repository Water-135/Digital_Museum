<%@ Page Title="Manage Profile" Language="C#" MasterPageFile="~/Member_MasterPage.Master"
    AutoEventWireup="true" CodeBehind="Member_ManageProfile.aspx.cs" Inherits="G5_Digital_Museum.Member_ManageProfile" %>

<asp:Content ID="Head1" ContentPlaceHolderID="HeadContent" runat="server"></asp:Content>

<asp:Content ID="Main1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="content-page">
        <section class="page-hero">
            <div class="container">
                <h1>Manage Profile</h1>
                <p>Update your details securely.</p>
            </div>
        </section>

        <div class="content-block">
            
            <asp:Label ID="lblMsg" runat="server" CssClass="form-msg" />

            <div class="form-group">
                <label>Full Name</label>
                <asp:TextBox ID="txtName" runat="server"></asp:TextBox>
            </div>

            <div class="form-group">
                <label>Email</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email"></asp:TextBox>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>New Password</label>

                    <div class="input-with-icon">
                        <asp:TextBox ID="txtNewPassword" runat="server"
                            TextMode="Password" ClientIDMode="Static"></asp:TextBox>

                        <button type="button" class="pw-toggle"
                            onclick="togglePw('txtNewPassword', this)" aria-label="Show password">
                            <svg class="icon-eye" viewBox="0 0 24 24" aria-hidden="true">
                                <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z"
                                    fill="none" stroke="currentColor" stroke-width="2" />
                                <path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z"
                                    fill="none" stroke="currentColor" stroke-width="2" />
                            </svg>
                        </button>
                    </div>
                </div>

                <div class="form-group">
                    <label>Confirm Password</label>

                    <div class="input-with-icon">
                        <asp:TextBox ID="txtConfirmPassword" runat="server"
                            TextMode="Password" ClientIDMode="Static"></asp:TextBox>

                        <button type="button" class="pw-toggle"
                            onclick="togglePw('txtConfirmPassword', this)" aria-label="Show password">
                            <svg class="icon-eye" viewBox="0 0 24 24" aria-hidden="true">
                                <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z"
                                    fill="none" stroke="currentColor" stroke-width="2" />
                                <path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z"
                                    fill="none" stroke="currentColor" stroke-width="2" />
                            </svg>
                        </button>
                    </div>
                </div>
            </div>

            <asp:Button ID="btnUpdate" runat="server"
                Text="Update Profile"
                CssClass="btn btn-primary btn-sm"
                OnClick="btnUpdate_Click" />

        </div>
    </div>

    <script type="text/javascript">
        function togglePw(inputId, btn) {
            var tb = document.getElementById(inputId);
            if (!tb) return;

            var isPw = (tb.getAttribute("type") === "password");
            tb.setAttribute("type", isPw ? "text" : "password");
            btn.setAttribute("aria-label", isPw ? "Hide password" : "Show password");
        }
    </script>
</asp:Content>