package org.lavro.carpetlir.mixins;

import net.minecraft.recipe.PreparedRecipes;
import net.minecraft.recipe.Recipe;
import net.minecraft.recipe.RecipeEntry;
import net.minecraft.recipe.RecipeType;
import net.minecraft.recipe.input.RecipeInput;
import net.minecraft.world.World;
import org.lavro.carpetlir.features.renewable.RecipeToggleFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import java.util.stream.Stream;

@Mixin(PreparedRecipes.class)
public abstract class PreparedRecipesMixin {
    @Inject(method = "find", at = @At("RETURN"), cancellable = true)
    private <I extends RecipeInput, T extends Recipe<I>> void carpetlir$filterDisabledRecipeStream(RecipeType<T> type, I input, World world, CallbackInfoReturnable<Stream<RecipeEntry<T>>> cir) {
        cir.setReturnValue(cir.getReturnValue().filter(RecipeToggleFeature::isEnabled));
    }
}
