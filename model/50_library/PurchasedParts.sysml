/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Local purchased-parts library: the concrete catalog parts selected for the
 * vacuum. The `BuyPart` annotation comes from the reusable `generic/procurement`
 * package in sysml-domain-libraries; each part's datasheet is cited in its
 * documentation.
 */
library package PurchasedParts {
  private import Elan8::Electronics::Compute::*;
  private import Elan8::Electronics::Core::*;
  private import Elan8::Electronics::Wireless::*;
  private import Elan8::Procurement::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  part def STM32U575VGT6 :> Microcontroller {
    @BuyPart {
      manufacturer = "STMicroelectronics";
      manufacturerPartNumber = "STM32U575VGT6";
      url = "https://www.st.com/en/microcontrollers-microprocessors/stm32u575vg.html";
    }
    doc /* Datasheet DS13737, Rev 10: https://www.st.com/resource/en/datasheet/stm32u575ai.pdf (checked 2026-07-26). */
    attribute supplyVoltageMin : ElectricPotentialValue = 1.71 [V];
    attribute supplyVoltageMax : ElectricPotentialValue = 3.6 [V];
    attribute operatingTemperatureMin : ThermodynamicTemperatureValue = 233.15 [K];
    attribute operatingTemperatureMax : ThermodynamicTemperatureValue = 358.15 [K];
  }

  part def DRV8316R :> ElectronicsComponent {
    @BuyPart {
      manufacturer = "Texas Instruments";
      manufacturerPartNumber = "DRV8316RRGFR";
      url = "https://www.ti.com/product/DRV8316/part-details/DRV8316RRGFR";
    }
    doc /* Datasheet SLVSGM1, Rev B: https://www.ti.com/lit/ds/symlink/drv8316.pdf (checked 2026-07-26). */
    attribute supplyVoltageMin : ElectricPotentialValue = 4.5 [V];
    attribute supplyVoltageMax : ElectricPotentialValue = 35 [V];
    attribute operatingTemperatureMin : ThermodynamicTemperatureValue = 233.15 [K];
    attribute operatingTemperatureMax : ThermodynamicTemperatureValue = 398.15 [K];
  }

  part def VL53L1CX :> ElectronicsComponent {
    @BuyPart {
      manufacturer = "STMicroelectronics";
      manufacturerPartNumber = "VL53L1CXV0FY/1";
      url = "https://www.st.com/en/imaging-and-photonics-solutions/vl53l1cx.html";
    }
    doc /* Datasheet DS11854, Rev 7: https://www.st.com/resource/en/datasheet/vl53l1cx.pdf (checked 2026-07-26). */
    attribute supplyVoltageMin : ElectricPotentialValue = 2.6 [V];
    attribute supplyVoltageMax : ElectricPotentialValue = 3.5 [V];
    attribute operatingTemperatureMin : ThermodynamicTemperatureValue = 253.15 [K];
    attribute operatingTemperatureMax : ThermodynamicTemperatureValue = 358.15 [K];
  }

  part def RPLIDARC1 :> ElectronicsComponent {
    @BuyPart {
      manufacturer = "Slamtec";
      manufacturerPartNumber = "RPLIDAR C1M1";
      url = "https://www.slamtec.com/en/c1/spec";
    }
    doc /* Datasheet RPLIDAR C1 Introduction and Datasheet, Rev 1.1: https://bucket-download.slamtec.com/2d4664be9f9f5c748f3b608f2cf1862962b168eb/SLAMTEC_rplidar_datasheet_C1_v1.1_en.pdf (checked 2026-07-26). */
    attribute supplyVoltageMin : ElectricPotentialValue = 4.9 [V];
    attribute supplyVoltageMax : ElectricPotentialValue = 5.5 [V];
    attribute operatingTemperatureMin : ThermodynamicTemperatureValue = 263.15 [K];
    attribute operatingTemperatureMax : ThermodynamicTemperatureValue = 323.15 [K];
  }

  part def ESP32C3MINI1 :> WirelessModule {
    @BuyPart {
      manufacturer = "Espressif Systems";
      manufacturerPartNumber = "ESP32-C3-MINI-1-N4";
      url = "https://www.espressif.com/en/products/modules/esp32-c3-mini-1";
    }
    doc /* Datasheet ESP32-C3-MINI-1 Datasheet, v2.2: https://www.espressif.com/sites/default/files/documentation/esp32-c3-mini-1_datasheet_en.pdf (checked 2026-07-26). */
    attribute supplyVoltageMin : ElectricPotentialValue = 3.0 [V];
    attribute supplyVoltageMax : ElectricPotentialValue = 3.6 [V];
    attribute operatingTemperatureMin : ThermodynamicTemperatureValue = 233.15 [K];
    attribute operatingTemperatureMax : ThermodynamicTemperatureValue = 358.15 [K];
  }

  part def BQ40Z50R2 :> ElectronicsComponent {
    @BuyPart {
      manufacturer = "Texas Instruments";
      manufacturerPartNumber = "BQ40Z50-R2";
      url = "https://www.ti.com/product/BQ40Z50-R2";
    }
    doc /* Datasheet SLUSCS4, Rev C: https://www.ti.com/lit/ds/symlink/bq40z50-r2.pdf (checked 2026-07-26). */
    attribute operatingTemperatureMin : ThermodynamicTemperatureValue = 233.15 [K];
    attribute operatingTemperatureMax : ThermodynamicTemperatureValue = 358.15 [K];
  }
}
