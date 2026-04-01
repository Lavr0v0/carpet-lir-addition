package org.lavro.carpetlir.mixins;

import net.minecraft.block.BlockState;
import net.minecraft.block.PistonBlock;
import net.minecraft.util.math.BlockPos;
import net.minecraft.world.World;
import org.lavro.carpetlir.LIRSettings;
import org.lavro.carpetlir.helpers.PistonHarvestContext;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(PistonBlock.class)
public abstract class PistonBlockMixin {
    /**
     * Tracks only piston block-event execution so the custom budding-amethyst drop is limited
     * to mechanical breaks and never leaks into ordinary mining or explosion loot paths.
     */
    @Inject(method = "onSyncedBlockEvent", at = @At("HEAD"))
    private void carpetlir$enterHarvestContext(BlockState state, World world, BlockPos pos, int type, int data, CallbackInfoReturnable<Boolean> cir) {
        if (!world.isClient() && LIRSettings.pistonHarvestableAmethysts) {
            PistonHarvestContext.enter();
        }
    }

    @Inject(method = "onSyncedBlockEvent", at = @At("RETURN"))
    private void carpetlir$exitHarvestContext(BlockState state, World world, BlockPos pos, int type, int data, CallbackInfoReturnable<Boolean> cir) {
        if (!world.isClient() && LIRSettings.pistonHarvestableAmethysts) {
            PistonHarvestContext.exit();
        }
    }
}
