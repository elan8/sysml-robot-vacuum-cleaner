/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Requirements allocated to the modules of the robot. A system requirement
 * that no single module can meet alone is split into budgets, one for each
 * module on the path. Each module specification constrains a design value of
 * its module against its budget, so a module team can work against its own
 * specification. The derivations from the system requirements are in
 * RequirementTraceability.
 */
package ModuleBudgets {
  private import Elan8::Units::Engineering::*;
  private import DesignLimits::*;
  private import ISQ::*;
  private import SI::*;
  private import NumericalFunctions::*;

  // Safe stop: 100 ms from hazard to standstill command, of which 10 ms is unallocated margin.
  attribute cliffSensingBudget : DurationValue = 25 [ms];
  attribute supervisorDecisionBudget : DurationValue = 10 [ms];
  attribute driveDisableBudget : DurationValue = 5 [ms];
  attribute brakingBudget : DurationValue = 50 [ms];
  attribute allocatedSafeStopTime : DurationValue =
    sum(cliffSensingBudget, supervisorDecisionBudget, driveDisableBudget, brakingBudget);

  // Mass: 4.0 kg, fully allocated; the margin is held inside each module budget.
  attribute baseMassBudget : MassValue = 2.75 [kg];
  attribute topMassBudget : MassValue = 0.60 [kg];
  attribute mainPcbMassBudget : MassValue = 0.25 [kg];
  attribute dustBinMassBudget : MassValue = 0.22 [kg];
  attribute harnessMassBudget : MassValue = 0.18 [kg];
  attribute allocatedMass : MassValue =
    sum(baseMassBudget, topMassBudget, mainPcbMassBudget, dustBinMassBudget, harnessMassBudget);

  // Height: 95 mm overall, split at the parting line between base and top.
  attribute baseHeightBudget : LengthValue = 57 [mm];
  attribute topHeightBudget : LengthValue = 38 [mm];
  attribute allocatedHeight : LengthValue = baseHeightBudget + topHeightBudget;

  // Energy and charging.
  attribute minBatteryCapacity : ElectricChargeValue = batteryCapacityBudget;
  attribute minChargeCurrent : ElectricCurrentValue = 2 [A];

  assert constraint safeStopBudgetCloses { allocatedSafeStopTime <= maxSafeStopReactionTime }
  assert constraint massBudgetCloses { allocatedMass <= maxRobotMass }
  assert constraint heightBudgetCloses { allocatedHeight <= maxOverallHeight }
}

package ModuleRequirements {
  private import Elan8Method::Metadata::*;
  private import ModuleBudgets::*;
  private import PhysicalArchitecture::*;
  private import FirmwareArchitecture::*;
  private import ISQ::*;
  private import SI::*;

  requirement baseModuleSpecification {
    subject base : BaseModule;

    requirement <'BASE-001'> 'Cliff sensing latency' {
      @RequirementRole { role = safety; }
      require constraint { base.cliffSensingLatency <= cliffSensingBudget }
      doc /* The base module shall assert a cliff or wheel-drop hazard signal within 25 ms of the hazard appearing under a sensor. */
    }

    requirement <'BASE-002'> 'Drive braking time' {
      @RequirementRole { role = safety; }
      require constraint { base.brakingTime <= brakingBudget }
      doc /* The base module shall bring both drive wheels to standstill within 50 ms of the drive outputs being disabled at cleaning speed. */
    }

    requirement <'BASE-003'> 'Base module mass' {
      @RequirementRole { role = 'interface'; }
      require constraint { base.mass <= baseMassBudget }
      doc /* The base module shall have a mass of at most 2.75 kg including the battery pack. */
    }

    requirement <'BASE-004'> 'Base module height' {
      @RequirementRole { role = 'interface'; }
      require constraint { base.height <= baseHeightBudget }
      doc /* The base module shall be at most 57 mm high from the floor to the parting line with the top module. */
    }

    requirement <'BASE-005'> 'Battery capacity' {
      @RequirementRole { role = performance; }
      require constraint { base.powerModule.battery.nominalCapacity >= minBatteryCapacity }
      doc /* The power module shall hold a battery pack with a rated capacity of at least 6400 mAh. */
    }

    requirement <'BASE-006'> 'Charge current' {
      @RequirementRole { role = performance; }
      require constraint { base.powerModule.charger.maxChargeCurrent >= minChargeCurrent }
      doc /* The power module shall charge the battery pack with at least 2 A in the constant-current phase. */
    }
  }

  requirement mainPcbSpecification {
    subject board : MainPcbModule;

    requirement <'PCB-001'> 'Drive disable latency' {
      @RequirementRole { role = safety; }
      require constraint { board.driveDisableLatency <= driveDisableBudget }
      doc /* The main board shall remove drive from both motors within 5 ms of the safe-stop command, through a disable line that does not depend on the motion-control loop. */
    }

    requirement <'PCB-002'> 'Main board mass' {
      @RequirementRole { role = 'interface'; }
      require constraint { board.mass <= mainPcbMassBudget }
      doc /* The assembled main board shall have a mass of at most 0.25 kg. */
    }
  }

  requirement firmwareSpecification {
    subject firmware : FirmwareTaskArchitecture;

    requirement <'FW-001'> 'Safety supervisor deadline' {
      @RequirementRole { role = safety; }
      require constraint { firmware.safetySupervisor.deadline <= supervisorDecisionBudget }
      doc /* The safety supervisor task shall issue the safe-stop command within 10 ms of a hazard event entering its queue, under worst-case load of all other tasks. */
    }
  }

  requirement topModuleSpecification {
    subject top : TopModule;

    requirement <'TOP-001'> 'Top module height' {
      @RequirementRole { role = 'interface'; }
      require constraint { top.height <= topHeightBudget }
      doc /* The top module shall rise at most 38 mm above the parting line, including the laser scanner turret. */
    }

    requirement <'TOP-002'> 'Top module mass' {
      @RequirementRole { role = 'interface'; }
      require constraint { top.mass <= topMassBudget }
      doc /* The top module shall have a mass of at most 0.60 kg. */
    }
  }

  requirement dustBinSpecification {
    subject bin : DustBin;

    requirement <'BIN-001'> 'Dust bin mass' {
      @RequirementRole { role = 'interface'; }
      require constraint { bin.mass <= dustBinMassBudget }
      doc /* The empty dust bin with its filter shall have a mass of at most 0.22 kg. */
    }
  }

  requirement harnessSpecification {
    subject robot : AutonomousFloorCleaningRobot;

    requirement <'HAR-001'> 'Wiring harness mass' {
      @RequirementRole { role = 'interface'; }
      require constraint { robot.baseHarness.mass + robot.topHarness.mass <= harnessMassBudget }
      doc /* The base and top wiring harnesses together shall have a mass of at most 0.18 kg. */
    }
  }
}
