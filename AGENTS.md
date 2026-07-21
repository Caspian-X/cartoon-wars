## Godot

This is a Godot project. Before changing Godot scenes, scripts, resources, project settings, or tests, read and follow [godot-best-practices.md](./docs/godot-best-practices.md).

## Gamespec

The [gamespec.md](./docs/gamespec.md) defines the game's observable states, flow, rules, data, UI requirements, and runtime architecture.

Read the relevant sections before changing gameplay behavior, game flow, balance, UI requirements, gameplay data, or runtime architecture. Documentation-only, tooling, and unrelated build changes do not require loading the full gamespec.

After changing the game, update the gamespec when observable behavior or an intentional architectural requirement changed. Do not add incidental implementation details. In the final response, include a small bulleted list of gamespec changes or state that no gamespec changes were needed.

Important gamespec requirements must have automated acceptance tests. When a requirement changes, update both the gamespec and its tests in the same change. Before finishing game work, run the relevant tests and verify that unchanged requirements still pass; add missing coverage when a regression reveals an untested requirement.

Organize gamespec tests by applicable `##` headings (for example `test_game_states.gd`, `test_rules.gd`, and `test_ui_feedback.gd`). Use focused tests for important behaviors within each heading; descriptive headings such as the glossary and open questions do not need tests. Prefer a few meaningful acceptance tests over one test per sentence.

## Documentation Maintenance

When project work reveals that a guide is incorrect or incomplete, update it only when the finding is verified and broadly reusable. Do not turn a task-specific workaround into project-wide policy. Preserve intentional project conventions even when they differ from general best practices. Keep guide changes narrowly scoped, report them separately in the final response, and ask before changing ambiguous visual or game-design intent.

## Blender

If Blender work requires the MCP and it is not started, run `just mcp`.

### Guides

Before creating or changing Blender assets, read [blender-project-preferences.md](./docs/blender-project-preferences.md) and [blender-best-practices.md](./docs/blender-best-practices.md).

When changing armatures, bones, constraints, or skinning, also read [blender-rigging-best-practices.md](./docs/blender-rigging-best-practices.md).

When changing actions or animation, also read [blender-animation-best-practices.md](./docs/blender-animation-best-practices.md).

When exporting, importing, reimporting, or using a Blender asset in Godot, also read [blender-models-in-godot.md](./docs/blender-models-in-godot.md).
