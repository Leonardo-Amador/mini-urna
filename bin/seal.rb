#!/usr/bin/env ruby
require "openssl"

HASH_FILE = "data/hashes.json"
SIG_FILE  = "data/hashes.sig"
PRIV_KEY  = "keys/private.pem"

unless File.exist?(HASH_FILE)
  warn "Missing #{HASH_FILE}. Run bin/hash.rb first."
  exit 1
end

unless File.exist?(PRIV_KEY)
  warn "Missing #{PRIV_KEY}. Generate keys first."
  exit 1
end

private_key = OpenSSL::PKey::RSA.new(File.read(PRIV_KEY))
data = File.binread(HASH_FILE)

digest = OpenSSL::Digest::SHA256.new
signature = private_key.sign(digest, data)

File.binwrite(SIG_FILE, signature)
puts "OK: sealed hashes manifest -> #{SIG_FILE} (#{signature.bytesize} bytes)."
