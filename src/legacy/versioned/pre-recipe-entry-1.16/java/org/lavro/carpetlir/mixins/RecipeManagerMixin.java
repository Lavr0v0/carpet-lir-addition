package org.lavro.carpetlir.mixins;

import net.minecraft.recipe.Recipe;
import net.minecraft.recipe.RecipeManager;
import org.lavro.carpetlir.features.renewable.RecipeToggleFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Redirect;

import java.util.Collection;
import java.util.stream.Stream;

@Mixin(RecipeManager.class)
public abstract class RecipeManagerMixin {
    /** Filters disabled controlled recipes before vanilla selects its first match. */
    @Redirect(
            method = "getFirstMatch(Lnet/minecraft/recipe/RecipeType;Lnet/minecraft/inventory/Inventory;Lnet/minecraft/world/World;)Ljava/util/Optional;",
            at = @At(
                    value = "INVOKE",
                    target = "Ljava/util/Collection;stream()Ljava/util/stream/Stream;"
            )
    )
    private <T extends Recipe<?>> Stream<T> carpetlir$filterDisabledRecipes(Collection<T> recipes) {
        return recipes.stream().filter(RecipeToggleFeature::isEnabled);
    }
}
