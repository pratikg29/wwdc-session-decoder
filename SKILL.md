---
name: wwdc-session-decoder
description: >-
  Decodes an Apple WWDC video session (talks at
  developer.apple.com/videos) into a fast, practical brief for an experienced
  iOS/macOS engineer — what's new, the API surface, real code, migration impact,
  gotchas — plus a runnable Swift demo when warranted. Trigger whenever the user
  points at a specific WWDC session and wants it explained, decoded, summarized,
  broken down, made into a cheat sheet, or wants its code/demo or an "is it worth
  watching / does it affect my code" verdict. The session may arrive as a
  developer.apple.com/videos link; a session number alone ("session 10160",
  "wwdc2023-10187"); a talk title ("Meet SwiftData", "What's new in SwiftUI"); or
  casual phrasing like "catch me up on…" or "tl;dr the … talk", incl. the slang
  "dub dub". Do NOT trigger for other conferences (Google I/O) or "what's new in"
  non-Apple tech; other senses of "session" (therapy, a web/HTTP session or
  URLSession, a talk the user is giving); generic Swift questions not tied to a
  WWDC video; or Apple doc pages, not videos.
---

# WWDC Session Decoder

## What this skill is for

WWDC drops 100+ developer sessions in a week. Nobody watches all of them — engineers
triage. This skill turns a single session into the artifact a busy, experienced
developer actually wants: a brief that answers *"what changed, do I care, and what do
I do about it?"* in seconds, then goes deep on the API surface and real code, and ships
a runnable demo when (and only when) the session is the kind that benefits from one.

The audience is an **experienced iOS/macOS engineer**. They already know Swift,
SwiftUI/UIKit, async/await, and the platform. So: skip the basics, lead with the delta,
and spend the words on API surface, migration, concurrency/`Sendable` implications,
availability, and the non-obvious gotchas. Treat them like a peer, not a beginner.

## The core idea: the output adapts to the session

A "what's new in SwiftUI" recap and a "meet a brand-new framework" deep dive need very
different briefs. Forcing one template onto every session produces padding for some and
thin coverage for others. So the first real decision is **classifying the session**, and
everything downstream (brief structure, depth, whether to build a demo) follows from that.

Read `references/session-types.md` for the full classifier and the routing rules. The
five types in brief:

1. **New framework / new API** → deepest brief + a runnable demo. The high-value case.
2. **"What's new in X" / enhancements** → migration-focused: API delta, before/after, what to adopt. Small focused snippets, usually no full demo.
3. **Behavior change / deprecation / requirement** → impact checklist first. Minimal or no demo.
4. **Conceptual / design / best-practices (incl. HIG)** → distilled principles and decision guidance. **No demo** — there's no API to run.
5. **Tooling / Xcode / Swift language / SwiftPM** → workflow steps and config/CLI snippets. Demo only if there's runnable Swift, not for IDE-only features.

When a session genuinely straddles two types, pick the one that serves the developer's
decision best and say so in one line at the top.

## Workflow

### 1. Get the session

The input is normally an Apple developer video URL, e.g.
`https://developer.apple.com/videos/play/wwdc2024/10184/`. If the user gives only a title
or number, search for the matching `developer.apple.com/videos/play/...` URL and confirm
the title before proceeding so you don't decode the wrong session.

### 2. Fetch the page (one fetch gets everything)

Fetch the session URL directly. Apple's session pages are server-rendered, so a single
fetch returns, in plain text:

- title + description
- **Chapters** with timestamps (the session's outline — use it to structure the brief)
- **Resources** (links to official docs, sample-code projects, related articles)
- **Related Videos** (prerequisites and deeper dives)
- the **full transcript**
- **every code sample** shown, each with a title and timestamp

You do not need to process the video. The transcript + code samples are the ground truth.
Ground every claim in them — **do not invent APIs, signatures, or availability** that
aren't supported by the page or the linked docs.

### 3. Pull 1–2 linked resources when accuracy matters

For new-API and "what's new" sessions, the transcript narrates but rarely gives exact
signatures, parameter names, or `@available` annotations. When the brief depends on those
details, fetch the most relevant **Resources** doc or sample-code link (1–2, not all) to
confirm names and availability. Skip this for conceptual sessions where there's no API.

**Important — Apple documentation pages are JavaScript-rendered.** A plain fetch of a
`developer.apple.com/documentation/...` URL returns an empty shell that just says "This page
requires JavaScript", not the actual content. So:

- The **session page itself fetches fine** (it's server-rendered) — its transcript and on-page
  code samples are your primary ground truth and are usually enough.
- For the linked docs, prefer **non-Apple-doc resources**, which fetch normally: GitHub READMes
  (e.g. open-source Swift packages), swift.org articles, and sample-code repos.
- If you genuinely need an Apple `documentation` page and a JavaScript-capable browser tool is
  available (e.g. a Chrome/browser MCP that renders pages), use it to read the rendered page.
- If you can't get the doc, **do not invent signatures, parameter names, or availability to
  fill the gap.** Build the brief from the transcript + on-page samples, and add a one-line note
  pointing the reader to the official doc for exact API details. An honest gap beats a confident
  guess — this is API reference material developers will copy.

### 4. Classify, then write the brief

Decide the session type (`references/session-types.md`), then build the brief from the
matching template in `references/brief-template.md`. Every brief starts with the same
fast-triage header so the reader gets the verdict before deciding to read on; the body
varies by type.

### 5. Decide on a demo

Use the demo decision rule and the Swift quality bar in `references/demo-guide.md`. The
short version: build a demo when there's a concrete API a developer would want to *run* to
understand (types 1, and sometimes 2 and 5). Don't build one for conceptual/design sessions
or IDE-only tooling.

**The demo is a real use-case, not the session's snippets reassembled.** WWDC samples are
fragmentary by design (they fit on a slide). First *learn* how the API actually fits together —
from the transcript, the readable linked resources, and solid framework knowledge — then invent
a small, plausible scenario and wire the session's APIs into it correctly, adding the connective
tissue (init, entry point, sample data, call order) the slides leave out. The result should read
like a minimal real app/feature that showcases the API end-to-end — a single self-contained,
idiomatic `Demo.swift` by default. Synthesizing the scenario is expected; fabricating API surface
(signatures, parameters, availability) is not — see the quality bar in the reference.

**Be honest about verification.** There's no Xcode or iOS simulator here, so generated
Swift can't be compiled or run. Present demo code as a high-quality, ready-to-paste
starting point — never claim it's been tested. Flag anything you're inferring rather than
confirming from the transcript or docs.

### 6. Save and present

Create a folder named after the session (e.g. `wwdc2024-10184-swift-tour/`) in the outputs
directory containing:

- `brief.md` — the decoded session brief
- `Demo.swift` — only if the session warranted one

Then present the files. Keep the chat summary short: the verdict, the session type, and
whether a demo was included. The brief is the deliverable; don't re-narrate it in chat.

## Depth control

Default to a focused brief, not an exhaustive one. If the user asks for a "quick" read,
give them the triage header plus the key APIs and gotchas only — skip the demo unless they
ask. If they ask to "go deep" or "build the demo", expand the API section and always
include the demo (when the type supports one). Match effort to the session and the ask
rather than always doing maximum work.

## References

- `references/session-types.md` — the classifier and per-type routing rules. Read this first, every time.
- `references/brief-template.md` — the shared triage header and the body template for each session type.
- `references/demo-guide.md` — when to build a demo, the Swift quality bar, and the `Demo.swift` structure.
