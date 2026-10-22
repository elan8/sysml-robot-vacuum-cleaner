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
    private import Sourcing::*;
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
    part def DustBinSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
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

    part def DustBinArchitecture :> DustBinSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
        part body : ComponentProfiles::DustBinBody::DustBinBodySpecification;
        part lid : ComponentProfiles::DustBinLid::DustBinLidSpecification;
        part 'filter' : ComponentProfiles::DustFilter::DustFilterSpecification;
    }

    part def DustBinIntegration :> DustBinArchitecture, Elan8::SystemsEngineering::SystemIntegration {
        part body : ComponentProfiles::DustBinBody::DustBinBodyArchitecture :>> body;
        part lid : ComponentProfiles::DustBinLid::DustBinLidArchitecture :>> lid;
        part redefines 'filter' : ComponentProfiles::DustFilter::DustFilterArchitecture;
        doc /*
              Tool-free-removable module, independent of Base/Top — matches it being a
              separately replaceable real-world spare part. Purely mechanical: no ports,
              no electronics.
            */
        attribute :>> mass = sum(body.mass, lid.mass, 'filter'.mass);
        attribute :>> capacity = 450 [mL];
    }

}
