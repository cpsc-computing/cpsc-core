#!/usr/bin/env python3
"""
QLoRA Fine-Tuning Script for CPSC Domain Model

Fine-tunes Qwen2.5-Coder-7B-Instruct using QLoRA on the extracted
training data from BitConcepts repositories.

Optimized for RTX 4070 SUPER (12 GB VRAM):
  - 4-bit quantization (NF4) during training
  - LoRA rank r=16, alpha=32
  - batch_size=1, gradient_accumulation=8 (effective batch=8)
  - max_seq_len=2048
  - learning_rate=2e-4, 3 epochs

Data balancing:
  The raw dataset is heavily Python-weighted (~13k records) vs VHDL (~112).
  We apply stratified sampling with per-language caps and oversampling of
  scarce languages to produce a balanced training set.

Usage:
    python scripts/training/finetune_qlora.py \\
        --input scripts/training/training_data.jsonl \\
        --output-dir models/cpsc-coder-lora \\
        [--base-model Qwen/Qwen2.5-Coder-7B-Instruct] \\
        [--epochs 3] \\
        [--max-samples 5000]

Requires: pip install "unsloth[colab-new] @ git+https://github.com/unslothai/unsloth.git"
          pip install datasets trl

SPDX-License-Identifier: MIT
"""

import argparse
import json
import random
import sys
from collections import defaultdict
from pathlib import Path


def load_and_balance(input_path: str, max_samples: int, seed: int = 42) -> list[dict]:
    """Load JSONL and produce a balanced dataset via stratified sampling."""
    random.seed(seed)

    by_lang: dict[str, list[dict]] = defaultdict(list)
    with open(input_path, "r", encoding="utf-8") as f:
        for line in f:
            record = json.loads(line)
            lang = record["metadata"]["language"]
            by_lang[lang].append(record)

    print(f"[DATA] Raw counts: { {k: len(v) for k, v in by_lang.items()} }")

    # Per-language target allocation:
    #   - VHDL: take all, oversample 5x (scarce, high value)
    #   - Rust: take all, oversample 3x (scarce)
    #   - C: cap at 800
    #   - Python: cap at 1500
    #   - YAML/other: cap at 500
    # NOTE: VHDL targets AMD Vivado 2025.2 / UltraScale+ — oversample heavily
    lang_config = {
        "vhdl":   {"cap": None, "oversample": 8},  # scarce + high value (Vivado 2025.2)
        "rust":   {"cap": None, "oversample": 3},
        "c":      {"cap": 800,  "oversample": 1},
        "python": {"cap": 1500, "oversample": 1},
        "yaml":   {"cap": 500,  "oversample": 1},
    }

    balanced = []
    for lang, records in by_lang.items():
        cfg = lang_config.get(lang, {"cap": 300, "oversample": 1})
        cap = cfg["cap"]
        oversample = cfg["oversample"]

        # Apply cap
        if cap and len(records) > cap:
            records = random.sample(records, cap)

        # Oversample scarce languages
        if oversample > 1:
            records = records * oversample

        balanced.extend(records)

    random.shuffle(balanced)

    # Global cap
    if len(balanced) > max_samples:
        balanced = balanced[:max_samples]

    lang_counts = defaultdict(int)
    for r in balanced:
        lang_counts[r["metadata"]["language"]] += 1
    print(f"[DATA] Balanced counts: {dict(lang_counts)}")
    print(f"[DATA] Total training samples: {len(balanced)}")

    return balanced


def format_for_training(record: dict) -> dict:
    """Format a record into the chat template expected by Qwen2.5-Coder."""
    return {
        "instruction": record["instruction"],
        "output": record["response"],
    }


def main():
    parser = argparse.ArgumentParser(description="QLoRA fine-tune for CPSC domain")
    parser.add_argument("--input", type=str, required=True, help="Path to training_data.jsonl")
    parser.add_argument("--output-dir", type=str, default="models/cpsc-coder-lora",
                        help="Directory to save LoRA adapter")
    parser.add_argument("--base-model", type=str, default="Qwen/Qwen2.5-Coder-7B-Instruct",
                        help="HuggingFace model ID")
    parser.add_argument("--epochs", type=int, default=3, help="Training epochs")
    parser.add_argument("--max-samples", type=int, default=5000,
                        help="Max total training samples after balancing")
    parser.add_argument("--max-seq-len", type=int, default=2048, help="Max sequence length")
    parser.add_argument("--lr", type=float, default=2e-4, help="Learning rate")
    parser.add_argument("--lora-r", type=int, default=16, help="LoRA rank")
    parser.add_argument("--lora-alpha", type=int, default=32, help="LoRA alpha")
    parser.add_argument("--batch-size", type=int, default=1, help="Per-device batch size")
    parser.add_argument("--grad-accum", type=int, default=8, help="Gradient accumulation steps")
    parser.add_argument("--seed", type=int, default=42, help="Random seed")
    parser.add_argument("--dry-run", action="store_true", help="Load data only, don't train")
    args = parser.parse_args()

    # ── Step 1: Load and balance data ────────────────────────
    print("=" * 60)
    print("Phase 1: Loading and balancing training data")
    print("=" * 60)
    balanced = load_and_balance(args.input, args.max_samples, args.seed)

    if args.dry_run:
        print("[DRY RUN] Skipping training. Data looks good.")
        return

    # ── Step 2: Import ML libraries (heavy imports) ──────────
    print("\n" + "=" * 60)
    print("Phase 2: Loading model and tokenizer")
    print("=" * 60)

    try:
        from unsloth import FastLanguageModel
    except ImportError:
        print("[ERROR] Unsloth not installed. Run:")
        print('  pip install "unsloth[colab-new] @ git+https://github.com/unslothai/unsloth.git"')
        sys.exit(1)

    from datasets import Dataset
    from trl import SFTTrainer
    from transformers import TrainingArguments

    # ── Step 3: Load base model with 4-bit quantization ──────
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name=args.base_model,
        max_seq_length=args.max_seq_len,
        dtype=None,  # auto-detect
        load_in_4bit=True,
    )

    # ── Step 4: Apply LoRA adapter ───────────────────────────
    print("\n" + "=" * 60)
    print("Phase 3: Applying LoRA adapter")
    print("=" * 60)

    model = FastLanguageModel.get_peft_model(
        model,
        r=args.lora_r,
        lora_alpha=args.lora_alpha,
        lora_dropout=0.05,
        target_modules=[
            "q_proj", "k_proj", "v_proj", "o_proj",
            "gate_proj", "up_proj", "down_proj",
        ],
        bias="none",
        use_gradient_checkpointing="unsloth",
        random_state=args.seed,
    )

    # ── Step 5: Prepare dataset ──────────────────────────────
    print("\n" + "=" * 60)
    print("Phase 4: Preparing dataset")
    print("=" * 60)

    formatted = [format_for_training(r) for r in balanced]

    # Split 90/10 train/eval
    split_idx = int(len(formatted) * 0.9)
    train_data = Dataset.from_list(formatted[:split_idx])
    eval_data = Dataset.from_list(formatted[split_idx:])
    print(f"[DATA] Train: {len(train_data)}, Eval: {len(eval_data)}")

    # Chat template formatting
    alpaca_prompt = """Below is an instruction that describes a task. Write a response that appropriately completes the request.

### Instruction:
{}

### Response:
{}"""

    def formatting_func(examples):
        texts = []
        for instruction, output in zip(examples["instruction"], examples["output"]):
            text = alpaca_prompt.format(instruction, output) + tokenizer.eos_token
            texts.append(text)
        return {"text": texts}

    train_data = train_data.map(formatting_func, batched=True)
    eval_data = eval_data.map(formatting_func, batched=True)

    # ── Step 6: Train ────────────────────────────────────────
    print("\n" + "=" * 60)
    print("Phase 5: Training")
    print("=" * 60)

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    training_args = TrainingArguments(
        output_dir=str(output_dir),
        num_train_epochs=args.epochs,
        per_device_train_batch_size=args.batch_size,
        gradient_accumulation_steps=args.grad_accum,
        learning_rate=args.lr,
        weight_decay=0.01,
        warmup_ratio=0.03,
        lr_scheduler_type="cosine",
        logging_steps=10,
        save_strategy="epoch",
        eval_strategy="epoch",
        bf16=True,
        optim="adamw_8bit",
        seed=args.seed,
        report_to="none",
    )

    trainer = SFTTrainer(
        model=model,
        tokenizer=tokenizer,
        train_dataset=train_data,
        eval_dataset=eval_data,
        dataset_text_field="text",
        max_seq_length=args.max_seq_len,
        args=training_args,
    )

    print(f"[TRAIN] Starting {args.epochs}-epoch training...")
    print(f"[TRAIN] Effective batch size: {args.batch_size * args.grad_accum}")
    print(f"[TRAIN] Estimated steps: {len(train_data) // (args.batch_size * args.grad_accum) * args.epochs}")

    trainer.train()

    # ── Step 7: Save LoRA adapter ────────────────────────────
    print("\n" + "=" * 60)
    print("Phase 6: Saving LoRA adapter")
    print("=" * 60)

    model.save_pretrained(str(output_dir / "adapter"))
    tokenizer.save_pretrained(str(output_dir / "adapter"))
    print(f"[SAVE] LoRA adapter saved to {output_dir / 'adapter'}")

    # Save training metadata
    metadata = {
        "base_model": args.base_model,
        "lora_r": args.lora_r,
        "lora_alpha": args.lora_alpha,
        "epochs": args.epochs,
        "max_seq_len": args.max_seq_len,
        "learning_rate": args.lr,
        "train_samples": len(train_data),
        "eval_samples": len(eval_data),
        "seed": args.seed,
    }
    with open(output_dir / "training_metadata.json", "w") as f:
        json.dump(metadata, f, indent=2)
    print(f"[SAVE] Metadata saved to {output_dir / 'training_metadata.json'}")

    print("\n[DONE] Fine-tuning complete.")
    print(f"[DONE] Next: run scripts/training/export_gguf.py to convert to GGUF format")


if __name__ == "__main__":
    main()
