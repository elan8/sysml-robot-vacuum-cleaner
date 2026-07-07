/*
* SPDX-FileCopyrightText: 2026 Elan8
* SPDX-License-Identifier: MIT
*
* Stakeholder views tuned for Spec42 diagram export. Robot LRU interconnection
* uses boundary ports on mainElectronics so views do not expand PCB internals.
*/
package ModelViews {
  private import Views::*;
  private import StakeholderNeeds::*;
  private import SystemRequirements::*;
  private import Architecture::*;
  private import PhysicalArchitecture::*;
  private import Verification::*;

  part def StakeholderRole;

  part productOwner : StakeholderRole;
  part verificationEngineer : StakeholderRole;
  part firmwareEngineer : StakeholderRole;
  part systemsEngineer : StakeholderRole;

  concern requirementCoverage {
    doc /* How do needs, requirements, design, and verification connect? */
    subject;
    stakeholder :>> productOwner;
    stakeholder :>> verificationEngineer;
  }

  concern firmwareRuntime {
    doc /* How are firmware tasks coupled and deployed to modules and the MCU? */
    subject;
    stakeholder :>> firmwareEngineer;
    stakeholder :>> systemsEngineer;
  }

  concern productIntegration {
    doc /* How are robot LRUs interconnected at the harness level? */
    subject;
    stakeholder :>> systemsEngineer;
  }

  viewpoint traceabilityPerspective {
    frame requirementCoverage;
  }

  viewpoint firmwareRuntimePerspective {
    frame firmwareRuntime;
  }

  viewpoint productIntegrationPerspective {
    frame productIntegration;
  }

  view firmwareTaskArchitecture : InterconnectionView {
    satisfy firmwareRuntimePerspective;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot.firmwareTasks;
  }

  view firmwareDeployment : InterconnectionView {
    satisfy firmwareRuntimePerspective;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot.firmwareTasks;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot.robotFirmware;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.mainControlPcb.mcu;
  }

  view robotLruInterconnection : InterconnectionView {
    satisfy productIntegrationPerspective;
    expose Architecture::robotSystem.physical.chassis;
    expose Architecture::robotSystem.physical.driveModule;
    expose Architecture::robotSystem.physical.cleaningHead;
    expose Architecture::robotSystem.physical.sensorAssembly;
    expose Architecture::robotSystem.physical.mainElectronics;
    expose Architecture::robotSystem.physical.powerModule;
    expose Architecture::robotSystem.physical.dockInterface;
    expose Architecture::robotSystem.physical.hmi;
  }

  view requirementsTraceability : GeneralView {
    satisfy traceabilityPerspective;
    expose StakeholderNeeds::*;
    expose SystemRequirements::*;
    expose Verification::*;
    expose Architecture::robotSystem.physical;
  }
}
