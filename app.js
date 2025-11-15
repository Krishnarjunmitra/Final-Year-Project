
(function(){
  document.addEventListener('DOMContentLoaded', function(){
    buildTOC();
    initReadingProgress();
    initTOCDrawer();
    initColumnToggle();
  });

  function buildTOC(){
    const headings = document.querySelectorAll('.main-content h3');
    const toc = document.getElementById('toc-list');
    if(!toc) return;
    const anchorMap = new Map();
    headings.forEach(h => {
      const raw = h.textContent.trim();
      if(!/^\d+\./.test(raw)) return; // include only numbered sections
      const label = raw.replace(/^\d+\.\s*/, ''); // strip leading number to avoid double numbering
      const id = label.toLowerCase().replace(/[^a-z0-9]+/g,'-');
      h.id = id;
      const li = document.createElement('li');
      const a = document.createElement('a');
      a.href = '#' + id;
      a.textContent = label; // rely on <ol> to render numbering once
      li.appendChild(a);
      toc.appendChild(li);
      anchorMap.set(id, a);
    });
    initTOCHighlight(anchorMap);
  }

  function initTOCHighlight(anchorMap){
    if(!('IntersectionObserver' in window) || !anchorMap || anchorMap.size === 0) return;
    const options = { root:null, rootMargin:'0px 0px -60% 0px', threshold:0.2 };
    const clearActive = () => anchorMap.forEach(a => a.classList.remove('active'));
    const obs = new IntersectionObserver((entries)=>{
      entries.forEach(entry => {
        if(entry.isIntersecting){
          const id = entry.target.id;
          const link = anchorMap.get(id);
          if(link){ clearActive(); link.classList.add('active'); }
        }
      });
    }, options);
    anchorMap.forEach((_, id) => {
      const el = document.getElementById(id);
      if(el) obs.observe(el);
    });
  }

  window.downloadPDF = function(){
    const el = document.getElementById('report');
    if(!el){ console.error('Report container not found'); return; }
    html2pdf().set({
      margin:[15,15,15,15],
      filename:'final_year_project_report.pdf',
      image:{ type:'jpeg', quality:0.95 },
      html2canvas:{ scale:2, useCORS:true },
      jsPDF:{ unit:'mm', format:'a4', orientation:'portrait' }
    }).from(el).save();
  };

  window.triggerPrint = function(){
    window.print();
  };

  function initReadingProgress(){
    const bar = document.getElementById('readProgressBar');
    const label = document.getElementById('readProgressLabel');
    if(!bar || !label) return;
    const update = () => {
      const doc = document.documentElement;
      const scrollTop = doc.scrollTop || document.body.scrollTop || 0;
      const scrollHeight = doc.scrollHeight || 1;
      const clientHeight = doc.clientHeight || window.innerHeight || 1;
      const max = Math.max(scrollHeight - clientHeight, 1);
      const pct = Math.min(100, Math.max(0, Math.round((scrollTop / max) * 100)));
      bar.style.width = pct + '%';
      label.textContent = pct + '% • ' + (100 - pct) + '% left';
      label.setAttribute('aria-valuenow', String(pct));
    };
    ['scroll','resize','orientationchange'].forEach(evt => window.addEventListener(evt, update, {passive:true}));
    update();
  }

  function initTOCDrawer(){
    const drawer = document.getElementById('toc-drawer');
    const toggle = document.getElementById('toc-toggle');
    const closeBtn = document.getElementById('toc-close');
    if(!drawer || !toggle) return;
    const LARGE_BP = 1200;
    const closeDrawer = () => {
      drawer.classList.remove('open');
      drawer.setAttribute('aria-hidden','true');
      toggle.setAttribute('aria-expanded','false');
      document.body.classList.remove('toc-open');
    };
    const openDrawer = () => {
      drawer.classList.add('open');
      drawer.setAttribute('aria-hidden','false');
      toggle.setAttribute('aria-expanded','true');
      document.body.classList.add('toc-open');
    };
    toggle.addEventListener('click', () => {
      if(drawer.classList.contains('open')){ closeDrawer(); } else { openDrawer(); focusFirstLink(); }
    });
    if(closeBtn){
      closeBtn.addEventListener('click', () => {
        if(drawer.classList.contains('open')){ 
          closeDrawer(); 
          toggle.focus(); 
        }
      });
    }
    function focusFirstLink(){
      const first = drawer.querySelector('a');
      if(first) first.focus();
    }
    drawer.addEventListener('click', (e) => {
      if(e.target.tagName === 'A'){
        // Smooth scroll
        const href = e.target.getAttribute('href');
        if(href && href.startsWith('#')){
          e.preventDefault();
          const id = href.slice(1);
            const target = document.getElementById(id);
            if(target){
              target.scrollIntoView({behavior:'smooth', block:'start'});
            }
        }
        if(window.innerWidth < 768){
          closeDrawer();
        }
      }
    });
    document.addEventListener('keydown', (e) => {
      if(e.key === 'Escape' && drawer.classList.contains('open')){
        closeDrawer();
        toggle.focus();
      }
    });
  }

  function initColumnToggle(){
    const toggleBtn = document.getElementById('column-toggle');
    const mainContent = document.querySelector('.main-content');
    if(!toggleBtn || !mainContent) return;

    // Check localStorage for saved preference
    const savedMode = localStorage.getItem('columnMode');
    if(savedMode === 'single'){
      mainContent.classList.add('single-column');
      updateToggleIcon(toggleBtn, true);
    }

    toggleBtn.addEventListener('click', () => {
      const isSingleColumn = mainContent.classList.toggle('single-column');
      updateToggleIcon(toggleBtn, isSingleColumn);
      
      // Save preference
      localStorage.setItem('columnMode', isSingleColumn ? 'single' : 'double');
    });
  }

  function updateToggleIcon(btn, isSingleColumn){
    const svg = btn.querySelector('svg');
    if(!svg) return;

    if(isSingleColumn){
      // Single column icon - one wide rectangle
      svg.innerHTML = '<rect x="6" y="4" width="12" height="16" fill="none" stroke="currentColor" stroke-width="2"/>';
    } else {
      // Double column icon - two rectangles
      svg.innerHTML = '<rect x="3" y="4" width="8" height="16" fill="none" stroke="currentColor" stroke-width="2"/><rect x="13" y="4" width="8" height="16" fill="none" stroke="currentColor" stroke-width="2"/>';
    }
  }
})();
