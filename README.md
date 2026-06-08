
<style>
*{box-sizing:border-box;margin:0;padding:0}
.readme{font-family:var(--font-sans);background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-lg);overflow:hidden}
.header{background:#FBEAF0;padding:28px 28px 20px;border-bottom:0.5px solid #F4C0D1}
.header-top{display:flex;align-items:flex-start;gap:16px;margin-bottom:14px}
.avatar{width:56px;height:56px;background:#F4C0D1;border-radius:14px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.title-block{}
.proj-title{font-size:22px;font-weight:500;color:#72243E;line-height:1.2;margin-bottom:4px}
.proj-sub{font-size:14px;color:#993556}
.badges{display:flex;flex-wrap:wrap;gap:6px;margin-top:12px}
.badge{font-size:11px;font-weight:500;padding:3px 10px;border-radius:20px;display:inline-flex;align-items:center;gap:4px}
.b-pink{background:#F4C0D1;color:#72243E}
.b-teal{background:#9FE1CB;color:#085041}
.b-amber{background:#FAC775;color:#633806}
.b-purple{background:#CECBF6;color:#3C3489}
.b-coral{background:#F5C4B3;color:#712B13}
.hero{background:#FBEAF0;border:1.5px dashed #ED93B1;border-radius:10px;margin:0 28px;margin-top:-1px;height:160px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:8px;cursor:pointer;transition:background 0.15s}
.hero:hover{background:#F4C0D1}
.hero-label{font-size:13px;color:#993556;font-weight:500}
.hero-sub{font-size:12px;color:#D4537E}
.body{padding:24px 28px}
.section-title{font-size:12px;font-weight:500;color:var(--color-text-secondary);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:10px}
.desc-block{font-size:14px;color:var(--color-text-primary);line-height:1.7;background:var(--color-background-secondary);border-radius:var(--border-radius-md);padding:12px 14px;margin-bottom:20px;border-left:3px solid #ED93B1;border-radius:0}
.feature-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:10px;margin-bottom:20px}
.feature-card{background:var(--color-background-secondary);border-radius:var(--border-radius-md);padding:12px 14px;border:0.5px solid var(--color-border-tertiary)}
.feature-icon{font-size:18px;margin-bottom:6px}
.feature-name{font-size:13px;font-weight:500;color:var(--color-text-primary)}
.feature-desc{font-size:12px;color:var(--color-text-secondary);margin-top:2px}
.install-block{background:var(--color-background-secondary);border-radius:var(--border-radius-md);padding:12px 16px;font-family:var(--font-mono);font-size:13px;color:var(--color-text-primary);border:0.5px solid var(--color-border-tertiary);display:flex;align-items:center;justify-content:space-between;margin-bottom:20px}
.copy-btn{font-size:12px;color:var(--color-text-secondary);cursor:pointer;display:flex;align-items:center;gap:4px;border:0.5px solid var(--color-border-secondary);border-radius:6px;padding:4px 8px;background:var(--color-background-primary)}
.copy-btn:hover{background:var(--color-background-secondary)}
.screenshot-row{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:20px}
.ss-slot{background:var(--color-background-secondary);border:1.5px dashed var(--color-border-secondary);border-radius:var(--border-radius-md);height:90px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:4px;cursor:pointer}
.ss-slot:hover{background:#FBEAF0;border-color:#ED93B1}
.ss-label{font-size:12px;color:var(--color-text-secondary)}
.footer{border-top:0.5px solid var(--color-border-tertiary);padding:14px 28px;display:flex;align-items:center;justify-content:space-between}
.footer-left{font-size:12px;color:var(--color-text-secondary)}
.footer-right{display:flex;gap:8px}
.footer-link{font-size:12px;color:#D4537E;text-decoration:none;display:flex;align-items:center;gap:3px}
.divider{height:0.5px;background:var(--color-border-tertiary);margin:0 0 20px}
@media (prefers-color-scheme: dark) {
.header{background:#4B1528;border-bottom-color:#72243E}
.avatar{background:#72243E}
.proj-title{color:#F4C0D1}
.proj-sub{color:#ED93B1}
.b-pink{background:#72243E;color:#F4C0D1}
.b-teal{background:#085041;color:#9FE1CB}
.b-amber{background:#633806;color:#FAC775}
.b-purple{background:#3C3489;color:#CECBF6}
.b-coral{background:#712B13;color:#F5C4B3}
.hero{background:#4B1528;border-color:#993556}
.hero:hover{background:#72243E}
.hero-label{color:#F4C0D1}
.hero-sub{color:#ED93B1}
.desc-block{border-left-color:#993556}
.ss-slot:hover{background:#4B1528;border-color:#993556}
.footer-link{color:#ED93B1}
}
</style>

<h2 class="sr-only">ตัวอย่าง README น่ารัก Playful สำหรับโปรเจกต์โค้ด</h2>

<div style="padding:1rem 0">
<div class="readme">

  <div class="header">
    <div class="header-top">
      <div class="avatar">
        <i class="ti ti-code" style="font-size:26px;color:#993556" aria-hidden="true"></i>
      </div>
      <div class="title-block">
        <div class="proj-title">my-awesome-tool</div>
        <div class="proj-sub">A cute little dev tool that does cool stuff</div>
      </div>
    </div>
    <div class="badges">
      <span class="badge b-pink"><i class="ti ti-tag" style="font-size:11px" aria-hidden="true"></i>v1.0.0</span>
      <span class="badge b-teal"><i class="ti ti-check" style="font-size:11px" aria-hidden="true"></i>build passing</span>
      <span class="badge b-amber"><i class="ti ti-license" style="font-size:11px" aria-hidden="true"></i>MIT</span>
      <span class="badge b-purple"><i class="ti ti-brand-typescript" style="font-size:11px" aria-hidden="true"></i>TypeScript</span>
      <span class="badge b-coral"><i class="ti ti-star" style="font-size:11px" aria-hidden="true"></i>124 stars</span>
    </div>
  </div>

  <div style="padding:16px 28px 0">
    <div style="font-size:11px;font-weight:500;color:var(--color-text-secondary);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:8px">banner image</div>
    <div class="hero" onclick="this.innerHTML='<i class=\'ti ti-photo\' style=\'font-size:28px;color:#993556\'></i><span class=\'hero-label\'>image.png</span><span class=\'hero-sub\'>คลิกเปลี่ยนรูปได้</span>'">
      <i class="ti ti-photo-plus" style="font-size:28px;color:#993556" aria-hidden="true"></i>
      <span class="hero-label">วางรูป banner ที่นี่</span>
      <span class="hero-sub">![banner](images/banner.png)</span>
    </div>
  </div>

  <div class="body">

    <div class="section-title">about</div>
    <div class="desc-block">
      ✏️ ใส่คำอธิบายโปรเจกต์ตรงนี้ บอกว่าทำอะไร ใครใช้ได้ แก้ปัญหาอะไร
    </div>

    <div class="section-title">install</div>
    <div class="install-block">
      <span><span style="color:#D4537E">npm</span> install my-awesome-tool</span>
      <button class="copy-btn" onclick="navigator.clipboard.writeText('npm install my-awesome-tool');this.innerHTML='<i class=\'ti ti-check\' style=\'font-size:12px\'></i> copied'">
        <i class="ti ti-copy" style="font-size:12px" aria-hidden="true"></i> copy
      </button>
    </div>

    <div class="section-title">features</div>
    <div class="feature-grid">
      <div class="feature-card">
        <div class="feature-icon"><i class="ti ti-bolt" style="color:#D4537E;font-size:18px" aria-hidden="true"></i></div>
        <div class="feature-name">fast</div>
        <div class="feature-desc">blazing quick</div>
      </div>
      <div class="feature-card">
        <div class="feature-icon"><i class="ti ti-puzzle" style="color:#7F77DD;font-size:18px" aria-hidden="true"></i></div>
        <div class="feature-name">modular</div>
        <div class="feature-desc">plug & play</div>
      </div>
      <div class="feature-card">
        <div class="feature-icon"><i class="ti ti-heart" style="color:#D85A30;font-size:18px" aria-hidden="true"></i></div>
        <div class="feature-name">easy to use</div>
        <div class="feature-desc">zero config</div>
      </div>
      <div class="feature-card">
        <div class="feature-icon"><i class="ti ti-shield-check" style="color:#1D9E75;font-size:18px" aria-hidden="true"></i></div>
        <div class="feature-name">type-safe</div>
        <div class="feature-desc">full TypeScript</div>
      </div>
    </div>

    <div class="section-title">screenshots</div>
    <div class="screenshot-row">
      <div class="ss-slot">
        <i class="ti ti-photo-plus" style="font-size:20px;color:var(--color-text-secondary)" aria-hidden="true"></i>
        <span class="ss-label">screenshot 1</span>
      </div>
      <div class="ss-slot">
        <i class="ti ti-photo-plus" style="font-size:20px;color:var(--color-text-secondary)" aria-hidden="true"></i>
        <span class="ss-label">screenshot 2</span>
      </div>
    </div>

  </div>

  <div class="footer">
    <span class="footer-left">made with <i class="ti ti-heart" style="font-size:12px;color:#D4537E" aria-hidden="true"></i> by @yourname</span>
    <div class="footer-right">
      <a class="footer-link" href="#"><i class="ti ti-brand-github" style="font-size:12px" aria-hidden="true"></i> repo</a>
      <a class="footer-link" href="#"><i class="ti ti-book" style="font-size:12px" aria-hidden="true"></i> docs</a>
    </div>
  </div>

</div>
</div>
