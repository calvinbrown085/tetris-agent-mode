# Tetris UI Visual Guide

## Main Menu Layout

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│             T E T R I S                 │
│      Classic Block Puzzle Game          │
│                                         │
│                                         │
│          ┌─────────────┐                │
│          │ START GAME  │                │
│          └─────────────┘                │
│                                         │
│          ┌─────────────┐                │
│          │    QUIT     │                │
│          └─────────────┘                │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

## Game Screen Layout

```
┌───────────────────────────────────────────────────────────────┐
│  ┌────────┐         ┌──────────┐         ┌────────┐          │
│  │ SCORE  │         │          │         │  NEXT  │          │
│  │        │         │          │         │        │          │
│  │   0    │         │          │         │  ┌──┐  │          │
│  └────────┘         │          │         │  └──┘  │          │
│                     │          │         └────────┘          │
│  ┌────────┐         │          │                             │
│  │ LEVEL  │         │   GAME   │         ┌────────┐          │
│  │        │         │          │         │CONTROLS│          │
│  │   1    │         │   BOARD  │         │        │          │
│  └────────┘         │          │         │← → Move│          │
│                     │  10 x 20 │         │↓  Drop │          │
│  ┌────────┐         │   GRID   │         │↑ Rotate│          │
│  │ LINES  │         │          │         │Space HD│          │
│  │        │         │          │         │P  Pause│          │
│  │   0    │         │          │         └────────┘          │
│  └────────┘         │          │                             │
│                     │          │                             │
│                     │          │                             │
│                     │          │                             │
│                     └──────────┘                             │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

## Game Board Detail

```
┌────────────────────────────┐
│ 0  1  2  3  4  5  6  7  8  9│ ← Column indices
│                            │
│        ┌──┬──┬──┬──┐       │ ← Current piece (I-block)
│        └──┴──┴──┴──┘       │
│                            │
│                            │
│                            │
│                            │
│                            │
│                            │
│                            │
│                            │
│                            │
│                            │
│                            │
│        ░░░░░░░░░░░░        │ ← Ghost piece (transparent)
│ ■ ■ ■                      │
│ ■ ■   ■ ■ ■ ■              │
│ ■ ■ ■ ■ ■ ■ ■   ■          │
│ ■ ■ ■ ■ ■ ■ ■ ■ ■          │ ← Placed blocks
└────────────────────────────┘
  0  1  2  3  4  5  6  7  8  9
Row 19 (bottom)
```

## Tetromino Shapes and Colors

```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  I-Block (Cyan)        O-Block (Yellow)                  │
│  ┌──┬──┬──┬──┐        ┌──┬──┐                           │
│  └──┴──┴──┴──┘        ├──┼──┤                           │
│                       └──┴──┘                           │
│                                                          │
│  T-Block (Purple)      S-Block (Green)                   │
│     ┌──┐              ┌──┬──┐                           │
│  ┌──┼──┼──┐           ├──┼──┤                           │
│  └──┴──┴──┘           └──┴──┘                           │
│                                                          │
│  Z-Block (Red)         J-Block (Blue)                    │
│  ┌──┬──┐              ┌──┐                              │
│  ├──┼──┤              ├──┼──┬──┐                        │
│  └──┴──┘              └──┴──┴──┘                        │
│                                                          │
│  L-Block (Orange)                                        │
│        ┌──┐                                              │
│  ┌──┬──┼──┤                                              │
│  └──┴──┴──┘                                              │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## Block Rendering (3D Effect)

```
Individual Block Detail:

┌──────────────┐
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓│  ← Highlight (lighter)
│▓░░░░░░░░░░░░▓│
│▓░          ░▓│
│▓░  MAIN    ░▓│
│▓░  COLOR   ░▓│
│▓░          ░▓│
│▓░░░░░░░░░░░░▓│
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓│  ← Shadow (darker)
└──────────────┘

Ghost Block (transparent):

┌──────────────┐
│              │
│ ┌──────────┐ │
│ │          │ │
│ │ 30% Alpha│ │
│ │          │ │
│ └──────────┘ │
│              │
└──────────────┘
```

## Pause Screen Overlay

```
┌───────────────────────────────────────────────────────────┐
│                                                           │
│               (Darkened Background)                       │
│                                                           │
│                                                           │
│                   P A U S E D                            │
│                                                           │
│              Press P to Resume                            │
│                                                           │
│                                                           │
│              ┌─────────────┐                             │
│              │   RESUME    │                             │
│              └─────────────┘                             │
│                                                           │
│              ┌─────────────┐                             │
│              │ MAIN MENU   │                             │
│              └─────────────┘                             │
│                                                           │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

## Game Over Screen Overlay

```
┌───────────────────────────────────────────────────────────┐
│                                                           │
│               (Darkened Background)                       │
│                                                           │
│                                                           │
│               G A M E   O V E R                          │
│                                                           │
│              Final Score: 12,450                          │
│                                                           │
│                                                           │
│              ┌─────────────┐                             │
│              │   RESTART   │                             │
│              └─────────────┘                             │
│                                                           │
│              ┌─────────────┐                             │
│              │ MAIN MENU   │                             │
│              └─────────────┘                             │
│                                                           │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

## Line Clear Animation

```
Frame 1: Normal
┌────────────┐
│            │
│            │
│ ■ ■ ■ ■ ■  │
│ ■ ■ ■ ■ ■ ■│ ← Full line
│ ■ ■ ■ ■ ■  │
└────────────┘

Frame 2: Flash (white)
┌────────────┐
│            │
│            │
│ ■ ■ ■ ■ ■  │
│ ▓▓▓▓▓▓▓▓▓▓▓│ ← Flashing
│ ■ ■ ■ ■ ■  │
└────────────┘

Frame 3: Cleared (blocks fall)
┌────────────┐
│            │
│            │
│            │
│ ■ ■ ■ ■ ■  │ ← Moved down
│ ■ ■ ■ ■ ■  │
└────────────┘
```

## Color Palette

### Background Colors
```
Main Background:    #141418  ████  (Very dark blue-grey)
Panel Background:   #262633  ████  (Dark blue-grey)
Grid Lines:         #33334D  ████  (Medium dark grey)
```

### Tetromino Colors
```
I (Cyan):          #00E5E5  ████
O (Yellow):        #E5E500  ████
T (Purple):        #9900E5  ████
S (Green):         #00E500  ████
Z (Red):           #E50000  ████
J (Blue):          #0000E5  ████
L (Orange):        #E57F00  ████
```

### UI Colors
```
Primary Text:      #FFFFFF  ████  (White)
Secondary Text:    #999999  ████  (Grey)
Accent:           #66CCFF  ████  (Light blue)
Error/Game Over:  #FF4D4D  ████  (Light red)
Success:          #4DFF4D  ████  (Light green)
```

## Responsive Behavior

### Portrait Mode (Mobile)
```
┌─────────┐
│ Score   │
│ Level   │
│ Lines   │
├─────────┤
│         │
│  Board  │
│         │
├─────────┤
│  Next   │
│ Controls│
└─────────┘
```

### Landscape Mode (Desktop)
```
┌───────┬─────────┬───────┐
│ Score │         │  Next │
│ Level │  Board  │Control│
│ Lines │         │       │
└───────┴─────────┴───────┘
```

## Animation Timings

- **Line Clear Flash**: 0.3 seconds
- **Piece Lock**: Instant
- **Score Count Up**: ~0.5 seconds for 100 points
- **Screen Shake**: 0.2-0.5 seconds (decays)
- **Button Hover**: Instant
- **Scene Transition**: Instant (can be enhanced)

## Z-Index Layers

```
Layer 5: Pause/Game Over Overlay (top)
Layer 4: UI Text and Buttons
Layer 3: Current Piece
Layer 2: Ghost Piece
Layer 1: Placed Blocks
Layer 0: Grid Background (bottom)
```

## Touch Targets (Mobile)

For future mobile implementation:

```
┌───────────────────────────────────┐
│         [Tap: Rotate]             │
├───────────────────────────────────┤
│                                   │
│        [Game Board Area]          │
│     [Swipe Left/Right: Move]      │
│     [Swipe Down: Soft Drop]       │
│                                   │
├───────┬─────────┬─────────────────┤
│[Pause]│[Rotate] │   [Hard Drop]   │
└───────┴─────────┴─────────────────┘

Minimum button size: 60x60 pixels
Recommended: 80x80 pixels for touch
```

## Visual States

### Button States
- **Normal**: Grey background, white text
- **Hover**: Light border glow, cyan tint
- **Pressed**: Darker background, slight scale
- **Disabled**: Greyed out (50% opacity)

### Game States
- **Playing**: Full color, responsive
- **Paused**: Darkened overlay (70% black)
- **Game Over**: Darkened overlay (80% black)
- **Line Clearing**: Flash animation on affected rows

## Accessibility Considerations

- High contrast colors for visibility
- Large text sizes for readability
- Clear visual feedback for all actions
- Keyboard navigation support
- Screen shake can be disabled (future enhancement)

## Performance Targets

- 60 FPS on mobile devices
- < 16ms frame time
- Minimal garbage collection
- Efficient redraw only when needed
- Low memory footprint (~50MB)
