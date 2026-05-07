// Please see documentation at https://docs.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// Dark mode toggle
(function () {
    var darkMode = localStorage.getItem('darkMode') === 'true';

    if (darkMode) {
        document.body.classList.add('dark-mode');
    }

    document.addEventListener('DOMContentLoaded', function () {
        var toggle = document.getElementById('dark-mode-toggle');
        var icon = document.getElementById('dark-mode-icon');

        function updateIcon() {
            if (!icon) return;
            if (document.body.classList.contains('dark-mode')) {
                icon.textContent = '🌙';
            } else {
                icon.textContent = '☀️';
            }
        }

        updateIcon();

        if (toggle) {
            toggle.addEventListener('click', function () {
                document.body.classList.toggle('dark-mode');
                var isDark = document.body.classList.contains('dark-mode');
                localStorage.setItem('darkMode', isDark);
                updateIcon();
            });
        }
    });
})();

document.addEventListener('DOMContentLoaded', function () {
    var searchInput = document.getElementById('product-search');
    var productCards = document.querySelectorAll('.product-card');
    var noProductsMessage = document.getElementById('no-products-message');

    if (searchInput) {
        searchInput.addEventListener('input', function () {
            var query = searchInput.value.toLowerCase();
            var visibleCount = 0;

            productCards.forEach(function (card) {
                var productName = card.getAttribute('data-product-name') || '';
                if (productName.includes(query)) {
                    card.classList.remove('d-none');
                    visibleCount++;
                } else {
                    card.classList.add('d-none');
                }
            });

            if (visibleCount === 0 && query.length > 0) {
                noProductsMessage.classList.remove('d-none');
            } else {
                noProductsMessage.classList.add('d-none');
            }
        });
    }
});
