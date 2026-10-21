/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Bill-of-materials vocabulary. A part usage or part definition annotated
 * `@BomItem` is one line of the bill of materials; an unannotated part that
 * owns annotated parts is an assembly. Manufacturer and part number of a
 * selected catalogue part come from its `Procurement::BuyPart` annotation.
 *
 * Unit costs are order-of-magnitude engineering estimates in EUR at a
 * production volume of 10 000 robots: a purchase-price estimate for a bought
 * item and a manufacturing-cost estimate for a made item. They are not
 * supplier quotes.
 */
library package Sourcing {
  private import ScalarValues::*;

  enum def SourcingKind {
    doc /* How an item is obtained. */
    enum buy { doc /* Commercial catalogue or commodity item. */ }
    enum make { doc /* Designed for this robot and manufactured to drawing. */ }
  }

  metadata def BomItem {
    doc /* One line of the bill of materials. */
    attribute description : String;
    attribute sourcing : SourcingKind;
    attribute unitCostEur : Real;
  }
}
