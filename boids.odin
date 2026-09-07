package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

NUM_BOIDS :: 300
BOID_SIZE :: 10.0

// Window dimensions
WIDTH :: 2560
HEIGHT :: 1600

// Boid parameters
MAX_SPEED :: 6.5
SEP_WEIGHT :: 0.5
ALIGN_WEIGHT :: 0.5
COH_WEIGHT :: 0.1

SEPARATION_RADIUS :: 25.0
ALIGNMENT_RADIUS :: 50.0
COHESION_RADIUS :: 50.0


Boid :: struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    acceleration: rl.Vector2,
}

main :: proc() {
    rl.InitWindow(WIDTH, HEIGHT, "Boids Simulation")
    rl.SetTargetFPS(60)
    
    flock_a := init_boids()
    flock_a_downed : [dynamic]Boid
    flock_b := init_boids()

    background_texture := rl.LoadTexture("assets/stars2.png")
    boid_texture_a := rl.LoadTexture("assets/plane.png")
    boid_texture_b := rl.LoadTexture("assets/plane2.png")
    explosion_texture := rl.LoadTexture("assets/explosion.png")
    planet_texture := rl.LoadTexture("assets/planet.png")

    // Main loop
    for !rl.WindowShouldClose() {
        fps := rl.GetFPS()
        lifebar_a := get_lifebar(flock_a)
        lifebar_b := get_lifebar(flock_b)
        update_boids(flock_a)
        update_boids(flock_b)
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        rl.DrawTexturePro(background_texture, rl.Rectangle{0, 0, f32(background_texture.width), f32(background_texture.height)}, rl.Rectangle{0, 0, WIDTH, HEIGHT}, rl.Vector2{0, 0}, 0.0, rl.WHITE)
        rl.DrawText(fmt.ctprint("fps:", fps), 10, 10, 20, rl.MAGENTA)
        rl.DrawText(lifebar_a, 10, 80, 30, rl.BLUE);
        rl.DrawText(lifebar_b, 10, 120, 30, rl.RED);
        rl.DrawText("BLUE_049 DOWN", 10, 1300, 30, rl.BLUE);
        rl.DrawText("BLUE_297 DOWN", 10, 1330, 30, rl.BLUE);
        rl.DrawText("RED_124 DOWN", 10, 1360, 30, rl.RED);
        rl.DrawText("RED_263 DOWN", 10, 1390, 30, rl.RED);
        rl.DrawText("BLUE_108 DOWN", 10, 1420, 30, rl.BLUE);
        draw_boids(flock_a, boid_texture_a, explosion_texture, rl.GREEN)
        rl.DrawTexture(planet_texture, 1200, 700, rl.WHITE)
        draw_boids(flock_b, boid_texture_b, explosion_texture, rl.YELLOW)

        rl.EndDrawing()

        if (len(flock_a) > 0) {
            unordered_remove(&flock_a, 0)
        }
    }
    
    rl.CloseWindow()
}

init_boids :: proc() -> [dynamic]Boid {
    boids : [dynamic]Boid
    
    // Initialize boids with random positions and velocities
    for i in 0..<NUM_BOIDS {
        append(
            &boids,
            Boid {
                position = rl.Vector2{f32(rl.GetRandomValue(0, WIDTH)), f32(rl.GetRandomValue(0, HEIGHT))},
                velocity = rl.Vector2{f32(rl.GetRandomValue(-1, 1)), f32(rl.GetRandomValue(-1, 1))},
                acceleration = rl.Vector2{0, 0},
            }
        )
    }
    
    return boids
}

get_lifebar :: proc(boids: [dynamic]Boid) -> cstring {
    lifebar := rl.TextFormat("Score: %d", len(boids))
    return lifebar
}

separation :: proc(boids: [dynamic]Boid, boid: Boid) -> rl.Vector2 {
    perception_radius: f32 = SEPARATION_RADIUS

    steer := rl.Vector2{0, 0}
    
    //  Count how many boids are in the perception radius
    total := 0
    for other in boids {
        if other != boid {
            distance := rl.Vector2Distance(boid.position, other.position)
            if distance < perception_radius && distance > 0 {
                diff := boid.position - other.position
                
                weight := (perception_radius - distance) / perception_radius
                weight *= weight
                
                diff = rl.Vector2Normalize(diff) * weight
                steer += diff
                total += 1
            }
        }
        
        // Average the steering vector
        if total > 0 {
            steer = steer * (1/f32(total))
            steer = rl.Vector2Normalize(steer)
            steer = steer * 0.8
        }
        
    }
    return steer
}

alignment :: proc(boids: [dynamic]Boid, boid: Boid) -> rl.Vector2 {
    perception_radius: f32 = ALIGNMENT_RADIUS
    avg_velocity := rl.Vector2{0, 0}

    // Count how many boids are in the perception radius
    total := 0
    for other in boids {
        if other != boid {
            distance := rl.Vector2Distance(boid.position, other.position)
            if distance < perception_radius {
                avg_velocity = avg_velocity + other.velocity
                total += 1
            }
        }
    }
    
    // Average the velocity vector
    if total > 0 {
        avg_velocity = avg_velocity * (1/f32(total))
        avg_velocity -= boid.velocity
        avg_velocity = rl.Vector2Normalize(avg_velocity) * 0.3
    }
    
    return avg_velocity
}

cohesion :: proc(boids: [dynamic]Boid, boid: Boid) -> rl.Vector2 {
    perception_radius: f32 = COHESION_RADIUS
    
    // Center of the boids in the perception radius
    center := rl.Vector2{0, 0}
    avg_distance: f32 = 0.0

    // Count how many boids are in the perception radius
    total := 0
    for other in boids {
        if other != boid {
            distance := rl.Vector2Distance(boid.position, other.position)
            if distance < perception_radius {
                center += other.position
                avg_distance += distance
                total += 1
            }
        }
    }
    
    // Average the center vector
    if total > 0 {
        center = center * (1/f32(total))
        avg_distance = avg_distance / f32(total)
        steer := center - boid.position

        weight := 0.02 + (0.1 * (avg_distance / perception_radius))
        steer = rl.Vector2Normalize(steer) * weight
        
        return steer
    }
    
    return center 
}

draw_boids :: proc(boids: [dynamic]Boid, texture: rl.Texture2D, explosion_texture: rl.Texture2D, laser_color: rl.Color) {
    size: f32 = BOID_SIZE

    for boid, idx in boids {
        vel_normalized := rl.Vector2Normalize(boid.velocity)
        
        // Calculate the angle of the velocity vector
        angle := math.atan2(vel_normalized.y, vel_normalized.x)

        // Draw the boid as a triangle pointing in the direction of the velocity
        front := rl.Vector2{
            boid.position.x + vel_normalized.x * size * 2, 
            boid.position.y + vel_normalized.y * size * 2
        }

        laser_front := rl.Vector2{
            boid.position.x + vel_normalized.x * size * 2000, 
            boid.position.y + vel_normalized.y * size * 2000
        }

        left := rl.Vector2{
            boid.position.x + math.cos(math.atan2(vel_normalized.y, vel_normalized.x) + 2.5) * size, 
            boid.position.y + math.sin(math.atan2(vel_normalized.y, vel_normalized.x) + 2.5) * size
        }

        right := rl.Vector2{
            boid.position.x + math.cos(math.atan2(vel_normalized.y, vel_normalized.x) - 2.5) * size, 
            boid.position.y + math.sin(math.atan2(vel_normalized.y, vel_normalized.x) - 2.5) * size
        }

        rl.DrawTexturePro(texture, rl.Rectangle{0, 0, f32(texture.width), f32(texture.height)}, rl.Rectangle{boid.position.x - size, boid.position.y - size, size * 2, size * 2}, rl.Vector2{size, size}, angle * (180 / math.PI), rl.WHITE)
        
        if (rl.GetRandomValue(0, 999) == 1) {
            rl.DrawLineEx(front, laser_front, 1.0, laser_color)
        }

        if (rl.GetRandomValue(0, 199) == 2) {
            rl.DrawTexturePro(explosion_texture, rl.Rectangle{0, 0, f32(explosion_texture.width), f32(explosion_texture.height)}, rl.Rectangle{boid.position.x - size, boid.position.y - size, size * 2, size * 2}, rl.Vector2{size, size}, angle * (180 / math.PI), rl.WHITE)
        }

        // rl.DrawTriangleLines(front, left, right, rl.LIGHTGRAY)
    }
}

update_boids :: proc(boids: [dynamic]Boid) {
    for i in 0..<len(boids) {
        boid := &boids[i]
        
        // Calculate the steering forces
        sep := separation(boids, boid^)
        align := alignment(boids, boid^)
        coh := cohesion(boids, boid^)
        
        // Update the boid's acceleration, velocity, and position
        boid.acceleration = (boid.acceleration * 0.7) + (sep * SEP_WEIGHT + align * ALIGN_WEIGHT + coh * COH_WEIGHT) * 0.3
        boid.velocity += boid.acceleration
        
        limit_speed(boid, MAX_SPEED)
        
        boid.position += boid.velocity
        
        // Wrap around the screen
        if boid.position.x < -10 {
            boid.position.x = WIDTH + 10
        } else if boid.position.x > WIDTH + 10 {
            boid.position.x = -10
        }

        if boid.position.y < -10 {
            boid.position.y = HEIGHT + 10
        } else if boid.position.y > HEIGHT + 10 {
            boid.position.y = -10
        }

        // Apply friction/drag
        boid.acceleration = boid.acceleration * 0.8
    }
}

limit_speed :: proc(boid: ^Boid, max_speed: f32) {
    speed := math.sqrt(boid.velocity.x * boid.velocity.x + boid.velocity.y * boid.velocity.y)
    
    if speed > max_speed {
        scale := max_speed / speed
        boid.velocity.x *= scale
        boid.velocity.y *= scale
    }
}