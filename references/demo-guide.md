# Demo guide

## When to build a demo

A demo earns its place when there's a concrete API a developer would learn faster by *running*
than by reading. Build one for:

- **Type 1 (new API)** — almost always. This is the payoff.
- **Type 2 (what's new)** — only when one feature is substantial enough to stand on its own
  (e.g. a new SwiftUI container). Not for a grab-bag of small tweaks.
- **Type 5 (tooling/language)** — only when there's runnable Swift: a new language feature, a
  Swift Testing example, a `Package.swift`. Never for IDE-only features (an Xcode panel, an
  Instruments template) — there's nothing to run. For a **grab-bag IDE recap** (e.g. "What's new
  in Xcode") where Swift appears only incidentally, default to keeping those snippets inline in
  the brief and skipping the separate `Demo.swift`; only promote to a demo file if one runnable
  feature (a language change, a Swift Testing example) is substantial enough to stand alone.

Do **not** build a demo for:

- **Type 3** — the value is the migration checklist, not runnable code. A migration snippet in
  the brief is enough.
- **Type 4** — design/conceptual sessions have no API to run. Forcing a demo here produces a
  meaningless toy. Skip it.

If you're unsure, ask: "would an experienced dev paste this and learn something the brief
didn't already give them?" If no, skip it.

## Build a real use-case, not a snippet dump

This is the whole point of the demo, so be explicit about it. WWDC code samples are deliberately
fragmentary — a struct on one slide, a lone method on another, no entry point, no connective
tissue — because they're built to fit on screen, not to run. **Do not transcribe those fragments
into `Demo.swift`.** Instead:

1. **Learn the API first.** Use the transcript to understand *intent*, then deepen it with the
   linked resources you can actually read (GitHub READMEs, swift.org articles, sample-code repos)
   and your own knowledge of how the framework fits together. Understand the real flow — how the
   types relate, what order calls happen in, what each piece is for — before writing anything.
2. **Invent a small, plausible scenario** that an experienced dev would recognize as a realistic
   use of the framework (e.g. for SwiftData, a tiny app with two related models and a list view —
   not five isolated declarations). The scenario is the spine that makes the APIs make sense
   together.
3. **Wire the session's APIs into that scenario correctly**, adding the obvious connective tissue
   the slides omitted (initializers, an `App`/entry point, sample data, the call sequence) so the
   thing is coherent and runnable end-to-end.

If the result looks like the slides reordered, you haven't done the job. If it looks like a
minimal real app/feature that happens to showcase the API, you have.

## The quality bar

The audience is experienced, so the demo must be *real*, not `print("hello")`:

- **Idiomatic and current.** Use the patterns the session actually teaches — modern
  concurrency, `Sendable`, the real types. Match the Swift version the session targets.
- **Self-contained and paste-ready.** A single `Demo.swift` by default. State at the top
  exactly where it runs (SwiftUI `App`, a Playground, an Xcode preview, a command-line
  executable) and any package dependency with its SwiftPM line.
- **Minimal but complete.** Enough to compile and demonstrate the API end-to-end through the
  scenario, nothing more. Cut unrelated scaffolding.
- **Commented at the decision points** — not line-by-line, but where the new API does something
  non-obvious, say why.
- **Accurate, and honest where it isn't.** Synthesizing the *scenario and structure* is expected
  and encouraged — that's not "making things up." What you must not do is fabricate **API surface**:
  signatures, parameter names, types, or availability that don't exist. Base every actual API call
  on the transcript, the readable linked resources, or well-established framework knowledge — and
  if you correct something the session got wrong (like a wrong parameter shape), say so. When the
  exact signature matters and the Apple doc is JavaScript-gated, fetch it through **sosumi.ai**
  (swap `developer.apple.com` → `sosumi.ai`; see SKILL.md step 3) — that returns the real signature
  as Markdown, so you rarely need to guess. Only if even that fails should you use your best-known
  form and flag it with a `// NOTE: verify — inferred` comment rather than passing a guess off as
  fact. An honest flag beats a confident error in code a developer will copy.

## Honesty about verification

There is no Xcode or iOS simulator in this environment, so the demo **cannot be compiled or
run here**. Never claim it builds or was tested. Frame it as a ready-to-paste starting point and
tell the reader to build it in Xcode. This protects the developer's trust — a confident-but-wrong
"this works" is worse than an honest "compile this in Xcode."

## `Demo.swift` structure

```swift
// Demo: <session title>
// Runs as: <SwiftUI App | Playground | command-line executable | Xcode preview>
// Requires: <iOS 18+ / Swift 6 / SwiftPM dep: .package(url: "…", from: "…")>
// NOTE: Not compiled in this environment — paste into Xcode to build.

import <frameworks>

// MARK: - <the focused thing the session is about>
<the smallest complete example that exercises the new API>

// MARK: - Wiring (App / preview / main) so it actually runs
<entry point appropriate to the run target>
```

For a bigger new framework where one file is genuinely cramped, it's fine to scaffold a small
folder (`Demo/` with a `Package.swift` and a couple of sources) instead of one file — but keep
it minimal and say in the brief how to open and run it.
