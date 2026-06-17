package org.lavro.carpetlir.mixins;

import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.LiquidBlock;
import net.minecraft.world.level.material.FlowingFluid;
import net.minecraft.tags.FluidTags;
import net.minecraft.core.BlockPos;
import net.minecraft.world.level.Level;
import org.lavro.carpetlir.features.renewable.CalciteGeneratorFeature;
import org.spongepowered.asm.mixin.Final;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(LiquidBlock.class)
public abstract class FluidBlockMixin {
    @Shadow
    @Final
    protected FlowingFluid fluid;

    /**
     * Mirrors vanilla lava-neighbor handling and adds a calcite branch beside the basalt branch
     * so the fluid system stays untouched outside of LiquidBlock's own conversion hook.
     */
    @Inject(method = "shouldSpreadLiquid", at = @At("HEAD"), cancellable = true)
    private void carpetlir$handleCalciteBranch(Level world, BlockPos pos, BlockState state, CallbackInfoReturnable<Boolean> cir) {
        if (!this.fluid.is(FluidTags.LAVA)) {
            return;
        }

        if (CalciteGeneratorFeature.receiveNeighborFluids(world, pos)) {
            cir.setReturnValue(false);
        }
    }
}

