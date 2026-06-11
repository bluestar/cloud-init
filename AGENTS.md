# AGENTS.md - cloud-init

Shell scripts for bootstrapping a new Linux host with the baseline tools and access configuration

## Working Rules

- Never commit or push directly to `main` — this includes documentation, config, and trivial fixes. Always create a feature branch and open a pull request.

## Commit Format

Use [Conventional Commits](https://www.conventionalcommits.org/) with GPG signing.

When adding an AI attribution trailer, use the one that matches the assistant
that made the change (adjust version as appropriate):

Co-Authored-By: Grok (x-ai/grok-code-fast-1) <kilo@kilo.ai>
Co-Authored-By: Codex (GPT-5) <codex@openai.com>
Co-Authored-By: Gemini 3 Flash <noreply@google.com>
Co-Authored-By: Claude (claude-opus-4-7) <noreply@anthropic.com>
Co-Authored-By: Claude (claude-sonnet-4-6) <noreply@anthropic.com>
Co-Authored-By: DeepSeek (deepseek-v4-pro) <noreply@deepseek.com>
Co-Authored-By: DeepSeek (deepseek-v4-flash) <noreply@deepseek.com>

Common types: `feat`, `fix`, `test`, `refactor`, `chore`.  
Common scopes: `boot` (cloud-boot.sh/cloud-init.sh), `modules` (modules/*.sh),
`access`, `ssh`, `python`, `mail`, `ci` (.github/), `readme`.

If signing fails due to a locked key, stop and wait — do not fall back to an unsigned commit.
