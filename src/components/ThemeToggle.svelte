<script>
  import { onMount } from "svelte";

  let theme = $state("light");

  onMount(() => {
    theme = document.documentElement.dataset.theme === "dark" ? "dark" : "light";
  });

  function toggle() {
    theme = theme === "dark" ? "light" : "dark";
    const root = document.documentElement;
    root.dataset.theme = theme;
    root.style.colorScheme = theme;
    localStorage.setItem("puv-theme", theme);
    const docs = root.dataset.surface === "docs";
    const color = docs
      ? theme === "dark"
        ? "#1a1d27"
        : "#ffffff"
      : theme === "dark"
        ? "#101218"
        : "#f4f6fa";
    const meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.setAttribute("content", color);
  }
</script>

<button
  class="theme"
  type="button"
  aria-pressed={theme === "dark"}
  aria-label={theme === "dark" ? "Switch to light" : "Switch to dark"}
  onclick={toggle}
>
  {theme === "dark" ? "Light" : "Dark"}
</button>
