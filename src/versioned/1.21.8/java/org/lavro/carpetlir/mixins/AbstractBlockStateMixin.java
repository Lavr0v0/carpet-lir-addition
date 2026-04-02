package org.lavro.carpetlir.mixins;

import net.minecraft.block.AbstractBlock;
import net.minecraft.item.ItemStack;
import net.minecraft.loot.context.LootWorldContext;
import net.minecraft.block.piston.PistonBehavior;
import org.lavro.carpetlir.features.renewable.ReinforcedDeepslateFeature;
import org.lavro.carpetlir.features.renewable.PistonHarvestableAmethystFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import java.util.List;

@Mixin(AbstractBlock.AbstractBlockState.class)
public abstract class AbstractBlockStateMixin {
    /**
     * Keeps the reinforced deepslate hardness override scoped to a single block and rule,
     * while delegating the actual value to obsidian's existing state hardness.
     */
    @Inject(method = "getHardness", at = @At("HEAD"), cancellable = true)
    private void carpetlir$useObsidianHardness(net.minecraft.world.BlockView world, net.minecraft.util.math.BlockPos pos, CallbackInfoReturnable<Float> cir) {
        AbstractBlock.AbstractBlockState state = (AbstractBlock.AbstractBlockState) (Object) this;
        if (ReinforcedDeepslateFeature.shouldUseObsidianHardness(state)) {
            cir.setReturnValue(ReinforcedDeepslateFeature.getObsidianHardness(world, pos));
        }
    }

    /**
     * Uses obsidian's actual mining delta calculation so reinforced deepslate matches the
     * intended break speed in practice, not just in a hardness getter.
     */
    @Inject(method = "calcBlockBreakingDelta", at = @At("HEAD"), cancellable = true)
    private void carpetlir$useObsidianMiningDelta(net.minecraft.entity.player.PlayerEntity player, net.minecraft.world.BlockView world, net.minecraft.util.math.BlockPos pos, CallbackInfoReturnable<Float> cir) {
        AbstractBlock.AbstractBlockState state = (AbstractBlock.AbstractBlockState) (Object) this;
        if (ReinforcedDeepslateFeature.shouldUseObsidianHardness(state)) {
            cir.setReturnValue(ReinforcedDeepslateFeature.getObsidianMiningDelta(player, world, pos));
        }
    }

    /**
     * Restricts piston harvesting to budding amethyst by overriding only its piston behavior,
     * leaving normal mining, loot, and all other blocks unchanged.
     */
    @Inject(method = "getPistonBehavior", at = @At("HEAD"), cancellable = true)
    private void carpetlir$markBuddingAmethystDestroyable(CallbackInfoReturnable<PistonBehavior> cir) {
        AbstractBlock.AbstractBlockState state = (AbstractBlock.AbstractBlockState) (Object) this;
        if (PistonHarvestableAmethystFeature.shouldBreakWhenPushed(state)) {
            cir.setReturnValue(PistonBehavior.DESTROY);
        }
    }

    /**
     * Adds a silk-touch-only loot path for reinforced deepslate without changing unrelated block
     * loot tables or normal non-silk mining behavior.
     */
    @Inject(method = "getDroppedStacks", at = @At("HEAD"), cancellable = true)
    private void carpetlir$dropReinforcedDeepslateWithSilkTouch(LootWorldContext.Builder builder, CallbackInfoReturnable<List<ItemStack>> cir) {
        AbstractBlock.AbstractBlockState state = (AbstractBlock.AbstractBlockState) (Object) this;
        if (ReinforcedDeepslateFeature.shouldDropWithSilkTouch(state, builder)) {
            cir.setReturnValue(ReinforcedDeepslateFeature.getSilkTouchDrops());
        }
    }
}
