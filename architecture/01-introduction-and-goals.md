# 1. Introduction and Goals

This document describes the architecture of the **Game of Life Simulator**, a small
kata application that evolves a grid according to Conway's Game of Life and shows
the result to a player. The system is implemented in Python 3.12 around one shared
Game Engine core library, with two thin interfaces: a command-line program (CLI) and
a Web UI served by a small Flask backend that calls the engine. Grids are persisted
as plain text files on the file system; there is no database.

The chapter summaries below follow the arc42 template. The existing C4 context
diagram in [`diagrams/c4-context.puml`](diagrams/c4-context.puml) gives the high-level
view, and the technology choices are already recorded in
[ADR-001](09-architecture-decisions.md#adr-001-use-python-with-a-shared-core-library-and-plain-text-grid-files).

## 1.1 Requirements Overview

### Function

The simulator applies Conway's rules to a rectangular grid of living and dead cells:

- A living cell with two or three living neighbours survives to the next generation.
- A dead cell with exactly three living neighbours becomes alive.
- Every other living cell dies.
- Every other dead cell stays dead.

Neighbours are the cells immediately surrounding a cell in the eight horizontal,
vertical and diagonal positions. The grid is fixed-size: cells outside the grid are
treated as dead, and there is no wrapping.

A grid file is plain text with one line per row. `*` means a living cell and `.`
means a dead cell. There is no header; the dimensions are taken from the content,
and all rows must have the same length. Files that do not follow this format are
rejected with a clear error message.

From these rules and the stated stack, the functional scope is:

| ID | Requirement |
| --- | --- |
| F-1 | Load a starting grid from a headerless plain text file using the `*` / `.` row format. |
| F-2 | Compute the next generation of a loaded grid using the shared Game Engine. |
| F-3 | Present a generation to the player through the CLI and through a page in the Web UI, which is served by a Flask backend calling the engine. |
| F-4 | Save a generated grid back to a plain text file in the same format. |
| F-5 | Produce identical rules behaviour in both interfaces by using the same engine. |
| F-6 | Reject invalid grid files with a clear error message instead of processing them (see ADR-001 consequences). |

The Game Engine itself performs only F-2: it has no file or user I/O. Reading,
writing and presenting grids belong to the interfaces — the CLI and the Flask-backed
Web UI.

### Scope boundaries

Still undefined and therefore out of scope until clarified: multi-player or
concurrent access, grid history/undo, and any authentication. The text file format,
edge behaviour and Web UI-to-engine connection were open in the first draft and are
now resolved in section 1.4.

## 1.2 Quality Goals

These goals follow directly from the architectural principles and ADR-001. Concrete,
measurable quality scenarios belong in Chapter 10 (Quality Requirements).

| Goal | Description | Origin |
| --- | --- | --- |
| Rules consistency | Both interfaces compute generations through the one shared engine, so the same input always yields the same output regardless of the interface used. | Shared-core principle; ADR-001 |
| Testability | The engine is free of I/O, so the rules can be unit tested in isolation and only once. | ADR-001 rationale and consequences |
| Simplicity | Choose the smallest design that meets the kata's needs and is easy to implement. | Architectural principle |
| Human-readable persistence | Grids are stored as text files that a person can create by hand and review in Git diffs; no database setup is needed. | ADR-001 rationale and consequences |

## 1.3 Stakeholders

| Role | Expectation |
| --- | --- |
| Player | Loads a starting grid, watches successive generations in the CLI or the Web UI, and can save a generation. |
| Developer / Maintainer | Implements and tests the shared engine and both interfaces, keeps the engine I/O-free, and keeps the engine's public interface stable because two clients depend on it (ADR-001). |

## 1.4 Resolved Decisions

The questions raised in the first draft of this chapter have been answered:

| # | Decision | Follow-up |
| --- | --- | --- |
| 1 | Grid files are headerless plain text: one line per row, `*` = living cell, `.` = dead cell; all rows the same length; size taken from the content; invalid files are rejected with a clear error message. | Record as ADR-002 when Chapter 9 is written. |
| 2 | Fixed-size grid; cells outside the grid are dead; no wrapping. | Record as ADR-003 when Chapter 9 is written. |
| 3 | The Web UI is served by a small Flask backend that calls the Game Engine. | Record as ADR-004 when Chapter 9 is written. Show the Web UI, Flask backend and Game Engine as separate containers in the Chapter 5 diagram. |
| 4 | Quality targets: a grid up to 100x100 produces the next generation in under 1 second, and invalid files give a clear error message. | Express as measurable quality scenarios in Chapter 10 (Quality Requirements). |
