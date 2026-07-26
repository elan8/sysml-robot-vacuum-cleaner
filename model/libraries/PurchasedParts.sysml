/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Local purchased-parts library. It imports only reusable domain and standard
 * libraries so it can later move to a separate repository unchanged.
 */
library package PurchasedParts {
  private import EmbeddedComputeDomain::*;
  private import ElectronicsCore::*;
  private import WirelessDomain::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  enum def PartLifecycleStatus {
    active;
    notRecommendedForNewDesign;
    endOfLife;
    unknown;
  }

  metadata def BuyPart {
    doc /*
      Procurement identity and authoritative external documentation for a
      concrete, purchasable part definition. URLs identify external resources;
      internal model identity remains semantic.
    */
    :> annotatedElement : SysML::PartDefinition;
    attribute manufacturer : String;
    attribute manufacturerPartNumber : String;
    attribute productPageUrl : String;
    attribute datasheetUrl : String;
    attribute datasheetDocumentId : String;
    attribute datasheetRevision : String;
    attribute lifecycleStatus : PartLifecycleStatus;
    attribute sourceCheckedOn : String;
  }

  part def STM32U575VGT6 :> Microcontroller {
    @BuyPart {
      manufacturer = "STMicroelectronics";
      manufacturerPartNumber = "STM32U575VGT6";
      productPageUrl = "https://www.st.com/en/microcontrollers-microprocessors/stm32u575vg.html";
      datasheetUrl = "https://www.st.com/resource/en/datasheet/stm32u575ai.pdf";
      datasheetDocumentId = "DS13737";
      datasheetRevision = "Rev 10";
      lifecycleStatus = PartLifecycleStatus::active;
      sourceCheckedOn = "2026-07-26";
    }
    attribute supplyVoltageMin : ElectricPotentialValue = 1.71 [V];
    attribute supplyVoltageMax : ElectricPotentialValue = 3.6 [V];
    attribute operatingTemperatureMin : ThermodynamicTemperatureValue = 233.15 [K];
    attribute operatingTemperatureMax : ThermodynamicTemperatureValue = 358.15 [K];
  }

  part def DRV8316R :> ElectronicsComponent {
    @BuyPart {
      manufacturer = "Texas Instruments";
      manufacturerPartNumber = "DRV8316RRGFR";
      productPageUrl = "https://www.ti.com/product/DRV8316/part-details/DRV8316RRGFR";
      datasheetUrl = "https://www.ti.com/lit/ds/symlink/drv8316.pdf";
      datasheetDocumentId = "SLVSGM1";
      datasheetRevision = "Rev B";
      lifecycleStatus = PartLifecycleStatus::active;
      sourceCheckedOn = "2026-07-26";
    }
    attribute supplyVoltageMin : ElectricPotentialValue = 4.5 [V];
    attribute supplyVoltageMax : ElectricPotentialValue = 35 [V];
    attribute operatingTemperatureMin : ThermodynamicTemperatureValue = 233.15 [K];
    attribute operatingTemperatureMax : ThermodynamicTemperatureValue = 398.15 [K];
  }

  part def VL53L1CX :> ElectronicsComponent {
    @BuyPart {
      manufacturer = "STMicroelectronics";
      manufacturerPartNumber = "VL53L1CXV0FY/1";
      productPageUrl = "https://www.st.com/en/imaging-and-photonics-solutions/vl53l1cx.html";
      datasheetUrl = "https://www.st.com/resource/en/datasheet/vl53l1cx.pdf";
      datasheetDocumentId = "DS11854";
      datasheetRevision = "Rev 7";
      lifecycleStatus = PartLifecycleStatus::active;
      sourceCheckedOn = "2026-07-26";
    }
    attribute supplyVoltageMin : ElectricPotentialValue = 2.6 [V];
    attribute supplyVoltageMax : ElectricPotentialValue = 3.5 [V];
    attribute operatingTemperatureMin : ThermodynamicTemperatureValue = 253.15 [K];
    attribute operatingTemperatureMax : ThermodynamicTemperatureValue = 358.15 [K];
  }

  part def RPLIDARC1 :> ElectronicsComponent {
    @BuyPart {
      manufacturer = "Slamtec";
      manufacturerPartNumber = "RPLIDAR C1M1";
      productPageUrl = "https://www.slamtec.com/en/c1/spec";
      datasheetUrl = "https://bucket-download.slamtec.com/2d4664be9f9f5c748f3b608f2cf1862962b168eb/SLAMTEC_rplidar_datasheet_C1_v1.1_en.pdf";
      datasheetDocumentId = "RPLIDAR C1 Introduction and Datasheet";
      datasheetRevision = "Rev 1.1";
      lifecycleStatus = PartLifecycleStatus::active;
      sourceCheckedOn = "2026-07-26";
    }
    attribute supplyVoltageMin : ElectricPotentialValue = 4.9 [V];
    attribute supplyVoltageMax : ElectricPotentialValue = 5.5 [V];
    attribute operatingTemperatureMin : ThermodynamicTemperatureValue = 263.15 [K];
    attribute operatingTemperatureMax : ThermodynamicTemperatureValue = 323.15 [K];
  }

  part def ESP32C3MINI1 :> WirelessModule {
    @BuyPart {
      manufacturer = "Espressif Systems";
      manufacturerPartNumber = "ESP32-C3-MINI-1-N4";
      productPageUrl = "https://www.espressif.com/en/products/modules/esp32-c3-mini-1";
      datasheetUrl = "https://www.espressif.com/sites/default/files/documentation/esp32-c3-mini-1_datasheet_en.pdf";
      datasheetDocumentId = "ESP32-C3-MINI-1 Datasheet";
      datasheetRevision = "v2.2";
      lifecycleStatus = PartLifecycleStatus::active;
      sourceCheckedOn = "2026-07-26";
    }
    attribute supplyVoltageMin : ElectricPotentialValue = 3.0 [V];
    attribute supplyVoltageMax : ElectricPotentialValue = 3.6 [V];
    attribute operatingTemperatureMin : ThermodynamicTemperatureValue = 233.15 [K];
    attribute operatingTemperatureMax : ThermodynamicTemperatureValue = 358.15 [K];
  }

  part def BQ40Z50R2 :> ElectronicsComponent {
    @BuyPart {
      manufacturer = "Texas Instruments";
      manufacturerPartNumber = "BQ40Z50-R2";
      productPageUrl = "https://www.ti.com/product/BQ40Z50-R2";
      datasheetUrl = "https://www.ti.com/lit/ds/symlink/bq40z50-r2.pdf";
      datasheetDocumentId = "SLUSCS4";
      datasheetRevision = "Rev C";
      lifecycleStatus = PartLifecycleStatus::active;
      sourceCheckedOn = "2026-07-26";
    }
    attribute operatingTemperatureMin : ThermodynamicTemperatureValue = 233.15 [K];
    attribute operatingTemperatureMax : ThermodynamicTemperatureValue = 358.15 [K];
  }
}
