package Architecture {
  public import ArchitectureCommon::*;
  public import FunctionalArchitecture::*;
  public import PhysicalArchitecture::*;
  public import ArchitectureAllocations::*;
  private import SystemRequirements::*;

  part robot : AutonomousFloorCleaningRobot;

  satisfy robot by limitBomCost;
  satisfy robot by limitTotalMass;
}
