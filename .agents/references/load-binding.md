# Which tracker

Read `.agents/binding` before any tracker verb. If the file is absent, treat `tracker` as `github`. Do not infer the tracker from the repo name, `DESIGN.md`, or conversation.

| `tracker` value | Load |
| --- | --- |
| `github` | [bindings/github.md](../bindings/github.md) |
| `pyramid` | [bindings/pyramid.md](../bindings/pyramid.md) |

A consuming repo changes that one file. It does not copy and edit the skills.
