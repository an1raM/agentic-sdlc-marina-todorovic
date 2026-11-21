# 8. Cross-cutting Concepts

This chapter collects the concepts that apply across multiple building blocks. Only
concepts supported by the requirements and decisions so far are described; anything
not specified is marked as such instead of being designed in.

## 8.1 Grid Format and Generation Semantics

- A grid file is headerless plain text, one line per row, with `*` for a living cell
  and `.` for a dead cell. All rows must have the same length; the dimensions come
  from the content (Chapter 1 decision 1).
- The grid is fixed-size. Neighbours outside it are dead and edges do not wrap
  (Chapter 1 decision 2). Conway's rules are applied by the Rules Engine in the
  shared Game Engine core library.
- Parsing and formatting live in the engine's Grid Text Codec (ADR-001), so the
  format is interpreted identically in the CLI and in the Flask-backed Web UI.
  File access remains in the interfaces.
- In the Web UI, the page holds the current grid text in the browser. Flask reads a
  player-named file from `grids/` on load and writes one there on save; the
  next-generation path uses the grid text sent by the page and reads no file
  (ADR-005). The CLI keeps its own current grid locally in the terminal flow.

## 8.2 Error Handling

- Errors are detected as early as possible: the Grid Text Codec rejects grid text
  that violates the agreed format (including rows of unequal length) and signals an
  error to its caller. It does not print, log or write anything, because the engine
  has no I/O.
- Each interface is responsible for presenting the error to the player: the CLI
  through its Terminal Presenter, the Web UI through the Flask backend's Page
  Renderer. Invalid files are never processed as if they were valid (Chapter 1,
  F-6 and quality target).
- Web UI file names are validated before any file access. Only letters, digits,
  hyphens and underscores plus `.txt` are accepted; other names are rejected with a
  clear error message, and files are only read from or written to `grids/`
  (ADR-006).
- The material available specifies this invalid-file case but does not enumerate
  other failure modes (for example unreadable or unwritable files). Those are left
  to follow the same user-facing error path if they occur; no additional error
  taxonomy is invented here.

## 8.3 Testing

- **Engine unit tests:** the rules and grid text codec are tested directly on
  in-memory data, without files or a user interface. This is the main benefit of the
  I/O-free engine (ADR-001) and means the rules are written and tested only once.
- **Rules coverage:** survival with two or three neighbours, birth with exactly
  three, all other cells dead, plus the fixed-size boundary behaviour (out-of-bounds
  neighbours dead, no wrapping).
- **Format coverage:** valid grids are parsed and formatted round-trip; invalid
  text — including unequal row lengths and disallowed characters — is rejected with
  an error rather than silently accepted.
- **Interface coverage:** CLI and Web UI flows load a grid, advance a generation and
  save a result through the shared engine, and both surface a clear error for an
  invalid grid file. The Flask backend is exercised as the adapter between the Web
  UI page and the engine; its Web UI next-generation test should show that no file
  is read, while load and save use named files in `grids/` (ADR-005).
- **File-name coverage:** Web UI load and save accept names such as `grid-1.txt` and
  reject names with path separators, spaces, extra dots or disallowed characters
  with a clear error; no file is accessed for a rejected name (ADR-006, Chapter 10
  Q-7).
- **Quality scenarios:** a grid up to 100x100 produces the next generation in under
  one second, invalid files yield a clear error message, and invalid file names are
  rejected with a clear error (Chapter 1 decision 4; ADR-006; detailed in Chapter 10).
- **Repository checks:** black, isort, ruff, bandit and detect-secrets run through
  pre-commit as configured in the repository (Chapter 2, T-10).

## 8.4 Logging

No logging requirement is specified by the brief or the existing decisions. Errors
are reported directly to the player through the interface instead of being written
to a log. Because the engine has no I/O, it cannot produce log output; if operational
logging is ever needed, it belongs in the CLI or Flask backend only. This is left
open rather than designed in now.

## 8.5 Configuration

No configuration mechanism is specified. The former open point about Web UI file
selection is resolved by ADR-005: the player enters a file name and Flask resolves
it inside `grids/` for load and save, and ADR-006 fixes the allowed file-name form
(`^[A-Za-z0-9_-]+\.txt$`). Deployment details such as host names and ports remain open
(Chapter 7, section 7.3). The CLI takes its grid file selection from terminal input;
no config file, environment variables or settings model are introduced by this
architecture.

## 8.6 Security and Authentication

There is no authentication or authorisation requirement, and multi-user access is
out of scope (Chapter 1, section 1.4), so no identity, credential or access-control
concept is included. Security-relevant tooling is limited to the repository's bandit
and detect-secrets checks (Chapter 2, T-10). Grid files are ordinary plain text
files on the host's file system. For the Web UI, ADR-006 confines file names to
letters, digits, hyphens, underscores and `.txt` inside `grids/`, so a supplied name
cannot address a path outside that folder; no other protection model is specified.
