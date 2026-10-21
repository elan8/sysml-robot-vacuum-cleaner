The robot consists of six line-replaceable units:

- the **base module**, which carries the chassis, the two drive trains, the cleaning head, four cliff sensors, the power module and the dock interface ({{PhysicalArchitecture::BaseModule}});
- the **main control board**, with the microcontroller, the two motor drivers, the inertial measurement unit and the wireless module ({{PhysicalArchitecture::MainPcbModule}});
- the **top module**, with the LiDAR, three time-of-flight sensors, the bumper and the human-machine interface ({{PhysicalArchitecture::TopModule}});
- the **dust bin**, with its lid and filter ({{PhysicalArchitecture::DustBin}});
- the **base wiring harness** and the **top wiring harness**, which connect the main control board to the two modules ({{PhysicalArchitecture::BaseWiringHarness}}, {{PhysicalArchitecture::TopWiringHarness}}).

Modules are connected only through typed ports. Power, signal and material paths are modelled explicitly, including dock charging, the protected battery rail and the debris path from the cleaning head to the dust bin. The diagrams in this chapter are drawn from those connections.

The cleaning direction defines the front of the robot. Two forward side brushes sweep
inward towards the main roller and suction intake. A belt-and-gear transmission drives
all three brushes from the existing 8 W brush motor; there are no separate side-brush
motors or control channels. This power rating is an estimate for the complete brush train.
The additional brushes and transmission are included in the BOM and mass roll-up.

The caster supports the **rear**, behind both the main roller and suction intake.
The model records their longitudinal positions relative to the drive axle and asserts
this ordering. The product-layout figure uses the same coordinates. Its body diameter
is nominally 340 mm; the modeled height is 55 mm base plus 37 mm top (92 mm total),
within the allocated 57 mm and 38 mm budgets and the 95 mm system limit.
