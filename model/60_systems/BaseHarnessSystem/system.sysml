/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package BaseHarnessSystem {
    private import NumericalFunctions::*;
    // sum(...) in the rolled-up mass/power attributes
    private import BehaviorStates::*;
    private import DomainModel::*;
    private import ProductContext::CleaningRobot;
    private import Elan8::Electronics::Core::*;
    private import Elan8::Electronics::Actuation::*;
    private import Elan8::Electronics::Sensing::*;
    private import Elan8::Electronics::Power::*;
    private import Elan8::Electronics::Assembly::*;
    private import Elan8::Electronics::Board::*;
    private import Elan8::Electronics::Buses::*;
    private import Elan8::Electronics::Interconnection::*;
    private import Elan8::Mechanical::Core::*;
    private import Elan8::Mechanical::Drivetrain::*;
    private import Elan8::Mechanical::Interconnection::*;
    private import Elan8::Electronics::Compute::*;
    private import FirmwareArchitecture::*;
    private import PurchasedParts::*;
    private import Elan8::Procurement::*;
    private import Elan8::Units::Money::*;
    private import SystemRequirements::*;
    private import Elan8::Software::*;
    private import Elan8::Electronics::Wireless::*;
    private import Elan8::Units::Engineering::*;
    private import ISQ::*;
    private import SI::*;
    private import ScalarValues::*;
    private import FunctionalArchitecture::*;
    private import PhysicalArchitecture::*;
    private import ModuleRequirements::*;
    private import FirmwareLibrary::*;
    private import PhysicalShared::*;
    private import StandardViewDefinitions::*;
    private import ReviewConcerns::*;
    port def BaseHarnessBus {
        doc /* The signals the base wiring harness carries between the main board and the base
             * module, as nested ports typed as the main board sees them. The base module uses
             * BaseHarnessModuleBus. */
        port batteryRail : PowerRailPort;
        port logicRail : PowerRailPort;
        port leftPhases : ThreePhaseDrivePort;
        port rightPhases : ThreePhaseDrivePort;
        port leftOdometry : QuadratureEncoderPort;
        port rightOdometry : QuadratureEncoderPort;
        port brushCommand : PwmPort;
        port vacuumCommand : PwmPort;
        port bmsBus : ~I2cControllerPort;
        port leftLiftHazard : GpioPort;
        port rightLiftHazard : GpioPort;
        port frontLeftCliffHazard : GpioPort;
        port frontRightCliffHazard : GpioPort;
        port rearLeftCliffHazard : GpioPort;
        port rearRightCliffHazard : GpioPort;
        port cleaningFault : GpioPort;
        port bmsAlert : GpioPort;
        port dockBeaconDetected : GpioPort;
    }

    port def BaseHarnessModuleBus {
        doc /* The signals of the base wiring harness as the module sees them: the mate of the bus the main
             * board uses. Conjugating a bus reverses only its directed features, not its nested
             * ports (SysML v2 7.12), so the module end has a definition of its own. */
        port batteryRail : PowerRailPort;
        port logicRail : PowerRailPort;
        port leftPhases : ThreePhaseDrivePort;
        port rightPhases : ThreePhaseDrivePort;
        port leftOdometry : QuadratureEncoderPort;
        port rightOdometry : QuadratureEncoderPort;
        port brushCommand : PwmPort;
        port vacuumCommand : PwmPort;
        port bmsBus : I2cControllerPort;
        port leftLiftHazard : GpioPort;
        port rightLiftHazard : GpioPort;
        port frontLeftCliffHazard : GpioPort;
        port frontRightCliffHazard : GpioPort;
        port rearLeftCliffHazard : GpioPort;
        port rearRightCliffHazard : GpioPort;
        port cleaningFault : GpioPort;
        port bmsAlert : GpioPort;
        port dockBeaconDetected : GpioPort;
    }

    part def BaseWiringHarnessSpecification :> Elan8::Core::PhysicalComponent, Elan8::SystemsEngineering::SystemSpecification {
        // Each end mates with the module it plugs into.
        port mainPcbEnd : BaseHarnessModuleBus;
        port baseEnd : BaseHarnessBus;
    }

    part def BaseWiringHarnessArchitecture :> BaseWiringHarnessSpecification, WiringHarness, Elan8::SystemsEngineering::SystemArchitecture {
        part pcbConnector : Elan8::Electronics::Interconnection::BoardConnector :> connectors;
        part baseConnector : Elan8::Electronics::Interconnection::ElectronicConnector :> connectors;
        part connectors : Elan8::Electronics::Interconnection::ElectronicConnector [2..*] :>> connectors;
        part conductors : Elan8::Electronics::Interconnection::HarnessConductor [1..*] :>> conductors;
    }

    part def BaseWiringHarnessIntegration :> BaseWiringHarnessArchitecture, Elan8::SystemsEngineering::SystemIntegration, CostedPart {
        doc /* Base wiring harness with connectors */
        /* illustrative estimate */
            part pcbConnector : Elan8::Electronics::Interconnection::BoardConnector :>> pcbConnector :> connectors;
        part baseConnector : Elan8::Electronics::Interconnection::ElectronicConnector :>> baseConnector :> connectors;
        part connectors : Elan8::Electronics::Interconnection::ElectronicConnector[2] :>> connectors = (pcbConnector, baseConnector);
        part conductors : Elan8::Electronics::Interconnection::HarnessConductor[1..*] :>> conductors;
        @MakePart;
        attribute :>> unitCost = 1.90 [EUR];
        attribute :>> mass = 0.12 [kg];
        connect mainPcbEnd.batteryRail to baseEnd.batteryRail;
        connect mainPcbEnd.logicRail to baseEnd.logicRail;
        connect mainPcbEnd.leftPhases to baseEnd.leftPhases;
        connect mainPcbEnd.rightPhases to baseEnd.rightPhases;
        connect mainPcbEnd.leftOdometry to baseEnd.leftOdometry;
        connect mainPcbEnd.rightOdometry to baseEnd.rightOdometry;
        connect mainPcbEnd.brushCommand to baseEnd.brushCommand;
        connect mainPcbEnd.vacuumCommand to baseEnd.vacuumCommand;
        connect mainPcbEnd.bmsBus to baseEnd.bmsBus;
        connect mainPcbEnd.leftLiftHazard to baseEnd.leftLiftHazard;
        connect mainPcbEnd.rightLiftHazard to baseEnd.rightLiftHazard;
        connect mainPcbEnd.frontLeftCliffHazard to baseEnd.frontLeftCliffHazard;
        connect mainPcbEnd.frontRightCliffHazard to baseEnd.frontRightCliffHazard;
        connect mainPcbEnd.rearLeftCliffHazard to baseEnd.rearLeftCliffHazard;
        connect mainPcbEnd.rearRightCliffHazard to baseEnd.rearRightCliffHazard;
        connect mainPcbEnd.cleaningFault to baseEnd.cleaningFault;
        connect mainPcbEnd.bmsAlert to baseEnd.bmsAlert;
        connect mainPcbEnd.dockBeaconDetected to baseEnd.dockBeaconDetected;
    }


}
