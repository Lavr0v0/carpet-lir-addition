package org.lavro.carpetlir.mixins;

import net.minecraft.world.item.crafting.Recipe;
import net.minecraft.world.item.crafting.RecipeHolder;
import net.minecraft.world.item.crafting.RecipeType;
import net.minecraft.world.item.crafting.RecipeManager;
import net.minecraft.world.item.crafting.RecipeInput;
import net.minecraft.world.level.Level;
import org.lavro.carpetlir.features.renewable.RecipeToggleFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import java.util.Optional;

@Mixin(RecipeManager.class)
public abstract class RecipeManagerMixin {
    /**
     * Filters normal crafting / smelting lookups so disabled renewable recipes cannot match.
     */
    @Inject(method = "getRecipeFor(Lnet/minecraft/world/item/crafting/RecipeType;Lnet/minecraft/world/item/crafting/RecipeInput;Lnet/minecraft/world/level/Level;)Ljava/util/Optional;", at = @At("RETURN"), cancellable = true)
    private <I extends RecipeInput, T extends Recipe<I>> void carpetlir$filterDisabledMatches(RecipeType<T> type, I input, Level world, CallbackInfoReturnable<Optional<RecipeHolder<T>>> cir) {
        if (cir.getReturnValue().filter(RecipeToggleFeature::isEnabled).isEmpty()) {
            cir.setReturnValue(Optional.empty());
        }
    }

    @Inject(method = "getRecipeFor(Lnet/minecraft/world/item/crafting/RecipeType;Lnet/minecraft/world/item/crafting/RecipeInput;Lnet/minecraft/world/level/Level;Lnet/minecraft/world/item/crafting/RecipeHolder;)Ljava/util/Optional;", at = @At("RETURN"), cancellable = true)
    private <I extends RecipeInput, T extends Recipe<I>> void carpetlir$filterDisabledCachedMatches(RecipeType<T> type, I input, Level world, RecipeHolder<T> recipe, CallbackInfoReturnable<Optional<RecipeHolder<T>>> cir) {
        if (cir.getReturnValue().filter(RecipeToggleFeature::isEnabled).isEmpty()) {
            cir.setReturnValue(Optional.empty());
        }
    }
}

