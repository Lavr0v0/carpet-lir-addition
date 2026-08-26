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
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import java.util.Optional;

@Mixin(ServerRecipeManager.class)
public abstract class RecipeManagerMixin {
    /** Prevents a disabled renewable recipe from escaping the prepared-recipe stream filter. */
    @Inject(method = "getFirstMatch(Lnet/minecraft/recipe/RecipeType;Lnet/minecraft/recipe/input/RecipeInput;Lnet/minecraft/world/World;)Ljava/util/Optional;", at = @At("RETURN"), cancellable = true)
    private <I extends RecipeInput, T extends Recipe<I>> void carpetlir$filterDisabledMatches(RecipeType<T> type, I input, World world, CallbackInfoReturnable<Optional<RecipeEntry<T>>> cir) {
        if (cir.getReturnValue().filter(RecipeToggleFeature::isEnabled).isEmpty()) {
            cir.setReturnValue(Optional.empty());
        }
    }

    /**
     * Furnaces retain their last matching recipe as a hint. Removing a disabled controlled recipe
     * from that hint forces vanilla to search the already-filtered prepared recipe stream instead.
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
