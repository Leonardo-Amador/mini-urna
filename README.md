# mini-urna

A small **educational** Ruby project to learn integrity and authenticity checks by simulating an e-voting **sealing** workflow:

- **BU** (toy): aggregated totals
- **RDV** (toy): vote-by-vote records
- **SHA-256 hashes**: tamper detection (integrity)
- **Digital signature**: prevents swapping the hash reference (authenticity)
- **Verifier**: checks signature + hashes before trusting artifacts

> Not the real urna source code. Not affiliated with TSE. This is a learning repo.

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

## Run

```bash
bin/hash.rb
ruby -ropenssl -e '
key = OpenSSL::PKey::RSA.new(3072)
File.write("keys/private.pem", key.to_pem)
File.write("keys/public.pem", key.public_key.to_pem)
'
bin/seal.rb
bin/verify.rb
```

## Quick attack demos

Tamper with BU after sealing:

```bash
perl -pi -e 's/CANDIDATO_22: 95/CANDIDATO_22: 96/' data/bu.txt
bin/verify.rb
```

Regenerate hashes without re-signing:

```bash
bin/hash.rb
bin/verify.rb
```