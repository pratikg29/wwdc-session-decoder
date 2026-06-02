# Session classifier and routing

Classify the session before writing anything. The type determines the brief structure and
whether a demo is built. Use the transcript, title, chapters, and Resources to decide — the
title alone is often misleading ("Meet X" can be a deep API session or a light overview).

## The five types

### Type 1 — New framework / new API
Signals: "Meet…", "Introducing…", a framework or API that didn't exist before, lots of new
type/method names in the code samples, Resources linking to a brand-new documentation page
or a new sample-code project.

Route: **deepest brief + runnable demo.** This is where the skill earns its keep. Cover the
mental model (why this API exists, what problem it solves), the core API surface, and a demo
the developer can paste into a project and run.

### Type 2 — "What's new in X" / enhancements
Signals: "What's new in SwiftUI/Swift/UIKit…", "Bring your app to…", incremental additions to
an existing framework, a grab-bag of features each covered briefly.

Route: **migration-focused brief.** Lead with the delta table (feature → what it changes →
should you adopt). Use small before/after snippets per feature. Usually no single demo — these
sessions are a list of unrelated improvements; instead give a focused snippet for the 1–2
highest-impact items. Build a demo only if one feature is substantial enough to stand alone.

### Type 3 — Behavior change / deprecation / requirement
Signals: deprecations, default-behavior changes, new App Store / privacy / entitlement
requirements, "Prepare for…", anything where *not acting* breaks or rejects your app.

Route: **impact-checklist brief.** Front-load "what breaks if you do nothing" and "what to
change", with a concrete checklist. Code only where a migration snippet helps. Minimal or no
demo — the value is the action list, not runnable code.

### Type 4 — Conceptual / design / best-practices
Signals: HIG / design talks, architecture philosophy, "Principles of…", performance or
accessibility guidance with few or no new APIs, advice rather than a new surface.

Route: **principles brief. No demo** — there's nothing to run. Distill the principles into
decision-useful guidance (when to apply, trade-offs, what to avoid) for an engineer who has to
turn philosophy into code choices. If the session references existing APIs, link them, but
don't manufacture a demo around a design talk.

### Type 5 — Tooling / Xcode / Swift language / SwiftPM
Signals: Xcode features, Instruments, build system, Swift language/compiler features, Swift
Package Manager, testing tooling.

Route: **workflow brief.** Steps, settings, and config/CLI snippets the developer follows.
Build a demo only when there's runnable Swift to show (e.g. a new language feature, a Swift
Testing example, a `Package.swift`); for IDE-only features (a new Xcode panel, an Instruments
template) there's nothing to run — skip the demo and show the workflow instead.

## Routing summary

| Type | Brief emphasis | Demo? |
|------|----------------|-------|
| 1 New API | mental model + API surface + code | Yes — full `Demo.swift` |
| 2 What's new | delta table + before/after | Rarely — only a standout feature |
| 3 Behavior change | impact checklist + migration | Minimal/no |
| 4 Conceptual/design | distilled principles | No |
| 5 Tooling/language | workflow + config snippets | Only if runnable Swift |

## When a session straddles types

Many sessions mix a new API with migration notes, or wrap a behavior change in a "what's new".
Pick the type that best serves the reader's decision, lead with that structure, and fold the
secondary aspect in as a sub-section. Note the call in one line at the top of the brief (e.g.
"Primarily a new-API session with migration notes for existing PhotoKit users.").
