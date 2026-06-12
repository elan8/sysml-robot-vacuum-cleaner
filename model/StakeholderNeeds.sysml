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
}
