package org.lavro.carpetlir.mixins;

import com.mojang.datafixers.util.Pair;
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
        Optional<RecipeEntry<T>> result = cir.getReturnValue();
        if (result.isPresent() && !RecipeToggleFeature.isEnabled(result.get())) {
            cir.setReturnValue(carpetlir$findEnabledMatch(type, input, world));
        }
    }

    /** Filters the Identifier-based furnace cache and returns the fallback id for cache refresh. */
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
            CallbackInfoReturnable<Optional<Pair<Identifier, RecipeEntry<T>>>> cir
    ) {
        Optional<Pair<Identifier, RecipeEntry<T>>> result = cir.getReturnValue();
        if (result.isEmpty() || RecipeToggleFeature.isEnabled(result.get().getSecond())) {
            return;
        }

        cir.setReturnValue(carpetlir$findEnabledMatch(type, input, world)
                .map(entry -> Pair.of(entry.id(), entry)));
    }

    private <C extends Inventory, T extends Recipe<C>> Optional<RecipeEntry<T>> carpetlir$findEnabledMatch(
            RecipeType<T> type,
            C input,
            World world
    ) {
        return ((RecipeManager) (Object) this).listAllOfType(type).stream()
                .filter(RecipeToggleFeature::isEnabled)
                .filter(entry -> entry.value().matches(input, world))
                .findFirst();
    }
}
