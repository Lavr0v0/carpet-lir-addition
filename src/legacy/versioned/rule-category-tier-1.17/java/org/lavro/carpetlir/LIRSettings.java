package org.lavro.carpetlir;

import carpet.settings.Rule;

public final class LIRSettings {
    private LIRSettings() {
    }

    @Rule(
            desc = "Lava flowing over bone blocks generates calcite when it finds an adjacent amethyst block in the same positions used by vanilla basalt generation.",
            category = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean renewableCalcite = false;

    @Rule(
            desc = "Enables the furnace recipe that smelts gravel into tuff.",
            category = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean renewableTuff = false;

    @Rule(
            desc = "Enables the calcite and amethyst shard crafting recipe for lapis ore.",
            category = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean renewableLapisOre = false;

    @Rule(
            desc = "Enables shaped crafting recipes that turn sticks plus matching logs into their corresponding leaves.",
            category = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean renewableLeavesCrafting = false;

    @Rule(
            desc = "Enables the cobblestone plus ingot crafting recipes for raw iron, raw copper, and raw gold.",
            category = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean renewableRawOresCrafting = false;

    @Rule(
            desc = "Enables the recipe that turns one honeycomb block back into four honeycombs.",
            category = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean renewableHoneycombCrafting = false;

    @Rule(
            desc = "Allows bone meal used on dirt to convert it into a grass block when grass can survive there.",
            category = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean boneMealGrassifyDirt = false;

    @Rule(
            desc = "Budding amethyst breaks and drops itself when a piston tries to push it.",
            category = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean pistonHarvestableAmethysts = false;
}
