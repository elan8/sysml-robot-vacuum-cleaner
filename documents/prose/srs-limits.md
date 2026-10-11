The requirements refer to the following limit values. They are defined once in the model ({{DesignLimits::cleaningAreaTarget}} and its siblings) and used by the requirements, the analyses and the verification cases, so a change to a limit propagates to all three. The values in this list are read from the model when the document is built.

- Cleaning area on one charge: at least 80 m².
- Coverage of the reachable floor: at least {{= DesignLimits::floorCoverageTargetPercent}} percent.
- Smallest obstacle to be avoided: {{= DesignLimits::minimumAvoidedObstacleHeight}} high.
- Smallest drop to be detected: {{= DesignLimits::minimumCliffHeight}}.
- Reaction time from hazard to safe stop: at most {{= DesignLimits::maxSafeStopReactionTime}}.
- Localization error during the reference mission: at most {{= DesignLimits::maxLocalizationError}}.
- Time to detect a stalled wheel: at most {{= DesignLimits::maxWheelStallDetectionTime}}.
- State of charge at which the robot returns to the dock: {{= DesignLimits::lowBatteryReturnThresholdPercent}} percent.
- Battery capacity budget: {{= DesignLimits::batteryCapacityBudget}}.
- Overall height: at most {{= DesignLimits::maxOverallHeight}}.
- Sound pressure level while cleaning a hard floor, at 1 m: at most {{= DesignLimits::maxSoundPressureLevel}}(A).
- Dust bin capacity: at least {{= DesignLimits::minDustBinCapacity}}.
- Rigid threshold the robot crosses: at least {{= DesignLimits::minClimbableThreshold}}.
- Robot mass with an empty dust bin: at most {{= DesignLimits::maxRobotMass}}.
- Recharge time from the return threshold to full: at most {{= DesignLimits::maxRechargeTime}}.
