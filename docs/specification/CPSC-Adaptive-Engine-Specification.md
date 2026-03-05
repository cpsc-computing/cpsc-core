# CPSC Adaptive Engine Specification
## Unified Engine with Auto-Detection of Optimal Solving Strategy

**Version:** 1.0  
**Status:** Draft Specification  
**Published:** February 15, 2026  

---

## License Notice

This specification is released under the **CPSC Research & Evaluation License**.

It may be used, shared, and cited for non-commercial research, evaluation, and educational purposes.
Commercial use, production deployment, or implementation in commercial systems requires a separate license.

The technology described herein may be subject to patent protection.
All rights are reserved.

---

## 1. Overview

The **AdaptiveEngine** is a meta-engine that analyzes CAS models and automatically selects the optimal solving strategy (Iterative vs Cellular) based on constraint structure. It provides a single, unified API while internally delegating to specialized engines.

### 1.1 Goals

1. **Automatic strategy selection** — Analyze constraint graph, detect structure, choose engine
2. **CAS-YAML hints** — Allow manual override via `projection.strategy` field (default: `auto`)
3. **Backward compatibility** — Existing `engine='iterative'` and `engine='cellular'` still work
4. **Diagnostics** — Return which strategy was chosen and why in `ProjectionResult.details`

### 1.2 Normative References

This specification depends on and must remain consistent with:

| Document | Scope | Key Interfaces |
|----------|-------|----------------|
| `CPSC-Specification.md` | Core CPSC model | §5 Projection, §6 Determinism |
| `CAS-YAML-Specification.md` | Constraint model format | §10 Projection Config |
| `CPSC-Engine-Modes-Specification.md` | Engine implementations | §3 Iterative, §4 Cellular |

---

## 2. CAS-YAML Schema Extensions

### 2.1 New `projection.strategy` Field

Add optional `strategy` field to the `projection` section:

```yaml
projection:
  method: gradient              # Existing: solving method
  strategy: auto                # NEW: engine strategy selection
  max_iterations: 100
  convergence_epsilon: 1e-6
```

### 2.2 Valid Strategy Values

| Value | Behavior |
|-------|----------|
| `auto` (default) | Analyze constraint graph, auto-detect structure |
| `iterative` | Force Iterative engine (global constraint evaluation) |
| `cellular` | Force Cellular engine (local grid-based rules) |
| `hybrid` | Reserved for future: mix strategies per constraint group |

### 2.3 Backward Compatibility

- **If `projection.strategy` is missing**: Default to `auto`
- **If `projection` section is missing**: Default to `auto` with standard parameters
- **Existing models work unchanged**: `auto` will detect their structure correctly

### 2.4 Example Models

#### Auto-detection (Global Constraints)
```yaml
version: 1.0
model_id: numeric_array_auto

projection:
  method: gradient
  strategy: auto               # Will detect global → Iterative
  max_iterations: 100
  convergence_epsilon: 1e-6

constraints:
  - expression: sum == count * (2 * base + (count - 1) * delta) / 2
```

#### Forced Cellular (Grid Problem)
```yaml
version: 1.0
model_id: grid_diffusion

projection:
  method: local_rules
  strategy: cellular           # Force Cellular engine
  max_iterations: 50
  convergence_epsilon: 1e-8

constraints:
  - expression: cell[i] == (cell[i-1] + cell[i+1]) / 2  # Neighbor deps
```

---

## 3. API Design

### 3.1 Public Interface

```python
from cpsc import solve, load_cas_model
from cpsc.solvers import AdaptiveEngine

# Option 1: Use high-level solve() API
model = load_cas_model('model.yaml')
result = solve(model, dof_values)  # Auto-detects strategy

# Option 2: Direct engine instantiation
engine = AdaptiveEngine()
result = engine.solve(model, dof_values)

# Option 3: Force a strategy (override CAS-YAML)
result = solve(model, dof_values, engine='adaptive', strategy='iterative')
```

### 3.2 AdaptiveEngine Class

```python
class AdaptiveEngine:
    """Meta-engine that auto-selects Iterative or Cellular strategy.
    
    Per CPSC-Adaptive-Engine-Specification.md:
    - Analyzes constraint graph structure
    - Detects locality patterns (grid vs global)
    - Delegates to IterativeEngine or CellularEngine
    - Respects CAS-YAML projection.strategy hints
    """
    
    def __init__(
        self,
        force_strategy: Literal["auto", "iterative", "cellular"] | None = None,
        enable_diagnostics: bool = True,
    ):
        """Initialize AdaptiveEngine.
        
        Args:
            force_strategy: Override auto-detection (default: None = use CAS-YAML)
            enable_diagnostics: Include strategy selection reasoning in result.details
        """
        self.force_strategy = force_strategy
        self.enable_diagnostics = enable_diagnostics
        self._iterative = IterativeEngine()
        self._cellular = CellularEngine()
    
    def solve(
        self,
        model: CasModel,
        dof_values: Sequence[float],
        max_iterations: int | None = None,
    ) -> ProjectionResult:
        """Solve using auto-detected or hinted strategy."""
        # 1. Determine strategy
        strategy = self._determine_strategy(model)
        
        # 2. Delegate to appropriate engine
        if strategy == "iterative":
            result = self._iterative.solve(model, dof_values, max_iterations)
        elif strategy == "cellular":
            result = self._cellular.solve(model, dof_values, max_iterations)
        else:
            raise EngineError(f"Unknown strategy: {strategy}")
        
        # 3. Add diagnostics
        if self.enable_diagnostics:
            result.details["adaptive_strategy"] = strategy
            result.details["adaptive_reason"] = self._last_reason
        
        return result
    
    def _determine_strategy(self, model: CasModel) -> str:
        """Determine solving strategy from CAS-YAML hint or auto-detection."""
        # Priority 1: Force override (API level)
        if self.force_strategy and self.force_strategy != "auto":
            self._last_reason = f"Forced via API: {self.force_strategy}"
            return self.force_strategy
        
        # Priority 2: CAS-YAML hint
        if model.projection and hasattr(model.projection, 'strategy'):
            yaml_strategy = model.projection.strategy
            if yaml_strategy and yaml_strategy != "auto":
                self._last_reason = f"CAS-YAML hint: {yaml_strategy}"
                return yaml_strategy
        
        # Priority 3: Auto-detection
        return self._auto_detect_strategy(model)
    
    def _auto_detect_strategy(self, model: CasModel) -> str:
        """Analyze constraint structure and select optimal strategy."""
        graph = ConstraintGraph.from_model(model)
        
        # Heuristics for strategy selection (see §4)
        if graph.has_grid_locality():
            self._last_reason = "Grid locality detected (neighbor dependencies)"
            return "cellular"
        elif graph.is_sparse_linear():
            self._last_reason = "Sparse linear system (few constraint interactions)"
            return "iterative"
        elif graph.has_global_constraints():
            self._last_reason = "Global constraints detected (all variables interact)"
            return "iterative"
        else:
            # Default fallback
            self._last_reason = "Default: general-purpose iterative"
            return "iterative"
```

---

## 4. Constraint Graph Analysis

### 4.1 ConstraintGraph Class

```python
@dataclass
class ConstraintGraph:
    """Dependency graph of variables and constraints.
    
    Nodes: Variables (free + derived)
    Edges: Constraint dependencies (var appears in constraint)
    """
    nodes: Set[str]                    # Variable names
    edges: Dict[str, Set[str]]         # var -> {vars it depends on}
    constraints: List[ConstraintInfo]  # Parsed constraint metadata
    
    @classmethod
    def from_model(cls, model: CasModel) -> 'ConstraintGraph':
        """Build constraint graph from CAS model."""
        nodes = set()
        edges = defaultdict(set)
        constraints = []
        
        for constraint in model.constraints:
            info = cls._parse_constraint(constraint)
            constraints.append(info)
            
            # Add dependencies: lhs depends on all vars in rhs
            for var in info.rhs_vars:
                edges[info.lhs_var].add(var)
                nodes.add(var)
            nodes.add(info.lhs_var)
        
        return cls(nodes=nodes, edges=dict(edges), constraints=constraints)
    
    def has_grid_locality(self) -> bool:
        """Detect if constraints have grid-like neighbor patterns.
        
        Returns True if:
        - Constraints reference neighbors (cell[i±1], cell[j±1])
        - Variables form 1D chain or 2D mesh topology
        - Most dependencies are local (1-2 hops)
        """
        # Check for neighbor patterns in constraint expressions
        neighbor_patterns = [
            r'cell\[i\s*[+-]\s*1\]',     # 1D: cell[i±1]
            r'cell\[i\]\[j\s*[+-]\s*1\]', # 2D: cell[i][j±1]
            r'\w+_(left|right|up|down)',  # Named neighbors
        ]
        
        neighbor_count = 0
        for constraint in self.constraints:
            expr = constraint.expression
            if any(re.search(pat, expr) for pat in neighbor_patterns):
                neighbor_count += 1
        
        # If >50% of constraints reference neighbors → grid locality
        return neighbor_count / len(self.constraints) > 0.5
    
    def is_sparse_linear(self) -> bool:
        """Detect if constraint graph is sparse and linear.
        
        Returns True if:
        - Each variable depends on few others (avg degree < 5)
        - No cyclic dependencies
        """
        if not self.edges:
            return False
        
        avg_degree = sum(len(deps) for deps in self.edges.values()) / len(self.edges)
        return avg_degree < 5
    
    def has_global_constraints(self) -> bool:
        """Detect if constraints involve many variables.
        
        Returns True if:
        - Any constraint references >30% of total variables
        - Or: avg constraint fan-in > 10 variables
        """
        n_vars = len(self.nodes)
        
        for constraint in self.constraints:
            n_refs = len(constraint.rhs_vars)
            if n_refs > n_vars * 0.3:
                return True
        
        avg_refs = sum(len(c.rhs_vars) for c in self.constraints) / len(self.constraints)
        return avg_refs > 10

@dataclass
class ConstraintInfo:
    """Metadata about a single constraint."""
    lhs_var: str              # Variable being defined/constrained
    rhs_vars: Set[str]        # Variables referenced in RHS expression
    expression: str           # Full constraint expression
    is_definition: bool       # True if "var = expr", False if "lhs == rhs"
```

### 4.2 Detection Heuristics

| Pattern | Strategy | Reason |
|---------|----------|--------|
| >50% constraints reference neighbors (`cell[i±1]`) | `cellular` | Grid locality detected |
| Avg constraint fan-in < 5 variables | `iterative` | Sparse linear system |
| Any constraint references >30% of variables | `iterative` | Global coupling |
| Cyclic dependencies | `iterative` | Needs global solver |
| Default (no clear pattern) | `iterative` | Safe general-purpose fallback |

---

## 5. Determinism Requirements

Per CPSC-Specification.md §6:

- Given identical CAS model, DoF values, and configuration, AdaptiveEngine MUST produce identical results
- Strategy selection MUST be deterministic (same model always selects same strategy)
- Diagnostics MUST NOT affect computation results

---

## 6. Test Requirements

### 6.1 Required Test Cases

1. **`test_auto_detects_iterative_for_global_constraints`**
   - Model: `sum == count * (...)`  (all vars interact)
   - Expected: Strategy = "iterative"

2. **`test_auto_detects_cellular_for_grid_constraints`**
   - Model: `cell[i] == (cell[i-1] + cell[i+1]) / 2`
   - Expected: Strategy = "cellular"

3. **`test_yaml_hint_overrides_auto_detection`**
   - Model: Global constraint but `strategy: cellular`
   - Expected: Strategy = "cellular" (respects hint)

4. **`test_api_force_overrides_yaml_hint`**
   - Model: `strategy: iterative` in YAML
   - API: `AdaptiveEngine(force_strategy='cellular')`
   - Expected: Strategy = "cellular" (API wins)

5. **`test_diagnostics_explain_strategy_choice`**
   - Verify `result.details['adaptive_strategy']` and `adaptive_reason` present

6. **`test_backward_compatibility_missing_strategy`**
   - Model: No `projection.strategy` field
   - Expected: Defaults to `auto`, works correctly

---

## 7. Priority Levels

### P0 (Must Have - MVP)
- AdaptiveEngine class with `_determine_strategy()`
- CAS-YAML schema: `projection.strategy` field
- Auto-detection: Simple heuristics (grid vs global)
- Tests: Basic strategy selection

### P1 (Should Have)
- ConstraintGraph full analysis
- Diagnostics in ProjectionResult.details
- Comprehensive test coverage

### P2 (Nice to Have)
- Advanced heuristics (sparse linear detection)
- Performance profiling (which strategy is faster)
- Visualization of constraint graph

---

## 8. Example Usage

### 8.1 Auto-Detection (User Doesn't Care)
```python
from cpsc import load_cas_model, solve

model = load_cas_model('numeric_array.yaml')
result = solve(model, [10.0, 5.0, 1.0])  # Auto-detects iterative

print(result.details['adaptive_strategy'])  # "iterative"
print(result.details['adaptive_reason'])    # "Global constraints detected"
```

### 8.2 CAS-YAML Hint
```yaml
# model.yaml
version: 1.0
model_id: force_cellular

projection:
  method: local_rules
  strategy: cellular           # Force cellular even if auto would choose iterative
  max_iterations: 32
```

```python
model = load_cas_model('model.yaml')
result = solve(model, dof_values)

print(result.details['adaptive_strategy'])  # "cellular"
print(result.details['adaptive_reason'])    # "CAS-YAML hint: cellular"
```

### 8.3 API Override
```python
from cpsc.solvers import AdaptiveEngine

# Force iterative regardless of model structure or YAML hints
engine = AdaptiveEngine(force_strategy='iterative')
result = engine.solve(model, dof_values)

print(result.details['adaptive_strategy'])  # "iterative"
print(result.details['adaptive_reason'])    # "Forced via API: iterative"
```

---

## 9. Conformance

### 9.1 Mandatory Requirements

An implementation claiming conformance to this specification MUST:

1. Implement the AdaptiveEngine class with the public interface defined in §3
2. Support all strategy values defined in §2.2
3. Respect the priority order: API override > CAS-YAML hint > auto-detection
4. Produce deterministic strategy selection for identical inputs
5. Maintain backward compatibility per §2.3

### 9.2 Optional Features

Implementations MAY:

1. Implement additional detection heuristics beyond those in §4.2
2. Support the `hybrid` strategy value
3. Provide performance metrics comparing strategy choices
4. Implement caching of strategy decisions for repeated solves

---

## 10. References

| Document | Description |
|----------|-------------|
| `CPSC-Specification.md` | Core CPSC computation model |
| `CAS-YAML-Specification.md` | Constraint model format |
| `CPSC-Engine-Modes-Specification.md` | Iterative and Cellular engine implementations |
| `Binary-Format-Specification.md` | DSIF binary format |

---

**CPSC-Adaptive-Engine-Specification.md** | © 2026 BitConcepts, LLC | Licensed under CPSC Research & Evaluation License v1.0
