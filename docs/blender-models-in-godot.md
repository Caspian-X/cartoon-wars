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

### Use an armature before animating characters

A well-planned bone structure generally produces better, more reusable animation than animating mesh objects directly. It gives each clip a consistent set of controls, supports cleaner arcs and poses, allows clips to blend in Godot, and makes later model changes less likely to invalidate animation tracks.

For this project's characters:

1. Create one armature with a stable root bone and clearly named bones such as `Torso`, `Head`, `Hand_L`, `Hand_R`, `Weapon`, `Boot_L`, and `Boot_R`. Keep `_L` and `_R` suffixes consistent.
2. Match the rig to the model's actual articulation. Do not add unnecessary deform chains to intentionally rigid or floating low-poly parts.
3. For separate rigid parts, parent each object to its controlling bone or give all of its vertices full weight to one bone. Use smooth weight painting only where a mesh is intended to bend.
4. Add control bones or constraints when they improve authoring, but export only bones and constraints needed by the deformation rig and animation. Keep control-only bones non-deforming.
5. Apply mesh and armature transforms before skinning, avoid negative or non-uniform scale, and establish the final rest pose before creating actions.
6. Animate bones rather than object transforms so every action targets the same skeleton. Keep locomotion in place unless gameplay explicitly requires root motion.
7. Test extreme poses for detached parts, weapon alignment, clipping, and unwanted deformation before building all animation clips.
8. Do not rename or remove exported deform bones after Godot scenes depend on them unless the affected imports, tracks, and wrapper scenes are updated together.

### For animated characters, use this workflow:

1. Rig and animate the character in Blender with clearly named `Idle`, `Walk`, `Attack`, and `Death` actions as applicable.
2. Export the mesh, skeleton, skin, materials, and animation clips together in the game-ready `.glb` file.
3. Verify that Godot imports the clips into an `AnimationPlayer` and that their node and bone tracks resolve correctly.
4. Use the Godot wrapper scene to select, play, and blend imported clips based on gameplay state.
5. Synchronize attacks, particles, audio, and damage with animation timing through method tracks, signals, or explicit timing data.
6. Keep only genuinely procedural motion, such as aiming or contextual recoil, in Godot. Do not replace authored character animation with whole-model tilting or ad hoc per-part transforms when proper clips can be authored in Blender.

## Reimporting Updated Models

After re-exporting a `.glb` with changed geometry, materials, rigging, or animations:

1. Stop the running project before reimporting. Godot may otherwise retain the previous imported scene in memory.
2. Export over the existing game-ready file under `res://assets/models/`, not the source file under `res://blender/`.
3. Allow the editor filesystem scan to finish. If the change is not detected, run a full filesystem scan.
4. Force reimport the updated `.glb` from the Godot FileSystem dock. With Godot AI, call `filesystem_manage(op="reimport", paths=["res://assets/models/.../model.glb"])` after playback has stopped.
5. Restart the game or reopen any scene that already instantiated the model so cached `PackedScene` resources are replaced.
6. Verify the imported `AnimationPlayer` contains the expected clip names and that the live instance is playing the updated tracks. Checking only the Blender file is not sufficient.

If Godot still shows an older animation, stop playback again, force a full filesystem scan, reimport the `.glb`, and restart the game. Do not work around a stale import by referencing the `.blend` file directly or by bypassing the Godot wrapper scene.
