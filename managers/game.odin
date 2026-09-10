package managers

import rl "vendor:raylib"

GameScreen :: enum {
    MENU,
    MAP,
    PLANET,
    PAUSE,
    GAME_OVER,
}

Game :: struct {
    current_screen : GameScreen,
}

load_game :: proc() -> Game {
    return Game {
        current_screen = GameScreen.MAP,
    }
}
