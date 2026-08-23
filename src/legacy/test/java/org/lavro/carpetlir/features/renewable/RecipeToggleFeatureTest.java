package org.lavro.carpetlir.features.renewable;

import net.minecraft.util.Identifier;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.lavro.carpetlir.CarpetLIRAddition;
import org.lavro.carpetlir.LIRSettings;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RecipeToggleFeatureTest {
    private static final Path RECIPE_DIRECTORY = Path.of(
            "src", "main", "resources", "data", CarpetLIRAddition.MOD_ID, "recipe"
    );

    @BeforeEach
    @AfterEach
    void resetRecipeRules() {
        resetAllRules();
    }

    @Test
    void everyBundledRecipeIsControlledByARule() throws IOException {
        Set<Identifier> bundledRecipeIds;
        try (Stream<Path> files = Files.list(RECIPE_DIRECTORY)) {
            bundledRecipeIds = files
                    .filter(path -> path.getFileName().toString().endsWith(".json"))
                    .map(path -> path.getFileName().toString().replaceFirst("\\.json$", ""))
                    .map(path -> Identifier.of(CarpetLIRAddition.MOD_ID, path))
                    .collect(Collectors.toUnmodifiableSet());
        }

        assertEquals(bundledRecipeIds, RecipeToggleFeature.controlledRecipeIds());
    }

    @Test
    void controlledRecipesAreDisabledByDefaultButUnrelatedRecipesPassThrough() {
        RecipeToggleFeature.controlledRecipeIds()
                .forEach(id -> assertFalse(RecipeToggleFeature.isEnabled(id), id.toString()));

        assertTrue(RecipeToggleFeature.isEnabled(Identifier.ofVanilla("crafting_table")));
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
                .map(path -> Identifier.of(CarpetLIRAddition.MOD_ID, path))
                .collect(Collectors.toUnmodifiableSet());
        Set<Identifier> enabled = RecipeToggleFeature.controlledRecipeIds().stream()
                .filter(RecipeToggleFeature::isEnabled)
                .collect(Collectors.toUnmodifiableSet());
        assertEquals(expected, enabled);
    }

    private static void resetAllRules() {
        LIRSettings.renewableTuff = false;
        LIRSettings.renewableLapisOre = false;
        LIRSettings.renewableLeavesCrafting = false;
        LIRSettings.renewableRawOresCrafting = false;
        LIRSettings.renewableHoneycombCrafting = false;
    }
}
