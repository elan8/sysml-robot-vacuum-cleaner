/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * External actors and the residential operating boundary.
 */
package ProductContext {
  private import DomainModel::*;
  private import SystemRequirements::*;
  private import ScalarValues::*;
  private import Elan8::Method::Core::*;

  part def User {
    port app : ~UserInteractionPort;
  }

  part def MobileApp {
    attribute localOnlyModeDefault : Boolean = true;
    port user : UserInteractionPort;
    port robot : ~RobotServicePort;
  }

  part def DockingStation {
    port chargePowerOut : PowerRailPort;
    port homingBeaconOut : GpioPort;
  }

  part def ResidentialEnvironment {
    port stimulus : EnvironmentStimulusPort;
  }

  abstract part def CleaningRobot :> SystemRequirementSubject {
    port app : RobotServicePort;
    port dockPower : PowerRailPort;
    port dockBeacon : GpioPort;
    port environment : ~EnvironmentStimulusPort;
  }

  part def ResidentialCleaningContext {
    @EngineeringConcern { concern = purpose; }
    @AbstractionLevel { level = operational; }
    ref part robot : CleaningRobot;
    part user : User;
    part app : MobileApp;
    part dock : DockingStation;
    part home : ResidentialEnvironment;

    connect user.app to app.user;
    connect app.robot to robot.app;
    connect dock.chargePowerOut to robot.dockPower;
    connect dock.homingBeaconOut to robot.dockBeacon;
    connect home.stimulus to robot.environment;
  }

  part residentialCleaningContext : ResidentialCleaningContext;
}
