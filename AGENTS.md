# Instructions for coding agents

This repository is the **Maori Health** Flutter app (`maori_health`).

1. **Start here:** [`docs/ai-knowledge-base.md`](docs/ai-knowledge-base.md) — architecture, DI, conventions, commands.
2. **Cursor:** Project rules live in [`.cursor/rules/`](.cursor/rules/) (always-on summary + link to the doc above).
3. **Human-oriented docs:** [`README.md`](README.md) (setup, structure, contributing flow).

When implementing features, keep **BLoC → use case → repository**; never wire **data sources** into BLoCs.
