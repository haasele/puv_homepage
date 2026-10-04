<script>
  import { onMount } from "svelte";
  import InstallPanel from "./InstallPanel.svelte";
  import ThemeToggle from "./ThemeToggle.svelte";

  onMount(() => {
    const node = document.querySelector(".aurora-background");
    const sync = () => node?.classList.toggle("is-paused", document.hidden);
    document.addEventListener("visibilitychange", sync);
    sync();
    return () => document.removeEventListener("visibilitychange", sync);
  });
</script>

<div class="haze">
  <div class="aurora-background aurora-animated" style="--opacity: 0.5" aria-hidden="true">
    <div class="aurora-layer aurora-1"></div>
    <div class="aurora-layer aurora-2"></div>
    <div class="aurora-layer aurora-3"></div>
  </div>

  <header class="haze-nav">
    <a class="brand" href="/">PUV</a>
    <nav>
      <a href="/" aria-current="page">Home</a>
      <a href="/wiki/install">Wiki</a>
      <a href="https://github.com/haasele/puv">GitHub</a>
      <ThemeToggle />
    </nav>
  </header>

  <main>
    <section class="landing-hero reveal">
      <div class="landing-hero__copy">
        <p class="landing-hero__eyebrow">puv.haasele.dev</p>
        <h1>PUV, the all-in-one tool for PHP.</h1>
        <p class="landing-hero__description">
          Manage your PHP runtime, packages and project with just one tool. PUV gives you the tooling,
          you always wanted for php!
        </p>
        <InstallPanel />
        <p class="landing-hero__note">Linux, macOS, and Windows · x86_64 and aarch64</p>
      </div>

      <figure class="landing-hero__visual">
        <span class="landing-hero__index">BASH</span>
        <pre class="landing-hero__tape"><span class="dim">$</span> puv init
<span class="dim">$</span> puv use 8.4
<span class="dim">$</span> puv add symfony/console
added symfony/console ^8.1
<span class="dim">$</span> puv add --dev phpunit/phpunit
added phpunit/phpunit ^13.4
<span class="dim">$</span> puv run src/main.php
Hello from app
<span class="dim">$</span> puv -c 'echo PHP_VERSION;'
8.4.23</pre>
      </figure>
    </section>

    <section class="features reveal" aria-label="What the binary does">
      <div class="feature-slot">
        <article class="glass-card feature-card">
          <div class="feature-card__top">
            <span class="feature-card__number">01</span>
            <span class="feature-card__glyph" aria-hidden="true">▹</span>
          </div>
          <h2>Runtime</h2>
          <p>
            <code>puv use 8.4</code> downloads a glibc CLI build if it is missing.
            <code>puv php list</code> shows the index. A required extension the runtime does not
            ship fails the lock, by name.
          </p>
        </article>
      </div>
      <div class="feature-slot">
        <article class="glass-card feature-card">
          <div class="feature-card__top">
            <span class="feature-card__number">02</span>
            <span class="feature-card__glyph" aria-hidden="true">▹</span>
          </div>
          <h2>Lock</h2>
          <p>
            <code>puv.lock</code> is TOML. <code>puv sync</code> restores that file and does not
            resolve again. A drifted manifest stops and tells you to run <code>puv lock</code>.
          </p>
        </article>
      </div>
      <div class="feature-slot">
        <article class="glass-card feature-card">
          <div class="feature-card__top">
            <span class="feature-card__number">03</span>
            <span class="feature-card__glyph" aria-hidden="true">▹</span>
          </div>
          <h2>Tools</h2>
          <p>
            <code>puv tool install phpstan/phpstan</code> gets its own environment.
            <code>puv load</code> does the same inside the project. They do not share a solver
            with the app.
          </p>
        </article>
      </div>
    </section>

    <section class="benefits">
      <div class="benefits__intro reveal">
        <p>Why it matters</p>
        <h2>What you stop juggling</h2>
      </div>
      <ol class="benefits__list">
        <li class="reveal">
          <span>01</span>
          <div>
            <h3>Pin a minor, lock the patch</h3>
            <p>
              A project pin in <code>puv.toml</code> names a minor line, <code>php = "8.4"</code>.
              The lockfile records the patch. <code>puv run</code> and <code>puv -c</code> use that
              runtime, with project dependencies already on the autoload path.
            </p>
          </div>
        </li>
        <li class="reveal">
          <span>02</span>
          <div>
            <h3>A caret, unless you say otherwise</h3>
            <p>
              <code>puv add</code> without a constraint writes a caret for the highest stable
              release. Pass one when you mean it: <code>puv add symfony/console:^7.0</code>.
            </p>
          </div>
        </li>
        <li class="reveal">
          <span>03</span>
          <div>
            <h3>The rest is written down</h3>
            <p>
              The walk is a <a href="/wiki/new-project">new project</a>. Each command has its own
              page, starting at the <a href="/wiki/commands">overview</a>.
            </p>
          </div>
        </li>
      </ol>
    </section>

    <section class="final-cta reveal">
      <div class="final-cta__panel">
        <span class="final-cta__mark" aria-hidden="true">✦</span>
        <p>Next</p>
        <h2>Got Corious? Read for yourself!</h2>
        <div class="final-cta__footer">
          <p>
            Look into the repo, install puv and test it for yourself!
          </p>
          <a class="btn btn--solid" href="/wiki/new-project">New project <span aria-hidden="true">↗</span></a>
        </div>
      </div>
    </section>
  </main>

  <footer class="haze-foot">
    <span>Linux, macOS, and Windows · x86_64 and aarch64</span>
    <a href="https://github.com/haasele/puv">github.com/haasele/puv</a>
  </footer>
</div>
