The system of interest, {{Architecture::robotSystem}}, has one physical realisation ({{PhysicalArchitecture::AutonomousFloorCleaningRobot}}) and one operating behaviour ({{FunctionalArchitecture::OperateCleaningRobot}}). The design links the two: every function is allocated to the hardware module and the firmware task that carry it out, and every system requirement is claimed by the function or the part that meets it.

The first figure shows the architecture as a block diagram, the second where the parts sit in the product.

Four decisions shape the design:

- **Safety is supervised independently of mission control.** Hazard signals reach a dedicated, highest-priority firmware task that can stop the motors without the mission controller's cooperation.
- **All loads are fed through the battery management system.** No module is connected to the battery directly, so over-current and over-temperature protection applies to every load.
- **The battery protects itself.** Over-current, over-voltage, under-voltage and over-temperature disconnect the pack in the gauge and protection circuit, without the application firmware.
- **Purchased components are selected, not specialised.** The robot's own part definitions state what the design needs; a named dependency selects the catalogue part that provides it. Replacing a component changes one dependency.
