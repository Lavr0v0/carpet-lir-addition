package org.lavro.carpetlir.mixins;

import net.minecraft.inventory.Inventory;
import net.minecraft.recipe.Recipe;
import net.minecraft.recipe.RecipeEntry;
import net.minecraft.recipe.RecipeManager;
import net.minecraft.recipe.RecipeType;
import net.minecraft.util.Identifier;
import net.minecraft.world.World;
import org.lavro.carpetlir.features.renewable.RecipeToggleFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import java.util.Optional;

@Mixin(RecipeManager.class)
public abstract class RecipeManagerMixin {
    /** Filters ordinary crafting lookups while preserving any other matching enabled recipe. */
    @Inject(
            method = "getFirstMatch(Lnet/minecraft/recipe/RecipeType;Lnet/minecraft/inventory/Inventory;Lnet/minecraft/world/World;)Ljava/util/Optional;",
            at = @At("RETURN"),
            cancellable = true
    )
    private <C extends Inventory, T extends Recipe<C>> void carpetlir$filterDirectMatch(
            RecipeType<T> type,
            C input,
            World world,
            CallbackInfoReturnable<Optional<RecipeEntry<T>>> cir
    ) {
        carpetlir$replaceDisabledMatch(type, input, world, cir);
    }

    /** Filters the Identifier-based cache used by furnaces and refreshes it with an enabled fallback. */
    @Inject(
            method = "getFirstMatch(Lnet/minecraft/recipe/RecipeType;Lnet/minecraft/inventory/Inventory;Lnet/minecraft/world/World;Lnet/minecraft/util/Identifier;)Ljava/util/Optional;",
            at = @At("RETURN"),
            cancellable = true
    )
    private <C extends Inventory, T extends Recipe<C>> void carpetlir$filterCachedMatch(
            RecipeType<T> type,
            C input,
            World world,
            Identifier recipeHint,
            CallbackInfoReturnable<Optional<RecipeEntry<T>>> cir
    ) {
        carpetlir$replaceDisabledMatch(type, input, world, cir);
    }

    private <C extends Inventory, T extends Recipe<C>> void carpetlir$replaceDisabledMatch(
            RecipeType<T> type,
            C input,
            World world,
            CallbackInfoReturnable<Optional<RecipeEntry<T>>> cir
    ) {
        Optional<RecipeEntry<T>> result = cir.getReturnValue();
        if (result.isEmpty() || result.filter(RecipeToggleFeature::isEnabled).isPresent()) {
            return;
        }

        Optional<RecipeEntry<T>> fallback = ((RecipeManager) (Object) this).listAllOfType(type).stream()
                .filter(RecipeToggleFeature::isEnabled)
                .filter(entry -> entry.value().matches(input, world))
                .findFirst();
        cir.setReturnValue(fallback);
    }
}
