# 9. Architecture Decisions

This chapter records the significant architecture decisions. ADR-001 is the existing
decision from the repository; ADR-002 to ADR-004 capture the choices made after
Chapter 1.

## ADR-001: Use Python with a Shared Core Library and Plain Text Grid Files

**Status:** Accepted

**Context:**
The Game of Life Simulator must compute the next generation of a grid using
Conway's rules. Players use it through a web UI or a command-line program, and
grids are loaded from and saved to text files. The rules logic must behave
identically in both interfaces.

**Decision:**
- Implement the system in Python 3.12.
- Put the rules and grid parsing in a Game Engine core library that both the
  CLI and the Web UI use.
- Store grids as plain text files on the file system. No database.

**Rationale:**
- Python is concise and readable, which suits a small rules-based kata
- black, ruff and the other tools in the repo already target Python
- One shared engine means the rules are written and tested once
- The engine has no I/O of its own, so it is easy to unit test
- Text files are human-readable, easy to create by hand and easy to diff in Git
- A database would add setup and operational cost the kata does not need

**Consequences:**
- The Web UI needs a way to reach the Python engine (a small backend or an
  in-browser runtime), which must be decided separately
- Grid files must follow a defined text format, and the parser must reject
  invalid files
- No querying, concurrency control or history beyond what the files provide
- The engine's public interface must stay stable because two clients depend on it

## ADR-002: Grid Text File Format

**Status:** Accepted

**Context:**
ADR-001 requires grids to be stored as plain text files and states that the parser
must reject invalid files, but it does not define the format. Both interfaces and
the shared engine's Grid Text Codec need one exact format so that files can be
written by hand, read consistently and validated predictably.

**Decision:**
- A grid file is headerless plain text with one line per row.
- `*` means a living cell and `.` means a dead cell.
- The grid dimensions are taken from the content; all rows must have the same length.
- Files that do not follow this format are rejected with a clear error message.

**Rationale:**
- A headerless `*` / `.` layout is human-readable, easy to create by hand and easy to
  diff in Git
- Deriving the size from the content avoids separate metadata that could disagree
  with the rows
- Requiring equal row lengths makes the rectangular grid unambiguous
- Defining the format once lets the shared codec validate it identically for the CLI
  and the Web UI

**Consequences:**
- The Grid Text Codec must enforce the allowed characters and equal row lengths and
  report a clear error when validation fails
- Files using other symbols, headers or ragged rows cannot be loaded
- The format carries no metadata such as a generation number or author
- Both interfaces must present the codec's error to the player rather than
  processing the file

## ADR-003: Fixed-Size Grid with Dead Cells Outside the Grid

**Status:** Accepted

**Context:**
Conway's rules refer to neighbours of a cell, but a stored grid is finite. The
behaviour at the edges was left undefined in the first draft of Chapter 1 and must
be fixed so the Rules Engine and its tests have one unambiguous rule.

**Decision:**
- The grid has a fixed size; its dimensions do not change between generations.
- Cells outside the grid are treated as dead.
- Edges do not wrap around to the opposite side.

**Rationale:**
- A single simple boundary rule is easy to implement and test
- The size can come directly from the grid file content, as required by ADR-002
- No extra configuration, coordinate mapping or growth logic is needed
- The behaviour is identical in the CLI and the Web UI because it lives in the shared
  engine

**Consequences:**
- Patterns that reach an edge are clipped by the dead outside cells; the player must
  start with enough space in the grid
- The Rules Engine treats every out-of-bounds neighbour as dead
- The Grid Model never resizes, and an expanding-grid feature is out of scope
- Tests must cover boundary cells explicitly, since wrapping is not available

## ADR-004: Serve the Web UI with a Small Flask Backend

**Status:** Accepted

**Context:**
ADR-001 left open how the Web UI reaches the Python engine: a small backend or an
in-browser runtime. The engine is a Python library with no I/O, so a browser cannot
call it directly, and the rules must not be duplicated in JavaScript.

**Decision:**
- Serve the Web UI as an HTML page from a small Flask backend.
- The Flask backend handles browser requests, calls the shared Game Engine library
  in-process and reads and writes grid files.
- The CLI calls the same engine library directly; no in-browser rules runtime is
  introduced.
- The engine remains a library, not a separately running service.

**Rationale:**
- Flask is a small framework that fits the kata and keeps the web layer thin
- Calling the Python engine from a Python backend avoids duplicating the rules
- File I/O stays in the interfaces, preserving the I/O-free engine from ADR-001
- A single backend is simpler than introducing another service boundary

**Consequences:**
- A Python 3.12 environment with Flask is needed on the simulator host
  (Chapter 7), and the Web UI is shown as a separate container from the engine
  and the Flask backend (Chapter 5)
- How the Web UI designates which grid file to load or save was left open at this
  point and is resolved by ADR-005
- The Flask backend must present engine errors as clear messages on the served page
- Browser requests add an HTTP hop that the CLI path does not have

## ADR-005: Web UI Holds the Current Grid and Exchanges Grid Text with Flask

**Status:** Accepted

**Context:**
ADR-004 introduced a Flask backend for the Web UI but did not decide where the
current grid lives between requests or how the browser designates files. Chapter 6
left this open. A choice is needed for the load, next and save flows that keeps the
engine I/O-free and the backend simple.

**Decision:**
- The Web UI page holds the current grid text in the browser; Flask keeps no
  server-side grid state between requests.
- **Load:** the player enters a file name; the page sends that name to Flask, which
  reads the named file from the `grids/` folder and returns the grid text.
- **Next:** the page sends its current grid text to Flask, which calls the shared
  engine and returns the next-generation grid text. No file is read or written.
- **Save:** the page sends its current grid text and a file name to Flask, which
  writes the text to the named file in `grids/`.
- File names entered by the player are resolved as files inside `grids/`.

**Rationale:**
- Supplying grid text to the engine keeps the I/O-free engine from ADR-001 intact
- Holding the grid in the page avoids server-side sessions or a grid store
- The next-generation path needs no file access, which is simpler and avoids an
  unnecessary read per step
- A single `grids/` folder gives load and save a clear, bounded location
- Both loaded text and page-supplied text are validated by the same Grid Text Codec

**Consequences:**
- Unsaved changes are lost when the page is reloaded or closed
- The player must type a file name; no file picker or browsing of `grids/` is defined
- Flask must report load/save failures and invalid grid text as clear messages on the
  page
- Because file names come from the browser, Flask must validate them before any file
  access; the allowed-name rule is defined in ADR-006
- Grid text for grids up to 100x100 travels over HTTP on each next request

## ADR-006: Restrict Web UI File Names and Access to grids/

**Status:** Accepted

**Context:**
ADR-005 lets the player enter a file name for Web UI load and save and resolves it
inside `grids/`. Chapter 11 tracked the lack of a naming rule as risk R-9 and debt
TD-1: a name containing path separators or other characters could escape the folder
or refer to an unexpected file. A precise, simple rule is needed before
implementation.

**Decision:**
- File names entered in the Web UI may contain only letters (`A`–`Z`, `a`–`z`),
  digits (`0`–`9`), hyphens (`-`) and underscores (`_`), followed by the `.txt`
  extension. Equivalently: `^[A-Za-z0-9_-]+\.txt$`.
- Any other file name is rejected with a clear error message before any file access.
- Web UI load and save read from and write to files inside the `grids/` folder only;
  no other path is used for these operations.
- The rule applies to Web UI load and save. CLI file selection remains terminal
  input, as stated in ADR-005.

**Rationale:**
- The restricted character set excludes path separators, relative-path segments and
  shell metacharacters, keeping resolved names inside `grids/`
- The `.txt` suffix matches the plain text grid format from ADR-002
- A single validation rule is easy to implement and test in the Flask backend
- Rejecting invalid names with a clear message gives predictable feedback instead of
  file-system errors

**Consequences:**
- Names containing spaces, additional dots, subdirectories or non-ASCII characters
  are not accepted; an existing file with such a name cannot be loaded or saved
  through the Web UI without renaming it
- Flask must validate the name before reading or writing and show the error on the
  served page
- The CLI does not use this rule, so Web UI and CLI file-name handling differ
- R-9 and TD-1 in Chapter 11 are resolved by this decision
