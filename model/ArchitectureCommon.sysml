/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns shared mission items, commands, telemetry, map data, and cyberphysical
 * ports used across functional and physical architecture. Depends only on
 * scalar values. Keep subsystem decomposition and implementation contracts in
 * their dedicated packages.
 */
package ArchitectureCommon {
  private import ScalarValues::*;

  item def OccupancyGrid {
    attribute cellSizeMm : Real;
    attribute cleanedCellPercent : Real;
    attribute unknownCellPercent : Real;
  }
  item def PoseEstimate {
    attribute xMm : Real;
    attribute yMm : Real;
    attribute headingDeg : Real;
    attribute errorMm : Real;
  }
  item def ObstacleObservation {
    attribute rangeMm : Real;
    attribute obstacleHeightMm : Real;
  }
  item def CliffObservation {
    attribute dropHeightMm : Real;
    attribute confidencePercent : Real;
  }
  item def HazardEvent {
    attribute hazardKind : String;
    attribute severity : String;
    attribute detectedWithinMs : Real;
    attribute safeStopRequired : Boolean;
  }
  item def DriveCommand {
    attribute linearVelocityMmPerS : Real;
    attribute angularVelocityDegPerS : Real;
    attribute forceStop : Boolean;
  }
  item def CleaningCommand {
    attribute brushEnabled : Boolean;
    attribute vacuumPowerMode : String;
    attribute requestedPowerW : Real;
  }
  item def MissionStatus {
    attribute stateName : String;
    attribute cleanedAreaPercent : Real;
    attribute userAttentionRequired : Boolean;
  }
  item def UserCommand {
    attribute commandKind : String;
    attribute cloudBackupConsent : Boolean;
  }
  item def BatteryTelemetry {
    attribute stateOfChargePercent : Real;
    attribute packVoltageV : Real;
    attribute chargeCurrentA : Real;
    attribute maxCellTemperatureK : Real;
  }

  port def SensorDataPort {
    out item observation;
  }
  port def MissionCommandPort {
    in item command;
  }
  port def MissionStatusPort {
    out item status;
  }
  port def OdometryPort;
  port def HazardPort;
  port def TelemetryPort;
}
