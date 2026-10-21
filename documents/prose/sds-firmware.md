The firmware runs on the microcontroller of the main control board as seven tasks under a fixed-priority real-time scheduler. The seven tasks are allocated to the scheduler execution platform, which is allocated to the microcontroller. Tasks communicate only through typed message queues.

- **Safety supervisor**, event-driven, deadline 10 ms, highest priority. Receives every hazard and issues the safe command.
- **Actuator control**, every 20 ms. Drives the wheel and cleaning motors and detects stalls.
- **Sensor acquisition**, every 20 ms. Reads the cliff, time-of-flight, bumper and inertial sensors and the LiDAR.
- **Mission controller**, event-driven, deadline 50 ms. Sequences the mission and arbitrates between planner and safety commands.
- **Power manager**, every 100 ms. Monitors the battery and controls charging.
- **Navigation**, every 50 ms. Maintains the map and pose and plans the path.
- **Application service**, event-driven, deadline 100 ms, lowest priority. Serves the mobile application.

Hazards travel on their own queue from sensor acquisition to the safety supervisor, and the safe command travels on its own queue to mission control. Neither shares a queue with planner or user traffic, so a busy planner cannot delay a stop.
