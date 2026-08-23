package org.lavro.carpetlir.mixins;

import net.minecraft.block.AbstractBlock;
import net.minecraft.block.piston.PistonBehavior;
import net.minecraft.item.ItemStack;
import net.minecraft.loot.context.LootContextParameterSet;
import org.lavro.carpetlir.features.renewable.PistonHarvestableAmethystFeature;
import org.lavro.carpetlir.features.renewable.ReinforcedDeepslateFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import java.util.List;

@Mixin(AbstractBlock.AbstractBlockState.class)
public abstract class AbstractBlockStateMixin {
    @Inject(method = "getHardness", at = @At("HEAD"), cancellable = true)
    private void carpetlir$useObsidianHardness(net.minecraft.world.BlockView world, net.minecraft.util.math.BlockPos pos, CallbackInfoReturnable<Float> cir) {
        AbstractBlock.AbstractBlockState state = (AbstractBlock.AbstractBlockState) (Object) this;
        if (ReinforcedDeepslateFeature.shouldUseObsidianHardness(state)) {
            cir.setReturnValue(ReinforcedDeepslateFeature.getObsidianHardness(world, pos));
        }
    }

    @Inject(method = "calcBlockBreakingDelta", at = @At("HEAD"), cancellable = true)
    private void carpetlir$useObsidianMiningDelta(net.minecraft.entity.player.PlayerEntity player, net.minecraft.world.BlockView world, net.minecraft.util.math.BlockPos pos, CallbackInfoReturnable<Float> cir) {
        AbstractBlock.AbstractBlockState state = (AbstractBlock.AbstractBlockState) (Object) this;
        if (ReinforcedDeepslateFeature.shouldUseObsidianHardness(state)) {
            cir.setReturnValue(ReinforcedDeepslateFeature.getObsidianMiningDelta(player, world, pos));
        }
    }

    @Inject(method = "getPistonBehavior", at = @At("HEAD"), cancellable = true)
    private void carpetlir$markBuddingAmethystDestroyable(CallbackInfoReturnable<PistonBehavior> cir) {
        AbstractBlock.AbstractBlockState state = (AbstractBlock.AbstractBlockState) (Object) this;
        if (PistonHarvestableAmethystFeature.shouldBreakWhenPushed(state)) {
            cir.setReturnValue(PistonBehavior.DESTROY);
        }
    }

    @Inject(method = "getDroppedStacks", at = @At("HEAD"), cancellable = true)
    private void carpetlir$dropReinforcedDeepslateWithSilkTouch(LootContextParameterSet.Builder builder, CallbackInfoReturnable<List<ItemStack>> cir) {
        AbstractBlock.AbstractBlockState state = (AbstractBlock.AbstractBlockState) (Object) this;
        if (ReinforcedDeepslateFeature.shouldDropWithSilkTouch(state, builder)) {
            cir.setReturnValue(ReinforcedDeepslateFeature.getSilkTouchDrops());
        }
    }
}
