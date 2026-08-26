package org.lavro.carpetlir.mixins;

import net.minecraft.block.AbstractBlock;
import net.minecraft.item.ItemStack;
import net.minecraft.loot.context.LootWorldContext;
import org.lavro.carpetlir.features.renewable.ReinforcedDeepslateFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import java.util.List;

@Mixin(AbstractBlock.AbstractBlockState.class)
public abstract class AbstractBlockStateMixin {
    /** Overrides only reinforced deepslate's hardness while its rule is enabled. */
    @Inject(method = "getHardness", at = @At("HEAD"), cancellable = true)
    private void carpetlir$useObsidianHardness(net.minecraft.world.BlockView world, net.minecraft.util.math.BlockPos pos, CallbackInfoReturnable<Float> cir) {
        AbstractBlock.AbstractBlockState state = (AbstractBlock.AbstractBlockState) (Object) this;
        if (ReinforcedDeepslateFeature.shouldUseObsidianHardness(state)) {
            cir.setReturnValue(ReinforcedDeepslateFeature.getObsidianHardness(world, pos));
        }
    }

    /** Mirrors obsidian's real mining delta instead of changing a display-only hardness value. */
    @Inject(method = "calcBlockBreakingDelta", at = @At("HEAD"), cancellable = true)
    private void carpetlir$useObsidianMiningDelta(net.minecraft.entity.player.PlayerEntity player, net.minecraft.world.BlockView world, net.minecraft.util.math.BlockPos pos, CallbackInfoReturnable<Float> cir) {
        AbstractBlock.AbstractBlockState state = (AbstractBlock.AbstractBlockState) (Object) this;
        if (ReinforcedDeepslateFeature.shouldUseObsidianHardness(state)) {
            cir.setReturnValue(ReinforcedDeepslateFeature.getObsidianMiningDelta(player, world, pos));
        }
    }

    /** Adds the rule-gated Silk Touch drop without replacing unrelated loot tables. */
    @Inject(method = "getDroppedStacks", at = @At("HEAD"), cancellable = true)
    private void carpetlir$dropReinforcedDeepslateWithSilkTouch(LootWorldContext.Builder builder, CallbackInfoReturnable<List<ItemStack>> cir) {
        AbstractBlock.AbstractBlockState state = (AbstractBlock.AbstractBlockState) (Object) this;
        if (ReinforcedDeepslateFeature.shouldDropWithSilkTouch(state, builder)) {
            cir.setReturnValue(ReinforcedDeepslateFeature.getSilkTouchDrops());
        }
    }
}
