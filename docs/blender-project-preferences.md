# Blender Project Preferences

These are Cartoon Wars-specific art and production choices. Follow them in addition to [Blender Best Practices](./blender-best-practices.md).

## Requirement Levels

- **Must:** A required part of the project's visual identity or asset integration.
- **Should:** The expected choice unless the asset has a concrete reason to differ.
- **Default:** A starting point that may be adjusted for the asset and its use.

## Visual Style

- **Must:** All authored 3D assets, including characters, props, environments, and effects, use a faceted low-poly style with hard, unsmoothed edges.
- **Should:** Preserve readable silhouettes and major forms at the expected Godot gameplay camera distance.

## Characters

- **Must:** Characters have no facial features such as a mouth, nose, or eyes.
- **Must:** Characters have no arms.
- **Should:** Use sphere-like hands attached to held objects or floating in a natural position when unoccupied.
- **Default:** Heads, hands, boots, and other body parts may float detached from the torso when it supports the character design.
- **Must:** Deliberately detached parts must still read as one coordinated character in representative poses and animations.

## Modeling And Naming

- **Should:** Keep rigid character parts as separate objects when they need independent rigging or animation. A deliberately deforming continuous mesh may remain joined.
- **Should:** Use clear object and bone names such as `Head`, `Torso`, `Hand_L`, `Hand_R`, `Boot_L`, `Boot_R`, and `Weapon`.
- **Must:** Use `_L` and `_R` suffixes for paired left and right objects and bones.

## Materials And Color

- **Should:** Maintain a coherent color theme across related parts of an asset.
- **Should:** Keep material contrast strong enough for adjacent parts to remain distinguishable at gameplay scale.

## Character Animation

- **Must:** Gameplay characters provide clearly named `Idle`, `Walk`, `Attack`, and `Death` actions when those states apply.
- **Must:** Keep locomotion actions in place unless the game's movement architecture is intentionally changed to consume root motion.
- **Should:** Favor strong poses and readable timing over subtle motion that disappears at gameplay scale.
- **Must:** Keep deliberately detached body parts visually coordinated throughout every action.

## Asset Review Setup

Use this four-light setup as the default for isolated asset review. Environment scenes and in-game wrapper scenes may use lighting designed for their actual context.

| Light | Type | Role | Settings |
|---|---|---|---|
| Key | Area | Main warm light, front-right of model | 200W, size 2.0, warm white `(1.0, 0.95, 0.85)` |
| Fill | Area | Softer cool fill, left side | 80W, size 3.0, cool blue `(0.85, 0.9, 1.0)` |
| Rim | Area | Back edge highlight for silhouette definition | 150W, size 1.5, neutral warm `(1.0, 0.98, 0.95)` |
| Bottom Fill | Area | Subtle under-fill to prevent pure black undersides | 30W, size 4.0, cool subtle `(0.7, 0.75, 0.85)` |

- **Should:** Enable shadows on all review lights.
- **Default:** Use a medium blue-gray world background `(0.15, 0.15, 0.2)` at strength `0.8`.
- **Default:** Use EEVEE for fast asset-review feedback.
- **Should:** Frame the complete model with the review camera.
