package org.lavro.carpetlir.mixins;

import com.mojang.datafixers.util.Pair;
import net.minecraft.inventory.Inventory;
import net.minecraft.recipe.Recipe;
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
    /** Filters ordinary lookups while preserving any later matching enabled recipe. */
    @Inject(
            method = "getFirstMatch(Lnet/minecraft/recipe/RecipeType;Lnet/minecraft/inventory/Inventory;Lnet/minecraft/world/World;)Ljava/util/Optional;",
            at = @At("RETURN"),
            cancellable = true
    )
    private <C extends Inventory, T extends Recipe<C>> void carpetlir$filterDirectMatch(
            RecipeType<T> type,
            C input,
            World world,
            CallbackInfoReturnable<Optional<T>> cir
    ) {
        Optional<T> result = cir.getReturnValue();
        if (result.isPresent() && !RecipeToggleFeature.isEnabled(result.get())) {
            cir.setReturnValue(carpetlir$findEnabledMatch(type, input, world));
        }
    }

    /** Filters the Identifier-based furnace cache and refreshes it with the fallback recipe's id. */
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
            CallbackInfoReturnable<Optional<Pair<Identifier, T>>> cir
    ) {
        Optional<Pair<Identifier, T>> result = cir.getReturnValue();
        if (result.isEmpty() || RecipeToggleFeature.isEnabled(result.get().getSecond())) {
            return;
        }

        cir.setReturnValue(carpetlir$findEnabledMatch(type, input, world)
                .map(recipe -> Pair.of(recipe.getId(), recipe)));
    }

    private <C extends Inventory, T extends Recipe<C>> Optional<T> carpetlir$findEnabledMatch(
            RecipeType<T> type,
            C input,
            World world
    ) {
        return ((RecipeManager) (Object) this).listAllOfType(type).stream()
                .filter(RecipeToggleFeature::isEnabled)
                .filter(recipe -> recipe.matches(input, world))
                .findFirst();
    }
}
