package StakeholderNeeds {
  private import RequirementManagement::*;

  requirement cleanLargeAreas : UserRequirement {
    doc /* Stakeholders need the robot to clean large floor areas efficiently in one mission. */
    attribute :>> status = RequirementStatusKind::approved;
  }
  requirement operateSafely : UserRequirement {
    doc /* The robot shall operate safely around people, pets, and household obstacles. */
    attribute :>> status = RequirementStatusKind::approved;
  }
  requirement quietCleaning : UserRequirement {
    doc /* Cleaning noise shall remain acceptable for residential and office use. */
    attribute :>> status = RequirementStatusKind::approved;
  }
  requirement reliableDocking : UserRequirement {
    doc /* The robot shall dock and charge reliably without user intervention. */
    attribute :>> status = RequirementStatusKind::approved;
  }
  requirement easyToEmpty : UserRequirement {
    doc /* The robot shall be easy to empty and maintain without tools or specialist skills. */
    attribute :>> status = RequirementStatusKind::approved;
  }
  requirement missionFeedback : UserRequirement {
    doc /* Users need visibility into cleaning progress and status from the mobile app during a mission. */
    attribute :>> status = RequirementStatusKind::approved;
  }
  requirement affordableProduct : UserRequirement {
    doc /* The product shall remain affordable at target production volume. */
    attribute :>> status = RequirementStatusKind::approved;
  }
  requirement portableDesign : UserRequirement {
    doc /* The robot shall be easy to lift and ship for home use. */
    attribute :>> status = RequirementStatusKind::approved;
  }
}
