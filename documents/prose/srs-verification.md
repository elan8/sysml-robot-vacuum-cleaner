Each system requirement is verified by at least one verification case in the model. Three methods are used:

- **test** on the assembled robot, for behaviour that depends on the physical world, such as cleaning coverage, docking and the cliff safe stop;
- **software verification** of the firmware on its target, for task behaviour and timing;
- **analysis**, where a requirement is shown by calculation from component data, such as the energy budget and the localization error.

The nine verification cases cover mission control, the safety supervisor, sensor acquisition, actuator control, application privacy, cleaning coverage, docking and charging, navigation performance and the cliff safe stop ({{Verification::verifyCliffSafeStop}}).

The model defines what is to be verified and how. It contains no executed results: no verification case has been run for this revision, and no requirement is claimed as verified.
