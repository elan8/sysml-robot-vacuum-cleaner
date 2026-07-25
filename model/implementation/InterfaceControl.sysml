/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns software-facing message item types, message enumerations, and the typed
 * data-flow contract connection for commands, status, telemetry, maps, hazards,
 * diagnostics, and app messages. Producer/consumer ownership is asserted by
 * firmware task flows in FirmwareArchitecture. Depends on shared architecture
 * items and software library concepts. Keep PCB harness ICD notes on physical
 * architecture ports.
 */
package InterfaceControl {
  private import ArchitectureCommon::*;
  private import SoftwareCore::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  // Message-layer enumerations (shared mission enums live in ArchitectureCommon).
  enum def AppMessageKind { command; status; mapSummary; diagnostic; consent; }
  enum def ObstacleClassName { cable; petWaste; shoe; unknown; }

  item def MapUpdate {
    attribute sequenceNumber : Integer;
    attribute changedCellCount : Integer;
    attribute includesRawHomeMap : Boolean;
  }

  item def DiagnosticEvent {
    attribute diagnosticCode : String;
    attribute severity : Severity;
    attribute latched : Boolean;
  }

  item def AppMessage {
    attribute messageKind : AppMessageKind;
    attribute protocolVersion : String;
    attribute requiresConsent : Boolean;
  }

  item def LidarScanFrame {
    attribute scanSequence : Integer;
    attribute scanRateHz : Real;
    attribute rangeSampleCount : Integer;
    attribute includesRawImageData : Boolean;
  }

  item def PoseGraphUpdate {
    attribute nodeCount : Integer;
    attribute loopClosureCandidateCount : Integer;
    attribute mapStabilityScore : Real;
  }

  item def ObstacleClassEvent {
    attribute className : ObstacleClassName;
    attribute confidencePercent : Real;
    attribute sourceSensor : String;
  }

  // A data contract is a typed connection between a producing and consuming
  // software feature carrying a specific payload item. Producer/consumer
  // ownership by firmware tasks is asserted in FirmwareArchitecture via flows.
  connection def DataFlowContract {
    doc /*
      Typed software data contract. Concrete usages bind producer and consumer
      directly to the firmware action parameters that participate in the flow;
      their typing identifies the payload without a parallel string field.
      allowedValues captures contract constraints that are not yet expressible
      as an enum or range.
    */
    end producer;
    end consumer;
    attribute period : DurationValue;
    attribute maxLatency : DurationValue;
    attribute privacySensitive : Boolean;
    attribute allowedValues : String;
  }
}
