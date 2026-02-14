#!/usr/bin/env ruby
require "json"
require "digest"
require "openssl"

HASH_FILE = "data/hashes.json"
SIG_FILE  = "data/hashes.sig"
PUB_KEY   = "keys/public.pem"

def fail!(msg)
  warn "FAIL: #{msg}"
  exit 2
end

fail!("Missing #{HASH_FILE}") unless File.exist?(HASH_FILE)
fail!("Missing #{SIG_FILE}")  unless File.exist?(SIG_FILE)
fail!("Missing #{PUB_KEY}")   unless File.exist?(PUB_KEY)

public_key = OpenSSL::PKey::RSA.new(File.read(PUB_KEY))
manifest   = File.binread(HASH_FILE)
signature  = File.binread(SIG_FILE)

digest = OpenSSL::Digest::SHA256.new
ok_sig = public_key.verify(digest, signature, manifest)
fail!("Invalid signature for hashes.json (manifest is not trustworthy).") unless ok_sig

payload = JSON.parse(File.read(HASH_FILE))
algo = payload["algorithm"]
fail!("Unexpected algorithm: #{algo.inspect}") unless algo == "SHA-256"

artifacts = payload["artifacts"]
fail!("Invalid manifest format: artifacts must be an object") unless artifacts.is_a?(Hash)

artifacts.each do |path, expected_hash|
  fail!("Listed file does not exist: #{path}") unless File.exist?(path)
  actual_hash = Digest::SHA256.file(path).hexdigest

  if actual_hash != expected_hash
    fail!("Hash mismatch for #{path}\n  expected: #{expected_hash}\n  actual:   #{actual_hash}")
  end
end

puts "OK: signature valid and all artifact hashes match."
