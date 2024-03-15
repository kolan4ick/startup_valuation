// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

import "@rails/ujs";

import "bootstrap";

import "@fortawesome/fontawesome-free/js/all";

document.addEventListener("turbo:load", () => {
    document.documentElement.setAttribute('data-bs-theme', localStorage.getItem('data-bs-theme') || 'light');
});

document.querySelectorAll('[data-bs-theme-value]').forEach(function (el) {
    el.addEventListener('click', function (event) {
        event.preventDefault();
        let themeVal = el.getAttribute('data-bs-theme-value');
        handleThemeSwitching(themeVal);
    })
});

function handleThemeSwitching(theme) {
    document.documentElement.setAttribute('data-bs-theme', theme);
    localStorage.setItem('data-bs-theme', theme);
}

function changeMethod(element, type) {
    let method = element.value;

    const hideableTh = document.getElementsByClassName(`${type}-hideable-th`)[0];
    const hideableTd = document.getElementsByClassName(`${type}-hideable-td`);
    if (method === "0") {
        hideableTh.hidden = true;
        for (let i = 0; i < hideableTd.length; i++) {
            hideableTd[i].hidden = true;
        }
    } else {
        hideableTh.hidden = false;
        for (let i = 0; i < hideableTd.length; i++) {
            hideableTd[i].hidden = false;
        }
    }
}

window.changeMethod = changeMethod;