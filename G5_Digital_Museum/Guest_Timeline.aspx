<%@ Page Title="Timeline" Language="C#" MasterPageFile="~/GuestSite.Master" AutoEventWireup="true" CodeBehind="Guest_Timeline.aspx.cs" Inherits="G5_Digital_Museum.Guest_Timeline" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style type="text/css">
    .stl-wrap { padding: 40px 0; position: relative; }

    /* === ROW === */
    .stl-row {
        position: relative;
        display: flex;
        align-items: center;
        padding: 170px 20px;
    }
    .stl-row.rev { flex-direction: row-reverse; }

    /* Horizontal line — full width */
    .stl-row .stl-line {
        position: absolute;
        top: 50%;
        left: 0; right: 0;
        height: 3px;
        background: #333;
        z-index: 0;
        transform: translateY(-50%);
    }
    /* Arrow head on the leading end */
    .stl-row .stl-line::after {
        content: '';
        position: absolute;
        top: -5px;
        border: 6px solid transparent;
    }
    .stl-row:not(.rev) .stl-line::after { right: -1px; border-left: 10px solid #c4a44a; }
    .stl-row.rev .stl-line::after { left: -1px; border-right: 10px solid #c4a44a; }

    /* Vertical tail going DOWN from row's line to bottom edge (for rows that connect downward-right) */
    .stl-row.tail-br::after {
        content: '';
        position: absolute;
        right: 0;
        top: 50%;
        bottom: 0;
        width: 3px;
        background: #333;
        z-index: 0;
    }
    /* Vertical tail going DOWN from row's line to bottom edge (left side) */
    .stl-row.tail-bl::after {
        content: '';
        position: absolute;
        left: 0;
        top: 50%;
        bottom: 0;
        width: 3px;
        background: #333;
        z-index: 0;
    }
    /* Vertical tail going UP from top edge to row's line (right side) */
    .stl-row.tail-tr::before {
        content: '';
        position: absolute;
        right: 0;
        top: 0;
        height: 50%;
        width: 3px;
        background: #333;
        z-index: 0;
    }
    /* Vertical tail going UP from top edge to row's line (left side) */
    .stl-row.tail-tl::before {
        content: '';
        position: absolute;
        left: 0;
        top: 0;
        height: 50%;
        width: 3px;
        background: #333;
        z-index: 0;
    }

    /* === EVENT NODE === */
    .stl-node {
        position: relative;
        z-index: 2;
        flex: 1;
        display: flex;
        flex-direction: column;
        align-items: center;
    }
    .stl-dot {
        width: 14px; height: 14px;
        background: #c4a44a;
        border-radius: 50%;
        border: 3px solid #0a0a0a;
        flex-shrink: 0;
        z-index: 3;
    }
    .stl-date {
        font-family: 'Source Sans Pro', sans-serif;
        font-size: 0.78rem;
        color: #c4a44a;
        letter-spacing: 1.5px;
        white-space: nowrap;
        margin: 6px 0;
        font-weight: 600;
    }

    /* === IMAGE CARD === */
    .stl-card {
        width: 230px; height: 165px;
        border-radius: 6px;
        overflow: hidden;
        cursor: pointer;
        position: relative;
        border: 1px solid #2a2a2a;
        transition: transform 0.3s, border-color 0.3s, box-shadow 0.3s;
    }
    .stl-card:hover { transform: scale(1.05); border-color: #c4a44a; box-shadow: 0 4px 20px rgba(196,164,74,0.2); }
    .stl-card img { width: 100%; height: 100%; object-fit: cover; transition: filter 0.4s, opacity 0.4s; }
    .stl-card.active img { filter: blur(4px) brightness(0.2); opacity: 0.4; }

    /* Overlay text */
    .stl-overlay {
        position: absolute; inset: 0;
        display: flex; flex-direction: column; justify-content: center;
        padding: 16px;
        opacity: 0;
        transition: opacity 0.4s;
        pointer-events: none;
        z-index: 5;
    }
    .stl-card.active .stl-overlay { opacity: 1; }
    .stl-overlay h4 { font-family: 'Playfair Display', serif; font-size: 0.85rem; color: #c4a44a; margin-bottom: 6px; line-height: 1.3; }
    .stl-overlay p { font-size: 0.7rem; color: #ddd; line-height: 1.5; }

    /* Above / below */
    .stl-node.above .stl-card { order: -2; margin-bottom: 8px; }
    .stl-node.above .stl-date { order: -1; }
    .stl-node.below .stl-card { order: 2; margin-top: 8px; }
    .stl-node.below .stl-date { order: 1; }

    /* Highlight */
    .stl-card.hl { border: 2px solid #8b1a1a; box-shadow: 0 0 24px rgba(139,26,26,0.5); }

    /* === RESPONSIVE === */
    @media (max-width: 960px) {
        .stl-row, .stl-row.rev { flex-direction: column !important; padding: 50px 10px; }
        .stl-row .stl-line { top: 0; bottom: 0; left: 50%; right: auto; width: 3px; height: auto; transform: none; }
        .stl-row::before, .stl-row::after { display: none !important; }
        .stl-node { margin: 16px 0; }
        .stl-node.above .stl-card, .stl-node.below .stl-card { order: 0; margin: 8px 0; }
        .stl-card { width: 270px; height: 190px; }
    }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="content-page">
    <div class="page-hero">
        <div class="container">
            <span class="section-label">Interactive Exhibit</span>
            <h1>Historical Timeline</h1>
            <p>Trace the chronological events of the Nanjing Massacre. Click each image to reveal the event summary.</p>
        </div>
    </div>

    <section class="section">
        <div class="container">
            <p style="text-align:center;color:#999;font-size:24px;max-width:700px;margin:0 auto 40px;">Source: The Memorial Hall of the Victims in Nanjing Massacre by Japanese Invaders</p>

            <div class="stl-wrap">

                <!-- ROW 1: L->R | tail down-right to connect to Row 2 -->
                <div class="stl-row tail-br">
                    <div class="stl-line"></div>
                    <div class="stl-node above" onclick="toggleCard(this)">
                        <div class="stl-card"><img src="image/MarcoPoloBridge.jpg" alt="Marco Polo Bridge"/><div class="stl-overlay"><h4>Marco Polo Bridge Incident</h4><p>A confrontation near Beijing marks the start of full-scale war between Japan and China.</p></div></div>
                        <span class="stl-date">Jul 1937</span><div class="stl-dot"></div>
                    </div>
                    <div class="stl-node below" onclick="toggleCard(this)">
                        <div class="stl-dot"></div><span class="stl-date">Aug 1937</span>
                        <div class="stl-card"><img src="image/BattleofShanghai.jpg" alt="Battle of Shanghai"/><div class="stl-overlay"><h4>Battle of Shanghai Begins</h4><p>A fierce three-month battle with heavy casualties on both sides.</p></div></div>
                    </div>
                    <div class="stl-node above" onclick="toggleCard(this)">
                        <div class="stl-card"><img src="image/ShanghaiFalls.jpg" alt="Shanghai Falls"/><div class="stl-overlay"><h4>Shanghai Falls</h4><p>Shanghai falls to Japanese forces. The army advances toward Nanjing.</p></div></div>
                        <span class="stl-date">Nov 1937</span><div class="stl-dot"></div>
                    </div>
                    <div class="stl-node below" onclick="toggleCard(this)">
                        <div class="stl-dot"></div><span class="stl-date">Nov 22, 1937</span>
                        <div class="stl-card"><img src="image/NanjingSafetyZone.jpg" alt="Safety Zone"/><div class="stl-overlay"><h4>Safety Zone Established</h4><p>John Rabe and foreign nationals create a demilitarized zone to shelter civilians.</p></div></div>
                    </div>
                    <div class="stl-node above" onclick="toggleCard(this)">
                        <div class="stl-card"><img src="image/JapaneseForcesApproach.jpg" alt="Forces Approach"/><div class="stl-overlay"><h4>Forces Approach Nanjing</h4><p>Japan orders the capture of Nanjing. ~100,000 troops defend the city.</p></div></div>
                        <span class="stl-date">Dec 1, 1937</span><div class="stl-dot"></div>
                    </div>
                </div>

                <!-- ROW 2: R->L | tail top-right (from Row1) + tail down-left (to Row3) -->
                <div class="stl-row rev tail-tr tail-bl">
                    <div class="stl-line"></div>
                    <div class="stl-node below" onclick="toggleCard(this)">
                        <div class="stl-dot"></div><span class="stl-date">Dec 9, 1937</span>
                        <div class="stl-card"><img src="image/JapaneseDemandSurrender.jpg" alt="Demand Surrender"/><div class="stl-overlay"><h4>Demand Surrender</h4><p>Matsui demands surrender. Tang refuses. Bombardment intensifies.</p></div></div>
                    </div>
                    <div class="stl-node above" onclick="toggleCard(this)">
                        <div class="stl-card"><img src="image/ChineseForcesRetreat.jpg" alt="Chinese Retreat"/><div class="stl-overlay"><h4>Chinese Forces Retreat</h4><p>Chaotic withdrawal. Thousands trapped inside the city walls.</p></div></div>
                        <span class="stl-date">Dec 12, 1937</span><div class="stl-dot"></div>
                    </div>
                    <div class="stl-node below" onclick="toggleCard(this)">
                        <div class="stl-dot" style="background:#8b1a1a;width:18px;height:18px"></div>
                        <span class="stl-date" style="color:#8b1a1a;font-weight:700;font-size:.85rem">Dec 13, 1937</span>
                        <div class="stl-card hl"><img src="image/TheFallofNanjing.jpg" alt="Fall of Nanjing"/><div class="stl-overlay"><h4 style="color:#cd5c5c">The Fall of Nanjing</h4><p>The Massacre begins. Now observed as National Memorial Day in China.</p></div></div>
                    </div>
                    <div class="stl-node above" onclick="toggleCard(this)">
                        <div class="stl-card"><img src="image/SixWeeksofAtrocities.jpg" alt="Six Weeks"/><div class="stl-overlay"><h4>Six Weeks of Atrocities</h4><p>Mass executions, violence, arson. Safety Zone shelters ~250,000 refugees.</p></div></div>
                        <span class="stl-date">Dec&ndash;Jan 1938</span><div class="stl-dot"></div>
                    </div>
                </div>

                <!-- ROW 3: L->R | tail top-left (from Row2) -->
                <div class="stl-row tail-tl">
                    <div class="stl-line"></div>
                    <div class="stl-node above" onclick="toggleCard(this)">
                        <div class="stl-card"><img src="image/OrderRestored.jpg" alt="Order Restored"/><div class="stl-overlay"><h4>Order Restored</h4><p>Japanese authorities restore order. Safety Zone committee documents atrocities.</p></div></div>
                        <span class="stl-date">Feb 1938</span><div class="stl-dot"></div>
                    </div>
                    <div class="stl-node below" onclick="toggleCard(this)">
                        <div class="stl-dot"></div><span class="stl-date">1946&ndash;1948</span>
                        <div class="stl-card"><img src="image/TokyoWarCrimesTribunal.jpg" alt="Tokyo Tribunal"/><div class="stl-overlay"><h4>Tokyo War Crimes Tribunal</h4><p>IMTFE examines evidence. Matsui found guilty. 200,000+ estimated killed.</p></div></div>
                    </div>
                    <div class="stl-node above" onclick="toggleCard(this)">
                        <div class="stl-card"><img src="image/MemorialHall.jpg" alt="Memorial Hall"/><div class="stl-overlay"><h4>Memorial Hall Established</h4><p>Built on a mass grave site, opened 1985. Visited by millions annually.</p></div></div>
                        <span class="stl-date">Aug 1985</span><div class="stl-dot"></div>
                    </div>
                    <div class="stl-node below" onclick="toggleCard(this)">
                        <div class="stl-dot"></div><span class="stl-date">Dec 2014</span>
                        <div class="stl-card"><img src="image/NationalMemorialDay.jpg" alt="Memorial Day"/><div class="stl-overlay"><h4>National Memorial Day</h4><p>First national memorial ceremony on December 13, designated as Memorial Day.</p></div></div>
                    </div>
                </div>

            </div>
        </div>
    </section>

    <section class="section section-dark">
        <div class="container">
            <div class="section-header">
                <span class="section-label">From Our Database</span>
                <h2 class="section-title">Timeline Records</h2>
                <p class="section-subtitle">Additional timeline events stored in the museum database.</p>
                <div class="section-divider"></div>
            </div>
            <asp:GridView ID="gvTimelineEvents" runat="server" AutoGenerateColumns="false"
                CssClass="gridview-style" GridLines="None" EmptyDataText="No additional timeline events found."
                style="width:100%;max-width:900px;margin:0 auto;">
                <Columns>
                    <asp:BoundField DataField="EventDate" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" />
                    <asp:BoundField DataField="EventTitle" HeaderText="Event" />
                    <asp:BoundField DataField="EventDescription" HeaderText="Description" />
                    <asp:BoundField DataField="Source" HeaderText="Source" />
                </Columns>
            </asp:GridView>
            <asp:Label ID="lblTimelineMsg" runat="server" Visible="false"
                style="display:block;text-align:center;color:#555;padding:32px;font-size:24px;"></asp:Label>
        </div>
    </section>
</div>

<script type="text/javascript">
    function toggleCard(node) {
        var card = node.querySelector('.stl-card');
        if (card) card.classList.toggle('active');
    }
</script>
</asp:Content>
