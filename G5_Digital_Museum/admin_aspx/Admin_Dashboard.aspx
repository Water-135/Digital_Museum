<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_Dashboard.aspx.cs" Inherits="G5_Digital_Museum.Admin_Dashboard" MasterPageFile="~/Admin_ASPX/Admin_Master.Master" %>

<asp:Content ContentPlaceHolderID="PageTitle" runat="server">
    <h2 class="mb-0">DASHBOARD</h2>
    <div class="ms-auto text-end">
        <span id="liveClock" class="live-clock">--:--:--</span>
        <span id="liveDate"  class="live-date">--- --, ----</span>
    </div>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <asp:HiddenField ID="hdnTotalUsers"         runat="server" />
    <asp:HiddenField ID="hdnTotalExhibits"       runat="server" />
    <asp:HiddenField ID="hdnTotalQuizzes"        runat="server" />
    <asp:HiddenField ID="hdnTotalAttempts"       runat="server" />
    <asp:HiddenField ID="hdnPendingFeedback"     runat="server" />
    <asp:HiddenField ID="hdnDraftExhibits"       runat="server" />
    <asp:HiddenField ID="hdnInactiveUsers"       runat="server" />
    <asp:HiddenField ID="hdnTotalModules"        runat="server" />
    <asp:HiddenField ID="hdnQuizzesNoAttempts"   runat="server" />
    <asp:HiddenField ID="hdnNeverLoggedIn"       runat="server" />
    <asp:HiddenField ID="hdnAvgScore"            runat="server" />
    <asp:HiddenField ID="hdnQuizRate"            runat="server" />
    <asp:HiddenField ID="hdnHealthScore"         runat="server" />
    <asp:HiddenField ID="hdnUserScore"           runat="server" />
    <asp:HiddenField ID="hdnQuizScorePts"        runat="server" />
    <asp:HiddenField ID="hdnExhibitScore"        runat="server" />
    <asp:HiddenField ID="hdnRoleLabels"          runat="server" />
    <asp:HiddenField ID="hdnRoleData"            runat="server" />
    <asp:HiddenField ID="hdnTopCategory"         runat="server" />
    <asp:HiddenField ID="hdnNewestUser"          runat="server" />

    <%-- ══ SECTION 1: ONGOING EXHIBITIONS ══ --%>
    <div class="section-label mb-3">Ongoing Exhibitions</div>
    <div class="card p-4 mb-4">
        <asp:Label ID="lblNoExhibits" runat="server" Visible="false"
            style="color:#555; font-size:13px;">No published exhibitions yet.</asp:Label>
        <div class="exhibit-grid">
            <asp:Repeater ID="rptExhibits" runat="server">
                <ItemTemplate>
                    <div class="exhibit-tile">
                        <div class="exhibit-img-wrap">
                            <%# RenderExhibitThumb(Eval("ImageUrl")) %>
                        </div>
                        <div class="exhibit-info">
                            <div class="exhibit-cat"><%# Eval("Category") %></div>
                            <div class="exhibit-title"><%# Eval("Title") %></div>
                            <div class="exhibit-date">Since <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM yyyy") %></div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <%-- ══ SECTION 2: PLATFORM SNAPSHOT ══ --%>
    <div class="section-label mb-3">Platform Snapshot</div>
    <div class="row g-3 mb-4">

        <div class="col-md-4">
            <div class="flip-card" onclick="flipCard(this)">
                <div class="flip-inner">
                    <div class="flip-front dash-card text-center">
                        <div class="flip-hint">Click for breakdown ↻</div>
                        <div class="dash-card-title">Museum Health Score</div>
                        <div class="dash-card-sub">Overall platform performance</div>
                        <div style="max-width:180px;margin:0 auto;position:relative;">
                            <canvas id="chartGauge"></canvas>
                            <div class="gauge-label">
                                <span id="healthVal">0</span>
                                <small>/100</small>
                            </div>
                        </div>
                        <div id="healthMsg" class="health-msg mt-3"></div>
                    </div>
                    <div class="flip-back dash-card">
                        <div class="flip-hint">Click to go back ↺</div>
                        <div class="dash-card-title">Score Breakdown</div>
                        <div class="dash-card-sub">How your score is calculated</div>
                        <div class="breakdown-list" id="healthBreakdown"></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="flip-card" onclick="flipCard(this)">
                <div class="flip-inner">
                    <div class="flip-front dash-card">
                        <div class="flip-hint">Click for analysis ↻</div>
                        <div class="dash-card-title">Platform Activity</div>
                        <div class="dash-card-sub">Key performance metrics</div>
                        <div class="prog-item mt-3">
                            <div class="d-flex justify-content-between mb-1">
                                <span class="prog-lbl">Quiz Completion Rate</span>
                                <span class="prog-val" id="lblQuizRate">0%</span>
                            </div>
                            <div class="prog-track"><div class="prog-bar" id="barQuizRate" style="--color:#c4a44a;width:0%"></div></div>
                        </div>
                        <div class="prog-item">
                            <div class="d-flex justify-content-between mb-1">
                                <span class="prog-lbl">Avg Quiz Score</span>
                                <span class="prog-val" id="lblAvgScore">0%</span>
                            </div>
                            <div class="prog-track"><div class="prog-bar" id="barAvgScore" style="--color:#3498db;width:0%"></div></div>
                        </div>
                        <div class="prog-item">
                            <div class="d-flex justify-content-between mb-1">
                                <span class="prog-lbl">Museum Health</span>
                                <span class="prog-val" id="lblHealthBar">0%</span>
                            </div>
                            <div class="prog-track"><div class="prog-bar" id="barHealth" style="--color:#2ecc71;width:0%"></div></div>
                        </div>
                    </div>
                    <div class="flip-back dash-card">
                        <div class="flip-hint">Click to go back ↺</div>
                        <div class="dash-card-title">Activity Analysis</div>
                        <div class="dash-card-sub">What these numbers mean</div>
                        <div class="breakdown-list" id="activityBreakdown"></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="flip-card" onclick="flipCard(this)">
                <div class="flip-inner">
                    <div class="flip-front dash-card">
                        <div class="flip-hint">Click for insights ↻</div>
                        <div class="dash-card-title">Users by Role</div>
                        <div class="dash-card-sub">Platform user breakdown</div>
                        <div style="max-width:190px;margin:0 auto;">
                            <canvas id="chartRoles"></canvas>
                        </div>
                    </div>
                    <div class="flip-back dash-card">
                        <div class="flip-hint">Click to go back ↺</div>
                        <div class="dash-card-title">Role Insights</div>
                        <div class="dash-card-sub">What admin can do</div>
                        <div class="breakdown-list" id="roleBreakdown"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- ══ SECTION 3: NEEDS ATTENTION ══ --%>
    <div class="section-label mb-3">Needs Attention</div>
    <div class="row g-3 mb-4">
        <div class="col-md-4 col-lg-2">
            <a href="Admin_Feedback.aspx" class="attention-card attention-gold">
                <div class="attention-icon">💬</div>
                <div class="attention-body">
                    <div class="attention-num" id="numFeedback">0</div>
                    <div class="attention-lbl">Pending Feedback</div>
                    <div class="attention-hint">Review and respond to submissions</div>
                </div>
            </a>
        </div>
        <div class="col-md-4 col-lg-2">
            <a href="Admin_ManageWebsite.aspx" class="attention-card attention-blue">
                <div class="attention-icon">🏛️</div>
                <div class="attention-body">
                    <div class="attention-num" id="numDraft">0</div>
                    <div class="attention-lbl">Draft Exhibits</div>
                    <div class="attention-hint">Unpublished exhibitions waiting</div>
                </div>
            </a>
        </div>
        <div class="col-md-4 col-lg-2">
            <a href="Admin_ManageUsers.aspx" class="attention-card attention-red">
                <div class="attention-icon">🔒</div>
                <div class="attention-body">
                    <div class="attention-num" id="numInactive">0</div>
                    <div class="attention-lbl">Inactive Users</div>
                    <div class="attention-hint">Accounts that are locked or suspended</div>
                </div>
            </a>
        </div>
        <div class="col-md-4 col-lg-2">
            <a href="Admin_ManageModules.aspx" class="attention-card attention-green">
                <div class="attention-icon">📦</div>
                <div class="attention-body">
                    <div class="attention-num" id="numModules">0</div>
                    <div class="attention-lbl">Active Modules</div>
                    <div class="attention-hint">Learning modules currently live</div>
                </div>
            </a>
        </div>
        <div class="col-md-4 col-lg-2">
            <a href="Admin_ManageQuizzes.aspx" class="attention-card attention-orange">
                <div class="attention-icon">📝</div>
                <div class="attention-body">
                    <div class="attention-num" id="numQuizNoAttempts">0</div>
                    <div class="attention-lbl">Unstarted Quizzes</div>
                    <div class="attention-hint">Quizzes with zero attempts</div>
                </div>
            </a>
        </div>
        <div class="col-md-4 col-lg-2">
            <a href="Admin_ManageUsers.aspx" class="attention-card attention-purple">
                <div class="attention-icon">🔐</div>
                <div class="attention-body">
                    <div class="attention-num" id="numNeverLogin">0</div>
                    <div class="attention-lbl">Security Alert</div>
                    <div class="attention-hint">Users who have never logged in</div>
                </div>
            </a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        function updateClock() {
            var now = new Date(), p = function (n) { return String(n).padStart(2, '0'); };
            document.getElementById('liveClock').innerText = p(now.getHours()) + ':' + p(now.getMinutes()) + ':' + p(now.getSeconds());
            var d = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
            var m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            document.getElementById('liveDate').innerText = d[now.getDay()] + ', ' + m[now.getMonth()] + ' ' + now.getDate() + ' ' + now.getFullYear();
        }
        updateClock(); setInterval(updateClock, 1000);

        function flipCard(c) { c.classList.toggle('flipped'); }

        function countUp(el, target, dur) {
            var step = target / (dur / 16), cur = 0;
            var t = setInterval(function () { cur += step; if (cur >= target) { cur = target; clearInterval(t); } el.innerText = Math.floor(cur); }, 16);
        }

        function animBar(barId, lblId, val, dur) {
            var bar = document.getElementById(barId), lbl = document.getElementById(lblId), cur = 0, step = val / (dur / 16);
            var t = setInterval(function () {
                cur += step; if (cur >= val) { cur = val; clearInterval(t); }
                bar.style.width = cur.toFixed(1) + '%'; lbl.innerText = cur.toFixed(1) + '%';
            }, 16);
        }

        function bitem(icon, title, body, color) {
            return '<div class="bitem"><div class="bitem-icon" style="color:' + color + '">' + icon + '</div>'
                + '<div><div class="bitem-title">' + title + '</div>'
                + '<div class="bitem-body">' + body + '</div></div></div>';
        }

        function g(id) { return JSON.parse(document.getElementById(id).value || '[]'); }
        function v(id) { return parseFloat(document.getElementById(id).value || '0'); }

        document.addEventListener('DOMContentLoaded', function () {

            var totalUsers = v('<%= hdnTotalUsers.ClientID %>');
            var totalExhibits = v('<%= hdnTotalExhibits.ClientID %>');
            var pendingFB = v('<%= hdnPendingFeedback.ClientID %>');
            var draftEx = v('<%= hdnDraftExhibits.ClientID %>');
            var inactiveU = v('<%= hdnInactiveUsers.ClientID %>');
            var totalModules = v('<%= hdnTotalModules.ClientID %>');
            var quizNoAttempts   = v('<%= hdnQuizzesNoAttempts.ClientID %>');
            var neverLogin       = v('<%= hdnNeverLoggedIn.ClientID %>');
            var avgScore         = v('<%= hdnAvgScore.ClientID %>');
            var quizRate         = v('<%= hdnQuizRate.ClientID %>');
            var healthScore      = v('<%= hdnHealthScore.ClientID %>');
            var userPts          = v('<%= hdnUserScore.ClientID %>');
            var quizPts          = v('<%= hdnQuizScorePts.ClientID %>');
            var exhibitPts       = v('<%= hdnExhibitScore.ClientID %>');
            var roleLabels       = g('<%= hdnRoleLabels.ClientID %>');
            var roleData         = g('<%= hdnRoleData.ClientID %>');

            countUp(document.getElementById('numFeedback'), pendingFB, 900);
            countUp(document.getElementById('numDraft'), draftEx, 900);
            countUp(document.getElementById('numInactive'), inactiveU, 900);
            countUp(document.getElementById('numModules'), totalModules, 900);
            countUp(document.getElementById('numQuizNoAttempts'), quizNoAttempts, 900);
            countUp(document.getElementById('numNeverLogin'), neverLogin, 900);

            if (pendingFB === 0) document.querySelector('.attention-gold').classList.add('attention-zero');
            if (draftEx === 0) document.querySelector('.attention-blue').classList.add('attention-zero');
            if (inactiveU === 0) document.querySelector('.attention-red').classList.add('attention-zero');
            if (totalModules === 0) document.querySelector('.attention-green').classList.add('attention-zero');
            if (quizNoAttempts === 0) document.querySelector('.attention-orange').classList.add('attention-zero');
            if (neverLogin === 0) document.querySelector('.attention-purple').classList.add('attention-zero');

            setTimeout(function () {
                animBar('barQuizRate', 'lblQuizRate', quizRate, 1200);
                animBar('barAvgScore', 'lblAvgScore', avgScore, 1400);
                animBar('barHealth', 'lblHealthBar', healthScore, 1600);
            }, 300);

            var hColor = healthScore >= 75 ? '#2ecc71' : healthScore >= 50 ? '#c4a44a' : '#e74c3c';
            countUp(document.getElementById('healthVal'), Math.floor(healthScore), 1800);
            var hMsg = document.getElementById('healthMsg');
            hMsg.style.color = hColor;
            hMsg.innerText = healthScore >= 75 ? '✅ Excellent — Platform is thriving.'
                : healthScore >= 50 ? '⚠️ Moderate — More content needed.'
                    : '❌ Needs Attention — Add exhibits and quizzes.';

            var tick = '#666'; var grid = 'rgba(255,255,255,0.04)';

            new Chart(document.getElementById('chartGauge'), {
                type: 'doughnut',
                data: { datasets: [{ data: [healthScore, 100 - healthScore], backgroundColor: [hColor, '#252525'], borderWidth: 0, circumference: 240, rotation: 240 }] },
                options: { responsive: true, cutout: '78%', plugins: { legend: { display: false }, tooltip: { enabled: false } } }
            });

            new Chart(document.getElementById('chartRoles'), {
                type: 'doughnut',
                data: { labels: roleLabels, datasets: [{ data: roleData, backgroundColor: ['#e74c3c', '#c4a44a', '#2ecc71', '#3498db'], borderColor: '#1a1a1a', borderWidth: 3 }] },
                options: { responsive: true, cutout: '62%', plugins: { legend: { position: 'bottom', labels: { color: tick, padding: 10, font: { size: 11 } } } } }
            });

            var hb = '';
            hb += bitem('👤', 'Users (40 pts max)', '<strong>' + userPts + ' pts</strong> earned — based on ' + totalUsers + ' registered users. Target: 100 users for full score.', '#c4a44a');
            hb += bitem('📝', 'Quiz Performance (30 pts max)', '<strong>' + quizPts + ' pts</strong> earned — based on average quiz score of ' + avgScore + '%.', '#3498db');
            hb += bitem('🏛️', 'Exhibits (30 pts max)', '<strong>' + exhibitPts + ' pts</strong> earned — based on ' + totalExhibits + ' active exhibits. Target: 20 for full score.', '#2ecc71');
            hb += bitem(healthScore >= 75 ? '✅' : healthScore >= 50 ? '⚠️' : '❌', 'Total: ' + healthScore + '/100',
                healthScore >= 75 ? 'Great work! Keep adding content and engaging users.'
                    : healthScore >= 50 ? 'Growing well. Publish draft exhibits and encourage quiz participation.'
                        : 'Focus on adding exhibits, creating quizzes, and growing user registrations.', hColor);
            document.getElementById('healthBreakdown').innerHTML = hb;

            var ab = '';
            ab += bitem('📋', 'Quiz Completion Rate', quizRate === 0 ? 'No attempts yet. Share quiz links with members to get started.'
                : '<strong>' + quizRate + '%</strong> of registered users have attempted at least one quiz. ' + (quizRate >= 60 ? 'Healthy engagement.' : 'Encourage more members to take quizzes.'), '#c4a44a');
            ab += bitem('🎯', 'Avg Quiz Score', avgScore === 0 ? 'No quiz data yet.'
                : 'Average score is <strong>' + avgScore + '%</strong>. ' + (avgScore >= 70 ? 'Learners are performing well.' : avgScore >= 50 ? 'Moderate. Review harder questions.' : 'Low scores. Consider simplifying questions.'),
                avgScore >= 70 ? '#2ecc71' : avgScore >= 50 ? '#c4a44a' : '#e74c3c');
            ab += bitem('🏥', 'Museum Health', 'Score of <strong>' + healthScore + '/100</strong>. Fastest way to improve: publish ' + draftEx + ' draft exhibit(s) and encourage quiz participation.', hColor);
            document.getElementById('activityBreakdown').innerHTML = ab;

            var rb = '';
            var totalR = roleData.reduce(function (a, b) { return a + b; }, 0) || 1;
            var domIdx = roleData.indexOf(Math.max.apply(null, roleData));
            rb += bitem('🏅', 'Dominant Role', '<strong>' + roleLabels[domIdx] + '</strong> makes up the largest group (' + roleData[domIdx] + ' users, ' + (roleData[domIdx] / totalR * 100).toFixed(0) + '%).', '#c4a44a');
            var gIdx = roleLabels.indexOf('Guest');
            if (gIdx >= 0 && roleData[gIdx] > totalR * 0.4)
                rb += bitem('⚠️', 'Many Guests', 'Over 40% are Guests. Consider adding incentives for Guests to register as Members.', '#c4a44a');
            else
                rb += bitem('✅', 'Good Member Ratio', 'Member accounts have full access to quizzes and modules — good for engagement.', '#2ecc71');
            if (inactiveU > 0)
                rb += bitem('🔒', 'Locked Accounts', '<strong>' + inactiveU + '</strong> user(s) are currently inactive. Review them in <a href="Admin_ManageUsers.aspx" style="color:#c4a44a;">Manage Users</a>.', '#e74c3c');
            document.getElementById('roleBreakdown').innerHTML = rb;
        });
    </script>

    <style>
        .live-clock { font-family:'Playfair Display',serif; font-size:20px; font-weight:700; color:#c4a44a; letter-spacing:2px; display:block; }
        .live-date  { font-size:11px; color:#444; letter-spacing:1px; text-transform:uppercase; display:block; }

        .section-label { font-size:11px; font-weight:700; letter-spacing:3px; text-transform:uppercase; color:#444; border-bottom:1px solid rgba(196,164,74,0.15); padding-bottom:8px; }

        .attention-card   { display:flex; align-items:center; gap:16px; padding:20px 24px; border-radius:4px; text-decoration:none !important; border:1px solid rgba(255,255,255,0.06); transition:transform 0.2s,border-color 0.2s; height:100%; min-height:110px; box-sizing:border-box; }
        .attention-card:hover { transform:translateY(-2px); }
        .attention-gold   { background:#1a1a1a; border-top:3px solid #c4a44a !important; }
        .attention-blue   { background:#1a1a1a; border-top:3px solid #3498db !important; }
        .attention-red    { background:#1a1a1a; border-top:3px solid #e74c3c !important; }
        .attention-green  { background:#1a1a1a; border-top:3px solid #2ecc71 !important; }
        .attention-orange { background:#1a1a1a; border-top:3px solid #e67e22 !important; }
        .attention-purple { background:#1a1a1a; border-top:3px solid #9b59b6 !important; }
        .attention-zero   { opacity:0.4; }
        .attention-icon   { font-size:28px; flex-shrink:0; }
        .attention-num    { font-family:'Playfair Display',serif; font-size:36px; font-weight:700; color:#e8e0d0; line-height:1; }
        .attention-lbl    { font-size:13px; font-weight:600; color:#999; margin-top:2px; }
        .attention-hint   { font-size:11px; color:#444; margin-top:3px; }

        .dash-card        { background:#1a1a1a; border:1px solid rgba(255,255,255,0.06); border-radius:4px; padding:22px; height:100%; box-sizing:border-box; }
        .dash-card-title  { font-size:15px; color:#c4a44a; font-weight:600; margin-bottom:2px; }
        .dash-card-sub    { font-size:12px; color:#444; margin-bottom:16px; }

        .flip-card        { perspective:1200px; height:100%; min-height:300px; cursor:pointer; }
        .flip-inner       { position:relative; width:100%; height:100%; transition:transform 0.6s cubic-bezier(0.4,0.2,0.2,1); transform-style:preserve-3d; }
        .flip-card.flipped .flip-inner { transform:rotateY(180deg); }
        .flip-front,.flip-back { position:absolute; width:100%; height:100%; backface-visibility:hidden; -webkit-backface-visibility:hidden; border-radius:4px; overflow:hidden; }
        .flip-back        { transform:rotateY(180deg); overflow-y:auto; }
        .flip-hint        { font-size:10px; color:#333; text-align:right; margin-bottom:6px; letter-spacing:1px; text-transform:uppercase; }
        .flip-card:hover .flip-hint { color:#c4a44a; }

        .gauge-label      { position:absolute; bottom:16px; left:50%; transform:translateX(-50%); text-align:center; }
        .gauge-label span { font-family:'Playfair Display',serif; font-size:30px; font-weight:700; color:#c4a44a; display:block; line-height:1; }
        .gauge-label small{ font-size:12px; color:#555; }
        .health-msg       { font-size:13px; font-weight:500; }

        .prog-item  { margin-bottom:18px; }
        .prog-lbl   { font-size:13px; color:#666; }
        .prog-val   { font-size:13px; font-weight:600; color:#c4a44a; }
        .prog-track { background:#252525; height:8px; border-radius:4px; overflow:hidden; }
        .prog-bar   { height:100%; width:0%; background:var(--color); border-radius:4px; transition:width 0.05s linear; }

        .breakdown-list   { display:flex; flex-direction:column; gap:10px; }
        .bitem            { display:flex; gap:12px; align-items:flex-start; padding:10px 12px; background:rgba(255,255,255,0.02); border-radius:3px; }
        .bitem-icon       { font-size:18px; flex-shrink:0; margin-top:2px; }
        .bitem-title      { font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#777; margin-bottom:3px; }
        .bitem-body       { font-size:13px; color:#999; line-height:1.5; }
        .bitem-body strong{ color:#c4a44a; }
        .bitem-body a     { color:#c4a44a; }

        .exhibit-grid     { display:grid; grid-template-columns:repeat(auto-fill, minmax(180px, 1fr)); gap:16px; }
        .exhibit-tile     { background:#141414; border:1px solid rgba(196,164,74,0.12); border-radius:4px; overflow:hidden; transition:border-color 0.2s,transform 0.2s; }
        .exhibit-tile:hover { border-color:rgba(196,164,74,0.4); transform:translateY(-2px); }
        .exhibit-img-wrap { width:100%; height:120px; overflow:hidden; background:#0a0a0a; }
        .exhibit-thumb    { width:100%; height:120px; object-fit:cover; display:block; }
        .exhibit-no-img   { width:100%; height:120px; display:flex; align-items:center; justify-content:center; font-size:11px; color:#333; background:#111; }
        .exhibit-info     { padding:10px 12px; }
        .exhibit-cat      { font-size:10px; color:#c4a44a; text-transform:uppercase; letter-spacing:1px; margin-bottom:4px; }
        .exhibit-title    { font-size:13px; color:#e8e0d0; font-weight:600; line-height:1.4; margin-bottom:4px; }
        .exhibit-date     { font-size:11px; color:#444; }
    </style>

</asp:Content>
