function replaceTemporaryFields() {
    var ticker : HTMLElement = document.getElementById("ticker") ?? document.body // see script.ts

    fetch('https://api.github.com/repos/GermanBread/Arnix/releases/latest')
        .then((res) => {
            res.json().then((json) => {
                ticker.innerHTML = ticker.innerHTML.replace("%s", json.tag_name.link(json.html_url))
            })
        })
        .catch((err) => console.error(err))
    fetch('https://api.github.com/repos/GermanBread/Arnix/commits/master')
        .then((res) => {
            res.json().then((json) => {
                ticker.innerHTML = ticker.innerHTML.replace("%g", json.sha.link(json.html_url))
            })
        })
        .catch((err) => console.error(err))
}