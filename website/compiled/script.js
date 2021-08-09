var logoScroll = 60;
function init() {
    window.addEventListener("scroll", handlescroll);
}
function handlescroll() {
    var _a;
    var element = (_a = document.getElementById("logo")) !== null && _a !== void 0 ? _a : document.body; // Stop annoying me VSCode. This is to shut you up
    element.style.opacity = ((logoScroll - window.scrollY) / logoScroll).toString();
}
