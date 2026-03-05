# Documentation Standards for CPSC Family Projects

**Version**: 1.0
**Last Updated**: 2026-02-19
**Applies To**: All CPSC family projects (cpac-engine-python, cpsc-engine-python, etc.)

---

## Overview

This document defines the documentation standards for all CPSC family projects to ensure:
- Consistent copyright attribution
- Professional ReadTheDocs-compatible documentation
- Clear API documentation for users and developers
- Compliance with licensing requirements

---

## Copyright Headers

### Python Files

All Python files (`.py`) must include a copyright header at the top, before the module docstring:

```python
# Copyright (c) 2026 BitConcepts, LLC
# SPDX-License-Identifier: LicenseRef-CPSC-Research-Evaluation-1.0
#
# This file is part of the [PROJECT_NAME].
# For full license terms, see LICENSE in the repository root.

"""
Module docstring here.
"""
```

**Template Variables:**
- `[PROJECT_NAME]`: Replace with project name (e.g., "CPAC Engine", "CPSC Engine")
- Date range: Update start year for new files, keep 2026 as end year
- License ID: Use `LicenseRef-CPSC-Research-Evaluation-1.0` for all CPSC family projects

### Markdown Files

Documentation files (`.md`) should include copyright notice at the bottom:

```markdown
---

**[Document Name]** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0
```

### Configuration Files

For `.toml`, `.yaml`, `.json` configuration files with comments:

```toml
# Copyright (c) 2026 BitConcepts, LLC
# Licensed under CPSC Research & Evaluation License v1.0
```

---

## Module Docstrings (Python)

### Format

Use **Google-style docstrings** for Sphinx/ReadTheDocs compatibility.

### Structure

```python
"""
[One-line summary of module purpose]

[Detailed description explaining what the module does, its role in the system,
and key concepts. Multiple paragraphs are fine.]

Typical Usage Example:
    ```python
    from module import function
    result = function(arg)
    ```

Architecture:
    [Optional: Describe module's place in overall architecture]

Notes:
    [Optional: Important notes, caveats, or design decisions]

See Also:
    related_module: Brief description
    another_module: Brief description
"""
```

### Examples

**Simple Module:**
```python
"""
Entropy coding backends for CPAC compression.

This module provides the backend compression layer that performs actual
byte-level compression after CPAC's projection stages. Supports multiple
backends (ZSTD, Brotli) with automatic selection based on content analysis.
"""
```

**Complex Module with Architecture:**
```python
"""
Structural Summary Record (SSR) analysis for format detection.

The SSR module implements Stage 0 of the CPAC pipeline, analyzing input data
to determine the optimal compression track:
- Track 1: Format-aware compression (MSN + CPSC projection)
- Track 2: Generic compression (direct entropy coding)

SSR uses statistical analysis and format signatures to assess data structure
and make track decisions that maximize compression ratio.

Architecture:
    SSR is the first stage in the CPAC pipeline:
    Input Data → SSR Analysis → Track Decision → MSN (Track 1) or Direct (Track 2)

Typical Usage Example:
    ```python
    from cpac.core import ssr
    
    data = open('file.json', 'rb').read()
    result = ssr.analyze(data)
    
    if result.track == ssr.Track.TRACK_1:
        # Use MSN + CPSC
        pass
    else:
        # Use direct compression
        pass
    ```

See Also:
    msn: Stage 1 processing for Track 1 data
    framing: Final framing with SSR metadata
"""
```

---

## Class Docstrings

### Format

```python
class ClassName:
    """
    [One-line summary of class purpose]
    
    [Detailed description of what the class does, its responsibilities,
    and how it fits into the system.]
    
    Attributes:
        attr_name (type): Description of attribute.
        another_attr (type): Description of another attribute.
    
    Example:
        ```python
        obj = ClassName(arg1, arg2)
        result = obj.method()
        ```
    
    Notes:
        [Optional: Important implementation details or constraints]
    """
```

### Example

```python
class CompressResult:
    """
    Result container for compression operations.
    
    Contains compressed data, metrics, and metadata from a CPAC compression
    operation. Provides convenient properties for analyzing compression
    effectiveness.
    
    Attributes:
        data (bytes): Compressed output bytes.
        original_size (int): Size of input data in bytes.
        compressed_size (int): Size of compressed output in bytes.
        track (Track): Compression track used (TRACK_1 or TRACK_2).
        ssr_result (SSRResult | None): SSR analysis result if available.
        encrypted (bool): Whether output is encrypted.
        domain_id (str | None): Domain identifier for Track 1 compression.
    
    Example:
        ```python
        result = compress(data)
        print(f"Ratio: {result.ratio:.2f}x")
        print(f"Track: {result.track}")
        ```
    """
```

---

## Function Docstrings

### Format

```python
def function_name(arg1: Type1, arg2: Type2, *, kwarg: Type3 = default) -> ReturnType:
    """
    [One-line summary of function purpose]
    
    [Detailed description of what the function does, including any important
    behavior, side effects, or algorithmic details.]
    
    Args:
        arg1: Description of first argument.
        arg2: Description of second argument.
        kwarg: Description of keyword-only argument (default: value).
    
    Returns:
        Description of return value and its structure.
    
    Raises:
        ExceptionType: When this exception is raised.
        AnotherException: When this other exception is raised.
    
    Example:
        ```python
        result = function_name(data, config, kwarg='custom')
        ```
    
    Notes:
        [Optional: Important implementation details or performance characteristics]
    """
```

### Examples

**Simple Function:**
```python
def compress_block(data: bytes, level: int = 3) -> bytes:
    """
    Compress a single block using ZSTD.
    
    Args:
        data: Input bytes to compress.
        level: Compression level 1-22 (default: 3).
    
    Returns:
        Compressed bytes.
    
    Raises:
        ValueError: If level is out of valid range.
    """
```

**Complex Function:**
```python
def analyze(
    data: bytes,
    *,
    threshold: float = 0.7,
    filename: str | None = None,
) -> SSRResult:
    """
    Analyze data structure to determine optimal compression track.
    
    Performs statistical analysis and format detection to decide between
    Track 1 (format-aware MSN+CPSC) and Track 2 (direct compression).
    Analysis includes:
    - Format signature detection (JSON, XML, CSV, etc.)
    - Entropy analysis
    - Structural regularity assessment
    - Size-based heuristics
    
    Args:
        data: Input bytes to analyze.
        threshold: Viability threshold for Track 1 selection (0.0-1.0).
            Higher values require stronger evidence of structure.
        filename: Optional filename hint for format detection.
    
    Returns:
        SSRResult containing track decision, detected format, and analysis
        metrics.
    
    Example:
        ```python
        result = analyze(json_data, threshold=0.8)
        if result.track == Track.TRACK_1:
            print(f"Detected: {result.format_id}")
        ```
    
    Notes:
        For files <10KB, SSR may be skipped for performance.
        Threshold tuning: 0.5-0.7 for balanced, 0.8+ for conservative.
    """
```

---

## Type Annotations

### Requirements

- All function signatures must include type annotations
- Use modern Python type hints (PEP 484, 585, 604)
- Prefer `|` over `Union` (Python 3.10+)
- Use `list[T]`, `dict[K, V]` instead of `List[T]`, `Dict[K, V]`

### Examples

```python
# Good (Python 3.10+)
def process(data: bytes, config: Config | None = None) -> list[Result]:
    ...

# Avoid (old style)
from typing import Union, List, Optional
def process(data: bytes, config: Optional[Config] = None) -> List[Result]:
    ...
```

### Complex Types

```python
from typing import Protocol, TypeAlias
from collections.abc import Callable, Iterable

# Type aliases for clarity
CompressorFunc: TypeAlias = Callable[[bytes], bytes]
DataStream: TypeAlias = Iterable[bytes]

# Protocol for structural typing
class Compressor(Protocol):
    def compress(self, data: bytes) -> bytes: ...
    def decompress(self, data: bytes) -> bytes: ...
```

---

## Constants and Enums

### Constants

Document module-level constants with inline comments:

```python
# Default block size for framing (256 KB)
DEFAULT_BLOCK_SIZE: int = 256 * 1024

# SSR viability threshold for Track 1 selection
DEFAULT_VIABILITY_THRESHOLD: float = 0.7

# Maximum file size for SSR analysis (100 MB)
MAX_SSR_SIZE: int = 100 * 1024 * 1024
```

### Enums

```python
class Track(Enum):
    """
    Compression track selection.
    
    Attributes:
        TRACK_1: Format-aware compression with MSN and CPSC projection.
        TRACK_2: Direct compression without structural analysis.
    """
    TRACK_1 = 1
    TRACK_2 = 2
```

---

## Dataclasses and Structures

```python
@dataclass
class CompressConfig:
    """
    Configuration for CPAC compression operations.
    
    Controls all aspects of the compression pipeline including track selection,
    backend configuration, encryption, and optimization parameters.
    
    Attributes:
        force_track: Override SSR track decision (None for auto).
        entropy_config: Backend compression configuration.
        encryption_config: Encryption settings (None for no encryption).
        block_size: Frame block size in bytes.
        ssr_threshold: Minimum viability score for Track 1 (0.0-1.0).
        filename: Filename hint for format detection.
        use_framing: Enable self-describing frame headers.
        use_auto_cas: Enable Auto-CAS constraint projection.
        auto_cas_config: Auto-CAS specific settings.
        cas_mode: CAS engine selection ('auto_cas' or 'cpsc').
        auto_backend: Enable content-based backend selection.
        compression_priority: Optimization priority ('speed', 'balanced', 'ratio').
    
    Example:
        ```python
        config = CompressConfig(
            force_track=Track.TRACK_1,
            compression_priority='ratio',
            use_auto_cas=True,
        )
        result = compress(data, config=config)
        ```
    """
    force_track: Track | None = None
    entropy_config: EntropyConfig | None = None
    # ... rest of fields
```

---

## Error Handling Documentation

### Custom Exceptions

```python
class CPACError(Exception):
    """
    Base exception for CPAC-specific errors.
    
    All CPAC exceptions derive from this base class, allowing users to
    catch all CPAC-related errors with a single except clause.
    """

class CompressionError(CPACError):
    """
    Raised when compression operation fails.
    
    Common causes:
    - Invalid input data format
    - Backend compression failure
    - Out of memory conditions
    
    The exception message contains details about the failure mode.
    """
```

---

## README.md Structure

### Required Sections

1. **Title and Tagline**
   ```markdown
   # Project Name - One-line Description
   
   **Brief compelling description of what the project does**
   ```

2. **Badges** (optional but recommended)
   ```markdown
   [![Version](badge-url)]
   [![License](badge-url)]
   [![Python](badge-url)]
   ```

3. **Features**
   - Bullet list of key capabilities
   - Focus on user benefits

4. **Performance** (if applicable)
   - Benchmark results
   - Comparison with alternatives

5. **Installation**
   - From source instructions
   - Dependencies
   - Platform notes

6. **Quick Start**
   - Minimal working example
   - Both CLI and API usage

7. **Advanced Usage**
   - Configuration options
   - Common patterns

8. **Architecture** (brief)
   - High-level overview
   - Link to detailed docs

9. **License**
   - Clear statement of license
   - Commercial licensing info

10. **Documentation Links**
    - Contributing guide
    - Technical documentation
    - API reference

11. **Copyright Footer**
    ```markdown
    ---
    
    **Project Name vX.Y.Z** | © 2026 BitConcepts, LLC
    ```

---

## CONTRIBUTING.md Structure

### Required Sections

1. **Welcome Statement**
2. **Code of Conduct Reference**
3. **Development Setup**
   - Environment setup
   - Dependencies
   - Build/test instructions
4. **Documentation Standards** (link to this document)
5. **Code Style**
   - Formatting (Black, isort, etc.)
   - Type annotations
   - Docstring requirements
6. **Testing Requirements**
   - Coverage expectations
   - Test organization
7. **Pull Request Process**
   - Branch naming
   - Commit message format
   - Review process
8. **License Agreement**
   - Contributor acknowledgment of license terms

---

## Sphinx/ReadTheDocs Configuration

### docstring_style

Use Google style for all projects:

```python
# conf.py
napoleon_google_docstring = True
napoleon_numpy_docstring = False
```

### Recommended Extensions

```python
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.napoleon',
    'sphinx.ext.viewcode',
    'sphinx.ext.intersphinx',
    'sphinx_rtd_theme',
]
```

---

## File Organization Best Practices

### Module Structure

```
src/project_name/
├── __init__.py          # Public API exports
├── core/                # Core functionality
│   ├── __init__.py
│   ├── api.py          # Main API entry points
│   └── ...
├── domains/            # Domain-specific modules
│   ├── __init__.py
│   └── ...
├── cli.py             # Command-line interface
└── ...
```

### Documentation Structure

```
docs/
├── README.md                    # Getting started
├── DOCUMENTATION_STANDARDS.md   # This file
├── API_REFERENCE.md            # Detailed API docs
├── ARCHITECTURE.md             # System architecture
├── CONTRIBUTING.md             # Contribution guide
└── examples/                   # Usage examples
```

---

## Checklist for New Files

### Python Files

- [ ] Copyright header with correct year range
- [ ] SPDX license identifier
- [ ] Module docstring with summary and details
- [ ] All public functions documented
- [ ] All public classes documented
- [ ] Type annotations on all function signatures
- [ ] Examples in docstrings where helpful
- [ ] Sphinx-compatible format (Google style)

### Documentation Files

- [ ] Copyright notice at bottom
- [ ] Clear structure with appropriate headings
- [ ] Links to related documentation
- [ ] Code examples formatted correctly
- [ ] Updated in table of contents (if applicable)

---

## Examples by File Type

### API Module (`api.py`)

```python
# Copyright (c) 2026 BitConcepts, LLC
# SPDX-License-Identifier: LicenseRef-CPSC-Research-Evaluation-1.0
#
# This file is part of the CPAC Engine.
# For full license terms, see LICENSE in the repository root.

"""
CPAC Public API: compress and decompress entry points.

This module provides the main public interface for CPAC compression with
a simple, high-level API suitable for most use cases.

The compression pipeline follows CPAC v1.0 architecture:
1. Stage 0: SSR (Structural Summary Record) - decides Track 1 vs Track 2
2. Stage 1: MSN (Merkur Semantic Normalization) - Track 1 only
3. Stage 2: CPSC projection - Track 1 only  
4. Stage 3: Entropy coding

Typical Usage Example:
    ```python
    from cpac import compress, decompress
    
    # Compress data
    result = compress(b"Hello, World!" * 1000)
    print(f"Ratio: {result.ratio:.2f}x")
    
    # Decompress
    original = decompress(result.data)
    assert original.data == b"Hello, World!" * 1000
    ```

See Also:
    cpac.core.ssr: Structural analysis
    cpac.core.msn: Format-aware extraction
    cpac.core.framing: Output framing
"""

from dataclasses import dataclass
from typing import BinaryIO

# ... rest of implementation
```

### Utility Module (`utils.py`)

```python
# Copyright (c) 2026 BitConcepts, LLC
# SPDX-License-Identifier: LicenseRef-CPSC-Research-Evaluation-1.0
#
# This file is part of the CPAC Engine.
# For full license terms, see LICENSE in the repository root.

"""
Utility functions for CPAC compression.

Provides helper functions for data manipulation, metrics calculation,
and common operations used across the CPAC codebase.
"""

def calculate_entropy(data: bytes) -> float:
    """
    Calculate Shannon entropy of byte data.
    
    Entropy measures the randomness/compressibility of data, with
    0.0 being perfectly compressible (all same byte) and 8.0 being
    incompressible random data.
    
    Args:
        data: Input bytes to analyze.
    
    Returns:
        Entropy value in bits per byte (0.0-8.0).
    
    Example:
        ```python
        entropy = calculate_entropy(b"aaaa")  # ~0.0
        entropy = calculate_entropy(os.urandom(100))  # ~8.0
        ```
    """
    # ... implementation
```

---

## Maintenance

This document should be:
- Reviewed annually or when Python/Sphinx versions change
- Updated when new patterns emerge in the codebase
- Referenced in CONTRIBUTING.md for all projects
- Applied consistently across all CPSC family repositories

---

**DOCUMENTATION_STANDARDS.md** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0
