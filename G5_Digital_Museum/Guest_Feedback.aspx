<%@ Page Title="Guestbook" Language="C#" MasterPageFile="~/GuestSite.Master" AutoEventWireup="true" CodeBehind="Guest_Feedback.aspx.cs" Inherits="G5_Digital_Museum.Guest_Feedback" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Internal CSS: Feedback page specific styles */
        .feedback-layout {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 48px;
            align-items: start;
        }
        @media (max-width: 768px) {
            .feedback-layout {
                grid-template-columns: 1fr;
            }
        }
        .rating-group {
            display: flex;
            gap: 8px;
            margin-top: 6px;
        }
        .rating-group input[type="radio"] {
            display: none;
        }
        .rating-group label {
            font-size: 36px;
            color: #2a2a2a;
            cursor: pointer;
            transition: color 0.2s ease;
            text-transform: none !important;
            letter-spacing: 0 !important;
            margin-bottom: 0 !important;
        }
        .rating-group label:hover,
        .rating-group label:hover ~ label {
            color: #c4a44a;
        }
        .rating-group input[type="radio"]:checked ~ label {
            color: #c4a44a;
        }
        .char-count {
            font-size: 18px;
            color: #555;
            text-align: right;
            margin-top: 4px;
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="content-page">

        <!-- Page Hero -->
        <div class="page-hero">
            <div class="container">
                <span class="section-label">Visitor Engagement</span>
                <h1>Guestbook</h1>
                <p>Share your reflections after visiting the Digital Museum. No registration required &mdash; your words help preserve the memory.</p>
            </div>
        </div>

        <section class="section">
            <div class="container">

                <div class="feedback-layout">

                    <!-- LEFT: Feedback Submission Form -->
                    <div>
                        <h2 style="font-family: 'Playfair Display', serif; font-size: 2rem; color: #f5f2ed; margin-bottom: 8px;">
                            Leave a Message
                        </h2>
                        <p style="color: #999; font-size: 24px; margin-bottom: 32px;">
                            Leave your reflection as a guest. Your entry will appear in Recent Entries after review.
                        </p>

                        <!-- Success / Error Messages -->
                        <asp:Label ID="lblSuccess" runat="server" CssClass="success-msg" Visible="false"></asp:Label>
                        <asp:Label ID="lblError" runat="server" CssClass="validation-summary" Visible="false"></asp:Label>

                        <!-- Validation Summary -->
                        <asp:ValidationSummary ID="vsSummary" runat="server" CssClass="validation-summary"
                            HeaderText="Please correct the following:" DisplayMode="BulletList" />

                        <!-- Name Field -->
                        <div class="form-group">
                            <label for="<%= txtName.ClientID %>">Your Name <span style="color: #a03030;">*</span></label>
                            <asp:TextBox ID="txtName" runat="server" CssClass="form-control" MaxLength="100"
                                placeholder="Enter your full name" />
                            <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName"
                                ErrorMessage="Name is required." Display="Dynamic" CssClass="aspnet-validator"
                                Text="&#9888; Name is required." />
                            <asp:RegularExpressionValidator ID="revName" runat="server" ControlToValidate="txtName"
                                ValidationExpression="^[a-zA-Z\s\-'.]{2,100}$"
                                ErrorMessage="Name must contain only letters, spaces, hyphens, or apostrophes (2-100 characters)."
                                Display="Dynamic" CssClass="aspnet-validator"
                                Text="&#9888; Invalid name format." />
                        </div>

                        <!-- Email Field -->
                        <div class="form-group">
                            <label for="<%= txtEmail.ClientID %>">Email Address <span style="color: #a03030;">*</span></label>
                            <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="form-control" MaxLength="150"
                                placeholder="your.email@example.com" />
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                                ErrorMessage="Email address is required." Display="Dynamic" CssClass="aspnet-validator"
                                Text="&#9888; Email is required." />
                            <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                                ValidationExpression="^[\w\.-]+@[\w\.-]+\.\w{2,}$"
                                ErrorMessage="Please enter a valid email address."
                                Display="Dynamic" CssClass="aspnet-validator"
                                Text="&#9888; Invalid email format." />
                        </div>

                        <!-- Country Field -->
                        <div class="form-group">
                            <label for="<%= ddlCountry.ClientID %>">Country</label>
                            <asp:DropDownList ID="ddlCountry" runat="server" CssClass="form-control">
                                <asp:ListItem Value="Australia">Australia</asp:ListItem>
                                <asp:ListItem Value="Canada">Canada</asp:ListItem>
                                <asp:ListItem Value="China">China</asp:ListItem>
                                <asp:ListItem Value="France">France</asp:ListItem>
                                <asp:ListItem Value="Germany">Germany</asp:ListItem>
                                <asp:ListItem Value="India">India</asp:ListItem>
                                <asp:ListItem Value="Japan">Japan</asp:ListItem>
                                <asp:ListItem Value="Malaysia">Malaysia</asp:ListItem>
                                <asp:ListItem Value="Singapore">Singapore</asp:ListItem>
                                <asp:ListItem Value="South Korea">South Korea</asp:ListItem>
                                <asp:ListItem Value="United Kingdom">United Kingdom</asp:ListItem>
                                <asp:ListItem Value="United States">United States</asp:ListItem>
                                <asp:ListItem Value="Other">Other</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <!-- Rating Field -->
                        <div class="form-group">
                            <label>Museum Rating <span style="color: #a03030;">*</span></label>

                            <div class="star-rating">
                                <span class="star" data-value="1">&#9733;</span>
                                <span class="star" data-value="2">&#9733;</span>
                                <span class="star" data-value="3">&#9733;</span>
                                <span class="star" data-value="4">&#9733;</span>
                                <span class="star" data-value="5">&#9733;</span>
                            </div>

                            <asp:HiddenField ID="hfRating" runat="server" ClientIDMode="Static" />
                        </div>
                        <!-- Message Field -->
                        <div class="form-group">
                            <label for="<%= txtMessage.ClientID %>">Your Message <span style="color: #a03030;">*</span></label>
                            <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine" Rows="5"
                                CssClass="form-control" MaxLength="1000"
                                placeholder="Share your thoughts, reflections, or words of remembrance..." />
                            <asp:RequiredFieldValidator ID="rfvMessage" runat="server" ControlToValidate="txtMessage"
                                ErrorMessage="Message is required." Display="Dynamic" CssClass="aspnet-validator"
                                Text="&#9888; Message is required." />
                            <asp:RegularExpressionValidator ID="revMessage" runat="server" ControlToValidate="txtMessage"
                                ValidationExpression="^[\s\S]{10,1000}$"
                                ErrorMessage="Message must be between 10 and 1000 characters."
                                Display="Dynamic" CssClass="aspnet-validator"
                                Text="&#9888; Message must be at least 10 characters." />
                            <div class="char-count">
                                <span id="charCount">0</span>/1000 characters
                            </div>
                        </div>

                        <!-- Submit Button -->
                        <asp:Button ID="btnSubmitFeedback" runat="server" Text="SUBMIT YOUR REFLECTION" 
                            CssClass="btn btn-primary btn-block" OnClick="btnSubmitFeedback_Click" />

                        <p style="color: #555; font-size: 13px; text-align: center; margin-top: 16px;">
                            Want to view more messages or join discussions? 
                            <a href="Main_LoginPage.aspx" style="color: #c4a44a;">Sign In</a> or 
                            <a href="Member_Registration.aspx" style="color: #c4a44a;">Register</a> as a member.
                        </p>
                    </div>

                    <!-- RIGHT: Display Existing Guestbook Entries -->
                    <div>
                        <h2 style="font-family: 'Playfair Display', serif; font-size: 2rem; color: #f5f2ed; margin-bottom: 8px;">
                            Recent Entries
                        </h2>
                        <p style="color: #999; font-size: 24px; margin-bottom: 32px;">
                            Messages from visitors around the world.
                        </p>

                        <asp:Repeater ID="rptFeedback" runat="server">
                            <ItemTemplate>
                                <div class="feedback-entry">
                                    <div class="entry-header">
                                        <span class="entry-name"><%# Server.HtmlEncode(Eval("VisitorName").ToString()) %></span>
                                        <span class="entry-date"><%# Eval("SubmittedDate", "{0:MMM dd, yyyy}") %></span>
                                    </div>
                                    <div class="stars"><%# GetStarRating((int)Eval("Rating")) %></div>
                                    <p class="entry-message"><%# Server.HtmlEncode(Eval("Message").ToString()) %></p>
                                    <span style="font-size: 18px; color: #555;">
                                        <%# Eval("Country") != DBNull.Value && !string.IsNullOrEmpty(Eval("Country").ToString()) 
                                            ? "From " + Server.HtmlEncode(Eval("Country").ToString()) 
                                            : "" %>
                                    </span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <asp:Label ID="lblNoEntries" runat="server" Visible="false"
                            style="display: block; text-align: center; color: #555; padding: 40px; font-size: 24px; background: #1e1e1e; border: 1px solid rgba(196, 164, 74, 0.2);">
                            No guestbook entries yet. Be the first to leave a message.
                        </asp:Label>
                    </div>

                </div>

            </div>
        </section>

    </div>

   
    <!-- Client-Side JavaScript -->
    <script type="text/javascript">
        // Character counter for message field
        (function () {
            var txtMsg = document.getElementById('<%= txtMessage.ClientID %>');
            var charDisplay = document.getElementById('charCount');
            if (txtMsg && charDisplay) {
                txtMsg.addEventListener('input', function () {
                    charDisplay.textContent = this.value.length;
                    if (this.value.length > 1000) {
                        charDisplay.style.color = '#a03030';
                    } else {
                        charDisplay.style.color = '#555';
                    }
                });
            }
        })();
    </script>

    <script type="text/javascript">
        window.addEventListener("load", function () {

            var stars = document.querySelectorAll(".star");
            var hiddenField = document.getElementById("hfRating");

            if (!hiddenField || stars.length === 0) return;

            for (let i = 0; i < stars.length; i++) {

                stars[i].style.fontSize = "42px";
                stars[i].style.cursor = "pointer";
                stars[i].style.color = "#444";
                stars[i].style.marginRight = "6px";

                stars[i].addEventListener("click", function () {

                    var value = parseInt(this.getAttribute("data-value"));
                    hiddenField.value = value;

                    for (let j = 0; j < stars.length; j++) {
                        stars[j].style.color = "#444";
                    }

                    for (let j = 0; j < value; j++) {
                        stars[j].style.color = "#c4a44a";
                    }
                });

            }

        });
    </script>

</asp:Content>
