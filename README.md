# Agent Skills

A curated collection of best-practice AI agent skills for Claude Code and other agent platforms.

## Skills

| Skill | Description | Install |
|-------|-------------|---------|
| **[github-workflows](github-workflows/)** | Create, review, repair, and debug GitHub Actions workflows with strong deploy diagnostics | `npx skills add 1hzio/agent-skills --skill github-workflows` |
| **[wikic](wikic/)** | Compile knowledge into a persistent Wiki of interlinked Markdown pages | `npx skills add 1hzio/agent-skills --skill wikic` |

## Install

```bash
# Install all skills
npx skills add 1hzio/agent-skills

# Install a specific skill
npx skills add 1hzio/agent-skills --skill wikic
npx skills add 1hzio/agent-skills --skill github-workflows

# Or use Claude Code CLI
claude skill install /path/to/agent-skills/wikic
```

## License

MIT
