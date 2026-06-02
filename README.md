# WWDC Session Decoder

> Turn any Apple WWDC developer session into a fast, practical brief — what's new, the API surface, real code, migration impact, and gotchas — plus a runnable Swift demo when the session warrants one.

A [Claude Agent Skill](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview) for iOS/macOS engineers who don't have time to watch all 100+ WWDC sessions but still need to know which ones matter and what to do about them. Give it a session link (or just a title or number), and it produces a peer-level brief written for someone who already knows Swift.

```text
You:  catch me up on the Meet SwiftData session and show me the code

Claude:  → fetches the session page (transcript + code samples)
         → classifies it as a new-API session
         → writes brief.md  (verdict, mental model, API surface, gotchas)
         → writes Demo.swift (a runnable SwiftUI app exercising the API)
```

## Why this exists

WWDC week drops more sessions than anyone can watch. Engineers triage. The most valuable
artifact isn't a transcript dump — it's an honest answer to *"what changed, do I care, and what
do I do about it?"*, followed by real code. This skill produces exactly that, and **adapts the
output to the kind of session** instead of forcing one template on everything.

## Features

- **Reads the real session** — fetches Apple's session page and grounds everything in the actual
  transcript and on-page code samples. No video processing, no guessing from the title.
- **Adaptive output by session type** — a "what's new" recap, a new-framework deep dive, a
  deprecation notice, and a design talk each get a structure that fits them (see below).
- **Written for experienced devs** — skips the basics; leads with the delta, API surface,
  migration impact, concurrency/`Sendable` implications, availability, and the non-obvious traps.
- **Runnable Swift demos** — for sessions with a concrete API, it generates a self-contained,
  idiomatic `Demo.swift` you can paste into Xcode — not a toy `print("hello")`.
- **Smart demo decision** — builds a demo only when running code teaches something the brief
  can't; skips it for design talks and IDE-only tooling.
- **Honest about limits** — never claims code was compiled (it can't be, outside Xcode), flags
  any inferred API, and refuses to fabricate when a session can't be fetched.

## How it works

1. **Get the session.** Accepts a `developer.apple.com/videos` link, a bare session number
   (`10160`, `wwdc2023-10187`), or a title — for a title it finds the URL and confirms it first.
2. **Fetch the page.** One fetch returns the title, chapters, resources, related videos, the full
   transcript, and every code sample (Apple's session pages are server-rendered).
3. **Classify the session** into one of five types.
4. **Write the brief** using the structure for that type, opening with a fast triage header
   (a real "Should you care?" verdict + minimum OS target).
5. **Decide on a demo** and, if warranted, generate a `Demo.swift`.
6. **Save** a `brief.md` (+ `Demo.swift`) in a session-named folder.

### Session type → output

| Session type | Brief emphasis | Demo? |
|---|---|---|
| **New framework / new API** | mental model + API surface + code | Yes — full `Demo.swift` |
| **"What's new in X"** | delta table + before/after snippets | Rarely — only a standout feature |
| **Behavior change / deprecation / requirement** | impact checklist + migration | Minimal / no |
| **Conceptual / design (incl. HIG)** | distilled principles + decision guidance | No |
| **Tooling / Xcode / Swift language / SwiftPM** | workflow + config snippets | Only if there's runnable Swift |

## Installation

This skill works in **Claude Code** and **Claude Cowork**.

### Option A — copy the folder

Place the `wwdc-session-decoder/` folder in your skills directory:

```bash
# Personal skills (all projects)
git clone https://github.com/<your-username>/wwdc-session-decoder.git \
  ~/.claude/skills/wwdc-session-decoder

# or, per-project
mkdir -p .claude/skills && cp -r wwdc-session-decoder .claude/skills/
```

### Option B — install the packaged skill

In Cowork or Claude Code, install the `wwdc-session-decoder.skill` file (a zipped skill bundle)
via your skills/plugins UI.

The skill auto-loads when your request matches its description — no manual activation needed.

## Usage

Just ask, in natural language. Examples that trigger it:

```text
Decode this for me: https://developer.apple.com/videos/play/wwdc2024/10179/
Catch me up on session 10160 — I'm a senior iOS dev, skip the basics
What's actually new in the "What's new in SwiftUI" talk, and does it affect my code?
Give me the tl;dr and a demo for Meet SwiftData
Is "Bring your app to CarPlay" worth watching? what changed?
```

Want a lighter pass? Ask for a "quick read" (verdict + key APIs only) or to "go deep / build the
demo" for the full treatment.

### Example output

For a new-API session you get a folder like:

```
wwdc2023-10187-meet-swiftdata/
├── brief.md      # verdict, "why this exists", key APIs, gotchas, go-deeper links
└── Demo.swift    # self-contained, paste-into-Xcode SwiftUI app
```

## Limitations

- **Demos aren't compiled.** There's no Xcode/Swift toolchain in the skill's environment, so
  generated Swift is a high-quality, ready-to-paste *starting point* — build it in Xcode. The
  skill says so explicitly and never claims otherwise.
- **Apple documentation pages are JavaScript-rendered.** A plain fetch of a
  `developer.apple.com/documentation/...` page returns an empty shell. The skill relies on the
  (server-rendered) session transcript and code samples as ground truth, prefers non-Apple-doc
  resources (GitHub READMEs, swift.org) when it needs exact signatures, and won't invent API
  details to fill a gap.
- **Best on developer/technical sessions.** It's tuned for framework, API, tooling, and design
  talks — not keynotes or business-track sessions.

## Repository structure

```
wwdc-session-decoder/
├── SKILL.md                      # skill entry point: workflow + routing
├── references/
│   ├── session-types.md          # the 5-type classifier and routing rules
│   ├── brief-template.md         # the triage header + per-type brief templates
│   └── demo-guide.md             # when to build a demo + the Swift quality bar
├── evals/
│   ├── evals.json                # output-quality test cases
│   └── trigger-evals.json        # description-triggering test cases
├── README.md
└── LICENSE
```

## Contributing

Contributions welcome. Useful additions: more session-type test cases in `evals/`, refinements to
the classifier in `references/session-types.md`, and improvements to the brief templates. Please
keep the skill's two core principles intact — **ground everything in the session's own content**,
and **never present unverified code or API details as fact**.

## License

[MIT](./LICENSE)
