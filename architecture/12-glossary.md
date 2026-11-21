# 12. Glossary

This glossary defines the terms used in the architecture documentation. References in
the last column point to the chapter where the term is introduced or used most.

| Term | Definition | Chapter |
| --- | --- | --- |
| ADR | Architecture Decision Record: a numbered record of a significant choice, with Status, Context, Decision, Rationale and Consequences. | 9 |
| arc42 | The documentation template used for this architecture, organised into twelve chapters. | 1 |
| Birth | A dead cell becomes living in the next generation when it has exactly three living neighbours. | 1 |
| C4 model | The notation used for the context, container, component and deployment diagrams. | 3, 5, 7 |
| Cell | A single position in the grid; it is either living or dead. | 1 |
| CLI | Command-line interface: the Python program that reads and writes grid files, calls the engine directly and prints results in a terminal. | 5 |
| Command Handler | CLI component that interprets load, next and save requests and coordinates the other CLI components. | 5 |
| Component | A C4 level-3 building block inside a container, such as the Grid Text Codec. | 5 |
| Container | A C4 level-2 building block: a separately runnable or deployable part of the system, such as the CLI or Flask backend. | 5 |
| Conway's rules | The four rules applied by the Rules Engine: survival with two or three neighbours, birth with exactly three, death otherwise, and no change for other dead cells. | 1 |
| Current grid text | The grid text held by the Web UI page in the browser between requests; sent to Flask on next and save. | 6, 9 (ADR-005) |
| Dead cell | A cell with no life; represented by `.` in a grid file. | 1 |
| Engine Adapter | Flask backend component that calls the shared engine with grid text and returns the resulting generation or error. | 5 |
| Fixed-size grid | A grid whose dimensions never change; cells outside it are dead and edges do not wrap. | 1, 9 (ADR-003) |
| Flask backend | Small Python/Flask HTTP backend that serves the Web UI page, calls the engine and handles grid files for browser requests. | 1, 5, 9 (ADR-004) |
| Game Engine (core library) | Shared Python library that holds the in-memory grid, parses and formats grid text, and computes next generations. It performs no I/O. | 1, 5 |
| Generation | The state of the grid after one application of Conway's rules. | 1 |
| Grid | A rectangular arrangement of living and dead cells. | 1 |
| Grid file | A plain text file holding a grid, with one row per line and no header. | 1, 9 (ADR-002) |
| Grid File I/O | Component in the CLI or Flask backend that reads grid files and writes saved generations. | 5 |
| Grid Model | Game Engine component that holds the fixed-size grid of cells in memory. | 5 |
| Grid Text Codec | Game Engine component that parses grid text into a grid and formats a grid back to text, rejecting invalid text. | 5 |
| `grids/` folder | Folder on the simulator host holding the plain text grid files that Flask reads on load and writes on save; the player supplies a file name. | 6, 7, 9 (ADR-005) |
| HTTP Request Handler | Flask backend component that accepts Web UI requests and coordinates the response. | 5 |
| I/O-free | Property of the engine: it does not read or write files, print to a terminal or serve HTTP; it only accepts and returns data. | 1, 4 |
| Invalid grid file | A file that violates the agreed grid format, for example by using a disallowed character or rows of unequal length; it is rejected with a clear error message. | 1, 9 (ADR-002) |
| Living cell | A cell that is alive; represented by `*` in a grid file. | 1 |
| Neighbour | One of the eight cells immediately surrounding a cell horizontally, vertically or diagonally. A neighbour outside the fixed-size grid is treated as dead. | 1, 9 (ADR-003) |
| Page Renderer | Flask backend component that serves the Web UI page containing a grid or a clear error message. | 5 |
| Plain text format | Headerless grid representation: one line per row, `*` for living, `.` for dead, all rows the same length, size taken from the content. | 1, 9 (ADR-002) |
| Player | The human actor who loads a grid, watches generations and saves results through the CLI or Web UI. | 3 |
| PlantUML | The tool used to write the diagram sources in `architecture/diagrams/`; it uses the bundled C4 library. | 3, 5, 7 |
| pre-commit | Repository tooling that runs formatting, linting, security and secret checks, and generates SVGs from staged `.puml` files. | 2 |
| Quality scenario | An observable statement of a quality requirement, with stimulus, environment, response and measure or target. | 10 |
| Rules Engine | Game Engine component that computes the next generation under Conway's rules with fixed-size boundaries. | 5 |
| Technical debt | A design-level item that should be resolved later; no code-level debt exists yet because the kata is not implemented. | 11 |
| Terminal Presenter | CLI component that renders grids and clear error messages in the terminal. | 5 |
| Web UI | The browser page served by the Flask backend that displays a grid and lets the player load, advance and save generations. | 1, 5 |
