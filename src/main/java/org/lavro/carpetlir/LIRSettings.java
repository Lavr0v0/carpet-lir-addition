package org.lavro.carpetlir;

import carpet.api.settings.Rule;

public class LIRSettings {
    private LIRSettings() {
    }

    @Rule(
            categories = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean renewableCalcite = false;

    @Rule(
            categories = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean renewableTuff = false;

    @Rule(
            categories = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean renewableLapisOre = false;

    @Rule(
            categories = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean renewableLeavesCrafting = false;

    @Rule(
            categories = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean renewableRawOresCrafting = false;

    @Rule(
            categories = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean renewableHoneycombCrafting = false;

    @Rule(
            categories = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean boneMealGrassifyDirt = false;

    @Rule(
            categories = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean obsidianHardnessReinforcedDeepslate = false;

    @Rule(
            categories = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean silkTouchableReinforcedDeepslate = false;

    @Rule(
            categories = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean wardensDropReinforcedDeepslate = false;

    @Rule(
            categories = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean pistonHarvestableAmethysts = false;
}
