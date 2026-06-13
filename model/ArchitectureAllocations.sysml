package ArchitectureAllocations {
  private import FunctionalArchitecture::*;
  private import PhysicalArchitecture::*;
  private import SoftwareCore::*;
  private import EmbeddedComputeDomain::*;

  allocation def SoftwareToComputeNode {
    end software : ExecutableComponent;
    end computeNode : EmbeddedComputeUnit;
  }

  part def AutonomousFloorCleaningRobotSystem {
    part physical : AutonomousFloorCleaningRobot;

    perform action operate : OperateCleaningRobot;
    perform action nominalMission : AutonomousCleaningMission;
    perform action recoveryMission : ObstacleRecoveryMission;
    perform action startMission : StartMission;
    perform action buildMap : BuildMap;
    perform action planCoveragePath : PlanCoveragePath;
    perform action cleanReachableArea : CleanReachableArea;
    perform action avoidDynamicObstacle : AvoidDynamicObstacle;
    perform action recoverFromStall : RecoverFromStall;
    perform action reportMissionStatus : ReportMissionStatus;
    perform action returnToDock : ReturnToDock;
    perform action chargeBattery : ChargeBattery;

    allocate operate.locomotion to physical.driveModule;
    allocate operate.cleaning to physical.cleaningHead;
    allocate operate.perception to physical.sensorAssembly;
    allocate operate.perception to physical.mainElectronics.robotFirmware.mapProcessing;
    allocate operate.navigation to physical.mainElectronics.robotFirmware.localizationEstimator;
    allocate operate.navigation to physical.mainElectronics.robotFirmware.coveragePlanner;
    allocate operate.powerManagement to physical.powerModule;
    allocate operate.docking to physical.dockInterface;
    allocate operate.missionControl to physical.mainElectronics.robotFirmware.applicationFirmware;
    allocate operate.safetySupervision to physical.mainElectronics.robotFirmware.safetySupervisor;
    allocate operate.userInteraction to physical.hmi;
    allocate operate.userInteraction to physical.mainElectronics.robotFirmware.applicationFirmware;

    allocate physical.mainElectronics.robotFirmware.applicationFirmware
        to physical.mainElectronics.mainControlPcb.mcu;
    allocate physical.mainElectronics.robotFirmware.safetySupervisor
        to physical.mainElectronics.mainControlPcb.mcu;
    allocate physical.mainElectronics.robotFirmware.mapProcessing
        to physical.mainElectronics.mainControlPcb.mcu;
    allocate physical.mainElectronics.robotFirmware.localizationEstimator
        to physical.mainElectronics.mainControlPcb.mcu;
    allocate physical.mainElectronics.robotFirmware.coveragePlanner
        to physical.mainElectronics.mainControlPcb.mcu;

    allocate startMission to operate.missionControl;
    allocate buildMap to operate.perception;
    allocate planCoveragePath to operate.navigation;
    allocate cleanReachableArea to operate.cleaning;
    allocate avoidDynamicObstacle to operate.perception;
    allocate recoverFromStall to operate.missionControl;
    allocate reportMissionStatus to operate.userInteraction;
    allocate returnToDock to operate.docking;
    allocate chargeBattery to operate.powerManagement;
  }

  part robotSystem : AutonomousFloorCleaningRobotSystem;
}
