package org.lavro.carpetlir.features.renewable;

import net.minecraft.recipe.Recipe;
import net.minecraft.util.Identifier;
import org.lavro.carpetlir.CarpetLIRAddition;
import org.lavro.carpetlir.LIRSettings;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.function.BooleanSupplier;

public final class RecipeToggleFeature {
    private static final Map<Identifier, BooleanSupplier> RULE_BY_RECIPE = createRuleMap();

    private RecipeToggleFeature() {
    }

    private static Identifier recipeId(String path) {
        return identifierForTest(CarpetLIRAddition.MOD_ID, path);
    }

    static Identifier identifierForTest(String namespace, String path) {
        return Identifier.of(namespace, path);
    }

    private static Map<Identifier, BooleanSupplier> createRuleMap() {
        Map<Identifier, BooleanSupplier> rules = new HashMap<>();
        registerIfBundled(rules, "gravel_to_tuff_smelting", () -> LIRSettings.renewableTuff);
        registerIfBundled(rules, "lapis_ore_from_calcite_and_amethyst_shard", () -> LIRSettings.renewableLapisOre);
        registerIfBundled(rules, "oak_leaves_from_oak_log_and_sticks", () -> LIRSettings.renewableLeavesCrafting);
        registerIfBundled(rules, "spruce_leaves_from_spruce_log_and_sticks", () -> LIRSettings.renewableLeavesCrafting);
        registerIfBundled(rules, "birch_leaves_from_birch_log_and_sticks", () -> LIRSettings.renewableLeavesCrafting);
        registerIfBundled(rules, "jungle_leaves_from_jungle_log_and_sticks", () -> LIRSettings.renewableLeavesCrafting);
        registerIfBundled(rules, "acacia_leaves_from_acacia_log_and_sticks", () -> LIRSettings.renewableLeavesCrafting);
        registerIfBundled(rules, "dark_oak_leaves_from_dark_oak_log_and_sticks", () -> LIRSettings.renewableLeavesCrafting);
        registerIfBundled(rules, "mangrove_leaves_from_mangrove_log_and_sticks", () -> LIRSettings.renewableLeavesCrafting);
        registerIfBundled(rules, "cherry_leaves_from_cherry_log_and_sticks", () -> LIRSettings.renewableLeavesCrafting);
        registerIfBundled(rules, "pale_oak_leaves_from_pale_oak_log_and_sticks", () -> LIRSettings.renewableLeavesCrafting);
        registerIfBundled(rules, "honeycomb_from_honeycomb_block", () -> LIRSettings.renewableHoneycombCrafting);
        registerIfBundled(rules, "raw_iron_from_cobblestone_and_iron_ingot", () -> LIRSettings.renewableRawOresCrafting);
        registerIfBundled(rules, "raw_copper_from_cobblestone_and_copper_ingot", () -> LIRSettings.renewableRawOresCrafting);
        registerIfBundled(rules, "raw_gold_from_cobblestone_and_gold_ingot", () -> LIRSettings.renewableRawOresCrafting);
        return Collections.unmodifiableMap(rules);
    }

    private static void registerIfBundled(
            Map<Identifier, BooleanSupplier> rules,
            String path,
            BooleanSupplier rule
    ) {
        if (isBundled(path)) {
            rules.put(recipeId(path), rule);
        }
    }

    private static boolean isBundled(String path) {
        ClassLoader classLoader = RecipeToggleFeature.class.getClassLoader();
        for (String directory : new String[]{"recipe", "recipes"}) {
            String resourcePath = "data/" + CarpetLIRAddition.MOD_ID + "/" + directory + "/" + path + ".json";
            if (classLoader.getResource(resourcePath) != null) {
                return true;
            }
        }
        return false;
    }

    public static boolean isEnabled(Recipe<?> recipe) {
        return isEnabled(recipe.getId());
    }

    public static boolean isEnabled(Identifier id) {
        BooleanSupplier rule = RULE_BY_RECIPE.get(id);
        return rule == null || rule.getAsBoolean();
    }

    static Set<Identifier> controlledRecipeIds() {
        return RULE_BY_RECIPE.keySet();
    }
}
