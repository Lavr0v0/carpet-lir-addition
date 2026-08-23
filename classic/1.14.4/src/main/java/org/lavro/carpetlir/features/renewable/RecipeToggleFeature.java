package org.lavro.carpetlir.features.renewable;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import net.minecraft.util.Identifier;
import org.lavro.carpetlir.CarpetLIRAddition;
import org.lavro.carpetlir.LIRSettings;

public final class RecipeToggleFeature {
    private static final Set<Identifier> CONTROLLED_RECIPES = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            recipeId("oak_leaves_from_oak_log_and_sticks"),
            recipeId("spruce_leaves_from_spruce_log_and_sticks"),
            recipeId("birch_leaves_from_birch_log_and_sticks"),
            recipeId("jungle_leaves_from_jungle_log_and_sticks"),
            recipeId("acacia_leaves_from_acacia_log_and_sticks"),
            recipeId("dark_oak_leaves_from_dark_oak_log_and_sticks")
    )));

    private RecipeToggleFeature() {
    }

    private static Identifier recipeId(String path) {
        return new Identifier(CarpetLIRAddition.MOD_ID, path);
    }

    public static boolean isEnabled(Identifier recipeId) {
        return !CONTROLLED_RECIPES.contains(recipeId) || LIRSettings.renewableLeavesCrafting;
    }

    static Set<Identifier> controlledRecipeIds() {
        return CONTROLLED_RECIPES;
    }
}
