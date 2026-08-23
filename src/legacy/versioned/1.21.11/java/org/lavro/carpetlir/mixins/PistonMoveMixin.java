package org.lavro.carpetlir.mixins;

import net.minecraft.block.Block;
import net.minecraft.block.BlockState;
import net.minecraft.block.PistonBlock;
import net.minecraft.block.entity.BlockEntity;
import net.minecraft.util.math.BlockPos;
import net.minecraft.world.WorldAccess;
import org.lavro.carpetlir.features.renewable.PistonHarvestableAmethystFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Redirect;

@Mixin(PistonBlock.class)
public abstract class PistonMoveMixin {
    /**
     * Replaces only the drop call for blocks that PistonBlock.move has already selected for
     * destruction. Mining, explosions, commands, and every non-piston drop path stay vanilla.
     */
    @Redirect(
            method = "move",
            at = @At(
                    value = "INVOKE",
                    target = "Lnet/minecraft/block/PistonBlock;dropStacks(Lnet/minecraft/block/BlockState;Lnet/minecraft/world/WorldAccess;Lnet/minecraft/util/math/BlockPos;Lnet/minecraft/block/entity/BlockEntity;)V"
            )
    )
    private void carpetlir$dropBuddingAmethystFromPiston(
            BlockState state,
            WorldAccess world,
            BlockPos pos,
            BlockEntity blockEntity
    ) {
        if (PistonHarvestableAmethystFeature.shouldBreakWhenPushed(state)) {
            PistonHarvestableAmethystFeature.dropSelf(world, pos);
            return;
        }

        Block.dropStacks(state, world, pos, blockEntity);
    }
}
