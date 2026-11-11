# YunChaoTsai Skills

Reusable Agent Skills by [YunChaoTsai](https://github.com/YunChaoTsai).

## Installation

Preview available skills:

```bash
npx -y skills@1.5.3 add YunChaoTsai/skills --list
```

Install all skills globally for all supported agents:

```bash
npx -y skills@1.5.3 add YunChaoTsai/skills --skill '*' -g --agent '*' -y
```

Install all skills globally for Claude Code or Codex:

```bash
npx -y skills@1.5.3 add YunChaoTsai/skills --skill '*' -g --agent claude-code
npx -y skills@1.5.3 add YunChaoTsai/skills --skill '*' -g --agent codex
```

Install selected skills:

```bash
npx -y skills@1.5.3 add YunChaoTsai/skills --skill yc-disk-cleanup -g --agent claude-code
```

Install to the current project instead of globally by omitting `-g`.

Read a skill before installing it: a skill tells an agent what to run on your
machine.

## Skills

### yc-disk-cleanup

Reclaim disk space on a developer Mac or Linux machine: measure what is
actually large, classify each item by what deleting it costs, ask per item,
and clean only what was named through each tool's own command.

## License

[MIT](LICENSE)
