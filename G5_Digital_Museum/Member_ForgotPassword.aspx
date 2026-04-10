<%@ Page Title="Forgot Password" Language="C#" MasterPageFile="~/Member_MasterPage.Master"
    AutoEventWireup="true" CodeBehind="Member_ForgotPassword.aspx.cs" Inherits="G5_Digital_Museum.Member_ForgotPassword" %>

<asp:Content ID="Head1" ContentPlaceHolderID="HeadContent" runat="server"></asp:Content>

<asp:Content ID="Main1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="form-page">
        <div class="form-container wide">
            <div class="form-header">
                <h1>Forgot Password</h1>
                <p>Enter your email to receive an OTP for login.</p>
            </div>

            <asp:Label ID="lblMsg" runat="server" />

            <div class="form-group">
                <label>Email</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email"></asp:TextBox>
            </div>

            <asp:Button ID="btnSendOtp" runat="server" Text="Send OTP"
                CssClass="btn btn-primary btn-block" OnClick="btnSendOtp_Click" />

            <hr style="margin:24px 0; border-color:#333;" />

            <div class="form-group">
                <label>OTP</label>
                <asp:TextBox ID="txtOtp" runat="server"></asp:TextBox>
            </div>

            <asp:Button ID="btnVerifyOtp" runat="server" Text="Verify OTP & Login"
                CssClass="btn btn-primary btn-block" OnClick="btnVerifyOtp_Click" />

            <div class="form-footer">
                <a href="Member_Login.aspx" class="go-login-link">Back to Login</a>
            </div>
        </div>
    </div>
</asp:Content>