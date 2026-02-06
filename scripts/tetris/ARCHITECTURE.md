# Tetris Backend Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                          UI Layer                               │
│  (Rendering, Animations, Sound, Menus - To be implemented)     │
└────────────────────────┬────────────────────────────────────────┘
                         │ Signals & Method Calls
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│                    TetrisGameManager (Node)                     │
│  • Main interface for UI                                        │
│  • Routes input to controller                                   │
│  • Provides accessor methods                                    │
│  • Configurable settings                                        │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│              TetrisGameController (Orchestrator)                │
│  • Coordinates all game logic                                   │
│  • Manages game state machine                                   │
│  • Handles piece lifecycle                                      │
│  • Implements game mechanics                                    │
└──┬──────────┬──────────┬──────────┬──────────┬─────────────────┘
   │          │          │          │          │
   ↓          ↓          ↓          ↓          ↓
┌─────┐  ┌────────┐  ┌──────┐  ┌─────────┐  ┌──────────┐
│Board│  │ Score  │  │Spawn │  │  Input  │  │Tetromino │
│     │  │Manager │  │  er  │  │ Handler │  │          │
└─────┘  └────────┘  └──────┘  └─────────┘  └──────────┘
```

## Component Responsibilities

### TetrisGameManager (Node)
**Role**: Facade / Integration Layer
```
Responsibilities:
├── Instantiate game controller
├── Route input events
├── Provide simple API for UI
└── Expose configuration options

Provides to UI:
├── start_new_game()
├── pause_game() / resume_game()
├── get_board() → GameBoard
├── get_score_manager() → ScoreManager
├── get_current_piece() → Tetromino
├── get_ghost_piece_blocks() → Array
└── get_game_state() → GameState
```

### TetrisGameController (RefCounted)
**Role**: Game Logic Orchestrator
```
Responsibilities:
├── Game state machine (IDLE, PLAYING, PAUSED, GAME_OVER)
├── Piece lifecycle management
│   ├── Spawn pieces
│   ├── Move pieces
│   ├── Rotate pieces
│   └── Lock pieces
├── Game mechanics
│   ├── Automatic falling (gravity)
│   ├── Lock delay (0.5s adjustment window)
│   ├── DAS/ARR (smooth movement)
│   ├── Hard drop / Soft drop
│   └── Hold piece system
└── Event coordination
    ├── Emit signals for UI
    └── Coordinate component interactions

Emits Signals:
├── game_started()
├── game_paused()
├── game_resumed()
├── game_over()
├── piece_spawned(piece)
├── piece_moved(piece)
├── piece_rotated(piece)
├── piece_locked(piece)
└── piece_hard_dropped(distance)
```

### GameBoard (RefCounted)
**Role**: Board State & Collision
```
Responsibilities:
├── Maintain 10×20 grid state
├── Collision detection
├── Line clearing logic
├── Drop distance calculation
└── Piece locking

Data Structure:
└── grid: Array[Array[Color|null]]
    ├── [y][x] indexing
    ├── null = empty cell
    └── Color = filled block

Methods:
├── is_valid_position(blocks) → bool
├── is_collision(blocks) → bool
├── lock_piece(piece) → void
├── check_and_clear_lines() → int
├── get_drop_distance(piece) → int
└── get_cell(x, y) → Color|null

Emits Signals:
├── lines_cleared(lines: int, is_tetris: bool)
└── board_updated()
```

### ScoreManager (RefCounted)
**Role**: Scoring & Progression
```
Responsibilities:
├── Track score, level, lines
├── Calculate points for actions
├── Level progression logic
├── Dynamic fall speed calculation
└── Game statistics

Scoring Rules:
├── Single: 100 × level
├── Double: 300 × level
├── Triple: 500 × level
├── Tetris: 800 × level
├── Soft drop: 1 point/cell
└── Hard drop: 2 points/cell

Level System:
├── Start at level 1
├── +1 level every 10 lines
└── Fall speed = base / (1 + (level-1) × 0.15)

Emits Signals:
├── score_changed(new_score: int)
├── level_changed(new_level: int)
└── lines_changed(new_lines: int)
```

### PieceSpawner (RefCounted)
**Role**: Piece Generation
```
Responsibilities:
├── Generate pieces using 7-bag system
├── Maintain next piece queue
├── Ensure fair distribution
└── Provide piece previews

7-Bag Algorithm:
1. Create bag with all 7 pieces
2. Shuffle bag
3. Draw pieces sequentially
4. When empty, refill and shuffle
Result: No long droughts, fair distribution

Queue System:
├── Stores 4 pieces (1 current + 3 next)
├── Updates when piece spawned
└── Always maintains full queue

Emits Signals:
└── next_pieces_updated(next_pieces: Array)
```

### InputHandler (RefCounted)
**Role**: Input Processing
```
Responsibilities:
├── Abstract input events
├── Track input state
├── Emit action signals
└── Provide input queries

Input Actions:
├── tetris_move_left → Arrow Left
├── tetris_move_right → Arrow Right
├── tetris_move_down → Arrow Down
├── tetris_rotate_cw → Arrow Up
├── tetris_rotate_ccw → Z key
├── tetris_hard_drop → Space
├── tetris_hold → C key
└── tetris_pause → Escape

State Tracking:
├── is_move_left_held: bool
├── is_move_right_held: bool
└── is_move_down_held: bool

Emits Signals:
├── move_left_pressed()
├── move_right_pressed()
├── move_down_pressed()
├── move_down_released()
├── rotate_cw_pressed()
├── rotate_ccw_pressed()
├── hard_drop_pressed()
├── hold_pressed()
└── pause_pressed()
```

### Tetromino (RefCounted)
**Role**: Piece Definition
```
Responsibilities:
├── Define 7 piece types (I, O, T, S, Z, J, L)
├── 4 rotation states per piece
├── Wall kick data (SRS)
├── Color assignments
└── Block position calculation

Piece Types:
├── I: Cyan    (straight line)
├── O: Yellow  (square)
├── T: Purple  (T-shape)
├── S: Green   (S-shape)
├── Z: Red     (Z-shape)
├── J: Blue    (J-shape)
└── L: Orange  (L-shape)

Rotation System:
├── SRS (Super Rotation System)
├── 4 rotation states (0°, 90°, 180°, 270°)
├── Wall kick tests (5 per rotation)
└── Different kicks for I vs JLSTZ

Methods:
├── get_blocks() → Array[Vector2i]
├── rotate_clockwise() → int
├── rotate_counterclockwise() → int
├── get_wall_kick_tests(old, new) → Array
├── move(delta) → void
└── duplicate_tetromino() → Tetromino
```

## Data Flow

### Game Start Flow
```
1. UI calls game_manager.start_new_game()
2. GameManager → Controller.start_game()
3. Controller:
   ├── Reset all components
   ├── Spawn first piece
   └── Start gravity timer
4. Controller emits game_started signal
5. UI responds to signal, shows game screen
```

### Piece Movement Flow
```
1. Player presses left arrow
2. Input event captured by GameManager._input()
3. GameManager → InputHandler.process_input()
4. InputHandler emits move_left_pressed signal
5. GameManager receives signal
6. GameManager → Controller.move_piece_left()
7. Controller:
   ├── Calculate new position
   ├── Check collision via Board
   ├── Update piece position if valid
   └── Emit piece_moved signal
8. UI receives piece_moved signal
9. UI redraws piece at new position
```

### Line Clear Flow
```
1. Piece locks on board
2. Controller → Board.lock_piece()
3. Board updates grid state
4. Board → check_and_clear_lines()
5. Board finds full lines
6. Board removes lines, shifts down
7. Board emits lines_cleared signal
8. Controller receives signal
9. Controller → ScoreManager.add_line_clear_score()
10. ScoreManager:
    ├── Calculate points
    ├── Add to score
    ├── Check level up
    └── Emit score_changed signal
11. UI receives score_changed signal
12. UI updates score display
13. UI plays line clear animation
```

### Rotation with Wall Kicks Flow
```
1. Player presses rotate key
2. Controller.rotate_piece_clockwise()
3. Save old rotation state
4. Apply rotation to piece
5. Get blocks in new rotation
6. Board.is_collision(blocks)?
   ├── No collision:
   │   ├── Accept rotation
   │   └── Emit piece_rotated
   └── Collision detected:
       ├── Get wall kick tests from piece
       ├── For each kick offset:
       │   ├── Apply offset
       │   ├── Check collision
       │   └── If valid: accept & return
       └── All kicks failed:
           └── Revert to old rotation
```

## Game Loop

### Main Game Loop (in _process)
```
Every frame while PLAYING:
1. Update fall timer
2. If fall_timer >= fall_speed:
   ├── Try to move piece down
   ├── Success: Reset fall timer
   └── Failure: Start lock delay
3. If lock delay active:
   ├── Increment lock delay timer
   └── If timer >= 0.5s: Lock piece
4. If DAS active:
   ├── Update DAS timer
   └── If charged: Start ARR
5. If ARR active:
   ├── Update ARR timer
   └── If triggered: Move piece
```

### Timers Explained

**Fall Timer** (Gravity)
- Increments every frame
- When >= fall_speed: piece moves down
- Speed decreases with level

**Lock Delay Timer**
- Starts when piece can't move down
- Gives 0.5s to adjust position
- Resets on successful move/rotate
- When expires: piece locks

**DAS Timer** (Delayed Auto Shift)
- Starts when movement key pressed
- 133ms delay before auto-repeat
- Prevents accidental fast movement

**ARR Timer** (Auto Repeat Rate)
- Starts after DAS completes
- 33ms between repeated movements
- Enables smooth sliding

## Signal Flow Diagram

```
                    ┌──────────────┐
                    │   UI Layer   │
                    └──────┬───────┘
                           │ (observes)
            ┌──────────────┼──────────────┐
            │              │              │
            ↓              ↓              ↓
    ┌───────────┐  ┌───────────┐  ┌───────────┐
    │  Piece    │  │   Board   │  │   Score   │
    │  Signals  │  │  Signals  │  │  Signals  │
    └───────────┘  └───────────┘  └───────────┘
            ↑              ↑              ↑
            └──────────────┼──────────────┘
                           │ (emits)
                    ┌──────┴───────┐
                    │  Controller  │
                    └──────┬───────┘
                           │ (uses)
            ┌──────────────┼──────────────┐
            │              │              │
            ↓              ↓              ↓
    ┌───────────┐  ┌───────────┐  ┌───────────┐
    │   Board   │  │ScoreManager│ │  Spawner  │
    │           │  │            │  │           │
    └───────────┘  └────────────┘  └───────────┘
```

## State Machine

```
┌──────┐  start_game()   ┌─────────┐
│ IDLE ├────────────────→│ PLAYING │
└──────┘                 └────┬────┘
                              │
                              │ pause_game()
                              ↓
                         ┌────────┐
                    ┌────┤ PAUSED ├────┐
                    │    └────────┘    │
                    │                  │
         end_game() │                  │ resume_game()
                    ↓                  ↓
              ┌───────────┐      ┌─────────┐
              │ GAME_OVER │      │ PLAYING │
              └───────────┘      └─────────┘
```

## Memory Management

All components use `RefCounted`:
- Automatic reference counting
- No manual memory management needed
- Garbage collected when no references remain

Only `TetrisGameManager` is a `Node`:
- Must be added to scene tree
- Can be added/removed dynamically
- All other components are owned by it

## Thread Safety

**Not thread-safe** - designed for single-threaded gameplay:
- All logic runs on main thread
- Godot's scene tree is not thread-safe
- No synchronization primitives needed

## Performance Profile

| Operation | Complexity | Notes |
|-----------|-----------|-------|
| Board cell access | O(1) | Direct array indexing |
| Collision check | O(4) | Only 4 blocks per piece |
| Piece rotation | O(4) | Check 4 blocks + wall kicks |
| Line clear | O(n) | n = lines cleared (1-4) |
| Spawn piece | O(1) | Pop from pre-shuffled bag |
| Score calculation | O(1) | Simple arithmetic |

**Frame Budget**: < 0.1ms per frame
**Memory Usage**: < 1MB total

## Extensibility Points

Want to add features? Hook in at these points:

**Custom Scoring**:
- Extend `ScoreManager`
- Override `add_line_clear_score()`

**Different Piece Sets**:
- Modify `Tetromino.SHAPES`
- Add new piece types to enum

**Game Modes**:
- Add new states to `GameState` enum
- Extend `TetrisGameController`

**Special Effects**:
- Connect to existing signals
- No backend changes needed

**AI/Replay**:
- Use `TetrisGameController` methods directly
- Bypass input system

## Testing Strategy

**Unit Tests**: Each component independently
- Tetromino: Rotation, wall kicks
- GameBoard: Collision, line clearing
- ScoreManager: Point calculation
- PieceSpawner: Randomization fairness

**Integration Tests**: Component interaction
- Controller + Board: Movement + collision
- Controller + Spawner: Piece lifecycle
- Full system: Complete gameplay loop

**See**: `validation_test.gd` for test implementation

---

## Quick Reference

**Add to scene**:
```gdscript
var manager = TetrisGameManager.new()
add_child(manager)
```

**Start game**:
```gdscript
manager.start_new_game()
```

**Connect signals**:
```gdscript
manager.game_controller.piece_moved.connect(on_moved)
```

**Get data**:
```gdscript
var board = manager.get_board()
var piece = manager.get_current_piece()
```

**That's it!** Everything else is handled automatically.
