# Tetris UI System Documentation

## Overview

This document describes the UI system for the Tetris game built in Godot 4.6. The UI is designed with a mobile-first approach and uses signals for communication with the backend game logic.

## Project Structure

```
calvin-2d-game/
├── scenes/
│   ├── main_menu.tscn          # Main menu scene
│   └── game.tscn               # Main game scene
├── scripts/
│   ├── main_menu.gd            # Main menu logic
│   ├── game_manager.gd         # Game coordinator
│   ├── game_board.gd           # Game board rendering
│   ├── next_piece_preview.gd   # Next piece preview
│   ├── game_ui.gd              # UI overlays (pause, game over)
│   └── visual_effects.gd       # Visual effects system
└── resources/
    └── tetris_theme.tres       # UI theme resource
```

## Scenes

### 1. Main Menu (`scenes/main_menu.tscn`)

**Purpose**: Entry point for the game with Start and Quit buttons.

**Components**:
- Background with dark blue gradient
- Title text "TETRIS" with cyan accent color
- Start Game button
- Quit button

**Signals**:
- `start_game_pressed` - Emitted when Start button is clicked
- `quit_pressed` - Emitted when Quit button is clicked

**Script**: `scripts/main_menu.gd`

### 2. Game Scene (`scenes/game.tscn`)

**Purpose**: Main gameplay scene containing all game elements.

**Layout**:
```
┌─────────────────────────────────────────┐
│  [Score]    [GAME BOARD]    [Next]      │
│  [Level]                    [Controls]  │
│  [Lines]                                │
└─────────────────────────────────────────┘
```

**Components**:
- **Left Panel**: Score, Level, Lines displays
- **Center**: Game board (10x20 grid)
- **Right Panel**: Next piece preview, Controls help
- **Overlays**: Pause screen, Game Over screen

**Script**: `scripts/game_manager.gd`

## Scripts

### 1. `game_manager.gd`

**Purpose**: Central coordinator for the game scene. Manages game state and connects UI to backend logic.

**Key Signals (Emitted to Backend)**:
```gdscript
signal game_started
signal game_paused
signal game_resumed
signal game_over
signal move_left_requested
signal move_right_requested
signal rotate_requested
signal soft_drop_requested
signal hard_drop_requested
```

**Public Methods (Called by Backend)**:
```gdscript
# UI Updates
update_score(score: int)
update_level(level: int)
update_lines(lines: int)
update_current_piece(piece_data: Dictionary)
update_ghost_piece(position: Vector2i)
update_next_piece(piece_type: String, blocks: Array)

# Game State
place_piece(piece_data: Dictionary)
clear_lines_visual(line_numbers: Array)
check_completed_lines() -> Array
is_position_valid(piece_data: Dictionary) -> bool
get_board_state() -> Array

# Game Control
pause_game()
resume_game()
end_game()
reset_game()
```

**Input Handling**:
- Arrow Keys: Move/Rotate
- Down Arrow: Soft drop
- Space: Hard drop
- P: Pause/Resume

### 2. `game_board.gd`

**Purpose**: Renders the 10x20 Tetris grid with pieces, animations, and effects.

**Constants**:
```gdscript
GRID_WIDTH = 10
GRID_HEIGHT = 20
CELL_SIZE = 30

TETROMINO_COLORS = {
    "I": Cyan (0.0, 0.9, 0.9)
    "O": Yellow (0.9, 0.9, 0.0)
    "T": Purple (0.6, 0.0, 0.9)
    "S": Green (0.0, 0.9, 0.0)
    "Z": Red (0.9, 0.0, 0.0)
    "J": Blue (0.0, 0.0, 0.9)
    "L": Orange (0.9, 0.5, 0.0)
}
```

**Public Methods**:
```gdscript
set_current_piece(piece_data: Dictionary)
update_ghost_piece(position: Vector2i)
place_piece(piece_data: Dictionary)
clear_lines(line_numbers: Array)
is_position_valid(piece_data: Dictionary) -> bool
check_lines() -> Array
get_grid_state() -> Array
reset_board()
```

**Piece Data Format**:
```gdscript
{
    "type": "I",  # Piece type (I, O, T, S, Z, J, L)
    "position": Vector2i(x, y),  # Grid position
    "blocks": [Vector2i(0,0), Vector2i(1,0), ...]  # Block offsets
}
```

**Visual Features**:
- Grid background with lines
- 3D block rendering with highlights and shadows
- Ghost piece (semi-transparent preview of landing position)
- Line clearing animation with flash effect

### 3. `next_piece_preview.gd`

**Purpose**: Displays the next piece in a centered preview box.

**Public Methods**:
```gdscript
set_next_piece(piece_type: String, blocks: Array)
clear_preview()
```

**Features**:
- Auto-centers pieces in preview area
- Uses same colors as game board
- 3D block rendering

### 4. `game_ui.gd`

**Purpose**: Manages overlay screens (pause, game over).

**Signals**:
```gdscript
signal restart_pressed
signal menu_pressed
signal resume_pressed
```

**Public Methods**:
```gdscript
show_game_over(final_score: int)
show_pause()
hide_all_screens()
```

**Screens**:
- **Game Over**: Shows final score with Restart and Main Menu buttons
- **Pause**: Shows pause message with Resume and Main Menu buttons

### 5. `visual_effects.gd`

**Purpose**: Handles visual feedback like screen shake.

**Public Methods**:
```gdscript
trigger_line_clear_effect(line_count: int)
trigger_piece_lock_effect()
trigger_hard_drop_effect()
trigger_level_up_effect()
trigger_game_over_effect()
screen_shake(intensity: float)
```

**Features**:
- Screen shake with varying intensity
- Automatic decay over time
- Can be extended with particle effects

## Communication Flow

### Game Start
```
Main Menu → start_game_pressed → Change to Game Scene
Game Scene → game_started signal → Backend initializes
```

### Player Input
```
Player Input → game_manager → Signal to Backend
Backend processes → Calls update methods on game_manager
game_manager → Updates UI components
```

### Line Clear
```
Backend detects full lines → Calls clear_lines_visual()
game_board → Plays animation → Emits lines_cleared
Backend updates score → Calls update_score()
```

### Game Over
```
Backend detects game over → Calls end_game()
game_manager → Shows game over screen
Player clicks Restart → restart_pressed signal → Backend resets
```

## Color Scheme

**Background Colors**:
- Main Background: `#141418` (very dark blue-grey)
- Panel Background: `#262633` (dark blue-grey)
- Grid Background: `#262633` (dark blue-grey)

**UI Colors**:
- Primary Text: `#FFFFFF` (white)
- Secondary Text: `#999999` (grey)
- Accent: `#66CCFF` (light blue)
- Score/Level: `#66CCFF` (light blue)
- Lines: `#FFCC66` (gold)

**Tetromino Colors**: See game_board.gd TETROMINO_COLORS

## Mobile Optimization

**Display Settings**:
- Viewport: 1080x1920 (portrait)
- Stretch Mode: canvas_items
- Aspect: keep
- Rendering: mobile

**Responsive Design**:
- Uses anchors and containers for flexible layout
- Minimum sizes set for critical UI elements
- Touch-friendly button sizes (60px height minimum)

## Integration with Backend

The UI is designed to be completely separate from game logic. The backend should:

1. **Listen to signals** from `game_manager` for player input
2. **Call public methods** on `game_manager` to update UI
3. **Use piece data format** as specified in documentation
4. **Not directly access** UI nodes (go through game_manager)

### Example Integration

```gdscript
# In backend game logic script
extends Node

@onready var game_manager = $Game  # Reference to game scene

func _ready():
    # Connect to input signals
    game_manager.move_left_requested.connect(_on_move_left)
    game_manager.rotate_requested.connect(_on_rotate)
    # ... etc

func _on_move_left():
    # Game logic here
    if can_move_left():
        current_piece.position.x -= 1
        game_manager.update_current_piece(current_piece)

func update_score_from_logic(points: int):
    score += points
    game_manager.update_score(score)
```

## Future Enhancements

Potential UI improvements for backend agent:
- High score persistence
- Settings menu (volume, controls)
- Touch controls for mobile
- Particle effects for line clears
- Combo indicators
- Background music visualization
- Achievements/statistics screen

## Testing

To test UI without backend:
1. Open `scenes/main_menu.tscn` in Godot Editor
2. Run the scene (F6)
3. Click Start Game to see game scene
4. Use keyboard controls to trigger input signals

Note: Without backend logic, pieces won't move, but UI will respond to inputs and update when methods are called.
