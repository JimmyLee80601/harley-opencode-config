#!/data/data/com.termux/files/usr/bin/bash
# Quick test: have Harley Vision 2B describe a Harley1 image
IMG="/storage/emulated/0/DCIM/Harley1/1783976676969.png"
B64=$(base64 -w0 "$IMG")
curl -s http://127.0.0.1:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d "{\"messages\":[{\"role\":\"user\",\"content\":[{\"type\":\"image_url\",\"image_url\":{\"url\":\"data:image/png;base64,$B64\"}},{\"type\":\"text\",\"text\":\"Describe this image factually in 1-2 sentences. Is it non-adult character art?\"}]}],\"max_tokens\":128}"
