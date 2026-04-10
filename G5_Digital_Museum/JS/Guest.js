// ============================================================
// DIGITAL MUSEUM: NANJING MASSACRE - Client-Side JavaScript
// Demonstrates: DOM manipulation, event handling, form validation
// ============================================================

document.addEventListener("DOMContentLoaded", function () {

    // ==================== MOBILE MENU TOGGLE ====================
    var menuToggle = document.getElementById('menuToggle');
    var primaryNav = document.getElementById('primaryNav');

    if (menuToggle && primaryNav) {
        menuToggle.addEventListener('click', function () {
            var isExpanded = menuToggle.getAttribute('aria-expanded') === 'true';
            menuToggle.setAttribute('aria-expanded', !isExpanded);
            primaryNav.classList.toggle('open');

            if (!isExpanded) {
                menuToggle.style.transform = 'rotate(90deg)';
            } else {
                menuToggle.style.transform = 'rotate(0deg)';
            }
        });

        document.addEventListener('click', function (e) {
            if (!menuToggle.contains(e.target) && !primaryNav.contains(e.target)) {
                primaryNav.classList.remove('open');
                menuToggle.setAttribute('aria-expanded', 'false');
                menuToggle.style.transform = 'rotate(0deg)';
            }
        });
    }

    // ==================== ACTIVE NAV HIGHLIGHT ====================
    var currentPage = window.location.pathname.split('/').pop().toLowerCase();
    var navLinks = document.querySelectorAll('.nav-list li a');

    navLinks.forEach(function (link) {
        var linkHref = link.getAttribute('href');
        if (linkHref) {
            var linkPage = linkHref.split('/').pop().toLowerCase();
            if (linkPage === currentPage) {
                link.classList.add('active');
            }
        }
    });

    // ==================== SMOOTH SCROLL FOR ANCHOR LINKS ====================
    var anchorLinks = document.querySelectorAll('a[href^="#"]');
    anchorLinks.forEach(function (link) {
        link.addEventListener('click', function (e) {
            var targetId = this.getAttribute('href').substring(1);
            var targetElement = document.getElementById(targetId);
            if (targetElement) {
                e.preventDefault();
                targetElement.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // ==================== HEADER SCROLL EFFECT ====================
    var header = document.querySelector('.site-header');
    if (header) {
        var lastScrollTop = 0;
        window.addEventListener('scroll', function () {
            var scrollTop = window.pageYOffset || document.documentElement.scrollTop;

            if (scrollTop > 50) {
                header.style.boxShadow = '0 4px 24px rgba(0, 0, 0, 0.5)';
            } else {
                header.style.boxShadow = 'none';
            }

            lastScrollTop = scrollTop;
        });
    }

    // ==================== FADE-IN ON SCROLL (Intersection Observer) ====================
    if ('IntersectionObserver' in window) {
        var observerOptions = {
            root: null,
            rootMargin: '0px 0px -80px 0px',
            threshold: 0.1
        };

        var fadeObserver = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                    fadeObserver.unobserve(entry.target);
                }
            });
        }, observerOptions);

        var elementsToAnimate = document.querySelectorAll('.section-header, .card, .flip-card, .feedback-entry, .info-box, .film-card, .book-flip-card');
        elementsToAnimate.forEach(function (el) {
            el.style.opacity = '0';
            el.style.transform = 'translateY(20px)';
            el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
            fadeObserver.observe(el);
        });
    }

    // ==================== STAT COUNTER ANIMATION ====================
    var statNumbers = document.querySelectorAll('.stat-number');
    if (statNumbers.length > 0 && 'IntersectionObserver' in window) {
        var statObserver = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    animateCounter(entry.target);
                    statObserver.unobserve(entry.target);
                }
            });
        }, { threshold: 0.5 });

        statNumbers.forEach(function (stat) {
            statObserver.observe(stat);
        });
    }

    function animateCounter(element) {
        var text = element.textContent.trim();
        var hasPlus = text.includes('+');
        var hasComma = text.includes(',');
        var numericValue = parseInt(text.replace(/[^0-9]/g, ''), 10);

        if (isNaN(numericValue) || numericValue === 0) return;

        var duration = 1500;
        var startTime = null;
        var startValue = 0;

        function step(timestamp) {
            if (!startTime) startTime = timestamp;
            var progress = Math.min((timestamp - startTime) / duration, 1);
            var currentValue = Math.floor(progress * numericValue);

            var displayValue = currentValue.toLocaleString();
            element.textContent = displayValue + (hasPlus ? '+' : '');

            if (progress < 1) {
                requestAnimationFrame(step);
            } else {
                element.textContent = text;
            }
        }

        requestAnimationFrame(step);
    }

    // ==================== FLIP CARD (Timeline & Books) ====================
    var flipCards = document.querySelectorAll('.flip-card, .book-flip-card');
    flipCards.forEach(function (card) {
        card.addEventListener('click', function (e) {
            // Don't flip if clicking a link
            if (e.target.tagName === 'A' || e.target.closest('a')) return;
            this.classList.toggle('flipped');
        });
    });

    // ==================== MODAL CLOSE ====================
    var modalOverlays = document.querySelectorAll('.modal-overlay');
    modalOverlays.forEach(function (overlay) {
        // Close on background click
        overlay.addEventListener('click', function (e) {
            if (e.target === overlay) {
                overlay.classList.remove('active');
            }
        });
        // Close button
        var closeBtn = overlay.querySelector('.modal-close');
        if (closeBtn) {
            closeBtn.addEventListener('click', function () {
                overlay.classList.remove('active');
            });
        }
    });

    console.log('Digital Museum: Nanjing Massacre - JavaScript loaded successfully.');
});


// ==================== GALLERY FILTER FUNCTION ====================
function filterGallery(category) {
    var items = document.querySelectorAll('.gallery-item');
    var buttons = document.querySelectorAll('.filter-btn');

    buttons.forEach(function (btn) {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');

    items.forEach(function (item) {
        if (category === 'all' || item.getAttribute('data-category') === category) {
            item.style.display = 'block';
            item.style.opacity = '0';
            setTimeout(function () {
                item.style.transition = 'opacity 0.4s ease';
                item.style.opacity = '1';
            }, 50);
        } else {
            item.style.opacity = '0';
            setTimeout(function () {
                item.style.display = 'none';
            }, 400);
        }
    });
}

// ==================== SHOW REGISTER MODAL ====================
function showRegisterModal() {
    var modal = document.getElementById('registerModal');
    if (modal) {
        modal.classList.add('active');
    }
    return false;
}

// ==================== STAR RATING ====================
document.addEventListener("DOMContentLoaded", function () {

    const stars = document.querySelectorAll(".star");
    const hiddenField = document.getElementById("hfRating");

    if (!stars.length || !hiddenField) return;

    stars.forEach(star => {

        star.style.fontSize = "42px";
        star.style.cursor = "pointer";
        star.style.color = "#444";

        star.addEventListener("click", function () {

            const value = parseInt(this.dataset.value);

            hiddenField.value = value;

            stars.forEach(s => s.style.color = "#444");

            for (let i = 0; i < value; i++) {
                stars[i].style.color = "#c4a44a";
            }

        });

        star.addEventListener("mouseover", function () {

            const value = parseInt(this.dataset.value);

            stars.forEach(s => s.style.color = "#444");

            for (let i = 0; i < value; i++) {
                stars[i].style.color = "#c4a44a";
            }

        });

        star.addEventListener("mouseout", function () {

            const selected = parseInt(hiddenField.value) || 0;

            stars.forEach(s => s.style.color = "#444");

            for (let i = 0; i < selected; i++) {
                stars[i].style.color = "#c4a44a";
            }

        });

    });

});
