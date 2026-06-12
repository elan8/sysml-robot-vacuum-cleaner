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
  requirement detectCliffs {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The robot shall detect floor drop-offs of at least 50 mm before any wheel crosses the edge. */
  }
  requirement localizeReliably {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The robot shall maintain localization error below 150 mm during a standard cleaning mission. */
  }
  requirement updateCoverageMap {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The robot shall maintain a coverage map with cleaned, unreachable, and unknown cells during the mission. */
  }
  requirement recoverFromStall {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The robot shall detect a wheel stall within 2 s and enter a bounded recovery maneuver. */
  }
  requirement protectMapPrivacy {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The robot shall keep raw home map data local unless the user explicitly enables cloud backup. */
  }
  requirement chargeSafely {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The robot shall limit charge current and temperature within the battery manufacturer's safe operating area. */
  }
  requirement superviseHazards {
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    doc /* The robot shall command a safe stop when cliff, bumper, lift, overcurrent, or thermal hazards are detected. */
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
  #derivation connection {
    end #original ::> protectHomes;
    end #derive ::> detectCliffs;
  }
  #derivation connection {
    end #original ::> adaptToHomes;
    end #derive ::> localizeReliably;
  }
  #derivation connection {
    end #original ::> adaptToHomes;
    end #derive ::> updateCoverageMap;
  }
  #derivation connection {
    end #original ::> tolerateFaults;
    end #derive ::> recoverFromStall;
  }
  #derivation connection {
    end #original ::> respectPrivacy;
    end #derive ::> protectMapPrivacy;
  }
  #derivation connection {
    end #original ::> maintainBatteryHealth;
    end #derive ::> chargeSafely;
  }
  #derivation connection {
    end #original ::> protectHomes;
    end #derive ::> superviseHazards;
  }
}
