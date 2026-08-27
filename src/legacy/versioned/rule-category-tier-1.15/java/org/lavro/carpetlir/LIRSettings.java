package org.lavro.carpetlir;

import carpet.settings.Rule;

public final class LIRSettings {
    private LIRSettings() {
    }

    @Rule(
            desc = "Allows bone meal used on dirt to convert it into a grass block when grass can survive there.",
            category = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean boneMealGrassifyDirt = false;

    @Rule(
            desc = "Enables shaped crafting recipes that turn sticks plus matching logs into their corresponding leaves.",
            category = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean renewableLeavesCrafting = false;

    @Rule(
            desc = "Enables the recipe that turns one honeycomb block back into four honeycombs.",
            category = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean renewableHoneycombCrafting = false;
}
