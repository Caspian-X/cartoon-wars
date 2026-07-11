import math
import os

import bpy


FPS = 24
CLIPS = {
    "Idle": (1, 48),
    "Walk": (1, 24),
    "Attack": (1, 30),
    "Death": (1, 30),
}


def remove_old_animation():
    for obj in list(bpy.data.objects):
        if obj.type == "ARMATURE":
            bpy.data.objects.remove(obj, do_unlink=True)
        elif obj.animation_data:
            obj.animation_data_clear()
    for action in list(bpy.data.actions):
        bpy.data.actions.remove(action)


def clear_rig_animation(rig):
    rig.animation_data_clear()
    for action in list(bpy.data.actions):
        bpy.data.actions.remove(action)


def create_rig(meshes):
    armature_data = bpy.data.armatures.new("CharacterRig")
    rig = bpy.data.objects.new("CharacterRig", armature_data)
    bpy.context.collection.objects.link(rig)
    bpy.context.view_layer.objects.active = rig
    rig.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")

    root = armature_data.edit_bones.new("Root")
    root.head = (0.0, 0.0, 0.0)
    root.tail = (0.0, 0.0, 0.25)
    for obj in meshes:
        bone = armature_data.edit_bones.new(obj.name)
        bone.head = obj.location
        bone.tail = (obj.location.x, obj.location.y, obj.location.z + 0.2)
        bone.parent = root
    bpy.ops.object.mode_set(mode="OBJECT")

    for obj in meshes:
        world = obj.matrix_world.copy()
        obj.parent = rig
        obj.parent_type = "BONE"
        obj.parent_bone = obj.name
        obj.matrix_world = world
    return rig


def pose_values(name, unit, clip, frame):
    lower = name.lower()
    is_left = "_l" in lower or "left" in lower
    is_right = "_r" in lower or "right" in lower
    is_leg = "leg" in lower or "boot" in lower
    is_body = any(part in lower for part in ("torso", "body", "chest", "belt"))
    is_head = "head" in lower or "hat" in lower
    is_weapon = any(part in lower for part in ("spear", "staff", "orb"))
    is_hand = "hand" in lower
    location = [0.0, 0.0, 0.0]
    rotation = [0.0, 0.0, 0.0]
    scale = [1.0, 1.0, 1.0]

    if clip == "Idle":
        wave = math.sin((frame - 1) / 47.0 * math.tau)
        if is_body or is_head or is_weapon or is_hand:
            location[2] = 0.025 * wave
    elif clip == "Walk":
        wave = math.sin((frame - 1) / 23.0 * math.tau)
        side = -1.0 if is_right else 1.0
        if "leg" in lower:
            rotation[2] = 0.32 * wave * side
            location[0] = 0.07 * wave * side
            location[2] = 0.03 * max(0.0, wave * side)
        elif "boot" in lower:
            foot_phase = wave * side
            location[0] = 0.19 * foot_phase
            location[2] = 0.09 * max(0.0, foot_phase)
            rotation[2] = -0.14 * foot_phase
        elif is_body or is_head:
            location[2] = 0.035 * abs(wave)
            rotation[2] = -0.025 * wave
        elif is_weapon or is_hand:
            location[2] = 0.02 * abs(wave)
            rotation[2] = -0.02 * wave
    elif clip == "Attack":
        phase = (frame - 1) / 29.0
        if unit == "spearman":
            lower_amount = min(1.0, phase / 0.30)
            lower_amount = lower_amount * lower_amount * (3.0 - 2.0 * lower_amount)
            thrust = max(0.0, math.sin((phase - 0.30) / 0.70 * math.pi)) if phase >= 0.30 else 0.0
            spear_angle = math.radians(78.0) * lower_amount
            spear_forward = 0.62 * thrust
            if "spearshaft" in name.lower():
                location[0] = spear_forward
                location[2] = -0.16 * lower_amount
                rotation[2] = spear_angle
            elif "speartip" in name.lower():
                location[1] = -1.15 * lower_amount
            elif "hand_l" in lower:
                location[0] = 0.65 * lower_amount + spear_forward
                location[1] = -0.10 * lower_amount
                location[2] = 0.30 * lower_amount - 0.16 * lower_amount
                rotation[2] = spear_angle
            elif "hand_r" in lower:
                location[0] = -0.35 * lower_amount + spear_forward
                location[1] = -0.10 * lower_amount
                location[2] = -0.20 * lower_amount - 0.16 * lower_amount
                rotation[2] = spear_angle
            elif is_body or is_head or "chest" in lower or "belt" in lower:
                location[0] = 0.12 * thrust
                rotation[2] = 0.10 * lower_amount - 0.22 * thrust
            elif is_leg:
                location[0] = (-0.10 if is_left else 0.10) * lower_amount
                rotation[2] = (-0.16 if is_left else 0.16) * lower_amount
        else:
            amount = math.sin(phase * math.pi) ** 3
            if is_weapon or is_hand:
                location[0] = 0.32 * amount
                rotation[1] = -0.35 * amount
            elif is_body or is_head:
                location[0] = 0.09 * amount
                rotation[1] = -0.12 * amount
    elif clip == "Death":
        if unit == "spearman":
            burst = max(0.0, (frame - 7) / 23.0)
            seed = sum((index + 1) * ord(char) for index, char in enumerate(name))
            angle = math.radians(seed % 360)
            speed = 0.8 + (seed % 7) * 0.12
            location[0] = math.cos(angle) * speed * burst
            location[1] = math.sin(angle) * speed * 0.55 * burst
            location[2] = (1.4 + (seed % 5) * 0.14) * burst - 1.15 * burst * burst
            rotation[0] = burst * math.radians(180 + seed % 220)
            rotation[1] = burst * math.radians(140 + (seed * 3) % 260)
            rotation[2] = burst * math.radians(120 + (seed * 7) % 300)
            squash = 1.0 + 0.08 * math.sin(min(1.0, burst * 5.0) * math.pi)
            scale = [squash, squash, squash]
        else:
            amount = min(1.0, (frame - 1) / 29.0)
            amount = amount * amount * (3.0 - 2.0 * amount)
            fall_sign = -1.0 if is_left else 1.0
            if is_leg:
                location[1] = 0.12 * fall_sign * amount
            location[2] = -0.45 * amount
            rotation[1] = math.radians(82.0) * amount
            rotation[2] = 0.12 * fall_sign * amount
    return location, rotation, scale


def create_actions(rig, meshes, unit):
    rig.animation_data_create()
    for clip, (start, end) in CLIPS.items():
        action = bpy.data.actions.new(clip)
        rig.animation_data.action = action
        frames = range(start, end + 1)
        for frame in frames:
            for obj in meshes:
                bone = rig.pose.bones[obj.name]
                location, rotation, scale = pose_values(obj.name, unit, clip, frame)
                bone.location = location
                bone.rotation_mode = "XYZ"
                bone.rotation_euler = rotation
                bone.scale = scale
                bone.keyframe_insert("location", frame=frame, group=obj.name)
                bone.keyframe_insert("rotation_euler", frame=frame, group=obj.name)
                bone.keyframe_insert("scale", frame=frame, group=obj.name)
        rig.animation_data.action = None
        track = rig.animation_data.nla_tracks.new()
        track.name = clip
        track.strips.new(clip, start, action)
        track.mute = clip != "Idle"
    rig.animation_data.action = bpy.data.actions["Idle"]


def export(unit, rig, meshes):
    export_dir = os.path.abspath(
        os.path.join(os.path.dirname(bpy.data.filepath), "..", "assets", "models", "characters")
    )
    os.makedirs(export_dir, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    rig.select_set(True)
    for obj in meshes:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = rig
    bpy.ops.export_scene.gltf(
        filepath=os.path.join(export_dir, f"{unit}.glb"),
        export_format="GLB",
        use_selection=True,
        export_animations=True,
        export_nla_strips=True,
        export_merge_animation="NLA_TRACK",
        export_yup=True,
    )


def main():
    unit = os.path.splitext(os.path.basename(bpy.data.filepath))[0]
    meshes = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
    rig = bpy.data.objects.get("CharacterRig")
    if rig and rig.type == "ARMATURE":
        clear_rig_animation(rig)
    else:
        remove_old_animation()
        rig = create_rig(meshes)
    if unit == "spearman":
        spear_tip = bpy.data.objects.get("SpearTip")
        if spear_tip:
            world = spear_tip.matrix_world.copy()
            spear_tip.parent = rig
            spear_tip.parent_type = "BONE"
            spear_tip.parent_bone = "SpearTip"
            spear_tip.matrix_world = world
        bpy.context.view_layer.objects.active = rig
        bpy.ops.object.mode_set(mode="EDIT")
        rig.data.edit_bones["SpearTip"].parent = rig.data.edit_bones["SpearShaft"]
        bpy.ops.object.mode_set(mode="OBJECT")
    create_actions(rig, meshes, unit)

    scene = bpy.context.scene
    scene.render.fps = FPS
    scene.frame_start = 1
    scene.frame_end = 48
    scene["animation_clips"] = "Idle,Walk,Attack,Death"
    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
    export(unit, rig, meshes)
    for track in rig.animation_data.nla_tracks:
        track.mute = True
    rig.animation_data.action = bpy.data.actions["Attack"]
    scene.frame_set(1)
    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
    print(f"Rigged and exported {unit}: {len(meshes)} parts, {len(CLIPS)} unified actions")


main()
