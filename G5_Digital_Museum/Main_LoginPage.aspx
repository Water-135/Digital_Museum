<%@ Page Title="Login" Language="C#" MasterPageFile="~/Login_MasterPage.Master"
    AutoEventWireup="true" CodeBehind="Main_LoginPage.aspx.cs" Inherits="G5_Digital_Museum.Main_LoginPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="login-page">
        <div class="login-card">
            <h1>Login</h1>
            <p class="login-subtitle">Sign in to access your Digital Museum account.</p>

            <asp:Label ID="lblMsg" runat="server" CssClass="login-msg"></asp:Label>

            <div class="form-group">
                <label for="<%= txtEmail.ClientID %>">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="login-input" TextMode="Email"></asp:TextBox>
            </div>

            <div class="form-group">
                <label for="<%= txtPassword.ClientID %>">Password</label>
                <div class="password-wrap">
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="login-input" TextMode="Password"></asp:TextBox>

                    <button type="button" class="toggle-password" onclick="togglePassword()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round"
                                d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                            <circle cx="12" cy="12" r="3"></circle>
                        </svg>
                    </button>
                </div>
            </div>

            <asp:Button ID="btnLogin" runat="server" Text="LOGIN" CssClass="login-btn" OnClick="btnLogin_Click" />

            <div class="login-links">
                <div class="extra-links">
                    <a href="ForgotPassword.aspx">Forgot Password?</a>
                </div>

                <div class="extra-links small">
                    No account yet?
                    <a href="Member_Registration.aspx">Create one</a>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function togglePassword() {
            var txt = document.getElementById('<%= txtPassword.ClientID %>');
            if (txt.type === "password") {
                txt.type = "text";
            } else {
                txt.type = "password";
            }
        }
    </script>

</asp:Content>