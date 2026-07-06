/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns operating lifecycle and detailed behavior fragments for startup, safety,
 * docking, and mission execution. Depends only on core language constructs.
 * Keep structural allocation and verification evidence in their own packages.
 */
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

  item def StartMissionEvent;
  item def SelfTestPassedEvent;
  item def SelfTestFailedEvent;
  item def MappingCompleteEvent;
  item def UserPauseEvent;
  item def UserResumeEvent;
  item def ObstacleStallEvent;
  item def RecoveryCompleteEvent;
  item def RecoveryFailedEvent;
  item def HazardDetectedEvent;
  item def SafeStopClearedEvent;
  item def BinFullEvent;
  item def BinMissingEvent;
  item def BinLatchedEvent;
  item def LowBatteryEvent;
  item def DockDetectedEvent;
  item def ChargeCompleteEvent;
  item def ServiceResetEvent;
  item def CloudConsentChangedEvent;

  state def RobotOperatingBehavior {
    entry;
    then idle;
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
    transition start_mission first idle accept StartMissionEvent then selfTest;
    transition self_test_passed first selfTest accept SelfTestPassedEvent then mapping;
    transition self_test_failed first selfTest accept SelfTestFailedEvent then fault;
    transition mapping_complete first mapping accept MappingCompleteEvent then cleaning;
    transition user_pause first cleaning accept UserPauseEvent then paused;
    transition user_resume first paused accept UserResumeEvent then cleaning;
    transition obstacle_stall first cleaning accept ObstacleStallEvent then recovering;
    transition recovery_complete first recovering accept RecoveryCompleteEvent then cleaning;
    transition recovery_failed first recovering accept RecoveryFailedEvent then safeStop;
    transition hazard_detected first cleaning accept HazardDetectedEvent then safeStop;
    transition safe_stop_cleared first safeStop accept SafeStopClearedEvent then recovering;
    transition bin_full first cleaning accept BinFullEvent then binFull;
    transition bin_missing first cleaning accept BinMissingEvent then binFull;
    transition bin_latched first binFull accept BinLatchedEvent then cleaning;
    transition low_battery first cleaning accept LowBatteryEvent then returning;
    transition low_battery_from_pause first paused accept LowBatteryEvent then returning;
    transition at_dock first returning accept DockDetectedEvent then docking;
    // Transition name must not be `docked` (parser keyword conflict).
    transition to_charging first docking accept DockDetectedEvent then charging;
    transition charged first charging accept ChargeCompleteEvent then idle;
    transition unrecoverable_fault first safeStop accept RecoveryFailedEvent then fault;
    transition service_reset first fault accept ServiceResetEvent then idle;
  }

  state def StartupSelfTestBehavior {
    entry;
    then selfTest;
    state selfTest;
    state ready;
    state failed;
    transition pass first selfTest accept SelfTestPassedEvent then ready;
    transition fail first selfTest accept SelfTestFailedEvent then failed;
    transition rerun_after_ready first ready accept StartMissionEvent then selfTest;
    transition rerun_after_failure first failed accept ServiceResetEvent then selfTest;
  }

  state def SafetyFaultResponseBehavior {
    entry;
    then monitoring;
    state monitoring;
    state safeStop;
    state faultLatched;
    transition hazard_to_stop first monitoring accept HazardDetectedEvent then safeStop;
    transition cleared first safeStop accept SafeStopClearedEvent then monitoring;
    transition unrecoverable first safeStop accept RecoveryFailedEvent then faultLatched;
  }

  state def BinServiceBehavior {
    entry;
    then binInstalled;
    state binInstalled;
    state binMissing;
    state binFull;
    transition missing first binInstalled accept BinMissingEvent then binMissing;
    transition latched first binMissing accept BinLatchedEvent then binInstalled;
    transition full first binInstalled accept BinFullEvent then binFull;
    transition emptied first binFull accept BinLatchedEvent then binInstalled;
  }

  state def PrivacyConsentBehavior {
    entry;
    then localOnly;
    state localOnly;
    state cloudBackupEnabled;
    transition consent_granted first localOnly accept CloudConsentChangedEvent then cloudBackupEnabled;
    transition consent_revoked first cloudBackupEnabled accept CloudConsentChangedEvent then localOnly;
  }

  state def LowBatteryDockingBehavior {
    entry;
    then cleaning;
    state cleaning;
    state returning;
    state docking;
    state charging;
    transition low_battery first cleaning accept LowBatteryEvent then returning;
    transition dock_detected first returning accept DockDetectedEvent then docking;
    transition charging_started first docking accept DockDetectedEvent then charging;
    transition charge_complete first charging accept ChargeCompleteEvent then cleaning;
  }
}
