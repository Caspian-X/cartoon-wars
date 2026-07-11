# Blender Models in Godot

## Before using a Blender model in Godot:

1. Export a game-ready `.glb` file into the appropriate directory under `res://assets/models/`.
2. Exclude Blender-only cameras, lights, reference objects, and display geometry from the export.
3. Preserve clear object, material, skeleton, and animation names needed by Godot.
4. Create a Godot wrapper scene under `res://scenes/` for engine-specific animation playback, particles, collision, audio, lighting, and scripts.
5. Game code must reference the exported asset or its wrapper scene, never a file under `res://blender/`.

## Godot Wrapper Scenes

Instance each GLB inside a Godot scene, add any Godot-specific configuration there, and use that scene as the model everywhere else in the game. This keeps game code independent of the imported GLB hierarchy and preserves Godot setup when the GLB is re-exported.

## Animations

Use Blender for authored character animation such as idle, walk, attack, and death clips. Use Godot to select and blend those clips, synchronize gameplay events, and implement runtime effects such as particles, audio, hit feedback, and procedural aiming.

### For animated characters, use this workflow:

1. Rig and animate the character in Blender with clearly named `Idle`, `Walk`, `Attack`, and `Death` actions as applicable.
2. Export the mesh, skeleton, skin, materials, and animation clips together in the game-ready `.glb` file.
3. Verify that Godot imports the clips into an `AnimationPlayer` and that their node and bone tracks resolve correctly.
4. Use the Godot wrapper scene to select, play, and blend imported clips based on gameplay state.
5. Synchronize attacks, particles, audio, and damage with animation timing through method tracks, signals, or explicit timing data.
6. Keep only genuinely procedural motion, such as aiming or contextual recoil, in Godot. Do not replace authored character animation with whole-model tilting or ad hoc per-part transforms when proper clips can be authored in Blender.
