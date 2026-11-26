# 11. Risks and Technical Debts

The repository contains architecture documentation and tooling but no implementation
yet, so there is no code-level technical debt to report. The items below are
design-level risks and explicitly accepted trade-offs that follow from the decisions
in Chapters 1, 4 and 9, plus the remaining open points recorded in Chapters 7, 8, 10
and 11. The former Chapter 6 open point is resolved by ADR-005.

## 11.1 Risks

| ID | Risk | Impact | Status |
| --- | --- | --- | --- |
| R-1 | The Web UI holds the current grid only in the browser (ADR-005). | Unsaved changes are lost if the page is reloaded or closed; the player must save explicitly to keep a generation. | Accepted consequence |
| R-2 | The engine's public interface must stay stable because both the CLI and the Flask backend depend on it (ADR-001). | A change to parsing or generation signatures requires updating both clients and re-running shared tests. | Accepted and monitored |
| R-3 | The performance target (100x100 under 1 second) has no specified hardware or measurement method (Chapter 10). | Q-2 cannot be verified consistently; a passing local run may not be reproducible elsewhere. | Open |
| R-4 | Some format edge cases are not specified, for example how an empty grid file should be treated (ADR-002 defines rows of `*` and `.` but not emptiness). | The codec implementation could make different assumptions than the player expects. | Open |
| R-5 | A fixed-size grid with dead cells outside clips patterns that reach an edge (ADR-003). | A player may interpret clipped patterns as incorrect rules behaviour unless the boundary rule is explained. | Accepted consequence |
| R-6 | No logging concept is defined (Chapter 8). | Diagnosing failures in the Flask backend or CLI may rely only on the error shown to the player. | Accepted for the kata |
| R-7 | Operating system, ports, packaging and browser support are not specified (Chapters 2 and 7). | Deployment instructions cannot be made concrete, and the Web UI may behave differently across browsers. | Open |
| R-8 | The wording of a "clear error message" is not specified (Chapter 10). | The CLI and Web UI could present inconsistent or unhelpful messages even though both reject the file. | Open |

## 11.2 Technical Debts

| ID | Debt | Origin | Proposed handling |
| --- | --- | --- | --- |
| TD-2 | ADR-001 still says the Web UI-to-engine connection "must be decided separately", although ADR-004 and ADR-005 now decide it. | ADR-001 was kept unchanged as an existing historical record. | Readers should follow ADR-004 and ADR-005; update ADR-001 only if the project allows revising accepted ADRs. |
| TD-3 | The timing target has no reproducible measurement setup. | Chapter 1 decision 4 and Chapter 10, Q-2. | Agree a simple, documented measurement method before verifying performance. |
| TD-4 | No logging mechanism exists. | No logging requirement was given; Chapter 8 leaves it open. | Add logging in the interfaces only if a real need appears; keep it out of the engine. |

## 11.3 Accepted Trade-offs

These are deliberate consequences of the architecture, not debts to be repaid:

- **No database, history, concurrency control or authentication** (ADR-001, Chapter 1). A database would add cost the kata does not need; if such requirements appear later, the storage design must change.
- **File I/O appears in both the CLI and the Flask backend.** This duplication is accepted to keep the engine I/O-free and testable; the Grid Text Codec still centralises the format.
- **The engine is a library, not a service.** Both clients load it in-process, which avoids a network hop but means each client must use the same Python environment.
- **The Flask backend adds an HTTP hop for Web UI users** that CLI users do not have (ADR-004).
- **The browser holds the current grid and no server-side session exists** (ADR-005). This keeps Flask simple and avoids file I/O on the next-generation path, at the cost of losing unsaved work on reload.
- **Web UI file names are restricted to letters, digits, hyphens, underscores and `.txt` inside `grids/`** (ADR-006). Names outside this form are rejected, which limits usability but keeps file access bounded.

## 11.4 Resolved Items

- **Former R-9 / TD-1 — Web UI file-name validation:** resolved by ADR-006. Only
  `^[A-Za-z0-9_-]+\.txt$` names are accepted, invalid names produce a clear error,
  and Web UI load and save touch only `grids/`. Chapter 10, Q-7 covers the observable
  behaviour.
