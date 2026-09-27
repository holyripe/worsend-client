# Worsend Client Visuals

Fabric client mod for Minecraft 1.21.1 — deep-blue neon visual modules:
Sky Changer, Kill Effect, Hit Effect, Target Highlight, and the shared
particle framework they all render through.

## Project layout

```
worsend-client/
├── build.gradle                   # Fabric Loom build, wired for 1.21.1
├── gradle.properties              # MC / Yarn / Loader / Fabric API versions
├── settings.gradle
├── gradlew / gradlew.bat          # Gradle wrapper scripts (see note below)
├── LICENSE
└── src/main/
    ├── java/com/worsend/client/
    │   ├── WorsendClient.java             # ClientModInitializer — wires everything to Fabric's event bus
    │   ├── module/
    │   │   ├── Module.java                # Base class every module extends
    │   │   ├── ModuleCategory.java
    │   │   ├── ModuleManager.java         # Owns one instance of each module
    │   │   └── render/
    │   │       ├── SkyChangerModule.java
    │   │       ├── KillEffectModule.java
    │   │       ├── HitEffectModule.java
    │   │       └── TargetHighlightModule.java
    │   ├── particle/
    │   │   ├── WorsendParticle.java       # Poolable particle state
    │   │   ├── ParticleEngine.java        # Fixed-capacity pool + batched renderer
    │   │   └── emitter/
    │   │       └── TrailEmitter.java      # Arrow / footstep / sword-swing trails
    │   ├── render/
    │   │   └── WorsendRenderLayers.java   # Custom additive RenderLayers
    │   ├── combat/
    │   │   └── CombatTracker.java         # Tracks entities the local player hit
    │   └── mixin/
    │       ├── WorldRendererMixin.java        # Sky override
    │       ├── GameRendererMixin.java         # Camera shake
    │       ├── LivingEntityDeathMixin.java    # Kill Effect trigger
    │       └── PlayerAttackMixin.java         # Hit Effect trigger + CombatTracker feed
    └── resources/
        ├── fabric.mod.json
        ├── worsend.mixins.json
        └── assets/worsend/textures/particle/  # drop soft_glow.png here (see below)
```

## Getting a compiled .jar without using a terminal

This project includes `.github/workflows/build.yml`, which builds the mod on
GitHub's own servers every time you push — you never run Gradle locally.

1. Create a new repository on GitHub (github.com → "New repository").
2. Upload this entire `worsend-client` folder to it. Easiest way with no
   terminal: on the repo's page, use "Add file" → "Upload files", drag the
   whole folder in, and commit. (GitHub's web uploader accepts folders
   dragged from your file explorer.)
3. Click the **Actions** tab at the top of the repo. You'll see a run
   already in progress (or starting shortly) called "Build Worsend Client" —
   it triggers automatically on every push.
4. Wait for the green checkmark (a first build usually takes a few minutes).
5. Click into that run, scroll to the **Artifacts** section at the bottom,
   and click **worsend-client-jar** to download a zip containing the
   compiled `.jar`.
6. Drop that `.jar` into your Fabric-loader'd `mods/` folder (alongside
   Fabric API) and launch Minecraft.

If the run shows a red ✕ instead, click into it and open the failed step —
the log will point at exactly which line failed (most likely one of the two
mapping-sensitive mixin signatures called out below, since those can't be
verified without a real compiler). You'd fix that one line directly in
GitHub's web-based file editor (click the file → pencil icon → edit → commit)
and the workflow reruns automatically — still no terminal involved.

## What's a deliberate substitution from earlier discussion

The "Target ESP" request is implemented here as **`TargetHighlightModule`** —
a glowing outline on whatever entity is actually under your crosshair,
resolved through the same block-respecting raycast vanilla uses for attack
targeting. It will never highlight an entity through walls. I kept this
boundary intentionally: a through-wall ESP gives an unfair advantage over
other players and is exactly the kind of feature that gets clients banned by
anti-cheat outright, so it's not something I'll build regardless of how it's
framed. Everything else — sky, kill/hit effects, particle engine — is
implemented as originally discussed.

## Before you build

**1. Missing binary: `gradle/wrapper/gradle-wrapper.jar`**
Same situation as the launcher project — this is a compiled binary Gradle
generates itself, not source code, so it isn't included. Either:
- Install Gradle (https://gradle.org/install/), run `gradle wrapper` once in
  this folder to generate it, then use `gradlew`/`gradlew.bat` from then on, or
- Just run `gradle` commands directly (e.g. `gradle build`) — no wrapper needed.

**2. Missing texture: `soft_glow.png`**
`WorsendRenderLayers.ADDITIVE_PARTICLES` references
`assets/worsend/textures/particle/soft_glow.png` — a small radial white
gradient (transparent at edges, opaque white center) that the additive blend
tints per-particle. Drop a 32×32 or 64×64 PNG like that at that path; I can't
generate binary image assets here.

**3. Confirm mapping-sensitive method signatures**
Two mixins target vanilla methods whose exact signature shifts between Yarn
builds more than most:
- `WorldRendererMixin` → `WorldRenderer.renderSky(...)`
- `GameRendererMixin` → `GameRenderer.renderWorld(...)`

Both files have a comment at the top telling you exactly what to check.
Open the decompiled class in your IDE after the first Loom sync
(`gradle genSources` if you want readable decompiled MC source) and confirm
the parameter list matches before your first real build — if Yarn renamed
something, only the `@Inject(method = "...")` string needs updating, not the
logic inside.

**4. `gradle.properties` version pins**
`yarn_mappings` and `fabric_version` are the exact strings current as of
recent 1.21.1 releases, but Fabric API ships frequent point releases —
double-check https://fabricmc.net/develop/ for the latest `1.21.1`-compatible
build before your first build, in case a newer one has fixes you want.

## Building

```
gradle build
```

Output `.jar` lands in `build/libs/worsend-client-1.0.0.jar` — drop it into
your Fabric-loader'd `mods/` folder alongside Fabric API.

For faster iteration while developing:
```
gradle runClient
```

## Wiring notes

- `ParticleEngine` and all four modules are already hooked into Fabric's
  event bus in `WorsendClient.java` — enabling a module via
  `WorsendClient.MODULES.getXModule().setEnabled(true)` (from your config
  screen / keybind handler) is all that's needed to activate it.
- `TrailEmitter` (arrow/footstep/sword-swing particles) isn't auto-wired to
  any event yet — call `TrailEmitter.arrowTrail(...)`, `.footstep(...)`, or
  `.swordSwing(...)` from wherever your client already ticks projectiles /
  player movement / attack animations.
- `HitEffectModule`'s `trigger(...)` currently gets called from
  `PlayerAttackMixin` with an *approximate* damage value (the player's base
  attack-damage attribute). If your client already predicts real damage
  numbers elsewhere, pass that value into `trigger(...)` instead for more
  accurate floating numbers.
