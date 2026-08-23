package org.lavro.carpetlir.mixins;

import net.minecraft.inventory.CraftingInventory;
import net.minecraft.recipe.ShapedRecipe;
import net.minecraft.world.World;
import org.lavro.carpetlir.features.renewable.RecipeToggleFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(ShapedRecipe.class)
public abstract class ShapedRecipeMixin {
    /**
     * Keeps the mixin limited to the vanilla match boundary. All recipe ownership and rule
     * decisions remain in RecipeToggleFeature, so unrelated shaped recipes stay vanilla.
     */
    @Inject(method = "matches", at = @At("HEAD"), cancellable = true)
    private void carpetlir$skipDisabledLeafRecipe(
            CraftingInventory inventory,
            World world,
            CallbackInfoReturnable<Boolean> cir
    ) {
        ShapedRecipe recipe = (ShapedRecipe) (Object) this;
        if (!RecipeToggleFeature.isEnabled(recipe.getId())) {
            cir.setReturnValue(false);
        }
    }
}
