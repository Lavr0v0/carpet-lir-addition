package org.lavro.carpetlir.mixins;

import com.llamalad7.mixinextras.injector.wrapoperation.Operation;
import com.llamalad7.mixinextras.injector.wrapoperation.WrapOperation;
import net.minecraft.core.BlockPos;
import net.minecraft.world.level.LevelAccessor;
import net.minecraft.world.level.block.entity.BlockEntity;
import net.minecraft.world.level.block.piston.PistonBaseBlock;
import net.minecraft.world.level.block.state.BlockState;
import org.lavro.carpetlir.features.renewable.PistonHarvestableAmethystFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;

@Mixin(PistonBaseBlock.class)
public abstract class PistonBlockMixin {
    /**
     * Replaces loot only at the piston destruction call site. Budding amethyst already uses
     * vanilla's DESTROY push reaction in 26.2, so the rule only needs to add its self-drop.
     */
    @WrapOperation(
            method = "moveBlocks",
            at = @At(
                    value = "INVOKE",
                    target = "Lnet/minecraft/world/level/block/piston/PistonBaseBlock;dropResources(Lnet/minecraft/world/level/block/state/BlockState;Lnet/minecraft/world/level/LevelAccessor;Lnet/minecraft/core/BlockPos;Lnet/minecraft/world/level/block/entity/BlockEntity;)V"
            )
    )
    private void carpetlir$dropBuddingAmethystFromPiston(
            BlockState state,
            LevelAccessor world,
            BlockPos pos,
            BlockEntity blockEntity,
            Operation<Void> original
    ) {
        if (PistonHarvestableAmethystFeature.shouldDropSelf(state)) {
            PistonHarvestableAmethystFeature.dropSelf(world, pos);
            return;
        }

        original.call(state, world, pos, blockEntity);
    }
}
