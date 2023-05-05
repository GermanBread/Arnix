var logoScroll = 60;
var logoElement;
function init() {
    var _a;
    logoElement = (_a = document.getElementById("logo")) !== null && _a !== void 0 ? _a : document.body; // Stop annoying me VSCode. This is to shut you up
    window.addEventListener("scroll", handlescroll);
}
function handlescroll() {
    logoElement.style.opacity = ((logoScroll - window.scrollY) / logoScroll).toString();
}
