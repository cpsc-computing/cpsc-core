# KANDELS RF Datagram Protocol — Collaboration Brief

**Version**: 0.1 (Draft)
**Date**: March 2, 2026
**Author**: BitConcepts, LLC
**Classification**: Business Confidential — Pre-Release

---

## Executive Summary

KANDELS RF Datagram (KRD) is a phonetic-compression-based messaging protocol designed for bandwidth-constrained radio frequency (RF) links. By encoding human language into compact 3-bit phonetic symbol codes — using the patented KANDELS system (US 2024/0248922 A1) — and layering CPSC constraint projection for error recovery, KRD enables intelligible text messaging in as few as **3 bytes per message** over links where voice and conventional text are impractical or impossible.

The KANDELS patent defines a phonetic-to-color mapping for visual applications (camera-decoded color grids). For RF, the same encoding is used but the visual representation is discarded entirely: each word's leading consonant maps to a 3-bit sound-group index (0–6) packed into a tight bitstream — no color values, no finder patterns, no spatial layout overhead. The result is a protocol-agnostic payload that fits inside any RF packet format.

KRD targets RF environments where every bit is expensive: LoRa mesh networks (Meshtastic), BLE, tactical military radios, satellite uplinks, deep-space relays, and proprietary sub-GHz ISM links.

---

## 1. What Problem Does This Solve?

### The Bandwidth Gap

In constrained RF environments, there is a fundamental gap between what operators need to communicate and what the channel can carry:

- **LoRa/Meshtastic**: ~5–20 bytes/second effective throughput; max payload ~228 bytes per packet; voice requires ~8,000 bytes/second — **400× more than available**
- **Tactical military radios (SINCGARS)**: 16 kbps shared across an entire net; voice ties up the channel for the duration of the transmission
- **Deep space (Mars rover direct-to-Earth)**: 500–32,000 bps depending on orbital geometry; a single English sentence in ASCII can take seconds of precious link time
- **BLE advertisements**: 31 bytes (legacy) or 255 bytes (extended); designed for beacons, not conversation
- **Submarine ELF/VLF**: Single-digit bits per second; currently limited to pre-coded brevity signals

**The core problem**: Voice is too expensive for these links. Standard text (ASCII/UTF-8 at 8 bits/character) wastes bandwidth on information the receiver can reconstruct. There is no widely available protocol that compresses human-language messages to the minimum bits needed for intelligibility while providing built-in error correction.

### What Exists Today Is Inadequate

- **Brevity codes** (BREVMAT, Z-codes, Q-codes): Require memorization, limited vocabulary, not machine-processable, no error correction
- **Standard compression** (LZ77, DEFLATE, zstd): Ineffective on short messages (<100 bytes); compression ratio often >1.0x (expansion) for tactical-length text
- **Protocol Buffers / MessagePack**: Schema-based serialization, not language-aware; no phonetic compression; still 8 bits/character for string fields
- **Codec2 / voice codecs**: Minimum ~700 bps for intelligible voice; still requires continuous channel allocation; degrades badly under packet loss

---

## 2. What Is KANDELS RF Datagram?

KRD exploits a fundamental property of human language: **the first consonant sound of a word carries the majority of its semantic identity**. The patented KANDELS system maps these sounds to 7 categories — named by colors in the visual system (Yellow, Gray, Red, Blue, Green, Purple, Brown) but transmitted as **3-bit symbol indices (0–6)** in RF. No bytes are wasted encoding color values; only the sound-group index enters the bitstream.

KRD defines three transmission modes that trade fidelity for compactness:

### Mode 1: Phonetic Skeleton (KRD-P) — Ultra-Compact

Transmit **only the KANDELS symbol sequence** — 3 bits per word, bit-packed to byte boundary, no metadata.

The receiver uses a shared tactical dictionary and phonetic context to reconstruct probable words. Lossy but intelligible for constrained vocabularies (military brevity, emergency codes, status reports).

**Example**: "CONTACT NORTH TWO HUNDRED METERS"
- CONTACT → K(1), NORTH → N(2), TWO → T(3), HUNDRED → H(5), METERS → M(2)
- Encoding: `[1, 2, 3, 5, 2]` = 15 bits of phonetic data, packed into 2 bytes
- Full datagram: 1-byte header + 2-byte payload = **3 bytes**
- Compare: ASCII = 33 characters × 8 bits = **264 bits (33 bytes)**
- **Compression: 11× vs ASCII**

With a shared tactical dictionary (e.g., NATO brevity, SALUTE report vocabulary), the receiver reconstructs: "CONTACT NORTH TWO HUNDRED METERS" from the 5-symbol sequence with high confidence because the vocabulary is constrained.

### Mode 2: Standard Frame (KRD-S) — Balanced

Serialize the KANDELS data and metadata symbols into an RF frame with RS error correction for lossless character reconstruction. Visual-only artifacts (finder corners, spatial layout) are stripped — only the 60 meaningful symbols are transmitted.

- 60 symbols × 3 bits = 180 bits = **23 bytes** payload (bit-packed)
- With datagram header (1 B) + CPSC trailer (2 B): **26 bytes** total
- Capacity: 10–14 characters per frame, **lossless**
- Includes interleaved Reed-Solomon RS(6,4) × 5 over GF(8): corrects up to 5 symbol errors
- CPSC constraint projection catches RS miscorrections (9–13× fewer false decodes)

**Example**: "EVAC NOW" = 8 characters, fits in 1 frame = 26 bytes with full error correction. Compare: ASCII = 8 bytes (no error correction). Adding equivalent FEC overhead to raw ASCII would bring it to ~16 bytes, but without CPSC's semantic validation layer.

### Mode 3: Multi-Frame Chain (KRD-M) — Extended Messages

For longer messages, chain multiple frames with continuity validation:

- Each frame: 24 bytes (23-byte symbol payload + 1-byte chain CRC)
- CPSC validates inter-frame consistency
- 4 frames = 99 bytes (1 header + 4 × 24 + 2 CPSC trailer) — fits in a single Meshtastic packet

---

## 3. KRD Datagram Format

The KRD datagram is a protocol-agnostic bitstream designed for minimum overhead. No bytes are allocated to color representation, spatial layout, or visual finder patterns — only sound-group indices and error-correction metadata.

```
┌──────────────────────────────────────────────────────┐
│  KRD HEADER (1 byte)                                  │
│    [2 bits] Version (00=v1)                           │
│    [2 bits] Mode (00=phonetic, 01=standard, 10=multi) │
│    [1 bit]  More frames follow (KRD-M only)           │
│    [3 bits] Word count (KRD-P, 1–7; 0=extended) or    │
│             frame seq number (KRD-S/M)                │
├──────────────────────────────────────────────────────┤
│  EXTENDED COUNT (1 byte, only when word_count == 0)    │
│    [8 bits] Actual word count (8–255)                  │
├──────────────────────────────────────────────────────┤
│  PAYLOAD (variable, bit-packed to byte boundary)       │
│    Mode 00: N × 3-bit symbol indices, tight-packed     │
│    Mode 01: 60 × 3-bit symbols = 180 bits (23 bytes)  │
│    Mode 10: N × (180-bit frame + 8-bit chain CRC)     │
├──────────────────────────────────────────────────────┤
│  CPSC TRAILER (2 bytes, Mode 01/10 only)               │
│    [8 bits] Constraint validation checksum              │
│    [8 bits] Frame/chain integrity hash                  │
└──────────────────────────────────────────────────────┘
```

KRD-P relies on the transport layer's native CRC (LoRa, BLE, and CC1101 all provide link-layer CRC) and does not carry a CPSC trailer, keeping the phonetic mode as compact as possible.

### Datagram Sizes (RF Bitstream)

| Mode | Content | Datagram Size | Equivalent ASCII |
|------|---------|---------------|-----------------|
| KRD-P (5 words) | Phonetic symbols | 3 bytes | 25–40 bytes |
| KRD-P (10 words) | Phonetic symbols | 6 bytes | 50–80 bytes |
| KRD-P (20 words) | Phonetic symbols | 10 bytes | 100–160 bytes |
| KRD-S (1 frame) | 10–14 chars lossless | 26 bytes | 10–14 bytes + FEC |
| KRD-M (4 frames) | ~50 chars lossless | 99 bytes | 50 bytes + FEC |

---

## 4. The Voice-to-KRD Pipeline

Voice communication over constrained RF is currently impossible (requires ~8,000 bytes/second vs 5–20 bytes/second available on LoRa). KRD solves this by converting voice to compact text datagrams:

```
┌──────────┐   ┌────────────┐   ┌──────────┐   ┌─────────┐   ┌──────────┐
│  Voice   │──>│  On-Device  │──>│  KANDELS  │──>│   KRD   │──>│  RF Link │
│  Input   │   │  Speech-to- │   │  Encoder  │   │Datagram │   │  (LoRa,  │
│(mic/PTT) │   │  Text (STT) │   │(3 bits/  │   │  (7-108 │   │   BLE,   │
│          │   │             │   │  word)    │   │  bytes) │   │ SINCGARS)│
└──────────┘   └────────────┘   └──────────┘   └─────────┘   └──────────┘
                                                                    │
┌──────────┐   ┌────────────┐   ┌──────────┐   ┌─────────┐         │
│  Audio   │<──│  Text-to-  │<──│  KANDELS  │<──│   KRD   │<───────┘
│  Output  │   │  Speech    │   │  Decoder  │   │  Decode │
│(speaker) │   │ (optional) │   │           │   │ + CPSC  │
└──────────┘   └────────────┘   └──────────┘   └─────────┘
```

**On-device STT**: Whisper.cpp, Vosk, or similar run on ARM Cortex-M7/A-class or RISC-V — no cloud required. Tactical keyword vocabulary can be constrained to improve accuracy and reduce compute.

**Encode latency**: KANDELS encoding is a simple lookup table — microseconds on any processor. The entire voice-to-datagram pipeline adds <500ms including STT.

**Result**: A 5-second spoken tactical message becomes a 7-byte burst transmission lasting <100ms on LoRa. The channel is occupied for **1/50th** the time of a voice transmission covering the same content.

---

## 5. Target Applications

### 5.1 Military & Defense

**Problem**: Tactical radios (SINCGARS, AN/PRC-117G, Harris Falcon III) share 16–64 kbps nets among entire platoons. Voice traffic saturates channels. In contested/jammed environments, shorter transmissions are harder to detect, locate, and jam (Low Probability of Intercept/Detection — LPI/LPD).

**KRD value**:
- **SALUTE reports** ("Size, Activity, Location, Unit, Time, Equipment") compress to ~12 words → KRD-P in 7 bytes, transmitted in <5ms on SINCGARS
- **9-Line MEDEVAC requests** (standardized fields): encode fixed-vocabulary fields in phonetic mode, free-text in grid mode → ~50 bytes total
- **Blue Force Tracking supplements**: Squad-level position + status in ultra-compact bursts
- **Drone swarm coordination**: Command/status messages between UAVs on bandwidth-limited data links
- **Reduced electromagnetic signature**: 7-byte burst vs multi-second voice transmission — dramatically reduced exposure to SIGINT/direction-finding

**Acquisition path**: SBIR/STTR programs (DoD), CRADA with DEVCOM C5ISR, prime contractor integration (L3Harris, Collins Aerospace, Thales)

### 5.2 Space Communications

**Problem**: Deep-space RF links operate at extremely limited data rates — Mars direct-to-Earth ranges from 500 bps to 32 kbps. Every bit consumes power and antenna time. Human-readable status messages compete with science data for scarce downlink bandwidth.

**KRD value**:
- **Crew status messages** from Mars surface: Voice status → KRD-P phonetic → 7-byte burst. At 500 bps worst-case, that is **0.1 seconds** of link time vs ~33 seconds for the same message in ASCII
- **CubeSat telemetry annotation**: Attach human-readable context to sensor data without doubling payload size
- **Lunar surface mesh**: Astronaut-to-astronaut text messaging over bandwidth-limited surface mesh networks
- **Emergency beacon enhancement**: Distress messages with context beyond standard PLB codes, fitting within existing beacon payload constraints

**Acquisition path**: NASA SBIR, ESA technology programs, commercial space operators (Axiom, Relativity)

### 5.3 Low-Power Mesh Telecommunications

**Problem**: LoRa/Meshtastic networks provide long-range (~10+ km) mesh communication but at extremely low data rates (~5–20 bytes/second). Current Meshtastic messaging is plain text, wasting bits. Voice over Meshtastic is effectively impossible.

**KRD value**:
- **Voice messaging over Meshtastic**: Speak → STT → KRD-P → transmit 7 bytes → decode → display (or TTS). Currently impossible with any other approach.
- **Emergency/disaster mesh**: Post-disaster communications when cellular infrastructure is destroyed. KRD enables 4–5× more messages per channel per hour than raw ASCII text.
- **Remote operations**: Mining, forestry, maritime, pipeline monitoring — workers communicating over long-range LoRa links with voice-to-text capability
- **Community mesh networks**: The ~40,000 active Meshtastic nodes globally could adopt KRD as a message-efficiency layer

**Acquisition path**: Open-source Meshtastic integration, Heltec/TTGO device partnerships, FEMA/emergency management procurement

### 5.4 BLE Tactical & First Responder

**Problem**: BLE has limited payload (31 bytes legacy advertisement, 255 bytes extended) and is increasingly used for proximity-based tactical coordination (building clearance, firefighter accountability, event security).

**KRD value**:
- **Firefighter accountability**: Status + location + condition in a single BLE advertisement (KRD-P fits in 3–6 bytes within the 31-byte legacy payload alongside other data)
- **Law enforcement building clearance**: Room-by-room status broadcasts via BLE mesh
- **Medical triage**: Patient status in compact BLE beacons

### 5.5 Protocol Integration: How KRD Fits Real RF Stacks

**LoRa / Meshtastic (915 MHz US, 868 MHz EU — CSS modulation)**
Max payload ~228 bytes per Meshtastic packet. KRD-P (3 B for a 5-word message) uses **1.3 %** of one packet. KRD-M 4-frame chain (99 B, ~50 chars lossless) fits in a single packet with room to spare. At SF12/125 kHz (250 bps, max range) a 3-byte burst takes ~330 ms; at SF7 (5.5 kbps, short range) it takes ~15 ms.

**Sigfox (868/915 MHz — Ultra-Narrowband, ~100 Hz BW)**
Max uplink 12 bytes, 140 messages/day, range up to 50 km. KRD-P (3 B) fits with 9 spare bytes for metadata or extended word count — enabling **140 tactical voice-to-text messages/day** over continent-scale infrastructure with zero provisioning.

**BLE (2.4 GHz — GFSK)**
Legacy advertisement: 31 bytes. KRD-P (3 B) fits inside a single advertisement alongside device ID and sensor data — no connection establishment needed.

**Sub-GHz ISM via CC1101 (315 / 433 / 868 / 915 MHz)**
TI CC1101: 64-byte FIFO, OOK/2-FSK/GFSK/MSK, 0.6–600 kbps, <1 µA sleep, 15–17 mA RX, +12 dBm TX. KRD-P (3 B) at 1.2 kbps OOK = **20 ms burst**; at 38.4 kbps GFSK = **<1 ms burst**. Wake-on-radio keeps average draw under 1 µA between messages.

### 5.6 Proposed Low-Energy KRD Transport Profiles

**KRD-Burst (433 MHz OOK, 1.2 kbps)** — Simplest possible TX: switch an oscillator on/off. Coin-cell powered, wake-on-radio. 3-byte message in ~20 ms, ~2 µJ per transmission. Target: disposable sensors, building-scale mesh, covert beacons.

**KRD-Hop (915 MHz GFSK, 38.4 kbps, frequency hopping)** — CC1101 FHSS with 75 µs settling. 3-byte message hops across channels in <1 ms total. Low probability of intercept/detection (LPI/LPD). Target: military tactical nets, contested RF environments.

**KRD-Deep (315 MHz 2-FSK, 1.2 kbps)** — Lowest ISM frequency for maximum penetration through structures, foliage, and earth. 3-byte burst in ~20 ms. Sensitivity −110 dBm. Target: underground/tunnel comms, dense-urban first responder, subterranean mining.

---

## 6. Competitive Advantage & Moat

### Why KANDELS, Not Just Better Compression?

Standard compression algorithms treat text as arbitrary byte sequences. KRD exploits the **phonetic structure of human language** — a fundamentally different approach:

| Approach | 10-Word Tactical Message | Error Correction | Semantic Awareness |
|----------|------------------------|-----------------|-------------------|
| ASCII (raw) | 80 bytes | None | None |
| ASCII + FEC | ~120 bytes | Yes (generic) | None |
| zstd (compressed) | ~75 bytes* | None | None |
| Codec2 voice (3s) | ~263 bytes | None | None |
| KRD-P (phonetic) | 6 bytes | Transport-layer CRC | Yes |
| KRD-S (lossless) | 26–99 bytes | RS + CPSC | Yes |

*zstd typically expands short messages; 75 bytes is optimistic with a trained dictionary.

### Intellectual Property

- **US 2024/0248922 A1** (Merkur, pending): Core KANDELS phonetic-to-symbol mapping, visual grid and RF frame encoding, categorical touch search system
- **BitConcepts CPSC provisional** (filed Feb 2026): Constraint projection for error recovery, data density improvement, miscorrection detection
- **Combined IP position**: The phonetic encoding (KANDELS patent) + error correction layer (CPSC patent) create a dual-patent moat that is difficult to design around

### Technical Moat

- **Phonetic compression is language-native**: Unlike byte-level compression, KANDELS understands that "CONTACT" and "KANGAROO" share the same leading sound — they compress identically. This is a structural property of the encoding, not a learned model.
- **CPSC constraint projection is not just FEC**: It validates semantic consistency, not just bitstream integrity. A standard FEC can "correct" errors into valid-but-wrong data; CPSC catches this (9–13× reduction in false corrections per simulation results).
- **Computationally trivial**: KANDELS encoding is a lookup table. Runs on an 8-bit microcontroller. No neural networks, no training data, no GPU. This matters for embedded, military, and space applications.

---

## 7. Market Sizing

### Addressable Markets

| Segment | TAM (Annual) | Basis |
|---------|-------------|-------|
| Military tactical communications | $15–20B | Global military C4ISR spending on tactical radio/data links |
| Space communications | $4–6B | Ground segment + onboard comms systems |
| LoRa/LPWAN IoT | $8–12B | LPWAN module + platform market (growing ~20% CAGR) |
| Public safety / first responder | $3–5B | P25/LTE/mesh radio procurement |
| **Total TAM** | **$30–43B** | |

KRD is a **protocol/software layer**, not hardware. It integrates into existing radio stacks. Realistic SAM is the software/firmware licensing slice of these markets.

### Business Model Options

1. **Licensing**: Per-device or per-unit firmware licensing to radio OEMs (L3Harris, Motorola Solutions, Collins Aerospace, Iridium)
2. **Government contracts**: SBIR/STTR → CRADA → PEO C3T program of record integration
3. **Open-source base + commercial extensions**: Free KRD-P (phonetic) mode for community adoption (Meshtastic); commercial license for KRD-S/KRD-M with CPSC error correction
4. **SaaS for space**: Ground-segment encoding/decoding service for commercial satellite operators

---

## 8. Technical Feasibility

### What Exists Today (TRL Assessment)

| Component | Status | TRL |
|-----------|--------|-----|
| KANDELS phonetic encoding | Implemented, tested (Python, camera demo) | 4 |
| KANDELS visual grid v2 (8×8, RS, metadata) | Implemented, roundtrip-validated | 4 |
| KANDELS RF symbol packing (bitstream) | Defined (this document), not yet implemented | 2 |
| CPSC constraint projection | Implemented, simulation-validated (82,800 trials) | 4 |
| On-device STT (Whisper.cpp, Vosk) | Mature open-source, runs on ARM | 6 |
| KRD datagram framing | Defined (this document), not yet implemented | 2 |
| LoRa/Meshtastic transport integration | Not yet implemented | 2 |
| CC1101 sub-GHz transport profiles | Not yet implemented | 1 |
| BLE transport integration | Not yet implemented | 2 |
| Tactical dictionary (constrained vocab) | Not yet defined | 1 |

### Development Roadmap

**Phase 1 (3 months): KRD protocol implementation**
- Define KRD datagram format (binary spec)
- Implement KRD encoder/decoder in C (embedded-friendly)
- Build tactical dictionary for NATO brevity / SALUTE / 9-Line
- Validate over serial/loopback

**Phase 2 (3 months): Transport integration**
- Meshtastic plugin (KRD as message type)
- CC1101 sub-GHz transport profiles (KRD-Burst, KRD-Hop, KRD-Deep)
- BLE advertisement encoding
- Voice pipeline (Whisper.cpp → KRD → LoRa) demo on ESP32-S3 or RPi

**Phase 3 (6 months): Field validation**
- Meshtastic field test (range, error rates, message throughput)
- Military-relevant scenario testing (SALUTE reports, 9-Line MEDEVAC)
- Space-link simulation (simulated Mars data rates)

**Phase 4 (6+ months): Hardening & certification**
- MIL-STD-188 compliance assessment
- CCSDS (space) compatibility analysis
- FIPS 140-3 assessment for encrypted KRD payloads

---

## 9. Risk Analysis

| Risk | Severity | Mitigation |
|------|----------|------------|
| Phonetic mode ambiguity (multiple words match same color) | Medium | Constrained tactical dictionaries reduce ambiguity; full grid mode available for critical messages |
| Patent prosecution uncertainty (KANDELS application pending) | Medium | Patent published with claims; CPSC provisional provides independent protection layer |
| STT accuracy in noisy field environments | Medium | Constrained vocabulary improves STT accuracy; KRD-P tolerates STT errors (phonetic skeleton often survives word-level errors) |
| Military certification timeline | High | Long DoD acquisition cycles; mitigate with SBIR fast-track and commercial dual-use strategy |
| Meshtastic community adoption | Low | Open-source phonetic mode aligns with community ethos; KRD reduces channel congestion which benefits all users |
| Non-English language support | Medium | KANDELS is phonetic, not orthographic; adaptable to other languages with modified sound-group tables (patent references Korean language variant) |

---

## 10. The Ask

### What We're Looking For

1. **Strategic partners** with existing RF hardware platforms (LoRa, tactical radio, satellite) to integrate and validate KRD
2. **SBIR/STTR co-applicants** with DoD prime contractor relationships
3. **Seed investment** ($500K–$1M) to fund Phase 1–2 development and a field demonstration
4. **Space industry partners** (CubeSat operators, NASA centers) for space-link validation

### What We Bring

- **Patented phonetic encoding system** (KANDELS, US 2024/0248922 A1)
- **CPSC constraint projection IP** (provisional filed, BitConcepts)
- **Working KANDELS encoder** with validated RS + CPSC error correction (visual grid demo proven; RF bitstream format defined)
- **Cross-platform demo** (Windows/macOS/Linux camera-based encode/decode)
- **Deep technical team** with embedded systems, RF, and compression expertise

---

## 11. Summary: Why This Matters

Every RF link on Earth and in space faces the same fundamental constraint: bandwidth is finite, power is limited, and humans need to communicate. Voice is the natural interface but the most expensive encoding. Text is more compact but still wastes bits on redundancy that the receiver could reconstruct.

KANDELS RF Datagram sits at the intersection of linguistics and information theory: it compresses human language by exploiting **phonetic structure** — the same structure humans unconsciously use to understand speech in noisy environments. A spoken word's identity is carried primarily by its initial consonant sound. KANDELS formalizes this into a 3-bit-per-word encoding that, combined with CPSC's constraint-based error correction, creates the most bandwidth-efficient human-language messaging protocol available. For RF, the encoding is pure bitstream — no visual overhead, no wasted bytes.

**3 bytes to say what takes 33 bytes in ASCII and is impossible with voice.**

That is the value proposition.

---

## References

1. US 2024/0248922 A1 — "System and Methods for Searching Text Utilizing Categorical Touch Inputs" (Merkur), Filed Jan. 19, 2024
2. KANDELS Grid v2 Design Specification — `cpsc-engine-python/studies/kandles-block-demo/SPECIFICATION.md`
3. CPSC Specification — `docs/specification/CPSC-Specification.md`
4. Meshtastic Protocol — max payload ~228 bytes, ~1 kbps at SF11, ~5–20 B/s effective throughput
5. NASA Deep Space Network — Mars direct-to-Earth: 500–32,000 bps (Curiosity/Perseverance)
6. TI CC1101 Datasheet (SWRS061I) — Sub-1 GHz RF transceiver, 315/433/868/915 MHz, OOK/FSK/GFSK/MSK
7. Sigfox Build — 12-byte uplink payload, 140 messages/day, UNB modulation
8. Bluetooth Core Specification — BLE legacy advertisement 31-byte payload

---

**Last updated**: March 2, 2026
**Maintainer**: BitConcepts, LLC

---

KANDELS-RF-Datagram-Brief.md | © 2026 BitConcepts, LLC | Business Confidential
