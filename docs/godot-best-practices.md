# Godot Best Practices

These rules apply to project-owned Godot code and assets. Vendored code under `res://addons/` should be updated as a single upstream unit unless a task explicitly requires changing it.

## Requirement Levels

- **Must:** A project invariant required for correctness or maintainability.
- **Should:** The expected approach unless the task provides a concrete reason to differ.
- **Default:** A starting point that may be adjusted to fit the feature.

## Project Structure

- **Must:** Keep feature code under `res://features/`, authored gameplay data under `res://data/`, reusable scenes under `res://scenes/`, and runtime-ready assets under `res://assets/`.
- **Must:** Runtime code must not reference source files under `res://blender/`.
- **Should:** Compose systems explicitly in scenes and keep the top-level game controller focused on coordination rather than feature implementation.
- **Should:** Use typed custom `Resource` classes for authored gameplay definitions instead of duplicating values in scripts or scenes.

## GDScript

- **Must:** Use Godot 4.7-compatible APIs and typed GDScript for parameters, return values, properties, and local variables when the type is known.
- **Must:** Verify node paths, property names, signals, and engine APIs against the scene or Godot ClassDB instead of guessing.
- **Should:** Prefer signals for communication across feature boundaries and direct calls within one cohesive feature.
- **Should:** Keep lifecycle methods small; move substantial simulation or presentation behavior into clearly named methods or focused nodes.
- **Should:** Avoid unnecessary autoloads and global mutable state. Add an autoload only when its lifetime and cross-scene ownership require it.
- **Should:** Use input actions from the InputMap rather than hard-coded key checks for gameplay controls.

## Scenes And Resources

- **Must:** Do not depend on the internal node hierarchy of imported assets. Wrap imported models in project-owned Godot scenes.
- **Must:** Stop the running project before edits or reimports that Godot rejects while playing.
- **Should:** Reference required scene children with stable paths and fail clearly when required dependencies are absent.
- **Should:** Keep engine-specific animation playback, collision, particles, audio, and scripts in wrapper scenes rather than imported GLB files.
- **Default:** Prefer reusable scenes and resources over constructing large persistent hierarchies entirely in code.

## Testing And Validation

- **Must:** Follow the authoritative [gamespec and acceptance-test policy](../AGENTS.md#gamespec) in `AGENTS.md`.
- **Must:** Run relevant tests after game changes and inspect Godot editor and game logs for parse, load, and runtime errors.
- **Should:** Test observable behavior instead of private method names or incidental node structure unless that architecture is itself an explicit requirement.
- **Should:** Verify presentation changes at the target viewport size and in the running game, not only in the editor.
