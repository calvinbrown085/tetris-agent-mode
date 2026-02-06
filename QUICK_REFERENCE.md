# Tetris UI - Quick Reference Card

## Main Integration Point
```gdscript
@onready var game_manager = $Game  # Main UI coordinator
```

---

## Signals (Listen to these in backend)

```gdscript
# Game state
game_manager.game_started.connect(_on_game_started)
game_manager.game_paused.connect(_on_game_paused)
game_manager.game_resumed.connect(_on_game_resumed)
game_manager.game_over.connect(_on_game_over)

# Player input
game_manager.move_left_requested.connect(_on_move_left)
game_manager.move_right_requested.connect(_on_move_right)
game_manager.rotate_requested.connect(_on_rotate)
game_manager.soft_drop_requested.connect(_on_soft_drop)
game_manager.hard_drop_requested.connect(_on_hard_drop)
```

---

## Methods (Call these from backend)

### Update Display
```gdscript
game_manager.update_score(1250)
game_manager.update_level(5)
game_manager.update_lines(42)
```

### Update Pieces
```gdscript
# Current piece
var piece = {
    "type": "I",
    "position": Vector2i(3, 5),
    "blocks": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0)]
}
game_manager.update_current_piece(piece)

# Ghost piece
game_manager.update_ghost_piece(Vector2i(3, 18))

# Next piece
game_manager.update_next_piece("T", [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)])

# Lock piece
game_manager.place_piece(piece)
```

### Visual Effects
```gdscript
# Clear lines with animation
game_manager.clear_lines_visual([18, 19])
```

### Board Queries
```gdscript
# Check collision
var is_valid = game_manager.is_position_valid(piece_data)

# Check full lines
var full_lines = game_manager.check_completed_lines()  # Returns Array

# Get board state
var board = game_manager.get_board_state()  # Returns Array[20][10]
```

### Game Control
```gdscript
game_manager.pause_game()
game_manager.resume_game()
game_manager.end_game()
game_manager.reset_game()
```

---

## Piece Data Format

```gdscript
{
    "type": "I",                  # String: I, O, T, S, Z, J, or L
    "position": Vector2i(x, y),   # Grid position (x: 0-9, y: 0-19)
    "blocks": [                   # Array of Vector2i offsets
        Vector2i(0, 0),
        Vector2i(1, 0),
        Vector2i(2, 0),
        Vector2i(3, 0)
    ]
}
```

---

## Tetromino Colors

```gdscript
I = Cyan    #00E5E5  Color(0.0, 0.9, 0.9)
O = Yellow  #E5E500  Color(0.9, 0.9, 0.0)
T = Purple  #9900E5  Color(0.6, 0.0, 0.9)
S = Green   #00E500  Color(0.0, 0.9, 0.0)
Z = Red     #E50000  Color(0.9, 0.0, 0.0)
J = Blue    #0000E5  Color(0.0, 0.0, 0.9)
L = Orange  #E57F00  Color(0.9, 0.5, 0.0)
```

---

## Grid Coordinates

```
(0,0)  (1,0)  (2,0)  ... (9,0)   ← Top row
(0,1)  (1,1)  (2,1)  ... (9,1)
  ...    ...    ...       ...
(0,19) (1,19) (2,19) ... (9,19)  ← Bottom row

Grid: 10 columns × 20 rows
Cell size: 30×30 pixels
Total: 300×600 pixels
```

---

## Input Mapping

```
←     → move_left_requested / move_right_requested
↑     → rotate_requested
↓     → soft_drop_requested
Space → hard_drop_requested
P     → Pause/Resume
```

---

## Common Patterns

### Spawn New Piece
```gdscript
func spawn_piece():
    var piece = {
        "type": next_type,
        "position": Vector2i(3, 0),
        "blocks": get_blocks(next_type)
    }
    game_manager.update_current_piece(piece)
    game_manager.update_ghost_piece(calculate_ghost(piece))
    game_manager.update_next_piece(generate_next_type(), get_blocks(next_type))
```

### Move Piece
```gdscript
func _on_move_left():
    var test = current_piece.duplicate(true)
    test.position.x -= 1
    if game_manager.is_position_valid(test):
        current_piece = test
        game_manager.update_current_piece(current_piece)
        game_manager.update_ghost_piece(calculate_ghost(current_piece))
```

### Lock Piece
```gdscript
func lock_piece():
    game_manager.place_piece(current_piece)
    var full_lines = game_manager.check_completed_lines()
    if full_lines.size() > 0:
        game_manager.clear_lines_visual(full_lines)
        add_score(calculate_points(full_lines.size()))
    spawn_piece()
```

### Update Score
```gdscript
func add_score(points: int):
    score += points
    game_manager.update_score(score)
    if score > next_level_threshold:
        level += 1
        game_manager.update_level(level)
```

---

## Files

### Must Read
- `UI_README.md` - Start here
- `scripts/game_manager.gd` - Main API

### Reference
- `UI_DOCUMENTATION.md` - Full docs
- `VISUAL_GUIDE.md` - Design guide

### Testing
- `scripts/ui_test_demo.gd` - Example usage

---

## Troubleshooting

**Pieces not showing?**
- Check piece_data format
- Verify position is in bounds (0-9 for x)
- Ensure blocks array not empty

**Input not working?**
- Check signals connected
- Verify game not paused
- Check is_game_active = true

**Collision wrong?**
- Use game_manager.is_position_valid()
- Check piece_data format correct

---

## Quick Test

```gdscript
# Test script to verify integration
extends Node

@onready var gm = $Game

func _ready():
    gm.game_started.connect(test_ui)

func test_ui():
    # Spawn test piece
    gm.update_current_piece({
        "type": "I",
        "position": Vector2i(3, 5),
        "blocks": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0)]
    })

    # Update displays
    gm.update_score(1000)
    gm.update_level(5)
    gm.update_lines(20)

    # Show next piece
    gm.update_next_piece("T", [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)])

    print("UI test complete!")
```

---

## Scene Paths

```gdscript
"res://scenes/main_menu.tscn"  # Entry point
"res://scenes/game.tscn"       # Main game
```

---

## Performance Tips

- Call update methods only when state changes
- Use `is_position_valid()` before moving pieces
- Batch UI updates when possible
- Let animations complete before spawning pieces

---

**Version**: 1.0 | **Date**: 2026-02-06 | **Godot**: 4.6
