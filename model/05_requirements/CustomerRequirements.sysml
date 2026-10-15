/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Customer requirements: what a household needs from the robot, in the
 * household's own terms. Where the customer knows a figure it is stated, but
 * nothing here says how it is measured. The measurable requirements on the
 * robot are derived in SystemRequirements, and RequirementTraceability shows
 * that every customer requirement is covered.
 */
package StakeholderNeeds {
  private import Elan8Method::Metadata::*;

  requirement <'USR-001'> 'Whole-home cleaning in one run' {
    @RequirementRole { role = user; }
    doc /* We want to start the robot once and have it clean the floors of our whole home, about 80 m², without recharging halfway or leaving large areas untouched. */
  }

  requirement <'USR-SAFE-001'> 'Safe operation in the household' {
    @RequirementRole { role = user; }
    doc /* The robot runs while we are out or busy. It must not fall down the stairs, push over or damage things, hurt children or pets, or become a fire risk while it charges. */
  }

  requirement <'USR-002'> 'Unattended docking and charging' {
    @RequirementRole { role = user; }
    doc /* We do not want to carry the robot to its charger. It should find its dock by itself before the battery is empty and be ready again for the next day. */
  }

  requirement <'USR-003'> 'Reliable navigation at home' {
    @RequirementRole { role = user; }
    doc /* Our home changes: chairs move, doors open and close, toys lie on the floor. The robot should still know where it is and where it has already cleaned. */
  }

  requirement <'USR-004'> 'Mission progress and fault feedback' {
    @RequirementRole { role = user; }
    doc /* We want to see on our phone what the robot is doing, how far it is, and why it stopped when it needs help. */
  }

  requirement <'USR-005'> 'Privacy of the home map' {
    @RequirementRole { role = user; }
    doc /* The map of our home is private. It stays in our home unless we explicitly agree to share it. */
  }

  requirement <'USR-006'> 'Cleaning under furniture' {
    @RequirementRole { role = user; }
    doc /* Most dust collects under the sofa and the beds. The robot has to fit under furniture with about 10 cm of clearance. */
  }

  requirement <'USR-007'> 'Quiet operation' {
    @RequirementRole { role = user; }
    doc /* The robot often runs while someone is at home. A conversation or a phone call in the same room must remain possible. */
  }

  requirement <'USR-008'> 'Easy routine maintenance' {
    @RequirementRole { role = user; }
    doc /* Emptying the dust bin should be the only routine job, needed at most once per cleaning run, and it should take no tools. */
  }

  requirement <'USR-009'> 'Thresholds between rooms' {
    @RequirementRole { role = user; }
    doc /* Our rooms are separated by door thresholds and the edges of rugs. The robot should cross them instead of getting stuck or skipping rooms. */
  }

  requirement <'USR-010'> 'Carrying between floors' {
    @RequirementRole { role = user; }
    doc /* We have two floors and one robot. One person has to be able to carry it upstairs in one hand. */
  }
}
