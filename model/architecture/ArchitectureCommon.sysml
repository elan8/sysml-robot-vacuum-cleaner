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

  // Shared closed-set vocabulary used by mission items across the model.
  enum def Severity { info; warning; fault; safetyCritical; }
  enum def HazardKind { cliff; bumper; lift; overcurrent; thermal; stall; privacy; }
  enum def VacuumPowerMode { eco; standard; max; off; }
  enum def UserCommandKind { start; pause; resume; home; emptyBinConfirmed; consentChanged; }

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
    attribute hazardKind : HazardKind;
    attribute severity : Severity;
    attribute detectedWithinMs : Real;
    attribute safeStopRequired : Boolean;
  }
  item def DriveCommand {
    attribute linearVelocityMmPerS : Real = 0.0;
    attribute angularVelocityDegPerS : Real = 0.0;
    attribute forceStop : Boolean = false;
    constraint { linearVelocityMmPerS >= -350.0 }
    constraint { linearVelocityMmPerS <= 350.0 }
  }
  item def CleaningCommand {
    attribute brushEnabled : Boolean;
    attribute vacuumPowerMode : VacuumPowerMode;
    attribute requestedPowerW : Real;
  }
  item def MissionStatus {
    attribute stateName : String;
    attribute cleanedAreaPercent : Real;
    attribute userAttentionRequired : Boolean;
  }
  item def UserCommand {
    attribute commandKind : UserCommandKind;
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
  port def OdometryPort {
    out item odometry : PoseEstimate;
  }
  port def HazardPort {
    out item hazard : HazardEvent;
  }
  port def TelemetryPort {
    out item telemetry : BatteryTelemetry;
  }
}
