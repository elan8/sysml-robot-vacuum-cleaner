The robot consists of six line-replaceable units:

- the **base module**, which carries the chassis, the two drive trains, the cleaning head, four cliff sensors, the power module and the dock interface ({{PhysicalArchitecture::BaseModule}});
- the **main control board**, with the microcontroller, the two motor drivers, the inertial measurement unit and the wireless module ({{PhysicalArchitecture::MainPcbModule}});
- the **top module**, with the LiDAR, three time-of-flight sensors, the bumper and the human-machine interface ({{PhysicalArchitecture::TopModule}});
- the **dust bin**, with its lid and filter ({{PhysicalArchitecture::DustBin}});
- the **base wiring harness** and the **top wiring harness**, which connect the main control board to the two modules ({{PhysicalArchitecture::BaseWiringHarness}}, {{PhysicalArchitecture::TopWiringHarness}}).

Modules are connected only through typed ports. Power, signal and material paths are modelled explicitly, including dock charging, the protected battery rail and the debris path from the cleaning head to the dust bin. The diagrams in this chapter are drawn from those connections.
