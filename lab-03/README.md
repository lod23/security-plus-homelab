# Lab 2.1 — Cryptographic Techniques and Verification

## Environment
Nested Ubuntu VM (XLAB-UBUNTU1) on a Hyper-V Windows host (MAD-HOST).
OpenSSL 3.0.2.

## Exercise 1 — Digital signatures
1. Alice generates an RSA keypair
2. Alice creates a digest file, signs it with her private key
3. Public key + signature + digest are sent to Bob
4. Bob verifies with Alice's public key → Verified OK
5. Digest is modified → Verification failure

## How signing actually works
Signing hashes the file (SHA-256), then encrypts that hash with the
private key. Verifying decrypts the signature with the public key to
recover the hash, independently hashes the file, and compares. Any
change to the file changes its hash, so the comparison fails.

The digest went from 24 bytes to 32 bytes when tampered — that size
change is literally why verification broke.

## Exercise 2 — CSR and CA
1. SecPlusLLC generates a keypair and a CSR
2. CA generates its own key
3. CA issues a certificate

A CSR carries the public key plus identity fields (C, ST, L, O, OU,
CN, email). It never contains the private key, which is why it's safe
to send to a CA.

## Something the lab gets wrong
The lab uses `openssl req -new -x509` for the CA step. That produces a
SELF-SIGNED certificate for the CA itself — subject and issuer are both
CertAuth. It never signs SecPlusLLC's CSR. The file is named
SecPlusLLC.crt and copied to SecPlusLLC's folder as if it were issued
to them, but it isn't.

Real issuance would be:
    openssl x509 -req -in SecPlusLLC.csr -CA ca.crt -CAkey CA_privatekey.pem \
      -CAcreateserial -out SecPlusLLC.crt -days 365

That gives subject=SecPlusLLC, issuer=CertAuth — an actual chain.

## File permissions
Private keys came out as -rw------- while public keys and certs were
-rw-rw-r--. OpenSSL restricts private keys to owner-only by default.

## Rebuild
scripts/rebuild-lab-03.sh runs the whole thing natively on macOS —
no VM needed, since openssl ships with the OS.
