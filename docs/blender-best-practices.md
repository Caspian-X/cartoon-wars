# Blender Best Practices

> **Default rule:** Anything not explicitly covered in this file should follow standard Blender best practices and conventions.

Project-specific art and production choices are defined in [Blender Project Preferences](./blender-project-preferences.md).

## Structure

### Parts
- When placing objects, account for the parent object's rotation before placing the child.

### Naming
- Follow Blender's default naming conventions for anything not defined by the project preferences.

## Material
- Always use node-based materials (Principled BSDF or another shader connected to Material Output) so colors show up in the rendered view. Legacy non-node materials only display in viewport preview and do not render.
- Choose a shader appropriate for the object: Principled BSDF for most surfaces, Emission for glowing objects, Glossy for shiny surfaces, etc.

## Review

- Switch to Rendered view or Material Preview in the viewport to verify lighting and materials.
- Verify materials and lighting look correct in Rendered view before exporting.
