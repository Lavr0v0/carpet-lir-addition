package org.lavro.carpetlir.mixins;

import net.minecraft.block.BlockState;
import net.minecraft.block.FluidBlock;
import net.minecraft.registry.tag.FluidTags;
import net.minecraft.util.math.BlockPos;
import net.minecraft.world.World;
import org.lavro.carpetlir.features.renewable.CalciteGeneratorFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(FluidBlock.class)
public abstract class FluidBlockMixin {
    /**
     * Adds the calcite conversion before FluidBlock performs its normal water and basalt checks.
     * Returning without cancellation for every non-match keeps the vanilla branches authoritative.
     */
    @Inject(method = "receiveNeighborFluids", at = @At("HEAD"), cancellable = true)
    private void carpetlir$handleCalciteBranch(World world, BlockPos pos, BlockState state, CallbackInfoReturnable<Boolean> cir) {
        if (!state.getFluidState().isIn(FluidTags.LAVA)) {
            return;
        }

        if (CalciteGeneratorFeature.tryGenerateCalcite(world, pos)) {
            cir.setReturnValue(false);
        }
    }
}
