# Blender Rigging Best Practices

> **Default rule:** Keep rigs as simple as the model and its required animations allow. Every bone, constraint, and control should have a clear purpose.

Follow [Blender Project Preferences](./blender-project-preferences.md) for character anatomy, detached parts, and naming requirements.

## Before Rigging

1. List the poses and animations the model must support before designing the skeleton.
2. Finish the model's proportions and intended rest pose before binding it to an armature.
3. Use one armature per character unless a separately reusable prop has a concrete reason to own another armature.
4. Apply rotation and scale on the armature and meshes before skinning. Avoid negative or non-uniform scale.
5. Keep the armature object at the world origin with a clean identity transform whenever practical.

## Bone Placement

- Place a bone's pivot at the center of the joint it rotates around, not merely at the center of the surrounding mesh.
- Align bone chains with the model's structure. The bone head should be at the parent-side joint and the tail should point toward the child-side joint.
- Put the root bone at the character origin, normally centered on the ground beneath the character. It should provide a stable parent for the entire rig.
- Put torso or body bones along the model's centerline. Place head, hand, boot, weapon, and accessory bones at their actual rotation pivots.
- For rigid separate parts, place the controlling bone so rotating it produces the intended hinge or swing without requiring translation correction.
- Deliberately detached parts may use spatially disconnected bones while remaining parented in the correct hierarchy.
- Connect bones only when their joints must share the same point. Parenting does not require the **Connected** option.
- Give bones enough visible length to select and understand them, but do not move a pivot merely to make a bone easier to select. Use custom control shapes instead.
- Check placement from front, side, and orthographic views. A rig that appears aligned from one view may be offset in depth.

## Bone Orientation And Roll

- Keep bone axes and roll consistent across comparable chains, especially `_L` and `_R` pairs.
- Recalculate or manually correct bone roll before adding constraints, IK, or animation.
- Mirror symmetrical bones using Blender's symmetrize tools when possible rather than rebuilding each side independently.
- Test local-axis rotation after adjusting roll. Similar left and right bones should respond predictably to equivalent local rotations.
- Do not change deform-bone orientation or rest transforms after animation or engine integration has begun unless all affected weights, constraints, and animations are updated.

## Hierarchy And Naming

- Use a stable hierarchy with one root bone. A typical hierarchy is `Root` -> `Torso` -> `Head`, hands, equipment, and other body parts as appropriate.
- Match the hierarchy to actual motion. Parent a weapon to the hand or body part that carries it; parent secondary parts to the bone whose motion they should inherit.
- Do not add anatomical chains that the model does not need, including chains for parts omitted by the project preferences.
- Use the descriptive names and paired-part suffixes defined by the project preferences. Keep names stable after export because Godot animation tracks and attachments may reference them.
- Give control-only bones a clear convention such as a `CTRL_` prefix, and mechanism/helper bones a convention such as `MCH_`.

## Deform And Control Bones

- Mark only bones that influence mesh vertices as **Deform**.
- Keep IK targets, pole targets, custom controls, and mechanical helper bones non-deforming.
- Prefer a small deformation skeleton with an optional control layer rather than mixing animation controls into the exported skeleton without need.
- Use custom bone shapes to make controls easy to select without changing deform-bone placement.
- Keep control constraints deterministic and avoid circular dependencies.
- Add IK only when it materially improves posing. Set an explicit chain length and place pole targets far enough from the limb plane to avoid flipping.
- Use **Child Of**, **Copy Transforms**, or similar constraints for switchable props only when simpler bone parenting cannot produce the required behavior.
- Apply or bake constraint-driven motion to exported deform bones when the export format or Godot import does not preserve the control setup reliably.

## Binding Meshes

### Rigid Parts

- Prefer bone parenting for a completely rigid separate object when it only follows one bone.
- Alternatively, use an Armature modifier and assign every vertex in the object to one deform bone at weight `1.0`.
- Do not use automatic weights for rigid low-poly parts. Blended weights can cause unwanted bending, gaps, and changing silhouettes.
- Keep each rigid object's origin and transform clean. Test its full rotation range around the controlling bone before animation.

### Deforming Meshes

- Use an Armature modifier and vertex groups whose names exactly match the deform bones.
- Automatic weights are only a starting point. Inspect and correct the result manually.
- Remove unintended influences, normalize weights, and limit each vertex to the fewest influences needed for clean deformation.
- Place enough topology around bending joints to support the required range of motion without collapsing or stretching badly.
- Test extreme poses, not just the rest pose. Check silhouettes, volume loss, clipping, and visible gaps.

## Rest Pose And Animation Readiness

- Use a neutral rest pose that makes symmetrical placement and weight editing straightforward while matching the character's intended range of motion.
- Set the final rest pose before authoring actions. Do not use **Apply Pose as Rest Pose** casually after animation work exists.
- Pose the rig through bones rather than armature-object or mesh-object transforms.
- Keep locomotion in place unless the gameplay design explicitly requires root motion.
- Use the root bone for deliberate whole-character motion; do not animate arbitrary deform bones as substitutes for a stable root.
- Verify detached hands, head, boots, weapons, and accessories remain aligned throughout representative poses.

## Godot Export

- Export the mesh, armature, skin, and required actions together in the game-ready `.glb`.
- Export only bones that are needed for deformation, animation playback, or runtime attachment. Exclude Blender-only controls and helpers when possible.
- Preserve bone names, hierarchy, and rest transforms between exports.
- Ensure every exported action animates the same stable skeleton and has a clear unique name.
- Bake animation when constraints or drivers are not represented directly by the export.
- Follow [Blender Models in Godot](./blender-models-in-godot.md) for the complete export, wrapper-scene, and reimport workflow.

## Validation Checklist

- Armature and mesh transforms are applied and free of negative or non-uniform scale.
- One stable root bone parents the required skeleton.
- Joint pivots are correctly placed in all orthographic views.
- Bone roll and local axes are consistent across mirrored parts.
- Only intended bones deform the mesh.
- Rigid parts have one full-weight influence or direct bone parenting.
- No vertices are unweighted or influenced by unintended bones.
- Extreme poses do not produce clipping, gaps, collapsing geometry, or IK flips.
- Bone names, hierarchy, and action names remain stable in the exported `.glb`.
- The imported skeleton, attachments, and animation tracks work in the Godot wrapper scene.
