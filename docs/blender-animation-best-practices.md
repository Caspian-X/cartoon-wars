# Blender Animation Best Practices

> **Default rule:** Animation must communicate gameplay clearly at game camera distance. Prefer strong poses, readable timing, and stable reusable clips over unnecessary motion or complexity.

## Before Animating

1. List every required clip and its gameplay purpose before creating actions.
2. Confirm the rig, rest pose, bone names, constraints, and skinning are final enough to animate. Follow [Blender Rigging Best Practices](./blender-rigging-best-practices.md).
3. Decide which clips loop, which play once, and which gameplay moment each one must communicate.
4. Establish the project's frame rate before timing actions. Do not change it midway through animation production.
5. Gather reference for motion, weight, posing, and timing when the movement is not already well understood.
6. Test the model from the expected Godot gameplay camera. Details that only read in a close Blender view are not sufficient.

## Actions And Naming

- Store each exported clip as a separate Blender action with a concise stable name such as `Idle`, `Walk`, `Attack`, `Hit`, or `Death`.
- In Blender versions with Action Slots, every action for the same armature must use a compatible slot with the same target ID type and identifier. Name the actions after clips, but keep their slots associated with the armature object; giving each slot the clip name can make only one action evaluate when switching clips.
- Use names consistently across related characters when clips have the same gameplay meaning.
- Give every action an intentional frame range. Remove accidental keys outside that range.
- Keep only actions intended for the asset. Delete obsolete duplicates and test actions before export.
- Protect required actions from accidental loss using the workflow appropriate for the Blender version, such as assigning them in the NLA or retaining them as saved data-blocks.
- Do not rename exported actions after Godot code or wrapper scenes depend on their clip names unless those references are updated together.
- Keep one clear source action for each clip rather than maintaining indistinguishable variants such as `Attack.001` and `Attack_final`.

## Posing Workflow

- Animate the armature through pose bones and controls. Do not animate mesh-object transforms as a substitute for skeletal animation.
- Block the main storytelling poses first using stepped or constant interpolation. Refine timing before polishing curves.
- Build poses from the character's center of mass outward. Establish torso and root motion before secondary parts.
- Check silhouettes from the gameplay camera. Hands, weapons, boots, and the head should not merge into unreadable shapes at important moments.
- Push anticipation, contact, recoil, and recovery poses enough to remain readable for the project's stylized low-poly characters.
- Preserve intentional asymmetry. Perfectly mirrored poses often appear static unless symmetry is required by the motion.
- Use arcs for heads, hands, weapons, and other visible moving parts unless the motion is intentionally mechanical.
- Respect the project's detached-part style. Floating hands, heads, boots, and other parts should move as a coordinated character without exposing accidental offsets or gaps.
- Key all controls required to establish a clip's starting pose so playback does not depend on the previously viewed Blender action.
- Do not key controls that have no effect on the clip unless consistent boundary keys are needed for reliable blending.

## Timing And Spacing

- Time motion according to gameplay needs first. Attacks must communicate anticipation, impact, and recovery within the duration expected by game logic.
- Hold important poses long enough to read, especially anticipation, attack contact, hit reaction, and death poses.
- Avoid uniform movement. Vary spacing to show acceleration, impact, weight, and settling.
- Keep transitions into and out of clips compatible with the states that can precede or follow them in Godot.
- Review animations at real-time speed frequently. Scrubbing and slow playback can hide weak timing.
- Preview at the expected game scale and camera distance, not only in close-up.
- Use motion trails, frame stepping, and viewport playback to check arcs and spacing rather than relying only on F-curves.

## Rotation And Curves

- Choose an appropriate rotation mode before animating a control and keep it stable throughout the action.
- Use quaternion rotation for broad free 3D motion when avoiding gimbal lock is more important than per-axis curve editing.
- Use Euler rotation for controls constrained to predictable axes when its curves are easier to author and inspect.
- Do not switch rotation modes inside an action unless there is a specific tested need.
- Inspect the Graph Editor after blocking. Remove overshoot, wobble, sudden velocity changes, and long handles that create unintended motion.
- Use constant interpolation during blocking, then deliberately choose bezier or linear interpolation during refinement.
- Keep curve handles and easing consistent for related controls, but do not flatten curves so much that the motion loses weight.
- Reduce redundant keys only after confirming the simplified curves preserve the intended pose and timing.

## Looping Clips

- Make the start and end of a looping clip join without a visible pop in pose, position, rotation, or velocity.
- Treat the loop as continuous motion across the boundary. Adjust curves with the boundary in view rather than matching only two static poses.
- Avoid an unintended pause caused by exporting duplicate start and end poses for two consecutive playback samples.
- For walk cycles, keep foot contacts consistent, prevent planted feet from sliding, and verify left/right timing is balanced.
- Add subtle variation to idle motion without making the character look distracted or obscuring gameplay state.
- Test loops for many repetitions in Blender and again in Godot. A seam may become visible only after import or blending.

## Root Motion And Movement

- Keep locomotion clips in place unless the game's movement system explicitly consumes root motion.
- Animate intentional whole-character displacement on the stable root bone, never through arbitrary mesh or armature-object transforms.
- Keep the root's height and orientation stable in in-place cycles unless bobbing, leaning, or turning is part of the intended motion.
- Separate visual motion from gameplay translation. Godot should normally move the character while the clip provides the matching in-place movement.
- If root motion is required, document which root bone and axes carry it and verify Godot extracts the same transform correctly.

## Gameplay Animations

### Attacks

- Clearly separate anticipation, active impact, and recovery phases.
- Put the visual contact frame at a precise known time so Godot can synchronize damage, audio, particles, and hit feedback.
- Keep weapon and hand alignment stable through the strike. Avoid clipping that obscures the attack direction.
- Do not embed gameplay damage logic in the Blender action. Author the visual clip in Blender and trigger gameplay behavior in Godot.

### Hit Reactions And Death

- Make the direction and force of a hit readable without moving the character so far that it conflicts with gameplay position.
- Return to a blendable pose at the end of a recoverable hit reaction.
- Death clips should settle into a stable final pose without requiring the clip to continue indefinitely.
- Avoid final-pose intersections that become obvious when the body remains on screen.

### Idle And Locomotion

- Keep idle movement restrained so it does not compete with attacks, damage feedback, or selection indicators.
- Match visible foot or boot cadence to the movement speed expected in Godot.
- Keep the torso, equipment, and detached parts coordinated so locomotion feels like one character rather than unrelated objects.

## Constraints And Baking

- Animate animator-facing controls rather than manually fighting constrained deform bones.
- Keep IK/FK state intentional throughout each action. Avoid unkeyed switches that cause snapping.
- Bake constraint-driven animation to exported deform bones when the `.glb` cannot reproduce the Blender control rig directly.
- Visually compare the baked result with the original before export.
- Remove or exclude control-only animation tracks that Godot does not need.
- Do not bake at a lower sample rate if it visibly changes fast attacks, impacts, or constrained motion.

## Godot Export

- Export the required actions with the same mesh, armature, and skin in the game-ready `.glb`.
- Preserve the action names, skeleton hierarchy, bone names, and rest transforms expected by Godot.
- Confirm each action exports only its intended frame range and does not include neighboring action keys.
- Bake animations when required for constraints, drivers, or control rigs that glTF does not preserve.
- Keep animation data on the skeleton whenever practical so clips share compatible tracks and blend correctly.
- Use Godot for clip selection, blending, state transitions, procedural aiming, and synchronization of damage, particles, audio, and other gameplay events.
- Follow [Blender Models in Godot](./blender-models-in-godot.md) for export, wrapper-scene, and reimport requirements.

## Validation Checklist

- Every required gameplay animation has one clearly named action.
- Selecting each action automatically resolves a compatible Action Slot on the intended armature and evaluates its keyed pose.
- Actions use intentional frame ranges with no stray keys.
- Important poses and silhouettes read from the gameplay camera.
- Timing clearly communicates anticipation, impact, recovery, and state changes.
- Curves contain no accidental pops, flips, overshoot, sliding, or wobble.
- Loop boundaries are seamless in both pose and velocity.
- Locomotion stays in place unless root motion is explicitly required.
- Detached parts, hands, weapons, and equipment remain aligned throughout each clip.
- Constraint-driven motion survives baking and export without visible changes.
- Godot imports every expected clip under the expected name and all bone tracks resolve.
- Clips loop, play once, transition, and blend correctly in the Godot wrapper scene.
- Gameplay events occur at the intended visual moments after import.
