## Godot
This is a godot project.

Always use the godot best practices.

## Gamespec

The [gamespec.md](./docs/gamespec.md) is a file that defines states of the game, flow, rules, etc.

Always reference the gamespec before making changes to the game to see know how the game works and how parts of it that you may be updating/adding fit into the current state of the game.

After implementing changes to the game you need to check if you should update the gamespec to stay up to date. Report back to the user with a small bulleted list what changes were made. Also tell the user if no changes were made.

Important gamespec requirements must have automated acceptance tests. When a requirement changes, update both the gamespec and its tests in the same change. Before finishing game work, run the relevant tests and verify that unchanged requirements still pass; add missing coverage when a regression reveals an untested requirement.

Organize gamespec tests by applicable `##` headings (for example `test_game_states.gd`, `test_rules.gd`, and `test_ui_feedback.gd`). Use focused tests for important behaviors within each heading; descriptive headings such as the glossary and open questions do not need tests. Prefer a few meaningful acceptance tests over one test per sentence.

## Blender

If you need to use blender and the blender MCP is not started you can start it with the `just mcp` command.

When you are working in blender and find something that contradicts the blender guide files, please update them.

### Guides

When using blender, load the [blender-best-practices.md](./docs/blender-best-practices.md) file and follow the best practices.

When rigging a model in Blender, also load [blender-rigging-best-practices.md](./docs/blender-rigging-best-practices.md) and follow its bone, skinning, control, and validation guidance.

When animating a model in Blender, also load [blender-animation-best-practices.md](./docs/blender-animation-best-practices.md) and follow its action, posing, timing, export, and validation guidance.

When using models in the game engine, load this file: [blender-models-in-godot.md](./docs/blender-models-in-godot.md).
