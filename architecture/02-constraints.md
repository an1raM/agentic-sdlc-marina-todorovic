# 2. Architecture Constraints

This chapter lists the constraints that limit the design freedom of the Game of Life
Simulator. Each is either given by the brief, already fixed in the repository, or
decided in Chapter 1. Nothing here adds a new requirement.

## 2.1 Technical Constraints

| # | Constraint | Consequence for the design | Source |
| --- | --- | --- | --- |
| T-1 | Python 3.12 is the implementation language. | All code targets Python 3.12; `pyproject.toml` already sets `requires-python = ">=3.12"` and the formatters/linter target `py312`. | Brief; ADR-001; `pyproject.toml` |
| T-2 | One shared Game Engine core library is used by every interface. | The rules exist in exactly one place; the CLI and the Web UI are clients of it, not reimplementations. | Brief; ADR-001 |
| T-3 | The engine has no I/O of its own. | File access and presentation live in the interfaces. The engine parses grid text into an in-memory grid and formats it back, but never reads or writes files, prints or renders. | Brief; ADR-001 |
| T-4 | Grids are stored as plain text files; no database. | Persistence is local file access. No schema, driver, server or migration tooling is needed. | Brief; ADR-001 |
| T-5 | The Web UI is served by a small Flask backend that calls the Game Engine. | The engine is not exposed directly to the browser; a Python-side HTTP layer sits between them. The CLI calls the engine directly. | Chapter 1 decision 3 (ADR-004 to follow) |
| T-6 | Grid file format: headerless plain text, one line per row, `*` = living cell, `.` = dead cell; all rows the same length; size taken from the content. | The file reader/writer must enforce this exact format, including equal row lengths. | Chapter 1 decision 1 (ADR-002 to follow) |
| T-7 | Invalid grid files are rejected with a clear error message. | Validation is part of the loading path in each interface; errors must be reported to the user, not silently ignored. | Chapter 1 decisions 1 and 4 |
| T-8 | The grid is fixed-size; cells outside it are dead; there is no wrapping. | The engine's step function treats out-of-bounds neighbours as dead and never changes grid dimensions. | Chapter 1 decision 2 (ADR-003 to follow) |
| T-9 | A grid up to 100x100 produces the next generation in under 1 second; invalid files give a clear error message. | The implementation must stay simple but avoid needlessly expensive per-generation work; these targets become measurable scenarios in Chapter 10. | Chapter 1 decision 4 |
| T-10 | Repository tooling runs black, isort, ruff, bandit and detect-secrets via pre-commit. | Code must pass these checks; line length is 88 and the ruff rule set is `E`, `F`, `W`, `I`, `N`, `UP`, `B`, `SIM`. | `.pre-commit-config.yaml`; `pyproject.toml` |

No operating system, browser, hosting platform or framework beyond Flask is prescribed
by the available material. Those choices remain open until they are needed in
Chapters 7 and 9.

## 2.2 Organizational Constraints

| # | Constraint | Consequence for the design | Source |
| --- | --- | --- | --- |
| O-1 | The work happens in the Agentic SDLC course repository, in the Software Architecture module. | Documentation is the deliverable of this phase; implementation follows later modules. | `README.md` |
| O-2 | Architecture is documented with arc42, one chapter at a time, each reviewed and approved before the next. | Only the current chapter is produced in a step; no later chapter is pre-empted. | Architecture agent workflow |
| O-3 | The existing `architecture/diagrams/c4-context.puml` and `architecture/09-architecture-decisions.md` (ADR-001) must be reused. | These files are referenced and extended, not replaced or rewritten. ADR-001 stays as the first decision; new ADRs are appended as ADR-002 onward. | Brief; architecture agent workflow |
| O-4 | Decisions 1–3 from Chapter 1 are to be recorded as ADR-002, ADR-003 and ADR-004 in Chapter 9. | Chapter 9 must preserve that numbering and append after ADR-001. | User decision after Chapter 1 |
| O-5 | The Chapter 5 container diagram must show the Flask backend between the Web UI and the Game Engine. | The Web UI, Flask backend and engine appear as separate containers. | User decision after Chapter 1 |
| O-6 | Commits follow the format `#<issue> <type>(<scope>): <description>` and are checked by a commit-msg hook. | Work is committed in small, issue-linked steps with an allowed type from `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `ci`, `perf`, `style`. | `scripts/hooks/check-commit-msg.sh` |

## 2.3 Conventions

- **Documentation structure:** the twelve arc42 chapters live in separate files under
  `architecture/`, using the numbering and file names defined by the architecture
  agent workflow (for example `01-introduction-and-goals.md`,
  `09-architecture-decisions.md`).
- **Diagrams:** all architecture diagrams use the C4 model in PlantUML, with the
  C4 library bundled in PlantUML (`!include <C4/C4_Context>`, `<C4/C4_Container>`,
  `<C4/C4_Component>`) so no internet access is required. Every diagram has a title
  and every element has a description. Diagram sources live in
  `architecture/diagrams/`; the pre-commit hook generates and stages an `.svg`
  alongside each staged `.puml`.
- **Architecture decisions:** ADRs are numbered consecutively from ADR-001 and use the
  Status / Context / Decision / Rationale / Consequences structure.
- **Python style:** black formatting with line length 88, isort with the `black`
  profile, and ruff with the rule set configured in `pyproject.toml`; security and
  secret scanning by bandit and detect-secrets run in pre-commit as well.
