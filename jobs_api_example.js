// --------------------------------------
// Javascript example
// --------------------------------------
function callService(service, callback) {
    var url = 'https://services.onetcenter.org/ws/' + service;
    var separator = service.indexOf('?') !== -1 ? '&' : '?';
    url += separator + 'client=turbojobs';

    var xhr;
    if (window.XDomainRequest) {
        xhr = new XDomainRequest();
        xhr.onload = function() {
            var p = new window.DOMParser();
            callback(p.parseFromString(xhr.responseText,
                                       'text/xml'));
        };
    } else if (window.XMLHttpRequest) {
        xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState == 4 && xhr.status == 200)
                callback(xhr.responseXML);
        };
    }
    xhr.open('GET', url, true);
    xhr.send();
}
// https://services.onetcenter.org/ws/online/related_dwa/search?keyword=[phrase or code]
callService("online/search?keyword=architect", function (xml) { console.log(xml) });

callService("online/related_dwa/search?keyword=architect", function (xml) { debugger; console.log(xml) });


// --------------------------------------
// jQuery
// --------------------------------------
function callService(service, callback) {
    var url = 'https://services.onetcenter.org/ws/' + service;
    var separator = service.indexOf('?') !== -1 ? '&' : '?';
    url += separator + 'client=turbojobs';

    jQuery.ajax({ url: url, success: callback });
}

callService("online/search?keyword=architect", function (xml) { ... });

// https://services.onetcenter.org/ws/online/related_dwa/search?keyword=[phrase or code]

