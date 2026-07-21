# Blender Best Practices

> **Default rule:** Anything not explicitly covered in this file should follow standard Blender best practices and conventions.

## Requirement Levels

- **Must:** A project invariant required for correct style or integration.
- **Should:** The expected approach unless the asset has a concrete reason to differ.
- **Default:** A starting point that should be adjusted for the asset and its use.
- Unlabeled guidance should be treated as **Should**.

## Style

### General
- **Must:** Use a faceted low-poly style with hard, unsmoothed edges.

### Character
- **Must:** Characters have no facial features such as a mouth, nose, or eyes.
- **Must:** Characters have no arms. Hands may be sphere-like shapes attached to held objects or may float in a natural position.
- **Default:** Heads and other body parts may float detached from the torso when it supports the character design.

## Structure

### Parts
- **Should:** Keep rigid character parts as separate objects when they need independent rigging or animation. A deliberately deforming continuous mesh may remain joined.
- **Must:** When placing objects, account for the parent object's rotation before placing the child.

### Naming
- Use clear, descriptive names for each object (e.g. `Head`, `Torso`, `Boot_L`).
- Use `_L` / `_R` suffixes for symmetrical left/right parts.
- For anything not covered here, follow Blender's default naming conventions.

## Material
- Always use node-based materials (Principled BSDF or another shader connected to Material Output) so colors show up in the rendered view. Legacy non-node materials only display in viewport preview and do not render.
- Choose a shader appropriate for the object: Principled BSDF for most surfaces, Emission for glowing objects, Glossy for shiny surfaces, etc.
- Maintain a consistent color theme across related parts (e.g. a soldier might use navy blue for cloth, brown leather for armor, dark steel for the helmet).

## Lighting
For isolated asset review renders, use this four-light setup as a default. Environment scenes and in-game wrapper scenes may use lighting designed for their actual context.

| Light | Type | Role | Settings |
|---|---|---|---|
| Key | Area | Main warm light, front-right of model | 200W, size 2.0, warm white `(1.0, 0.95, 0.85)` |
| Fill | Area | Softer cool fill, left side | 80W, size 3.0, cool blue `(0.85, 0.9, 1.0)` |
| Rim | Area | Back edge highlight for silhouette definition | 150W, size 1.5, neutral warm `(1.0, 0.98, 0.95)` |
| Bottom Fill | Area | Subtle under-fill to prevent pure black undersides | 30W, size 4.0, cool subtle `(0.7, 0.75, 0.85)` |

- All lights should have shadows enabled.
- Adjust energies and positions to suit the model's size and desired mood.

## World & Render Settings
- World background: medium blue-gray `(0.15, 0.15, 0.2)` at strength 0.8.
- Use EEVEE as the default render engine for quick viewport feedback.
- Switch to Rendered view or Material Preview in the viewport to verify lighting and materials.

## Post Creation
- Set the camera up properly so that the full model is in view.
- Verify materials and lighting look correct in Rendered view before exporting.
