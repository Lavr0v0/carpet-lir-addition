package org.lavro.carpetlir.features.renewable;

import net.minecraft.recipe.RecipeEntry;
import net.minecraft.util.Identifier;
import org.lavro.carpetlir.CarpetLIRAddition;
import org.lavro.carpetlir.LIRSettings;

import java.util.Set;

public final class RecipeToggleFeature {
    private static final Identifier GRAVEL_TO_TUFF_SMELTING = Identifier.of(CarpetLIRAddition.MOD_ID, "gravel_to_tuff_smelting");
    private static final Identifier LAPIS_ORE_FROM_CALCITE = Identifier.of(CarpetLIRAddition.MOD_ID, "lapis_ore_from_calcite_and_amethyst_shard");
    private static final Set<Identifier> LEAVES_FROM_LOG_AND_STICKS = Set.of(
            Identifier.of(CarpetLIRAddition.MOD_ID, "oak_leaves_from_oak_log_and_sticks"),
            Identifier.of(CarpetLIRAddition.MOD_ID, "spruce_leaves_from_spruce_log_and_sticks"),
            Identifier.of(CarpetLIRAddition.MOD_ID, "birch_leaves_from_birch_log_and_sticks"),
            Identifier.of(CarpetLIRAddition.MOD_ID, "jungle_leaves_from_jungle_log_and_sticks"),
            Identifier.of(CarpetLIRAddition.MOD_ID, "acacia_leaves_from_acacia_log_and_sticks"),
            Identifier.of(CarpetLIRAddition.MOD_ID, "dark_oak_leaves_from_dark_oak_log_and_sticks"),
            Identifier.of(CarpetLIRAddition.MOD_ID, "mangrove_leaves_from_mangrove_log_and_sticks"),
            Identifier.of(CarpetLIRAddition.MOD_ID, "cherry_leaves_from_cherry_log_and_sticks"),
            Identifier.of(CarpetLIRAddition.MOD_ID, "pale_oak_leaves_from_pale_oak_log_and_sticks")
    );
    private static final Identifier HONEYCOMB_FROM_HONEYCOMB_BLOCK = Identifier.of(CarpetLIRAddition.MOD_ID, "honeycomb_from_honeycomb_block");
    private static final Identifier RAW_IRON_FROM_COBBLESTONE = Identifier.of(CarpetLIRAddition.MOD_ID, "raw_iron_from_cobblestone_and_iron_ingot");
    private static final Identifier RAW_COPPER_FROM_COBBLESTONE = Identifier.of(CarpetLIRAddition.MOD_ID, "raw_copper_from_cobblestone_and_copper_ingot");
    private static final Identifier RAW_GOLD_FROM_COBBLESTONE = Identifier.of(CarpetLIRAddition.MOD_ID, "raw_gold_from_cobblestone_and_gold_ingot");

    private RecipeToggleFeature() {
    }

    public static boolean isEnabled(RecipeEntry<?> recipeEntry) {
        return isEnabled(recipeEntry.id());
    }

    public static boolean isEnabled(Identifier id) {
        if (GRAVEL_TO_TUFF_SMELTING.equals(id)) {
            return LIRSettings.renewableTuff;
        }
        if (LAPIS_ORE_FROM_CALCITE.equals(id)) {
            return LIRSettings.renewableLapisOre;
        }
        if (LEAVES_FROM_LOG_AND_STICKS.contains(id)) {
            return LIRSettings.renewableLeavesCrafting;
        }
        if (HONEYCOMB_FROM_HONEYCOMB_BLOCK.equals(id)) {
            return LIRSettings.renewableHoneycombCrafting;
        }
        if (RAW_IRON_FROM_COBBLESTONE.equals(id)
                || RAW_COPPER_FROM_COBBLESTONE.equals(id)
                || RAW_GOLD_FROM_COBBLESTONE.equals(id)) {
            return LIRSettings.renewableRawOresCrafting;
        }
        return true;
    }
}
