<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_ManageUsers.aspx.cs" Inherits="G5_Digital_Museum.Admin_ASPX.Admin_ManageUsers" MasterPageFile="~/Admin_ASPX/Admin_Master.Master" %>

<asp:Content ContentPlaceHolderID="PageTitle" runat="server">
    <h2 class="mb-0">MANAGE USERS</h2>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert d-block mb-3"></asp:Label>
    <asp:HiddenField ID="hdnUserId" runat="server" />

    <div class="card p-3 mb-3">
        <div class="row g-2 align-items-end">
            <div class="col-md-4">
                <label class="form-label">Search Name</label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" Placeholder="Search name..."></asp:TextBox>
            </div>
            <div class="col-md-3">
                <label class="form-label">Filter by Role</label>
                <asp:DropDownList ID="ddlFilterRole" runat="server" CssClass="form-select">
                    <asp:ListItem Text="All Roles"  Value=""></asp:ListItem>
                    <asp:ListItem Text="Admin"      Value="Admin"></asp:ListItem>
                    <asp:ListItem Text="Instructor" Value="Instructor"></asp:ListItem>
                    <asp:ListItem Text="Member"     Value="Member"></asp:ListItem>
                    <asp:ListItem Text="Guest"      Value="Guest"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-md-2">
                <label class="form-label">Date From</label>
                <asp:TextBox ID="txtDateFrom" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
            </div>
            <div class="col-md-2">
                <label class="form-label">Date To</label>
                <asp:TextBox ID="txtDateTo" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
            </div>
            <div class="col-md-1">
                <asp:Button ID="btnFilter" runat="server" Text="Search"
                    CssClass="btn btn-primary w-100" OnClick="btnFilter_Click"
                    CausesValidation="false" />
            </div>
        </div>
        <div class="mt-2">
            <asp:Button ID="btnClear" runat="server" Text="Clear"
                CssClass="btn btn-secondary btn-sm" OnClick="btnClear_Click"
                CausesValidation="false" />
            <asp:Label ID="lblResultCount" runat="server" CssClass="ms-3 text-muted small"></asp:Label>
        </div>
    </div>

    <div class="d-flex justify-content-end mb-3">
        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addUserModal">
            + Add New User
        </button>
    </div>

    <div class="card p-3 mb-4">
        <div class="table-responsive">
            <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False"
                CssClass="table table-hover align-middle mb-0" GridLines="None" BorderStyle="None"
                OnRowCommand="gvUsers_RowCommand">
                <Columns>
                    <asp:BoundField DataField="UserID"    HeaderText="ID" />
                    <asp:BoundField DataField="FullName"  HeaderText="Full Name" />
                    <asp:BoundField DataField="Email"     HeaderText="Email" />
                    <asp:BoundField DataField="Role"      HeaderText="Role" />
                    <asp:BoundField DataField="CreatedAt" HeaderText="Joined" DataFormatString="{0:dd/MM/yyyy}" />
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <div style="display:flex;gap:6px;">
                                <asp:Button runat="server" Text="Edit"
                                    CommandName="EditUser"
                                    CommandArgument='<%# Eval("UserID") %>'
                                    CssClass="btn btn-sm btn-primary action-btn"
                                    CausesValidation="false" />
                                <asp:Button runat="server" Text="Delete"
                                    CommandName="DeleteUser"
                                    CommandArgument='<%# Eval("UserID") %>'
                                    CssClass="btn btn-sm btn-danger action-btn"
                                    CausesValidation="false"
                                    OnClientClick="return confirm('Delete this user?');" />
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <%-- Edit Panel --%>
    <asp:Panel ID="pnlEditUser" runat="server" Visible="false">
        <div id="editPanel" class="card p-4 mb-4" style="border-left:3px solid #c4a44a !important;">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 style="color:#c4a44a;margin:0;">Edit User</h5>
                <asp:Button ID="btnCancelEdit" runat="server" Text="✕ Close"
                    CssClass="btn btn-secondary btn-sm" OnClick="btnCancelEdit_Click"
                    CausesValidation="false" />
            </div>
            <asp:Label ID="lblEditMessage" runat="server" Visible="false" CssClass="alert d-block mb-3"></asp:Label>
            <div class="row">
                <div class="col-md-6 mb-4">
                    <div class="card p-4 h-100">
                        <h5 class="mb-3" style="font-size:14px;color:#999;text-transform:uppercase;letter-spacing:1px;">User Information</h5>
                        <div class="mb-3">
                            <label class="form-label">Full Name</label>
                            <asp:TextBox ID="txtEditFullName" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditFullName"
                                ValidationGroup="EditProfile" CssClass="val-msg"
                                ErrorMessage="Full name is required." Display="Dynamic" />
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email</label>
                            <asp:TextBox ID="txtEditEmail" runat="server" CssClass="form-control" TextMode="Email"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditEmail"
                                ValidationGroup="EditProfile" CssClass="val-msg"
                                ErrorMessage="Email is required." Display="Dynamic" />
                            <asp:RegularExpressionValidator runat="server" ControlToValidate="txtEditEmail"
                                ValidationGroup="EditProfile" CssClass="val-msg"
                                ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                                ErrorMessage="Enter a valid email address." Display="Dynamic" />
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Role</label>
                            <asp:DropDownList ID="ddlEditRole" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Guest"      Value="Guest"></asp:ListItem>
                                <asp:ListItem Text="Member"     Value="Member"></asp:ListItem>
                                <asp:ListItem Text="Instructor" Value="Instructor"></asp:ListItem>
                                <asp:ListItem Text="Admin"      Value="Admin"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="mb-3">
                            <label class="form-label" style="font-size:11px;color:#555;text-transform:uppercase;">Date Joined</label>
                            <div class="form-control" style="background:transparent;border-color:rgba(255,255,255,0.1);color:#999;">
                                <asp:Label ID="lblDateJoined" runat="server"></asp:Label>
                            </div>
                        </div>
                        <asp:Button ID="btnSaveProfile" runat="server" Text="Save Changes"
                            CssClass="btn btn-primary" OnClick="btnSaveProfile_Click"
                            ValidationGroup="EditProfile" />
                    </div>
                </div>
                <div class="col-md-6 mb-4">
                    <div class="card p-4 h-100">
                        <h5 class="mb-3" style="font-size:14px;color:#999;text-transform:uppercase;letter-spacing:1px;">Change Password</h5>
                        <div class="mb-3">
                            <label class="form-label">Current Password</label>
                            <div class="form-control" style="background:transparent;border-color:rgba(255,255,255,0.1);color:#999;word-break:break-all;">
                                <asp:Label ID="lblCurrentPassword" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">New Password</label>
                            <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control"
                                TextMode="Password" Placeholder="Min. 6 characters"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNewPassword"
                                ValidationGroup="ChangePass" CssClass="val-msg"
                                ErrorMessage="New password is required." Display="Dynamic" />
                            <asp:RegularExpressionValidator runat="server" ControlToValidate="txtNewPassword"
                                ValidationGroup="ChangePass" CssClass="val-msg"
                                ValidationExpression=".{6,}"
                                ErrorMessage="Password must be at least 6 characters." Display="Dynamic" />
                        </div>
                        <asp:Button ID="btnChangePassword" runat="server" Text="Change Password"
                            CssClass="btn btn-danger" OnClick="btnChangePassword_Click"
                            ValidationGroup="ChangePass" />
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <%-- Add User Modal --%>
    <div class="modal fade" id="addUserModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add New User</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Full Name</label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" Placeholder="Enter full name"></asp:TextBox>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtFullName"
                            ValidationGroup="AddUser" CssClass="val-msg"
                            ErrorMessage="Full name is required." Display="Dynamic" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" Placeholder="Enter email"></asp:TextBox>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail"
                            ValidationGroup="AddUser" CssClass="val-msg"
                            ErrorMessage="Email is required." Display="Dynamic" />
                        <asp:RegularExpressionValidator runat="server" ControlToValidate="txtEmail"
                            ValidationGroup="AddUser" CssClass="val-msg"
                            ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                            ErrorMessage="Enter a valid email address." Display="Dynamic" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Password</label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" Placeholder="Min. 6 characters"></asp:TextBox>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPassword"
                            ValidationGroup="AddUser" CssClass="val-msg"
                            ErrorMessage="Password is required." Display="Dynamic" />
                        <asp:RegularExpressionValidator runat="server" ControlToValidate="txtPassword"
                            ValidationGroup="AddUser" CssClass="val-msg"
                            ValidationExpression=".{6,}"
                            ErrorMessage="Password must be at least 6 characters." Display="Dynamic" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Role</label>
                        <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-select">
                            <asp:ListItem Text="Guest"      Value="Guest"></asp:ListItem>
                            <asp:ListItem Text="Member"     Value="Member"></asp:ListItem>
                            <asp:ListItem Text="Instructor" Value="Instructor"></asp:ListItem>
                            <asp:ListItem Text="Admin"      Value="Admin"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <asp:Label ID="lblModalError" runat="server" Visible="false" CssClass="alert alert-danger d-block"></asp:Label>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnAddUser" runat="server" Text="Add User"
                        CssClass="btn btn-primary" OnClick="btnAddUser_Click"
                        ValidationGroup="AddUser" />
                </div>
            </div>
        </div>
    </div>

    <style>
        .action-btn { width:75px; text-align:center; }
        .val-msg    { display:block; font-size:11px; color:#e74c3c; margin-top:4px; font-weight:500; }
    </style>

</asp:Content>