package PhysicalProtocols {
  public import ElectronicsInterconnection::*;
  public import ElectronicBusDomain::*;
  public import ElectronicIoDomain::*;
  public import ElectricalPowerDomain::*;
  public import EmbeddedComputeDomain::*;
  public import WirelessDomain::*;

  part def SensorI2cBus :> I2cBusHub;
  part def BmsSmbusHub :> I2cBusHub;
  part def FlashSpiBus :> SpiBusHub;
  part def WirelessUartHub :> UartBusHub;

  part def RobotWirelessModule :> WirelessModule;
}
