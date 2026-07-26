/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * External actors and the residential operating boundary.
 */
package ProductContext {
  private import DomainModel::*;
  private import PhysicalArchitecture::*;
  private import ScalarValues::*;

  part def User {
    port app : ~AppServicePort;
  }

  part def MobileApp {
    attribute localOnlyModeDefault : Boolean = true;
    port user : AppServicePort;
    port robot : ~AppServicePort;
  }

  part def HomeNetwork {
    port app : AppServicePort;
    port robot : ~AppServicePort;
    connect app to robot;
  }

  part def DockingStation {
    port chargePowerOut : PowerRailPort;
    port homingBeaconOut : GpioPort;
  }

  part def HomeEnvironment {
    attribute includesStairEdge : Boolean = true;
    attribute includesMovableObstacles : Boolean = true;
    port stimulus : EnvironmentPort;
  }

  part def RobotContextBoundary {
    ref robot : AutonomousFloorCleaningRobot;
    port app : AppServicePort;
    port dockPower : PowerRailPort;
    port dockBeacon : GpioPort;
    port environment : ~EnvironmentPort;
  }

  part def ResidentialCleaningContext {
    part robotBoundary : RobotContextBoundary;
    part user : User;
    part app : MobileApp;
    part network : HomeNetwork;
    part dock : DockingStation;
    part home : HomeEnvironment;

    connect user.app to app.user;
    connect app.robot to network.app;
    connect network.robot to robotBoundary.app;
    connect dock.chargePowerOut to robotBoundary.dockPower;
    connect dock.homingBeaconOut to robotBoundary.dockBeacon;
    connect home.stimulus to robotBoundary.environment;
  }

  part residentialCleaningContext : ResidentialCleaningContext;
}
