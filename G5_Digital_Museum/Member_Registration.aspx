<%@ Page Title="Registration" Language="C#" MasterPageFile="~/Member_MasterPage.Master"
    AutoEventWireup="true" CodeBehind="Member_Registration.aspx.cs"
    Inherits="G5_Digital_Museum.Member_Registration" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="form-page">
        <div class="form-container wide">
            <div class="form-header">
                <h1>Create Member Account</h1>
                <p>Register to save favourites and leave comments.</p>
            </div>

            <asp:Label ID="lblMsg" runat="server" />

            <div class="form-group">
                <label>Full Name</label>
                <asp:TextBox ID="txtFullName" runat="server" />
            </div>

            <div class="form-group">
                <label>Email</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" />
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Password</label>
                    <div class="input-with-icon">
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" ClientIDMode="Static" />
                        <button type="button" class="pw-toggle" onclick="togglePw('txtPassword', this)" aria-label="Show password">
                            <svg class="icon-eye" viewBox="0 0 24 24" aria-hidden="true">
                                <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z" fill="none" stroke="currentColor" stroke-width="2"/>
                                <path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" fill="none" stroke="currentColor" stroke-width="2"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <div class="form-group">
                    <label>Confirm Password</label>
                    <div class="input-with-icon">
                        <asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" ClientIDMode="Static" />
                        <button type="button" class="pw-toggle" onclick="togglePw('txtConfirm', this)" aria-label="Show password">
                            <svg class="icon-eye" viewBox="0 0 24 24" aria-hidden="true">
                                <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z" fill="none" stroke="currentColor" stroke-width="2"/>
                                <path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" fill="none" stroke="currentColor" stroke-width="2"/>
                            </svg>
                        </button>
                    </div>
                </div>
            </div>

            <asp:Button ID="btnRegister" runat="server" Text="Register"
                CssClass="btn btn-primary btn-block" OnClick="btnRegister_Click" />

            <div class="form-footer">
                Already have an account?
                <a href="Main_LoginPage.aspx" class="go-login-link">Go to Login</a>
            </div>
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