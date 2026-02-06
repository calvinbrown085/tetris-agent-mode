# QA Bug Fixes

## Issues Found During QA Testing

### Issue 1: Left/Right Arrow Keys Move Piece All The Way ❌
**Problem:** When pressing left or right arrow, the piece would slide all the way to the edge instead of moving one cell at a time.

**Root Cause:** DAS (Delayed Auto-Shift) was being activated immediately on the first key press, causing rapid auto-repeat without the proper delay.

**Fix Applied:**
1. Removed immediate DAS activation from key press handlers
2. Added `_process()` function in `tetris_game_manager.gd` to monitor held keys
3. DAS now only activates when a key is continuously HELD, not on initial press
4. First press = single movement, then DAS kicks in after delay if key stays held

**Files Modified:**
- `scripts/tetris/tetris_game_manager.gd`

---

### Issue 2: Soft Drop (Down Arrow) Doesn't Work ❌
**Problem:** Pressing the down arrow key did nothing - pieces didn't move down faster.

**Root Cause:** Soft drop feature was never implemented (functions were empty `pass` statements).

**Fix Applied:**
1. Implemented `start_soft_drop()` and `stop_soft_drop()` in `tetris_game_controller.gd`
2. Added soft drop timer and rate (0.05 seconds = 20 cells/second)
3. Modified `_process()` to handle soft drop mode separately from normal falling
4. Added scoring: +1 point per cell moved during soft drop
5. Connected the down key press/release to soft drop start/stop

**Files Modified:**
- `scripts/tetris/tetris_game_manager.gd`
- `scripts/tetris/tetris_game_controller.gd`

---

## How DAS Works Now (Fixed)

**Delayed Auto-Shift (DAS) Behavior:**
1. Press left/right → Piece moves ONE cell immediately
2. Hold key for 133ms (DAS delay) → DAS activates
3. While DAS active → Piece moves every 33ms (ARR rate)
4. Release key → DAS stops immediately

This matches standard Tetris behavior!

---

## How Soft Drop Works Now (Fixed)

**Soft Drop Behavior:**
1. Press down arrow → Soft drop activates
2. Piece falls faster (every 0.05 seconds instead of normal speed)
3. You earn +1 point for each cell moved during soft drop
4. Release down arrow → Returns to normal falling speed
5. Works independently of normal falling - doesn't interfere

---

## Testing Checklist

After these fixes, test the following:

### Movement Tests
- [ ] Press left once → Piece moves one cell left
- [ ] Press right once → Piece moves one cell right
- [ ] Hold left → Piece moves left one cell, then after delay, slides left continuously
- [ ] Hold right → Same behavior as hold left, but rightward
- [ ] Release during DAS → Piece stops immediately

### Soft Drop Tests
- [ ] Press down → Piece falls faster
- [ ] Hold down → Piece continues falling fast
- [ ] Release down → Piece returns to normal speed
- [ ] Check score increases while holding down
- [ ] Soft drop should work all the way to bottom

### Combined Tests
- [ ] Hold left while soft dropping → Both should work together
- [ ] Rotate while soft dropping → Should work normally
- [ ] Hard drop (space) during soft drop → Should work

---

## Expected Behavior After Fixes

✅ **Single Key Press:** Moves piece exactly ONE cell
✅ **Held Key:** Moves one cell, pauses briefly, then starts auto-repeating
✅ **Down Arrow:** Makes piece fall significantly faster
✅ **Scoring:** Soft drop awards points for each cell moved

---

## Technical Details

### DAS Timing Values
- **DAS Delay:** 133ms (time before auto-repeat starts)
- **ARR Rate:** 33ms (time between auto-repeat movements)

### Soft Drop Timing
- **Normal Fall Speed:** Varies by level (slower at level 1, faster at higher levels)
- **Soft Drop Rate:** Fixed at 0.05s (50ms) = 20 cells per second
- **Scoring:** +1 point per cell during soft drop

---

## What Changed in Code

### tetris_game_manager.gd
```gdscript
# BEFORE (Buggy):
func _on_move_left_pressed():
    if game_controller.move_piece_left():
        game_controller.start_das(Vector2i(-1, 0))  # ❌ Immediate DAS

# AFTER (Fixed):
func _on_move_left_pressed():
    game_controller.move_piece_left()  # ✅ Just move once

func _process(_delta):
    # ✅ DAS handled here, based on held keys
    var direction = game_controller.input_handler.get_movement_direction()
    if direction != Vector2i.ZERO:
        if not game_controller.is_das_charging:
            game_controller.start_das(direction)
```

### tetris_game_controller.gd
```gdscript
# ADDED:
var is_soft_drop_active: bool = false
var soft_drop_timer: float = 0.0
var soft_drop_rate: float = 0.05

func start_soft_drop():
    is_soft_drop_active = true

func stop_soft_drop():
    is_soft_drop_active = false

# MODIFIED _process() to handle soft drop
if is_soft_drop_active:
    # Use faster falling speed
    # Award points for soft drop
```

---

## Try It Now! 🎮

1. Reload the project in Godot
2. Press F5 to run
3. Test left/right movement (should move one cell at a time)
4. Hold left/right (should auto-repeat after brief delay)
5. Press/hold down arrow (should fall faster)

Enjoy the improved controls! 🚀
