/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns scenario-level use cases over the robot, user, dock, and environment.
 * Depends on architecture, functional actions, and product context. Keep
 * reusable capability definitions in FunctionalArchitecture.
 */
package OperationalScenarios {
  private import Architecture::*;
  private import FunctionalArchitecture::*;
  private import ProductContext::*;
  private import SystemRequirements::*;

  part def Homeowner;
  part def HomeEnvironment;

  use case def RunAutonomousCleaningMission {
    subject robotSystem : CleaningRobotSystemOfInterest;
    actor homeowner : Homeowner;
    actor home : HomeEnvironment;
    objective {
      doc /*
        Clean reachable floor area with autonomous mapping, hazard supervision,
        recovery behavior, status reporting, and return-to-dock charging.
      */
    }
  }

  action def ObstacleRecoveryScenario :> ObstacleRecoveryMission;

  use case def ReturnToDockOnLowBattery {
    subject context : ProductContext::ResidentialCleaningContext;
    actor homeowner : Homeowner;
    objective {
      doc /*
        When battery state of charge reaches the reserve threshold, the robot reports status,
        homes on the docking station beacon, docks, and begins safe charging without user help.
      */
    }
  }

  use case def LocalOnlyPrivacyMission {
    subject context : ProductContext::ResidentialCleaningContext;
    actor homeowner : Homeowner;
    objective {
      doc /*
        Run a cleaning mission with local map storage only; cloud backup remains disabled unless
        the user explicitly provides consent in the mobile app.
      */
    }
  }

  use case def CliffAndObstacleEncounter {
    subject context : ProductContext::ResidentialCleaningContext;
    actor home : ProductContext::HomeEnvironment;
    objective {
      doc /*
        Encounter furniture, movable clutter, and a stair edge while maintaining bounded speed,
        replanning or stopping before the robot crosses a cliff hazard.
      */
    }
  }

  action def ObserveSafeStop {
    in stopCommand : DriveCommand;
    out stoppedStatus : MissionStatus;
    doc /*
      Observe zero commanded motion and a safety-critical mission status at the
      robot boundary after the safety supervisor issues a forced stop.
    */
  }

  action def CliffSafeStopGoldenThread {
    in cliffStimulus : CliffObservation;
    out reportedStatus : MissionStatus;

    action startMission : StartMission;
    action detectCliff : SenseEnvironment;
    action superviseHazard : SuperviseSafety;
    action applySafeStop : ProvideLocomotion;
    action observeSafeStop : ObserveSafeStop;
    action reportSafeStop : ReportMissionStatus;

    flow detectCliff.hazard to superviseHazard.hazardIn;
    flow superviseHazard.safeCommand to applySafeStop.command;
    flow superviseHazard.safeCommand to observeSafeStop.stopCommand;
    flow observeSafeStop.stoppedStatus to reportSafeStop.status;
    bind reportedStatus = observeSafeStop.stoppedStatus;

    first startMission then detectCliff;
    first detectCliff then superviseHazard;
    first superviseHazard then applySafeStop;
    first applySafeStop then observeSafeStop;
    first observeSafeStop then reportSafeStop;

    doc /*
      Canonical end-to-end demonstration thread: mission start, cliff sensing,
      typed hazard propagation, safety supervision, forced drive stop, observed
      safe state, and user-visible status reporting.
    */
  }

  action cliffSafeStopGoldenThread : CliffSafeStopGoldenThread;

  allocate cliffSafeStopGoldenThread.detectCliff
    to robotSystem.physical.sensorAssembly;
  allocate cliffSafeStopGoldenThread.superviseHazard
    to robotSystem.physical.robotFirmware.safetySupervisor;
  allocate cliffSafeStopGoldenThread.applySafeStop
    to robotSystem.physical.driveModule;
  allocate cliffSafeStopGoldenThread.reportSafeStop
    to robotSystem.physical.robotFirmware.applicationFirmware;

  satisfy detectCliffs by cliffSafeStopGoldenThread.detectCliff;
  satisfy superviseHazards by cliffSafeStopGoldenThread.superviseHazard;
  satisfy reportCleaningStatus by cliffSafeStopGoldenThread.reportSafeStop;

  use case demonstrateCliffSafeStop {
    subject context : ProductContext::ResidentialCleaningContext;
    actor homeowner : Homeowner;
    actor home : ProductContext::HomeEnvironment;
    objective {
      doc /*
        Demonstrate the requirements-to-design-to-evidence path for detecting a
        stair edge, commanding a bounded-latency stop, and reporting the event.
      */
    }
    first start;
    then action executeGoldenThread : CliffSafeStopGoldenThread;
    then done;
  }
}
