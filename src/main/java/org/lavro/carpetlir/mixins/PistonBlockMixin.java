package org.lavro.carpetlir.mixins;

import com.llamalad7.mixinextras.injector.wrapmethod.WrapMethod;
import com.llamalad7.mixinextras.injector.wrapoperation.Operation;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.piston.PistonBaseBlock;
import net.minecraft.core.BlockPos;
import net.minecraft.world.level.Level;
import org.lavro.carpetlir.LIRSettings;
import org.lavro.carpetlir.helpers.PistonHarvestContext;
import org.spongepowered.asm.mixin.Mixin;

@Mixin(PistonBaseBlock.class)
public abstract class PistonBlockMixin {
    /**
     * Wraps PistonBaseBlock.triggerEvent because that method owns the destroy-and-drop sequence.
     * The scoped helper uses finally cleanup, so an exception cannot leak piston context into
     * later block drops on the same server thread.
     */
    @WrapMethod(method = "triggerEvent")
    private boolean carpetlir$withHarvestContext(
            BlockState state,
            Level world,
            BlockPos pos,
            int type,
            int data,
            Operation<Boolean> original
    ) {
        if (world.isClientSide() || !LIRSettings.pistonHarvestableAmethysts) {
            return original.call(state, world, pos, type, data);
        }

        return PistonHarvestContext.run(() -> original.call(state, world, pos, type, data));
    }
}

