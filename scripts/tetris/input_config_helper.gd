@tool
extends EditorScript

## Helper script to configure Tetris input actions in project settings
## Run this script once from the Godot editor: File > Run

func _run() -> void:
	print("=== Tetris Input Configuration Helper ===")
	print("Configuring input actions for Tetris game...")

	var actions = InputHandler.get_required_input_actions()

	for action_data in actions:
		var action_name = action_data["name"]
		var default_key = action_data["default_key"]
		var description = action_data["description"]

		if InputMap.has_action(action_name):
			print("  ✓ Action already exists: %s" % action_name)
		else:
			# Add the action
			InputMap.add_action(action_name)

			# Create keyboard event
			var key_event = InputEventKey.new()
			key_event.keycode = default_key

			# Add the event to the action
			InputMap.action_add_event(action_name, key_event)

			print("  + Created action: %s (Key: %s) - %s" % [action_name, OS.get_keycode_string(default_key), description])

	print("\nInput configuration complete!")
	print("\nConfigured actions:")
	print("  - Arrow Left: Move piece left")
	print("  - Arrow Right: Move piece right")
	print("  - Arrow Down: Soft drop")
	print("  - Arrow Up: Rotate clockwise")
	print("  - Z: Rotate counter-clockwise")
	print("  - Space: Hard drop")
	print("  - C: Hold piece")
	print("  - Escape: Pause game")
	print("\nYou can customize these in Project > Project Settings > Input Map")
