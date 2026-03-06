# VibeProject — A Constraint-Projected Music Recommendation Engine

**Version**: 0.1 (Draft)
**Date**: March 2026
**Author**: BitConcepts, LLC
**Classification**: Business Confidential — Pre-Release

---

## Abstract

VibeProject is a music recommendation engine that understands what makes songs *feel* alike — not by tracking what other listeners played, but by analyzing the structural DNA of music itself. It extracts audio features from a reference track, expresses the resulting "vibe" as a machine-executable constraint model, and uses a deterministic projection engine to find every song in a catalog that jointly satisfies those structural constraints.

The result: playlists that are structurally correct, not socially guessed. Every recommendation is explainable, deterministic, composable, and genre-agnostic.

VibeProject is powered by two patented technologies from BitConcepts, LLC:
- **CPSC** (Constraint-Projected State Computing) — U.S. Provisional Patent Application No. 63/980,251, filed February 11, 2026
- **KANDELS** (phonetic encoding system) — US 2024/0248922 A1

---

## 1. The Problem: Music Recommendation Is Broken

### 1.1 Nobody Recommends by Structure

When you find a song that perfectly captures a mood — a late-night drive, a rainy afternoon, the energy of a packed room — and ask for more like it, every music platform gives you the same thing: songs that *other people* also listened to. Not songs that are structurally similar. Not songs that share the same groove, the same build, the same tension-and-release arc. Songs that share *listeners*.

This is collaborative filtering, and it powers Spotify, Apple Music, YouTube Music, and Amazon Music. It works well enough for mainstream tastes. It fails everywhere else:

- **New and niche tracks** have no listening data — the cold-start problem means the best match in the catalog might never surface
- **Cross-genre vibe matches** are invisible — a jazz trio track with the same groove as an electronic track will never be recommended because the listener pools don't overlap
- **Popularity dominates** — well-known tracks are recommended regardless of structural fit
- **No explanation** — the system cannot tell you *why* it recommended a song, only that similar listeners played it

Pandora's Music Genome Project tried to fix this by having trained musicologists tag ~450 attributes per song. Better — but expensive ($$$$ per song), subjective (analyst-dependent), unscalable (~2 million songs tagged vs. 100 million+ in modern catalogs), and still treats attributes as independent tags rather than structural relationships.

### 1.2 What a "Vibe" Actually Is

When a listener says "I want more songs with this vibe," they're not describing a list of independent attributes. They're describing a **constraint system** — a set of structural relationships that must all hold simultaneously:

- Fast tempo + sparse arrangement = "chill groove"
- Fast tempo + dense arrangement = "high energy"
- Same tempo. Completely different vibe.

The vibe lives in the *relationships between* features, not in any single feature. A mellow acoustic track and a death metal track can share the same tempo and key. No distance metric catches this. Constraints do.

### 1.3 Why Existing Approaches Can't Solve This

| Approach | What It Actually Does | Why It Fails for Vibe |
|----------|----------------------|----------------------|
| Collaborative filtering (Spotify) | Correlates listener behavior | Doesn't analyze music structure at all |
| Manual tagging (Pandora) | Human-assigned attribute labels | Expensive, subjective, doesn't capture relationships |
| Feature vector + k-NN (standard MIR) | Computes distance in feature space | Treats features independently; no conditional logic |
| AI/ML embeddings | Learns latent representations | Black box; non-deterministic; unexplainable |

None of these can express: "If the reference track has vocals, the candidate must also have vocals AND match the lyrical density AND the melodic contour should correlate." That's a conditional, joint constraint — and it's how humans actually think about vibe.

---

## 2. How VibeProject Works

### 2.1 The Engine

VibeProject inverts the recommendation model:

```
TRADITIONAL:    Song → Feature Vector → Distance → Ranked List
VIBEPROJECT:    Song → Feature Extraction → Constraint Model → Projection → Playlist
```

1. **Analyze** a reference song to extract 30+ structural features across eight dimensions
2. **Generate** a constraint model — the "vibe specification" — from those features
3. **Project** every candidate song against all constraints *jointly* using the CPSC-RE engine
4. **Accept** songs where all hard constraints are satisfied; **rank** by soft constraint optimization
5. **Explain** every inclusion and exclusion with per-constraint evaluation detail

The constraint model is the core artifact: machine-executable, human-readable, version-controlled, composable, and deterministic. Same reference song + same constraints = same playlist. Always.

### 2.2 What Gets Analyzed

Audio features are extracted using established tooling (librosa, essentia, Demucs) and organized into eight structural dimensions:

**Temporal** — Tempo (BPM), tempo stability, time signature, swing ratio

**Spectral** — Brightness (spectral centroid), timbral change rate (spectral flux), frequency band energy distribution across sub-bass / bass / mid / presence / air

**Harmonic** — Key, mode (major/minor/modal), chord progression complexity, harmonic rhythm, tonal tension curve over time

**Rhythmic** — Groove template (onset pattern per bar), syncopation index, percussive density, rhythmic repetition period

**Dynamic** — Loudness contour across sections, dynamic range, compression profile

**Arrangement** — Instrument density over time, arrangement arc (how the song builds and releases), section structure, vocal presence ratio

**Vocal** — Vocal register, melodic contour shape, lyrical density (syllables per beat), phonetic rhythm pattern

**Psychoacoustic** — Perceived energy, warmth, space (reverb/stereo width), complexity

### 2.3 Source Separation: Understanding the Arrangement

VibeProject doesn't just analyze the mixed signal — it decomposes each track into its constituent layers (drums, bass, vocals, other instruments) using state-of-the-art source separation (HTDemucs). This enables structural analysis of *how the arrangement works*:

- When each layer enters and exits
- How layers interact and modulate each other over time
- The arrangement's skeleton — its build/release pattern independent of specific instruments

This is the difference between "these songs have similar average brightness" and "these songs build tension the same way: drums and bass lay a sparse foundation, harmony enters at the same structural point, then vocals and texture layer in with the same density curve."

Two songs can share an arrangement skeleton while differing completely in genre, instrumentation, and surface-level sound. VibeProject finds these cross-genre vibe matches that no other system can.

### 2.4 The Vibe Specification

A vibe is expressed as a constraint model in CAS-YAML — the same declarative format used across all CPSC applications:

```yaml
version: 1.0.0
model_id: vibe_late_night_drive

constraints:
  # === Hard: non-negotiable vibe boundaries ===
  - id: tempo_range
    type: hard
    expression: "abs(candidate.bpm - reference.bpm) / reference.bpm <= 0.12"
    description: "Tempo within ±12% of reference"

  - id: energy_envelope
    type: hard
    expression: "candidate.energy between reference.energy * 0.75 and reference.energy * 1.30"
    description: "Energy stays within 75–130% of reference"

  - id: mode_compatibility
    type: hard
    expression: "candidate.mode in compatible_modes(reference.mode)"
    description: "Key/mode must be emotionally compatible"

  # === Conditional: relationship-dependent ===
  - id: vocal_match
    type: hard
    expression: "if reference.vocal_presence > 0.5 then candidate.vocal_presence > 0.3"
    description: "If reference has vocals, candidate should too"

  - id: lyrical_flow
    type: soft
    objective: minimize
    expression: >
      if reference.vocal_presence > 0.5
      then abs(candidate.syllables_per_beat - reference.syllables_per_beat)
    description: "Match lyrical flow rate when vocals are present"

  # === Soft: ranked preferences ===
  - id: groove_match
    type: soft
    objective: maximize
    expression: "correlation(candidate.groove_template, reference.groove_template)"
    description: "Maximize rhythmic groove similarity"

  - id: arrangement_arc
    type: soft
    objective: maximize
    expression: "correlation(candidate.arrangement_arc, reference.arrangement_arc)"
    description: "Similar build/release structure"

  - id: timbral_distance
    type: soft
    objective: minimize
    expression: "euclidean(candidate.band_energy, reference.band_energy)"
    description: "Minimize timbral distance"

  - id: warmth
    type: soft
    objective: minimize
    expression: "abs(candidate.warmth - reference.warmth)"
    description: "Similar perceived warmth"
```

This is not pseudo-code. This is the actual specification consumed by the engine.

### 2.5 Composable Vibe Profiles

Users build vibes by layering constraint profiles — the same way a chef builds a flavor profile by layering ingredients:

```yaml
includes:
  - vibes/late-night-drive.yaml         # base vibe from a reference song
  - overlays/instrumental-only.yaml     # drop the vocal requirement
  - overlays/prefer-analog-warmth.yaml  # bias toward warm, vintage timbres
  - overlays/higher-energy.yaml         # shift energy constraints up 20%
```

"Late-night drive but instrumental and warmer" is a three-line overlay, not a new recommendation algorithm. Vibes are modular, shareable, and version-controlled.

### 2.6 Every Decision Is Explainable

When VibeProject rejects a song, it tells you exactly why:

```
REJECTED: "Track X" by Artist Y
  ✗ tempo_range: candidate BPM 142 exceeds reference 98 by 44.9% (limit: 12%)
  ✗ energy_envelope: candidate energy 0.91 exceeds ceiling 0.78 (130% of ref 0.60)
  ✓ mode_compatibility: C major compatible with A minor (relative major)
  ✓ groove_match: correlation 0.72
```

When it accepts a song, it tells you *how well* it matches:

```
ACCEPTED: "Track Z" by Artist W — match score: 0.87
  ✓ tempo_range: 94 BPM vs 98 BPM reference (4.1%, within 12%)
  ✓ energy_envelope: 0.58 within [0.45, 0.78]
  ✓ groove_match: correlation 0.84
  ✓ arrangement_arc: correlation 0.79
  ✓ warmth: delta 0.06
```

No other recommendation engine can do this. Spotify cannot tell you why it recommended a song. VibeProject can tell you why it recommended *or rejected* every song in the catalog.

---

## 3. KANDELS: Phonetic Lyrical Analysis

VibeProject includes a novel lyrical analysis layer powered by the KANDELS phonetic encoding system (US 2024/0248922 A1).

Lyrics that *sound* similar often *feel* similar, independent of what they mean. Alliteration, assonance, consonant patterns, and vowel flow contribute to a song's feel in ways that semantic analysis misses entirely. KANDELS captures this by mapping each word's leading consonant sound to a 3-bit symbol index across 7 sound groups.

Applied to lyrics, KANDELS enables:
- Extraction of the phonetic symbol sequence of a song's lyrics
- Comparison of phonetic rhythm patterns between songs (consonant density, vowel flow, alliterative frequency)
- Matching the *sonic texture* of lyrics — how they feel in the mouth and ear — not their dictionary meaning

Two songs with similar KANDELS phonetic patterns will have similar lyrical "feel" regardless of topic, language register, or vocabulary. This is an underappreciated dimension of vibe that no existing recommendation system addresses.

---

## 4. Why VibeProject Is Different

### 4.1 vs. Spotify / Apple Music

| | Spotify | VibeProject |
|---|---------|------------|
| **Analyzes** | Listener behavior | Song structure |
| **Cold start** | Can't recommend unknown songs | Analyzes audio directly — no listening data needed |
| **Cross-genre** | Trapped in genre silos | Genre-agnostic — matches structural skeleton |
| **Explainability** | None | Per-constraint evaluation for every song |
| **Determinism** | Randomized per session | Same inputs → same playlist, always |
| **User control** | Thumbs up/down | Modify constraint parameters, layer overlays |

### 4.2 vs. Pandora Music Genome Project

| | Pandora | VibeProject |
|---|---------|------------|
| **Feature source** | Human musicologist annotation | Automated audio extraction |
| **Cost per song** | $$$$ (trained analyst) | Seconds of compute |
| **Catalog scale** | ~2M songs | 100M+ feasible |
| **Relationships** | Independent attribute tags | Joint constraint satisfaction |
| **Composability** | Not user-modifiable | Layered, shareable vibe profiles |

### 4.3 vs. AI/ML Embedding Models

| | ML Embeddings | VibeProject |
|---|--------------|------------|
| **Transparency** | Black box latent space | Human-readable constraint model |
| **Determinism** | Model-dependent, non-reproducible | Mathematically deterministic |
| **Conditional logic** | Not expressible | Native ("if vocals present, then...") |
| **User modification** | Retrain the model | Edit one constraint |
| **Audit trail** | None | Full projection transcript |

---

## 5. Technical Architecture

### 5.1 Pipeline

```
┌──────────────┐    ┌──────────────────┐    ┌──────────────────┐
│  Reference   │───>│  Feature          │───>│  Vibe Constraint │
│  Song        │    │  Extraction       │    │  Model (CAS-YAML)│
└──────────────┘    │  (librosa/Demucs) │    └────────┬─────────┘
                    └──────────────────┘             │
                                                     ▼
┌──────────────┐    ┌──────────────────┐    ┌──────────────────┐
│  Candidate   │───>│  Pre-computed     │───>│  CPSC-RE         │
│  Catalog     │    │  Feature Index    │    │  Projection      │
└──────────────┘    └──────────────────┘    │  Engine          │
                                             └────────┬─────────┘
                                                      │
                                             ┌────────▼─────────┐
                                             │  Ranked Playlist │
                                             │  + Transcripts   │
                                             └──────────────────┘
```

### 5.2 Component Stack

| Layer | Technology | Status |
|-------|-----------|--------|
| Audio feature extraction | librosa, essentia, madmom | Mature, open-source |
| Source separation | HTDemucs (Meta) | State-of-the-art, open-source |
| Beat/groove analysis | madmom, librosa | Well-established |
| Arrangement segmentation | MSAF, librosa | Active research, good tools |
| Lyrical phonetic analysis | KANDELS (patented) | Encoding proven; music application novel |
| Constraint specification | CAS-YAML v1.0.0 (patented) | Published, stable |
| Projection engine | CPSC-RE (patented) | Python ref impl working; Rust in development |
| Transcript/audit | CPSC-RE Epoch Scheduler | Specified, implemented |

### 5.3 Performance at Scale

- **Feature extraction**: ~5–15 seconds per song; parallelizable, run once per catalog
- **Feature storage**: ~2–5 KB per song (compressed); 100M songs = 200–500 GB
- **Projection**: Sub-millisecond per candidate (Python); microseconds (Rust)
- **Real-time workflow**: Pre-filter by cheap features (tempo, key), then project full constraint model on the reduced set
- **Playlist generation**: <1 second for a 1,000-song catalog; <10 seconds for 100K with pre-filtering

---

## 6. Product Applications

### 6.1 Consumer Playlist Engine

The primary application: a listener plays a song, VibeProject generates a playlist of songs that structurally match the vibe. Available as:
- Standalone mobile/web app
- API integration for existing music platforms
- Plugin for DJ software

### 6.2 Sync Licensing & Music Supervision

Film, TV, and advertising music supervisors search for songs that match a scene's mood. VibeProject translates scene requirements into structural constraints: tempo to match edit pace, energy to match scene intensity, arrangement arc to match narrative beat. Deterministic, explainable results replace hours of subjective searching.

### 6.3 Music Production & A&R

Producers and A&R teams analyze arrangement structure to understand *why* certain songs work. VibeProject's structural decomposition reveals the skeleton beneath the surface — informing production decisions, identifying market gaps, and discovering structurally similar reference tracks across genres.

### 6.4 DJ & Live Performance

Automated setlist construction based on structural flow constraints: energy curves, key compatibility, groove template continuity. Build a 2-hour set that follows a declared energy arc with smooth structural transitions — not just BPM matching.

### 6.5 Music Therapy

Evidence-based playlist construction using measurable structural properties. Define therapeutic constraint profiles (calming, energizing, focus-inducing) with specific tempo, dynamic range, and arrangement density parameters. Reproducible, auditable playlists for clinical settings.

---

## 7. Market Opportunity

### 7.1 Market Size

The global music streaming market exceeds **$40 billion annually** (growing ~10% CAGR). Recommendation quality is a primary competitive differentiator — Spotify, Apple Music, Amazon Music, YouTube Music, and Tidal all invest heavily in recommendation R&D.

The sync licensing market (film/TV/advertising) exceeds **$5 billion annually**, with music search and discovery as a major cost center.

The DJ/production tools market exceeds **$1 billion annually** and is growing with the creator economy.

### 7.2 Business Model

1. **API/SaaS** — Vibe-matching engine as a service for music platforms. Per-projection or per-seat pricing. Primary revenue stream.
2. **Technology licensing** — License the engine to streaming platforms as a recommendation component. Enterprise contracts.
3. **Standalone consumer app** — Direct-to-consumer vibe playlist application. Freemium model.
4. **B2B sync licensing tool** — Constraint-based music search for film/TV/advertising professionals. Subscription pricing.
5. **Production/DJ tools** — Structural analysis plugins for DAWs and DJ software. Per-license.

---

## 8. Intellectual Property

### 8.1 Patent Coverage

**CPSC** — U.S. Provisional Patent Application No. 63/980,251 (*Constraint-Projected State Computing Systems, Semantic System Specification, and Applications*), filed February 11, 2026. Covers the constraint projection computing model, CAS-YAML specification format, and the software/hardware engine architecture. The broad claims on constraint-projected state evaluation extend to audio feature matching as an application domain.

**KANDELS** — US 2024/0248922 A1 (*System and Methods for Searching Text Utilizing Categorical Touch Inputs*), filed January 19, 2024. Covers the phonetic-to-symbol encoding system. Application to lyrical phonetic analysis in music represents a novel extension of this IP.

### 8.2 Defensible Claims

VibeProject's IP position combines:
1. **The engine**: Constraint projection as the recommendation mechanism — not a solver invoked after-the-fact, but the way candidate evaluation occurs
2. **The specification**: CAS-YAML vibe models as portable, composable, machine-executable constraint systems over audio features
3. **The lyrical layer**: KANDELS phonetic encoding applied to lyrical pattern matching
4. **The transcript**: Deterministic, replayable, explainable evaluation of every recommendation decision

Competitors would need to independently develop a constraint projection engine, a declarative audio constraint specification format, and a phonetic lyrical analysis system — then make them work together. The dual-patent moat (CPSC + KANDELS) makes this difficult to design around.

---

## 9. Proof-of-Concept Plan

A minimal viable demonstration:

1. **Corpus**: 1,000–5,000 songs with genre diversity (public domain or licensed catalog)
2. **Feature extraction**: librosa + HTDemucs, pre-computed and indexed
3. **Vibe profiles**: 5–10 hand-authored CAS-YAML constraint models covering distinct vibes (late-night drive, workout energy, rainy afternoon, deep focus, summer cookout)
4. **Engine**: Existing Python CPSC-RE reference implementation
5. **Evaluation**: Blind A/B test against Spotify Radio playlists generated from the same seed songs — human evaluators rate "vibe match" quality
6. **Timeline**: 2–4 weeks with existing tooling
7. **Success criteria**: VibeProject playlists rated as equal or better vibe match in ≥60% of blind comparisons

---

## 10. Summary

Music recommendation has been solved for popularity. It has not been solved for *vibe*.

VibeProject is the first recommendation engine that models vibe as what it actually is: a joint constraint system over music structure. It analyzes the structural DNA of a reference track — tempo, groove, arrangement arc, spectral shape, vocal characteristics, lyrical phonetics — and finds every song in a catalog that jointly satisfies those structural constraints. No social signals. No black-box embeddings. No subjective tags.

Every recommendation is deterministic, explainable, composable, and genre-agnostic. Users describe vibes in constraints, not keywords. Playlists are structurally correct, not socially guessed.

**A vibe is not a point in feature space. It is a region defined by structural constraints. VibeProject finds everything in that region.**

---

## References

1. U.S. Provisional Patent Application No. 63/980,251, *Constraint-Projected State Computing Systems, Semantic System Specification, and Applications*, filed February 11, 2026
2. US 2024/0248922 A1 — "System and Methods for Searching Text Utilizing Categorical Touch Inputs" (Merkur/KANDELS), Filed Jan. 19, 2024
3. CAS-YAML Specification v1.0.0 — `docs/specification/CAS-YAML-Specification.md`
4. McFee, B. et al. — librosa: Audio and Music Signal Analysis in Python
5. Défossez, A. et al. — Hybrid Transformers for Music Source Separation (HTDemucs)
6. Nieto, O. & Bello, J. P. — Music Segment Similarity and Structure (MSAF)

---

**Last updated**: March 2026
**Maintainer**: BitConcepts, LLC

---

CPSC-Music-Vibe-Matching-Concept.md | © 2026 BitConcepts, LLC | Business Confidential
