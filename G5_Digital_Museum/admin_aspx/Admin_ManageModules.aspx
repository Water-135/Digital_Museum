<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_ManageModules.aspx.cs" Inherits="G5_Digital_Museum.Admin_ASPX.Admin_ManageModules" MasterPageFile="~/Admin_ASPX/Admin_Master.Master" %>

<asp:Content ContentPlaceHolderID="PageTitle" runat="server">
    <h2 class="mb-0">MANAGE MODULES &amp; QUIZZES</h2>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert d-block mb-3"></asp:Label>
    <asp:HiddenField ID="hdnModuleId" runat="server" />

    <div class="d-flex justify-content-between align-items-center mb-3">
        <asp:Label ID="lblCount" runat="server" CssClass="text-muted small"></asp:Label>
        <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addModuleModal">
            + Add New Module
        </button>
    </div>

    <div class="card p-3 mb-4">
        <asp:GridView ID="gvModules" runat="server" AutoGenerateColumns="False"
            CssClass="table table-hover align-middle mb-0" GridLines="None" BorderStyle="None"
            OnRowCommand="gvModules_RowCommand">
            <Columns>
                <asp:BoundField DataField="ModuleID"  HeaderText="ID" />
                <asp:BoundField DataField="Title"     HeaderText="Title" />
                <asp:BoundField DataField="SortOrder" HeaderText="Order" />
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate><%# RenderStatusBadge(Eval("Status")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="CreatedAt" HeaderText="Created" DataFormatString="{0:dd/MM/yyyy}" />
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <div style="display:flex;gap:6px;">
                            <asp:Button runat="server" Text="Edit + Quizzes"
                                CommandName="EditModule"
                                CommandArgument='<%# Eval("ModuleID") %>'
                                CssClass="btn btn-sm btn-primary"
                                CausesValidation="false" />
                            <asp:Button runat="server" Text="Delete"
                                CommandName="DeleteModule"
                                CommandArgument='<%# Eval("ModuleID") %>'
                                CssClass="btn btn-sm btn-danger action-btn"
                                CausesValidation="false"
                                OnClientClick="return confirm('Delete this module?');" />
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>

    <asp:Panel ID="pnlEdit" runat="server" Visible="false">
        <div id="editPanel" class="card p-4 mb-4" style="border-left:3px solid #c4a44a !important;">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 style="color:#c4a44a;margin:0;">Edit Module</h5>
                <asp:Button ID="btnCancelEdit" runat="server" Text="✕ Close"
                    CssClass="btn btn-secondary btn-sm" OnClick="btnCancelEdit_Click"
                    CausesValidation="false" />
            </div>
            <asp:Label ID="lblEditMessage" runat="server" Visible="false" CssClass="alert d-block mb-3"></asp:Label>
            <div class="row mb-3">
                <div class="col-md-6 mb-3">
                    <label class="form-label">Title *</label>
                    <asp:TextBox ID="txtEditTitle" runat="server" CssClass="form-control"></asp:TextBox>
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEditTitle"
                        ValidationGroup="EditModule" CssClass="val-msg"
                        ErrorMessage="Title is required." Display="Dynamic" />
                </div>
                <div class="col-md-3 mb-3">
                    <label class="form-label">Status</label>
                    <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Draft"     Value="Draft"></asp:ListItem>
                        <asp:ListItem Text="Published" Value="Published"></asp:ListItem>
                        <asp:ListItem Text="Archived"  Value="Archived"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-md-3 mb-3">
                    <label class="form-label">Sort Order</label>
                    <asp:TextBox ID="txtEditSortOrder" runat="server" CssClass="form-control"></asp:TextBox>
                    <asp:RangeValidator runat="server" ControlToValidate="txtEditSortOrder"
                        ValidationGroup="EditModule" CssClass="val-msg"
                        MinimumValue="0" MaximumValue="9999" Type="Integer"
                        ErrorMessage="Must be a number 0–9999." Display="Dynamic" />
                </div>
                <div class="col-md-12 mb-3">
                    <label class="form-label">Description</label>
                    <asp:TextBox ID="txtEditDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2"></asp:TextBox>
                </div>
            </div>
            <asp:Button ID="btnSaveEdit" runat="server" Text="Save Module"
                CssClass="btn btn-primary mb-4" OnClick="btnSaveEdit_Click"
                ValidationGroup="EditModule" />

            <div style="border-top:1px solid rgba(196,164,74,0.15);padding-top:20px;">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h6 style="color:#c4a44a;margin:0;letter-spacing:1px;text-transform:uppercase;font-size:12px;">Quizzes in this Module</h6>
                    <asp:Label ID="lblQuizCount" runat="server" CssClass="text-muted small"></asp:Label>
                </div>
                <asp:GridView ID="gvQuizzes" runat="server" AutoGenerateColumns="False"
                    CssClass="table table-hover align-middle mb-0" GridLines="None" BorderStyle="None"
                    OnRowCommand="gvQuizzes_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="QuizID"   HeaderText="ID" />
                        <asp:BoundField DataField="Title"    HeaderText="Quiz Title" />
                        <asp:BoundField DataField="QuizType" HeaderText="Type" />
                        <asp:BoundField DataField="PassMark" HeaderText="Pass Mark" />
                        <asp:TemplateField HeaderText="Attempts">
                            <ItemTemplate><%# RenderAttemptBadge(Eval("AttemptCount")) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <%# GetIsActive(Eval("IsActive"))
                                    ? "<span style='color:#2ecc71;font-weight:600;'>● Active</span>"
                                    : "<span style='color:#e74c3c;font-weight:600;'>● Inactive</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <div style="display:flex;gap:6px;">
                                    <asp:Button runat="server" Text="✔ Enable"
                                        CommandName="EnableQuiz"
                                        CommandArgument='<%# Eval("QuizID") %>'
                                        CssClass="btn btn-sm btn-success action-btn"
                                        CausesValidation="false"
                                        Visible='<%# !GetIsActive(Eval("IsActive")) %>' />
                                    <asp:Button runat="server" Text="✕ Disable"
                                        CommandName="DisableQuiz"
                                        CommandArgument='<%# Eval("QuizID") %>'
                                        CssClass="btn btn-sm btn-warning action-btn"
                                        CausesValidation="false"
                                        Visible='<%# GetIsActive(Eval("IsActive")) %>'
                                        OnClientClick="return confirm('Disable this quiz?');" />
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </asp:Panel>

    <div class="modal fade" id="addModuleModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add New Module</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Title *</label>
                        <asp:TextBox ID="txtAddTitle" runat="server" CssClass="form-control"></asp:TextBox>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddTitle"
                            ValidationGroup="AddModule" CssClass="val-msg"
                            ErrorMessage="Title is required." Display="Dynamic" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Description</label>
                        <asp:TextBox ID="txtAddDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Status</label>
                            <asp:DropDownList ID="ddlAddStatus" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Draft"     Value="Draft"></asp:ListItem>
                                <asp:ListItem Text="Published" Value="Published"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Sort Order</label>
                            <asp:TextBox ID="txtAddSortOrder" runat="server" CssClass="form-control" Text="0"></asp:TextBox>
                            <asp:RangeValidator runat="server" ControlToValidate="txtAddSortOrder"
                                ValidationGroup="AddModule" CssClass="val-msg"
                                MinimumValue="0" MaximumValue="9999" Type="Integer"
                                ErrorMessage="Must be a number 0–9999." Display="Dynamic" />
                        </div>
                    </div>
                    <asp:Label ID="lblAddError" runat="server" Visible="false" CssClass="alert alert-danger d-block"></asp:Label>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnAddModule" runat="server" Text="Add Module"
                        CssClass="btn btn-primary" OnClick="btnAddModule_Click"
                        ValidationGroup="AddModule" />
                </div>
            </div>
        </div>
    </div>

    <style>
        .action-btn { width:90px; text-align:center; }
        .val-msg    { display:block; font-size:11px; color:#e74c3c; margin-top:4px; font-weight:500; }
    </style>

</asp:Content>