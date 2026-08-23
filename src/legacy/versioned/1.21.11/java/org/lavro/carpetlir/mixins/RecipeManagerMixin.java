package org.lavro.carpetlir.mixins;

import com.llamalad7.mixinextras.injector.wrapmethod.WrapMethod;
import com.llamalad7.mixinextras.injector.wrapoperation.Operation;
import net.minecraft.recipe.Recipe;
import net.minecraft.recipe.RecipeEntry;
import net.minecraft.recipe.RecipeType;
import net.minecraft.recipe.ServerRecipeManager;
import net.minecraft.recipe.input.RecipeInput;
import net.minecraft.world.World;
import org.lavro.carpetlir.features.renewable.RecipeToggleFeature;
import org.spongepowered.asm.mixin.Mixin;

import java.util.Optional;

@Mixin(ServerRecipeManager.class)
public abstract class RecipeManagerMixin {
    /**
     * A furnace or other cached lookup may retain a renewable recipe after its Carpet rule is
     * disabled. Replacing that hint with null makes vanilla search the already-filtered recipe
     * stream, so another enabled recipe can still match the same input.
     */
    @WrapMethod(method = "getFirstMatch(Lnet/minecraft/recipe/RecipeType;Lnet/minecraft/recipe/input/RecipeInput;Lnet/minecraft/world/World;Lnet/minecraft/recipe/RecipeEntry;)Ljava/util/Optional;")
    private <I extends RecipeInput, T extends Recipe<I>> Optional<RecipeEntry<T>> carpetlir$skipDisabledCachedHint(
            RecipeType<T> type,
            I input,
            World world,
            RecipeEntry<T> recipeHint,
            Operation<Optional<RecipeEntry<T>>> original
    ) {
        RecipeEntry<T> enabledHint = recipeHint != null && RecipeToggleFeature.isEnabled(recipeHint)
                ? recipeHint
                : null;
        return original.call(type, input, world, enabledHint);
    }
}
