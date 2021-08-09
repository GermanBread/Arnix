var logoScroll : number = 60

function init() {
    window.addEventListener("scroll", handlescroll)
}

function handlescroll() {
    var element = document.getElementById("logo")
    element.style.opacity = ((logoScroll - window.scrollY) / logoScroll).toString()
}