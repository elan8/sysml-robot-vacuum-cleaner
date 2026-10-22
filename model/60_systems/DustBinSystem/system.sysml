/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package DustBinSystem {
    private import NumericalFunctions::*;
    // sum(...) in the rolled-up mass/power attributes
    private import BehaviorStates::*;
    private import DomainModel::*;
    private import ProductContext::CleaningRobot;
    private import Elan8::Electronics::Core::*;
    private import Elan8::Electronics::Actuation::*;
    private import Elan8::Electronics::Sensing::*;
    private import Elan8::Electronics::Power::*;
    private import Elan8::Electronics::Assembly::*;
    private import Elan8::Electronics::Board::*;
    private import Elan8::Electronics::Buses::*;
    private import Elan8::Electronics::Interconnection::*;
    private import Elan8::Mechanical::Core::*;
    private import Elan8::Mechanical::Drivetrain::*;
    private import Elan8::Mechanical::Interconnection::*;
    private import Elan8::Electronics::Compute::*;
    private import FirmwareArchitecture::*;
    private import PurchasedParts::*;
    private import Elan8::Procurement::*;
    private import Elan8::Units::Money::*;
    private import SystemRequirements::*;
    private import Elan8::Software::*;
    private import Elan8::Electronics::Wireless::*;
    private import Elan8::Units::Engineering::*;
    private import ISQ::*;
    private import SI::*;
    private import ScalarValues::*;
    private import FunctionalArchitecture::*;
    private import PhysicalArchitecture::*;
    private import ModuleRequirements::*;
    private import FirmwareLibrary::*;
    private import PhysicalShared::*;
    private import StandardViewDefinitions::*;
    private import ReviewConcerns::*;
    part def DustBinSpecification :> MechanicalComponent, Elan8::SystemsEngineering::SystemSpecification {
        port debrisIn : ~CleaningFlowPort;
        attribute capacity : VolumeValue;
        satisfy Requirements::dustBinSpecification;
    }
    package Requirements {
        private import ModuleBudgets::*;
        private import RequirementLimits::*;
        private import ISQ::*;
        private import SI::*;
        requirement dustBinSpecification {
            subject bin : DustBinSystem::DustBinSpecification;

            requirement <'BIN-001'> 'Dust bin mass' {
              require constraint { bin.mass <= dustBinMassBudget }
              doc /* The empty dust bin with its filter shall have a mass of at most {{= ModuleBudgets::dustBinMassBudget}}. */
            }
          }
    }

    part def DustBinArchitecture :> DustBinSpecification, Elan8::SystemsEngineering::SystemArchitecture {
        part body : DustBinSystem::DustBinBody;
        part lid : DustBinSystem::DustBinLid;
        part 'filter' : DustBinSystem::DustFilter;
    }

    part def DustBinIntegration :> DustBinArchitecture, Elan8::SystemsEngineering::SystemIntegration {
        part body : DustBinSystem::DustBinBody :>> body;
        part lid : DustBinSystem::DustBinLid :>> lid;
        part redefines 'filter' : DustBinSystem::DustFilter;
        doc /*
              Tool-free-removable module, independent of Base/Top — matches it being a
              separately replaceable real-world spare part. Purely mechanical: no ports,
              no electronics.
            */
        attribute :>> mass = sum(body.mass, lid.mass, 'filter'.mass);
        attribute :>> capacity = 450 [mL];
    }

    part def DustBinLid :> MechanicalComponent, CostedPart {
        doc /* Dust bin lid, moulded */
        @MakePart;
        attribute :>> unitCost = 0.30 [EUR];
        attribute :>> mass = 0.03 [kg];
    }

    part def DustFilter :> MechanicalComponent, CostedPart {
        doc /* Pleated dust filter */
        @BuyPart;
        attribute :>> unitCost = 0.55 [EUR];
        attribute :>> mass = 0.02 [kg];
    }

    part def DustBinBody :> MechanicalComponent, CostedPart {
        doc /* Dust bin body, moulded */
        @MakePart;
        attribute :>> unitCost = 0.70 [EUR];
        attribute :>> mass = 0.15 [kg];
    }

}
