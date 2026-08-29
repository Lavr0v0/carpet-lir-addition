package org.lavro.carpetlir.mixins;

import net.minecraft.core.BlockPos;
import net.minecraft.tags.FluidTags;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.LiquidBlock;
import net.minecraft.world.level.block.state.BlockState;
import org.lavro.carpetlir.features.renewable.CalciteGeneratorFeature;
import org.lavro.carpetlir.features.renewable.CinnabarGeneratorFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(LiquidBlock.class)
public abstract class FluidBlockMixin {
    /**
     * Adds the rule-gated generator branches before LiquidBlock performs its normal water and basalt checks.
     * Both helpers return without changing the world on a non-match, keeping vanilla authoritative.
     */
    @Inject(method = "shouldSpreadLiquid", at = @At("HEAD"), cancellable = true)
    private void carpetlir$handleRenewableBranches(Level world, BlockPos pos, BlockState state, CallbackInfoReturnable<Boolean> cir) {
        if (!state.getFluidState().is(FluidTags.LAVA)) {
            return;
        }

        if (CinnabarGeneratorFeature.tryGenerateCinnabar(world, pos)
                || CalciteGeneratorFeature.tryGenerateCalcite(world, pos)) {
            cir.setReturnValue(false);
        }
    }
}
