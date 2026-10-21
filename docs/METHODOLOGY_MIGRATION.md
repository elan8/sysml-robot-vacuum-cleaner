# Methodology migration

Baseline: methodology commit `3837d43ac9d16f25b6d99e52e1e8e545bf16bc6b` (0.3.0).
The old discipline folders are replaced by context, use cases, stakeholder
requirements, shared library, flat systems and document sources. No old source
tree is inside the active `model/` load boundary.

Engineering identifiers survive: all customer/system/module requirements,
verification and validation case IDs retain their meanings. File-derived Spec42
tokens change on moves; use semantic names and engineering IDs for migration.
Compatibility imports/aliases in `50_library/Navigation.sysml` preserve prior
access paths without duplicating the authoritative definitions.

## System definition mapping

| Original definition | Specification | Selected design |
| --- | --- | --- |
| `DriveTrain` | `DriveTrainSystem::Specification::DriveTrainSpecification` | `DriveTrainSystem::Integration::DriveTrainIntegration` |
| `CleaningHeadModule` | `CleaningHeadSystem::Specification::CleaningHeadModuleSpecification` | `CleaningHeadSystem::Integration::CleaningHeadModuleIntegration` |
| `PowerModule` | `PowerSystem::Specification::PowerModuleSpecification` | `PowerSystem::Integration::PowerModuleIntegration` |
| `DockInterfaceModule` | `DockInterfaceSystem::Specification::DockInterfaceModuleSpecification` | `DockInterfaceSystem::Integration::DockInterfaceModuleIntegration` |
| `BaseModule` | `BaseSystem::Specification::BaseModuleSpecification` | `BaseSystem::Integration::BaseModuleIntegration` |
| `RobotMainMcu` | `ControllerSystem::Specification::RobotMainMcuSpecification` | `ControllerSystem::Integration::RobotMainMcuIntegration` |
| `MainPcbModule` | `MainControlBoardSystem::Specification::MainPcbModuleSpecification` | `MainControlBoardSystem::Integration::MainPcbModuleIntegration` |
| `TopModule` | `TopSystem::Specification::TopModuleSpecification` | `TopSystem::Integration::TopModuleIntegration` |
| `DustBin` | `DustBinSystem::Specification::DustBinSpecification` | `DustBinSystem::Integration::DustBinIntegration` |
| `BaseWiringHarness` | `BaseHarnessSystem::Specification::BaseWiringHarnessSpecification` | `BaseHarnessSystem::Integration::BaseWiringHarnessIntegration` |
| `TopWiringHarness` | `TopHarnessSystem::Specification::TopWiringHarnessSpecification` | `TopHarnessSystem::Integration::TopWiringHarnessIntegration` |
| `AutonomousFloorCleaningRobot` | `RobotPlatformSystem::Specification::AutonomousFloorCleaningRobotSpecification` | `RobotPlatformSystem::Integration::AutonomousFloorCleaningRobotIntegration` |
| `FirmwareTaskArchitecture` | `FirmwareSystem::Specification::FirmwareTaskArchitectureSpecification` | `FirmwareSystem::Integration::FirmwareTaskArchitectureIntegration` |
| `CleaningRobotSystemOfInterest` | `VacuumCleanerSystem::Specification::CleaningRobotSystemOfInterestSpecification` | `VacuumCleanerSystem::Integration::CleaningRobotSystemOfInterestIntegration` |

Leaf definitions now live under
`ComponentProfiles::<OriginalName>::{Specification,Architecture}` with matching
`<OriginalName>Specification` and `<OriginalName>Architecture` classifiers.
Shared abstract tasks remain in FirmwareLibrary; common physical relations
remain in PhysicalShared. PurchasedParts, Sourcing and DomainModel retain names.

## Other canonical owners

| Previous owner | Current owner |
| --- | --- |
| SystemRequirements | RobotPlatformSystem::Specification::Requirements |
| RequirementLimits | RobotPlatformSystem::Specification::Limits |
| RequirementTraceability | RobotPlatformSystem::Specification::Traceability |
| ModuleBudgets | RobotPlatformSystem::Architecture::Budgets |
| RequirementAllocation | RobotPlatformSystem::Architecture::RequirementAllocation |
| ModuleRequirements | Accepting system's Specification::Requirements; harness obligations in RobotPlatformSystem::Specification::HarnessRequirements |
| RobotAnalysisCases | RobotPlatformSystem::Analysis |
| Verification | RobotPlatformSystem::Verification |
| Validation | VacuumCleanerSystem::Verification::Validation |
| Architecture::robotSystem | VacuumCleanerSystem::Integration::robotSystem |
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
