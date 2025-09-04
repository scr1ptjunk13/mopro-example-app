// Here we're calling a macro exported with Uniffi. This macro will
// write some functions and bind them to FFI type.
// These functions include:
// - `generate_circom_proof`
// - `verify_circom_proof`
// - `generate_halo2_proof`
// - `verify_halo2_proof`
// - `generate_noir_proof`
// - `verify_noir_proof`
mopro_ffi::app!();

/// You can also customize the bindings by #[uniffi::export]
/// Reference: https://mozilla.github.io/uniffi-rs/latest/proc_macro/index.html
#[uniffi::export]
fn mopro_uniffi_hello_world() -> String {
    "Hello, World!".to_string()
}

// CIRCOM_TEMPLATE

// HALO2_TEMPLATE

// --- Noir Example of using Ultra Honk proving and verifying circuits ---

// Module containing the Noir circuit logic (Multiplier2)

#[cfg(test)]
mod noir_tests {
    // Import the generated functions from the uniffi bindings
    use serial_test::serial;
    use super::*;

    #[test]
    #[serial]
    fn test_addition_circuit() {
        let circuit_path = "./test-vectors/noir/addition_circuit.json".to_string();
        let circuit_inputs = vec!["10".to_string(), "5".to_string()];
        
        let vk = get_noir_verification_key(
            circuit_path.clone(),
            None,   // no srs needed for small circuits
            true,   // on_chain (uses Keccak for Solidity compatibility)
            false,  // low_memory_mode
        ).unwrap();

        let proof = generate_noir_proof(
            circuit_path.clone(),
            None,   // no srs needed for small circuits
            circuit_inputs.clone(),
            true,   // on_chain (uses Keccak for Solidity compatibility)
            vk.clone(),
            false,  // low_memory_mode
        ).unwrap();

        let valid = verify_noir_proof(
            circuit_path,
            proof,
            true,   // on_chain (uses Keccak for Solidity compatibility)
            vk,
            false,  // low_memory_mode
        ).unwrap();
        assert!(valid);
    }
}


