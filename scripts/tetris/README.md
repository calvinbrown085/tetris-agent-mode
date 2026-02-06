# Tetris Game Backend - Implementation Guide

This directory contains the complete backend logic for a Tetris game implemented in Godot 4.6 using GDScript.

## Architecture Overview

The backend follows the **Single Responsibility Principle** with modular, decoupled components:

```
tetris_game_manager.gd (Node - Main Interface)
    └── tetris_game_controller.gd (Orchestrator)
        ├── game_board.gd (Board State & Collision)
        ├── score_manager.gd (Scoring & Levels)
        ├── piece_spawner.gd (Piece Generation)
        ├── input_handler.gd (Input Processing)
        └── tetromino.gd (Piece Definitions)
```

## Component Details

### 1. `tetromino.gd`
**Purpose**: Defines all 7 tetromino pieces (I, O, T, S, Z, J, L)

**Features**:
- 4 rotation states per piece (SRS - Super Rotation System)
- Wall kick data for realistic rotation behavior
- Color definitions for each piece type
- Helper methods for getting block positions

**Key Methods**:
- `get_blocks()` - Returns array of absolute block positions
- `rotate_clockwise()` / `rotate_counterclockwise()` - Rotation with state tracking
- `get_wall_kick_tests()` - Returns wall kick offsets for collision recovery

---

### 2. `game_board.gd`
**Purpose**: Manages the 10x20 game board grid and collision detection

**Features**:
- Board state stored as 2D array (null = empty, Color = filled)
- Collision detection for pieces
- Line clearing with proper gravity
- Drop distance calculation for ghost pieces

**Signals**:
- `lines_cleared(lines: int, is_tetris: bool)` - Emitted when lines are cleared
- `board_updated()` - Emitted when board state changes

**Key Methods**:
- `is_valid_position(blocks)` - Check if position is valid
- `lock_piece(piece)` - Lock piece to board
- `check_and_clear_lines()` - Clear full lines and return count
- `get_drop_distance(piece)` - Calculate hard drop distance

---

### 3. `score_manager.gd`
**Purpose**: Handles scoring, statistics, and level progression

**Features**:
- Original Tetris scoring system (100/300/500/800 points)
- Level-based score multipliers
- Automatic level progression every 10 lines
- Dynamic fall speed calculation based on level
- Soft drop and hard drop scoring

**Signals**:
- `score_changed(new_score: int)`
- `level_changed(new_level: int)`
- `lines_changed(new_lines: int)`

**Key Methods**:
- `add_line_clear_score(lines, is_tetris)` - Add score for clearing lines
- `get_fall_speed()` - Calculate current fall speed
- `get_statistics()` - Get all game statistics

---

### 4. `piece_spawner.gd`
**Purpose**: Manages piece spawning with 7-bag randomization

**Features**:
- 7-bag system (each bag contains exactly one of each piece)
- Next piece preview queue (3 pieces ahead)
- Fair randomization (no long droughts of specific pieces)

**Signals**:
- `next_pieces_updated(next_pieces: Array[Tetromino.Type])`

**Key Methods**:
- `spawn_next_piece()` - Get next piece and update queue
- `get_next_pieces()` - Get preview queue
- `reset()` - Reset spawner state

---

### 5. `input_handler.gd`
**Purpose**: Processes player input and emits action signals

**Features**:
- Input abstraction layer
- Input state tracking (key held/released)
- Configurable input actions

**Signals**:
- `move_left_pressed()`, `move_right_pressed()`, `move_down_pressed()`
- `rotate_cw_pressed()`, `rotate_ccw_pressed()`
- `hard_drop_pressed()`, `hold_pressed()`, `pause_pressed()`

**Required Input Actions**:
- `tetris_move_left` - Left Arrow
- `tetris_move_right` - Right Arrow
- `tetris_move_down` - Down Arrow
- `tetris_rotate_cw` - Up Arrow
- `tetris_rotate_ccw` - Z
- `tetris_hard_drop` - Space
- `tetris_hold` - C
- `tetris_pause` - Escape

---

### 6. `tetris_game_controller.gd`
**Purpose**: Main orchestrator that coordinates all game logic

**Features**:
- Game state management (IDLE, PLAYING, PAUSED, GAME_OVER)
- Piece movement and rotation with wall kicks
- Lock delay mechanism (0.5s to allow adjustments)
- DAS (Delayed Auto Shift) for smooth horizontal movement
- ARR (Auto Repeat Rate) for repeated movement
- Soft drop and hard drop mechanics
- Hold piece functionality
- Ghost piece calculation
- Automatic gravity (falling)

**Signals**:
- `game_started()`, `game_paused()`, `game_resumed()`, `game_over()`
- `piece_spawned(piece)`, `piece_moved(piece)`, `piece_rotated(piece)`
- `piece_locked(piece)`, `piece_hard_dropped(distance)`

**Key Methods**:
- `start_game(starting_level)` - Initialize and start game
- `move_piece_left()` / `move_piece_right()` - Horizontal movement
- `rotate_piece_clockwise()` / `rotate_piece_counterclockwise()` - Rotation
- `hard_drop()` - Instant drop to bottom
- `soft_drop()` - Fast downward movement
- `hold_piece()` - Hold current piece for later
- `get_ghost_piece_position()` - Get ghost piece blocks

---

### 7. `tetris_game_manager.gd`
**Purpose**: Top-level Node that integrates everything and provides UI interface

**Features**:
- Easy-to-use API for UI layer
- Input routing from Godot to game controller
- Configurable settings (starting level, ghost piece, hold enabled)
- Accessor methods for all game data

**Export Variables**:
- `starting_level: int` - Initial game level (default: 1)
- `enable_ghost_piece: bool` - Show ghost piece (default: true)
- `enable_hold: bool` - Enable hold functionality (default: true)

**Key Methods for UI**:
- `start_new_game()` - Start a new game
- `get_board()` - Access game board
- `get_score_manager()` - Access scoring system
- `get_current_piece()` - Get current active piece
- `get_ghost_piece_blocks()` - Get ghost piece for rendering
- `get_game_state()` - Get current game state

---

## Usage Instructions

### Setup

1. **Configure Input Actions**
   Run `input_config_helper.gd` from Godot Editor (File > Run) to auto-configure input actions.

   Or manually add these actions in Project Settings > Input Map:
   - tetris_move_left (Left Arrow)
   - tetris_move_right (Right Arrow)
   - tetris_move_down (Down Arrow)
   - tetris_rotate_cw (Up Arrow)
   - tetris_rotate_ccw (Z)
   - tetris_hard_drop (Space)
   - tetris_hold (C)
   - tetris_pause (Escape)

2. **Add Game Manager to Scene**
   ```gdscript
   # In your main game scene
   var game_manager = preload("res://scripts/tetris/tetris_game_manager.gd").new()
   add_child(game_manager)
   ```

### Starting a Game

```gdscript
# Start a new game at level 1
game_manager.start_new_game()

# Or specify starting level
game_manager.starting_level = 5
game_manager.start_new_game()
```

### Connecting to UI

```gdscript
# Connect to game controller signals
var controller = game_manager.game_controller

# Game state signals
controller.game_started.connect(_on_game_started)
controller.game_over.connect(_on_game_over)
controller.game_paused.connect(_on_game_paused)

# Piece signals
controller.piece_spawned.connect(_on_piece_spawned)
controller.piece_moved.connect(_on_piece_moved)
controller.piece_locked.connect(_on_piece_locked)

# Board signals
controller.board.lines_cleared.connect(_on_lines_cleared)
controller.board.board_updated.connect(_on_board_updated)

# Score signals
controller.score_manager.score_changed.connect(_on_score_changed)
controller.score_manager.level_changed.connect(_on_level_changed)

# Next pieces signal
controller.piece_spawner.next_pieces_updated.connect(_on_next_pieces_updated)
```

### Rendering the Game Board

```gdscript
func render_board():
    var board = game_manager.get_board()

    # Render locked blocks
    for y in range(board.BOARD_HEIGHT):
        for x in range(board.BOARD_WIDTH):
            var cell = board.get_cell(x, y)
            if cell != null:
                # Draw block at (x, y) with color 'cell'
                draw_block(x, y, cell)

    # Render current piece
    var current_piece = game_manager.get_current_piece()
    if current_piece:
        for block in current_piece.get_blocks():
            draw_block(block.x, block.y, current_piece.color)

    # Render ghost piece
    var ghost_blocks = game_manager.get_ghost_piece_blocks()
    for block in ghost_blocks:
        draw_ghost_block(block.x, block.y)
```

### Accessing Game Data

```gdscript
# Get score information
var score = game_manager.get_score_manager().get_current_score()
var level = game_manager.get_score_manager().get_current_level()
var lines = game_manager.get_score_manager().get_lines_cleared()

# Get next pieces for preview
var next_pieces = game_manager.get_piece_spawner().get_next_pieces()

# Get held piece
var held_type = game_manager.get_held_piece_type()
if held_type != -1:
    # Draw held piece preview
    pass

# Check game state
var state = game_manager.get_game_state()
if state == TetrisGameController.GameState.GAME_OVER:
    show_game_over_screen()
```

## Game Mechanics

### Movement
- **Left/Right**: Immediate movement with DAS/ARR for smooth repeated movement
- **Down**: Soft drop (faster falling, awards 1 point per cell)
- **Space**: Hard drop (instant drop, awards 2 points per cell)

### Rotation
- **Up Arrow**: Rotate clockwise
- **Z**: Rotate counter-clockwise
- Uses SRS (Super Rotation System) with wall kicks
- Lock delay resets on successful rotation

### Lock Delay
- 0.5 second delay before piece locks
- Allows for last-moment adjustments
- Resets when piece moves or rotates successfully

### Hold System
- Press **C** to hold current piece
- Can only hold once per piece
- Swaps with held piece if one exists

### Scoring
- **Single**: 100 × level
- **Double**: 300 × level
- **Triple**: 500 × level
- **Tetris (4 lines)**: 800 × level
- **Soft Drop**: 1 point per cell
- **Hard Drop**: 2 points per cell

### Level Progression
- Level increases every 10 lines cleared
- Fall speed increases with level
- Formula: `base_speed / (1 + (level - 1) × 0.15)`
- Minimum fall speed: 0.05 seconds

## Testing

### Manual Testing Checklist
- [ ] All 7 pieces spawn correctly
- [ ] Pieces rotate with wall kicks
- [ ] Left/right movement works
- [ ] Soft drop increases speed
- [ ] Hard drop places piece instantly
- [ ] Line clearing works (1-4 lines)
- [ ] Scoring calculates correctly
- [ ] Level increases every 10 lines
- [ ] Fall speed increases with level
- [ ] Hold piece works correctly
- [ ] Ghost piece shows correct position
- [ ] Game over triggers when spawn blocked
- [ ] Pause/resume works
- [ ] Lock delay allows adjustments

### Unit Testing
Each component is designed to be independently testable:

```gdscript
# Test piece rotation
var piece = Tetromino.new(Tetromino.Type.T, Vector2i(0, 0))
piece.rotate_clockwise()
assert(piece.rotation_state == 1)

# Test board collision
var board = GameBoard.new()
var blocks = [Vector2i(0, 0), Vector2i(1, 0)]
assert(board.is_valid_position(blocks))

# Test scoring
var score_manager = ScoreManager.new()
score_manager.add_line_clear_score(4, true)  # Tetris
assert(score_manager.get_current_score() == 800)
```

## Performance Considerations

- **Board State**: Uses simple 2D array for O(1) access
- **Collision Detection**: Checks only 4 blocks per piece
- **Line Clearing**: O(n) where n = number of cleared lines
- **Memory**: All components use RefCounted for automatic cleanup
- **No Physics Engine**: Pure logic-based, very lightweight

## Future Enhancements

Possible additions (not implemented):
- T-Spin detection and bonus scoring
- Combo system for consecutive line clears
- Persistent high scores
- Replay system
- Custom piece sets
- Multiplayer support
- Save/load game state

## Credits

- Tetromino shapes: Standard Tetris guidelines
- Rotation system: SRS (Super Rotation System)
- Scoring: Based on original Tetris (1984)
- Bag randomization: Modern Tetris standard

---

**For UI implementation**, see the UI agent's documentation. This backend provides all the necessary signals and accessor methods for a complete visual implementation.
