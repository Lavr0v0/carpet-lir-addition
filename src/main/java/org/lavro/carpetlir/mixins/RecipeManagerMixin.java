package org.lavro.carpetlir.mixins;

import com.llamalad7.mixinextras.injector.wrapmethod.WrapMethod;
import com.llamalad7.mixinextras.injector.wrapoperation.Operation;
import net.minecraft.world.item.crafting.Recipe;
import net.minecraft.world.item.crafting.RecipeHolder;
import net.minecraft.world.item.crafting.RecipeType;
import net.minecraft.world.item.crafting.RecipeManager;
import net.minecraft.world.item.crafting.RecipeInput;
import net.minecraft.world.level.Level;
import org.lavro.carpetlir.features.renewable.RecipeToggleFeature;
import org.spongepowered.asm.mixin.Mixin;

import java.util.Optional;

@Mixin(RecipeManager.class)
public abstract class RecipeManagerMixin {
    /**
     * A furnace or other cached recipe lookup may retain a recipe after its Carpet rule is
     * disabled. Replacing that hint with null lets vanilla fall back to the filtered RecipeMap
     * instead of returning an empty result forever for that cache.
     */
    @WrapMethod(method = "getRecipeFor(Lnet/minecraft/world/item/crafting/RecipeType;Lnet/minecraft/world/item/crafting/RecipeInput;Lnet/minecraft/world/level/Level;Lnet/minecraft/world/item/crafting/RecipeHolder;)Ljava/util/Optional;")
    private <I extends RecipeInput, T extends Recipe<I>> Optional<RecipeHolder<T>> carpetlir$skipDisabledCachedHint(
            RecipeType<T> type,
            I input,
            Level world,
            RecipeHolder<T> recipeHint,
            Operation<Optional<RecipeHolder<T>>> original
    ) {
        RecipeHolder<T> enabledHint = recipeHint != null && RecipeToggleFeature.isEnabled(recipeHint)
                ? recipeHint
                : null;
        return original.call(type, input, world, enabledHint);
    }
}

