package org.lavro.carpetlir.features.renewable;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;
import net.minecraft.util.Identifier;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.lavro.carpetlir.LIRSettings;

class RecipeToggleFeatureTest {
    @AfterEach
    void restoreDefault() {
        LIRSettings.renewableLeavesCrafting = false;
    }

    @Test
    void disabledRuleRejectsAllSixControlledRecipes() {
        LIRSettings.renewableLeavesCrafting = false;

        assertEquals(6, RecipeToggleFeature.controlledRecipeIds().size());
        assertTrue(RecipeToggleFeature.controlledRecipeIds().stream()
                .noneMatch(RecipeToggleFeature::isEnabled));
    }

    @Test
    void enabledRuleAcceptsAllSixControlledRecipes() {
        LIRSettings.renewableLeavesCrafting = true;

        assertTrue(RecipeToggleFeature.controlledRecipeIds().stream()
                .allMatch(RecipeToggleFeature::isEnabled));
    }

    @Test
    void controlledSetIsExactlyTheSixClassicTrees() {
        Set<String> paths = RecipeToggleFeature.controlledRecipeIds().stream()
                .map(Identifier::getPath)
                .collect(Collectors.toSet());

        assertEquals(new HashSet<>(Arrays.asList(
                "oak_leaves_from_oak_log_and_sticks",
                "spruce_leaves_from_spruce_log_and_sticks",
                "birch_leaves_from_birch_log_and_sticks",
                "jungle_leaves_from_jungle_log_and_sticks",
                "acacia_leaves_from_acacia_log_and_sticks",
                "dark_oak_leaves_from_dark_oak_log_and_sticks"
        )), paths);
    }

    @Test
    void unrelatedShapedRecipeRemainsAvailableWhenRuleIsOff() {
        LIRSettings.renewableLeavesCrafting = false;

        assertTrue(RecipeToggleFeature.isEnabled(new Identifier("minecraft", "crafting_table")));
        assertFalse(RecipeToggleFeature.isEnabled(
                new Identifier("carpetlir", "oak_leaves_from_oak_log_and_sticks")
        ));
    }
}
