use macroquad::prelude::*;

use macroquad_tiled as tiled;

#[macroquad::main("Timejumper")]
async fn main() {
    loop {
        clear_background(BLACK);
        next_frame().await;
    }
}
