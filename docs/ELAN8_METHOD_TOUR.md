# MBSE methodology tour

The model follows the updated MBSE methodology: one project context, stakeholder
needs, shared types, flat systems and publication sources. Recursive composition
is semantic, not folder nesting. See [structure](https://github.com/elan8/mbse-methodology/blob/0cb3ee0e7b5e64cf4f850a46da5f26acb280a4c2/docs/structure.md)
and the project's [baseline](../project.md).

Start with `00_context/Context.sysml`, then the four scenarios in `10_usecases`
and eleven stakeholder requirements in `20_requirements`. Follow those needs
into `RobotPlatformSystem`: its Requirements, Limits and
Traceability packages own the 21 system obligations and their derivations.

Each of the fourteen developed systems has one `60_systems/<System>/system.sysml` (root: `00_VacuumCleanerSystem`).
Its specification definition is a black box with boundary ports/properties and
asserted requirements. Its architecture specializes that specification and the independent
architecture marker; developed children are typed by child specifications, while
ordinary leaf components use native types or plain product specializations. Its integration
specializes the architecture and the integration marker, redefining those parts
with selected compatible architectures or integrations. A leaf architecture can
be selected directly. Ordinary leaf parts use domain types directly. Robot-specific leaf definitions live
with their systems; shared firmware types live in `50_library/FirmwareLibrary.sysml`.

The three role definitions belong directly to the system package. Role subpackages
are optional in the methodology; this model does not use them. `Requirements`,
`Analysis`, `Verification` and `Views` remain where they organize useful content.

For example, `RobotPlatformSystem` decomposes into base, board, top, bin and
harness contracts. Its integration selects their integrations. `BaseSystem`
recursively selects drive, cleaning, power and docking designs. The two drive
usages reuse `DriveTrainSystem`; neither requires a nested folder or copied model.
Firmware has its own system contract, architecture and selected task/queue design.

System and module requirements are owned by their accepting systems and
asserted inside their specifications against implicit self. Budgets and child requirement
derivations are owned by the parent system alongside its architecture. Concrete satisfaction links, behavior and
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
