
package screens

import "core:fmt"
import "core:math"
import rl "vendor:raylib"
import "../models"
import "../managers"
import "../screens"

draw_map_screen :: proc(textures: Textures, game: ^Game) {

    rl.BeginDrawing()

    rl.ClearBackground(rl.BLACK)

    // Define button bounds
    btn_bounds := rl.Rectangle{350, 200, 100, 40}

    // Raygui functions are inside the same 'rl' package prefix
    if rl.GuiButton(btn_bounds, "Click Me") {
        game.current_screen = managers.GameScreen.PLANET
    }

    rl.EndDrawing()

}