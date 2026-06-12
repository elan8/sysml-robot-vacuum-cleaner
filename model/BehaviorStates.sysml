package BehaviorStates {
  state def Idle;
  state def Mapping;
  state def Cleaning;
  state def Paused;
  state def Recovering;
  state def SafeStop;
  state def BinFull;
  state def ReturningToDock;
  state def Docking;
  state def Charging;
  state def Fault;

  state def RobotOperatingBehavior {
    state idle;
    state selfTest;
    state mapping;
    state cleaning;
    state paused;
    state recovering;
    state safeStop;
    state binFull;
    state returning;
    state docking;
    state charging;
    state fault;
    transition start_mission first idle then selfTest;
    transition self_test_passed first selfTest then mapping;
    transition self_test_failed first selfTest then fault;
    transition mapping_complete first mapping then cleaning;
    transition user_pause first cleaning then paused;
    transition user_resume first paused then cleaning;
    transition obstacle_stall first cleaning then recovering;
    transition recovery_complete first recovering then cleaning;
    transition recovery_failed first recovering then safeStop;
    transition hazard_detected first cleaning then safeStop;
    transition safe_stop_cleared first safeStop then recovering;
    transition bin_full first cleaning then binFull;
    transition bin_emptied first binFull then cleaning;
    transition low_battery first cleaning then returning;
    transition low_battery_from_pause first paused then returning;
    transition at_dock first returning then docking;
    // Transition name must not be `docked` (parser keyword conflict).
    transition to_charging first docking then charging;
    transition charged first charging then idle;
    transition unrecoverable_fault first safeStop then fault;
    transition service_reset first fault then idle;
  }
}
