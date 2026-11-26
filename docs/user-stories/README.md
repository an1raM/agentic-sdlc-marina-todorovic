# User Stories

This directory contains user stories derived from the Game of Life Simulator architecture in `architecture/` (chapters 01-12, ADR-001-ADR-006, C4 and sequence diagrams). Stories follow Domain-Driven Design bounded contexts and are prioritized with Pareto analysis.

## Domains

| Domain | Bounded context | Architecture references |
|---|---|---|
| `ENGINE` | Shared Game Engine core library: Grid Model, Grid Text Codec, Rules Engine; I/O-free parsing/formatting and next-generation computation. | `architecture/04-solution-strategy.md` §4.1-4.3; `architecture/05-building-block-view.md` §5.1, §5.3.1; ADR-001, ADR-002, ADR-003 |
| `CLI` | Command-line interface: Command Handler, Grid File I/O, Terminal Presenter; direct engine calls and terminal/file I/O. | `architecture/05-building-block-view.md` §5.2, §5.3.2; `architecture/06-runtime-view.md` §6.1, §6.3.1, §6.4; ADR-001 |
| `WEB` | Web interface: Web UI page and Flask backend (HTTP Request Handler, Engine Adapter, Grid File I/O, Page Renderer); browser holds current grid text, Flask reads/writes `grids/` only on load/save. | `architecture/05-building-block-view.md` §5.2, §5.3.3, §5.3.4; `architecture/06-runtime-view.md` §6.2, §6.3.2, §6.4; `architecture/07-deployment-view.md`; ADR-004, ADR-005, ADR-006 |

## Pareto Analysis

- **Total stories:** 11
- **Core (Pareto 20%):** 2 stories (~18%, nearest to 20%) expected to deliver ~80% of simulation value.
- **Core rationale:** The shared engine rules and grid text codec are the highest-dependency, highest-value foundations. Every CLI and Web flow depends on correct generation computation and consistent grid parsing/formatting/validation.

## Story Inventory

| ID | Title | Domain | Priority | Status | File | Core reason |
|---|---|---|---|---|---|---|
| `ENGINE-STORY-001` | Compute next generation with Conway's rules on a fixed-size grid | ENGINE | Core (Pareto 20%) | Written | [`engine.md`](engine.md) | Foundational simulation value: all advance/display flows depend on correct rule computation; exercises Rules Engine and Grid Model across interfaces (F-2, F-5, Q-1, Q-2, Q-5). |
| `ENGINE-STORY-002` | Parse, validate, and format grid text in the agreed plain-text format | ENGINE | Core (Pareto 20%) | Written | [`engine.md`](engine.md) | Foundational data contract: all load/save/display/error flows depend on one codec for parsing, formatting, and validation (F-1, F-4, F-6, Q-3, Q-4, Q-6). |
| `CLI-STORY-001` | Load and display a starting grid in the CLI | CLI | Supporting | Not written yet | - | - |
| `CLI-STORY-002` | Advance to the next generation in the CLI | CLI | Supporting | Not written yet | - | - |
| `CLI-STORY-003` | Save the current generation from the CLI | CLI | Supporting | Not written yet | - | - |
| `CLI-STORY-004` | Show a clear error for an invalid grid file in the CLI | CLI | Supporting | Not written yet | - | - |
| `WEB-STORY-001` | Load a named grid file in the Web UI | WEB | Supporting | Not written yet | - | - |
| `WEB-STORY-002` | Advance to the next generation in the Web UI | WEB | Supporting | Not written yet | - | - |
| `WEB-STORY-003` | Save the current generation from the Web UI | WEB | Supporting | Not written yet | - | - |
| `WEB-STORY-004` | Show a clear error for an invalid grid file in the Web UI | WEB | Supporting | Not written yet | - | - |
| `WEB-STORY-005` | Reject invalid Web UI file names with a clear error | WEB | Supporting | Not written yet | - | - |

## Pareto Progress

Pareto Progress: 2/2 core stories (100%)

Core functionality coverage: ~80% of the 80% target

## Open Points Carried Forward

These are architecture-open points; stories must not invent behavior for them:

- Q-2 performance verification has no specified reference hardware or measurement method (`architecture/10-quality-requirements.md` §10.3).
- "Clear error message" wording is not specified (`architecture/10-quality-requirements.md` §10.3).
- ADR-002 format edge cases such as empty grid files are not fully specified (`architecture/11-risks-and-technical-debts.md` R-4).
- Deployment specifics such as OS, ports, browser support, and packaging are not specified (`architecture/07-deployment-view.md` §7.3).
