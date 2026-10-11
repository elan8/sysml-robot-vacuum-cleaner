Each system requirement is verified by at least one verification case in the model. Four methods are used:

- **test** on the assembled robot, for behaviour that depends on the physical world, such as cleaning coverage, docking, threshold crossing, noise and the cliff safe stop;
- **software verification** of the firmware on its target, for task behaviour and timing;
- **analysis**, where a requirement is shown by calculation from component data, such as the energy budget, the mass budget and the localization error;
- **inspection and measurement** of the assembled robot, for height, mass and dust bin volume.

The matrix below is generated from the model. It names, for every system requirement, the design element that claims it and the verification cases that cover it. The build fails for a requirement without a claim or without a case.

The model defines what is to be verified and how. It contains no executed results: no verification case has been run for this revision, and no requirement is claimed as verified.
