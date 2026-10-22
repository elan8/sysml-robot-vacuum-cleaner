# Model guide

Load all of `model/`, with the pinned domain library. `Root.sysml` is navigation.
The [methodology tour](ELAN8_METHOD_TOUR.md) explains contracts, decomposition
and selection. The [migration map](METHODOLOGY_MIGRATION.md) records new owners.

## Reading path

1. Read `00_context/Context.sysml`, `10_usecases/UseCases.sysml` and
   `20_requirements/StakeholderRequirements.sysml` for the home, four scenarios
   and eleven customer requirements.
2. Read `60_systems/RobotPlatformSystem/system.sysml`. Its specification,
   architecture and integration definitions live directly in the system package.
   `Requirements`, `Limits` and `Traceability` contain the 21 measurable system
   obligations and their customer derivations; `Budgets` and `RequirementAllocation`
   contain module budgets and derivations. The integration selects six hardware
   modules and the referenced firmware design.
3. Read `60_systems/VacuumCleanerSystem/system.sysml`. Its single selected usage
   `VacuumCleanerSystem::robotSystem` composes the physical baseline, performs the
   functional behavior and exhibits the operating states. Allocations and
   detailed satisfaction claims refer to those concrete usages.
4. Follow BaseSystem, MainControlBoardSystem, TopSystem, DustBinSystem and both
   harness systems. Their specification, architecture and integration definitions show
   boundary contracts, child contracts and compatible selected child designs.
   Ordinary leaf types come directly from the domain library; robot-specific leaf
   definitions live with their owning systems. Purchased part metadata stays in `50_library`.
5. Follow FirmwareSystem: seven periodic/event-driven task profiles, five typed
   runtime queues, scheduling priorities/deadlines and deployment through a
   scheduler execution platform to the main controller.
6. Inspect RobotPlatformSystem's four analyses and twelve verification cases,
   then VacuumCleanerSystem's five household validation cases.
7. Export the nine focused views described in [VIEWS.md](VIEWS.md). Four additional
   methodology views can be exported with a development build supporting inheritance.

## Ownership and identity

Stakeholder needs remain in `StakeholderNeeds`. Authoritative system/module
requirements live alongside the accepting system's specification, including
boundary properties that express capacity, latency and mass without reaching
through child implementation structure. Contracts assert their requirement
collections against self; integrations provide the actual values.

Behavior is authored in the supporting `FunctionalArchitecture` and `BehaviorStates`
packages in VacuumCleanerSystem/Behavior.sysml, explicitly publicly imported as
`VacuumCleanerSystem::Behavior`. The import provides navigation, not new ownership.
`DomainModel` owns shared protocol items, ports and logical buses. `PhysicalShared`
and `FirmwareLibrary` own common helper definitions. `PurchasedParts` owns six
catalog choices; `Sourcing` owns make/buy BOM metadata.

Ordinary leaf components use the native domain types directly: BatteryPack,
Wheel, Gearbox, BoardConnector and others. Thirty definitions with real robot
content remain as plain specializations: brush geometry/ports, motor and sensor
mass/power, selected catalog parts, enclosures, firmware tasks and typed queues.
They belong to their owning systems; shared software definitions live in FirmwareLibrary.
There is no ComponentProfiles package or synthetic PhysicalComponent role hierarchy.
The PCB mountedComponents collection uses Elan8::Core::PhysicalComponent directly.

Developed subsystems retain their actual specification/architecture/integration
chains. Ordinary leaves need no method-role wrappers. The checker permits only
typed leaves with no inherited or usage-local structural parts, so a hidden
composite cannot bypass recursive subsystem checks. PCBA mountedComponents and
harness connector groups still collect named subset parts, not extra purchases.

`Navigation.sysml` preserves older qualified access paths through aliases and
public imports. The old PhysicalArchitecture, FirmwareArchitecture, requirement,
analysis, verification and ModelViews names are navigation facades. Tools use
canonical owners. Stable engineering IDs are unchanged; source-based tool tokens
change when a definition moves.

## Engineering backbone

Customer requirements derive system requirements; parent architecture budgets
derive module requirements. Satisfaction claims identify concrete behavior or
parts, and verification cases identify the obligations they assess. Quantitative
analyses share the same authoritative limits and selected design values.
There are 11 customer, 21 system and 13 module requirements, four analyses,
12 verification cases and five validation cases.

The physical baseline retains a dock/charger/BMS/battery path, separate safety
signals, two module harnesses, mechanically connected drivetrains, a powered
beacon receiver, debris transfer to the removable bin, and the top-module HMI.
Two forward side brushes share the brush transmission. The main roller and
suction intake are ahead of the rear caster. Nominal body diameter is 340 mm;
illustrative design height is 55 + 37 mm. The 49-item BOM totals 3.694 kg and
EUR 121.10. These are teaching estimates, not released production data.

Limits are defined once in RobotPlatformSystem::Limits; module
budgets are in RobotPlatformSystem::Budgets. Document placeholders can retain old
navigation aliases, but resolve to those authoritative values. Document views,
prose, figures and the inactive house template live in `80_documents`.
The BOM and mass-budget script operates independently of document rendering.
PDF generation remains disabled; see [VALIDATION.md](VALIDATION.md).
