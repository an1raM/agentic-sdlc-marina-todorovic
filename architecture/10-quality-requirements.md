# 10. Quality Requirements

This chapter turns the quality goals from Chapter 1 and the targets confirmed after
Chapter 1 into observable quality scenarios. No numeric targets are added beyond the
one given: a grid up to 100x100 produces the next generation in under 1 second.

## 10.1 Quality Tree

| Quality goal | Aspect | Source | Priority |
| --- | --- | --- | --- |
| Rules consistency | Same input yields the same generation in the CLI and the Web UI. | Chapter 1; ADR-001 | Not specified |
| Performance | Next generation for a grid up to 100x100 in under 1 second. | Chapter 1 decision 4 | Not specified |
| Robustness | Invalid grid files are rejected with a clear error message. | Chapter 1 F-6 and decision 4; ADR-002 | Not specified |
| Input validation | Invalid Web UI file names are rejected with a clear error; only `grids/` is accessed. | ADR-006 | Not specified |
| Testability | The rules can be unit tested in isolation, without I/O. | Chapter 1; ADR-001 | Not specified |
| Simplicity | The smallest design that meets the kata's needs. | Chapter 1; architectural principles | Not specified |
| Human-readable persistence | Grids are stored as plain text that can be read and diffed by a person. | Chapter 1; ADR-001 and ADR-002 | Not specified |

No relative priorities between these goals were specified in the available material,
so none are assumed here.

## 10.2 Quality Scenarios

### Q-1: Identical Rules Behaviour Across Interfaces

- **Stimulus:** The player requests the next generation for the same valid grid, once
  through the CLI and once through the Web UI.
- **Source:** Player, through either interface.
- **Environment:** CLI and Flask backend each using the shared Game Engine library.
- **Response:** Both interfaces present the same resulting grid.
- **Measure:** Cell-by-cell comparison of the two displayed generations shows no
  difference.

### Q-2: Generation Time for a Large Grid

- **Stimulus:** The player requests the next generation for a valid grid of up to
  100x100 cells.
- **Source:** Player, through either interface.
- **Environment:** Simulator host with the Python 3.12 runtime; no specific hardware
  or measurement setup was specified.
- **Response:** The next generation is computed and presented.
- **Target:** Under 1 second for a grid up to 100x100.

### Q-3: Invalid Grid File Handling

- **Stimulus:** The player asks to load a grid file that violates the agreed format,
  for example a row with a disallowed character or rows of unequal length.
- **Source:** Player, through either interface.
- **Environment:** CLI or Web UI with the shared Grid Text Codec.
- **Response:** The player sees a clear error message, and the invalid file is not
  processed as a grid.
- **Measure:** An error message is visible in the terminal or on the served page and
  no generation is computed from the invalid file. The exact wording of the message
  is not specified.

### Q-4: Isolated Engine Testing

- **Stimulus:** A developer tests the rules and grid text codec.
- **Source:** Developer.
- **Environment:** Unit tests using in-memory grid data only.
- **Response:** Tests run without files, terminal output or HTTP requests.
- **Measure:** The engine tests require no I/O setup; any file or presentation logic
  stays in the interfaces.

### Q-5: Single Implementation of the Rules

- **Stimulus:** A developer changes a rule.
- **Source:** Developer.
- **Environment:** Game Engine core library used by both interfaces.
- **Response:** The change is made in the engine and applies to both the CLI and the
  Web UI.
- **Measure:** Only one implementation of the rules exists in the codebase.

### Q-6: Human-Readable Saved Grids

- **Stimulus:** A developer or player opens a saved grid file.
- **Source:** Developer or player.
- **Environment:** File System with plain text files.
- **Response:** The file shows one headerless row per line using `*` and `.`, with all
  rows the same length.
- **Measure:** The file conforms to the format fixed in ADR-002 and can be reviewed
  with a normal text diff.

### Q-7: Invalid Web UI File Names Are Rejected

- **Stimulus:** The player enters a file name for Web UI load or save that contains a
  disallowed character — for example a path separator, a space, an extra dot or a
  character outside letters, digits, hyphens and underscores — or that lacks the
  `.txt` suffix.
- **Source:** Player, through the Web UI page.
- **Environment:** Flask backend validating the name before any file access; target
  folder `grids/`.
- **Response:** Flask rejects the name with a clear error message shown on the page,
  and performs no file read or write.
- **Measure:** `^[A-Za-z0-9_-]+\.txt$` is accepted, while every other name produces a
  clear error and no file operation; valid names such as `grid-1.txt` are resolved
  only inside `grids/`.

## 10.3 Notes and Open Items

- The performance target does not specify reference hardware or how the one second is
  measured; that must be agreed before Q-2 can be verified consistently.
- "Clear error message" is expressed here as a user-visible message identifying the
  failure; precise wording is not defined.
- Q-7 applies to file names entered in the Web UI only; ADR-006 leaves CLI file
  selection as terminal input.
- ADR-005 fixes the Web UI file flow: the player enters a name and Flask uses a file
  in `grids/` on load and save, while next-generation requests carry grid text from
  the page. This defines how Q-2 and Q-3 are exercised through the browser but does
  not change their targets.
