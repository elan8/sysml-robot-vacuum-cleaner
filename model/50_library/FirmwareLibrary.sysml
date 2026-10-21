/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package FirmwareLibrary {
    private import DomainModel::*;
    private import Elan8::Software::*;
    abstract part def FirmwareTask :> Task;
    abstract part def PeriodicFirmwareTask :> FirmwareTask, PeriodicTask;
    abstract part def EventDrivenFirmwareTask :> FirmwareTask, EventDrivenTask;
    port def HazardEventQueuePort {
        in item input : HazardEvent;
        out item output : HazardEvent;
      }
    port def UserCommandQueuePort {
        in item input : UserCommand;
        out item output : UserCommand;
      }
    port def DriveCommandQueuePort {
        in item input : DriveCommand;
        out item output : DriveCommand;
      }
    port def MapUpdateQueuePort {
        in item input : MapUpdate;
        out item output : MapUpdate;
      }
}
