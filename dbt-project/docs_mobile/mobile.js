// Adds the "Models" drawer button used by mobile.css on narrow screens.
(function () {
  function setup() {
    var frame = document.querySelector(".app-content .app-frame");
    if (!frame) {
      setTimeout(setup, 100);
      return;
    }
    if (document.querySelector(".mdl-menu-btn")) return;

    var button = document.createElement("button");
    button.type = "button";
    button.className = "mdl-menu-btn";
    button.setAttribute("aria-label", "Show the model list");
    button.setAttribute("aria-expanded", "false");
    button.innerHTML =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" ' +
      'stroke-linecap="round" aria-hidden="true"><path d="M4 6h16M4 12h16M4 18h16"/></svg>' +
      "<span>Models</span>";
    frame.insertBefore(button, frame.firstChild);

    // The backdrop must live inside .app: .app is position: fixed, which makes
    // it a stacking context, so a backdrop on <body> would cover the drawer.
    var backdrop = document.createElement("div");
    backdrop.className = "mdl-backdrop";
    frame.closest(".app").appendChild(backdrop);

    function setOpen(open) {
      document.body.classList.toggle("mdl-menu-open", open);
      button.setAttribute("aria-expanded", String(open));
    }

    button.addEventListener("click", function () {
      setOpen(!document.body.classList.contains("mdl-menu-open"));
    });
    backdrop.addEventListener("click", function () {
      setOpen(false);
    });
    // Picking a model changes the route (#!/model/...): close the drawer.
    window.addEventListener("hashchange", function () {
      setOpen(false);
    });
    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape") setOpen(false);
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", setup);
  } else {
    setup();
  }
})();
