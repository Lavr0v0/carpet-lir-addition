package org.lavro.carpetlir.mixins;

import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.LiquidBlock;
import net.minecraft.tags.FluidTags;
import net.minecraft.core.BlockPos;
import net.minecraft.world.level.Level;
import org.lavro.carpetlir.features.renewable.CalciteGeneratorFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(LiquidBlock.class)
public abstract class FluidBlockMixin {
    /**
     * Adds the calcite conversion before LiquidBlock performs its normal water and basalt checks.
     * Returning without cancellation for every non-match keeps the vanilla branches authoritative.
     */
    @Inject(method = "shouldSpreadLiquid", at = @At("HEAD"), cancellable = true)
    private void carpetlir$handleCalciteBranch(Level world, BlockPos pos, BlockState state, CallbackInfoReturnable<Boolean> cir) {
        if (!state.getFluidState().is(FluidTags.LAVA)) {
            return;
        }

        if (CalciteGeneratorFeature.tryGenerateCalcite(world, pos)) {
            cir.setReturnValue(false);
        }
    }
}
