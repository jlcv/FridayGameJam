
package models

import rl "vendor:raylib"

Boid :: struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    acceleration: rl.Vector2,
}
