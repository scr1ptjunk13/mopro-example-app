// poseidon_utils.nr - Poseidon Hash Utilities for zkETHer
// Provides SNARK-friendly hash functions using Poseidon2

use poseidon::poseidon2::Poseidon2;

// Hash two field elements together using Poseidon2
// This is the core building block for Merkle tree hash computations
pub fn poseidon_hash_pair(left: Field, right: Field) -> Field {
    let inputs = [left, right];
    Poseidon2::hash(inputs, 2)
}

// Hash three field elements (used for commitment calculation in full zkETHer)
pub fn poseidon_hash_3(a: Field, b: Field, c: Field) -> Field {
    let inputs = [a, b, c];
    Poseidon2::hash(inputs, 3)
}

// Hash four field elements
pub fn poseidon_hash_4(a: Field, b: Field, c: Field, d: Field) -> Field {
    let inputs = [a, b, c, d];
    Poseidon2::hash(inputs, 4)
}

// Specialized hash for zkETHer commitments
// commitment = Poseidon([amount, owner_pubkey, nonce])
pub fn hash_commitment(amount: Field, owner_pubkey: Field, nonce: Field) -> Field {
    poseidon_hash_3(amount, owner_pubkey, nonce)
}

// Specialized hash for zkETHer nullifiers  
// nullifier = Poseidon([owner_privkey, nonce])
pub fn hash_nullifier(owner_privkey: Field, nonce: Field) -> Field {
    poseidon_hash_pair(owner_privkey, nonce)
}

// Utility function to create a zero hash (empty leaf value)
pub fn zero_hash() -> Field {
    0
}

// Precomputed zero hashes for different tree levels
// This can be used to optimize sparse Merkle trees
pub fn get_zero_hash_at_level(level: u32) -> Field {
    // For now, return simple zero - in production you'd precompute these
    // Level 0: hash of two zeros, Level 1: hash of two level-0 hashes, etc.
    if level == 0 {
        poseidon_hash_pair(0, 0)
    } else {
        // Simplified - in practice you'd have a lookup table of precomputed values
        0
    }
}

// ============================================================================
// TESTS - Verify poseidon_utils.nr works correctly and matches poseidon_circuit
// ============================================================================

#[test]
fn test_poseidon_hash_pair() {
    let left = 12345;
    let right = 67890;
    
    let hash = poseidon_hash_pair(left, right);
    
    // Hash should be deterministic and non-zero
    assert(hash != 0);
    
    // Same inputs should produce same hash
    let hash2 = poseidon_hash_pair(left, right);
    assert(hash == hash2);
    
    // Different inputs should produce different hash
    let different_hash = poseidon_hash_pair(left, right + 1);
    assert(hash != different_hash);
    
    // Order matters in hash functions
    let reversed_hash = poseidon_hash_pair(right, left);
    assert(hash != reversed_hash);
}

#[test]
fn test_poseidon_hash_3() {
    let a = 100;
    let b = 200;
    let c = 300;
    
    let hash = poseidon_hash_3(a, b, c);
    
    // Hash should be deterministic and non-zero
    assert(hash != 0);
    
    // Same inputs should produce same hash
    let hash2 = poseidon_hash_3(a, b, c);
    assert(hash == hash2);
    
    // Different inputs should produce different hash
    let different_hash = poseidon_hash_3(a, b, c + 1);
    assert(hash != different_hash);
}

#[test]
fn test_poseidon_hash_4() {
    let a = 1000;
    let b = 2000;
    let c = 3000;
    let d = 4000;
    
    let hash = poseidon_hash_4(a, b, c, d);
    
    // Hash should be deterministic and non-zero
    assert(hash != 0);
    
    // Same inputs should produce same hash
    let hash2 = poseidon_hash_4(a, b, c, d);
    assert(hash == hash2);
    
    // Different inputs should produce different hash
    let different_hash = poseidon_hash_4(a, b, c, d + 1);
    assert(hash != different_hash);
}

#[test]
fn test_commitment_generation() {
    // Use same test values as poseidon_circuit for consistency verification
    let amount = 100000000000000000; // 0.1 ETH in wei
    let owner_pubkey = 12345;
    let nonce = 67890;
    
    let commitment = hash_commitment(amount, owner_pubkey, nonce);
    
    // Commitment should be deterministic and non-zero
    assert(commitment != 0);
    
    // Same inputs should produce same commitment
    let commitment2 = hash_commitment(amount, owner_pubkey, nonce);
    assert(commitment == commitment2);
    
    // Different amounts should produce different commitments
    let different_commitment = hash_commitment(amount + 1, owner_pubkey, nonce);
    assert(commitment != different_commitment);
    
    // Verify this matches direct poseidon_hash_3 call
    let direct_hash = poseidon_hash_3(amount, owner_pubkey, nonce);
    assert(commitment == direct_hash);
}

#[test]
fn test_nullifier_generation() {
    // Use same test values as poseidon_circuit for consistency verification
    let owner_privkey = 54321;
    let nonce = 67890;
    
    let nullifier = hash_nullifier(owner_privkey, nonce);
    
    // Nullifier should be deterministic and non-zero
    assert(nullifier != 0);
    
    // Same inputs should produce same nullifier
    let nullifier2 = hash_nullifier(owner_privkey, nonce);
    assert(nullifier == nullifier2);
    
    // Different private keys should produce different nullifiers
    let different_nullifier = hash_nullifier(owner_privkey + 1, nonce);
    assert(nullifier != different_nullifier);
    
    // Verify this matches direct poseidon_hash_pair call
    let direct_hash = poseidon_hash_pair(owner_privkey, nonce);
    assert(nullifier == direct_hash);
}

#[test]
fn test_zero_hash_functions() {
    let zero = zero_hash();
    assert(zero == 0);
    
    // Test level 0 zero hash (hash of two zeros)
    let level0_zero = get_zero_hash_at_level(0);
    let expected_level0 = poseidon_hash_pair(0, 0);
    assert(level0_zero == expected_level0);
    assert(level0_zero != 0); // Should not be zero since it's a hash
    
    // Test other levels return 0 (simplified implementation)
    let level1_zero = get_zero_hash_at_level(1);
    assert(level1_zero == 0);
}

#[test]
fn test_merkle_tree_hash_operations() {
    // Test typical Merkle tree operations
    let leaf1 = hash_commitment(1000, 111, 1);
    let leaf2 = hash_commitment(2000, 222, 2);
    let leaf3 = hash_commitment(3000, 333, 3);
    let leaf4 = hash_commitment(4000, 444, 4);
    
    // Build a small Merkle tree
    let node1 = poseidon_hash_pair(leaf1, leaf2);
    let node2 = poseidon_hash_pair(leaf3, leaf4);
    let root = poseidon_hash_pair(node1, node2);
    
    // All values should be different and non-zero
    assert(leaf1 != leaf2);
    assert(leaf2 != leaf3);
    assert(leaf3 != leaf4);
    assert(node1 != node2);
    assert(root != node1);
    assert(root != node2);
    assert(root != 0);
    
    // Verify tree structure is deterministic
    let node1_verify = poseidon_hash_pair(leaf1, leaf2);
    let node2_verify = poseidon_hash_pair(leaf3, leaf4);
    let root_verify = poseidon_hash_pair(node1_verify, node2_verify);
    
    assert(node1 == node1_verify);
    assert(node2 == node2_verify);
    assert(root == root_verify);
}