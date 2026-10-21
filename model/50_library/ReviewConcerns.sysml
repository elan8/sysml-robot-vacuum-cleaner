/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package ReviewConcerns {
    private import Views::*;
    private import StandardViewDefinitions::*;
    // GeneralView and the other standard view definitions
      private import Architecture::*;
    private import FirmwareArchitecture::*;
    private import OperationalScenarios::*;
    private import SystemRequirements::*;
    part def StakeholderRole;
    part systemsEngineer : StakeholderRole;
    part firmwareEngineer : StakeholderRole;
    part verificationEngineer : StakeholderRole;
    part productEngineer : StakeholderRole;
    concern productStructure {
        doc /* What constitutes the selected robot baseline? */
        subject;
        stakeholder :>> systemsEngineer;
        stakeholder :>> productEngineer;
      }
    concern productConnections {
        doc /* How are the product LRUs connected? */
        subject;
        stakeholder :>> systemsEngineer;
      }
    concern firmwareDeployment {
        doc /* Which firmware tasks execute on which processor? */
        subject;
        stakeholder :>> firmwareEngineer;
        stakeholder :>> systemsEngineer;
      }
    concern requirementStructure {
        doc /* Which system requirements constrain the robot? */
        subject;
        stakeholder :>> verificationEngineer;
        stakeholder :>> systemsEngineer;
      }
    concern safeStopScenario {
        doc /* How does a cliff observation lead to a verified safe stop? */
        subject;
        stakeholder :>> verificationEngineer;
        stakeholder :>> systemsEngineer;
      }
    viewpoint productStructurePerspective { frame productStructure; }
    viewpoint productConnectionsPerspective { frame productConnections; }
    viewpoint firmwareDeploymentPerspective { frame firmwareDeployment; }
    viewpoint requirementStructurePerspective { frame requirementStructure; }
    viewpoint safeStopScenarioPerspective { frame safeStopScenario; }
}
