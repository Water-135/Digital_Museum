<%@ Page Title="Gallery" Language="C#" MasterPageFile="~/GuestSite.Master" AutoEventWireup="true" CodeBehind="Guest_Gallery.aspx.cs" Inherits="G5_Digital_Museum.Guest_Gallery" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style type="text/css">
/* ===== BOOK GALLERY ===== */
.book-gallery-wrap{max-width:900px;margin:0 auto;padding:40px 0}
.book-container{position:relative;width:100%;aspect-ratio:4/3;background:#1a1614;border-radius:8px;border:1px solid #2a2a2a;overflow:hidden;box-shadow:0 8px 40px rgba(0,0,0,.6)}
/* Spine */
.book-container::before{content:'';position:absolute;left:50%;top:0;bottom:0;width:4px;background:linear-gradient(to bottom,#2a2218,#3a3228,#2a2218);z-index:10;transform:translateX(-50%)}
/* Pages */
.book-page{position:absolute;inset:0;display:flex;transition:opacity .5s ease}
.book-page.hidden{opacity:0;pointer-events:none}
.book-page-left,.book-page-right{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:28px 24px;position:relative}
.book-page-left{background:#161412;border-right:1px solid #222}
.book-page-right{background:#1a1816}
/* Image display */
.book-img-display{width:100%;max-height:70%;object-fit:contain;border-radius:4px;border:1px solid #2a2a2a;cursor:pointer;transition:transform .3s}
.book-img-display:hover{transform:scale(1.02)}
.book-subtitle{font-family:'Playfair Display',serif;font-size:1rem;color:#c4a44a;margin-top:14px;text-align:center;line-height:1.4}
.book-desc{font-size:.82rem;color:#999;text-align:center;margin-top:8px;line-height:1.6;max-width:320px}
/* Page number */
.book-pagenum{position:absolute;bottom:12px;font-size:.7rem;color:#555;letter-spacing:1px}
.book-page-left .book-pagenum{left:20px}
.book-page-right .book-pagenum{right:20px}
/* Navigation arrows */
.book-nav{position:absolute;top:50%;transform:translateY(-50%);z-index:20;background:rgba(196,164,74,.15);border:1px solid rgba(196,164,74,.3);color:#c4a44a;width:40px;height:40px;border-radius:50%;cursor:pointer;font-size:18px;display:flex;align-items:center;justify-content:center;transition:background .3s}
.book-nav:hover{background:rgba(196,164,74,.3)}
.book-nav.prev{left:8px}
.book-nav.next{right:8px}
.book-nav:disabled{opacity:.3;cursor:default}
/* Thumbnail strip */
.thumb-strip{display:flex;gap:8px;justify-content:center;flex-wrap:wrap;margin-top:24px;padding:16px;background:#151515;border-radius:6px;border:1px solid #222}
.thumb-item{width:80px;height:56px;border-radius:4px;overflow:hidden;cursor:pointer;border:2px solid transparent;transition:border-color .3s,transform .3s;opacity:.7;flex-shrink:0}
.thumb-item:hover,.thumb-item.active{border-color:#c4a44a;opacity:1;transform:scale(1.08)}
.thumb-item img{width:100%;height:100%;object-fit:cover}
/* Page indicator */
.page-indicator{text-align:center;margin-top:12px;font-size:.75rem;color:#666;letter-spacing:1px}
@media(max-width:640px){
    .book-container{aspect-ratio:3/4}
    .book-page{flex-direction:column}
    .book-page-left,.book-page-right{padding:16px 12px}
    .book-container::before{display:none}
    .book-subtitle{font-size:.85rem}
    .thumb-item{width:60px;height:42px}
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="content-page">
    <div class="page-hero">
        <div class="container">
            <span class="section-label">Visual Archive</span>
            <h1>Gallery &amp; Exhibition</h1>
            <p>Historical photographs bearing witness to the events of December 1937. Source: The Memorial Hall of the Victims in Nanjing Massacre by Japanese Invaders.</p>
        </div>
    </div>

    <div class="memorial-ribbon" style="background:#2a2a2a;border-bottom:1px solid rgba(139,26,26,.3);">
        &#9888; <strong>Content Advisory:</strong> Some materials depict the aftermath of wartime atrocities. All images are presented for educational purposes.
    </div>

    <section class="section">
        <div class="container">
            <div class="section-header">
                <span class="section-label">Documentary Gallery</span>
                <h2 class="section-title">Historical Photo Book</h2>
                <p class="section-subtitle">Browse through pages of historical photographs. Click thumbnails below to jump to any image.</p>
                <div class="section-divider"></div>
            </div>

            <div class="book-gallery-wrap">
                <!-- Book -->
                <div class="book-container" id="bookContainer">
                    <button type="button" class="book-nav prev" id="btnPrev" onclick="bookPrev()">&#x25C0;</button>
                    <button type="button" class="book-nav next" id="btnNext" onclick="bookNext()">&#x25B6;</button>
                    <div id="bookPages"></div>
                </div>

                <!-- Page indicator -->
                <div class="page-indicator" id="pageIndicator">Page 1 of 5</div>

                <!-- Thumbnail strip -->
                <div class="thumb-strip" id="thumbStrip"></div>
            </div>
        </div>
    </section>

    <!-- Database Exhibition -->
    <section class="section section-dark">
        <div class="container">
            <div class="section-header">
                <span class="section-label">Section 2</span>
                <h2 class="section-title">Curated Exhibition</h2>
                <p class="section-subtitle">Exhibits curated from our database collection.</p>
                <div class="section-divider"></div>
            </div>
            <asp:DataList ID="dlGallery" runat="server" RepeatColumns="3" RepeatDirection="Horizontal"
                CellSpacing="12" style="width:100%;">
                <ItemTemplate>
                    <div class="card" style="min-width:260px;">
                        <div class="card-image">
                            <asp:Image ID="imgGallery" runat="server"
                                ImageUrl='<%# Eval("ImagePath") %>'
                                AlternateText='<%# Eval("Title") %>'
                                onerror="this.style.display='none'" />
                            <div class="placeholder-icon" style="font-size:56px;color:#555;">&#x1F5BC;</div>
                        </div>
                        <div class="card-body">
                            <span class="card-category"><%# Eval("Category") %></span>
                            <h3 class="card-title"><%# Eval("Title") %></h3>
                            <p class="card-text"><%# Eval("Description") %></p>
                        </div>
                        <div class="card-footer">
                            <span><%# Eval("YearTaken") %></span>
                            <span><%# Eval("Source") %></span>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:DataList>
            <asp:Label ID="lblGalleryMsg" runat="server" Visible="false"
                style="display:block;text-align:center;color:#555;padding:32px;font-size:24px;"></asp:Label>
        </div>
    </section>

    <!-- About Materials -->
    <section class="section">
        <div class="container">
            <div style="background:#1e1e1e;border:1px solid rgba(196,164,74,.2);padding:24px;margin-top:60px;">
                <h3 style="color:#c4a44a;font-family:'Playfair Display',serif;font-size:1.4rem;margin-bottom:8px;">About These Materials</h3>
                <p style="color:#999;font-size:24px;line-height:1.7;">
                    The photographs featured in this gallery are sourced from The Memorial Hall of the Victims in Nanjing Massacre by Japanese Invaders (19371213.com.cn), historical archives, tribunal records, and personal collections of international residents who witnessed the events.
                </p>
            </div>
        </div>
    </section>
</div>

<script type="text/javascript">
var galleryData = [
    { img: "image/AtrocitiesRecordedinDiaries.jpg", title: "Atrocities Recorded in Diaries", desc: "Diary entries documenting the atrocities committed by Japanese invaders, 1937" },
    { img: "image/RevisitingtheNanjingSafetyZone.jpg", title: "Revisiting the Nanjing Safety Zone", desc: "Tracing the Path of Great Love through the Safety Zone established by international residents" },
    { img: "image/JohnRabeLegacy.jpg", title: "John Rabe\u2019s Legacy", desc: "The German businessman who led the International Safety Zone Committee" },
    { img: "image/MinnieVautrin.jpg", title: "Minnie Vautrin", desc: "American missionary who sheltered over 10,000 women and children at Ginling College" },
    { img: "image/PhotosTakenbyJapaneseSoldiers.png", title: "Photos Taken by Japanese Soldiers", desc: "Photographic evidence of the Nanjing Massacre captured by Japanese soldiers themselves" },
    { img: "image/TokyoTrialsEvidenceCollection.jpg", title: "Tokyo Trials Evidence Collection", desc: "Evidence collection process during the International Military Tribunal for the Far East" },
    { img: "image/MemorialHall.jpg", title: "The Memorial Hall, Nanjing", desc: "Built on the original site where remains of victims were found, opened August 15, 1985" },
    { img: "image/NationalMemorialDay.jpg", title: "A Moment of Eternity", desc: "National Memorial Day ceremony \u2014 annual commemoration held on December 13 since 2014" },
    { img: "image/SurvivorTestimonies.jpg", title: "Survivors\u2019 Eternal Memories", desc: "Testimonies from survivors who bore witness to history, preserved for future generations" }
];

var currentPage = 0;
var totalPages = Math.ceil(galleryData.length / 2);

function renderBook() {
    var container = document.getElementById('bookPages');
    var thumbs = document.getElementById('thumbStrip');
    container.innerHTML = '';
    thumbs.innerHTML = '';

    for (var p = 0; p < totalPages; p++) {
        var li = p * 2;
        var ri = p * 2 + 1;
        var left = galleryData[li];
        var right = ri < galleryData.length ? galleryData[ri] : null;

        var page = document.createElement('div');
        page.className = 'book-page' + (p !== currentPage ? ' hidden' : '');
        page.setAttribute('data-page', p);

        var lhtml = '<div class="book-page-left">';
        lhtml += '<img class="book-img-display" src="' + left.img + '" alt="' + left.title + '"/>';
        lhtml += '<div class="book-subtitle">' + left.title + '</div>';
        lhtml += '<div class="book-desc">' + left.desc + '</div>';
        lhtml += '<span class="book-pagenum">' + (li + 1) + '</span></div>';

        var rhtml = '<div class="book-page-right">';
        if (right) {
            rhtml += '<img class="book-img-display" src="' + right.img + '" alt="' + right.title + '"/>';
            rhtml += '<div class="book-subtitle">' + right.title + '</div>';
            rhtml += '<div class="book-desc">' + right.desc + '</div>';
            rhtml += '<span class="book-pagenum">' + (ri + 1) + '</span>';
        } else {
            rhtml += '<div style="color:#333;font-size:3rem;font-family:Playfair Display,serif;">&#x1F56F;</div>';
            rhtml += '<div class="book-subtitle" style="color:#555;">End of Gallery</div>';
        }
        rhtml += '</div>';

        page.innerHTML = lhtml + rhtml;
        container.appendChild(page);
    }

    // Thumbnails
    for (var i = 0; i < galleryData.length; i++) {
        var t = document.createElement('div');
        t.className = 'thumb-item' + (Math.floor(i / 2) === currentPage ? ' active' : '');
        t.setAttribute('data-index', i);
        t.innerHTML = '<img src="' + galleryData[i].img + '" alt="' + galleryData[i].title + '"/>';
        t.onclick = (function(idx) { return function() { goToImage(idx); }; })(i);
        thumbs.appendChild(t);
    }

    updateNav();
}

function updateNav() {
    document.getElementById('btnPrev').disabled = currentPage === 0;
    document.getElementById('btnNext').disabled = currentPage >= totalPages - 1;
    document.getElementById('pageIndicator').textContent = 'Page ' + (currentPage + 1) + ' of ' + totalPages;

    var pages = document.querySelectorAll('.book-page');
    for (var i = 0; i < pages.length; i++) {
        pages[i].classList.toggle('hidden', parseInt(pages[i].getAttribute('data-page')) !== currentPage);
    }
    var ts = document.querySelectorAll('.thumb-item');
    for (var i = 0; i < ts.length; i++) {
        ts[i].classList.toggle('active', Math.floor(parseInt(ts[i].getAttribute('data-index')) / 2) === currentPage);
    }
}

function bookPrev() { if (currentPage > 0) { currentPage--; updateNav(); } }
function bookNext() { if (currentPage < totalPages - 1) { currentPage++; updateNav(); } }
function goToImage(idx) { currentPage = Math.floor(idx / 2); updateNav(); }

window.addEventListener('load', renderBook);
</script>
</asp:Content>
