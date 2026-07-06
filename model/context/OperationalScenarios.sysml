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
}
