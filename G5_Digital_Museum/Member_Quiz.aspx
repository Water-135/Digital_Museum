<%@ Page Title="Member Quiz" Language="C#"
    MasterPageFile="~/Member_MasterPage.Master"
    AutoEventWireup="true"
    CodeBehind="Member_Quiz.aspx.cs"
    Inherits="G5_Digital_Museum.Member_Quiz" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        .quiz-page {
            padding-top: 72px;
            background: var(--dm-black);
            min-height: 100vh;
        }

        .quiz-hero {
            padding: 80px 0 40px;
            text-align: center;
            background: var(--dm-dark);
            border-bottom: 1px solid var(--dm-border);
        }

        .quiz-hero h1 {
            font-size: clamp(2rem, 4vw, 3rem);
            margin-bottom: 12px;
        }

        .quiz-hero p {
            color: var(--dm-grey-light);
            max-width: 760px;
            margin: 0 auto;
            font-size: 16px;
        }

        .quiz-layout {
            display: grid;
            grid-template-columns: 340px 1fr;
            gap: 28px;
            padding: 40px 0 80px;
        }

        .quiz-panel {
            background: var(--dm-dark);
            border: 1px solid var(--dm-border);
            box-shadow: var(--dm-shadow);
        }

        .quiz-panel-header {
            padding: 22px 24px 16px;
            border-bottom: 1px solid var(--dm-border);
        }

        .quiz-panel-header h2 {
            font-size: 1.4rem;
            margin-bottom: 6px;
        }

        .quiz-panel-header p {
            font-size: 14px;
            color: var(--dm-grey-light);
        }

        .quiz-panel-body {
            padding: 24px;
        }

        .quiz-list {
            display: grid;
            gap: 16px;
        }

        .quiz-item {
            background: var(--dm-charcoal);
            border: 1px solid var(--dm-border);
            padding: 18px;
            transition: all var(--transition);
        }

        .quiz-item:hover {
            border-color: var(--dm-accent-dim);
            transform: translateY(-2px);
        }

        .quiz-item .meta {
            font-size: 10px;
            letter-spacing: 3px;
            text-transform: uppercase;
            color: var(--dm-accent);
            margin-bottom: 10px;
        }

        .quiz-item h3 {
            font-size: 1.1rem;
            margin-bottom: 8px;
        }

        .quiz-item p {
            font-size: 13px;
            color: var(--dm-grey-light);
            margin-bottom: 14px;
        }

        .quiz-topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }

        .timer-box {
            background: var(--dm-charcoal);
            border: 1px solid var(--dm-border);
            padding: 12px 16px;
            min-width: 150px;
        }

        .timer-box .label {
            display: block;
            font-size: 10px;
            letter-spacing: 3px;
            text-transform: uppercase;
            color: var(--dm-accent);
            margin-bottom: 6px;
        }

        .timer-box .value {
            font-size: 1.6rem;
            font-family: var(--font-display);
            color: var(--dm-white);
        }

        .progress-box {
            flex: 1;
            min-width: 220px;
        }

        .progress-text {
            font-size: 12px;
            color: var(--dm-grey-light);
            margin-bottom: 8px;
            letter-spacing: 1px;
        }

        .progress-track {
            width: 100%;
            height: 12px;
            background: var(--dm-charcoal);
            border: 1px solid var(--dm-border);
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            width: 0%;
            background: var(--dm-accent);
            transition: width 0.4s ease;
        }

        .question-meta {
            font-size: 11px;
            letter-spacing: 3px;
            text-transform: uppercase;
            color: var(--dm-accent);
            margin-bottom: 14px;
        }

        .question-title {
            font-size: 1.8rem;
            margin-bottom: 12px;
        }

        .question-text {
            color: var(--dm-grey-light);
            line-height: 1.8;
            margin-bottom: 24px;
            font-size: 15px;
        }

        .quiz-answer-area {
            margin-bottom: 28px;
        }

        .quiz-options {
            display: grid;
            gap: 14px;
        }

        .quiz-option {
            background: var(--dm-charcoal);
            border: 1px solid var(--dm-border);
            padding: 16px 18px;
            cursor: pointer;
            transition: all var(--transition);
        }

        .quiz-option:hover {
            border-color: var(--dm-accent-dim);
            background: rgba(196, 164, 74, 0.06);
        }

        .quiz-option.selected {
            border-color: var(--dm-accent);
            background: rgba(196, 164, 74, 0.12);
        }

        .quiz-option input {
            margin-right: 10px;
            accent-color: var(--dm-accent);
        }

        .quiz-option label {
            color: var(--dm-cream);
            cursor: pointer;
        }

        .quiz-textbox,
        .quiz-textarea,
        .quiz-select {
            width: 100%;
            padding: 12px 16px;
            background: var(--dm-charcoal);
            border: 1px solid var(--dm-grey-dark);
            color: var(--dm-cream);
            font-family: var(--font-body);
            font-size: 14px;
            outline: none;
        }

        .quiz-textbox:focus,
        .quiz-textarea:focus,
        .quiz-select:focus {
            border-color: var(--dm-accent);
        }

        .quiz-textarea {
            min-height: 130px;
            resize: vertical;
        }

        .quiz-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 24px;
        }

        .result-box {
            background: var(--dm-charcoal);
            border: 1px solid var(--dm-border);
            padding: 28px;
            text-align: center;
        }

        .result-box h3 {
            font-size: 2rem;
            margin-bottom: 12px;
        }

        .result-score {
            font-size: 3rem;
            color: var(--dm-accent);
            font-family: var(--font-display);
            margin-bottom: 12px;
        }

        .result-box p {
            color: var(--dm-grey-light);
            margin-bottom: 18px;
        }

        .quiz-empty {
            color: var(--dm-grey-light);
            font-size: 15px;
            line-height: 1.8;
        }

        .quiz-message {
            background: rgba(139, 26, 26, 0.12);
            border: 1px solid var(--dm-red-memorial);
            color: #d8a8a8;
            padding: 14px 16px;
            margin-bottom: 18px;
            font-size: 14px;
        }

        .timeline-grid {
            display: grid;
            gap: 14px;
        }

        .timeline-item {
            background: var(--dm-charcoal);
            border: 1px solid var(--dm-border);
            padding: 16px;
        }

        .timeline-item .event-text {
            color: var(--dm-cream);
            margin-bottom: 10px;
        }

        .image-match-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(180px, 1fr));
            gap: 16px;
        }

        .image-choice {
            background: var(--dm-charcoal);
            border: 1px solid var(--dm-border);
            padding: 12px;
            transition: all var(--transition);
        }

        .image-choice:hover {
            border-color: var(--dm-accent-dim);
        }

        .image-choice.selected {
            border-color: var(--dm-accent);
            background: rgba(196, 164, 74, 0.10);
        }

        .image-choice img {
            width: 100%;
            height: 180px;
            object-fit: cover;
            margin-bottom: 10px;
            border: 1px solid rgba(255,255,255,0.08);
        }

        .image-choice label {
            display: block;
            color: var(--dm-cream);
            cursor: pointer;
        }

        @media (max-width: 992px) {
            .quiz-layout {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .image-match-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <div class="quiz-page">

        <section class="quiz-hero">
            <div class="container">
                <div class="section-label">Assessment Tools</div>
                <h1>Member Quiz</h1>
                <p>
                    Test your understanding of the museum modules through respectful and interactive assessments.
                </p>
                <div class="section-divider"></div>
            </div>
        </section>

        <section class="section">
            <div class="container">

                <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="quiz-message"></asp:Label>

                <div class="quiz-layout">

                    <!-- LEFT QUIZ LIST -->
                    <div class="quiz-panel fade-in-up">
                        <div class="quiz-panel-header">
                            <h2>Available Quizzes</h2>
                            <p>Select a published quiz to begin.</p>
                        </div>
                        <div class="quiz-panel-body">
                            <div class="quiz-panel fade-in-up">
    <div class="quiz-panel-header">
        <h2>Quiz Categories</h2>
        <p>Select a published quiz type to begin.</p>
    </div>

    <div class="quiz-panel-body">

        <div class="quiz-group">
            <div class="quiz-group-title">MCQ</div>
            <asp:Repeater ID="rptMCQ" runat="server" OnItemCommand="rptQuizzes_ItemCommand">
                <ItemTemplate>
                    <div class="quiz-item">
                        <div class="meta">
                            <%# Eval("ModuleTitle") %> • <%# Eval("QuizType") %>
                        </div>
                        <h3><%# Eval("Title") %></h3>
                        <p>Pass mark: <%# Eval("PassMark") %>%</p>

                        <asp:LinkButton ID="btnStartQuiz" runat="server"
                            CssClass="btn btn-primary btn-sm"
                            CommandName="start"
                            CommandArgument='<%# Eval("QuizID") %>'>
                            Start Quiz
                        </asp:LinkButton>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlNoMCQ" runat="server" Visible="false">
                <div class="quiz-empty">No MCQ quiz available.</div>
            </asp:Panel>
        </div>

        <div class="quiz-group">
            <div class="quiz-group-title">True / False</div>
            <asp:Repeater ID="rptTrueFalse" runat="server" OnItemCommand="rptQuizzes_ItemCommand">
                <ItemTemplate>
                    <div class="quiz-item">
                        <div class="meta">
                            <%# Eval("ModuleTitle") %> • <%# Eval("QuizType") %>
                        </div>
                        <h3><%# Eval("Title") %></h3>
                        <p>Pass mark: <%# Eval("PassMark") %>%</p>

                        <asp:LinkButton ID="btnStartQuiz" runat="server"
                            CssClass="btn btn-primary btn-sm"
                            CommandName="start"
                            CommandArgument='<%# Eval("QuizID") %>'>
                            Start Quiz
                        </asp:LinkButton>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlNoTrueFalse" runat="server" Visible="false">
                <div class="quiz-empty">No True / False quiz available.</div>
            </asp:Panel>
        </div>

        <div class="quiz-group">
            <div class="quiz-group-title">Fill in the Blank</div>
            <asp:Repeater ID="rptFillBlank" runat="server" OnItemCommand="rptQuizzes_ItemCommand">
                <ItemTemplate>
                    <div class="quiz-item">
                        <div class="meta">
                            <%# Eval("ModuleTitle") %> • <%# Eval("QuizType") %>
                        </div>
                        <h3><%# Eval("Title") %></h3>
                        <p>Pass mark: <%# Eval("PassMark") %>%</p>

                        <asp:LinkButton ID="btnStartQuiz" runat="server"
                            CssClass="btn btn-primary btn-sm"
                            CommandName="start"
                            CommandArgument='<%# Eval("QuizID") %>'>
                            Start Quiz
                        </asp:LinkButton>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlNoFillBlank" runat="server" Visible="false">
                <div class="quiz-empty">No Fill in the Blank quiz available.</div>
            </asp:Panel>
        </div>

        <div class="quiz-group">
            <div class="quiz-group-title">Image Match</div>
            <asp:Repeater ID="rptImageMatch" runat="server" OnItemCommand="rptQuizzes_ItemCommand">
                <ItemTemplate>
                    <div class="quiz-item">
                        <div class="meta">
                            <%# Eval("ModuleTitle") %> • <%# Eval("QuizType") %>
                        </div>
                        <h3><%# Eval("Title") %></h3>
                        <p>Pass mark: <%# Eval("PassMark") %>%</p>

                        <asp:LinkButton ID="btnStartQuiz" runat="server"
                            CssClass="btn btn-primary btn-sm"
                            CommandName="start"
                            CommandArgument='<%# Eval("QuizID") %>'>
                            Start Quiz
                        </asp:LinkButton>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlNoImageMatch" runat="server" Visible="false">
                <div class="quiz-empty">No Image Match quiz available.</div>
            </asp:Panel>
        </div>

        <div class="quiz-group">
            <div class="quiz-group-title">Short Answer</div>
            <asp:Repeater ID="rptShortAnswer" runat="server" OnItemCommand="rptQuizzes_ItemCommand">
                <ItemTemplate>
                    <div class="quiz-item">
                        <div class="meta">
                            <%# Eval("ModuleTitle") %> • <%# Eval("QuizType") %>
                        </div>
                        <h3><%# Eval("Title") %></h3>
                        <p>Pass mark: <%# Eval("PassMark") %>%</p>

                        <asp:LinkButton ID="btnStartQuiz" runat="server"
                            CssClass="btn btn-primary btn-sm"
                            CommandName="start"
                            CommandArgument='<%# Eval("QuizID") %>'>
                            Start Quiz
                        </asp:LinkButton>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlNoShortAnswer" runat="server" Visible="false">
                <div class="quiz-empty">No Short Answer quiz available.</div>
            </asp:Panel>
        </div>

    </div>
</div>

                            <asp:Panel ID="pnlNoQuiz" runat="server" Visible="false">
                                <div class="quiz-empty">
                                    No published quizzes are available yet.
                                </div>
                            </asp:Panel>
                        </div>
                    </div>

                    <!-- RIGHT CONTENT -->
                    <div class="quiz-panel fade-in-up delay-1">
                        <div class="quiz-panel-body">

                            <asp:MultiView ID="mvQuiz" runat="server" ActiveViewIndex="0">

                                <!-- INTRO -->
                                <asp:View ID="vwIntro" runat="server">
                                    <div class="section-label">Quiz Centre</div>
                                    <h2 class="section-title">Begin Your Assessment</h2>
                                    <p class="section-subtitle" style="text-align:left; max-width:none;">
                                        Choose a quiz from the left panel. Your score will be recorded after submission.
                                    </p>
                                </asp:View>

                                <!-- QUESTION -->
                                <asp:View ID="vwQuestion" runat="server">

                                    <div class="quiz-topbar">
                                        <div class="timer-box">
                                            <span class="label">Time Remaining</span>
                                            <div class="value" id="quizTimer">05:00</div>
                                        </div>

                                        <div class="progress-box">
                                            <div class="progress-text">
                                                <asp:Literal ID="litProgressText" runat="server"></asp:Literal>
                                            </div>
                                            <div class="progress-track">
                                                <div id="quizProgressBar" class="progress-fill"></div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="question-meta">
                                        <asp:Literal ID="litQuestionType" runat="server"></asp:Literal>
                                    </div>

                                    <div class="question-title">
                                        <asp:Literal ID="litQuestionTitle" runat="server"></asp:Literal>
                                    </div>

                                    <div class="question-text">
                                        <asp:Literal ID="litQuestionText" runat="server"></asp:Literal>
                                    </div>

                                    <div class="quiz-answer-area">
                                        <asp:PlaceHolder ID="phQuestionInput" runat="server"></asp:PlaceHolder>
                                    </div>
                                    <asp:Panel ID="pnlReviewFeedback" runat="server" Visible="false" CssClass="review-box">
    <h4>Answer Review</h4>
    <asp:Literal ID="litReviewFeedback" runat="server"></asp:Literal>
</asp:Panel>

                                    <div class="quiz-actions">
                                        <asp:Button ID="btnPrev" runat="server"
                                            Text="Previous"
                                            CssClass="btn btn-outline btn-sm"
                                            OnClick="btnPrev_Click" />

                                        <asp:Button ID="btnNext" runat="server"
                                            Text="Next"
                                            CssClass="btn btn-primary btn-sm"
                                            OnClick="btnNext_Click" />

                                        <asp:Button ID="btnSubmitQuiz" runat="server"
                                            Text="Submit Quiz"
                                            CssClass="btn btn-memorial btn-sm"
                                            OnClick="btnSubmitQuiz_Click"
                                            OnClientClick="return confirmQuizSubmit();" />
                                    </div>

                                    <asp:HiddenField ID="hfCurrentQuestion" runat="server" />
                                    <asp:HiddenField ID="hfTotalQuestions" runat="server" />
                                </asp:View>

                                <!-- RESULT -->
                                <asp:View ID="vwResult" runat="server">
                                    <div class="result-box">
                                        <div class="section-label">Assessment Complete</div>
                                        <h3><asp:Literal ID="litResultTitle" runat="server"></asp:Literal></h3>
                                        <div class="result-score">
                                            <asp:Literal ID="litScore" runat="server"></asp:Literal>
                                        </div>
                                        <p><asp:Literal ID="litResultSummary" runat="server"></asp:Literal></p>

                                        <div class="quiz-actions" style="justify-content:center;">
    <asp:Button ID="btnReviewAnswers" runat="server"
        Text="Review Answers"
        CssClass="btn btn-primary"
        OnClick="btnReviewAnswers_Click" />

    <asp:Button ID="btnReattemptQuiz" runat="server"
        Text="Re-attempt Quiz"
        CssClass="btn btn-memorial"
        OnClick="btnReattemptQuiz_Click" />

    <asp:Button ID="btnBackToList" runat="server"
        Text="Back to Quiz List"
        CssClass="btn btn-outline"
        OnClick="btnBackToList_Click" />
</div>
                                    </div>
                                </asp:View>

                            </asp:MultiView>

                        </div>
                    </div>

                </div>
            </div>
        </section>
    </div>

    <script>
        let totalSeconds = 300;
        let timerInterval = null;

        function startQuizTimer() {
            const timerEl = document.getElementById("quizTimer");
            if (!timerEl) return;

            if (timerInterval) {
                clearInterval(timerInterval);
            }

            timerInterval = setInterval(function () {
                const minutes = Math.floor(totalSeconds / 60);
                const seconds = totalSeconds % 60;

                timerEl.textContent =
                    String(minutes).padStart(2, '0') + ":" +
                    String(seconds).padStart(2, '0');

                if (totalSeconds <= 0) {
                    clearInterval(timerInterval);
                    alert("Time is up. Your quiz will be submitted.");
                    const submitBtn = document.getElementById('<%= btnSubmitQuiz.ClientID %>');
                    if (submitBtn) {
                        submitBtn.click();
                    }
                    return;
                }

                totalSeconds--;
            }, 1000);
        }

        function setProgressBar() {
            const currentField = document.getElementById('<%= hfCurrentQuestion.ClientID %>');
            const totalField = document.getElementById('<%= hfTotalQuestions.ClientID %>');
            const progressBar = document.getElementById("quizProgressBar");

            if (!currentField || !totalField || !progressBar) return;

            const current = parseInt(currentField.value || "0");
            const total = parseInt(totalField.value || "0");

            if (total > 0) {
                const percent = (current / total) * 100;
                progressBar.style.width = percent + "%";
            }
        }

        function confirmQuizSubmit() {
            return confirm("Submit your quiz now? You cannot change your answers after submission.");
        }

        function enableOptionHighlight() {
            document.querySelectorAll(".quiz-option").forEach(function (box) {
                box.addEventListener("click", function (e) {
                    const input = box.querySelector("input[type='radio']");
                    if (input) {
                        input.checked = true;

                        const groupName = input.name;
                        document.querySelectorAll("input[name='" + groupName + "']").forEach(function (rb) {
                            const parent = rb.closest(".quiz-option");
                            if (parent) parent.classList.remove("selected");
                        });

                        box.classList.add("selected");
                    }
                });
            });

            document.querySelectorAll(".image-choice").forEach(function (box) {
                box.addEventListener("click", function () {
                    const input = box.querySelector("input[type='radio']");
                    if (input) {
                        input.checked = true;

                        const groupName = input.name;
                        document.querySelectorAll("input[name='" + groupName + "']").forEach(function (rb) {
                            const parent = rb.closest(".image-choice");
                            if (parent) parent.classList.remove("selected");
                        });

                        box.classList.add("selected");
                    }
                });
            });
        }

        document.addEventListener("DOMContentLoaded", function () {
            setProgressBar();
            enableOptionHighlight();

            const timerEl = document.getElementById("quizTimer");
            if (timerEl) {
                startQuizTimer();
            }
        });
    </script>

</asp:Content>