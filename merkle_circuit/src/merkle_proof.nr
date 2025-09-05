// merkle_proof.nr - Core Merkle Tree Verification Logic
// Implements the cryptographic verification of Merkle tree inclusion proofs

use crate::poseidon_utils::poseidon_hash_pair;

// Import the global constant from main.nr (commented out as unused)
// use crate::MERKLE_DEPTH;

// Verify a Merkle inclusion proof with configurable depth
// Returns the computed root if the proof is valid
pub fn verify_merkle_path(
    leaf: Field,
    merkle_path: [Field; 16],
    merkle_path_indices: [Field; 16],
    depth: u32
) -> Field {
    let mut current_hash = leaf;
    
    // Traverse up the tree for the specified depth only
    for i in 0..16 {
        if i < depth {
            let sibling = merkle_path[i];
            let is_right = merkle_path_indices[i];
            
            // Compute parent hash based on position
            current_hash = compute_parent_hash(current_hash, sibling, is_right);
        }
    }
    
    current_hash
}

// zkETHer-specific depth variants for optimal performance
pub fn verify_merkle_path_d16(
    leaf: Field,
    merkle_path: [Field; 16],
    merkle_path_indices: [Field; 16]
) -> Field {
    verify_merkle_path(leaf, merkle_path, merkle_path_indices, 16)
}

pub fn verify_merkle_path_d20(
    leaf: Field,
    merkle_path: [Field; 20],
    merkle_path_indices: [Field; 20]
) -> Field {
    let mut current_hash = leaf;
    for i in 0..20 {
        let sibling = merkle_path[i];
        let is_right = merkle_path_indices[i];
        current_hash = compute_parent_hash(current_hash, sibling, is_right);
    }
    current_hash
}

// Compute parent hash given left and right children
// is_right: 0 means current_hash is left child, 1 means right child  
fn compute_parent_hash(current_hash: Field, sibling: Field, is_right: Field) -> Field {
    // Ensure is_right is binary (0 or 1)
    assert((is_right == 0) | (is_right == 1));
    
    // Use conditional logic to determine left and right children
    let left_child = (1 - is_right) * current_hash + is_right * sibling;
    let right_child = is_right * current_hash + (1 - is_right) * sibling;
    
    poseidon_hash_pair(left_child, right_child)
}

// Helper function to verify a path for trees with variable depth
// Note: This function is simplified - in practice you'd use compile-time constants
pub fn verify_merkle_path_variable_depth(
    leaf: Field,
    merkle_path: [Field; 16],
    merkle_path_indices: [Field; 16],
    actual_depth: u32
) -> Field {
    let mut current_hash = leaf;
    
    // Use a fixed loop with conditional processing
    for i in 0..16 {
        if i < actual_depth {
            let sibling = merkle_path[i];
            let is_right = merkle_path_indices[i];
            current_hash = compute_parent_hash(current_hash, sibling, is_right);
        }
    }
    
    current_hash
}

// Optimized version for specific common depths
pub fn verify_merkle_path_depth_16(
    leaf: Field,
    merkle_path: [Field; 16],
    merkle_path_indices: [Field; 16]
) -> Field {
    let mut current_hash = leaf;
    
    // Unrolled loop for exactly 16 levels for maximum performance
    current_hash = compute_parent_hash(current_hash, merkle_path[0], merkle_path_indices[0]);
    current_hash = compute_parent_hash(current_hash, merkle_path[1], merkle_path_indices[1]);
    current_hash = compute_parent_hash(current_hash, merkle_path[2], merkle_path_indices[2]);
    current_hash = compute_parent_hash(current_hash, merkle_path[3], merkle_path_indices[3]);
    current_hash = compute_parent_hash(current_hash, merkle_path[4], merkle_path_indices[4]);
    current_hash = compute_parent_hash(current_hash, merkle_path[5], merkle_path_indices[5]);
    current_hash = compute_parent_hash(current_hash, merkle_path[6], merkle_path_indices[6]);
    current_hash = compute_parent_hash(current_hash, merkle_path[7], merkle_path_indices[7]);
    current_hash = compute_parent_hash(current_hash, merkle_path[8], merkle_path_indices[8]);
    current_hash = compute_parent_hash(current_hash, merkle_path[9], merkle_path_indices[9]);
    current_hash = compute_parent_hash(current_hash, merkle_path[10], merkle_path_indices[10]);
    current_hash = compute_parent_hash(current_hash, merkle_path[11], merkle_path_indices[11]);
    current_hash = compute_parent_hash(current_hash, merkle_path[12], merkle_path_indices[12]);
    current_hash = compute_parent_hash(current_hash, merkle_path[13], merkle_path_indices[13]);
    current_hash = compute_parent_hash(current_hash, merkle_path[14], merkle_path_indices[14]);
    current_hash = compute_parent_hash(current_hash, merkle_path[15], merkle_path_indices[15]);
    
    current_hash
}

#[test]
fn test_compute_parent_hash() {
    // Test left child case (is_right = 0)
    let left = 1;
    let right = 2;
    let result1 = compute_parent_hash(left, right, 0);
    
    // Test right child case (is_right = 1)  
    let result2 = compute_parent_hash(right, left, 1);
    
    // Both should produce the same hash since the inputs are the same
    assert(result1 == result2);
}

#[test]
fn test_simple_merkle_path() {
    // Test a 1-level tree (just leaf + sibling = root)
    let leaf = 1;
    let sibling = 2;
    let path = [sibling, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let indices = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]; // leaf is left child
    
    // Use depth=1 for this simple test
    let root = verify_merkle_path(leaf, path, indices, 1);
    
    // Verify the computation manually
    let expected_root = poseidon_hash_pair(leaf, sibling);
    assert(root == expected_root);
}

#[test]
fn test_zkether_depth_variants() {
    // Test zkETHer-specific depth functions
    let leaf = 100;
    let sibling = 200;
    let path16 = [sibling, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let indices16 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    
    // Test depth 1 vs depth 16 - should be different
    let root_d1 = verify_merkle_path(leaf, path16, indices16, 1);
    let root_d16 = verify_merkle_path_d16(leaf, path16, indices16);
    
    // Depth 1 should just be hash of leaf + sibling
    let expected_d1 = poseidon_hash_pair(leaf, sibling);
    assert(root_d1 == expected_d1);
    
    // Depth 16 should be different (processes all 16 levels)
    assert(root_d1 != root_d16);
}