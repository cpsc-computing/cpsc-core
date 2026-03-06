# Constraint-Projected Music Structure Analysis for Vibe-Matching — Concept Paper

**Version**: 0.1 (Concept Draft)
**Date**: March 2026
**Author**: BitConcepts, LLC
**Classification**: Business Confidential — Pre-Release
**Status**: Exploratory concept — not yet implemented

---

## Abstract

Current music recommendation systems rely on collaborative filtering ("people who liked X also liked Y") or manual tagging (Pandora's Music Genome Project). Neither approach models the structural relationships that define what listeners experience as a song's "vibe." This paper proposes applying Constraint-Projected State Computing (CPSC) to music structure analysis: extracting audio features from a reference track, expressing the desired vibe as a declarative constraint model in CAS-YAML, and using the CPSC-RE projection engine to find songs where all structural constraints are jointly satisfied. The result is a deterministic, explainable, composable vibe-matching system that operates on music structure — not social signals or subjective tags.

This concept represents a potential new embodiment of the CPSC computing model (U.S. Provisional Patent Application No. 63/980,251, filed February 11, 2026) applied to audio signal analysis and music information retrieval.

---

## 1. The Problem: Recommendation Is Not Understanding

### 1.1 How Music Recommendation Works Today

The two dominant approaches to music recommendation share a fundamental limitation: neither actually analyzes what makes a song *feel* like another song.

**Collaborative filtering** (Spotify, Apple Music, YouTube Music) models user behavior: listening history, skip rates, playlist co-occurrence, and social graph overlap. When Spotify recommends a song, it is saying "users with similar listening patterns also listened to this." It is not saying "this song has similar structural properties to what you're listening to." This approach fails systematically in several ways:

- **Cold start**: New releases and niche tracks have no behavioral data to learn from
- **Popularity bias**: Well-known tracks dominate recommendations regardless of structural fit
- **Genre imprisonment**: Cross-genre vibe matches (a jazz track with the same groove as an electronic track) are invisible to collaborative filtering
- **Opacity**: No explanation is possible beyond "similar listeners liked this"

**Manual tagging** (Pandora Music Genome Project) addresses some of these limitations by having trained musicologists annotate ~450 attributes per song. This produces better structural matching but is:

- **Expensive**: Each song requires trained human analysis
- **Subjective**: Different musicologists may tag differently
- **Unscalable**: The Music Genome Project has analyzed ~2 million songs; Spotify's catalog exceeds 100 million
- **Static**: Tags don't capture dynamic structural relationships (how attributes interact over the course of a song)

### 1.2 What "Vibe" Actually Is

When a listener says "I want more songs with this vibe," they are describing a constraint system, not a point in feature space. A vibe is defined by **relationships between structural properties**:

- A fast tempo + sparse arrangement = "chill groove"
- A fast tempo + dense arrangement = "high energy"
- Same tempo. Completely different vibe.

The vibe is not in any single feature — it is in the **joint satisfaction of multiple structural constraints**. This is precisely what CPSC is designed to evaluate.

### 1.3 Why Vector Distance Fails

The standard Music Information Retrieval (MIR) approach computes a feature vector per song and uses cosine similarity or k-nearest-neighbors to find similar tracks. This fails for vibe-matching because:

1. **Feature independence assumption**: Vector distance treats each feature as an independent dimension. But vibe is about conditional relationships — tempo matters differently depending on arrangement density, harmonic complexity, and vocal presence.

2. **No hard boundaries**: Vector distance produces a smooth gradient. But some vibe distinctions are categorical: a mellow acoustic vibe should never return a death metal track, regardless of how close the tempo and key are. There is no distance threshold that captures this without also excluding valid matches.

3. **No composability**: A listener cannot say "take this vibe but make it instrumental" by modifying a distance metric. They can by adding a constraint.

4. **No explainability**: A distance score of 0.73 tells you nothing about *why* two songs are similar or different.

---

## 2. The Proposed Solution: Constraint-Projected Vibe Matching

### 2.1 Core Concept

CPSC vibe-matching inverts the recommendation model:

```
TRADITIONAL:    Song → Feature Vector → Distance → Ranked List
CPSC:           Song → Feature Extraction → Constraint Model → Projection → Playlist
```

A reference song is analyzed to extract structural features. These features define a constraint model — the "vibe specification." Every candidate song in the catalog is evaluated by the CPSC-RE projection engine against all constraints jointly. Songs that converge to a valid projected state are included in the playlist. Soft constraints rank them.

The constraint model is the artifact: machine-executable, human-readable, version-controlled, composable, and deterministic.

### 2.2 Feature Extraction Layer

Audio features are extracted using established MIR tooling (librosa, essentia, madmom) and modern source separation (Demucs/HTDemucs). Features fall into eight categories:

**Temporal**
- Tempo (BPM) and tempo stability
- Time signature
- Beat grid regularity
- Swing ratio (straight vs. shuffled feel)

**Spectral**
- Spectral centroid (perceived brightness)
- Spectral flux (rate of timbral change)
- Frequency band energy distribution (sub-bass / bass / mid / presence / air)
- Spectral rolloff (frequency below which N% of energy is concentrated)

**Harmonic**
- Key and mode (major / minor / modal)
- Chord progression complexity (unique chords per section)
- Harmonic rhythm (chord change rate)
- Tonal tension curve (tension/resolution pattern over time)

**Rhythmic**
- Groove template (onset pattern per bar, extracted from percussion)
- Syncopation index
- Percussive density (hits per beat)
- Rhythmic repetition period (how often the groove pattern repeats)

**Dynamic**
- Loudness contour (energy curve across song sections)
- Dynamic range (peak-to-average loudness ratio)
- Compression profile (perceived loudness consistency)

**Arrangement**
- Instrument density over time (number of active layers per section)
- Arrangement arc (sparse → dense → sparse progression)
- Intro/outro length ratio
- Section structure (verse/chorus/bridge pattern)
- Vocal presence ratio (percentage of song with vocals)

**Vocal** (when vocals are present)
- Vocal register (bass / baritone / tenor / alto / soprano range)
- Melodic contour shape (ascending / descending / static patterns)
- Lyrical density (syllables per beat)
- Phonetic rhythm pattern (consonant/vowel flow — potential KANDELS application)

**Psychoacoustic**
- Perceived energy (composite of tempo, loudness, spectral flux)
- Perceived warmth (low-mid frequency balance)
- Perceived space (reverb amount, stereo width)
- Perceived complexity (information density per unit time)

### 2.3 Structural Decomposition via Source Separation

Raw feature extraction on a mixed audio signal captures aggregate statistics. Source separation (Demucs, HTDemucs) decomposes a track into constituent layers — drums, bass, vocals, and other instruments — enabling analysis of how these layers interact over time.

This is the difference between:
- "These two songs have similar average spectral centroids" (aggregate)
- "These two songs build tension the same way: sparse drums + bass foundation, then harmony enters at the same structural point, then vocals and texture layer in with the same density curve" (structural)

The **interaction network** between separated sources — when they enter, exit, how they modulate each other, their phase relationships — provides the arrangement's skeleton. Two songs can share an arrangement skeleton while differing in genre, instrumentation, and surface-level sound.

### 2.4 Vibe as a CAS-YAML Constraint Model

A vibe specification is expressed in CAS-YAML, the same declarative constraint format used across all CPSC applications:

```yaml
version: 1.0.0
model_id: vibe_late_night_drive

state:
  variables:
    # Reference song features (fixed — the vibe anchor)
    - name: ref_bpm
      type: float
      role: fixed
    - name: ref_energy
      type: float
      role: fixed
    - name: ref_groove_template
      type: vector
      role: fixed
    - name: ref_spectral_centroid
      type: float
      role: fixed
    - name: ref_vocal_presence
      type: float
      role: fixed
    - name: ref_arrangement_arc
      type: vector
      role: fixed

    # Candidate song features (external — runtime inputs)
    - name: cand_bpm
      type: float
      role: external
    - name: cand_energy
      type: float
      role: external
    - name: cand_groove_template
      type: vector
      role: external
    - name: cand_spectral_centroid
      type: float
      role: external
    - name: cand_vocal_presence
      type: float
      role: external
    - name: cand_arrangement_arc
      type: vector
      role: external

    # Decision variables (free — what the engine determines)
    - name: include_in_playlist
      type: bool
      domain: [true, false]
      role: free
    - name: match_score
      type: float
      role: derived

constraints:
  # === Hard Constraints (non-negotiable vibe boundaries) ===

  - id: tempo_range
    type: hard
    expression: "abs(cand_bpm - ref_bpm) / ref_bpm <= 0.12"
    description: "Tempo within ±12% of reference"

  - id: energy_floor
    type: hard
    expression: "cand_energy >= ref_energy * 0.75"
    description: "Energy must not drop below 75% of reference"

  - id: energy_ceiling
    type: hard
    expression: "cand_energy <= ref_energy * 1.30"
    description: "Energy must not exceed 130% of reference"

  - id: mode_compatibility
    type: hard
    expression: "cand_mode in compatible_modes(ref_mode)"
    description: "Key/mode must be emotionally compatible"

  # === Conditional Constraints (relationship-dependent) ===

  - id: vocal_presence_match
    type: hard
    expression: "if ref_vocal_presence > 0.5 then cand_vocal_presence > 0.3"
    description: "If reference has vocals, candidate should too"

  - id: lyrical_flow_match
    type: soft
    objective: minimize
    expression: >
      if ref_vocal_presence > 0.5
      then abs(cand_syllables_per_beat - ref_syllables_per_beat)
    description: "Match lyrical flow rate when vocals present"

  # === Soft Constraints (ranked preferences) ===

  - id: groove_similarity
    type: soft
    objective: maximize
    expression: "correlation(cand_groove_template, ref_groove_template)"
    description: "Maximize rhythmic groove similarity"

  - id: spectral_shape_match
    type: soft
    objective: minimize
    expression: "euclidean(cand_band_energy, ref_band_energy)"
    description: "Minimize timbral distance"

  - id: arrangement_arc_match
    type: soft
    objective: maximize
    expression: "correlation(cand_arrangement_arc, ref_arrangement_arc)"
    description: "Similar build/release structure over time"

  - id: warmth_match
    type: soft
    objective: minimize
    expression: "abs(cand_warmth - ref_warmth)"
    description: "Similar perceived warmth"
```

This is not pseudo-code. This is the specification format consumed by the CPSC-RE projection engine — the same engine used for compliance enforcement, access control, and all other CPSC applications.

### 2.5 Composable Vibe Profiles

CAS-YAML's file inclusion and override semantics enable layered vibe construction:

```yaml
includes:
  - vibes/late-night-drive.yaml       # base vibe from a reference song
  - overlays/instrumental-only.yaml   # remove vocal requirement
  - overlays/prefer-analog-warmth.yaml # bias toward warm, analog timbres
  - overlays/higher-energy.yaml       # shift energy constraints up 20%
```

Users compose vibes the way compliance engineers compose regulatory frameworks — by layering base models with overlays. A "late-night drive" base vibe can be modified to "late-night drive but instrumental and warmer" without rebuilding the constraint model from scratch.

### 2.6 Projection and Playlist Generation

For each candidate song in the catalog:

1. **Extract features** (pre-computed and indexed)
2. **Bind** candidate features to External variables in the constraint model
3. **Project** — the CPSC-RE engine evaluates all constraints jointly
4. **Accept/Reject** — hard constraint violations reject the candidate; soft constraints compute a match score
5. **Rank** — accepted candidates are ordered by composite soft constraint satisfaction
6. **Transcript** — every accept/reject decision is recorded with full constraint evaluation detail

The result: a deterministic playlist where every included song provably satisfies all vibe constraints, ranked by structural similarity, with a complete explanation for every inclusion and exclusion.

---

## 3. KANDELS Application: Phonetic Lyrical Analysis

The KANDELS phonetic encoding system (US 2024/0248922 A1) provides a novel approach to lyrical vibe-matching. Lyrics that *sound* similar often *feel* similar, independent of semantic meaning — this is a well-known property of songwriting (alliteration, assonance, and consonant patterns contribute to a song's feel).

KANDELS maps the leading consonant sound of each word to a 3-bit symbol index (7 sound groups). Applied to lyrics:

- Extract the phonetic symbol sequence of a song's lyrics
- Compare phonetic rhythm patterns between songs (consonant density, vowel flow, alliterative frequency)
- Match the *sonic texture* of lyrics, not their meaning
- Two songs with similar phonetic patterns will have similar lyrical "mouth feel" — an underappreciated dimension of vibe

This is a direct extension of KANDELS from its original text-encoding application to audio-domain phonetic pattern analysis.

---

## 4. Differentiation from Existing Systems

### 4.1 vs. Spotify / Apple Music (Collaborative Filtering)

| Property | Collaborative Filtering | CPSC Vibe-Matching |
|----------|------------------------|-------------------|
| What it analyzes | User behavior (listens, skips, playlists) | Song structure (audio features, arrangement) |
| Cold start problem | Severe — new songs have no data | None — features extracted from audio directly |
| Cross-genre matching | Poor — genre silos from user behavior | Native — structure-based, genre-agnostic |
| Explainability | "Similar listeners liked this" | "Groove correlation 0.87, tempo within 8%, arrangement arc correlation 0.79" |
| Determinism | No — session-dependent randomization | Yes — same inputs, same playlist, always |
| User control | Thumbs up/down, skip | Modify constraint parameters, add/remove overlays |

### 4.2 vs. Pandora Music Genome Project (Manual Tagging)

| Property | Music Genome Project | CPSC Vibe-Matching |
|----------|---------------------|-------------------|
| Feature source | Human musicologist annotation | Automated audio feature extraction |
| Cost per song | $$$$ (trained analyst time) | Compute only (seconds per song) |
| Scalability | ~2M songs analyzed | Entire catalogs (100M+) feasible |
| Subjectivity | Analyst-dependent | Deterministic extraction |
| Relationship modeling | Independent attribute tags | Joint constraint satisfaction |
| Composability | Not user-modifiable | Layered CAS-YAML profiles |

### 4.3 vs. Standard MIR (Vector Distance)

| Property | Feature Vector + k-NN | CPSC Vibe-Matching |
|----------|----------------------|-------------------|
| Feature relationships | Independent dimensions | Joint constraints with conditionals |
| Hard boundaries | Smooth distance only | Hard + soft constraints |
| Composability | Fixed distance metric | Layered, overridable constraint models |
| Explainability | Distance score (opaque) | Per-constraint evaluation detail |
| Conditional logic | Not expressible | Native ("if vocals present, then match flow rate") |

---

## 5. Technical Feasibility

### 5.1 Component Readiness

| Component | Status | Difficulty |
|-----------|--------|-----------|
| Audio feature extraction (tempo, key, spectral) | Mature — librosa, essentia, madmom | Low |
| Beat/groove template extraction | Well-studied MIR problem | Low–Medium |
| Arrangement density / segmentation | Active research, good tools (MSAF, librosa) | Medium |
| Source separation (vocals/drums/bass/other) | State of art — Demucs, HTDemucs | Low (off-the-shelf) |
| CAS-YAML vibe constraint models | New — requires defining "vibe vocabulary" | Medium |
| CPSC-RE projection over music features | Direct application of existing engine | Low |
| KANDELS lyrical phonetic analysis | Novel extension of existing encoding | Medium |
| Structural interaction network analysis | Novel — needs definition and validation | Medium–High |
| Scalable indexing (millions of songs) | Pre-compute features; project on demand | Medium |

### 5.2 Proof-of-Concept Path

A minimal viable demonstration could be built with existing technology:

1. **Corpus**: 1,000–5,000 songs with genre diversity
2. **Feature extraction**: librosa + Demucs, pre-computed and stored
3. **Vibe profiles**: 5–10 hand-authored CAS-YAML constraint models covering distinct vibes (late-night drive, workout energy, rainy afternoon, deep focus, summer cookout)
4. **Engine**: Existing Python CPSC-RE reference implementation
5. **Evaluation**: Blind A/B test against Spotify Radio playlists from the same seed songs
6. **Timeline**: 2–4 weeks with existing tooling

### 5.3 Scaling Considerations

- Feature extraction: ~5–15 seconds per song on commodity hardware; parallelizable
- Feature storage: ~2–5 KB per song (compressed feature vectors); 100M songs = 200–500 GB
- Projection: sub-millisecond per candidate on the Python engine; microseconds on Rust
- Real-time use case: Pre-filter by cheap features (tempo, key), then project against full constraint model on the reduced set

---

## 6. Intellectual Property Considerations

### 6.1 Existing Coverage

U.S. Provisional Patent Application No. 63/980,251 covers the CPSC computing model broadly, including constraint projection as the primary computation mechanism, CAS-YAML as the specification format, and the software/hardware engine architecture. The broad claims on constraint-projected state evaluation may extend to audio feature matching as an application domain.

### 6.2 Potential Additional Claims

A music/audio-specific embodiment could strengthen the non-provisional filing with claims targeting:

- Constraint-projected audio feature matching for music recommendation
- Declarative vibe specification as a CAS-YAML constraint model
- Composable vibe profiles via constraint model layering
- Phonetic lyrical pattern analysis using KANDELS encoding for music similarity
- Structural arrangement network analysis for cross-genre vibe matching
- Deterministic, explainable playlist generation via constraint projection transcripts

### 6.3 KANDELS Extension

The KANDELS patent (US 2024/0248922 A1) covers phonetic-to-symbol mapping. Applying this encoding to lyrical analysis in music represents a novel application that could be documented as an extension of the existing IP.

---

## 7. Market Context

### 7.1 Music Streaming Market

The global music streaming market exceeds $40 billion annually and is growing ~10% CAGR. Recommendation quality is a primary competitive differentiator — Spotify, Apple Music, Amazon Music, YouTube Music, and Tidal all invest heavily in recommendation systems.

### 7.2 Potential Applications

- **Consumer music platforms**: Vibe-based playlist generation as a feature or API
- **Content licensing**: Match music to video/film/advertising moods programmatically
- **Music production**: Analyze arrangement structure to inform songwriting and production decisions
- **DJ/live performance**: Automated setlist construction based on structural flow constraints
- **Sync licensing**: Match songs to visual content based on structural constraints (tempo to edit pace, energy to scene intensity)
- **Music therapy**: Evidence-based playlist construction using measurable structural properties

### 7.3 Business Model Options

1. **API/SaaS**: Vibe-matching engine as a service for music platforms ($X per M projections)
2. **Technology licensing**: License to streaming platforms as a recommendation engine component
3. **Standalone product**: Consumer-facing "vibe playlist" application
4. **B2B sync licensing tool**: Constraint-based music search for film/TV/advertising

---

## 8. Summary

Music recommendation today is built on social signals (collaborative filtering) or expensive human judgment (manual tagging). Neither approach models the structural relationships that define a listener's experience of "vibe." CPSC provides the missing mechanism: a vibe is a constraint system over audio structure variables, and constraint projection finds songs where all structural relationships are jointly satisfied.

The technical components are largely mature: audio feature extraction, source separation, and beat analysis are well-established fields. The novel contribution is the constraint projection layer — expressing vibe as a declarative, composable, machine-executable specification and using deterministic projection to generate explainable, reproducible playlists.

**A vibe is not a point in feature space. It is a region defined by structural constraints. CPSC finds everything in that region.**

---

## References

1. U.S. Provisional Patent Application No. 63/980,251, *Constraint-Projected State Computing Systems, Semantic System Specification, and Applications*, filed February 11, 2026
2. US 2024/0248922 A1 — "System and Methods for Searching Text Utilizing Categorical Touch Inputs" (Merkur/KANDELS), Filed Jan. 19, 2024
3. CPSC Specification — `docs/specification/CPSC-Specification.md`
4. CAS-YAML Specification v1.0.0 — `docs/specification/CAS-YAML-Specification.md`
5. McFee, B. et al. — librosa: Audio and Music Signal Analysis in Python
6. Défossez, A. et al. — Hybrid Transformers for Music Source Separation (HTDemucs)
7. Nieto, O. & Bello, J. P. — Music Segment Similarity and Structure (MSAF)
8. Spotify Engineering Blog — recommendation system architecture
9. Pandora Media — The Music Genome Project methodology

---

**Last updated**: March 2026
**Maintainer**: BitConcepts, LLC

---

CPSC-Music-Vibe-Matching-Concept.md | © 2026 BitConcepts, LLC | Business Confidential
