# **zkETHer Protocol Specification **

Version: 1.0.1  
Author**:** Yash Sharma

Date**:** 2025-09-04

### **Abstract**

The zkETHer protocol is a decentralized application on the Ethereum blockchain that enables private peer-to-peer transfers of ETH. It leverages a smart contract as a privacy pool and uses Zero-Knowledge Succinct Non-Interactive Arguments of Knowledge (zk-SNARKs) to break the on-chain link between the depositor and the withdrawer. This specification outlines the protocol's architecture, core components, and the operational flow required to achieve transactional privacy. The circuits are specified using the Noir programming language for safety and developer productivity, with Poseidon as the chosen SNARK-friendly hash function.

## **1\. Architectural Overview**

The protocol is composed of three primary components that interact to facilitate a private transfer: the On-Chain Smart Contract, the Off-Chain User Client (Prover), and the Off-Chain Relayer.

**The operational flow is a two-stage process:**

1. **Deposit:** A user sends ETH to the zkETHer smart contract, creating a private "note" represented by a public commitment which is added to an on-chain Merkle tree. This action is public.  
2. **Withdrawal:** The recipient of the note generates a zk-SNARK proof of ownership. This proof is submitted to the smart contract via a Relayer, which breaks the link to the user's on-chain identity. The contract verifies the proof and transfers the funds to the recipient's specified address.

## **2\. Core Cryptographic Concepts**

2.1. Note  
A note is an off-chain data structure representing ownership of funds within the contract. It is kept secret by the owner.

* **amount**: The value of the note in Wei.  
* **owner\_pubkey**: The recipient's Public Spending Key (a cryptographic key, not an Ethereum address).  
* **nonce**: A large, random number (salt) to ensure commitment uniqueness.

2.2. Commitment  
A public cryptographic binding to a secret note. It is calculated off-chain and stored on-chain in the Merkle Tree.

* **commitment \= Poseidon(\[amount, owner\_pubkey, nonce\])**

2.3. Nullifier  
A unique public value derived from a secret note that is revealed upon spending to prevent double-spends.

* **nullifier \= Poseidon(\[owner\_privkey, nonce\])**

2.4. Merkle Tree of Commitments  
An on-chain data structure that stores all commitments from valid deposits. Its root is used in proofs to verify that a note exists within the pool. The tree uses Poseidon for hashing its nodes.

## 

## 

## 

## 

## 

## 

## 

## 

## 

## **3\. On-Chain Specification: zkETHer Smart Contract**

The primary smart contract that holds the ETH pool and enforces the protocol rules.

**3.1. State Variables**

* **verifier**: address \- The address of the deployed Verifier contract.  
* **merkleTree**: MerkleTree \- The data structure storing note commitments. It will expose the current merkleRoot.  
* **nullifierSet**: mapping(bytes32 \=\> bool) \- A mapping to track spent nullifiers.

**3.2. Events**

* **Deposit(bytes32 commitment, uint32 leafIndex)**: Emitted when a new note is successfully deposited.  
* **Withdrawal(address recipient, bytes32 nullifier)**: Emitted when funds are successfully withdrawn.

**3.3. Functions**

**deposit(bytes32 \_commitment)**

* **Visibility:** public payable  
* **Purpose:** To add funds to the pool and associate them with a new private note.  
* **Logic:**  
  1. require(msg.value \> 0, "Deposit value must be positive.")  
  2. The contract calculates the next available leaf index in its Merkle tree.  
  3. It inserts the \_commitment into the tree: merkleTree.insert(\_commitment).  
  4. It emits the Deposit(\_commitment, newLeafIndex) event.

**withdraw(Proof \_proof, bytes32 \_merkleRoot, bytes32 \_nullifier, address \_recipient)**

* **Visibility:** public  
* **Purpose:** To atomically verify a proof, prevent a double-spend, and transfer funds.  
* **Logic (in strict order):**  
  1. **Check current Merkle Root:** require(\_merkleRoot \== merkleTree.root(), "Merkle root is not up to date.")  
  2. **Nullifier Check:** require(\!nullifierSet\[\_nullifier\], "Note has already been spent.")  
  3. **Proof Verification:**  
     * Construct the publicInputs array: \[\_merkleRoot, \_nullifier, \_recipient\].  
     * Call the external Verifier contract: bool isValid \= verifier.verifyProof(\_proof, publicInputs).  
     * require(isValid, "Invalid zk-SNARK proof.")  
  4. **Update State (Effects):** nullifierSet\[\_nullifier\] \= true;  
  5. **Transfer Funds (Interactions):**  
     * The amount to be withdrawn is derived from the note, but since it's private, the protocol MUST operate on fixed denominations or other mechanisms agreed upon in the circuit. For this spec, we assume a fixed withdrawal amount for simplicity. Let's say 1 ETH.  
     * (bool success, ) \= \_recipient.call{value: 1 ether}("");  
     * require(success, "ETH transfer failed.")  
  6. Emit the Withdrawal(\_recipient, \_nullifier) event.

## **4\. Off-Chain Specification**

The client-side application (web, mobile, or desktop) that manages all user interactions with the protocol.

4.1. The User Client  
The client application handles distinct flows for the sender (depositor) and the recipient (withdrawer).

4.1.1. Deposit Flow (Sender)  
The following steps are performed by the sender's client to deposit funds and create a private note for a recipient.

1. **Obtain Recipient Key:** The sender obtains the recipient's owner\_pubkey through a secure off-chain communication channel (e.g., secure chat, ENS record).  
2. **Note Construction:** The client constructs the note with the amount, the recipient's owner\_pubkey, and a freshly generated random nonce.  
3. **Commitment Calculation:** The client calculates the commitment by hashing the note's components: commitment \= Poseidon(\[amount, owner\_pubkey, nonce\]).  
4. **On-Chain Transaction:** The client, using the sender's standard EOA key, sends a transaction to the deposit function of the zkETHer smart contract, passing the msg.value (the amount of ETH) and the calculated \_commitment.

4.1.2. Withdrawal Flow (Recipient/Prover)  
The following steps are performed by the recipient's client to privately withdraw funds.

* **Key Management:** The client must manage a standard Ethereum EOA key for general use and a separate, persistent zkETHer Private Spending Key.  
* **Blockchain Scanner:** The client must monitor Deposit events from the contract. For each new commitment, it performs a trial decryption using the user's Private Spending Key to identify and save incoming notes to a local, encrypted database.  
* **Proof Generation Flow:**  
  1. The user selects a note they own from their local database.  
  2. The client constructs the private inputs: amount, owner\_pubkey, owner\_privkey, nonce, and the merklePath for the note's commitment.  
  3. The client constructs the public inputs: merkleRoot, nullifier, recipient.  
  4. It calls the **WASM Prover** (compiled from the Noir circuit) with these inputs.  
  5. The WASM module returns a proof object.  
  6. The client sends the proof and public inputs to a Relayer

4.2. The Relayer  
A service that submits withdrawal transactions on behalf of users to preserve their anonymity.

* **API Endpoint:** POST /withdraw  
* **Request Body (JSON):**  
  {  
    "proof": "...",  
    "merkleRoot": "0x...",  
    "nullifier": "0x...",  
    "recipient": "0x..."  
  }

* **Logic:**  
  1. Receive the request.  
  2. Perform basic validation on the data format.  
  3. Construct and sign a transaction calling the zkETHer.withdraw() function with the provided data.  
  4. Broadcast the transaction to the Ethereum network.  
  5. Return the transaction hash to the user.

## **5\. Zero-Knowledge Circuit Specification (Noir)**

The logic that the zk-SNARK proves. Written in Noir for safety and clarity.

**5.1. Language and Hashing**

* **Language:** Noir  
* **SNARK-Friendly Hash:** poseidon\_bn254 from the Noir standard library.

**5.2. Circuit Inputs**

* **Private Inputs (witness):**  
  * note\_amount: Field  
  * note\_owner\_pubkey: Field  
  * note\_owner\_privkey: Field  
  * note\_nonce: Field  
  * merkle\_path: array\[Field\] \- The path proving the commitment's inclusion.  
  * merkle\_path\_indices: array\[Field\] \- The indices for the path verification.  
* **Public Inputs:**  
  * merkle\_root: Field  
  * nullifier: Field  
  * recipient: Field

5.3. Circuit Logic (Constraints)  
The circuit MUST enforce the following constraints:

1. **Commitment Calculation:**  
   * Re-calculate the commitment inside the circuit using the private inputs: computed\_commitment \= poseidon(\[note\_amount, note\_owner\_pubkey, note\_nonce\]).  
2. **Nullifier Calculation:**  
   * Re-calculate the nullifier inside the circuit: computed\_nullifier \= poseidon(\[note\_owner\_privkey, note\_nonce\]).  
   * Constrain that this matches the public input: constrain computed\_nullifier \== nullifier;.  
3. **Merkle Path Verification:**  
   * Use a standard library function to verify that the computed\_commitment is a leaf in a Merkle tree that results in the public merkle\_root, using the private merkle\_path and merkle\_path\_indices.  
4. **Ownership Verification:**  
   * The circuit must verify that note\_owner\_pubkey is correctly derived from note\_owner\_privkey. This prevents a user from creating a proof for a note they don't own.

## **6\. Security Considerations**

* **Trusted Setup:** The Groth16 proving system, a likely backend for Noir, requires a trusted setup ceremony. The security of the entire protocol depends on the integrity of this ceremony and the destruction of its toxic waste.  
* **Smart Contract Security:** The contract holds all funds and is a primary target. It must be professionally audited.  
* **Relayer Centralization:** Users are reliant on relayers. A malicious relayer could censor transactions. A diversity of relayers is crucial for the health of the protocol.  
* **Transaction Graph Analysis:** While the protocol breaks the cryptographic link, observers can still perform statistical analysis on deposit/withdrawal amounts and timing to de-anonymize users. Using standard, fixed denominations is highly recommended to mitigate this.