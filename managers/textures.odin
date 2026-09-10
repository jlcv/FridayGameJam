package managers

import rl "vendor:raylib"

Textures :: struct {
    background_texture : rl.Texture2D,
    boid_texture_a : rl.Texture2D,
    boid_texture_b : rl.Texture2D,
    explosion_texture : rl.Texture2D,
    planet_texture : rl.Texture2D
}

load_textures :: proc() -> Textures {
    return Textures {
        background_texture = rl.LoadTexture("assets/stars2.png"),
        boid_texture_a = rl.LoadTexture("assets/plane.png"),
        boid_texture_b = rl.LoadTexture("assets/plane2.png"),
        explosion_texture = rl.LoadTexture("assets/explosion.png"),
        planet_texture = rl.LoadTexture("assets/planet.png")
    }
}
