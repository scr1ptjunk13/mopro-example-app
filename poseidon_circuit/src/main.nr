use poseidon::poseidon2::Poseidon2;

fn main(amount: Field, owner_pubkey: Field, nonce: Field) -> pub Field {
    // Generate commitment using Poseidon2 hash
    let inputs = [amount, owner_pubkey, nonce];
    let commitment = Poseidon2::hash(inputs, 3);
    commitment
}

// Function to generate nullifier (for zkETHer)
fn generate_nullifier(owner_privkey: Field, nonce: Field) -> Field {
    let inputs = [owner_privkey, nonce];
    Poseidon2::hash(inputs, 2)
}

#[test]
fn test_commitment_generation() {
    let amount = 100000000000000000; // 0.1 ETH in wei
    let owner_pubkey = 12345;
    let nonce = 67890;
    
    let commitment = main(amount, owner_pubkey, nonce);
    
    // Commitment should be deterministic
    assert(commitment != 0);
    
    // Test same inputs produce same commitment
    let commitment2 = main(amount, owner_pubkey, nonce);
    assert(commitment == commitment2);
}

#[test]
fn test_nullifier_generation() {
    let owner_privkey = 54321;
    let nonce = 67890;
    
    let nullifier = generate_nullifier(owner_privkey, nonce);
    
    // Nullifier should be deterministic
    assert(nullifier != 0);
    
    // Test same inputs produce same nullifier
    let nullifier2 = generate_nullifier(owner_privkey, nonce);
    assert(nullifier == nullifier2);
    
    // Different private keys should produce different nullifiers
    let different_nullifier = generate_nullifier(54322, nonce);
    assert(nullifier != different_nullifier);
}
