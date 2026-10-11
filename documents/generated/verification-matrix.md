| System requirement | Satisfied by | Verified by |
| --- | --- | --- |
| SYS-001 Cleaning area per charge | OperateCleaningRobot.cleaning | Cleaning coverage |
| SYS-002 Floor coverage | OperateCleaningRobot.navigation | Cleaning coverage |
| SYS-003 Obstacle avoidance | OperateCleaningRobot.perception | Sensor acquisition |
| SYS-004 Localization accuracy | OperateCleaningRobot.navigation | Navigation performance |
| SYS-005 Coverage map maintenance | OperateCleaningRobot.navigation | Navigation performance |
| SYS-006 Wheel stall detection and recovery | OperateCleaningRobot.missionControl | Actuator control, Mission control |
| SYS-007 Return to dock on low battery | OperateCleaningRobot.docking | Docking and charging, Mission control |
| SYS-008 Charging within the battery safe operating area | OperateCleaningRobot.powerManagement | Battery protection, Docking and charging, Safety supervisor |
| SYS-009 Mission status reporting | CliffSafeStopScenario.reportSafeStop, OperateCleaningRobot.userInteraction | App privacy, Cliff safe stop, Mission control |
| SYS-010 Local storage of map data | OperateCleaningRobot.userInteraction | App privacy |
| SYS-011 Overall height | AutonomousFloorCleaningRobot.top | Physical envelope |
| SYS-012 Acoustic noise | BaseModule.cleaningHead | Mobility and acoustics |
| SYS-013 Dust bin capacity | AutonomousFloorCleaningRobot.dustBin | Physical envelope |
| SYS-014 Threshold climbing | OperateCleaningRobot.locomotion | Mobility and acoustics |
| SYS-015 Robot mass | CleaningRobotSystemOfInterest.physical | Physical envelope |
| SYS-016 Recharge time | OperateCleaningRobot.powerManagement | Docking and charging |
| SYS-SAFE-010 Cliff detection | CliffSafeStopScenario.detectCliff, OperateCleaningRobot.perception | Cliff safe stop, Safety supervisor, Sensor acquisition |
| SYS-SAFE-011 Safe stop on hazard | CliffSafeStopScenario.superviseHazard, OperateCleaningRobot.safetySupervision | Actuator control, Cliff safe stop, Safety supervisor |
| SYS-SAFE-012 Battery protection independent of firmware | PowerModule.bms | Battery protection |
