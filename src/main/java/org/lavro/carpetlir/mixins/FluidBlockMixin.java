package org.lavro.carpetlir.mixins;

import net.minecraft.block.BlockState;
import net.minecraft.block.FluidBlock;
import net.minecraft.fluid.FlowableFluid;
import net.minecraft.registry.tag.FluidTags;
import net.minecraft.util.math.BlockPos;
import net.minecraft.world.World;
import org.lavro.carpetlir.features.renewable.CalciteGeneratorFeature;
import org.spongepowered.asm.mixin.Final;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(FluidBlock.class)
public abstract class FluidBlockMixin {
    @Shadow
    @Final
    protected FlowableFluid fluid;

    /**
     * Mirrors vanilla lava-neighbor handling and adds a calcite branch beside the basalt branch
     * so the fluid system stays untouched outside of FluidBlock's own conversion hook.
     */
    @Inject(method = "receiveNeighborFluids", at = @At("HEAD"), cancellable = true)
    private void carpetlir$handleCalciteBranch(World world, BlockPos pos, BlockState state, CallbackInfoReturnable<Boolean> cir) {
        if (!this.fluid.isIn(FluidTags.LAVA)) {
            return;
        }

        cir.setReturnValue(!CalciteGeneratorFeature.receiveNeighborFluids(world, pos));
    }
}
