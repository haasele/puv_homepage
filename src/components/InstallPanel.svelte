<script>
  import { onMount } from "svelte";

  const unix = "curl -fsSL https://raw.githubusercontent.com/haasele/puv/main/install.sh | sh";
  const windows = "irm https://raw.githubusercontent.com/haasele/puv/main/install.ps1 | iex";
  const releaseUrl = "https://api.github.com/repos/haasele/puv/releases/latest";

  /** @type {"unix" | "windows"} */
  let tab = $state("unix");
  /** @type {"" | "unix" | "windows"} */
  let copied = $state("");
  let copyError = $state("");
  /** @type {"loading" | "ready" | "empty" | "error"} */
  let status = $state("loading");
  /** @type {null | { tag_name: string, html_url: string, published_at: string, assets: { name: string, browser_download_url: string, size: number }[] }} */
  let release = $state(null);

  /** @type {{ id: "unix" | "windows", label: string, command: string }[]} */
  const tabs = [
    { id: "unix", label: "Linux/macOS", command: unix },
    { id: "windows", label: "Windows", command: windows },
  ];

  let command = $derived(tabs.find((item) => item.id === tab)?.command ?? unix);

  onMount(async () => {
    if (/Win/i.test(navigator.platform) || /Windows/i.test(navigator.userAgent)) tab = "windows";
    try {
      const response = await fetch(releaseUrl, {
        headers: { Accept: "application/vnd.github+json" },
      });
      if (response.status === 404) {
        status = "empty";
        return;
      }
      if (!response.ok) {
        status = "error";
        return;
      }
      release = await response.json();
      status = "ready";
    } catch {
      status = "error";
    }
  });

  /**
   * @param {"unix" | "windows"} id
   * @param {string} command
   */
  async function copy(id, command) {
    copyError = "";
    try {
      await navigator.clipboard.writeText(command);
      copied = id;
      window.setTimeout(() => {
        if (copied === id) copied = "";
      }, 1600);
    } catch {
      copyError = "Clipboard is blocked. Select the command.";
    }
  }

  function when(iso) {
    return new Date(iso).toLocaleDateString("en-GB", {
      day: "numeric",
      month: "short",
      year: "numeric",
    });
  }

  function size(bytes) {
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }

  /** @param {string} value */
  function segments(value) {
    const bits = value.split("/");
    return bits.map((bit, index) => ({ bit, slash: index < bits.length - 1 }));
  }

  /** @param {"unix" | "windows"} id */
  function select(id) {
    tab = id;
    copyError = "";
  }

  /** @param {KeyboardEvent} event */
  function onTabsKeydown(event) {
    const ids = tabs.map((item) => item.id);
    const index = ids.indexOf(tab);
    let next = index;
    if (event.key === "ArrowRight") next = (index + 1) % ids.length;
    else if (event.key === "ArrowLeft") next = (index - 1 + ids.length) % ids.length;
    else if (event.key === "Home") next = 0;
    else if (event.key === "End") next = ids.length - 1;
    else return;
    event.preventDefault();
    tab = ids[next];
    copyError = "";
    document.getElementById(`install-tab-${tab}`)?.focus();
  }
</script>

<div class="install" id="setup">
  <div class="install-switch">
    <div class="install-tabs" role="tablist" aria-label="Install platform" onkeydown={onTabsKeydown}>
      {#each tabs as item}
        <button
          class="install-tab"
          id="install-tab-{item.id}"
          type="button"
          role="tab"
          aria-selected={tab === item.id}
          aria-controls="install-panel"
          tabindex={tab === item.id ? 0 : -1}
          onclick={() => select(item.id)}
        >
          {item.label}
        </button>
      {/each}
    </div>
    <div class="command" id="install-panel" role="tabpanel" aria-labelledby="install-tab-{tab}">
      <code>{#each segments(command) as segment}{segment.bit}{#if segment.slash}/<wbr>{/if}{/each}</code>
      <button class="btn btn--solid" type="button" onclick={() => copy(tab, command)}>
        {copied === tab ? "Copied" : "Copy"}
      </button>
    </div>
  </div>
  {#if copyError}<p class="note">{copyError}</p>{/if}

  <div class="release">
    {#if status === "loading"}
      <p>Asking GitHub for the latest release…</p>
    {:else if status === "empty"}
      <p>
        No GitHub release is published yet. The commands above are already the install path: they
        stop with a source-build hint until an asset exists.
      </p>
    {:else if status === "error"}
      <p>
        The release list did not load from this browser. The commands still use
        <code>releases/latest/download</code>, which follows whatever GitHub marks as latest.
      </p>
    {:else if release}
      <p>
        Latest tag <a href={release.html_url}>{release.tag_name}</a>,
        {when(release.published_at)}.
      </p>
      {#if release.assets.length === 0}
        <p>That release has no files attached.</p>
      {:else}
        <ul>
          {#each release.assets as asset}
            <li>
              <a href={asset.browser_download_url}>{asset.name}</a>
              <span>{size(asset.size)}</span>
            </li>
          {/each}
        </ul>
      {/if}
    {/if}
  </div>
</div>
