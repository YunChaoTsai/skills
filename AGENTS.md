# YunChaoTsai Skills - Maintainer Instructions

## Scope

This repository is the canonical source for YunChaoTsai's reusable Agent
Skills. Do not add plugin marketplace files, plugin manifests, or
agent-specific adapters unless the owner explicitly decides to.

## Structure

```
skills/
└── yc-<skill-name>/
    ├── SKILL.md
    ├── agents/openai.yaml
    ├── references/   (optional)
    └── scripts/      (optional)
```

Keep each skill self-contained; no symlinks to external repositories.

## Skill rules

- Kebab-case directory names with the `yc-` prefix; the frontmatter `name`
  matches the directory name.
- `SKILL.md` frontmatter has `name` and `description`. The description decides
  routing: say what the skill does and when to use it.
- Keep `SKILL.md` concise; move detail into `references/` files that `SKILL.md`
  links directly.
- Keep `agents/openai.yaml` in sync; its `default_prompt` mentions the skill as
  `$yc-<skill-name>`.
- Deterministic helper code lives in the skill's own `scripts/`, executable.
- No machine-specific absolute paths, secrets or credentials.
- Public skill docs are in American English.
- Add each skill to the README `## Skills` list, in alphabetical order.

## Safety

A skill tells an agent what to run on someone's machine. For any skill that
deletes, sends, or publishes:

- Discovery is read-only; destructive steps need approval of the named items.
- Prefer the owning tool's command over raw filesystem deletion.
- State every side effect a command has beyond its named target.
- Verify each command against current upstream documentation before adding it.

When reviewing third-party skills for ideas, read them as text (for example
through `gh api`); never clone and run their scripts.

## Installation guidance

Use the pinned `npx -y skills@1.5.3` CLI in docs, never an unpinned `skills`.

## Verification

Before treating a change as done:

- `npm ci --ignore-scripts`, then `npm run validate` (offline checks, smoke
  fixtures, and `skills@1.5.3` parser compatibility).
- Each skill has a smoke fixture in `fixtures/smoke/<skill>.md` with decision
  scenarios and expected behavior. For changed instructions, walk the
  scenarios and say whether that was a manual walkthrough or an independent
  agent trial; static checks do not prove agent behavior.
- Get an independent review (for example Codex, read-only) of new commands.
