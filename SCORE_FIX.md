# Score/Lines Update Fix

## Issue
Score and lines counter never updated during gameplay.

## Root Cause
**Signal Connection Lost on Game Start**

When `start_game()` was called, it created a **NEW** `ScoreManager` instance:

```gdscript
# BEFORE (Buggy):
func start_game(starting_level: int = 1) -> void:
    score_manager = ScoreManager.new(starting_level)  # ❌ Creates new instance!
    score_manager.level_changed.connect(_on_level_changed)  # Only reconnects 1 signal
```

This broke all existing signal connections! The UI had connected to the old ScoreManager:
- `score_manager.score_changed` → UI update
- `score_manager.level_changed` → UI update
- `score_manager.lines_changed` → UI update

But when a NEW ScoreManager was created, these connections pointed to the old (now unused) instance. When the new ScoreManager emitted signals, nobody was listening!

## The Fix

**Reuse the existing ScoreManager instead of creating a new one:**

```gdscript
# AFTER (Fixed):
func start_game(starting_level: int = 1) -> void:
    score_manager.reset()  # ✅ Reset existing instance
    score_manager.level = starting_level  # Set starting level
    # Signal connections preserved!
```

Now the ScoreManager instance is reset but not replaced, so all UI signal connections remain intact.

## What Changed

**File:** `scripts/tetris/tetris_game_controller.gd`

```gdscript
# Removed:
score_manager = ScoreManager.new(starting_level)
score_manager.level_changed.connect(_on_level_changed)

# Replaced with:
score_manager.reset()
score_manager.level = starting_level
```

## Why This Works

The `ScoreManager.reset()` method:
1. Resets score to 0
2. Resets level to 1
3. Resets lines to 0
4. **Emits all the signals** to update UI immediately
5. **Preserves the instance** so connections stay intact

## How Signal Connections Work

**Connection Flow:**
1. `TetrisGameController._init()` creates ScoreManager instance
2. UI calls `_connect_backend_signals()` and connects to that instance
3. **OLD:** `start_game()` replaced instance → connections broken ❌
4. **NEW:** `start_game()` resets instance → connections preserved ✅

## Testing

Score display should now:
- ✅ Update when clearing lines (100/300/500/800 points)
- ✅ Update during soft drop (+1 per cell)
- ✅ Update during hard drop (+2 per cell)

Lines display should:
- ✅ Update when clearing lines
- ✅ Trigger level up every 10 lines

Level display should:
- ✅ Update every 10 lines cleared
- ✅ Increase game speed when level increases

---

## Try It Now! 🎮

1. Reload the project
2. Play a game
3. Clear some lines
4. Watch the score, lines, and level displays update in real-time!

---

## Technical Note

This is a common bug pattern in game development: **Object Replacement Breaking Signal Connections**

**Rule of thumb:** If objects have signals connected to them, either:
- Never replace the instance (use reset methods)
- Re-establish all connections after replacement
- Emit a "replaced" signal so listeners can reconnect

In our case, using `reset()` is the cleanest solution! ✅
