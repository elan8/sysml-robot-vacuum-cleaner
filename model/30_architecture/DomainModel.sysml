/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Shared items, ports, protocol media, and closed-set vocabulary.
 */
package DomainModel {
  public import Elan8::Electronics::Interconnection::*;
  public import Elan8::Electronics::Buses::*;
  public import Elan8::Electronics::Io::*;
  public import Elan8::Electronics::Power::*;
  public import Elan8::Electronics::Compute::*;
  public import Elan8::Electronics::Wireless::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  enum def Severity { info; warning; fault; safetyCritical; }
  enum def HazardKind { cliff; bumper; lift; overcurrent; thermal; stall; }
  enum def VacuumPowerMode { off; eco; standard; max; }
  enum def UserCommandKind { start; pause; resume; home; consentChanged; }
  enum def AppMessageKind { command; status; mapSummary; diagnostic; consent; }
  enum def AppProtocolVersion { v1; }

  item def OccupancyGrid {
    attribute cellSizeMm : Real;
    attribute cleanedCellPercent : Real;
    attribute unknownCellPercent : Real;
    constraint { cellSizeMm > 0.0 }
    constraint { cleanedCellPercent >= 0.0 }
    constraint { cleanedCellPercent <= 100.0 }
  }

  item def PoseEstimate {
    attribute xMm : Real;
    attribute yMm : Real;
    attribute headingDeg : Real;
    attribute errorMm : Real;
    constraint { errorMm >= 0.0 }
  }

  item def ObstacleObservation {
    attribute rangeMm : Real;
    attribute obstacleHeightMm : Real;
  }

  item def CliffObservation {
    attribute dropHeightMm : Real;
    attribute confidencePercent : Real;
    constraint { confidencePercent >= 0.0 }
    constraint { confidencePercent <= 100.0 }
  }

  item def HazardEvent {
    attribute hazardKind : HazardKind;
    attribute severity : Severity;
    attribute detectedWithinMs : Real;
    attribute safeStopRequired : Boolean = false;
  }

  item def DriveCommand {
    attribute linearVelocityMmPerS : Real = 0.0;
    attribute angularVelocityDegPerS : Real = 0.0;
    attribute forceStop : Boolean = false;
    constraint { linearVelocityMmPerS >= -350.0 }
    constraint { linearVelocityMmPerS <= 350.0 }
  }

  item def CleaningCommand {
    attribute brushEnabled : Boolean = false;
    attribute vacuumPowerMode : VacuumPowerMode = VacuumPowerMode::off;
    attribute requestedPowerW : Real = 0.0;
    constraint { requestedPowerW >= 0.0 }
  }

  item def MissionStatus {
    attribute operatingState : String;
    attribute cleanedAreaPercent : Real;
    attribute userAttentionRequired : Boolean = false;
  }

  item def UserCommand {
    attribute commandKind : UserCommandKind;
    attribute cloudBackupConsent : Boolean = false;
  }

  item def BatteryTelemetry {
    attribute stateOfChargePercent : Real;
    attribute packVoltageV : Real;
    attribute chargeCurrentA : Real;
    attribute maxCellTemperatureK : Real;
    constraint { stateOfChargePercent >= 0.0 }
    constraint { stateOfChargePercent <= 100.0 }
  }

  item def LidarScanFrame {
    attribute scanSequence : Integer;
    attribute scanRateHz : Real;
    attribute rangeSampleCount : Integer;
    attribute includesRawImageData : Boolean = false;
    constraint { scanRateHz > 0.0 }
    constraint { rangeSampleCount > 0 }
  }

  item def MapUpdate {
    attribute sequenceNumber : Integer;
    attribute changedCellCount : Integer;
    attribute includesRawHomeMap : Boolean = false;
    constraint { changedCellCount >= 0 }
  }

  item def DiagnosticEvent {
    attribute diagnosticCode : String;
    attribute severity : Severity;
    attribute latched : Boolean = false;
  }

  item def AppMessage {
    attribute messageKind : AppMessageKind;
    attribute protocolVersion : AppProtocolVersion = AppProtocolVersion::v1;
    attribute requiresConsent : Boolean = false;
  }

  port def UserServicePort {
    in item command : UserCommand;
    out item status : MissionStatus;
  }

  port def HazardPort {
    out item hazard : HazardEvent;
  }

  port def OdometryPort {
    out item odometry : PoseEstimate;
  }

  port def TelemetryPort {
    out item telemetry : BatteryTelemetry;
  }

  port def AppServicePort {
    in item command : UserCommand;
    out item status : MissionStatus;
  }

  port def EnvironmentPort {
    out item obstacle : ObstacleObservation;
    out item cliff : CliffObservation;
  }

  part def SensorI2cBus :> I2cBus {
    port host : ~I2cControllerPort;
    port frontTof : ~I2cTargetPort;
    port leftTof : ~I2cTargetPort;
    port rightTof : ~I2cTargetPort;
    port imu : ~I2cTargetPort;
  }

  part def BmsSmbusBus :> SmbusBus {
    port host : I2cControllerPort;
    port bms : ~I2cTargetPort;
  }

  part def LidarUartBus :> UartBus {
    port host : UartPort;
    port lidar : UartPort;
  }

  part def WirelessUartBus :> UartBus {
    port host : UartPort;
    port wireless : UartPort;
  }
}
