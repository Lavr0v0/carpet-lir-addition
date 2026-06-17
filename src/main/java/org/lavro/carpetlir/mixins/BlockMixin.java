package org.lavro.carpetlir.mixins;

import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.entity.BlockEntity;
import net.minecraft.core.BlockPos;
import net.minecraft.world.level.LevelAccessor;
import org.lavro.carpetlir.features.renewable.PistonHarvestableAmethystFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(net.minecraft.world.level.block.Block.class)
public abstract class BlockMixin {
    /**
     * Overrides the piston-only budding amethyst loot at the common drop hook so vanilla still
     * removes the block and plays break effects, while the custom item drop stays tightly scoped.
     */
    @Inject(
            method = "dropResources(Lnet/minecraft/world/level/block/state/BlockState;Lnet/minecraft/world/level/LevelAccessor;Lnet/minecraft/core/BlockPos;Lnet/minecraft/world/level/block/entity/BlockEntity;)V",
            at = @At("HEAD"),
            cancellable = true
    )
    private static void carpetlir$dropBuddingAmethyst(BlockState state, LevelAccessor world, BlockPos pos, BlockEntity blockEntity, CallbackInfo ci) {
        if (!PistonHarvestableAmethystFeature.shouldDropSelf(state)) {
            return;
        }

        PistonHarvestableAmethystFeature.dropSelf(world, pos);
        ci.cancel();
    }
}

