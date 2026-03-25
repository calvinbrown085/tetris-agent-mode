# Tetris Agent Mode - Developer Guide

This repository contains a complete Tetris game implemented in Godot 4.6 using GDScript. It features a robust, modular backend designed with the Single Responsibility Principle, handling all core game logic, scoring, piece management, and input processing, along with a separate UI layer. The project is structured for clear separation of concerns, making the backend reusable and the overall game easily maintainable.

## Architecture

The project separates the Tetris game's core logic (backend) from its Godot-specific UI and overall game management.

The `scripts/tetris` directory encapsulates a self-contained Tetris backend, exposing `tetris_game_manager.gd` as its primary interface. This backend can be integrated as a `Node` into any Godot scene.

The main Godot project (at the root) utilizes this backend, with `scripts/game_manager.gd` orchestrating the high-level game flow, scene transitions, and interacting with the `scripts/tetris/tetris_game_manager.gd` node. The UI components (`scripts/game_ui.gd`, `scripts/game_board.gd`) are responsible for rendering the game state received from the backend.

```
Overall Godot Project Structure
├── project.godot
├── scenes/
│   ├── main_menu.tscn     (Entry point scene)
│   └── game.tscn          (Gameplay scene, integrates UI and backend)
├── scripts/
│   ├── game_manager.gd    (High-level game flow, scene management)
│   ├── game_ui.gd         (Main UI logic for the overall game scene)
│   ├── game_board.gd      (Visual rendering of the Tetris board)
│   └── tetris/            (Encapsulated Tetris Backend Logic)
│       ├── tetris_game_manager.gd (Node - Backend's main interface for UI)
│       └── tetris_game_controller.gd (Core game orchestrator)
│           ├── game_board.gd        (Backend: abstract board state & collision)
│           ├── score_manager.gd     (Backend: scoring & levels)
│           ├── piece_spawner.gd     (Backend: piece generation)
│           ├── input_handler.gd     (Backend: input processing)
│           └── tetromino.gd         (Backend: piece definitions & rotations)
└── resources/
```

## Key Files

*   `project.godot`: The main Godot project configuration file.
*   `scenes/main_menu.tscn`: The starting scene of the game, typically presenting options like "New Game."
*   `scenes/game.tscn`: The primary gameplay scene. It integrates the `tetris_game_manager.gd` node and various UI components (`game_ui.gd`, `game_board.gd`) to display and manage the game.
*   `scripts/game_manager.gd`: The top-level GDScript responsible for managing the overall game lifecycle, including scene transitions (e.g., from main menu to game) and potentially initializing or coordinating with the `tetris_game_manager.gd` backend.
*   `scripts/game_ui.gd`: Handles the graphical user interface elements for the game, such as score displays, next piece previews, hold piece display, and game state messages (e.g., "Game Over," "Paused").
*   `scripts/game_board.gd`: Manages the visual rendering of the Tetris game board on screen, drawing locked blocks, the current active piece, and the ghost piece. *This is distinct from the backend's `scripts/tetris/game_board.gd`.*
*   `scripts/tetris/`: This directory contains the entirely decoupled backend logic for a Tetris game.
    *   `scripts/tetris/tetris_game_manager.gd`: The main entry point Node for the Tetris backend. It provides an easy-to-use API for the UI to interact with and access all core game data and actions.
    *   `scripts/tetris/tetris_game_controller.gd`: The central orchestrator that manages game state, piece movement, rotation, lock delay, and coordinates interactions between all other backend components.
    *   `scripts/tetris/game_board.gd`: Manages the abstract 10x20 game board grid, handling block states, collision detection logic, and line clearing operations.
    *   `scripts/tetris/tetromino.gd`: Defines the data and behavior for all seven Tetromino piece types, including their block configurations, rotation states, and Super Rotation System (SRS) wall kick data.
    *   `scripts/tetris/score_manager.gd`: Implements the scoring system, level progression, and manages game statistics (score, level, lines cleared).
    *   `scripts/tetris/piece_spawner.gd`: Manages piece generation using a 7-bag randomization system and maintains the next piece preview queue.
    *   `scripts/tetris/input_handler.gd`: Processes raw player input into game-specific actions, abstracting input handling for the `tetris_game_controller.gd`.
    *   `scripts/tetris/input_config_helper.gd`: A utility script to automatically configure Godot's input map for the required Tetris actions.
    *   `scripts/tetris/validation_test.gd`: Contains unit-like tests for the backend logic to ensure correct behavior.
*   `icon.svg`: The project's icon, displayed in the Godot editor and as the application icon.

## How to Run

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/calvinbrown085/tetris-agent-mode.git
    cd tetris-agent-mode
    ```
2.  **Open in Godot Engine:**
    Open the project in Godot Engine (version 4.x is required, Godot 4.6 or later recommended).
3.  **Configure Input Actions:**
    Run `scripts/tetris/input_config_helper.gd` directly from the Godot Editor (File > Run) to automatically configure the required input actions in your project settings.
    Alternatively, manually add the following actions in Project Settings > Input Map:
    *   `tetris_move_left` (Default: Left Arrow)
    *   `tetris_move_right` (Default: Right Arrow)
    *   `tetris_move_down` (Default: Down Arrow)
    *   `tetris_rotate_cw` (Default: Up Arrow)
    *   `tetris_rotate_ccw` (Default: Z)
    *   `tetris_hard_drop` (Default: Space)
    *   `tetris_hold` (Default: C)
    *   `tetris_pause` (Default: Escape)
4.  **Run the Project:**
    Press `F5` in the Godot Editor to run the main scene (`main_menu.tscn`).

## Environment Variables

This project does not rely on traditional environment variables for configuration. Instead, key settings like `starting_level`, `enable_ghost_piece`, and `enable_hold` are exposed as `export` variables on the `tetris_game_manager.gd` Node. These can be configured directly within the Godot editor's Inspector panel when the node is selected, or programmatically via GDScript.

## How to Test

The backend includes a `scripts/tetris/validation_test.gd` script, which can be extended or run for automated testing of core logic. For comprehensive verification of the integrated game, perform the following manual testing:

*   **Piece Spawning:**
    *   Verify all 7 distinct tetromino pieces (I, O, T, S, Z, J, L) spawn correctly.
    *   Confirm the 7-bag randomization system ensures fair distribution of pieces.
    *   Check that the "next piece" preview accurately displays the upcoming pieces.
*   **Movement:**
    *   Test left and right horizontal movement.
    *   Verify Delayed Auto Shift (DAS) and Auto Repeat Rate (ARR) provide smooth, responsive repeated movement.
    *   Confirm soft drop increases fall speed and awards 1 point per cell dropped.
    *   Test hard drop for instant placement at the lowest valid position, awarding 2 points per cell and locking the piece.
*   **Rotation:**
    *   Verify pieces rotate clockwise and counter-clockwise with their respective inputs.
    *   Test the Super Rotation System (SRS) with wall kicks, ensuring rotations function correctly near walls and other placed blocks.
    *   Confirm lock delay resets upon successful rotation, allowing for further adjustments.
*   **Lock Delay:**
    *   Observe the 0.5-second delay before a piece locks after landing, allowing for last-moment horizontal shifts or rotations.
    *   Confirm that successful piece movement or rotation resets this lock delay timer.
*   **Hold System:**
    *   Test pressing the hold key (`C`) to swap the current piece with the held piece (if one exists).
    *   Verify a piece can only be held once per spawn.
    *   Check that the held piece preview updates correctly.
*   **Line Clearing:**
    *   Ensure full lines are correctly cleared from the board.
    *   Verify blocks above cleared lines fall down to fill the gaps.
    *   Confirm line clear animations (if any) and sound effects trigger.
*   **Scoring and Leveling:**
    *   Check that scores for single, double, triple, and Tetris line clears are calculated correctly based on the current level (100/300/500/800 multiplied by level).
    *   Verify score is awarded for soft and hard drops.
    *   Confirm the game level increases every 10 lines cleared.
    *   Observe that fall speed dynamically increases with the level.
*   **Game States:**
    *   Test transitions between `IDLE`, `PLAYING`, `PAUSED`, and `GAME_OVER` states.
    *   Verify the game over condition is correctly detected (new piece spawns intersecting existing blocks).
    *   Test pause/resume functionality.
*   **Ghost Piece:**
    *   If `enable_ghost_piece` is true, confirm a ghost piece visually indicates where the current piece would land on hard drop.
    *   Verify the ghost piece position updates correctly with piece movement and rotation.