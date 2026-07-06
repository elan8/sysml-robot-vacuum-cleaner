/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns stakeholder-level user needs with requirement metadata. Depends on
 * requirement and modeling metadata libraries. Keep derived system requirements
 * and solution details in downstream packages.
 */
package StakeholderNeeds {
  private import RequirementMetadata::*;
  private import ModelingMetadata::*;

  requirement cleanLargeAreas {
    @RequirementRole { role = user; }
    @StatusInfo { status = done; }
    doc /* Stakeholders need the robot to clean large floor areas efficiently in one mission. */
  }
  requirement operateSafely {
    @RequirementRole { role = user; }
    @StatusInfo { status = done; }
    doc /* The robot shall operate safely around people, pets, and household obstacles. */
  }
  requirement quietCleaning {
    @RequirementRole { role = user; }
    @StatusInfo { status = done; }
    doc /* Cleaning noise shall remain acceptable for residential and office use. */
  }
  requirement reliableDocking {
    @RequirementRole { role = user; }
    @StatusInfo { status = done; }
    doc /* The robot shall dock and charge reliably without user intervention. */
  }
  requirement easyToEmpty {
    @RequirementRole { role = user; }
    @StatusInfo { status = open; }
    doc /* The robot shall be easy to empty and maintain without tools or specialist skills. */
  }
  requirement missionFeedback {
    @RequirementRole { role = user; }
    @StatusInfo { status = done; }
    doc /* Users need visibility into cleaning progress and status from the mobile app during a mission. */
  }
  requirement affordableProduct {
    @RequirementRole { role = user; }
    @StatusInfo { status = done; }
    doc /* The product shall remain affordable at target production volume. */
  }
  requirement portableDesign {
    @RequirementRole { role = user; }
    @StatusInfo { status = done; }
    doc /* The robot shall be easy to lift and ship for home use. */
  }
  requirement protectHomes {
    @RequirementRole { role = user; }
    @StatusInfo { status = done; }
    doc /* The robot shall protect household occupants, furniture, stairs, and fragile objects while cleaning autonomously. */
  }
  requirement adaptToHomes {
    @RequirementRole { role = user; }
    @StatusInfo { status = done; }
    doc /* The robot shall adapt to typical homes with mixed flooring, thresholds, low furniture, narrow passages, and changing clutter. */
  }
  requirement respectPrivacy {
    @RequirementRole { role = user; }
    @StatusInfo { status = done; }
    doc /* The robot shall preserve user privacy when sensing, mapping, storing, and communicating home data. */
  }
  requirement tolerateFaults {
    @RequirementRole { role = user; }
    @StatusInfo { status = done; }
    doc /* The robot shall detect and recover from common operational faults without creating unsafe behavior. */
  }
  requirement maintainBatteryHealth {
    @RequirementRole { role = user; }
    @StatusInfo { status = done; }
    doc /* The robot shall charge safely and protect battery lifetime across repeated missions. */
  }
}
