package SystemRequirements {
  private import RequirementManagement::*;
  private import StakeholderNeeds::*;

  requirement cleanAtLeastEighty : SystemRequirement {
    doc /* The robot shall clean at least 80 m² on a single charge. */
    attribute :>> status = RequirementStatusKind::approved;
  }
  requirement returnToDock : SystemRequirement {
    doc /* The robot shall return to the docking station when battery state of charge drops below 15%. */
    attribute :>> status = RequirementStatusKind::approved;
  }
  requirement avoidObstacles : SystemRequirement {
    doc /* The robot shall avoid obstacles higher than 30 mm. */
    attribute :>> status = RequirementStatusKind::approved;
  }
  requirement detectDustBin : SystemRequirement {
    doc /* The robot shall detect when the dust bin is full. */
    attribute :>> status = RequirementStatusKind::approved;
  }
  requirement keepNoise : SystemRequirement {
    doc /* The robot shall keep acoustic noise below 65 dBA in standard mode. */
    attribute :>> status = RequirementStatusKind::approved;
  }
  requirement coverFloor : SystemRequirement {
    doc /* The robot shall cover at least 90% of reachable floor area in a rectangular room. */
    attribute :>> status = RequirementStatusKind::approved;
  }
  requirement reportCleaningStatus : SystemRequirement {
    doc /* The robot shall report cleaning progress and status to the mobile app during a mission. */
    attribute :>> status = RequirementStatusKind::approved;
  }
  requirement limitBomCost : SystemRequirement {
    doc /* The bill of materials at target production volume shall not exceed 400 EUR. */
    attribute :>> status = RequirementStatusKind::approved;
  }
  requirement limitTotalMass : SystemRequirement {
    doc /* The total robot mass shall not exceed 5.0 kg. */
    attribute :>> status = RequirementStatusKind::approved;
  }

  #derivation connection {
    end #original ::> cleanLargeAreas;
    end #derive ::> cleanAtLeastEighty;
  }
  #derivation connection {
    end #original ::> reliableDocking;
    end #derive ::> returnToDock;
  }
  #derivation connection {
    end #original ::> operateSafely;
    end #derive ::> avoidObstacles;
  }
  #derivation connection {
    end #original ::> cleanLargeAreas;
    end #derive ::> detectDustBin;
  }
  #derivation connection {
    end #original ::> quietCleaning;
    end #derive ::> keepNoise;
  }
  #derivation connection {
    end #original ::> cleanLargeAreas;
    end #derive ::> coverFloor;
  }
  #derivation connection {
    end #original ::> missionFeedback;
    end #derive ::> reportCleaningStatus;
  }
  #derivation connection {
    end #original ::> affordableProduct;
    end #derive ::> limitBomCost;
  }
  #derivation connection {
    end #original ::> portableDesign;
    end #derive ::> limitTotalMass;
  }
}
