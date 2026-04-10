<%@ Page Title="Admin Registration" Language="C#" MasterPageFile="~/Login_MasterPage.Master"
    AutoEventWireup="true" CodeBehind="Admin_Registration.aspx.cs" Inherits="G5_Digital_Museum.Admin_Registration" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
.login-page {
    min-height: 100vh;
    background: #050505;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 60px 20px;
}

.login-card {
    width: 100%;
    max-width: 760px;
    padding: 30px 20px;
}

.login-card h1 {
    text-align: center;
    color: #fff;
    font-size: 56px;
    font-family: 'Playfair Display', serif;
}

.login-subtitle {
    text-align: center;
    color: #b9b1a4;
    margin-bottom: 60px;
}

.form-group {
    margin-bottom: 28px;
}

.form-group label {
    color: #d7d1c7;
    letter-spacing: 4px;
    text-transform: uppercase;
}

.login-input {
    width: 100%;
    height: 60px;
    background: #141416;
    border: 1px solid #242428;
    color: #fff;
    padding: 0 15px;
}

.login-btn {
    width: 100%;
    height: 60px;
    background: #c9a84b;
    border: none;
    font-weight: bold;
    letter-spacing: 3px;
    margin-top: 10px;
}

.login-links {
    text-align: center;
    margin-top: 30px;
}

.login-links a {
    color: #c9a84b;
}
</style>

<div class="login-page">
    <div class="login-card">

        <h1>Create Admin Account</h1>
        <p class="login-subtitle">Register a new administrator account.</p>

        <asp:Label ID="lblMsg" runat="server" />

        <div class="form-group">
            <label>Full Name</label>
            <asp:TextBox ID="txtName" runat="server" CssClass="login-input"></asp:TextBox>
        </div>

        <div class="form-group">
            <label>Email</label>
            <asp:TextBox ID="txtEmail" runat="server" CssClass="login-input"></asp:TextBox>
        </div>

        <div class="form-group">
            <label>Password</label>
            <asp:TextBox ID="txtPassword" runat="server" CssClass="login-input" TextMode="Password"></asp:TextBox>
        </div>

        <div class="form-group">
            <label>Confirm Password</label>
            <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="login-input" TextMode="Password"></asp:TextBox>
        </div>

        <asp:Button ID="btnRegister" runat="server" Text="CREATE ADMIN"
            CssClass="login-btn" OnClick="btnRegister_Click" />

        <div class="login-links">
            <a href="Admin_Login.aspx">Back to Login</a>
        </div>

    </div>
</div>

</asp:Content>