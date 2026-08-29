package org.lavro.carpetlir;

import carpet.settings.Rule;

public final class LIRSettings {
    private LIRSettings() {
    }

    @Rule(
            desc = "After enabling, place or update lava. It becomes calcite when a bone block is directly below and a regular amethyst block is horizontally adjacent or directly above; water is not required.",
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
            desc = "Changes only reinforced deepslate's mining speed and progress to match obsidian; it does not add a block drop or renewable source.",
            category = {"LIR", "FEATURE"}
    )
    public static boolean obsidianHardnessReinforcedDeepslate = false;

    @Rule(
            desc = "Lets existing reinforced deepslate drop itself when mined with Silk Touch; it recovers a block but does not create a new one.",
            category = {"LIR", "FEATURE"}
    )
    public static boolean silkTouchableReinforcedDeepslate = false;

    @Rule(
            desc = "Provides the renewable source: Wardens drop 1 to 4 reinforced deepslate on death while mob loot is enabled.",
            category = {"LIR", "FEATURE", "RENEWABLE"}
    )
    public static boolean wardensDropReinforcedDeepslate = false;

    @Rule(
            desc = "Lets a piston harvest an existing budding amethyst by breaking and dropping it; this does not make budding amethyst renewable.",
            category = {"LIR", "FEATURE"}
    )
    public static boolean pistonHarvestableAmethysts = false;
}
