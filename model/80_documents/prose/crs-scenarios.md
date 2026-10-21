Four scenarios describe how the household expects the robot to behave. They are the basis for the customer requirements and for validating the finished product.

**Autonomous cleaning.** The user starts a mission. The robot maps the home, cleans the reachable floor, reports its progress and returns to the dock when it has finished ({{OperationalScenarios::runAutonomousCleaning}}).

**Unexpected obstacle.** Furniture, a toy or a cable blocks the planned path. The robot detects it, plans around it and continues without collision ({{OperationalScenarios::avoidUnexpectedObstacle}}).

**Low battery.** The battery runs low before the mission is complete. The robot stops cleaning, returns to the dock and recharges without help ({{OperationalScenarios::returnForLowBattery}}).

**Stair edge.** The robot approaches a drop such as the top of a staircase. It stops before a wheel crosses the edge and tells the user what happened ({{OperationalScenarios::respondToCliffHazard}}).
