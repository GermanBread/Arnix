async function replaceTemporaryFields() {
    var ticker : HTMLElement = document.getElementById("ticker")!;

    const stabledata = await fetch('https://api.github.com/repos/GermanBread/Arnix/releases/latest')
    const stablejson = await stabledata.json();
    ticker.innerHTML = ticker.innerHTML.replace("%s", stablejson.tag_name.link(stablejson.html_url))

    const devdata = await fetch('https://api.github.com/repos/GermanBread/Arnix/commits/dev')
    const devjson = await devdata.json();
    ticker.innerHTML = ticker.innerHTML.replace("%g", devjson.sha.link(devjson.html_url))
}