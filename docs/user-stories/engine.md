# ENGINE-STORY-001: Compute next generation with Conway's rules on a fixed-size grid

**Priority**: Core (Pareto 20%)
**Architecture references**: `architecture/01-introduction-and-goals.md` §1.1 (F-2, F-5), §1.2; `architecture/04-solution-strategy.md` §4.1, §4.2, §4.3; `architecture/05-building-block-view.md` §5.1, §5.3.1; `architecture/06-runtime-view.md` §6.1, §6.2.2, §6.5; `architecture/08-cross-cutting-concepts.md` §8.1, §8.3; `architecture/10-quality-requirements.md` Q-1, Q-2, Q-5; `architecture/09-architecture-decisions.md` ADR-001, ADR-003; `architecture/diagrams/c4-component-engine.puml`, `architecture/diagrams/sequence-cli-load-and-next.puml`, `architecture/diagrams/sequence-webui-next.puml`

AS A player I WANT the simulator to compute the next generation of my grid using Conway's rules SO THAT I can see how my pattern evolves.

## Scenarios

### SCENARIO 1: Blinker horizontal line becomes vertical

**Scenario ID**: ENGINE-STORY-001-S1

**GIVEN**
* a 5x5 grid with living cells only at (2,1), (2,2), (2,3), with row and column counting from 0

**WHEN**
* the player requests the next generation

**THEN**
* the living cells are exactly (1,2), (2,2), (3,2)

### SCENARIO 2: Dead cell is born with exactly three neighbours

**Scenario ID**: ENGINE-STORY-001-S2

**GIVEN**
* a fixed-size in-memory grid contains a dead cell
* that dead cell has exactly three living neighbours within the grid

**WHEN**
* the player requests the next generation

**THEN**
* the cell becomes living in the next generation

### SCENARIO 3: Cells die or remain dead by Conway's rules

**Scenario ID**: ENGINE-STORY-001-S3

**GIVEN**
* a fixed-size in-memory grid contains living and dead cells
* a living cell has fewer than two or more than three living neighbours

**WHEN**
* the player requests the next generation

**THEN**
* that living cell is dead in the next generation
* dead cells without exactly three living neighbours remain dead

### SCENARIO 4: Edge cells treat outside as dead with no wrapping

**Scenario ID**: ENGINE-STORY-001-S4

**GIVEN**
* a 5x5 grid with living cells only at (1,0), (2,0), (3,0), with row and column counting from 0

**WHEN**
* the player requests the next generation

**THEN**
* the living cells are exactly (2,0) and (2,1)
* cell (2,4) stays dead because there is no wrapping
* the grid stays 5x5

### SCENARIO 5: Same input produces same result across interfaces

**Scenario ID**: ENGINE-STORY-001-S5

**GIVEN**
* the same valid grid is available to the CLI and to the Web UI
* both interfaces use the shared Game Engine core library

**WHEN**
* the player requests the next generation through each interface

**THEN**
* both interfaces present the same resulting grid

## Sub-stories

### ENGINE-INFRA-001.1: Provide a Python runtime for engine execution

**Architecture references**: `architecture/02-constraints.md` T-1; `architecture/07-deployment-view.md` §7.1, §7.2; `architecture/08-cross-cutting-concepts.md` §8.2; `architecture/09-architecture-decisions.md` ADR-001

The engine runs as part of the simulator host Python runtime. The data store is the `grids/` folder of plain text files, accessed by the interfaces and not by the engine. No separate engine service, database, or event infrastructure is introduced.

#### Scenarios

##### SCENARIO 1: Simulator host has Python 3.12 runtime

**Scenario ID**: ENGINE-INFRA-001.1-S1

**GIVEN**
* the simulator host is prepared for running the Game of Life Simulator

**WHEN**
* a developer starts a process that uses the Game Engine core library

**THEN**
* Python 3.12 is available to run the engine code
* the engine is loaded in-process by the calling interface

##### SCENARIO 2: No external persistence or event infrastructure required

**Scenario ID**: ENGINE-INFRA-001.1-S2

**GIVEN**
* the engine computes next generations from in-memory grid data
* grid files are stored in the `grids/` folder as plain text files

**WHEN**
* the engine is deployed with the CLI or Flask backend

**THEN**
* the `grids/` folder is the data store, accessed by the interfaces and not by the engine
* no database is required
* event handling is not applicable because the architecture defines no events or queues
* monitoring is limited to error reporting through the calling interface as defined by the architecture; no additional logging, metrics, or tooling is added

### ENGINE-BE-001.1: Compute next generation in the Rules Engine

**Architecture references**: `architecture/01-introduction-and-goals.md` F-2, §1.4 decision 2; `architecture/04-solution-strategy.md` §4.1, §4.2, §4.3; `architecture/05-building-block-view.md` §5.3.1; `architecture/08-cross-cutting-concepts.md` §8.1, §8.3; `architecture/10-quality-requirements.md` Q-1, Q-2, Q-4, Q-5; `architecture/09-architecture-decisions.md` ADR-001, ADR-003

The Rules Engine computes the next generation from the Grid Model using Conway's rules. It has no file, terminal, or HTTP I/O.

#### Scenarios

##### SCENARIO 1: Apply Conway survival and birth rules

**Scenario ID**: ENGINE-BE-001.1-S1

**GIVEN**
* the Grid Model contains a fixed-size grid with living and dead cells

**WHEN**
* the Rules Engine computes the next generation

**THEN**
* living cells with two or three living neighbours survive
* dead cells with exactly three living neighbours become alive
* all other cells are dead in the next generation

##### SCENARIO 2: Apply fixed boundary rule

**Scenario ID**: ENGINE-BE-001.1-S2

**GIVEN**
* a cell is at or near the grid boundary

**WHEN**
* the Rules Engine counts its neighbours

**THEN**
* neighbours outside the grid are treated as dead
* the grid is not wrapped
* the Grid Model dimensions remain unchanged

##### SCENARIO 3: Compute without I/O

**Scenario ID**: ENGINE-BE-001.1-S3

**GIVEN**
* a valid in-memory grid is provided to the Game Engine

**WHEN**
* the next generation is computed

**THEN**
* the computation uses in-memory grid data only
* no file, terminal, or HTTP I/O occurs in the engine

##### SCENARIO 4: Meet the stated performance target for supported grid size

**Scenario ID**: ENGINE-BE-001.1-S4

**GIVEN**
* a valid grid up to 100x100 cells

**WHEN**
* the Rules Engine computes the next generation

**THEN**
* the next generation is produced within the target stated by the architecture: under 1 second
* the exact measurement method and reference hardware remain an open point per `architecture/10-quality-requirements.md` §10.3

FE: not applicable, presentation is covered by the CLI and WEB stories.
# ENGINE-STORY-002: Parse, validate, and format grid text in the agreed plain-text format

**Priority**: Core (Pareto 20%)
**Architecture references**: `architecture/01-introduction-and-goals.md` §1.1 (F-1, F-4, F-6), §1.2; `architecture/04-solution-strategy.md` §4.1, §4.2, §4.3; `architecture/05-building-block-view.md` §5.1, §5.3.1; `architecture/06-runtime-view.md` §6.3.1, §6.4, §6.5; `architecture/08-cross-cutting-concepts.md` §8.1, §8.2, §8.3; `architecture/10-quality-requirements.md` Q-3, Q-4, Q-6; `architecture/11-risks-and-technical-debts.md` R-4; `architecture/09-architecture-decisions.md` ADR-001, ADR-002; `architecture/diagrams/c4-component-engine.puml`, `architecture/diagrams/sequence-save-generation.puml`, `architecture/diagrams/sequence-invalid-file.puml`

AS A player I WANT grid files to be read and saved in a clear plain-text format SO THAT I can create, understand, and reuse grids reliably.

## Scenarios

### SCENARIO 1: Parse a valid grid text file

**Scenario ID**: ENGINE-STORY-002-S1

**GIVEN**
* a grid text contains headerless rows of `*` and `.` characters
* the grid text is:
  ```text
  .*.
  ..*
  ***
  ```

**WHEN**
* the player loads the grid

**THEN**
* the Grid Text Codec parses the text into an in-memory grid
* the grid dimensions are taken from the content as 3 rows by 3 columns
* living cells correspond to `*` and dead cells correspond to `.`

### SCENARIO 2: Format a grid back to plain text

**Scenario ID**: ENGINE-STORY-002-S2

**GIVEN**
* an in-memory 3x3 grid has living cells only at (0,1), (1,2), (2,0), (2,1), and (2,2), with row and column counting from 0

**WHEN**
* the player saves the grid

**THEN**
* the Grid Text Codec formats the grid as headerless plain text
* the saved text is:
  ```text
  .*.
  ..*
  ***
  ```
* the formatted text can be parsed back into an equivalent grid

### SCENARIO 3: Reject grid text with a disallowed character

**Scenario ID**: ENGINE-STORY-002-S3

**GIVEN**
* a grid text contains a disallowed character:
  ```text
  .*.
  .X*
  ***
  ```

**WHEN**
* the player loads the grid

**THEN**
* the Grid Text Codec rejects the text as invalid
* the invalid grid is not processed as a valid grid
* a clear error message is reported to the player by the calling interface

### SCENARIO 4: Reject grid text with unequal row lengths

**Scenario ID**: ENGINE-STORY-002-S4

**GIVEN**
* a grid text has rows of unequal length:
  ```text
  .*.
  ..
  ***
  ```

**WHEN**
* the player loads the grid

**THEN**
* the Grid Text Codec rejects the text as invalid
* the invalid grid is not processed as a valid grid
* a clear error message is reported to the player by the calling interface

## Open Points

- **R-4 (open):** ADR-002 defines rows of `*` and `.` but does not specify how an empty grid file should be treated. This story does not define behavior for empty files or other unspecified format edge cases; behavior must follow architecture clarification before implementation.

## Sub-stories

### ENGINE-INFRA-002.1: Provide plain-text grid file storage for interfaces

**Architecture references**: `architecture/02-constraints.md` T-1, T-4; `architecture/07-deployment-view.md` §7.1, §7.2; `architecture/08-cross-cutting-concepts.md` §8.2, §8.4; `architecture/09-architecture-decisions.md` ADR-001, ADR-002

The data store is the `grids/` folder of plain text files. The engine parses and formats grid text but has no file I/O; interfaces read and write grid files.

#### Scenarios

##### SCENARIO 1: Plain-text file store is available

**Scenario ID**: ENGINE-INFRA-002.1-S1

**GIVEN**
* the simulator host is prepared for running the Game of Life Simulator

**WHEN**
* a player loads or saves a grid through an interface

**THEN**
* the `grids/` folder on the host file system is available for plain text grid files
* interfaces access the grid files; the engine does not read or write files

##### SCENARIO 2: No database, no events, limited monitoring

**Scenario ID**: ENGINE-INFRA-002.1-S2

**GIVEN**
* grid persistence uses plain text files in the `grids/` folder

**WHEN**
* the simulator is deployed

**THEN**
* no database is required
* event handling is not applicable because the architecture defines no events or queues
* monitoring and logging follow `architecture/08-cross-cutting-concepts.md` §8.2 and §8.4: errors are reported directly to the player through the calling interface; no logging requirement is specified and the engine cannot produce log output

### ENGINE-BE-002.1: Parse and format grid text in the Grid Text Codec

**Architecture references**: `architecture/01-introduction-and-goals.md` F-1, F-4, F-6; `architecture/04-solution-strategy.md` §4.1, §4.2, §4.3; `architecture/05-building-block-view.md` §5.3.1; `architecture/06-runtime-view.md` §6.3.1, §6.4, §6.5; `architecture/08-cross-cutting-concepts.md` §8.1, §8.2, §8.3; `architecture/10-quality-requirements.md` Q-3, Q-4, Q-6; `architecture/11-risks-and-technical-debts.md` R-4; `architecture/09-architecture-decisions.md` ADR-001, ADR-002

The Grid Text Codec parses headerless `*`/`.` text into the Grid Model and formats a grid back to text. It rejects invalid text and has no file, terminal, or HTTP I/O.

#### Scenarios

##### SCENARIO 1: Parse valid headerless grid text

**Scenario ID**: ENGINE-BE-002.1-S1

**GIVEN**
* grid text is:
  ```text
  .*.
  ..*
  ***
  ```

**WHEN**
* the Grid Text Codec parses the text

**THEN**
* it produces an in-memory grid with 3 rows and 3 columns
* `*` cells are living and `.` cells are dead
* the grid dimensions come from the content

##### SCENARIO 2: Format grid text for round-trip use

**Scenario ID**: ENGINE-BE-002.1-S2

**GIVEN**
* an in-memory 3x3 grid has living cells only at (0,1), (1,2), (2,0), (2,1), and (2,2), with row and column counting from 0

**WHEN**
* the Grid Text Codec formats the grid

**THEN**
* it returns headerless plain text with one row per line
* the text uses only `*` and `.` with equal row lengths
* parsing the formatted text produces an equivalent grid

##### SCENARIO 3: Reject disallowed characters

**Scenario ID**: ENGINE-BE-002.1-S3

**GIVEN**
* grid text is:
  ```text
  .*.
  .X*
  ***
  ```

**WHEN**
* the Grid Text Codec parses the text

**THEN**
* it detects the format violation
* it reports an invalid-grid error to its caller
* it performs no file, terminal, or HTTP I/O

##### SCENARIO 4: Reject unequal row lengths

**Scenario ID**: ENGINE-BE-002.1-S4

**GIVEN**
* grid text is:
  ```text
  .*.
  ..
  ***
  ```

**WHEN**
* the Grid Text Codec parses the text

**THEN**
* it detects the unequal row lengths
* it reports an invalid-grid error to its caller
* the invalid text is not processed as a grid

FE: not applicable, presentation is covered by the CLI and WEB stories.
