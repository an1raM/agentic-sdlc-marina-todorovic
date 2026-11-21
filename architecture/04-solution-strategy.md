# 4. Solution Strategy

This chapter describes the overall approach chosen to satisfy the requirements and
constraints of Chapters 1–3. It introduces no new requirements; the building blocks
named here are detailed in Chapter 5 and the significant choices are recorded as ADRs
in Chapter 9.

## 4.1 Fundamental Solution Approach

1. **One source of truth for the rules.** All generation steps are computed by the
   shared Game Engine core library. Both the CLI and the Flask-backed Web UI call it,
   so the same input produces the same output in either interface.
2. **I/O-free engine with text at its edges.** The engine works on in-memory grid
   data. It parses grid text into that representation and formats a grid back to
   text, but it never reads a file, writes a file, prints to a terminal or renders a
   page. Those operations belong to the interfaces. This follows ADR-001, which puts
   the rules *and grid parsing* in the engine while keeping file I/O out of it.
3. **Thin interfaces.** The CLI handles terminal input/output and grid files. The
   Web UI is a page served by a small Flask backend; the backend accepts browser
   requests, calls the engine and accesses grid files. No rules logic is placed in
   the browser or duplicated in either interface.
4. **Text files as the only persistence.** Grids are stored in the format fixed in
   Chapter 1 (headerless rows of `*` and `.`, equal row lengths, size from content).
   Files that do not match the format are rejected with a clear message to the
   player. No database or schema is introduced.
5. **Fixed-size grid with a simple boundary rule.** The grid never changes size;
   neighbours outside it count as dead and there is no wrapping. This keeps the step
   calculation straightforward.
6. **Simplicity first, decisions recorded.** Prefer the smallest design that meets
   the kata's needs. Each significant choice is captured as an ADR rather than left
   implicit in the code.

## 4.2 Top-Level Decomposition

| Building block | Responsibility | Detailed in |
| --- | --- | --- |
| Game Engine core library | In-memory grid representation, parsing and formatting of grid text, and computation of the next generation under Conway's rules. No I/O. | Chapter 5 |
| CLI | Reads/writes grid files, calls the engine, renders grids and error messages in the terminal. | Chapter 5 |
| Flask backend | Serves the Web UI page, translates browser requests into engine calls, reads/writes grid files and reports errors. | Chapter 5 (as a container between Web UI and engine) |
| Web UI page | Presents a grid and lets the player load, advance and save generations through the backend. | Chapter 5 |
| Grid text files | External plain-text storage for starting grids and saved generations. | Chapters 3 and 5 |

The engine is a library used by both interfaces, not a running service. The Flask
backend is the only server-side process; it is a thin adapter around the engine.

## 4.3 Strategy to Achieve the Quality Goals

| Quality goal (Chapter 1) | How the strategy addresses it |
| --- | --- |
| Rules consistency | A single engine implements the rules; neither interface reimplements them, so CLI and Web UI results cannot diverge. |
| Testability | The engine has no I/O, so it can be unit tested directly on in-memory grids; only a small amount of file and presentation logic remains in the interfaces. |
| Simplicity | Few building blocks, no database, no browser-side rule engine, no concurrency or multi-user machinery; Flask is the only framework added. |
| Human-readable persistence | The fixed `*` / `.` text format produces files that can be written by hand and reviewed in Git diffs; parsing and formatting are shared in the engine. |
| Performance and clear errors (100x100 under 1 second; invalid files reported clearly) | A direct per-cell computation over a fixed-size grid avoids unnecessary work, and format validation happens when the grid text is parsed, with the resulting error surfaced by the interface. These targets become measurable scenarios in Chapter 10. |

## 4.4 Decision Management

ADR-001 already records the Python/shared-engine/text-file choices. The three
decisions made after Chapter 1 are to be written as ADR-002 (grid file format),
ADR-003 (fixed-size grid boundaries) and ADR-004 (Flask backend) when Chapter 9 is
reached. The Flask layer will appear as a distinct container in the Chapter 5
diagram, as agreed.
