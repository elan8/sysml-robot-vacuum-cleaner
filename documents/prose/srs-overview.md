The robot performs nine functions, which together form its operating behaviour ({{FunctionalArchitecture::OperateCleaningRobot}}):

- **locomotion**, driving and steering the robot;
- **cleaning**, brushing and vacuuming the floor;
- **perception**, sensing obstacles, drops and the surrounding space;
- **navigation**, mapping the home, locating the robot in it and planning its path;
- **power management**, supplying the robot and charging its battery;
- **docking**, finding the docking station and connecting to it;
- **mission control**, sequencing a cleaning mission from start to finish;
- **safety supervision**, stopping the robot when a hazard is detected;
- **user interaction**, accepting commands and reporting status.

Each system requirement is satisfied by one of these functions; the allocation of functions to hardware and firmware is described in RVC-SDS-001.
