package org.lavro.carpetlir.mixins;

import net.minecraft.block.BlockState;
import net.minecraft.block.entity.BlockEntity;
import net.minecraft.util.math.BlockPos;
import net.minecraft.world.WorldAccess;
import org.lavro.carpetlir.features.renewable.PistonHarvestableAmethystFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(net.minecraft.block.Block.class)
public abstract class BlockMixin {
    /**
     * Overrides the piston-only budding amethyst loot at the common drop hook so vanilla still
     * removes the block and plays break effects, while the custom item drop stays tightly scoped.
     */
    @Inject(
            method = "dropStacks(Lnet/minecraft/block/BlockState;Lnet/minecraft/world/WorldAccess;Lnet/minecraft/util/math/BlockPos;Lnet/minecraft/block/entity/BlockEntity;)V",
            at = @At("HEAD"),
            cancellable = true
    )
    private static void carpetlir$dropBuddingAmethyst(BlockState state, WorldAccess world, BlockPos pos, BlockEntity blockEntity, CallbackInfo ci) {
        if (!PistonHarvestableAmethystFeature.shouldDropSelf(state)) {
            return;
        }

        PistonHarvestableAmethystFeature.dropSelf(world, pos);
        ci.cancel();
    }
}
