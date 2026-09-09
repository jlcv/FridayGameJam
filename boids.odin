package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"
import "managers"
import "screens"
import "models"

NUM_BOIDS :: 300
BOID_SIZE :: 4.0

// Window dimensions
WIDTH :: 1080
HEIGHT :: 800

// Boid parameters
MAX_SPEED :: 6.5
SEP_WEIGHT :: 0.5
ALIGN_WEIGHT :: 0.5
COH_WEIGHT :: 0.1

SEPARATION_RADIUS :: 25.0
ALIGNMENT_RADIUS :: 50.0
COHESION_RADIUS :: 50.0

Textures :: managers.Textures
Game :: managers.Game

main :: proc() {
    rl.InitWindow(WIDTH, HEIGHT, "Boids Simulation")
    rl.SetTargetFPS(60)

    textures := managers.load_textures()
    game := managers.load_game()

    screens.init_planet_screen()

    // Main loop
    for !rl.WindowShouldClose() {
        update_screen(textures, &game)
    }
    
    rl.CloseWindow()
}

update_screen :: proc(textures: Textures, game: ^Game) {
    switch game.current_screen {
    case managers.GameScreen.MENU:
        // Handle menu logic
    case managers.GameScreen.MAP:
        screens.draw_map_screen(textures, game)
    case managers.GameScreen.PLANET:
        screens.draw_planet_screen(textures, game)
    case managers.GameScreen.PAUSE:
        // Handle pause logic
    case managers.GameScreen.GAME_OVER:
        // Handle game over logic
    }
}
