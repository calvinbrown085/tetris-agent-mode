# UI Integration Guide for Tetris Backend

This guide is for the UI agent to understand how to integrate with the backend logic.

## Quick Start

### 1. Add Game Manager to Scene

```gdscript
# In your main scene script
extends Node2D

var game_manager: TetrisGameManager

func _ready():
    game_manager = TetrisGameManager.new()
    add_child(game_manager)

    # Connect signals (see below)
    setup_signals()

    # Start game when ready
    game_manager.start_new_game()
```

### 2. Essential Signals to Connect

```gdscript
func setup_signals():
    var controller = game_manager.game_controller

    # Must-have for rendering
    controller.piece_moved.connect(_on_piece_moved)
    controller.piece_rotated.connect(_on_piece_rotated)
    controller.piece_spawned.connect(_on_piece_spawned)
    controller.board.board_updated.connect(_on_board_updated)

    # Must-have for UI updates
    controller.score_manager.score_changed.connect(_on_score_changed)
    controller.score_manager.level_changed.connect(_on_level_changed)
    controller.board.lines_cleared.connect(_on_lines_cleared)

    # Game state
    controller.game_over.connect(_on_game_over)
    controller.game_paused.connect(_on_game_paused)
```

## Rendering the Game

### Board Rendering (10x20 grid)

```gdscript
func render_board():
    var board = game_manager.get_board()

    # Clear previous rendering
    clear_board_sprites()

    # Render locked blocks
    for y in range(board.BOARD_HEIGHT):
        for x in range(board.BOARD_WIDTH):
            var color = board.get_cell(x, y)
            if color != null:
                draw_block_sprite(x, y, color)

    # Render current active piece
    render_current_piece()

    # Render ghost piece (preview of where piece will land)
    render_ghost_piece()
```

### Current Piece Rendering

```gdscript
func render_current_piece():
    var piece = game_manager.get_current_piece()
    if piece == null:
        return

    var blocks = piece.get_blocks()
    for block in blocks:
        draw_block_sprite(block.x, block.y, piece.color)
```

### Ghost Piece Rendering

```gdscript
func render_ghost_piece():
    var ghost_blocks = game_manager.get_ghost_piece_blocks()
    for block in ghost_blocks:
        # Draw semi-transparent version
        draw_ghost_block_sprite(block.x, block.y, Color(1, 1, 1, 0.3))
```

### Next Pieces Preview

```gdscript
func render_next_pieces():
    var next_pieces = game_manager.get_piece_spawner().get_next_pieces()

    for i in range(min(3, next_pieces.size())):
        var piece_type = next_pieces[i]
        var preview_piece = Tetromino.new(piece_type, Vector2i(0, 0))

        # Draw in preview area
        var preview_blocks = preview_piece.get_blocks()
        for block in preview_blocks:
            # Position in preview panel (offset by i for vertical stacking)
            var preview_pos = Vector2i(block.x, block.y + i * 3)
            draw_preview_block(preview_pos.x, preview_pos.y, preview_piece.color)
```

### Held Piece Display

```gdscript
func render_held_piece():
    var held_type = game_manager.get_held_piece_type()
    if held_type == -1:
        return  # No held piece

    var held_piece = Tetromino.new(held_type, Vector2i(0, 0))
    var blocks = held_piece.get_blocks()

    for block in blocks:
        draw_held_block(block.x, block.y, held_piece.color)
```

## UI Elements to Display

### Score Panel

```gdscript
func update_score_display():
    var score_mgr = game_manager.get_score_manager()

    score_label.text = "Score: %d" % score_mgr.get_current_score()
    level_label.text = "Level: %d" % score_mgr.get_current_level()
    lines_label.text = "Lines: %d" % score_mgr.get_lines_cleared()
```

### Game State Indicators

```gdscript
func update_game_state_ui():
    var state = game_manager.get_game_state()

    match state:
        TetrisGameController.GameState.IDLE:
            show_start_screen()
        TetrisGameController.GameState.PLAYING:
            hide_overlays()
        TetrisGameController.GameState.PAUSED:
            show_pause_overlay()
        TetrisGameController.GameState.GAME_OVER:
            show_game_over_screen()
```

## Coordinate System

- **Board**: 10 columns (0-9) × 20 rows (0-19)
- **Origin**: Top-left is (0, 0)
- **Block Size**: Define your own (e.g., 32×32 pixels)
- **Conversion**: `screen_pos = board_pos * BLOCK_SIZE`

```gdscript
const BLOCK_SIZE = 32  # pixels
const BOARD_OFFSET = Vector2(100, 50)  # offset from screen edge

func board_to_screen(board_pos: Vector2i) -> Vector2:
    return Vector2(board_pos) * BLOCK_SIZE + BOARD_OFFSET
```

## Animation Opportunities

### When to Trigger Animations

```gdscript
# Piece locked - play "thud" animation
controller.piece_locked.connect(func(piece):
    play_lock_animation(piece.get_blocks())
)

# Lines cleared - play clear animation
controller.board.lines_cleared.connect(func(lines, is_tetris):
    if is_tetris:
        play_tetris_animation()
    else:
        play_line_clear_animation(lines)
)

# Level up - play celebration
controller.score_manager.level_changed.connect(func(level):
    play_level_up_animation(level)
)

# Hard drop - play fast drop animation
controller.piece_hard_dropped.connect(func(distance):
    play_hard_drop_animation(distance)
)
```

## Audio Cues

### Suggested Sound Effects

```gdscript
# Movement sounds
controller.piece_moved.connect(func(_): play_sfx("move"))
controller.piece_rotated.connect(func(_): play_sfx("rotate"))

# Action sounds
controller.piece_locked.connect(func(_): play_sfx("lock"))
controller.piece_hard_dropped.connect(func(_): play_sfx("hard_drop"))

# Score sounds
controller.board.lines_cleared.connect(func(lines, is_tetris):
    if is_tetris:
        play_sfx("tetris")
    else:
        play_sfx("line_clear")
)

# State sounds
controller.game_over.connect(func(): play_sfx("game_over"))
controller.score_manager.level_changed.connect(func(_): play_sfx("level_up"))
```

## Input Handling

**Important**: Input is already handled by the backend! You don't need to process input events.

However, if you want to add visual feedback for button presses:

```gdscript
# Listen to input handler signals for visual feedback
var input_handler = game_manager.game_controller.input_handler

input_handler.move_left_pressed.connect(func():
    highlight_button("left")
)
input_handler.rotate_cw_pressed.connect(func():
    highlight_button("rotate")
)
# etc.
```

## Performance Tips

### Only Redraw When Needed

```gdscript
# Don't redraw every frame, only when board changes
var needs_redraw = false

func _on_board_updated():
    needs_redraw = true

func _on_piece_moved(_piece):
    needs_redraw = true

func _process(_delta):
    if needs_redraw:
        render_board()
        needs_redraw = false
```

### Use Object Pooling for Blocks

```gdscript
var block_pool: Array[Sprite2D] = []

func get_block_sprite() -> Sprite2D:
    if block_pool.is_empty():
        return create_new_block_sprite()
    return block_pool.pop_back()

func return_block_sprite(sprite: Sprite2D):
    sprite.visible = false
    block_pool.append(sprite)
```

## Common Patterns

### Full Board Render Function

```gdscript
func render_full_board():
    # 1. Clear all visuals
    clear_all_sprites()

    # 2. Draw locked blocks
    var board = game_manager.get_board()
    for y in range(board.BOARD_HEIGHT):
        for x in range(board.BOARD_WIDTH):
            var color = board.get_cell(x, y)
            if color:
                draw_block(x, y, color, false)

    # 3. Draw ghost piece
    for block in game_manager.get_ghost_piece_blocks():
        draw_block(block.x, block.y, Color.WHITE, true)

    # 4. Draw current piece
    var piece = game_manager.get_current_piece()
    if piece:
        for block in piece.get_blocks():
            draw_block(block.x, block.y, piece.color, false)

    # 5. Update UI
    update_score_display()
    render_next_pieces()
    render_held_piece()
```

### Responsive Button Implementation

```gdscript
# UI buttons that trigger game actions
func _on_pause_button_pressed():
    if game_manager.get_game_state() == TetrisGameController.GameState.PLAYING:
        game_manager.pause_game()
    else:
        game_manager.resume_game()

func _on_restart_button_pressed():
    game_manager.start_new_game()
```

## Debugging Helpers

### Visual Debug Info

```gdscript
func show_debug_info():
    var piece = game_manager.get_current_piece()
    if piece:
        debug_label.text = "Piece: %s\n" % Tetromino.Type.keys()[piece.type]
        debug_label.text += "Pos: %s\n" % str(piece.position)
        debug_label.text += "Rot: %d\n" % piece.rotation_state
        debug_label.text += "Blocks: %s\n" % str(piece.get_blocks())

    var board = game_manager.get_board()
    var drop_dist = board.get_drop_distance(piece) if piece else 0
    debug_label.text += "Drop Distance: %d\n" % drop_dist

    var score_mgr = game_manager.get_score_manager()
    debug_label.text += "Fall Speed: %.3f\n" % score_mgr.get_fall_speed()
```

## Complete Example Scene Structure

```
TetrisGame (Node2D)
├── GameManager (TetrisGameManager) - Backend
├── BoardRenderer (Node2D) - Visual board
│   └── Blocks (Node2D) - Container for block sprites
├── UI (CanvasLayer)
│   ├── ScorePanel (Panel)
│   │   ├── ScoreLabel
│   │   ├── LevelLabel
│   │   └── LinesLabel
│   ├── NextPiecesPanel (Panel)
│   ├── HeldPiecePanel (Panel)
│   ├── PauseOverlay (Panel)
│   └── GameOverScreen (Panel)
└── AudioPlayer (AudioStreamPlayer)
```

## Testing Your UI

```gdscript
# Quick test to verify integration
func test_integration():
    assert(game_manager != null, "Game manager not initialized")
    assert(game_manager.get_board() != null, "Board not accessible")
    assert(game_manager.get_score_manager() != null, "Score manager not accessible")

    game_manager.start_new_game()
    assert(game_manager.get_current_piece() != null, "Piece not spawned")

    print("✓ All integration tests passed!")
```

## Need Help?

- Check `README.md` for backend component details
- See `example_usage.gd` for working code examples
- All signals are documented in component files
- Backend is fully functional - focus on visuals!

---

**Remember**: The backend handles ALL game logic. Your job is to:
1. Render the game state
2. Update UI displays
3. Add visual polish (animations, particles, etc.)
4. Handle menus and screens
5. Add audio feedback

No need to implement collision, scoring, movement logic, etc. - it's all done! ✨
