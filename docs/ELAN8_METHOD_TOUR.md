# MBSE methodology tour

The model follows the updated MBSE methodology: one project context, stakeholder
needs, shared types, flat systems and publication sources. Recursive composition
is semantic, not folder nesting. See [structure](https://github.com/elan8/mbse-methodology/blob/3837d43ac9d16f25b6d99e52e1e8e545bf16bc6b/docs/structure.md)
and the project's [baseline](../project.md).

Start with `00_context/Context.sysml`, then the four scenarios in `10_usecases`
and eleven stakeholder requirements in `20_requirements`. Follow those needs
into `RobotPlatformSystem::Specification`: its Requirements, Limits and
Traceability packages own the 21 system obligations and their derivations.

Each of the fourteen developed systems has one `60_systems/<System>/system.sysml`.
Its Specification is a black box with boundary ports/properties and authoritative
requirements. Its Architecture specializes that specification and the independent
architecture marker; child parts are typed by child specifications. Its Integration
specializes the architecture and the integration marker, redefining those parts
with selected compatible architectures or integrations. A leaf architecture can
be selected directly. Shared leaf contracts/designs live in `50_library/ComponentProfiles.sysml`.

For example, `RobotPlatformSystem` decomposes into base, board, top, bin and
harness contracts. Its integration selects their integrations. `BaseSystem`
recursively selects drive, cleaning, power and docking designs. The two drive
usages reuse `DriveTrainSystem`; neither requires a nested folder or copied model.
Firmware has its own system contract, architecture and selected task/queue design.

System and module requirements are owned by their accepting specifications and
asserted there against implicit self. Budgets and child requirement derivations
belong to the parent architecture. Concrete satisfaction links, behavior and
allocations remain attached to the selected system baseline.

For a safety reading path, follow the household safety need to cliff detection,
safe-stop and reporting requirements; then base sensing/braking, firmware deadline
and board-disable budgets; then `CliffSafeStopScenario`, the selected allocations,
`RobotPlatformSystem::Analysis::SafetyReactionAnalysis`, its cliff-safe-stop
verification case and the household safety validation in `VacuumCleanerSystem`.

Views live with the systems they review. The context and three system role views
use `Elan8::SystemsEngineering`; nine focused views retain detailed engineering
questions. `80_documents` selects the same authoritative graph for publication.
PDF generation stays disabled. Shared document vocabulary is `Elan8::Documents`.

See [MODEL_GUIDE.md](MODEL_GUIDE.md), [VIEWS.md](VIEWS.md) and
[migration mapping](METHODOLOGY_MIGRATION.md).
