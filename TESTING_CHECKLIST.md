# Tetris Integration Testing Checklist

## Pre-Flight Checks

- [ ] Project opens in Godot 4.6 without errors
- [ ] No script compilation errors in Output panel
- [ ] All scenes load correctly (main_menu.tscn, game.tscn)
- [ ] Input actions configured in Project Settings → Input Map

## Main Menu Tests

- [ ] Main menu displays correctly
- [ ] "TETRIS" title visible
- [ ] START GAME button works
- [ ] QUIT button works (closes application)
- [ ] Scene transitions to game.tscn on start

## Game Start Tests

- [ ] Game scene loads completely
- [ ] Board renders (10×20 grid with grid lines)
- [ ] Score displays as "0"
- [ ] Level displays as "1"
- [ ] Lines displays as "0"
- [ ] Next piece preview shows a piece
- [ ] First piece spawns at top of board
- [ ] Ghost piece appears below current piece

## Movement Tests

### Basic Movement
- [ ] Left arrow moves piece left
- [ ] Right arrow moves piece right
- [ ] Down arrow makes piece fall faster (soft drop)
- [ ] Piece can't move through walls (left/right boundaries)
- [ ] Piece can't move through locked blocks

### Advanced Movement
- [ ] Holding left/right causes continuous movement (DAS)
- [ ] Piece moves smoothly with DAS
- [ ] Releasing direction key stops movement

## Rotation Tests

- [ ] Up arrow rotates piece clockwise
- [ ] Z key rotates piece counter-clockwise
- [ ] O piece doesn't rotate (square stays square)
- [ ] Other pieces rotate through 4 states
- [ ] Wall kicks work (piece adjusts position when rotating near wall)
- [ ] Can't rotate into locked blocks

## Dropping Tests

- [ ] Space bar instantly drops piece to bottom (hard drop)
- [ ] Hard drop locks piece immediately
- [ ] Soft drop (down arrow) increases fall speed
- [ ] Piece falls automatically even without input
- [ ] Lock delay activates when piece touches bottom
- [ ] Lock delay gives ~0.5 seconds to adjust piece

## Line Clearing Tests

- [ ] Completing a horizontal line clears it
- [ ] Cleared line disappears
- [ ] Blocks above cleared line fall down
- [ ] Can clear multiple lines at once (2, 3, or 4)
- [ ] Tetris (4 lines) works correctly
- [ ] Board state updates after line clear

## Scoring Tests

- [ ] Score increases when clearing lines
- [ ] 1 line = 100 × level points
- [ ] 2 lines = 300 × level points
- [ ] 3 lines = 500 × level points
- [ ] 4 lines (Tetris) = 800 × level points
- [ ] Soft drop adds 1 point per cell
- [ ] Hard drop adds 2 points per cell
- [ ] Score display updates immediately

## Level Progression Tests

- [ ] Level starts at 1
- [ ] Level increases after 10 lines cleared
- [ ] Level increases after 20 lines (level 3)
- [ ] Speed increases with level
- [ ] Fall speed gets noticeably faster
- [ ] Level display updates correctly

## Visual Tests

### Piece Rendering
- [ ] All 7 piece types render with correct colors:
  - [ ] I-piece: Cyan
  - [ ] O-piece: Yellow
  - [ ] T-piece: Purple
  - [ ] S-piece: Green
  - [ ] Z-piece: Red
  - [ ] J-piece: Blue
  - [ ] L-piece: Orange
- [ ] Pieces have 3D block effect (highlight/shadow)
- [ ] Current piece visible on board
- [ ] Ghost piece visible (semi-transparent)
- [ ] Ghost piece always at correct drop position

### Board Rendering
- [ ] Grid lines visible
- [ ] Locked pieces visible on board
- [ ] Board background correct color
- [ ] No visual glitches when pieces move
- [ ] No flickering

### Next Piece Preview
- [ ] Shows correct next piece
- [ ] Piece centered in preview box
- [ ] Same color as piece will be on board
- [ ] Updates when new piece spawns

## Pause System Tests

- [ ] P key pauses game
- [ ] Pause screen appears with "PAUSED" text
- [ ] Pieces stop falling when paused
- [ ] Can't move pieces when paused
- [ ] P key resumes game
- [ ] Resume button on pause screen works
- [ ] Game continues correctly after resume
- [ ] Menu button on pause screen works

## Game Over Tests

- [ ] Game ends when pieces stack to top
- [ ] "GAME OVER" screen appears
- [ ] Final score displayed correctly
- [ ] Can't move pieces after game over
- [ ] Restart button works
- [ ] Menu button works
- [ ] New game starts fresh (score/level/board reset)

## Restart Tests

- [ ] Can restart from pause menu
- [ ] Can restart from game over screen
- [ ] Restart clears board completely
- [ ] Restart resets score to 0
- [ ] Restart resets level to 1
- [ ] Restart resets lines to 0
- [ ] Restart spawns new first piece
- [ ] Restart updates next piece preview

## Edge Case Tests

### Boundary Tests
- [ ] Piece spawns at correct position (top center)
- [ ] Can't move piece off left edge
- [ ] Can't move piece off right edge
- [ ] Can't move piece below bottom
- [ ] Pieces lock at correct positions

### Collision Tests
- [ ] Piece stops at other locked pieces
- [ ] Can't rotate into locked pieces
- [ ] Wall kicks handle edge cases
- [ ] Game over triggers if can't spawn piece

### Timing Tests
- [ ] Lock delay works consistently
- [ ] DAS activates at correct time
- [ ] Auto-repeat rate feels responsive
- [ ] Fall speed appropriate for level

## Performance Tests

- [ ] Game runs smoothly at 60 FPS
- [ ] No lag when moving pieces
- [ ] No lag when clearing lines
- [ ] No lag when level increases
- [ ] Memory usage stable (no leaks)
- [ ] CPU usage reasonable

## Integration Tests

### Backend-UI Communication
- [ ] Backend signals reach UI
- [ ] UI updates reflect backend state
- [ ] Input flows from UI to backend
- [ ] No signal connection errors in console
- [ ] No null reference errors

### Data Conversion
- [ ] Piece data converts correctly backend→UI
- [ ] Board state syncs correctly
- [ ] Colors match between systems
- [ ] Positions align correctly

## Stress Tests

- [ ] Can play multiple games in a row
- [ ] Can restart many times without issues
- [ ] Can pause/resume many times
- [ ] Game stable after clearing many lines (100+)
- [ ] Game stable at high levels (10+)

## Regression Tests

- [ ] Re-run all tests after any code changes
- [ ] Verify no new bugs introduced
- [ ] Check that existing features still work

## Platform Tests

### Desktop
- [ ] Windows (if applicable)
- [ ] macOS (if applicable)
- [ ] Linux (if applicable)

### Input
- [ ] Keyboard controls work
- [ ] Arrow keys responsive
- [ ] Letter keys (Z, P, C) work
- [ ] Space bar works

## Bug Tracking

### Known Issues
Document any issues found:

1. Issue: _______________________________________________
   Severity: [ ] Critical [ ] Major [ ] Minor
   Steps to Reproduce: _________________________________
   Expected: ___________________________________________
   Actual: _____________________________________________
   Status: [ ] Open [ ] Fixed [ ] Won't Fix

2. Issue: _______________________________________________
   Severity: [ ] Critical [ ] Major [ ] Minor
   Steps to Reproduce: _________________________________
   Expected: ___________________________________________
   Actual: _____________________________________________
   Status: [ ] Open [ ] Fixed [ ] Won't Fix

## Test Results Summary

Date Tested: _______________
Tester: ____________________
Platform: __________________
Godot Version: _____________

**Total Tests**: _____
**Passed**: _____
**Failed**: _____
**Blocked**: _____

**Overall Status**: [ ] Pass [ ] Fail [ ] Needs Work

**Notes**:
_____________________________________________________
_____________________________________________________
_____________________________________________________

## Sign-Off

Integration is ready for: [ ] Testing [ ] Review [ ] Production

Tested by: __________________ Date: ______________
Reviewed by: ________________ Date: ______________
Approved by: ________________ Date: ______________
