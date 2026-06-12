package ArchitectureCommon {
  interface def PowerInterface;
  interface def DataInterface;
  interface def CommandInterface;
  connection def PowerConnection;
  connection def DataConnection;
  connection def CommandConnection;

  item def OccupancyGrid;
  item def PoseEstimate;
  item def ObstacleObservation;
  item def CliffObservation;
  item def HazardEvent;
  item def DriveCommand;
  item def CleaningCommand;
  item def MissionStatus;
  item def UserCommand;
  item def BatteryTelemetry;

  port def PowerLoadPort {
    in item electricalPower;
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
  port def MotorControlPort;
  port def TelemetryPort;
}
