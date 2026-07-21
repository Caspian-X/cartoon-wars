# Blender Best Practices

> **Default rule:** When guidance is absent, use Blender conventions appropriate to the asset. Ask before making a choice that affects visual or gameplay intent.

Project-specific art and production choices are defined in [Blender Project Preferences](./blender-project-preferences.md).

## Structure

### Parts
- When placing objects, account for the parent object's rotation before placing the child.

### Naming
- Follow Blender's default naming conventions for anything not defined by the project preferences.

## Materials

- Use node-based materials with a shader connected to Material Output. Viewport display colors alone are not reliable in EEVEE renders or glTF exports.
- Use Principled BSDF for most surfaces, Emission for intentionally self-lit surfaces, and specialized shaders only when the asset has a concrete need.

## Review

- Switch to Rendered view or Material Preview in the viewport to verify lighting and materials.
- Verify materials and lighting look correct in Rendered view before exporting.
