package org.lavro.carpetlir.mixins;

import com.llamalad7.mixinextras.injector.wrapmethod.WrapMethod;
import com.llamalad7.mixinextras.injector.wrapoperation.Operation;
import net.minecraft.recipe.Recipe;
import net.minecraft.recipe.RecipeEntry;
import net.minecraft.recipe.RecipeManager;
import net.minecraft.recipe.RecipeType;
import net.minecraft.recipe.input.RecipeInput;
import net.minecraft.world.World;
import org.lavro.carpetlir.features.renewable.RecipeToggleFeature;
import org.spongepowered.asm.mixin.Mixin;

import java.util.Optional;

@Mixin(RecipeManager.class)
public abstract class RecipeManagerMixin {
    /**
     * The old recipe manager has no prepared stream to filter. Clear disabled cache hints, then
     * replace a disabled first result with the first enabled recipe that actually matches.
     */
    @WrapMethod(method = "getFirstMatch(Lnet/minecraft/recipe/RecipeType;Lnet/minecraft/recipe/input/RecipeInput;Lnet/minecraft/world/World;Lnet/minecraft/recipe/RecipeEntry;)Ljava/util/Optional;")
    private <I extends RecipeInput, T extends Recipe<I>> Optional<RecipeEntry<T>> carpetlir$filterDisabledMatches(
            RecipeType<T> type,
            I input,
            World world,
            RecipeEntry<T> recipeHint,
            Operation<Optional<RecipeEntry<T>>> original
    ) {
        RecipeEntry<T> enabledHint = recipeHint != null && RecipeToggleFeature.isEnabled(recipeHint)
                ? recipeHint
                : null;
        Optional<RecipeEntry<T>> result = original.call(type, input, world, enabledHint);
        if (result.isEmpty() || result.filter(RecipeToggleFeature::isEnabled).isPresent()) {
            return result;
        }

        return ((RecipeManager) (Object) this).listAllOfType(type).stream()
                .filter(RecipeToggleFeature::isEnabled)
                .filter(entry -> entry.value().matches(input, world))
                .findFirst();
    }
}
