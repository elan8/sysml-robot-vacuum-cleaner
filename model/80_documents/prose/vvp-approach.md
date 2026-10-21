## Methods

Four methods are used, as defined in the NASA Systems Engineering Handbook. The tables of this plan name them with the terms of the SysML v2 standard library.

| Method | In the tables | Used when |
| --- | --- | --- |
| Test | `test` | The requirement is shown by operating the robot or its firmware under controlled conditions and measuring the result against the limit. |
| Analysis | `analyze` | The requirement is shown by calculation or simulation from design data, where a test is impractical or to extend a test result to conditions that were not tested. |
| Inspection | `inspect` | The requirement is shown by examining or measuring the product or its records without operating it. |
| Demonstration | `demo` | The requirement is shown by operating the product and observing the result, without measurement against a numeric limit. |

Test is preferred for every requirement with a numeric limit. Analysis alone is not accepted for a safety requirement.

## Pass criteria

Each case states its own criterion. A requirement is verified when every case that names it has passed on the configuration under test. A case that is run again after a change to the robot is run in full.

## Order of work

Firmware cases run first, on the target board, because they need no assembled robot. Module quantities are measured next, so that a module outside its budget is found before system tests. System cases follow on the assembled robot, and validation comes last, with production-representative units.

## Nonconformance

A failed case is recorded with the configuration it was run on. The cause is traced through the model: from the requirement to the module budget, the design element that claims it and the analysis behind it. The case is repeated after the correction.

## Independence

The safety cases, VER-002, VER-009 and VER-012, are witnessed by an engineer who did not design the item under test. The household safety walkthrough, VAL-003, is observed by an assessor from outside the project.
