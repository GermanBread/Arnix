function replaceTemporaryFields() {
    var ticker = document.getElementById("ticker");
    fetch('https://api.github.com/repos/GermanBread/Arnix/releases/latest')
        .then(function (res) {
        res.json().then(function (json) {
            ticker.innerHTML = ticker.innerHTML.replace("%s", json.tag_name.link(json.html_url));
        });
    })["catch"](function (err) { return console.error(err); });
    fetch('https://api.github.com/repos/GermanBread/Arnix/commits/master')
        .then(function (res) {
        res.json().then(function (json) {
            ticker.innerHTML = ticker.innerHTML.replace("%g", json.sha.link(json.html_url));
        });
    })["catch"](function (err) { return console.error(err); });
}
