package org.lavro.carpetlir.mixins;

import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.piston.PistonBaseBlock;
import net.minecraft.core.BlockPos;
import net.minecraft.world.level.Level;
import org.lavro.carpetlir.LIRSettings;
import org.lavro.carpetlir.helpers.PistonHarvestContext;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(PistonBaseBlock.class)
public abstract class PistonBlockMixin {
    /**
     * Tracks only piston block-event execution so the custom budding-amethyst drop is limited
     * to mechanical breaks and never leaks into ordinary mining or explosion loot paths.
     */
    @Inject(method = "triggerEvent", at = @At("HEAD"))
    private void carpetlir$enterHarvestContext(BlockState state, Level world, BlockPos pos, int type, int data, CallbackInfoReturnable<Boolean> cir) {
        if (!world.isClientSide() && LIRSettings.pistonHarvestableAmethysts) {
            PistonHarvestContext.enter();
        }
    }

    @Inject(method = "triggerEvent", at = @At("RETURN"))
    private void carpetlir$exitHarvestContext(BlockState state, Level world, BlockPos pos, int type, int data, CallbackInfoReturnable<Boolean> cir) {
        if (!world.isClientSide() && LIRSettings.pistonHarvestableAmethysts) {
            PistonHarvestContext.exit();
        }
    }
}

