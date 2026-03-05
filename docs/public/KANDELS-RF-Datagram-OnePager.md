# KANDELS RF Datagram (KRD) — Executive Teaser

**Compact voice-to-data messaging for bandwidth-starved radio links** | BitConcepts, LLC | March 2026

---

## The Problem

Voice over constrained RF is impossible — LoRa delivers 5–20 B/s; voice needs 8,000. Plain text wastes bits. Standard compression *expands* short messages. There is no protocol that compresses human language to the minimum bits needed for intelligibility while providing error correction.

## The Solution

KRD encodes language using the patented KANDELS phonetic encoding (US 2024/0248922 A1). Each word's first consonant maps to a 3-bit sound-group index, bit-packed into an RF payload sized to the target protocol's MTU — no color values, no visual overhead. Combined with CPSC constraint-projection error correction:

> *"CONTACT NORTH TWO HUNDRED METERS" → **3 bytes** (vs. 33 B ASCII — 11× compression, impossible via voice)*

Three modes: **KRD-P** 3 bits/word lossy · **KRD-S** 26 B lossless frame · **KRD-M** chained frames for longer messages.
Speak → on-device STT → KANDELS encode → RF burst → decode + CPSC validate → display/TTS.
A 5-second message becomes a sub-100 ms transmission.

---

## How KRD Fits Real Protocols

**LoRa / Meshtastic (915/868 MHz, CSS)** — 228 B max payload. KRD-P (3 B) = 1.3 % of one packet; KRD-M 4-frame chain (99 B) fits with room to spare. SF12 burst: ~330 ms; SF7: ~15 ms. Voice needs 400× available throughput.

**Sigfox (868/915 MHz, UNB ~100 Hz)** — 12 B max uplink, 140 msg/day, 50 km range. KRD-P (3 B) fits with 9 spare bytes → **140 tactical voice-to-text messages/day**, continent-scale, zero provisioning.

**BLE (2.4 GHz, GFSK)** — 31 B legacy advertisement. KRD-P (3 B) fits alongside device ID + sensor data, no connection needed. First-responder triage, building-clearance beacons.

**CC1101 Sub-GHz ISM (315/433/868/915 MHz)** — 64 B FIFO, OOK/FSK/GFSK/MSK, 0.6–600 kbps, <1 µA sleep. KRD-P: **20 ms** at 1.2 kbps OOK, **<1 ms** at 38.4 kbps GFSK.

---

## Proposed Low-Energy KRD Transport Profiles

**KRD-Burst (433 MHz OOK, 1.2 kbps)** — Simplest TX, coin-cell powered, ~20 ms / ~2 µJ per message. Target: disposable sensors, covert beacons.

**KRD-Hop (915 MHz GFSK, 38.4 kbps, FHSS)** — Frequency-hopping, <1 ms burst, LPI/LPD. Target: military tactical nets, contested RF.

**KRD-Deep (315 MHz 2-FSK, 1.2 kbps)** — Lowest ISM band, max penetration, −110 dBm sensitivity. Target: underground/tunnel, subterranean mining.

---

## IP, Status & The Ask

**IP** — Dual-patent moat: *US 2024/0248922 A1* (KANDELS encoding, Merkur) + *CPSC provisional* (constraint-projection ECC, BitConcepts Feb 2026) — 9–13× fewer false decodes than Reed-Solomon alone.

**Status** — Working KANDELS encoder with RS over GF(8) and CPSC validation (82,800 simulation trials). Visual camera-decode demo proven; RF adaptation bit-packs the same 3-bit symbol indices into protocol-native payloads — no color overhead. KRD datagram format defined; transport integration next.

**The Ask** — RF hardware partners, SBIR/STTR co-applicants, or $500K–$1M seed for protocol implementation, Meshtastic integration, and field demonstration. **$30–43 B TAM** across military, space, LPWAN, and public safety.

---

**Full brief**: KANDELS-RF-Datagram-Brief.md | **Contact**: BitConcepts, LLC | © 2026 BitConcepts, LLC | Business Confidential
