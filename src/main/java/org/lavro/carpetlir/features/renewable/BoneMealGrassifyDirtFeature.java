package org.lavro.carpetlir.features.renewable;

import net.fabricmc.fabric.api.event.player.UseBlockCallback;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;
import net.minecraft.world.InteractionResult;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.level.gameevent.GameEvent;
import net.minecraft.world.phys.BlockHitResult;
import net.minecraft.core.BlockPos;
import net.minecraft.world.level.Level;
import org.lavro.carpetlir.LIRSettings;

public final class BoneMealGrassifyDirtFeature {
    private BoneMealGrassifyDirtFeature() {
    }

    public static void register() {
        UseBlockCallback.EVENT.register(BoneMealGrassifyDirtFeature::onUseBlock);
    }

    private static InteractionResult onUseBlock(Player player, Level world, InteractionHand hand, BlockHitResult hitResult) {
        if (!LIRSettings.boneMealGrassifyDirt) {
            return InteractionResult.PASS;
        }

        ItemStack stack = player.getItemInHand(hand);
        if (stack.getItem() != Items.BONE_MEAL) {
            return InteractionResult.PASS;
        }

        BlockPos pos = hitResult.getBlockPos();
        if (!world.getBlockState(pos).is(Blocks.DIRT)) {
            return InteractionResult.PASS;
        }

        if (!Blocks.GRASS_BLOCK.defaultBlockState().canSurvive(world, pos)) {
            return InteractionResult.PASS;
        }

        if (world.isClientSide()) {
            return InteractionResult.SUCCESS;
        }

        world.setBlockAndUpdate(pos, Blocks.GRASS_BLOCK.defaultBlockState());
        if (!player.isCreative()) {
            stack.shrink(1);
        }
        stack.causeUseVibration(player, GameEvent.ITEM_INTERACT_FINISH);
        world.levelEvent(1505, pos, 15);
        return InteractionResult.SUCCESS_SERVER;
    }
}

