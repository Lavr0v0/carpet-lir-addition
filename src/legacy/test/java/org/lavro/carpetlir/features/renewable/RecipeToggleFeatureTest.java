package org.lavro.carpetlir.features.renewable;

import net.minecraft.util.Identifier;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.lavro.carpetlir.CarpetLIRAddition;
import org.lavro.carpetlir.LIRSettings;

import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RecipeToggleFeatureTest {
    private static final Set<String> KNOWN_RECIPE_PATHS = Set.of(
            "gravel_to_tuff_smelting",
            "lapis_ore_from_calcite_and_amethyst_shard",
            "oak_leaves_from_oak_log_and_sticks",
            "spruce_leaves_from_spruce_log_and_sticks",
            "birch_leaves_from_birch_log_and_sticks",
            "jungle_leaves_from_jungle_log_and_sticks",
            "acacia_leaves_from_acacia_log_and_sticks",
            "dark_oak_leaves_from_dark_oak_log_and_sticks",
            "mangrove_leaves_from_mangrove_log_and_sticks",
            "cherry_leaves_from_cherry_log_and_sticks",
            "pale_oak_leaves_from_pale_oak_log_and_sticks",
            "honeycomb_from_honeycomb_block",
            "raw_iron_from_cobblestone_and_iron_ingot",
            "raw_copper_from_cobblestone_and_copper_ingot",
            "raw_gold_from_cobblestone_and_gold_ingot"
    );

    @BeforeEach
    @AfterEach
    void resetRecipeRules() {
        resetAllRules();
    }

    @Test
    void everyBundledRecipeIsControlledByARule() {
        Set<Identifier> bundledRecipeIds = KNOWN_RECIPE_PATHS.stream()
                .filter(RecipeToggleFeatureTest::isBundledRecipe)
                .map(path -> RecipeToggleFeature.identifierForTest(CarpetLIRAddition.MOD_ID, path))
                .collect(Collectors.toUnmodifiableSet());

        assertEquals(bundledRecipeIds, RecipeToggleFeature.controlledRecipeIds());
    }

    @Test
    void controlledRecipesAreDisabledByDefaultButUnrelatedRecipesPassThrough() {
        RecipeToggleFeature.controlledRecipeIds()
                .forEach(id -> assertFalse(RecipeToggleFeature.isEnabled(id), id.toString()));

        assertTrue(RecipeToggleFeature.isEnabled(
                RecipeToggleFeature.identifierForTest("minecraft", "crafting_table")
        ));
    }

    @Test
    void eachRuleEnablesOnlyItsRecipeGroup() {
        assertEnabledRecipes(() -> LIRSettings.renewableTuff = true, "gravel_to_tuff_smelting");
        assertEnabledRecipes(() -> LIRSettings.renewableLapisOre = true, "lapis_ore_from_calcite_and_amethyst_shard");
        assertEnabledRecipes(
                () -> LIRSettings.renewableLeavesCrafting = true,
                "oak_leaves_from_oak_log_and_sticks",
                "spruce_leaves_from_spruce_log_and_sticks",
                "birch_leaves_from_birch_log_and_sticks",
                "jungle_leaves_from_jungle_log_and_sticks",
                "acacia_leaves_from_acacia_log_and_sticks",
                "dark_oak_leaves_from_dark_oak_log_and_sticks",
                "mangrove_leaves_from_mangrove_log_and_sticks",
                "cherry_leaves_from_cherry_log_and_sticks",
                "pale_oak_leaves_from_pale_oak_log_and_sticks"
        );
        assertEnabledRecipes(
                () -> LIRSettings.renewableRawOresCrafting = true,
                "raw_iron_from_cobblestone_and_iron_ingot",
                "raw_copper_from_cobblestone_and_copper_ingot",
                "raw_gold_from_cobblestone_and_gold_ingot"
        );
        assertEnabledRecipes(() -> LIRSettings.renewableHoneycombCrafting = true, "honeycomb_from_honeycomb_block");
    }

    private static void assertEnabledRecipes(Runnable enableRule, String... expectedPaths) {
        resetAllRules();
        enableRule.run();
        Set<Identifier> expected = Stream.of(expectedPaths)
                .filter(RecipeToggleFeatureTest::isBundledRecipe)
                .map(path -> RecipeToggleFeature.identifierForTest(CarpetLIRAddition.MOD_ID, path))
                .collect(Collectors.toUnmodifiableSet());
        Set<Identifier> enabled = RecipeToggleFeature.controlledRecipeIds().stream()
                .filter(RecipeToggleFeature::isEnabled)
                .collect(Collectors.toUnmodifiableSet());
        assertEquals(expected, enabled);
    }

    private static boolean isBundledRecipe(String path) {
        ClassLoader classLoader = RecipeToggleFeatureTest.class.getClassLoader();
        for (String directory : new String[]{"recipe", "recipes"}) {
            String resourcePath = "data/" + CarpetLIRAddition.MOD_ID + "/" + directory + "/" + path + ".json";
            if (classLoader.getResource(resourcePath) != null) {
                return true;
            }
        }
        return false;
    }

    private static void resetAllRules() {
        LIRSettings.renewableTuff = false;
        LIRSettings.renewableLapisOre = false;
        LIRSettings.renewableLeavesCrafting = false;
        LIRSettings.renewableRawOresCrafting = false;
        LIRSettings.renewableHoneycombCrafting = false;
    }
}
