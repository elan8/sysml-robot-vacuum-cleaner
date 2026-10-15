/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Nine focused views over the authoritative product graph.
 */
package ModelViews {
  private import Views::*;
  private import StandardViewDefinitions::*; // GeneralView and the other standard view definitions
  private import Architecture::*;
  private import FirmwareArchitecture::*;
  private import OperationalScenarios::*;
  private import SystemRequirements::*;

  part def StakeholderRole;
  part systemsEngineer : StakeholderRole;
  part firmwareEngineer : StakeholderRole;
  part verificationEngineer : StakeholderRole;
  part productEngineer : StakeholderRole;

  concern productStructure {
    doc /* What constitutes the selected robot baseline? */
    subject;
    stakeholder :>> systemsEngineer;
    stakeholder :>> productEngineer;
  }
  concern productConnections {
    doc /* How are the product LRUs connected? */
    subject;
    stakeholder :>> systemsEngineer;
  }
  concern firmwareDeployment {
    doc /* Which firmware tasks execute on which processor? */
    subject;
    stakeholder :>> firmwareEngineer;
    stakeholder :>> systemsEngineer;
  }
  concern requirementStructure {
    doc /* Which system requirements constrain the robot? */
    subject;
    stakeholder :>> verificationEngineer;
    stakeholder :>> systemsEngineer;
  }
  concern safeStopScenario {
    doc /* How does a cliff observation lead to a verified safe stop? */
    subject;
    stakeholder :>> verificationEngineer;
    stakeholder :>> systemsEngineer;
  }
  viewpoint productStructurePerspective { frame productStructure; }
  viewpoint productConnectionsPerspective { frame productConnections; }
  viewpoint firmwareDeploymentPerspective { frame firmwareDeployment; }
  viewpoint requirementStructurePerspective { frame requirementStructure; }
  viewpoint safeStopScenarioPerspective { frame safeStopScenario; }

  view productDecomposition : GeneralView {
    doc /* What are the top-level constituents of this robot baseline? Show the physical robot, its
     * six hardware modules and its referenced firmware task group. Module internals are explored
     * in the module views; type names identify reusable definitions without displaying a second
     * definition tree. */
    satisfy productStructurePerspective;
    filter @SysML::PartUsage;
    expose Architecture::robotSystem.physical;
  }

  view baseDecomposition : GeneralView {
    doc /* Which components constitute this robot's base? Show the chassis, two drive trains, caster,
     * four cliff sensors, cleaning head, power module and dock interface in their base context.
     * Electrical routing belongs in interconnections, not in this composition view. */
    satisfy productStructurePerspective;
    filter @SysML::PartUsage;
    expose Architecture::robotSystem.physical.base;
  }

  view topDecomposition : GeneralView {
    doc /* Which sensing and interaction components constitute this robot's top module? Show the
     * bumper, time-of-flight sensors, LiDAR, shell, sensor bus and human-machine interface in
     * their top context. This view answers composition, not signal routing. */
    satisfy productStructurePerspective;
    filter @SysML::PartUsage;
    expose Architecture::robotSystem.physical.top;
  }

  view mainPcbDecomposition : GeneralView {
    doc /* Which board and electronic components constitute this robot's main PCB assembly? Show the
     * bare board, MCU, two motor drivers, IMU, wireless module and wireless link in this
     * assembly context. Procurement choices and circuit routing are outside this view. */
    satisfy productStructurePerspective;
    filter @SysML::PartUsage;
    expose Architecture::robotSystem.physical.mainPcb;
  }

  view powerDecomposition : GeneralView {
    doc /* Which components constitute this robot's power module? Show the battery, BMS, charger, two
     * regulators and SMBus in this power-module context. This view answers composition; the
     * document's power-module interconnection view answers how protected power is distributed. */
    satisfy productStructurePerspective;
    filter @SysML::PartUsage;
    expose Architecture::robotSystem.physical.base.powerModule;
  }

  view interconnections : InterconnectionView {
    doc /* How do the six hardware modules connect at their boundaries? Show the base, main PCB, two
     * harnesses, top and dust bin. Start with module internals closed to follow inter-module
     * power, signals and debris transfer; expand a module only to trace an endpoint inside it.
     * Firmware deployment is shown separately. */
    satisfy productConnectionsPerspective;
    expose Architecture::robotSystem.physical.base;
    expose Architecture::robotSystem.physical.mainPcb;
    expose Architecture::robotSystem.physical.baseHarness;
    expose Architecture::robotSystem.physical.topHarness;
    expose Architecture::robotSystem.physical.top;
    expose Architecture::robotSystem.physical.dustBin;
  }

  view firmwareDeployment : GeneralView {
    doc /* Which processor hosts each of the seven firmware tasks? Show only task usages, the MCU
     * usage and their allocation relationships. Task queues, runtime behavior and reusable task
     * definitions are outside this deployment view. */
    satisfy firmwareDeploymentPerspective;
    filter @SysML::PartUsage or @SysML::AllocationUsage;
    expose Architecture::robotSystem.physical.firmwareTasks.missionController;
    expose Architecture::robotSystem.physical.firmwareTasks.safetySupervisor;
    expose Architecture::robotSystem.physical.firmwareTasks.actuatorControl;
    expose Architecture::robotSystem.physical.firmwareTasks.sensorAcquisition;
    expose Architecture::robotSystem.physical.firmwareTasks.navigation;
    expose Architecture::robotSystem.physical.firmwareTasks.powerManager;
    expose Architecture::robotSystem.physical.firmwareTasks.appService;
    expose Architecture::robotSystem.physical.mainPcb.mcu;
  }

  view systemRequirements : GeneralView {
    doc /* Which 21 system requirements constrain the robot baseline? Show the requirement collection
     * and its individual requirements. Satisfaction, derivation and verification evidence are
     * provided by the document trace tables, not inferred from this inventory. */
    satisfy requirementStructurePerspective;
    filter @SysML::RequirementUsage;
    expose SystemRequirements::robotSystemSpecification;
  }

  view cliffSafeStopScenario : ActionFlowView {
    doc /* How does a cliff observation propagate to stopped actuation and reported safe-stop status?
     * Show the scenario actions, parameter flows and successions. This is the behavioral path;
     * timing budgets and requirement verification are provided separately. */
    satisfy safeStopScenarioPerspective;
    expose OperationalScenarios::CliffSafeStopScenario;
  }
}
