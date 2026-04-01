package org.lavro.carpetlir.mixins;

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
    /**
     * Filters normal crafting / smelting lookups so disabled renewable recipes cannot match.
     */
    @Inject(method = "getFirstMatch(Lnet/minecraft/recipe/RecipeType;Lnet/minecraft/recipe/input/RecipeInput;Lnet/minecraft/world/World;)Ljava/util/Optional;", at = @At("RETURN"), cancellable = true)
    private <I extends RecipeInput, T extends Recipe<I>> void carpetlir$filterDisabledMatches(RecipeType<T> type, I input, World world, CallbackInfoReturnable<Optional<RecipeEntry<T>>> cir) {
        if (cir.getReturnValue().filter(RecipeToggleFeature::isEnabled).isEmpty()) {
            cir.setReturnValue(Optional.empty());
        }
    }
}
