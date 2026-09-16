# software-factory

This repository *is* the skills. There is no application to build.

- Skills live in `.agents/skills/`. Shared facts live in `.agents/references/`. Tracker verbs live in `.agents/bindings/`.
- One home per fact. If a rule appears in two skills, move it to `references/` and point both at it.
- Product-specific lore (a lookup that must not return zero, a `private/` tree, a `cfg` pitfall) does not belong here. It belongs in the consuming repo's `AGENTS.md`.
- Scripts in `.agents/scripts/` report. They do not claim, merge, or close. `test-skill-docs` is mechanical lint of this kernel, not an authority engine.
- Default binding is GitHub Issues. Do not GitHub-wash Pyramid examples into the kernel.
- Do not reintroduce an all-in-one `backlog` skill. Intake, grooming, dispatch, implement, coordinate, review, and audit stay separate.

When editing a skill, load it and the references it points to, and apply the same proportionality rule the skills teach: if a sentence does not change agent behavior, delete it.
