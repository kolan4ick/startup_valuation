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

function changeMethod(element) {
    let method = element.value;

    const multicriteriaHideableTh = document.getElementsByClassName("multicriteria-hideable-th")[0];
    const multicriteriaHideableTd = document.getElementsByClassName("multicriteria-hideable-td");
    if (method === "0") {
        multicriteriaHideableTh.hidden = true;
        for (let i = 0; i < multicriteriaHideableTd.length; i++) {
            multicriteriaHideableTd[i].hidden = true;
        }
    } else {
        multicriteriaHideableTh.hidden = false;
        for (let i = 0; i < multicriteriaHideableTd.length; i++) {
            multicriteriaHideableTd[i].hidden = false;
        }
    }
}

window.changeMethod = changeMethod;