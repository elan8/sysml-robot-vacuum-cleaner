/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns external actors, home environment, dock/app/cloud context, and boundary
 * interactions around the robot. Depends on shared architecture, realized
 * architecture, physical protocols, and scalar values. Keep internal robot
 * decomposition in architecture packages.
 */
package ProductContext {
  private import ArchitectureCommon::*;
  private import PhysicalArchitecture::*;
  private import Architecture::*;
  private import PhysicalProtocols::*;
  private import ScalarValues::*;

  port def AppServicePort {
    in item command : UserCommand;
    out item status : MissionStatus;
  }

  port def CloudBackupPort {
    in item consent : UserCommand;
    out item status : MissionStatus;
  }

  port def EnvironmentContactPort {
    out item obstacle : ObstacleObservation;
    out item cliff : CliffObservation;
    out item hazard : HazardEvent;
  }

  part def User {
    port appCommand : ~AppServicePort;
  }

  part def MobileApp {
    attribute localOnlyModeDefault : Boolean = true;
    port userLink : AppServicePort;
    port robotLink : ~AppServicePort;
    port cloudBackup : ~CloudBackupPort;
  }

  part def CloudBackupService {
    attribute storesRawMapByDefault : Boolean = false;
    port backupApi : CloudBackupPort;
  }

  part def HomeNetwork {
    attribute connectivityType : String = "BLE plus optional Wi-Fi";
    port appSide : AppServicePort;
    port robotSide : ~AppServicePort;
    connect appSide to robotSide;
  }

  part def DockingStation {
    attribute chargeVoltageV : Real = 19.0;
    attribute maxChargeCurrentA : Real = 2.0;
    port chargePowerOut : PowerRailPort;
    port homingBeaconOut : GpioPort;
  }

  part def FloorSurface {
    attribute surfaceKind : String;
    port contact : EnvironmentContactPort;
  }

  part def StairEdge {
    attribute dropHeightMm : Real = 50.0;
    port cliffExposure : EnvironmentContactPort;
  }

  part def Obstacle {
    attribute obstacleHeightMm : Real = 30.0;
    port obstacleExposure : EnvironmentContactPort;
  }

  part def HomeEnvironment {
    part hardFloor : FloorSurface;
    part carpet : FloorSurface;
    part stairEdge : StairEdge;
    part movableObstacle : Obstacle;
    port environmentStimulus : EnvironmentContactPort;
  }

  part def RobotContextBoundary {
    ref robot : AutonomousFloorCleaningRobot;
    port appService : AppServicePort;
    port dockPowerIn : PowerRailPort;
    port dockBeaconIn : GpioPort;
    port environmentIn : ~EnvironmentContactPort;
  }

  part def ResidentialCleaningContext {
    part robotBoundary : RobotContextBoundary;
    part user : User;
    part app : MobileApp;
    part cloudBackup : CloudBackupService;
    part homeNetwork : HomeNetwork;
    part dock : DockingStation;
    part home : HomeEnvironment;
    connect user.appCommand to app.userLink;
    connect app.robotLink to homeNetwork.appSide;
    connect homeNetwork.robotSide to robotBoundary.appService;
    connect app.cloudBackup to cloudBackup.backupApi;
    connect dock.chargePowerOut to robotBoundary.dockPowerIn;
    connect dock.homingBeaconOut to robotBoundary.dockBeaconIn;
    connect home.environmentStimulus to robotBoundary.environmentIn;
  }

  part residentialCleaningContext : ResidentialCleaningContext;
}
