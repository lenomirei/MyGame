@tool
extends EditorPlugin
# Minimal EditorPlugin wrapper.
# TextDatabase itself is a plain RefCounted class, so it doesn't need any
# editor functionality. This wrapper only exists so the addon can be
# "enabled" in Project Settings -> Plugins. The actual class is already
# globally available via `class_name TextDatabase`.
