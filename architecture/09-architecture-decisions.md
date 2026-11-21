# 9. Architecture Decisions

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
