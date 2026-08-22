package org.lavro.carpetlir.mixins;

import net.minecraft.world.item.crafting.Recipe;
import net.minecraft.world.item.crafting.RecipeHolder;
import net.minecraft.world.item.crafting.RecipeMap;
import net.minecraft.world.item.crafting.RecipeType;
import net.minecraft.world.item.crafting.RecipeInput;
import net.minecraft.world.level.Level;
import org.lavro.carpetlir.features.renewable.RecipeToggleFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import java.util.stream.Stream;

@Mixin(RecipeMap.class)
public abstract class PreparedRecipesMixin {
    /**
     * Filters the final matching stream instead of mutating Minecraft's loaded recipe registry.
     * This allows Carpet rules to change at runtime while leaving unrelated recipes untouched.
     */
    @Inject(method = "getRecipesFor", at = @At("RETURN"), cancellable = true)
    private <I extends RecipeInput, T extends Recipe<I>> void carpetlir$filterDisabledRecipeStream(RecipeType<T> type, I input, Level world, CallbackInfoReturnable<Stream<RecipeHolder<T>>> cir) {
        cir.setReturnValue(cir.getReturnValue().filter(RecipeToggleFeature::isEnabled));
    }
}

