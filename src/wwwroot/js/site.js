// Please see documentation at https://docs.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

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
