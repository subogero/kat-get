kat = {};

kat.search = function(query) {
    document.getElementById("hits").innerHTML = "Waiting for kat.cr...";
    var req = new XMLHttpRequest();
    req.onreadystatechange = function() {
        if (req.readyState == 4 && req.status == 200) {
            kat.render(JSON.parse(req.responseText));
        } else {
            kat.err(req);
        }
    }
    req.open("GET", query, true);
    req.send();
}

kat.render = function(hitlist) {
    var table = document.createElement('TABLE');
    table.appendChild(kat.tableheader(['', 'Size', 'Seeds', 'Title']);
    for (i = 0; i < hitlist.length; i++) {
        table.appendChild(kat.renderhit(hitlist[i]));
    }
    document.getElementById("hits").innerHTML = table;
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
    var hit = document.createElement('TR');

    var h = document.createElement('TD');
    var b = document.createElement('BUTTON');
    b.onclick = kat.start(hit.magnet);
    h.appendChild(document.createTextNode(hit.magnet));
    hit.appendChild(h);

    return hit;
}

kat.err = function(req) {
    var txt = document.createTextNode(req.status + ' ' + req.responseText);
    document.getElementById("hits").innerHTML = txt;
}

kat.start = function(magnet) {
}
