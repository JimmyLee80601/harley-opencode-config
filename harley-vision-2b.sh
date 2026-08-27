#!/data/data/com.termux/files/usr/bin/bash
# Harley Vision 2B - Qwen3-VL-2B abliterated, local vision server
MODEL_DIR="$HOME/models/harley-vision-2b"
LLM="$MODEL_DIR/huihui-qwen3vl-2b.Q4_K_M.gguf"
MMPROJ="$MODEL_DIR/mmproj-qwen3vl-2b.f16.gguf"

exec llama-server \
  -m "$LLM" \
  --mmproj "$MMPROJ" \
  -c 4096 \
  --image-min-tokens 1024 \
  -ngl 99 \
  --host 127.0.0.1 \
  --port 8080 \
  "$@"
