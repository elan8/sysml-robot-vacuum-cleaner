Three analyses in the model support the design. Each compares a calculated value with a design limit of RVC-SRS-001. The input values are design estimates, not measurements.

**Mission energy** ({{RobotAnalysisCases::MissionEnergyAnalysis}}). An average current of 5 A over a mission of 1.875 hours draws 9 375 mAh. The budget of 12 500 mAh less a 15 percent reserve leaves 10 625 mAh, so the mission fits with margin.

**Safety reaction** ({{RobotAnalysisCases::SafetyReactionAnalysis}}). Sensor detection (25 ms), queueing and scheduling (10 ms), the safety task (5 ms) and motor disable (50 ms) add up to 90 ms, within the 100 ms limit.

**Localization performance** ({{RobotAnalysisCases::LocalizationPerformanceAnalysis}}). The selected combination of time-of-flight sensors, LiDAR, inertial measurement and odometry gives an estimated error of 95 mm against a limit of 150 mm.
