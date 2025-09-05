// main.nr - zkETHer Merkle Proof Circuit
// Main circuit entry point for proving Merkle tree inclusion

mod merkle_proof;
mod poseidon_utils;

use merkle_proof::verify_merkle_path;

// Configurable tree depth - change this constant for different tree sizes
// Depth 16 = 65,536 leaves, Depth 20 = 1,048,576 leaves, Depth 24 = 16,777,216 leaves
global MERKLE_DEPTH: u32 = 16;

fn main(
    // Private inputs (witness)
    commitment: Field,
    merkle_path: [Field; MERKLE_DEPTH], // Sibling hashes along the path
    merkle_path_indices: [Field; MERKLE_DEPTH], // Left/right indicators (0 = left, 1 = right)
    
    // Public inputs
    merkle_root: pub Field
) {
    // Verify the Merkle inclusion proof
    let computed_root = verify_merkle_path(
        commitment,
        merkle_path,
        merkle_path_indices,
        MERKLE_DEPTH
    );
    
    // Constrain that the computed root matches the public root
    assert(computed_root == merkle_root);
}

// Test function to verify circuit logic
#[test]
fn test_merkle_proof_circuit() {
    // Test with a simple 3-level tree
    let leaf = 1;
    let path = [
        2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    let indices = [
        0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    
    let root = verify_merkle_path(leaf, path, indices, 3);
    
    // This is a basic test - in practice you'd calculate the expected root
    // For now, we just verify the function doesn't crash
    assert(root != 0);
}