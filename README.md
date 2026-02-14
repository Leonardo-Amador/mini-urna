# mini-urna

A small **educational** Ruby project to learn integrity and authenticity checks by simulating an e-voting **sealing** workflow:

- **BU** (toy): aggregated totals (per section)
- **RDV** (toy): vote-by-vote records (no voter identity)
- **SHA-256 hashes**: tamper detection (**integrity**)
- **Digital signature**: protects the hash reference (**authenticity**)
- **Verifier**: validates signature + hashes before trusting artifacts

> Not the real urna source code. Not affiliated with TSE. This is a learning repo.

## What you can do (Phase 1)

- Generate a **hash manifest** for BU/RDV (`data/hashes.json`)
- **Seal** (sign) that manifest (`data/hashes.sig`)
- **Verify** integrity/authenticity with a local verifier (`bin/verify.rb`)
- Run simple tamper demos to see verification failures

## Structure

```
mini_urna/
  bin/   # hash.rb, seal.rb, verify.rb
  data/  # bu.txt, rdv_final.jsonl, (generated) hashes.json, hashes.sig
  keys/  # (generated) private.pem, public.pem
```

## Requirements

- Ruby 3+
- No gems (stdlib: OpenSSL, Digest, JSON)

## Setup

1) Clone and enter the repo:
```bash
git clone <your-repo-url>
cd mini_urna
```

2) Make scripts executable (if needed):
```bash
chmod +x bin/*.rb
```

3) Make sure you have the toy artifacts:
- `data/bu.txt`
- `data/rdv_final.jsonl`

## Run (generate -> seal -> verify)

1) Generate hashes (manifest):
```bash
bin/hash.rb
cat data/hashes.json
```

2) Generate keys (local only):
```bash
mkdir -p keys
ruby -ropenssl -e '
key = OpenSSL::PKey::RSA.new(3072)
File.write("keys/private.pem", key.to_pem)
File.write("keys/public.pem", key.public_key.to_pem)
puts "OK: generated keys/private.pem and keys/public.pem"
'
```

3) Seal (sign the manifest):
```bash
bin/seal.rb
ls -lh data/hashes.sig
```

4) Verify (signature + artifact hashes):
```bash
bin/verify.rb
```

Expected output:
- `OK: signature valid and all artifact hashes match.`

## Quick tamper demos

### Demo 1 — Tamper with BU after sealing (should fail)
```bash
perl -pi -e 's/MUNICIPIO: BIRIGUI/MUNICIPIO: BIRIGUI-SP/' data/bu.txt
bin/verify.rb
```

Undo the change:
```bash
git checkout -- data/bu.txt
```

Then regenerate + reseal:
```bash
bin/hash.rb
bin/seal.rb
bin/verify.rb
```

### Demo 2 — Regenerate hashes without re-signing (should fail)
This simulates an attacker changing the manifest but not being able to re-sign it.

```bash
bin/hash.rb
bin/verify.rb
```

Expected: verification fails due to **invalid signature**.
