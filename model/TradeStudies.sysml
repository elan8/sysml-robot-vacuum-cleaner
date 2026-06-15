/*
 * Owns selected and deferred product trade options with rationale. Depends on
 * requirements, physical architecture, analyses, and scalar values. Keep the
 * realized baseline structure in PhysicalArchitecture and allocation packages.
 */
package TradeStudies {
  private import SystemRequirements::*;
  private import PhysicalArchitecture::*;
  private import AnalysisCases::*;
  private import ScalarValues::*;

  part def TradeOption {
    attribute optionName : String;
    attribute selected : Boolean;
    attribute rationale : String;
  }

  part sensorBaseline : TradeOption {
    attribute :>> optionName = "ToF plus IMU";
    attribute :>> selected = false;
    attribute :>> rationale = "low-cost privacy tier for simple reference layouts; deferred because it is not robust enough for premium room-scale SLAM";
  }

  part sensorLidarUpgrade : TradeOption {
    attribute :>> optionName = "ToF plus IMU plus 2D dToF/LiDAR";
    attribute :>> selected = true;
    attribute :>> rationale = "selected premium architecture for robust room-scale SLAM, stable maps, and 150 mm localization target without camera-by-default privacy impact";
  }

  part flagshipAiVisionUpgrade : TradeOption {
    attribute :>> optionName = "LiDAR plus RGB/dual camera plus local AI accelerator plus 3D ToF";
    attribute :>> selected = false;
    attribute :>> rationale = "best semantic obstacle recognition, deferred because it adds privacy, compute, power, BOM, and regulatory concerns";
  }

  part standardFan : TradeOption {
    attribute :>> optionName = "standard low-power fan";
    attribute :>> selected = true;
    attribute :>> rationale = "supports quiet standard mode and runtime target";
  }

  part highSuctionFan : TradeOption {
    attribute :>> optionName = "higher suction fan";
    attribute :>> selected = false;
    attribute :>> rationale = "improves pickup but pushes max-mode power above the continuous budget";
  }

  part battery4s2p : TradeOption {
    attribute :>> optionName = "4S2P 12500 mAh pack";
    attribute :>> selected = true;
    attribute :>> rationale = "keeps 80 m2 mission target with reserve capacity and manageable mass";
  }

  part sameMcuSafetySupervisor : TradeOption {
    attribute :>> optionName = "same-MCU safety supervisor";
    attribute :>> selected = true;
    attribute :>> rationale = "acceptable for the demonstrator and low-cost product tier; independent monitor is a safety follow-up";
  }

  part independentSafetyMonitor : TradeOption {
    attribute :>> optionName = "independent safety monitor";
    attribute :>> selected = false;
    attribute :>> rationale = "stronger diagnostic independence, retained as risk-reduction option";
  }

  part localOnlyPrivacyDefault : TradeOption {
    attribute :>> optionName = "local-only privacy default";
    attribute :>> selected = true;
    attribute :>> rationale = "satisfies protectMapPrivacy without requiring cloud trust";
  }

  satisfy sensorBaseline by limitBomCost;
  satisfy sensorLidarUpgrade by localizeReliably;
  satisfy sensorLidarUpgrade by updateCoverageMap;
  satisfy flagshipAiVisionUpgrade by avoidObstacles;
  satisfy flagshipAiVisionUpgrade by protectMapPrivacy;
  satisfy standardFan by keepNoise;
  satisfy standardFan by cleanAtLeastEighty;
  satisfy battery4s2p by cleanAtLeastEighty;
  satisfy battery4s2p by chargeSafely;
  satisfy sameMcuSafetySupervisor by superviseHazards;
  satisfy localOnlyPrivacyDefault by protectMapPrivacy;
}
