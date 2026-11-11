# skills

Agent skills for Claude Code, Codex and other agents that read `SKILL.md`.

| Skill | What it does |
|---|---|
| [`dev-disk-cleanup`](skills/dev-disk-cleanup/SKILL.md) | Reclaim disk space on a developer Mac or Linux machine: measure, classify by what deleting costs, ask per item, clean only what was named through each tool's own command |

## Install

Copy or symlink a skill directory into your agent's skill folder:

```bash
git clone https://github.com/YunChaoTsai/skills ~/Documents/projects/YunChaoTsai/skills
ln -s ~/Documents/projects/YunChaoTsai/skills/skills/dev-disk-cleanup ~/.claude/skills/dev-disk-cleanup
```

Read a skill before installing it: a skill tells an agent what to run on your
machine.
