package org.lavro.carpetlir;

import carpet.settings.Rule;

public final class LIRSettings {
    private LIRSettings() {
    }

    @Rule(
            desc = "Allows bone meal to convert dirt into grass where grass can survive.",
            category = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean boneMealGrassifyDirt = false;

    @Rule(
            desc = "Enables recipes that craft four classic leaves from four sticks and a matching log.",
            category = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean renewableLeavesCrafting = false;
}
