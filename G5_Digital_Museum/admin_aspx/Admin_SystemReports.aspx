<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_SystemReports.aspx.cs" Inherits="G5_Digital_Museum.Admin_ASPX.Admin_SystemReports" MasterPageFile="~/Admin_ASPX/Admin_Master.Master" %>

<asp:Content ContentPlaceHolderID="PageTitle" runat="server">
    <h2 class="mb-0">SYSTEM REPORTS</h2>
    <div class="ms-auto d-flex gap-2">
        <button type="button" class="btn btn-sm btn-primary" onclick="printReports()">🖨️ Print Report</button>
        <button type="button" class="btn btn-sm btn-secondary" onclick="exportCSV()">📥 Export CSV</button>
    </div>
</asp:Content>


<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <asp:HiddenField ID="hdnRoleLabels"   runat="server" />
    <asp:HiddenField ID="hdnRoleData"     runat="server" />
    <asp:HiddenField ID="hdnCatLabels"    runat="server" />
    <asp:HiddenField ID="hdnCatData"      runat="server" />
    <asp:HiddenField ID="hdnPassed"       runat="server" />
    <asp:HiddenField ID="hdnFailed"       runat="server" />
    <asp:HiddenField ID="hdnStatusLabels" runat="server" />
    <asp:HiddenField ID="hdnStatusData"   runat="server" />
    <asp:HiddenField ID="hdnQuizLabels"   runat="server" />
    <asp:HiddenField ID="hdnQuizData"     runat="server" />
    <asp:HiddenField ID="hdnGrowthLabels" runat="server" />
    <asp:HiddenField ID="hdnGrowthData"   runat="server" />

    <%-- Row 1: Role (small) + Category (wide) --%>
    <div class="row mb-4">
        <div class="col-md-5 mb-4">
            <div class="card p-4 h-100 d-flex flex-column">
                <h5 class="chart-title">Users by Role</h5>
                <p class="chart-sub">Role distribution across all accounts</p>
                <div style="max-width:280px;margin:0 auto;width:100%;flex-shrink:0;">
                    <canvas id="chartRoles"></canvas>
                </div>
                <div class="desc-box mt-auto"><asp:Label ID="lblRoleDesc" runat="server" /></div>
            </div>
        </div>
        <div class="col-md-7 mb-4">
            <div class="card p-4 h-100 d-flex flex-column">
                <h5 class="chart-title">Exhibits by Category</h5>
                <p class="chart-sub">Distribution of museum exhibitions</p>
                <canvas id="chartCategories"></canvas>
                <div class="desc-box mt-3"><asp:Label ID="lblCatDesc" runat="server" /></div>
            </div>
        </div>
    </div>

    <%-- Row 2: Pass/Fail + Status + Top Quizzes --%>
    <div class="row mb-4">
        <div class="col-md-3 mb-4">
            <div class="card p-4 h-100 d-flex flex-column">
                <h5 class="chart-title">Quiz Pass vs Fail</h5>
                <p class="chart-sub">Overall quiz performance</p>
                <div style="max-width:220px;margin:0 auto;width:100%;flex-shrink:0;">
                    <canvas id="chartPassFail"></canvas>
                </div>
                <div class="desc-box mt-auto"><asp:Label ID="lblPassFailDesc" runat="server" /></div>
            </div>
        </div>
        <div class="col-md-3 mb-4">
            <div class="card p-4 h-100 d-flex flex-column">
                <h5 class="chart-title">Exhibits by Status</h5>
                <p class="chart-sub">Draft vs Published</p>
                <div style="max-width:220px;margin:0 auto;width:100%;flex-shrink:0;">
                    <canvas id="chartStatus"></canvas>
                </div>
                <div class="desc-box mt-auto"><asp:Label ID="lblStatusDesc" runat="server" /></div>
            </div>
        </div>
        <div class="col-md-6 mb-4">
            <div class="card p-4 h-100 d-flex flex-column">
                <h5 class="chart-title">Top 5 Quizzes</h5>
                <p class="chart-sub">Most attempted quizzes</p>
                <canvas id="chartTopQuizzes"></canvas>
                <div class="desc-box mt-auto"><asp:Label ID="lblQuizDesc" runat="server" /></div>
            </div>
        </div>
    </div>

    <%-- Row 3: User Growth --%>
    <div class="card p-4 mb-4">
        <h5 class="chart-title">User Growth Over Time</h5>
        <p class="chart-sub">New user registrations by month</p>
        <canvas id="chartGrowth"></canvas>
        <div class="desc-box mt-3">
            <asp:Label ID="lblGrowthDesc" runat="server" />
        </div>
    </div>

    <%-- Recent Attempts --%>
    <div class="card p-4 mb-4">
        <h5 class="chart-title mb-3">Recent Quiz Attempts</h5>
        <div class="table-responsive">
            <asp:GridView ID="gvRecentAttempts" runat="server" AutoGenerateColumns="False"
                CssClass="table table-hover align-middle mb-0" GridLines="None" BorderStyle="None">
                <Columns>
                    <asp:BoundField DataField="AttemptID"   HeaderText="ID" />
                    <asp:BoundField DataField="UserName"    HeaderText="User" />
                    <asp:BoundField DataField="QuizTitle"   HeaderText="Quiz" />
                    <asp:BoundField DataField="Score"       HeaderText="Score" />
                    <asp:BoundField DataField="Passed"      HeaderText="Passed" />
                    <asp:BoundField DataField="AttemptedAt" HeaderText="Date" DataFormatString="{0:dd/MM/yyyy}" />
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        var roleLabels = JSON.parse(document.getElementById('<%= hdnRoleLabels.ClientID %>').value || '[]');
        var roleData = JSON.parse(document.getElementById('<%= hdnRoleData.ClientID %>').value || '[]');
        var catLabels = JSON.parse(document.getElementById('<%= hdnCatLabels.ClientID %>').value || '[]');
        var catData = JSON.parse(document.getElementById('<%= hdnCatData.ClientID %>').value || '[]');
        var passed = parseInt(document.getElementById('<%= hdnPassed.ClientID %>').value || '0');
        var failed = parseInt(document.getElementById('<%= hdnFailed.ClientID %>').value         || '0');
        var statusLabels = JSON.parse(document.getElementById('<%= hdnStatusLabels.ClientID %>').value || '[]');
        var statusData   = JSON.parse(document.getElementById('<%= hdnStatusData.ClientID %>').value   || '[]');
        var quizLabels   = JSON.parse(document.getElementById('<%= hdnQuizLabels.ClientID %>').value   || '[]');
        var quizData     = JSON.parse(document.getElementById('<%= hdnQuizData.ClientID %>').value     || '[]');
        var growthLabels = JSON.parse(document.getElementById('<%= hdnGrowthLabels.ClientID %>').value || '[]');
        var growthData   = JSON.parse(document.getElementById('<%= hdnGrowthData.ClientID %>').value || '[]');

        var darkGrid = 'rgba(255,255,255,0.05)';
        var tickColor = '#999';

        new Chart(document.getElementById('chartRoles'), {
            type: 'doughnut',
            data: { labels: roleLabels, datasets: [{ data: roleData, backgroundColor: ['#e74c3c', '#3498db', '#2ecc71', '#f39c12'], borderColor: '#1e1e1e', borderWidth: 3 }] },
            options: { responsive: true, cutout: '60%', plugins: { legend: { position: 'bottom', labels: { color: tickColor, padding: 10, font: { size: 11 } } } } }
        });

        new Chart(document.getElementById('chartCategories'), {
            type: 'bar',
            data: { labels: catLabels, datasets: [{ label: 'Exhibits', data: catData, backgroundColor: '#c4a44a', borderRadius: 3 }] },
            options: { responsive: true, plugins: { legend: { display: false } }, scales: { x: { ticks: { color: tickColor }, grid: { color: darkGrid } }, y: { ticks: { color: tickColor }, grid: { color: darkGrid }, beginAtZero: true } } }
        });

        new Chart(document.getElementById('chartPassFail'), {
            type: 'doughnut',
            data: { labels: ['Pass', 'Fail'], datasets: [{ data: [passed, failed], backgroundColor: ['#2ecc71', '#8b1a1a'], borderColor: '#1e1e1e', borderWidth: 3 }] },
            options: { responsive: true, cutout: '60%', plugins: { legend: { position: 'bottom', labels: { color: tickColor, padding: 10, font: { size: 11 } } } } }
        });

        new Chart(document.getElementById('chartStatus'), {
            type: 'doughnut',
            data: { labels: statusLabels, datasets: [{ data: statusData, backgroundColor: ['#3498db', '#c4a44a'], borderColor: '#1e1e1e', borderWidth: 3 }] },
            options: { responsive: true, cutout: '60%', plugins: { legend: { position: 'bottom', labels: { color: tickColor, padding: 10, font: { size: 11 } } } } }
        });

        new Chart(document.getElementById('chartTopQuizzes'), {
            type: 'bar',
            data: { labels: quizLabels, datasets: [{ label: 'Attempts', data: quizData, backgroundColor: '#3498db', borderRadius: 3 }] },
            options: { indexAxis: 'y', responsive: true, plugins: { legend: { display: false } }, scales: { x: { ticks: { color: tickColor }, grid: { color: darkGrid }, beginAtZero: true }, y: { ticks: { color: tickColor }, grid: { display: false } } } }
        });

        new Chart(document.getElementById('chartGrowth'), {
            type: 'line',
            data: { labels: growthLabels, datasets: [{ label: 'New Users', data: growthData, borderColor: '#c4a44a', backgroundColor: 'rgba(196,164,74,0.1)', borderWidth: 2, pointBackgroundColor: '#c4a44a', fill: true, tension: 0.4 }] },
            options: { responsive: true, plugins: { legend: { display: false } }, scales: { x: { ticks: { color: tickColor }, grid: { color: darkGrid } }, y: { ticks: { color: tickColor }, grid: { color: darkGrid }, beginAtZero: true } } }
        });
    </script>

    <style>
        .chart-title { color: #c4a44a; font-size: 15px; margin-bottom: 2px; }
        .chart-sub   { font-size: 12px; color: #555; margin-bottom: 16px; }
        .desc-box    { background: rgba(196,164,74,0.06); border-left: 3px solid #c4a44a; padding: 10px 14px; border-radius: 2px; font-size: 13px; color: #aaa; line-height: 1.6; margin-top: 16px; }
        .desc-box strong { color: #c4a44a; }
    </style>
<asp:HiddenField ID="hdnExportData" runat="server" />

<script>
    function printReports() {
        window.print();
    }

    function exportCSV() {
        var raw = document.getElementById('<%= hdnExportData.ClientID %>').value;
        if (!raw) { alert('No data to export.'); return; }
        var blob = new Blob([raw], { type: 'text/csv;charset=utf-8;' });
        var url = URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.href = url;
        a.download = 'DigitalMuseum_Report_' + new Date().toISOString().slice(0, 10) + '.csv';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }
</script>

<style>
@media print {
    .topbar, .page-header, .admin-footer,
    button, .btn, [class*="notif-badge"] { display:none !important; }

    body, .admin-content { background:#fff !important; color:#000 !important; }

    .card { border:1px solid #ccc !important; background:#fff !important;
            break-inside:avoid; margin-bottom:16px; }

    .section-label { color:#333 !important; border-bottom:1px solid #ccc !important; }

    .chart-title { color:#000 !important; }
    .chart-sub   { color:#555 !important; }

    .desc-box { border-left:3px solid #c4a44a !important;
                background:#f9f9f9 !important; color:#333 !important; }
    .desc-box strong { color:#8b6914 !important; }

    canvas { max-height:220px !important; }

    @page { margin:15mm; size:A4; }

    h2 { color:#000 !important; font-size:18px !important; }
}
</style>
</asp:Content>