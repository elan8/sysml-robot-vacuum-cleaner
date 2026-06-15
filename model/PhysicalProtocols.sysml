/*
 * Owns product-specific physical protocol aliases for buses, wireless links,
 * power rails, and harness attachment points. Depends on domain electronics,
 * communication, and software libraries. Keep concrete product assemblies in
 * PhysicalArchitecture.
 */
package PhysicalProtocols {
  public import ElectronicsInterconnection::*;
  public import ElectronicBusDomain::*;
  public import ElectronicIoDomain::*;
  public import ElectricalPowerDomain::*;
  public import EmbeddedComputeDomain::*;
  public import WirelessDomain::*;

  doc /*
    Product-specific bus media: specialize domain bus types with named attachment
    ports for each participant (OMG CAN-style), not generic numbered fan-out.
  */

  part def SensorI2cBus :> I2cBus {
    port hostBackplane : I2cPort;
    port frontTof : I2cPort;
    port leftWallTof : I2cPort;
    port rightWallTof : I2cPort;
    port imu : I2cPort;
  }

  part def BmsSmbusBus :> SmbusBus {
    port hostBackplane : I2cPort;
    port bms : I2cPort;
  }

  part def FlashSpiBus :> SpiBus {
    port flash : SpiPort;
  }

  part def McuWirelessUart :> UartBus {
    port mcu : UartPort;
    port wirelessModule : UartPort;
  }

  part def LidarSerialBus :> UartBus {
    port mcu : UartPort;
    port lidarModule : UartPort;
  }

  part def RobotWirelessModule :> WirelessModule;
}
