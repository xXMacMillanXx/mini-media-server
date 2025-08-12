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

async function changeContent(path) {
  const res = await fetch(`/content/${path}`);
  const html = await res.text();
  document.getElementById("content").innerHTML = html;
}

async function changeDirectory(path) {
  const res = await fetch(`/contentdirectory/${path}`);
  const html = await res.text();
  document.getElementById("sidebar").outerHTML = html;
}

async function updateSidebar(search) {
  if (search == "..") {
    return;
  }
  const res = await fetch(`/sidebarsearch/${search}`);
  const html = await res.text();
  document.getElementById("sidebar").outerHTML = html;
}

window.onload = function () {
  const toggleBtn = document.getElementById("toggleSidebar");
  const overlay = document.getElementById("overlay");

  document.getElementById("sidebar").classList.remove("is-active");

  toggleBtn.addEventListener("click", () => {
    const sidebar = document.getElementById("sidebar");

    const isActive = sidebar.classList.toggle("is-active");
    overlay.classList.toggle("is-active", isActive);
  });

  overlay.addEventListener("click", () => {
    const sidebar = document.getElementById("sidebar");

    sidebar.classList.remove("is-active");
    overlay.classList.remove("is-active");
  });
};
