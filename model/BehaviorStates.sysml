package BehaviorStates {
  state def Idle;
  state def Mapping;
  state def Cleaning;
  state def ReturningToDock;
  state def Docking;
  state def Charging;

  state def RobotOperatingBehavior {
    state idle;
    state mapping;
    state cleaning;
    state returning;
    state docking;
    state charging;
    transition start_mapping first idle then mapping;
    transition mapping_complete first mapping then cleaning;
    transition low_battery first cleaning then returning;
    transition at_dock first returning then docking;
    // Transition name must not be `docked` (parser keyword conflict).
    transition to_charging first docking then charging;
    transition charged first charging then idle;
  }
}
