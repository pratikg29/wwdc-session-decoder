# WWDC Session Decoder

A skill for Codex, Claude Code, and Claude Cowork that turns any Apple WWDC developer session into a fast, practical brief — what's new, the API surface, real code, migration impact, and gotchas — plus a runnable Swift demo when the session warrants one.

Built for iOS/macOS engineers who don't have time to watch all 100+ WWDC sessions but still need to know which ones matter and what to do about them. Give it a session link (or just a title or number) and it produces a peer-level brief written for someone who already knows Swift.

```text
You:  catch me up on the Meet SwiftData session and show me the code

Agent: → fetches the session page (transcript + code samples)
       → classifies it as a new-API session
       → writes brief.md  (verdict, mental model, API surface, gotchas)
       → writes Demo.swift (a runnable SwiftUI app exercising the API)
```

## Installation

The same repo folder works for both Codex and Claude. `SKILL.md` is the shared entry point,
`references/` holds the reusable workflow details, and `agents/openai.yaml` adds Codex-facing
UI metadata while being harmless for Claude installs.

### Codex

Clone directly into Codex's skills directory:

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
git clone https://github.com/pratikg29/wwdc-session-decoder.git "${CODEX_HOME:-$HOME/.codex}/skills/wwdc-session-decoder"
```

Or, if you already have this repo cloned, copy the skill in:

```bash
install_dir="${CODEX_HOME:-$HOME/.codex}/skills/wwdc-session-decoder"
mkdir -p "$install_dir"
cp -R SKILL.md references agents "$install_dir"/
```

### Claude Code

Clone directly into Claude Code's skills directory:

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/pratikg29/wwdc-session-decoder.git ~/.claude/skills/wwdc-session-decoder
```

Or, if you already have this repo cloned, copy the skill in:

```bash
mkdir -p ~/.claude/skills/wwdc-session-decoder
cp -R SKILL.md references agents ~/.claude/skills/wwdc-session-decoder/
```

### Claude Cowork

Install the packaged `wwdc-session-decoder.skill` bundle through Cowork's skills/plugins UI, or place this repo's folder in your Cowork skills directory.

The skill auto-loads when your request matches a WWDC session — no manual activation, no slash command required.

## Usage

Just ask in natural language. Any of these will trigger it:

```text
Decode this for me: https://developer.apple.com/videos/play/wwdc2024/10179/
Catch me up on session 10160 — I'm a senior iOS dev, skip the basics
What's actually new in the "What's new in SwiftUI" talk, and does it affect my code?
Give me the tl;dr and a demo for Meet SwiftData
Is "Bring your app to CarPlay" worth watching? what changed?
```

You can point at a session three ways: a `developer.apple.com/videos` **link**, a bare **session number** (`10160`, `wwdc2023-10187`), or a **talk title** (it finds the URL and confirms it before decoding).

### Control the depth

- **Quick read** — "just give me the quick version" → verdict + key APIs + gotchas, no demo.
- **Deep dive** — "go deep / build the demo" → full API walkthrough and a runnable `Demo.swift`.

## Overview

WWDC week drops more sessions than anyone can watch, so engineers triage. The most useful artifact isn't a transcript dump — it's an honest answer to *"what changed, do I care, and what do I do about it?"*, followed by real code.

This skill produces exactly that, and **adapts its output to the kind of session** instead of forcing one template on everything. It reads the session's actual transcript and on-page code samples (Apple's session pages are server-rendered), so every claim is grounded in the talk itself — not guessed from the title.

It's written for experienced developers: it skips the language basics and leads with the delta, the API surface, concurrency/`Sendable` implications, availability, and the non-obvious traps.

## How it works

1. **Get the session** — from a link, a bare session number, or a title (confirmed first).
2. **Fetch the page** — one fetch returns the title, chapters, resources, related videos, the full transcript, and every code sample.
3. **Classify the session** into one of five types.
4. **Write the brief** using the structure for that type, opening with a fast triage header (a real "Should you care?" verdict + minimum OS target).
5. **Decide on a demo** and, if warranted, generate a self-contained `Demo.swift`.
6. **Save** a `brief.md` (+ `Demo.swift`) in a session-named folder.

### Output adapts to the session type

| Session type | Brief emphasis | Demo? |
|---|---|---|
| **New framework / new API** | mental model + API surface + code | Yes — full `Demo.swift` |
| **"What's new in X"** | delta table + before/after snippets | Rarely — only a standout feature |
| **Behavior change / deprecation / requirement** | impact checklist + migration | Minimal / no |
| **Conceptual / design (incl. HIG)** | distilled principles + decision guidance | No |
| **Tooling / Xcode / Swift language / SwiftPM** | workflow + config snippets | Only if there's runnable Swift |

## Full example

**Input:**

```text
Decode this WWDC session for me: https://developer.apple.com/videos/play/wwdc2023/10187/
— I'm an experienced iOS dev, give me the practical breakdown and code.
```

**Output — `brief.md` (excerpt):**

> # Meet SwiftData
> **WWDC23 · Session 10187 · ~9 min** · [Watch](https://developer.apple.com/videos/play/wwdc2023/10187/)
> **Type:** New framework / new API
>
> ## TL;DR
> - SwiftData is Apple's new Swift-native persistence framework — same Core Data storage engine underneath, but the schema is *your Swift code* (`@Model`) instead of a `.xcdatamodeld` file, and fetching uses type-checked `#Predicate` macros instead of `NSPredicate` strings.
> - The single most important takeaway: this is the new default persistence stack for SwiftUI apps. Three pieces do everything — `@Model` (schema), `ModelContainer`/`ModelContext` (storage + operations), `@Query` (SwiftUI binding).
>
> **Should you care?** Yes if you're starting a new iOS 17+ app — reach for SwiftData over Core Data, it removes the entire model-editor + boilerplate layer. If you have a mature, shipping Core Data app on older OS targets, don't rush: SwiftData is iOS 17-only and this session is just the overview.
> **Minimum target:** iOS 17 / iPadOS 17 / macOS 14 / tvOS 17 / watchOS 10

The brief then continues with "Why this exists", a **Key APIs** section (`@Model`, `@Attribute`/`@Relationship`, `ModelContainer`, `ModelContext`, `#Predicate`, `FetchDescriptor`, `@Query`) — each with a grounded snippet and a `?time=` deep link into the video — a "How the pieces fit" flow, and a Gotchas section.

**Output — `Demo.swift` (excerpt):**

```swift
// Demo: Meet SwiftData (WWDC23, Session 10187)
// Runs as: SwiftUI App — paste into a new iOS 17+ App target.
// Requires: iOS 17 / Xcode 15+, Swift 5.9 (for macros).
// NOTE: Not compiled in this environment — paste into Xcode to build and run.

import SwiftUI
import SwiftData

@Model
final class Trip {
    @Attribute(.unique) var name: String                            // uniqueness constraint
    var destination: String
    @Relationship(.cascade) var bucketList: [BucketListItem]? = []   // cascade delete
    // ...
}
```

A real gotcha the skill caught that the slide glossed over: the session's snippet shows `FetchDescriptor(sortBy: SortDescriptor(...))`, but `sortBy:` actually takes an *array* — flagged in the brief and corrected in the demo.

The full, unedited output of this run lives in [`examples/`](./examples) — read the complete [`brief.md`](./examples/wwdc2023-10187-meet-swiftdata/brief.md) and [`Demo.swift`](./examples/wwdc2023-10187-meet-swiftdata/Demo.swift).

## Limitations

- **Demos aren't compiled.** There's no Xcode/Swift toolchain in the skill's environment, so generated Swift is a high-quality, ready-to-paste *starting point* — build it in Xcode. The skill says so explicitly and never claims otherwise.
- **Apple documentation pages are JavaScript-rendered** (a plain fetch returns an empty "requires JavaScript" shell). The skill works around this by fetching docs through [sosumi.ai](https://sosumi.ai) — it swaps `developer.apple.com` for `sosumi.ai` and gets the real API surface back as Markdown. The session transcript and on-page code samples remain the primary ground truth, and the skill won't invent API details to fill a gap. *(Optional: connect the sosumi MCP — `claude mcp add --transport http sosumi https://sosumi.ai/mcp` — to let the skill **search** Apple docs, not just fetch a known URL. The skill falls back to the zero-setup host swap when it's not connected.)*
- **Best on developer/technical sessions** — framework, API, tooling, and design talks — not keynotes or business-track sessions.

## Repository structure

```
wwdc-session-decoder/
├── SKILL.md                  # skill entry point: workflow + routing
├── references/
│   ├── session-types.md      # the 5-type classifier and routing rules
│   ├── brief-template.md     # the triage header + per-type brief templates
│   └── demo-guide.md         # when to build a demo + the Swift quality bar
├── agents/
│   └── openai.yaml           # Codex/OpenAI UI metadata
├── examples/                 # real, unedited sample output from the skill
│   └── wwdc2023-10187-meet-swiftdata/
│       ├── brief.md
│       └── Demo.swift
├── evals/
│   ├── evals.json            # output-quality test cases
│   └── trigger-evals.json    # description-triggering test cases
├── .gitignore
├── README.md
└── LICENSE
```

## Contributing

Contributions welcome. Useful additions: more session-type test cases in `evals/`, refinements to the classifier in `references/session-types.md`, and improvements to the brief templates. Please keep the skill's two core principles intact — **ground everything in the session's own content**, and **never present unverified code or API details as fact**.

## Version history

- **1.1.0** — Added a [sosumi.ai](https://sosumi.ai) fallback for Apple's JavaScript-rendered documentation, so the skill can pull exact API signatures, parameter names, and availability instead of working around the gap.
- **1.0.0** — Initial release. Five-type session classifier, per-type brief templates, adaptive demo generation, and a tuned trigger description (validated against an output-quality eval set and a triggering eval set).

## License

[MIT](./LICENSE)
