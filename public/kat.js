var kat = {};

kat.search = function(query) {
    document.getElementById("status").innerHTML = "Waiting for kat.cr...";
    var req = new XMLHttpRequest();
    req.onreadystatechange = function() {
        var statusbar = document.getElementById("status");
        if (req.readyState == 4 && req.status == 200) {
            kat.render(JSON.parse(req.responseText));
            statusbar.innerHTML = '200';
        } else {
            statusbar.innerHTML = req.status + ' ' + req.responseText;
        }
        kat.focusQuery();
    }
    req.open("GET", query, true);
    req.send();
}

kat.render = function(hitlist) {
    var table = document.createElement('TABLE');
    table.appendChild(kat.tableheader(['', 'Seeds', 'Size', 'Title']));
    for (i = 0; i < hitlist.length; i++) {
        table.appendChild(kat.renderhit(hitlist[i]));
    }
    hits = document.getElementById("hits");
    while (hits.firstChild) { hits.removeChild(hits.firstChild) }
    hits.appendChild(table);
}

kat.tableheader = function(fields) {
    var header = document.createElement('TR');
    for (i = 0; i < fields.length; i++) {
        var h = document.createElement('TH');
        h.appendChild(document.createTextNode(fields[i]));
        header.appendChild(h);
    }
    return header;
}

kat.renderhit = function(hit) {
    var row = document.createElement('TR');

    var d0 = document.createElement('TD');
    var b = document.createElement('INPUT');
    b.type = 'button';
    b.value = '↷';
    b.title = 'start torrent';
    b.setAttribute('magnet', hit.magnet);
    b.onclick = kat.start;
    d0.appendChild(b);
    row.appendChild(d0);

    var d1 = document.createElement('TD');
    d1.appendChild(document.createTextNode(hit.seeds));
    d1.className = 'num';
    row.appendChild(d1);

    var d2 = document.createElement('TD');
    d2.appendChild(document.createTextNode(hit.size));
    d2.className = 'num';
    row.appendChild(d2);

    var d3 = document.createElement('TD');
    d3.appendChild(document.createTextNode(hit.title));
    row.appendChild(d3);

    return row;
}

kat.start = function() {
    document.getElementById("status").innerHTML = "Starting torrent...";
    var req = new XMLHttpRequest();
    req.onreadystatechange = function() {
        var statusbar = document.getElementById("status");
        if (req.readyState == 4 && req.status == 201) {
            statusbar.innerHTML = "201 Torrent started";
        } else {
            statusbar.innerHTML = req.status + ' ' + req.responseText;
        }
    }
    req.open("POST", 'start', true);
    req.setRequestHeader("Content-type","application/json");
    req.send(JSON.stringify({ magnet: this.getAttribute('magnet') }));
}

kat.focusQuery = function() {
    var queryfield = document.getElementById('query')
    queryfield.focus();
    queryfield.select();
}
