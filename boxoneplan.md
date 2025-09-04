# box 1a: mopro basics (day 1-2)

## what you'll learn
- mopro installation and setup ✓ (done)
- basic noir circuit compilation
- hello world proof generation on mobile
- wasm integration fundamentals

## hands-on tasks

### task 1: create simple noir circuit (addition proof)

```sh
# create noir project
mkdir ~/addition-circuit
cd ~/addition-circuit
nargo init
```

edit `src/main.nr`:
```noir
fn main(a: Field, b: Field) -> pub Field {
    a + b
}
```

compile circuit:
```sh
nargo compile
```

### task 2: integrate with mopro

copy compiled artifacts to your mopro project:
```sh
cp target/addition.json ~/my-zk-project/mopro-example-app/test-vectors/noir/
cp target/addition.srs ~/my-zk-project/mopro-example-app/test-vectors/noir/
cp target/addition.vk ~/my-zk-project/mopro-example-app/test-vectors/noir/
```

### task 3: add test for addition circuit

edit `src/lib.rs`, add after existing tests:
```rust
#[test]
#[serial]
fn test_addition_circuit() {
    let srs_path = "./test-vectors/noir/addition.srs".to_string();
    let circuit_path = "./test-vectors/noir/addition.json".to_string();
    let circuit_inputs = vec!["10".to_string(), "5".to_string()];
    
    let vk = get_noir_verification_key(
        circuit_path.clone(),
        Some(srs_path.clone()),
        true,
        false,
    ).unwrap();

    let proof = generate_noir_proof(
        circuit_path.clone(),
        Some(srs_path),
        circuit_inputs,
        true,
        vk.clone(),
        false,
    ).unwrap();

    let valid = verify_noir_proof(
        circuit_path,
        proof,
        true,
        vk,
        false,
    ).unwrap();
    assert!(valid);
}
```

### task 4: test your circuit

```sh
cargo test test_addition_circuit
```

### task 5: build for mobile

```sh
mopro build
# choose: debug
# choose: android
# choose: aarch64-linux-android
```

### task 6: create react native template

```sh
mopro create
# choose: react-native
```

### task 7: test on mobile

```sh
cd react-native
npm install
npx react-native run-android
```

## success metrics
- [ ] noir addition circuit compiles successfully
- [ ] rust test passes for addition proof
- [ ] mobile bindings generate without errors
- [ ] react native app runs on android device
- [ ] can generate addition proof (10 + 5 = 15) on mobile

## troubleshooting

if nargo not found:
```sh
curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
noirup
```

if react native fails:
```sh
# make sure android device is connected
adb devices
# or use emulator
```

## next steps
after completing box 1a, you'll be ready for:
- box 1b: advanced circuits (merkle trees, signatures)
- box 2a: mobile ui/ux for zk apps
- box 3a: real-world zk applications
