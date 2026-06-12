package SystemRequirements {
  private import RequirementMetadata::*;
  private import ModelingMetadata::*;
  private import StakeholderNeeds::*;

  requirement cleanAtLeastEighty {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The robot shall clean at least 80 m² on a single charge. */
  }
  requirement returnToDock {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The robot shall return to the docking station when battery state of charge drops below 15%. */
  }
  requirement avoidObstacles {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The robot shall avoid obstacles higher than 30 mm. */
  }
  requirement detectDustBin {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The robot shall detect when the dust bin is full. */
  }
  requirement keepNoise {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The robot shall keep acoustic noise below 65 dBA in standard mode. */
  }
  requirement coverFloor {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The robot shall cover at least 90% of reachable floor area in a rectangular room. */
  }
  requirement reportCleaningStatus {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The robot shall report cleaning progress and status to the mobile app during a mission. */
  }
  requirement limitBomCost {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The bill of materials at target production volume shall not exceed 400 EUR. */
  }
  requirement limitTotalMass {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The total robot mass shall not exceed 5.0 kg. */
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
