package org.lavro.carpetlir.features.renewable;

import net.minecraft.recipe.RecipeEntry;
import net.minecraft.registry.RegistryKey;
import net.minecraft.util.Identifier;
import org.lavro.carpetlir.CarpetLIRAddition;
import org.lavro.carpetlir.LIRSettings;

import java.util.Map;
import java.util.Set;
import java.util.function.BooleanSupplier;

public final class RecipeToggleFeature {
    private static final Map<Identifier, BooleanSupplier> RULE_BY_RECIPE = Map.ofEntries(
            Map.entry(recipeId("gravel_to_tuff_smelting"), () -> LIRSettings.renewableTuff),
            Map.entry(recipeId("lapis_ore_from_calcite_and_amethyst_shard"), () -> LIRSettings.renewableLapisOre),
            Map.entry(recipeId("oak_leaves_from_oak_log_and_sticks"), () -> LIRSettings.renewableLeavesCrafting),
            Map.entry(recipeId("spruce_leaves_from_spruce_log_and_sticks"), () -> LIRSettings.renewableLeavesCrafting),
            Map.entry(recipeId("birch_leaves_from_birch_log_and_sticks"), () -> LIRSettings.renewableLeavesCrafting),
            Map.entry(recipeId("jungle_leaves_from_jungle_log_and_sticks"), () -> LIRSettings.renewableLeavesCrafting),
            Map.entry(recipeId("acacia_leaves_from_acacia_log_and_sticks"), () -> LIRSettings.renewableLeavesCrafting),
            Map.entry(recipeId("dark_oak_leaves_from_dark_oak_log_and_sticks"), () -> LIRSettings.renewableLeavesCrafting),
            Map.entry(recipeId("mangrove_leaves_from_mangrove_log_and_sticks"), () -> LIRSettings.renewableLeavesCrafting),
            Map.entry(recipeId("cherry_leaves_from_cherry_log_and_sticks"), () -> LIRSettings.renewableLeavesCrafting),
            Map.entry(recipeId("pale_oak_leaves_from_pale_oak_log_and_sticks"), () -> LIRSettings.renewableLeavesCrafting),
            Map.entry(recipeId("honeycomb_from_honeycomb_block"), () -> LIRSettings.renewableHoneycombCrafting),
            Map.entry(recipeId("raw_iron_from_cobblestone_and_iron_ingot"), () -> LIRSettings.renewableRawOresCrafting),
            Map.entry(recipeId("raw_copper_from_cobblestone_and_copper_ingot"), () -> LIRSettings.renewableRawOresCrafting),
            Map.entry(recipeId("raw_gold_from_cobblestone_and_gold_ingot"), () -> LIRSettings.renewableRawOresCrafting)
    );

    private RecipeToggleFeature() {
    }

    private static Identifier recipeId(String path) {
        return Identifier.of(CarpetLIRAddition.MOD_ID, path);
    }

    public static boolean isEnabled(RecipeEntry<?> recipeEntry) {
        return isEnabled(recipeEntry.id());
    }

    public static boolean isEnabled(RegistryKey<?> recipeKey) {
        return isEnabled(recipeKey.getValue());
    }

    public static boolean isEnabled(Identifier id) {
        BooleanSupplier rule = RULE_BY_RECIPE.get(id);
        return rule == null || rule.getAsBoolean();
    }

    static Set<Identifier> controlledRecipeIds() {
        return RULE_BY_RECIPE.keySet();
    }
}
