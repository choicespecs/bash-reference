// Site-wide search: each topic is its own page, so the search box lists matching pages.
(function () {
  var input = document.getElementById('search');
  if (!input || !window.SEARCH_INDEX) return;
  var host = input.closest('.search');
  if (!host) {
    host = document.createElement('div');
    host.style.cssText = 'position:relative;flex:1;max-width:420px;display:flex;min-width:0';
    input.parentNode.insertBefore(host, input);
    host.appendChild(input);
    input.style.maxWidth = 'none';
    input.style.width = '100%';
  } else {
    host.style.position = 'relative';
  }
  input.setAttribute('placeholder', 'Search all pages… (press / )');
  input.setAttribute('aria-label', 'Search all pages');
  var box = document.createElement('div');
  box.className = 'search-results';
  box.hidden = true;
  host.appendChild(box);
  var sel = 0, results = [];
  function esc(s) { return s.replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }
  function snippet(text, q) {
    var i = text.indexOf(q);
    if (i < 0) return '';
    var s = Math.max(0, i - 50);
    return (s ? '…' : '') + text.slice(s, i + q.length + 80) + '…';
  }
  function paint() {
    box.querySelectorAll('a').forEach(function (a, i) { a.classList.toggle('sel', i === sel); });
  }
  function run() {
    var q = input.value.trim().toLowerCase();
    if (!q) { box.hidden = true; return; }
    var terms = q.split(/\s+/);
    results = window.SEARCH_INDEX.map(function (p) {
      var t = p.title.toLowerCase(), score = 0;
      for (var k = 0; k < terms.length; k++) {
        var w = terms[k];
        if (t.indexOf(w) >= 0) score += 10;
        else if (p.text.indexOf(w) >= 0) score += 1 + Math.min(4, p.text.split(w).length - 1) / 2;
        else return null;
      }
      return { p: p, score: score };
    }).filter(Boolean).sort(function (a, b) { return b.score - a.score; }).slice(0, 12);
    sel = 0;
    box.innerHTML = results.length
      ? results.map(function (r) {
          return '<a href="' + r.p.url + '"><b>' + esc(r.p.title) + '</b><span>' + esc(snippet(r.p.text, terms[0])) + '</span></a>';
        }).join('')
      : '<div class="none">No pages match.</div>';
    box.hidden = false;
    paint();
  }
  input.addEventListener('input', run);
  input.addEventListener('focus', run);
  input.addEventListener('keydown', function (e) {
    if (e.key === 'ArrowDown') { e.preventDefault(); sel = Math.min(sel + 1, results.length - 1); paint(); }
    else if (e.key === 'ArrowUp') { e.preventDefault(); sel = Math.max(sel - 1, 0); paint(); }
    else if (e.key === 'Enter' && results[sel]) { location.href = results[sel].p.url; }
    else if (e.key === 'Escape') { input.value = ''; box.hidden = true; input.blur(); }
  });
  document.addEventListener('click', function (e) { if (!host.contains(e.target)) box.hidden = true; });
  document.addEventListener('keydown', function (e) {
    if (e.key === '/' && document.activeElement !== input && !/INPUT|TEXTAREA/.test(document.activeElement.tagName)) { e.preventDefault(); input.focus(); }
  });
})();
