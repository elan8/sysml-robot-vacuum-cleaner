The system under verification is the robot described in RVC-SDS-001: six modules and the firmware on the main control board.

Requirements flow down in two steps. Each customer requirement is derived into system requirements, and each system requirement that no single module can meet alone is split into module budgets. Verification runs the other way: a module is shown to be inside its budget, the robot is shown to meet its system requirements, and the product is shown to meet the needs of the household.

| Level | Requirements | Number | Shown by |
| --- | --- | ---: | --- |
| Customer | USR, in RVC-CRS-001 | 11 | 5 validation cases |
| System | SYS, in RVC-SRS-001 | 21 | 12 verification cases |
| Module | BASE, PCB, FW, TOP, BIN, HAR, in RVC-SDS-001 | 13 | The same 12 cases, with the module quantity measured separately |
