# Blender Best Practices

## Style

### General
- Faceted low poly with lots of edges but no smooth edges.

### Character
- Hands of humans should be sphere-like, attached to objects they are holding. Having the hand(s) floating in a normal hand position, if they aren't holding an object or only require one hand to hold the object, is ok too.
- Should not have arms.
- No facial features like mouth, nose, eyes, etc.

### Material
- Always use node-based materials (Principled BSDF or another shader connected to Material Output) so colors show up in the rendered view. Legacy non-node materials only display in viewport preview and do not render.
- Choose a shader appropriate for the object: Principled BSDF for most surfaces, Emission for glowing objects, Glossy for shiny surfaces, etc.

## When creating a single object
- Parts should all be connected visually.
- Parts should be separate objects and not a single joined mesh so that they can be imported into the game engine and animated, etc.
- When placing objects, for example if object A needs to be attached to the tip of object B, account for the object B's rotation before placing object A.

## Post creation
- Set the camera up properly so that the full model is in view.
