package Architecture {
  private import SystemRequirements::*;
  private import BehaviorStates::*;
  private import MonetaryUnits::*;
  private import ISQ::*;
  private import SI::*;

  interface def PowerInterface;
  interface def DataInterface;
  interface def CommandInterface;
  connection def PowerConnection;
  connection def DataConnection;
  connection def CommandConnection;

  part def RobotSubsystem {
    doc /*
      Shared roll-up attributes for robot subsystems (power, mass, BOM).
      Specialized by each physical or logical subsystem below.
    */
    attribute powerDrawW : PowerValue;
    attribute massKg : MassValue;
    attribute bomCost : MonetaryAmount;
  }

  part def MobilitySubsystem :> RobotSubsystem {
    attribute drivePowerW : PowerValue = 28 [W];
    attribute :>> powerDrawW = 28 [W];
    attribute :>> massKg = 1.2 [kg];
    attribute :>> bomCost = 120 [EUR];
    port powerIn;
    port commandIn;
  }
  part def CleaningSubsystem :> RobotSubsystem {
    attribute brushPowerW : PowerValue = 12 [W];
    attribute vacuumPowerW : PowerValue = 6 [W];
    attribute :>> powerDrawW = 18 [W];
    attribute :>> massKg = 0.9 [kg];
    attribute :>> bomCost = 75 [EUR];
    port powerIn;
    port commandIn;
  }
  part def PerceptionSubsystem :> RobotSubsystem {
    attribute :>> powerDrawW = 0 [W];
    attribute :>> massKg = 0.25 [kg];
    attribute :>> bomCost = 35 [EUR];
    port powerIn;
    port mapOut;
    port obstacleOut;
  }
  part def NavigationSubsystem :> RobotSubsystem {
    attribute :>> powerDrawW = 0 [W];
    attribute :>> massKg = 0.15 [kg];
    attribute :>> bomCost = 25 [EUR];
    port powerIn;
    port mapIn;
    port obstacleIn;
    port commandOut;
  }
  part def PowerSubsystem :> RobotSubsystem {
    attribute electronicsPowerW : PowerValue = 8 [W];
    attribute :>> powerDrawW = 8 [W];
    attribute :>> massKg = 0.55 [kg];
    attribute :>> bomCost = 60 [EUR];
    port powerOut;
  }
  part def DockingSubsystem :> RobotSubsystem {
    attribute :>> powerDrawW = 0 [W];
    attribute :>> massKg = 0.35 [kg];
    attribute :>> bomCost = 18 [EUR];
    port powerIn;
    port dockStatusOut;
  }
  part def ControlSoftware :> RobotSubsystem {
    attribute :>> powerDrawW = 0 [W];
    attribute :>> massKg = 0.15 [kg];
    attribute :>> bomCost = 12 [EUR];
    port powerIn;
    port commandOut;
    port statusOut;
    exhibit state behavior : RobotOperatingBehavior;
  }
  part def UserInterface :> RobotSubsystem {
    attribute :>> powerDrawW = 0 [W];
    attribute :>> massKg = 0.65 [kg];
    attribute :>> bomCost = 4 [EUR];
    port statusIn;
    port userCommandOut;
  }

  part def AutonomousFloorCleaningRobot {
    part mobility : MobilitySubsystem;
    part cleaning : CleaningSubsystem;
    part perception : PerceptionSubsystem;
    part navigation : NavigationSubsystem;
    part power : PowerSubsystem;
    part docking : DockingSubsystem;
    part control : ControlSoftware;
    part userInterface : UserInterface;
    connect power.powerOut to mobility.powerIn;
    connect power.powerOut to cleaning.powerIn;
    connect power.powerOut to perception.powerIn;
    connect power.powerOut to navigation.powerIn;
    connect power.powerOut to docking.powerIn;
    connect power.powerOut to control.powerIn;
    connect perception.mapOut to navigation.mapIn;
    connect perception.obstacleOut to navigation.obstacleIn;
    connect navigation.commandOut to control.commandOut;
    connect control.commandOut to mobility.commandIn;
    connect control.commandOut to cleaning.commandIn;
    connect control.statusOut to userInterface.statusIn;
    connect userInterface.userCommandOut to control.commandOut;
    connect docking.dockStatusOut to control.statusOut;
  }

  part robot : AutonomousFloorCleaningRobot;

  satisfy robot.mobility by coverFloor;
  satisfy robot.cleaning by cleanAtLeastEighty;
  satisfy robot.perception by avoidObstacles;
  satisfy robot.navigation by coverFloor;
  satisfy robot.power by cleanAtLeastEighty;
  satisfy robot.docking by returnToDock;
  satisfy robot.control by detectDustBin;
  satisfy robot.userInterface by reportCleaningStatus;
  satisfy robot by limitBomCost;
  satisfy robot by limitTotalMass;
}
