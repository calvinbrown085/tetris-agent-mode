# Ghost Piece Alignment Fix

## Issue
The ghost piece (outline showing where piece will land) didn't line up with where the piece actually was on the board.

## Root Cause
**Coordinate System Mismatch**

The code was mixing two different coordinate systems:

1. **Backend `get_ghost_piece_blocks()`** returns absolute grid positions (e.g., [3,18], [4,18], [5,18], [6,18] for an I-piece)
2. **UI rendering** expects a piece anchor position + relative block offsets (e.g., position [3,18] + offsets [0,0], [1,0], [2,0], [3,0])

### The Bug
```gdscript
# BEFORE (Buggy):
var ghost_blocks = backend_manager.get_ghost_piece_blocks()
# Returns: [[3,18], [4,18], [5,18], [6,18]] - absolute positions

game_board.update_ghost_piece(ghost_blocks[0])
# Passes: [3,18] - just the first block position!

# Then in UI:
for block in blocks:  # blocks are [[0,0], [1,0], [2,0], [3,0]] - relative offsets
    var draw_pos = Vector2(ghost_piece_position.x + block.x, ghost_piece_position.y + block.y)
    # Draws at: [3+0,18+0], [3+1,18+0], [3+2,18+0], [3+3,18+0]
    # Which is correct for an I-piece at position [3,18]

# BUT: ghost_piece_position was [3,18] (first block), NOT the actual anchor!
# This caused misalignment when the piece's anchor isn't at its first block
```

## The Fix

**Calculate the ghost piece anchor position correctly:**

```gdscript
# AFTER (Fixed):
func _update_ghost_piece(piece: Tetromino):
    # Calculate where the piece would land (anchor position + drop distance)
    var drop_distance = backend_manager.game_controller.board.get_drop_distance(piece)
    var ghost_position = Vector2i(piece.position.x, piece.position.y + drop_distance)
    game_board.update_ghost_piece(ghost_position)
```

Now the ghost position is:
- **Current piece anchor position** (e.g., [3, 2])
- **Plus drop distance** (e.g., 16 cells down)
- **Equals ghost anchor position** (e.g., [3, 18])

The UI then correctly draws the ghost piece using this anchor + the same relative block offsets as the current piece.

## What Changed

**File:** `scripts/game_manager.gd`

### Added New Helper Function
```gdscript
func _update_ghost_piece(piece: Tetromino):
    var drop_distance = backend_manager.game_controller.board.get_drop_distance(piece)
    var ghost_position = Vector2i(piece.position.x, piece.position.y + drop_distance)
    game_board.update_ghost_piece(ghost_position)
```

### Updated Event Handlers
```gdscript
# Changed in _on_backend_piece_spawned():
_update_ghost_piece(piece)  # Instead of passing ghost_blocks[0]

# Changed in _on_backend_piece_moved():
_update_ghost_piece(piece)  # Instead of passing ghost_blocks[0]

# Changed in _on_backend_piece_rotated():
_update_ghost_piece(piece)  # Instead of passing ghost_blocks[0]
```

## How It Works Now

1. **Piece moves/rotates** → Event triggers
2. **Calculate drop distance** from current position to landing position
3. **Ghost anchor position** = current position + drop distance (in Y axis only)
4. **Pass anchor position** to UI (not absolute block positions)
5. **UI draws ghost** using anchor + same relative offsets as current piece

## Testing

Ghost piece should now:
- ✅ Line up perfectly under the current piece
- ✅ Show exactly where the piece will land
- ✅ Move correctly when piece moves left/right
- ✅ Adjust correctly when piece rotates
- ✅ Handle all 7 tetromino shapes correctly

## Why This Matters

Different tetromino shapes have their anchor at different positions:
- **I-piece:** Anchor at position [1,0] relative to bounds
- **O-piece:** Anchor at position [1,0] relative to bounds
- **T/S/Z/J/L:** Various anchor positions

Using the first block's position as the anchor caused the ghost to be offset differently for each shape. Now it uses the actual piece anchor, so all shapes align correctly!

---

## Try It Now! 🎮

1. Reload the project
2. Play a game
3. The ghost piece outline should now perfectly align under each piece!

The ghost piece is your landing preview - it should always show exactly where pressing Space (hard drop) will place the piece.
