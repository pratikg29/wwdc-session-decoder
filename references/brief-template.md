# Brief templates

Every brief is a Markdown file. It opens with the **shared triage header** (same for all
types) so the reader gets the verdict immediately, then continues with the **body** for the
session's type. Write for an experienced engineer: dense, concrete, no filler, no "Swift is a
modern language" throat-clearing.

A note on the code samples: the session page already contains the presenter's own code
snippets. Reuse them where they're the clearest illustration, but don't just dump them —
frame each with what it demonstrates and, where relevant, how it differs from the old way.
Always keep the `?time=` timestamp link so the reader can jump to that moment in the video.

---

## Shared triage header (all types)

```markdown
# <Session title>

**WWDC<yy> · Session <id> · <duration>** · [Watch](<url>)
**Type:** <one of the five> <"(+ migration notes)" etc. if it straddles>

## TL;DR
- <what's new / what changed, one line>
- <who it affects and the headline benefit or cost>
- <the single most important takeaway>

**Should you care?** <One honest sentence: who should act now, who can skip, and why.>
**Minimum target:** <iOS/macOS/etc. version, or "n/a">
```

The "Should you care?" line is the most valuable sentence in the whole brief. Make it a real
recommendation, not a hedge.

---

## Type 1 — New framework / new API

```markdown
## Why this exists
<The problem this API solves and the mental model behind it. What did developers do before,
and why is this better. 2–4 sentences — this is the part videos and docs do worst.>

## Key APIs
For each important type/method:
### `SymbolName`
<One line: what it does.> Available <version>.
` ` `swift
<focused snippet — the real signature/usage, grounded in the transcript or linked docs>
` ` `
<Why it matters / when to reach for it. Note any async/Sendable/actor implications.>

## How the pieces fit
<Short narrative or step list of the typical end-to-end flow, if the APIs combine into one.>

## Gotchas
- <availability, deprecations, threading/Sendable, retain cycles, performance, common traps>

## Try it
See `Demo.swift` — <one line on what the demo shows>.

## Go deeper
- <related sessions and doc links from the page's Resources / Related Videos>
```

## Type 2 — What's new in X

```markdown
## The delta
| Feature | What it changes | Adopt? |
|---------|-----------------|--------|
| <name> | <effect> | <Now / When convenient / Skip> |

## Highlights
For the 1–3 highest-impact items, a before/after:
### <Feature>
**Before**
` ` `swift
<old way>
` ` `
**Now**
` ` `swift
<new way>
` ` `
<Why it's better; any catch.>

## Gotchas & availability
- <version gating, behavioral subtleties>

## Go deeper
- <links>
```

## Type 3 — Behavior change / deprecation / requirement

```markdown
## What breaks if you do nothing
<Plain statement of the consequence — crash, deprecation warning, App Store rejection, silent
behavior change — and when it takes effect.>

## What to change — checklist
- [ ] <concrete action>
- [ ] <concrete action>

## Migration snippets
` ` `swift
<before → after where code changes>
` ` `

## Timeline & gating
<Deadlines, OS versions, enforcement dates.>

## Go deeper
- <links>
```

## Type 4 — Conceptual / design / best-practices

```markdown
## The core principles
1. **<Principle>** — <what it means and why, in engineering terms.>
2. ...

## Applying it
<Decision guidance: when each principle applies, the trade-offs, what to avoid. Connect to
concrete API or design choices an engineer makes, even though there's no new API here.>

## Anti-patterns called out
- <things the session warns against>

## Go deeper
- <links>
```
(No demo for this type.)

## Type 5 — Tooling / Xcode / Swift language / SwiftPM

```markdown
## What it does for you
<The workflow improvement and when it helps.>

## How to use it — steps
1. <step, with the exact menu/setting/flag>
2. ...

## Config / CLI
` ` `<bash|swift|toml>
<settings, Package.swift, command invocations>
` ` `

## Gotchas
- <version requirements, caveats>

## Go deeper
- <links>
```
(Demo only if there's runnable Swift — e.g. a language feature or Swift Testing example.)
