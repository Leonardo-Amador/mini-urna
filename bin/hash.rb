#!/usr/bin/env ruby
require "json"
require "digest"
require "time"

ARTIFACTS = [
  "data/bu.txt",
  "data/rdv_final.jsonl",
].freeze

hashes = {}

ARTIFACTS.each do |path|
  unless File.exist?(path)
    warn "File not found: #{path}"
    exit 1
  end

  hashes[path] = Digest::SHA256.file(path).hexdigest
end

payload = {
  generated_at: Time.now.utc.iso8601,
  algorithm: "SHA-256",
  artifacts: hashes
}

File.write("data/hashes.json", JSON.pretty_generate(payload) + "\n")
puts "OK: generated data/hashes.json (#{hashes.size} artifacts)."
