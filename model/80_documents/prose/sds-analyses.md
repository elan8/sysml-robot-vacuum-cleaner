Four analyses in the model support the design. Each compares a calculated value with a design limit of RVC-SRS-001. The input values are design estimates, not measurements.

**Mission energy** ({{RobotAnalysisCases::MissionEnergyAnalysis}}). An average current of 2.6 A over a mission of 1.875 hours draws 4 875 mAh. The budget of 6 400 mAh less a 15 percent reserve leaves 5 440 mAh, so the mission fits with a margin of 565 mAh.

**Safety reaction** ({{RobotAnalysisCases::SafetyReactionAnalysis}}). The analysis adds the design values of the four steps of the safe stop, taken from the modules: 20 ms, 10 ms, 2 ms and 40 ms, together 72 ms against the 100 ms limit.

**Localization performance** ({{RobotAnalysisCases::LocalizationPerformanceAnalysis}}). The selected combination of time-of-flight sensors, laser scanner, inertial measurement and odometry gives an estimated error of 95 mm against a limit of 150 mm.

**Mass budget** ({{RobotAnalysisCases::MassBudgetAnalysis}}). The module masses are rolled up from the parts of the bill of materials and compared with the mass limit. The table below is generated from the same values.
