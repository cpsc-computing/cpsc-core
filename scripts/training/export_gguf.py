#!/usr/bin/env python3
"""
Export Fine-Tuned Model to GGUF Format

Merges the QLoRA adapter with the base model and exports to GGUF Q8_0
format for use with Ollama.

Usage:
    python scripts/training/export_gguf.py \\
        --adapter-dir models/cpsc-coder-lora/adapter \\
        --output-dir models/cpsc-coder-gguf \\
        [--quantization q8_0]

Requires: pip install "unsloth[colab-new] @ git+https://github.com/unslothai/unsloth.git"

SPDX-License-Identifier: MIT
"""

import argparse
import json
import sys
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description="Export LoRA to GGUF")
    parser.add_argument("--adapter-dir", type=str, default="models/cpsc-coder-lora/adapter",
                        help="Path to saved LoRA adapter")
    parser.add_argument("--output-dir", type=str, default="models/cpsc-coder-gguf",
                        help="Output directory for GGUF file")
    parser.add_argument("--quantization", type=str, default="q8_0",
                        choices=["q4_k_m", "q5_k_m", "q8_0", "f16"],
                        help="Quantization method")
    parser.add_argument("--base-model", type=str, default="Qwen/Qwen2.5-Coder-7B-Instruct",
                        help="HuggingFace base model ID")
    parser.add_argument("--max-seq-len", type=int, default=2048, help="Max sequence length")
    args = parser.parse_args()

    try:
        from unsloth import FastLanguageModel
    except ImportError:
        print("[ERROR] Unsloth not installed.")
        sys.exit(1)

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Load the fine-tuned model (base + adapter)
    print(f"[LOAD] Loading base model + LoRA adapter from {args.adapter_dir}")
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name=args.adapter_dir,
        max_seq_length=args.max_seq_len,
        dtype=None,
        load_in_4bit=True,
    )

    # Export to GGUF
    print(f"[EXPORT] Saving as GGUF ({args.quantization}) to {output_dir}")
    model.save_pretrained_gguf(
        str(output_dir),
        tokenizer,
        quantization_method=args.quantization,
    )

    print(f"\n[DONE] GGUF model exported to {output_dir}")
    print(f"[DONE] Next: create Ollama Modelfile and run:")
    print(f"         ollama create cpsc-coder -f tools/ollama/Modelfile.cpsc-coder")


if __name__ == "__main__":
    main()
