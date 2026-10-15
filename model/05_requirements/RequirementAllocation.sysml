/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * The allocation of system requirements to module requirements: one
 * derivation for each system requirement that is split into module budgets,
 * with the reason the budgets close. The budgets are in ModuleBudgets and the
 * module requirements in ModuleRequirements.
 */
package RequirementAllocation {
  private import RequirementDerivation::*;
  private import ModelingMetadata::*;
  private import SystemRequirements::*;
  private import ModuleRequirements::*;

  connection safeStopAllocation : Derivation {
    @Rationale { text = "The 100 ms from hazard to standstill is a chain of four steps in three modules: sensing 25 ms, supervisor decision 10 ms, drive disable 5 ms and braking 50 ms. The budgets add up to 90 ms, which leaves 10 ms unallocated margin."; }
    end :>> Derivation::originalRequirement ::> robotSystemSpecification.'Safe stop on hazard';
    end #derive derived1 ::> baseModuleSpecification.'Cliff sensing latency';
    end #derive derived2 ::> firmwareSpecification.'Safety supervisor deadline';
    end #derive derived3 ::> mainPcbSpecification.'Drive disable latency';
    end #derive derived4 ::> baseModuleSpecification.'Drive braking time';
  }

  connection massAllocation : Derivation {
    @Rationale { text = "Every gram of the robot belongs to one of five budgets, and the budgets add up to the 4.0 kg limit. Margin is held inside each module budget, so a module that grows has to renegotiate with the others rather than use up a common reserve unnoticed."; }
    end :>> Derivation::originalRequirement ::> robotSystemSpecification.'Robot mass';
    end #derive derived1 ::> baseModuleSpecification.'Base module mass';
    end #derive derived2 ::> topModuleSpecification.'Top module mass';
    end #derive derived3 ::> mainPcbSpecification.'Main board mass';
    end #derive derived4 ::> dustBinSpecification.'Dust bin mass';
    end #derive derived5 ::> harnessSpecification.'Wiring harness mass';
  }

  connection heightAllocation : Derivation {
    @Rationale { text = "The overall height is the base module up to the parting line plus the top module above it. The split at 57 mm follows the drive wheel diameter and the battery pack; the remaining 38 mm is for the shell and the scanner turret."; }
    end :>> Derivation::originalRequirement ::> robotSystemSpecification.'Overall height';
    end #derive derived1 ::> baseModuleSpecification.'Base module height';
    end #derive derived2 ::> topModuleSpecification.'Top module height';
  }

  connection energyAllocation : Derivation {
    @Rationale { text = "The mission energy analysis shows that 80 m² at an average of 2.6 A takes 4875 mAh. With a 15 % reserve for the return to the dock this needs a 6400 mAh pack."; }
    end :>> Derivation::originalRequirement ::> robotSystemSpecification.'Cleaning area per charge';
    end #derive derived1 ::> baseModuleSpecification.'Battery capacity';
  }

  connection rechargeAllocation : Derivation {
    @Rationale { text = "Recharging 85 % of 6400 mAh within 4 hours, including the constant-voltage tail, needs at least 2 A in the constant-current phase."; }
    end :>> Derivation::originalRequirement ::> robotSystemSpecification.'Recharge time';
    end #derive derived1 ::> baseModuleSpecification.'Charge current';
  }
}
