var volume = 0.1;

function get_vol() {
  return volume;
}

function set_vol(num) {
  volume = num;
}

function clear_searchbar() {
  document.getElementsByName("search")[0].value = "";
}

function set_sidebar_width(size) {
  let r = document.querySelector(":root");
  r.style.setProperty("--sidebar-size", size + "px");
  r.style.setProperty("--topbar-pad-left", size + 15 + "px");
}

window.onload = function () {
  const toggleBtn = document.getElementById("toggleSidebar");
  const overlay = document.getElementById("overlay");

  document.getElementById("sidebar").classList.remove("is-active");

  toggleBtn.addEventListener("click", () => {
    const sidebar = document.getElementById("sidebar");

    const isActive = sidebar.classList.add("is-active");
    overlay.classList.add("is-active", isActive);
  });

  overlay.addEventListener("click", () => {
    const sidebar = document.getElementById("sidebar");

    sidebar.classList.remove("is-active");
    overlay.classList.remove("is-active");
  });

  function screenSizeChanged(e) {
    if (e.matches) {
      document.getElementById("sidebar").classList.remove("is-active");
      document.getElementById("overlay").classList.remove("is-active");
    }
  }

  const screenQuery = window.matchMedia("(max-width: 768px)");
  screenSizeChanged(screenQuery);
  screenQuery.addEventListener("change", screenSizeChanged);
};
