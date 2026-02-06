# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot Engine 4.6 project for a 2D game using the mobile rendering method. The project uses Jolt Physics for 3D physics (if needed) and is configured for mobile-first development.

## Key Commands

### Running the Project
- Open the project in Godot Editor: `godot --editor project.godot`
- Run the project: `godot project.godot`
- Run headless (for testing): `godot --headless project.godot`

### Exporting
- Export the project: `godot --export-release <preset_name> <output_path>`
- List export presets: `godot --export-debug --list-presets`

### Scene and Script Management
- Godot uses `.tscn` files for scenes (text-based scene format)
- Scripts use GDScript (`.gd` files) by default
- The `project.godot` file contains project settings and should be edited through the Godot Editor when possible

## Project Structure

### Core Files
- `project.godot` - Main project configuration file
- `.godot/` - Generated editor cache (ignored by git)
- `icon.svg` - Default project icon

### Configuration
- Uses mobile rendering method (`renderer/rendering_method="mobile"`)
- Windows builds use DirectX 12 by default
- Character encoding: UTF-8 (enforced by .editorconfig)

## Godot-Specific Development Notes

### Scene Tree Architecture
Godot uses a scene tree where every object is a Node. Scenes can be instantiated as nodes in other scenes, creating a hierarchical structure.

### GDScript Conventions
- Use `snake_case` for variable and function names
- Use `PascalCase` for class names
- Signals use past tense (e.g., `body_entered`, not `body_enter`)
- Export variables to expose them in the editor: `@export var speed: float = 100.0`

### Resource Paths
- Always use `res://` protocol for resource paths within the project
- User data uses `user://` protocol

### Physics and Rendering
- 3D physics engine: Jolt Physics
- 2D rendering optimized for mobile performance
- Consider performance implications when adding nodes to the scene tree

### Version Control
- `.godot/` directory is excluded from version control
- Scene files (`.tscn`) are text-based and merge-friendly
- Binary imports are generated automatically by the engine
