<%@ Page Title="Forgot Password" Language="C#" MasterPageFile="~/Login_MasterPage.Master"
    AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="G5_Digital_Museum.ForgotPassword" %>

<asp:Content ID="Head1" ContentPlaceHolderID="HeadContent" runat="server"></asp:Content>

<asp:Content ID="Main1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="login-page">
        <div class="login-card">
            <h1>Forgot Password</h1>
            <p class="login-subtitle">Enter your email to receive an OTP for login.</p>

            <asp:Label ID="lblMsg" runat="server" CssClass="login-msg"></asp:Label>

            <div class="form-group">
                <label for="<%= txtEmail.ClientID %>">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="login-input" TextMode="Email"></asp:TextBox>
            </div>

            <asp:Button ID="btnSendOtp" runat="server" Text="SEND OTP"
                CssClass="login-btn" OnClick="btnSendOtp_Click" />

            <hr class="login-divider" />

            <div class="form-group">
                <label for="<%= txtOtp.ClientID %>">OTP</label>
                <asp:TextBox ID="txtOtp" runat="server" CssClass="login-input"></asp:TextBox>
            </div>

            <asp:Button ID="btnVerifyOtp" runat="server" Text="VERIFY OTP & LOGIN"
                CssClass="login-btn" OnClick="btnVerifyOtp_Click" />

            <div class="login-links">
                <div class="back-link">
                    <a href="Main_LoginPage.aspx">Back to Login</a>
                </div>
            </div>
        </div>
    </div>
</asp:Content>