var logoScroll : number = 60

function init() {
    window.addEventListener("scroll", handlescroll)
}

function handlescroll() {
    var element = document.getElementById("logo") ?? document.body // Stop annoying me VSCode. This is to shut you up
    element.style.opacity = ((logoScroll - window.scrollY) / logoScroll).toString()
}