package org.lavro.carpetlir.features.renewable;

import net.minecraft.util.Identifier;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.lavro.carpetlir.CarpetLIRAddition;
import org.lavro.carpetlir.LIRSettings;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RecipeToggleFeatureTest {
    private static final Set<String> KNOWN_RECIPE_PATHS = Collections.unmodifiableSet(
            Arrays.stream(new String[]{
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
            }).collect(Collectors.toSet())
    );
    private static final Map<String, Set<String>> RECIPE_PATHS_BY_RULE = createRecipePathsByRule();

    @BeforeEach
    @AfterEach
    void resetRecipeRules() throws IllegalAccessException {
        resetAllRules();
    }

    @Test
    void everyBundledRecipeIsControlledByARule() {
        Set<Identifier> bundledRecipeIds = KNOWN_RECIPE_PATHS.stream()
                .filter(RecipeToggleFeatureTest::isBundledRecipe)
                .map(path -> RecipeToggleFeature.identifierForTest(CarpetLIRAddition.MOD_ID, path))
                .collect(Collectors.toSet());

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
        for (Map.Entry<String, Set<String>> entry : RECIPE_PATHS_BY_RULE.entrySet()) {
            Set<String> bundledPaths = entry.getValue().stream()
                    .filter(RecipeToggleFeatureTest::isBundledRecipe)
                    .collect(Collectors.toSet());
            if (hasRule(entry.getKey())) {
                assertEnabledRecipes(entry.getKey(), bundledPaths);
            } else {
                assertTrue(bundledPaths.isEmpty(),
                        "recipes for unavailable rule " + entry.getKey() + " must not be bundled");
            }
        }
    }

    private static void assertEnabledRecipes(String ruleName, Set<String> expectedPaths) {
        resetAllRulesUnchecked();
        setRule(ruleName, true);
        Set<Identifier> expected = expectedPaths.stream()
                .map(path -> RecipeToggleFeature.identifierForTest(CarpetLIRAddition.MOD_ID, path))
                .collect(Collectors.toSet());
        Set<Identifier> enabled = RecipeToggleFeature.controlledRecipeIds().stream()
                .filter(RecipeToggleFeature::isEnabled)
                .collect(Collectors.toSet());
        assertEquals(expected, enabled);
    }

    private static Map<String, Set<String>> createRecipePathsByRule() {
        Map<String, Set<String>> groups = new LinkedHashMap<>();
        groups.put("renewableTuff", paths("gravel_to_tuff_smelting"));
        groups.put("renewableLapisOre", paths("lapis_ore_from_calcite_and_amethyst_shard"));
        groups.put("renewableLeavesCrafting", paths(
                "oak_leaves_from_oak_log_and_sticks",
                "spruce_leaves_from_spruce_log_and_sticks",
                "birch_leaves_from_birch_log_and_sticks",
                "jungle_leaves_from_jungle_log_and_sticks",
                "acacia_leaves_from_acacia_log_and_sticks",
                "dark_oak_leaves_from_dark_oak_log_and_sticks",
                "mangrove_leaves_from_mangrove_log_and_sticks",
                "cherry_leaves_from_cherry_log_and_sticks",
                "pale_oak_leaves_from_pale_oak_log_and_sticks"
        ));
        groups.put("renewableRawOresCrafting", paths(
                "raw_iron_from_cobblestone_and_iron_ingot",
                "raw_copper_from_cobblestone_and_copper_ingot",
                "raw_gold_from_cobblestone_and_gold_ingot"
        ));
        groups.put("renewableHoneycombCrafting", paths("honeycomb_from_honeycomb_block"));
        return Collections.unmodifiableMap(groups);
    }

    private static Set<String> paths(String... values) {
        return Collections.unmodifiableSet(Arrays.stream(values).collect(Collectors.toSet()));
    }

    private static boolean hasRule(String ruleName) {
        try {
            LIRSettings.class.getField(ruleName);
            return true;
        } catch (NoSuchFieldException ignored) {
            return false;
        }
    }

    private static void setRule(String ruleName, boolean value) {
        try {
            LIRSettings.class.getField(ruleName).setBoolean(null, value);
        } catch (ReflectiveOperationException exception) {
            throw new AssertionError("Unable to update rule " + ruleName, exception);
        }
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

    private static void resetAllRules() throws IllegalAccessException {
        for (Field field : LIRSettings.class.getDeclaredFields()) {
            if (field.getType() == boolean.class && Modifier.isStatic(field.getModifiers())) {
                field.setBoolean(null, false);
            }
        }
    }

    private static void resetAllRulesUnchecked() {
        try {
            resetAllRules();
        } catch (IllegalAccessException exception) {
            throw new AssertionError("Unable to reset Carpet rules", exception);
        }
    }
}
