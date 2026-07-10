# Blender Best Practices

> **Default rule:** Anything not explicitly covered in this file should follow standard Blender best practices and conventions.

## Style

### General
- Faceted low poly with lots of edges but no smooth edges.

### Character
- No facial features (mouth, nose, eyes, etc.).
- No arms. Hands may exist as sphere-like shapes attached to objects they are holding, or floating in a natural hand position if unoccupied or the object only requires one hand.
- Head and other body parts may float detached from the torso (e.g. removing the neck and leaving the head suspended above). This is a valid stylistic choice.

## Structure

### Parts
- Parts should be separate objects, not a single joined mesh, so they can be imported into the game engine and animated.
- When placing objects, account for the parent object's rotation before placing the child (e.g. if object A attaches to the tip of object B, place A relative to B's rotated transform).

### Naming
- Use clear, descriptive names for each object (e.g. `Head`, `Torso`, `Boot_L`).
- Use `_L` / `_R` suffixes for symmetrical left/right parts.
- For anything not covered here, follow Blender's default naming conventions.

## Material
- Always use node-based materials (Principled BSDF or another shader connected to Material Output) so colors show up in the rendered view. Legacy non-node materials only display in viewport preview and do not render.
- Choose a shader appropriate for the object: Principled BSDF for most surfaces, Emission for glowing objects, Glossy for shiny surfaces, etc.
- Maintain a consistent color theme across related parts (e.g. a soldier might use navy blue for cloth, brown leather for armor, dark steel for the helmet).

## Lighting
Use a standard four-light setup:

| Light | Type | Role | Settings |
|---|---|---|---|
| Key | Area | Main warm light, front-right of model | 200W, size 2.0, warm white `(1.0, 0.95, 0.85)` |
| Fill | Area | Softer cool fill, left side | 80W, size 3.0, cool blue `(0.85, 0.9, 1.0)` |
| Rim | Area | Back edge highlight for silhouette definition | 150W, size 1.5, neutral warm `(1.0, 0.98, 0.95)` |
| Bottom Fill | Area | Subtle under-fill to prevent pure black undersides | 30W, size 4.0, cool subtle `(0.7, 0.75, 0.85)` |

- All lights should have shadows enabled.
- Adjust energies and positions to suit the model's size and desired mood.

## World & Render Settings
- World background: dark blue-gray `(0.05, 0.05, 0.08)` at strength 0.3.
- Use EEVEE as the default render engine for quick viewport feedback.
- Switch to Rendered view or Material Preview in the viewport to verify lighting and materials.

## Post Creation
- Set the camera up properly so that the full model is in view.
- Verify materials and lighting look correct in Rendered view before exporting.
