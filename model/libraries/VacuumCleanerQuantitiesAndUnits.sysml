/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns project-specific measurement units that are not declared by the bundled
 * OMG quantities-and-units library. Keep unit symbols and conversions explicit
 * so model validation does not depend on tool-specific unit synthesis.
 */
library package VacuumCleanerQuantitiesAndUnits {
  private import MeasurementReferences::*;
  private import ISQ::*;
  private import SI::*;
  private import SIPrefixes::*;

  attribute <Ah> 'ampere hour' : ElectricChargeUnit = A*h;

  attribute <mAh> 'milliampere hour' : ElectricChargeUnit {
    :>> unitConversion {
      private attribute prefix : UnitPrefix = milli;
      :>> referenceUnit = Ah;
      :>> conversionFactor = prefix.conversionFactor;
    }
  }

  attribute <ms> millisecond : DurationUnit {
    :>> unitConversion {
      private attribute prefix : UnitPrefix = milli;
      :>> referenceUnit = s;
      :>> conversionFactor = prefix.conversionFactor;
    }
  }
}
