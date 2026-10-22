# Methodology migration

Baseline: methodology commit `d4fa2f0dad0c6886cd96d4409677a7dc95c1974f` (0.4.0).
The old discipline folders are replaced by context, use cases, stakeholder
requirements, shared library, flat systems and document sources. No old source
tree is inside the active `model/` load boundary.

Engineering identifiers survive: all customer/system/module requirements,
verification and validation case IDs retain their meanings. File-derived Spec42
tokens change on moves; use semantic names and engineering IDs for migration.
Compatibility imports/aliases in `50_library/Navigation.sysml` preserve the older
discipline-based access paths without duplicating authoritative definitions.

Role definitions now belong directly to their system or component profile package.
For example, `DriveTrainSystem::DriveTrainSpecification` and
`DriveTrainSystem::DriveTrainIntegration` replace the intermediate role-package
paths. The old Specification/Architecture/Integration wrappers are removed,
including those around shared leaf profiles. Their names are not retained as
empty compatibility packages. Requirements, Limits, Budgets, Analysis,
Verification and Views remain useful groupings under their systems.

The namespace change preserves all 62 engineering IDs and names, all 10,096
selected engineering relationship edges after namespace mapping, and byte-identical
BOM and mass-budget outputs. Specification views select contracts/requirements
explicitly so flattening does not broaden their scope to designs.

## System definition mapping

| Original definition | Specification | Selected design |
| --- | --- | --- |
| `DriveTrain` | `DriveTrainSystem::DriveTrainSpecification` | `DriveTrainSystem::DriveTrainIntegration` |
| `CleaningHeadModule` | `CleaningHeadSystem::CleaningHeadModuleSpecification` | `CleaningHeadSystem::CleaningHeadModuleIntegration` |
| `PowerModule` | `PowerSystem::PowerModuleSpecification` | `PowerSystem::PowerModuleIntegration` |
| `DockInterfaceModule` | `DockInterfaceSystem::DockInterfaceModuleSpecification` | `DockInterfaceSystem::DockInterfaceModuleIntegration` |
| `BaseModule` | `BaseSystem::BaseModuleSpecification` | `BaseSystem::BaseModuleIntegration` |
| `RobotMainMcu` | `ControllerSystem::RobotMainMcuSpecification` | `ControllerSystem::RobotMainMcuIntegration` |
| `MainPcbModule` | `MainControlBoardSystem::MainPcbModuleSpecification` | `MainControlBoardSystem::MainPcbModuleIntegration` |
| `TopModule` | `TopSystem::TopModuleSpecification` | `TopSystem::TopModuleIntegration` |
| `DustBin` | `DustBinSystem::DustBinSpecification` | `DustBinSystem::DustBinIntegration` |
| `BaseWiringHarness` | `BaseHarnessSystem::BaseWiringHarnessSpecification` | `BaseHarnessSystem::BaseWiringHarnessIntegration` |
| `TopWiringHarness` | `TopHarnessSystem::TopWiringHarnessSpecification` | `TopHarnessSystem::TopWiringHarnessIntegration` |
| `AutonomousFloorCleaningRobot` | `RobotPlatformSystem::AutonomousFloorCleaningRobotSpecification` | `RobotPlatformSystem::AutonomousFloorCleaningRobotIntegration` |
| `FirmwareTaskArchitecture` | `FirmwareSystem::FirmwareTaskArchitectureSpecification` | `FirmwareSystem::FirmwareTaskArchitectureIntegration` |
| `CleaningRobotSystemOfInterest` | `VacuumCleanerSystem::CleaningRobotSystemOfInterestSpecification` | `VacuumCleanerSystem::CleaningRobotSystemOfInterestIntegration` |

Leaf definitions now live under
`ComponentProfiles::<OriginalName>` with matching
`<OriginalName>Specification` and `<OriginalName>Architecture` classifiers.
Shared abstract tasks remain in FirmwareLibrary; common physical relations
remain in PhysicalShared. PurchasedParts, Sourcing and DomainModel retain names.

## Other canonical owners

| Previous owner | Current owner |
| --- | --- |
| SystemRequirements | RobotPlatformSystem::Requirements |
| RequirementLimits | RobotPlatformSystem::Limits |
| RequirementTraceability | RobotPlatformSystem::Traceability |
| ModuleBudgets | RobotPlatformSystem::Budgets |
| RequirementAllocation | RobotPlatformSystem::RequirementAllocation |
| ModuleRequirements | Accepting system's Requirements; harness obligations in RobotPlatformSystem::HarnessRequirements |
| RobotAnalysisCases | RobotPlatformSystem::Analysis |
| Verification | RobotPlatformSystem::Verification |
| Validation | VacuumCleanerSystem::Verification::Validation |
| Architecture::robotSystem | VacuumCleanerSystem::robotSystem |
| ModelViews | Each reviewed system's Views package; see VIEWS.md |

Customer requirements remain in StakeholderNeeds. The retained RobotDocuments
package now lives in `model/80_documents`, alongside its prose, figures and
inactive template. Generated data moves from `documents/generated/` to root
`generated/`, which is ignored. No Doc42 pipeline is enabled.

## Preserved baseline and coverage

The migrated BOM still has 49 items, 3.694 kg and EUR 121.10; two side brushes
and the rear caster remain modeled. There are 11 customer, 21 system and 13
module requirements, four analyses, 12 verification and five validation cases.
See VALIDATION.md for language diagnostics, complete child selection checks
and explicit structural checker coverage limits.
