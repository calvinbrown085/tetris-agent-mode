# Tetris - Quick Start Guide

## 🎮 How to Play

1. **Open the project** in Godot 4.6
2. **Press F5** to run the game
3. **Click "START GAME"** on the main menu
4. **Play Tetris!**

## 🕹️ Controls

| Action | Key |
|--------|-----|
| Move Left | ← Left Arrow |
| Move Right | → Right Arrow |
| Soft Drop | ↓ Down Arrow |
| Rotate | ↑ Up Arrow |
| Rotate CCW | Z |
| Hard Drop | Space |
| Pause | P |

## 🎯 Objective

- **Arrange falling blocks** to create complete horizontal lines
- **Complete lines disappear** and you earn points
- **Game speeds up** as you level up (every 10 lines)
- **Game ends** when blocks stack to the top

## 💯 Scoring

- **1 Line** = 100 × Level
- **2 Lines** = 300 × Level
- **3 Lines** = 500 × Level
- **4 Lines (TETRIS!)** = 800 × Level
- **Soft Drop** = 1 point per cell
- **Hard Drop** = 2 points per cell

## 🎨 Features

- ✅ Classic Tetris gameplay
- ✅ Ghost piece preview (shows where piece will land)
- ✅ Next piece preview
- ✅ SRS rotation system with wall kicks
- ✅ Lock delay (0.5 seconds to adjust before locking)
- ✅ Smooth movement (DAS/ARR)
- ✅ Progressive difficulty (speed increases with level)
- ✅ Pause/resume
- ✅ Restart anytime

## 🎲 The 7 Pieces

```
I - Cyan Line     ████
O - Yellow Square ██
                  ██
T - Purple T      ███
                   █
S - Green Z       ██
                 ██
Z - Red Z        ██
                  ██
J - Blue J       █
                 ███
L - Orange L       █
                 ███
```

## 🏆 Pro Tips

1. **Use the ghost piece** - The faint outline shows where your piece will land
2. **Look ahead** - Check the next piece preview to plan your moves
3. **T-Spins** - Rotate pieces at the last moment to fit tight spaces
4. **Build flat** - Leaving gaps makes it harder to clear lines
5. **Save the I-piece** - Use I-pieces for Tetrises (clearing 4 lines at once)

## 🔧 Technical Details

- **Board Size**: 10 columns × 20 rows
- **Starting Level**: 1
- **Level Up**: Every 10 lines cleared
- **Maximum Speed**: Level-dependent (gets very fast!)

## 🐛 Troubleshooting

**Pieces not moving?**
- Make sure the game isn't paused (press P to unpause)
- Check that you're using the arrow keys

**Game too fast/slow?**
- Speed is level-based - it will increase as you clear lines
- Restart to begin at level 1

**Want to restart?**
- Press P to pause, then click "RESTART"

## 📁 Project Structure

```
calvin-2d-game/
├── scenes/
│   ├── main_menu.tscn    # Start here
│   └── game.tscn         # Main game
├── scripts/
│   ├── game_manager.gd   # Integration layer
│   ├── game_board.gd     # Visual rendering
│   └── tetris/           # Backend logic
│       ├── tetris_game_manager.gd
│       ├── tetris_game_controller.gd
│       └── ...
└── documentation/
    ├── INTEGRATION_SUMMARY.md   # Technical details
    └── QUICK_START.md          # This file
```

## 🚀 Next Steps

Want to customize the game?

1. **Enable Hold Piece**: In `game_manager.gd`, change:
   ```gdscript
   backend_manager.enable_hold = true
   ```

2. **Change Starting Level**: In `game_manager.gd`, change:
   ```gdscript
   backend_manager.starting_level = 5  # Start at level 5
   ```

3. **Add Sound Effects**: Connect to backend signals and play audio
   ```gdscript
   controller.piece_locked.connect(func(): play_sound("lock"))
   controller.board.lines_cleared.connect(func(lines, is_tetris):
       play_sound("tetris" if is_tetris else "line_clear"))
   ```

## 📖 More Information

- `INTEGRATION_SUMMARY.md` - Complete technical documentation
- `UI_INTEGRATION_GUIDE.md` - UI integration details
- `TETRIS_BACKEND_COMPLETE.md` - Backend system overview

---

**Have fun playing! 🎮✨**
