<script>
  import { onMount } from "svelte";

  const command = "curl -fsSL https://puv.haasele.dev/install.sh | sh";
  const releaseUrl = "https://api.github.com/repos/haasele/puv/releases/latest";

  let copied = $state(false);
  let copyError = $state("");
  /** @type {"loading" | "ready" | "empty" | "error"} */
  let status = $state("loading");
  /** @type {null | { tag_name: string, html_url: string, published_at: string, assets: { name: string, browser_download_url: string, size: number }[] }} */
  let release = $state(null);

  onMount(async () => {
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

  async function copy() {
    copyError = "";
    try {
      await navigator.clipboard.writeText(command);
      copied = true;
      window.setTimeout(() => {
        copied = false;
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
</script>

<div class="install" id="setup">
  <div class="command">
    <code>{command}</code>
    <button class="btn btn--solid" type="button" onclick={copy}>{copied ? "Copied" : "Copy"}</button>
  </div>
  {#if copyError}<p class="note">{copyError}</p>{/if}

  <div class="release">
    {#if status === "loading"}
      <p>Asking GitHub for the latest release…</p>
    {:else if status === "empty"}
      <p>
        No GitHub release is published yet. The command above is already the install path: it
        stops with a source-build hint until an asset exists.
      </p>
    {:else if status === "error"}
      <p>
        The release list did not load from this browser. The command still uses
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
