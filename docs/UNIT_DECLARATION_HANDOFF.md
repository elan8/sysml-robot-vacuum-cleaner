# Handoff: Project-defined duration and battery charge units

## Purpose

This note records the work needed to make the robot-vacuum model's millisecond and battery-capacity
notation portable and strictly declaration-based. It is intentionally separate from the Spec42
semantic diagnostic fixes so that the model update can be implemented and reviewed in this
repository.

## Decision

The model must not rely on Spec42 implicitly recognizing undeclared atomic unit symbols.

The bundled OMG SysML v2 quantities-and-units library baseline defines the SI prefix `milli`, the
second symbol `s`, the ampere symbol `A`, and the hour symbol `h`, but it does not declare atomic
`ms`, `Ah`, or `mAh` symbols. Consequently, accepting those symbols only because a tool can combine
a prefix and familiar unit abbreviation would be a tool extension rather than declaration-based
SysML v2 validation.

The robot-vacuum repository should therefore declare the battery charge units it uses in a local
model library and import that library where required. Spec42 should resolve and validate those
declarations; it should not invent them.

Capitalization is significant. The conventional symbols are `Ah`, `mAh`, and `Wh`, not `aH`,
`mah`, or `wH`.

## Current affected model elements

There are eight `[mAh]` literals:

| File | Line | Element |
|------|-----:|---------|
| `model/architecture/PhysicalArchitecture.sysml` | 263 | `nominalCapacity` |
| `model/architecture/PhysicalArchitecture.sysml` | 281 | `batteryCapacity` |
| `model/architecture/PhysicalArchitecture.sysml` | 283 | `reserveCapacity` |
| `model/requirements/DesignLimits.sysml` | 29 | `batteryCapacityBudget` |
| `model/assurance/AnalysisCases.sysml` | 95 | `missionChargeDraw` |
| `model/assurance/AnalysisCases.sysml` | 97 | `reserveCharge` |
| `model/assurance/AnalysisCases.sysml` | 98 | `usableMissionBudget` |
| `model/assurance/AnalysisCases.sysml` | 99 | `missionChargeMargin` |

There are also 65 loaded `[ms]` literals:

| File | Count |
|------|------:|
| `model/implementation/FirmwareArchitecture.sysml` | 58 |
| `model/architecture/PhysicalArchitecture.sysml` | 4 |
| `model/implementation/SoftwareImplementation.sysml` | 3 |

The strict Spec42 workspace run reports 68 `unknown_unit_symbol` diagnostics: all 65 loaded `[ms]`
literals and the three `[mAh]` literals in `PhysicalArchitecture.sysml`. All eight `[mAh]` literals
have the same declaration dependency and must be handled consistently even when a particular
validation entry point does not currently report every occurrence.

## Proposed model work

1. Add a small project library, for example
   `model/libraries/VacuumCleanerQuantitiesAndUnits.sysml`.
2. Import the appropriate standard quantities, units, and SI packages.
3. Declare a millisecond unit with symbol `ms` and quantity kind `DurationUnit`, using the standard
   `milli` prefix and `s` as its reference unit.
4. Declare an ampere-hour unit with symbol `Ah` and quantity kind `ElectricChargeUnit`, with its
   conversion expressed in terms of standard declared units.
5. Declare a milliampere-hour unit with symbol `mAh`, using the standard `milli` prefix and `Ah` as
   its reference unit.
6. Import the project library in each package that contains an affected literal.
7. Keep the existing numerical values and `[ms]`/`[mAh]` notation once the symbols resolve through
   project declarations.
8. Confirm the exact declaration and conversion syntax against the bundled OMG library baseline
   used by the repository before committing the model implementation.

An algebraic literal such as `[mA * h]` is an alternative only if every referenced symbol,
including `mA`, is resolvable through declared library elements. The explicit project-unit approach
is preferred because it gives `mAh` a named electric-charge dimension and keeps the engineering
model readable.

## Spec42 work kept out of this repository

The following belongs in Spec42 rather than this model update:

- Resolve user-defined unit symbols and their conversion metadata from the semantic graph.
- Diagnose an atomic unit symbol when neither the standard libraries nor the user model declares it.
- Check that `mAh` is compatible with `ElectricChargeValue` after the project declaration is loaded.
- Review the existing synthetic `Wh` and `VA` registry behavior. Strict validation should not
  silently create undeclared model elements; any permissive behavior should be explicit and must
  not mask a missing declaration.
- Add cross-repository integration coverage proving that project-defined units work.

No parser change is currently expected. Revisit that conclusion only if a minimal parser test shows
that the required unit definition, prefix, reference-unit, or conversion information is missing
from the AST.

## Acceptance criteria

- The repository contains explicit, reviewable declarations for `ms`, `Ah`, and `mAh`.
- Every `[ms]` literal resolves to the project-defined duration unit.
- Every `[mAh]` literal resolves to the project-defined unit.
- Each affected attribute remains typed as `ElectricChargeValue`.
- Spec42 reports no `unknown_unit_symbol` or `incompatible_unit_dimension` diagnostic for the
  affected duration and electric-charge literals.
- Removing or misspelling the project import causes an `unknown_unit_symbol` diagnostic.
- A deliberately incompatible quantity/unit pairing still causes
  `incompatible_unit_dimension`.
- The model passes its normal validation and diagram-export workflows without relying on
  permissive undeclared-unit synthesis.

## Out of scope

- Fixing the other robot-vacuum warning families in Spec42.
- Adding `Ah`, `mAh`, or `Wh` to the OMG standard library.
- Teaching Spec42 that every concatenation of an SI prefix and unit symbol is automatically a
  declared SysML model element.
