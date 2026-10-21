The operating behaviour is decomposed into nine functions that exchange typed items: maps and obstacles from perception to navigation, drive commands from navigation through mission control to locomotion, and hazards from every source to safety supervision.

Each function is allocated to the elements that perform it:

- **Locomotion:** the base module and the actuator-control task.
- **Cleaning:** the cleaning head and the actuator-control task.
- **Perception:** the sensors of the base and top modules and the sensor-acquisition task.
- **Navigation:** the navigation task.
- **Power management:** the power module and the power-manager task.
- **Docking:** the dock interface.
- **Mission control:** the mission-controller task.
- **Safety supervision:** the safety-supervisor task.
- **User interaction:** the human-machine interface and the application-service task.
