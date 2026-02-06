# Tetris UI System

A complete UI implementation for a Tetris game in Godot 4.6, designed with mobile-first principles and signal-based communication.

## Features

### Visual Components
- **10x20 Game Board** with custom grid rendering
- **7 Tetromino Colors** (I, O, T, S, Z, J, L) with 3D block effects
- **Ghost Piece** preview showing landing position
- **Next Piece Preview** with centered rendering
- **Score/Level/Lines Display** with live updates
- **Line Clear Animation** with flash effects
- **Main Menu** with Start/Quit buttons
- **Game Over Screen** with final score
- **Pause Screen** with resume functionality

### Effects & Polish
- **Screen Shake** for various game events
- **3D Block Rendering** with highlights and shadows
- **Smooth Animations** for line clearing
- **Visual Feedback** for piece locking and drops
- **Responsive Layout** for different screen sizes

### Input System
- **Arrow Keys**: Move left/right, rotate, soft drop
- **Space Bar**: Hard drop
- **P Key**: Pause/Resume
- Signal-based input forwarding to backend

## File Structure

```
scenes/
├── main_menu.tscn              # Entry point
└── game.tscn                   # Main game scene

scripts/
├── main_menu.gd                # Menu controller
├── game_manager.gd             # Game coordinator (MAIN INTEGRATION POINT)
├── game_board.gd               # Board rendering & state
├── next_piece_preview.gd       # Next piece display
├── game_ui.gd                  # Overlay screens
├── visual_effects.gd           # Screen shake & effects
├── tetromino_shapes.gd         # Shape definitions (reference)
└── score_display.gd            # Animated score counter

resources/
└── tetris_theme.tres           # UI theme
```

## Quick Start

### For Backend Developer

The main integration point is `game_manager.gd`. Here's how to connect your game logic:

```gdscript
# In your backend game logic script
extends Node

@onready var game_manager = $Game

func _ready():
    # Listen to UI input signals
    game_manager.game_started.connect(_on_game_started)
    game_manager.move_left_requested.connect(_on_move_left)
    game_manager.move_right_requested.connect(_on_move_right)
    game_manager.rotate_requested.connect(_on_rotate)
    game_manager.soft_drop_requested.connect(_on_soft_drop)
    game_manager.hard_drop_requested.connect(_on_hard_drop)
    game_manager.game_paused.connect(_on_game_paused)
    game_manager.game_resumed.connect(_on_game_resumed)

func _on_move_left():
    # Your game logic here
    # Then update UI:
    game_manager.update_current_piece({
        "type": "I",
        "position": Vector2i(3, 0),
        "blocks": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0)]
    })
```

### Piece Data Format

All piece data uses this dictionary structure:

```gdscript
{
    "type": "I",                    # String: I, O, T, S, Z, J, or L
    "position": Vector2i(x, y),     # Grid position (0-9 for x, 0-19 for y)
    "blocks": [                     # Array of block offsets from position
        Vector2i(0, 0),
        Vector2i(1, 0),
        Vector2i(2, 0),
        Vector2i(3, 0)
    ]
}
```

## API Reference

### Signals (UI → Backend)

```gdscript
# Game state
signal game_started
signal game_paused
signal game_resumed
signal game_over

# Player input
signal move_left_requested
signal move_right_requested
signal rotate_requested
signal soft_drop_requested
signal hard_drop_requested
```

### Methods (Backend → UI)

#### Update Display
```gdscript
game_manager.update_score(score: int)
game_manager.update_level(level: int)
game_manager.update_lines(lines: int)
```

#### Update Pieces
```gdscript
game_manager.update_current_piece(piece_data: Dictionary)
game_manager.update_ghost_piece(position: Vector2i)
game_manager.update_next_piece(piece_type: String, blocks: Array)
game_manager.place_piece(piece_data: Dictionary)
```

#### Game State Queries
```gdscript
# Check if a piece position is valid
var is_valid = game_manager.is_position_valid(piece_data)

# Check for completed lines
var full_lines = game_manager.check_completed_lines()  # Returns Array of line numbers

# Get current board state
var board = game_manager.get_board_state()  # Returns 2D Array[20][10]
```

#### Visual Effects
```gdscript
# Clear lines with animation
game_manager.clear_lines_visual([18, 19])  # Array of line numbers

# Game control
game_manager.pause_game()
game_manager.resume_game()
game_manager.end_game()
game_manager.reset_game()
```

## Color Scheme

### Tetromino Colors
- **I (Cyan)**: `Color(0.0, 0.9, 0.9)`
- **O (Yellow)**: `Color(0.9, 0.9, 0.0)`
- **T (Purple)**: `Color(0.6, 0.0, 0.9)`
- **S (Green)**: `Color(0.0, 0.9, 0.0)`
- **Z (Red)**: `Color(0.9, 0.0, 0.0)`
- **J (Blue)**: `Color(0.0, 0.0, 0.9)`
- **L (Orange)**: `Color(0.9, 0.5, 0.0)`

### UI Colors
- Background: `#141418`
- Panels: `#262633`
- Accent: `#66CCFF`
- Text: `#FFFFFF`

## Grid System

- **Grid Size**: 10 columns × 20 rows
- **Cell Size**: 30×30 pixels
- **Total Board Size**: 300×600 pixels
- **Coordinate System**: (0,0) is top-left

## Example: Complete Game Loop

```gdscript
extends Node

@onready var game_manager = $Game

var current_piece = null
var next_piece_type = "I"

func _ready():
    # Connect all signals
    game_manager.game_started.connect(_on_game_started)
    game_manager.move_left_requested.connect(_on_move_left)
    game_manager.hard_drop_requested.connect(_on_hard_drop)

func _on_game_started():
    spawn_new_piece()

func spawn_new_piece():
    current_piece = {
        "type": next_piece_type,
        "position": Vector2i(3, 0),
        "blocks": get_piece_blocks(next_piece_type)
    }

    # Update UI
    game_manager.update_current_piece(current_piece)

    # Update ghost piece
    var ghost_pos = calculate_ghost_position()
    game_manager.update_ghost_piece(ghost_pos)

    # Generate next piece
    next_piece_type = ["I","O","T","S","Z","J","L"].pick_random()
    game_manager.update_next_piece(next_piece_type, get_piece_blocks(next_piece_type))

func _on_move_left():
    if not current_piece:
        return

    # Try to move
    var test_piece = current_piece.duplicate(true)
    test_piece.position.x -= 1

    if game_manager.is_position_valid(test_piece):
        current_piece = test_piece
        game_manager.update_current_piece(current_piece)
        update_ghost_piece()

func _on_hard_drop():
    if not current_piece:
        return

    # Drop to bottom
    while true:
        var test_piece = current_piece.duplicate(true)
        test_piece.position.y += 1

        if not game_manager.is_position_valid(test_piece):
            break
        current_piece = test_piece

    # Lock piece
    game_manager.place_piece(current_piece)

    # Check for line clears
    var full_lines = game_manager.check_completed_lines()
    if full_lines.size() > 0:
        game_manager.clear_lines_visual(full_lines)
        var points = calculate_score(full_lines.size())
        game_manager.update_score(points)

    # Spawn next piece
    spawn_new_piece()

func calculate_ghost_position() -> Vector2i:
    var ghost_pos = current_piece.position
    var test_piece = current_piece.duplicate(true)

    while game_manager.is_position_valid(test_piece):
        ghost_pos = test_piece.position
        test_piece.position.y += 1

    return ghost_pos

func update_ghost_piece():
    game_manager.update_ghost_piece(calculate_ghost_position())
```

## Testing

### Test UI Without Backend
1. Open Godot Editor
2. Load `scenes/main_menu.tscn`
3. Press F6 to run scene
4. Click "START GAME"
5. UI will display but pieces won't move (no backend logic)

### Test With Dummy Backend
1. Create a test script that connects signals
2. Have it call update methods with dummy data
3. Verify UI responds correctly

## Mobile Configuration

The project is configured for mobile (portrait mode):
- Viewport: 1080×1920
- Stretch Mode: canvas_items
- Rendering: mobile
- Touch controls: Not yet implemented (use for future enhancement)

## Performance Notes

- Uses custom drawing with `_draw()` for grid and blocks
- Animations use Godot's Tween system
- No heavy physics calculations in UI layer
- Optimized for mobile devices

## Future Enhancements

Ready-to-add features:
- Touch controls for mobile
- Particle effects for line clears
- Sound effect triggers (signals in place)
- High score persistence
- Settings menu
- Multiple themes
- Combo indicators
- Hold piece feature

## Troubleshooting

### Pieces Not Showing
- Ensure you're calling `update_current_piece()` with correct format
- Check that piece position is within grid bounds (0-9 for x)
- Verify blocks array is not empty

### Input Not Working
- Check that signals are connected in backend
- Verify game is not paused
- Ensure `is_game_active` is true

### Animation Issues
- Line clear animation is automatic after calling `clear_lines_visual()`
- Wait for animation to complete before spawning next piece
- Listen to `lines_cleared` signal from game_board

## Support

See `UI_DOCUMENTATION.md` for detailed technical documentation.

## License

Part of the calvin-2d-game project.
