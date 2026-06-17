package org.lavro.carpetlir.mixins;

import net.minecraft.world.level.block.state.BlockBehaviour;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.level.storage.loot.LootParams;
import net.minecraft.world.level.material.PushReaction;
import org.lavro.carpetlir.features.renewable.ReinforcedDeepslateFeature;
import org.lavro.carpetlir.features.renewable.PistonHarvestableAmethystFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import java.util.List;

@Mixin(BlockBehaviour.BlockStateBase.class)
public abstract class AbstractBlockStateMixin {
    /**
     * Keeps the reinforced deepslate hardness override scoped to a single block and rule,
     * while delegating the actual value to obsidian's existing state hardness.
     */
    @Inject(method = "getDestroySpeed", at = @At("HEAD"), cancellable = true)
    private void carpetlir$useObsidianHardness(net.minecraft.world.level.BlockGetter world, net.minecraft.core.BlockPos pos, CallbackInfoReturnable<Float> cir) {
        BlockBehaviour.BlockStateBase state = (BlockBehaviour.BlockStateBase) (Object) this;
        if (ReinforcedDeepslateFeature.shouldUseObsidianHardness(state)) {
            cir.setReturnValue(ReinforcedDeepslateFeature.getObsidianHardness(world, pos));
        }
    }

    /**
     * Uses obsidian's actual mining delta calculation so reinforced deepslate matches the
     * intended break speed in practice, not just in a hardness getter.
     */
    @Inject(method = "getDestroyProgress", at = @At("HEAD"), cancellable = true)
    private void carpetlir$useObsidianMiningDelta(net.minecraft.world.entity.player.Player player, net.minecraft.world.level.BlockGetter world, net.minecraft.core.BlockPos pos, CallbackInfoReturnable<Float> cir) {
        BlockBehaviour.BlockStateBase state = (BlockBehaviour.BlockStateBase) (Object) this;
        if (ReinforcedDeepslateFeature.shouldUseObsidianHardness(state)) {
            cir.setReturnValue(ReinforcedDeepslateFeature.getObsidianMiningDelta(player, world, pos));
        }
    }

    /**
     * Restricts piston harvesting to budding amethyst by overriding only its piston behavior,
     * leaving normal mining, loot, and all other blocks unchanged.
     */
    @Inject(method = "getPistonPushReaction", at = @At("HEAD"), cancellable = true)
    private void carpetlir$markBuddingAmethystDestroyable(CallbackInfoReturnable<PushReaction> cir) {
        BlockBehaviour.BlockStateBase state = (BlockBehaviour.BlockStateBase) (Object) this;
        if (PistonHarvestableAmethystFeature.shouldBreakWhenPushed(state)) {
            cir.setReturnValue(PushReaction.DESTROY);
        }
    }

    /**
     * Adds a silk-touch-only loot path for reinforced deepslate without changing unrelated block
     * loot tables or normal non-silk mining behavior.
     */
    @Inject(method = "getDrops", at = @At("HEAD"), cancellable = true)
    private void carpetlir$dropReinforcedDeepslateWithSilkTouch(LootParams.Builder builder, CallbackInfoReturnable<List<ItemStack>> cir) {
        BlockBehaviour.BlockStateBase state = (BlockBehaviour.BlockStateBase) (Object) this;
        if (ReinforcedDeepslateFeature.shouldDropWithSilkTouch(state, builder)) {
            cir.setReturnValue(ReinforcedDeepslateFeature.getSilkTouchDrops());
        }
    }
}

