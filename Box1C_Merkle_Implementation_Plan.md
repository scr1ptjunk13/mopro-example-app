# Box 1C: zkETHer Merkle Tree Implementation Plan

## Overview

Box 1C is **perfectly aligned** with zkETHer protocol requirements. The Merkle tree inclusion proof is the core privacy mechanism that allows users to prove note ownership without revealing which specific note they own. This implementation will create the foundation for private ETH transfers.

## Objectives

- Build production-ready Noir circuit for Merkle inclusion proofs
- Optimize for mobile performance with mopro integration
- Test multiple tree depths for privacy vs performance tradeoffs
- Create reusable circuit component for full zkETHer protocol

## Implementation Strategy

### Phase 1: Core Circuit Development (Days 1-2)

#### 1.1 Create Base Merkle Circuit Structure
```
merkle_circuit/
├── src/
│   ├── main.nr              # Main circuit entry point
│   ├── merkle_proof.nr      # Core Merkle verification logic
│   └── poseidon_utils.nr    # Poseidon hash utilities
├── Nargo.toml               # Circuit configuration
└── test_vectors/            # Test data for verification
```

#### 1.2 Circuit Requirements (from zkETHer spec)
- **Private Inputs:**
  - `commitment`: Field (the leaf we're proving)
  - `merkle_path`: [Field; DEPTH] (sibling hashes along path)
  - `merkle_path_indices`: [Field; DEPTH] (left/right indicators)
- **Public Inputs:**
  - `merkle_root`: Field (current tree root)
- **Constraints:**
  - Verify path leads from commitment to root using Poseidon

#### 1.3 Configurable Tree Depth
- Generic implementation supporting depths 16, 20, 24
- Compile-time depth selection for optimal performance
- Separate circuits for each depth to minimize constraints

### Phase 2: Multi-Depth Testing (Days 2-3)

#### 2.1 Create Test Circuits
```
merkle_circuit_d16/    # Depth 16 (65K leaves)
merkle_circuit_d20/    # Depth 20 (1M leaves) 
merkle_circuit_d24/    # Depth 24 (16M leaves)
```

#### 2.2 Test Vector Generation
- Generate realistic test trees with random commitments
- Create valid and invalid proof test cases
- Benchmark constraint counts for each depth

#### 2.3 Performance Metrics
| Metric | Depth 16 | Depth 20 | Depth 24 |
|--------|----------|----------|----------|
| Constraints | ~9,600 | ~12,000 | ~14,400 |
| Proof Size | 512 bytes | 640 bytes | 768 bytes |
| Target Mobile Time | 2-3s | 4-6s | 8-12s |

### Phase 3: Mobile Optimization (Days 3-4)

#### 3.1 mopro Integration
- Compile circuits to WASM for mobile proving
- Test on actual mobile devices (iOS/Android)
- Measure real-world proving times and memory usage

#### 3.2 Circuit Optimizations
- Use `poseidon2` for faster hashing if available
- Minimize field operations in path verification
- Optimize witness generation for mobile constraints

#### 3.3 Performance Benchmarking
```rust
// Benchmark structure
struct MerkleProofBenchmark {
    depth: u8,
    proving_time_ms: u64,
    memory_usage_mb: u32,
    proof_size_bytes: usize,
    verification_time_ms: u64,
}
```

### Phase 4: Integration Preparation (Day 5)

#### 4.1 zkETHer Protocol Integration
- Ensure circuit matches exact zkETHer specification
- Test with realistic commitment values
- Verify compatibility with smart contract expectations

#### 4.2 Documentation and Testing
- Complete test coverage for all edge cases
- Performance documentation for mobile deployment
- Integration guide for full zkETHer implementation

## Technical Specifications

### Circuit Architecture

```noir
// Main circuit structure
fn main(
    // Private inputs
    commitment: Field,
    merkle_path: [Field; DEPTH],
    merkle_path_indices: [Field; DEPTH],
    
    // Public inputs  
    merkle_root: pub Field
) {
    // Verify Merkle inclusion proof
    let computed_root = verify_merkle_path(
        commitment, 
        merkle_path, 
        merkle_path_indices
    );
    
    // Constrain computed root equals public root
    assert(computed_root == merkle_root);
}
```

### Poseidon Hash Integration

```noir
use dep::std::hash::poseidon2;

fn hash_pair(left: Field, right: Field) -> Field {
    poseidon2::Poseidon2::hash([left, right], 2)
}
```

### Mobile Performance Targets

| Device Class | Depth 16 | Depth 20 | Depth 24 |
|--------------|----------|----------|----------|
| High-end (iPhone 14+) | <2s | <4s | <8s |
| Mid-range (iPhone 12) | <3s | <6s | <12s |
| Budget Android | <5s | <10s | <20s |

## Success Metrics

### Technical Metrics
- [ ] Circuit compiles without errors for all depths
- [ ] All test vectors pass verification
- [ ] Constraint counts within expected ranges
- [ ] Mobile proving times meet performance targets

### Integration Metrics
- [ ] Circuit matches zkETHer protocol specification exactly
- [ ] Proof format compatible with smart contract verifier
- [ ] mopro integration works on iOS and Android
- [ ] Memory usage stays under mobile constraints

### Performance Metrics
- [ ] Depth 16: <3 second mobile proving
- [ ] Depth 20: <6 second mobile proving  
- [ ] Depth 24: <12 second mobile proving
- [ ] Memory usage <50MB during proving

## Implementation Timeline

### Day 1: Foundation
- [ ] Create circuit directory structure
- [ ] Implement basic Merkle verification logic
- [ ] Add Poseidon hash integration
- [ ] Create initial test cases

### Day 2: Multi-Depth Support
- [ ] Create configurable depth circuits
- [ ] Generate comprehensive test vectors
- [ ] Benchmark constraint counts
- [ ] Verify proof correctness

### Day 3: Mobile Testing
- [ ] Compile circuits for mopro
- [ ] Test on mobile devices
- [ ] Measure real-world performance
- [ ] Identify optimization opportunities

### Day 4: Optimization
- [ ] Implement circuit optimizations
- [ ] Fine-tune mobile performance
- [ ] Create performance documentation
- [ ] Validate against zkETHer requirements

### Day 5: Integration Ready
- [ ] Final testing and validation
- [ ] Complete documentation
- [ ] Performance benchmarking report
- [ ] Integration guide for zkETHer

## File Structure

```
merkle_circuit/
├── README.md                    # Implementation overview
├── circuits/
│   ├── merkle_d16/             # Depth 16 circuit
│   ├── merkle_d20/             # Depth 20 circuit  
│   └── merkle_d24/             # Depth 24 circuit
├── test_vectors/
│   ├── valid_proofs.json       # Valid test cases
│   ├── invalid_proofs.json     # Invalid test cases
│   └── generate_vectors.py     # Test vector generator
├── benchmarks/
│   ├── constraint_counts.md    # Circuit complexity analysis
│   ├── mobile_performance.md   # Mobile benchmarking results
│   └── benchmark_runner.rs     # Automated benchmarking
└── docs/
    ├── circuit_specification.md # Technical specification
    ├── integration_guide.md     # zkETHer integration guide
    └── mobile_optimization.md   # Mobile performance guide
```

## Next Steps

1. **Start with Depth 16**: Build the simplest version first for rapid iteration
2. **Focus on Correctness**: Ensure perfect compliance with zkETHer specification
3. **Mobile-First Testing**: Test on actual devices early and often
4. **Performance Documentation**: Track all metrics for optimization decisions
5. **Integration Planning**: Keep full zkETHer protocol integration in mind

This implementation will create the **privacy engine** for zkETHer - the core component that enables anonymous ETH transfers by proving note ownership without revealing which note. The mobile optimization ensures this privacy comes with excellent UX.
