/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Robot-specific roles of generic Elan8 sensing kinds: the bumper and
 * wheel-drop switches and the docking station's infrared homing beacon.
 */
package RobotSensing {
  private import Elan8::Electronics::Sensing::*;

  item def LiftStateMeasurement :> BinaryStateMeasurement;

  part def BumperSwitch :> SwitchSensor;

  part def LiftSwitch :> SwitchSensor {
    item liftState : LiftStateMeasurement;
  }

  item def HomingBeaconSignal :> InfraredSignal;

  port def HomingBeaconPort :> InfraredPort {
    out item :>> signal : HomingBeaconSignal;
  }

  part def HomingBeaconTransmitter :> InfraredTransmitter {
    port beacon : HomingBeaconPort :>> emission;
  }

  part def HomingBeaconReceiver :> InfraredReceiver {
    port beacon : ~HomingBeaconPort :>> reception;
  }
}
