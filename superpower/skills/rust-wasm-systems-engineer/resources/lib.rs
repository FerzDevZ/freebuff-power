use wasm_bindgen::prelude::*;

#[wasm_bindgen]
pub fn calculate_hash(input: &str) -> String {
    format!("hash_{}", input.len())
}
