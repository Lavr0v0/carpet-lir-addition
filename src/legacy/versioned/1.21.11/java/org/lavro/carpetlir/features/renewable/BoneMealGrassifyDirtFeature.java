package org.lavro.carpetlir.features.renewable;

import net.fabricmc.fabric.api.event.player.UseBlockCallback;
import net.minecraft.block.BlockState;
import net.minecraft.block.Blocks;
import net.minecraft.block.SnowBlock;
import net.minecraft.entity.player.PlayerEntity;
import net.minecraft.item.ItemStack;
import net.minecraft.item.Items;
import net.minecraft.util.ActionResult;
import net.minecraft.util.Hand;
import net.minecraft.util.hit.BlockHitResult;
import net.minecraft.util.math.BlockPos;
import net.minecraft.util.math.Direction;
import net.minecraft.world.World;
import net.minecraft.world.chunk.light.ChunkLightProvider;
import net.minecraft.world.event.GameEvent;
import org.lavro.carpetlir.LIRSettings;

public final class BoneMealGrassifyDirtFeature {
    private BoneMealGrassifyDirtFeature() {
    }

    public static void register() {
        UseBlockCallback.EVENT.register(BoneMealGrassifyDirtFeature::onUseBlock);
    }

    private static ActionResult onUseBlock(PlayerEntity player, World world, Hand hand, BlockHitResult hitResult) {
        if (!canHandleInteraction(LIRSettings.boneMealGrassifyDirt, player.isSpectator())) {
            return ActionResult.PASS;
        }

        ItemStack stack = player.getStackInHand(hand);
        if (!stack.isOf(Items.BONE_MEAL)) {
            return ActionResult.PASS;
        }

        BlockPos pos = hitResult.getBlockPos();
        if (!world.getBlockState(pos).isOf(Blocks.DIRT)) {
            return ActionResult.PASS;
        }

        if (!canGrassSurvive(world, pos)) {
            return ActionResult.PASS;
        }

        if (world.isClient()) {
            return ActionResult.SUCCESS;
        }

        world.setBlockState(pos, Blocks.GRASS_BLOCK.getDefaultState());
        if (!player.getAbilities().creativeMode) {
            stack.decrement(1);
        }
        stack.emitUseGameEvent(player, GameEvent.ITEM_INTERACT_FINISH);
        world.syncWorldEvent(1505, pos, 15);
        return ActionResult.SUCCESS_SERVER;
    }

    static boolean canHandleInteraction(boolean ruleEnabled, boolean spectator) {
        return ruleEnabled && !spectator;
    }

    private static boolean canGrassSurvive(World world, BlockPos pos) {
        BlockState grass = Blocks.GRASS_BLOCK.getDefaultState();
        BlockState above = world.getBlockState(pos.up());
        if (above.isOf(Blocks.SNOW) && above.get(SnowBlock.LAYERS) == 1) {
            return true;
        }
        if (above.getFluidState().getLevel() == 8) {
            return false;
        }

        int opacity = ChunkLightProvider.getRealisticOpacity(
                grass,
                above,
                Direction.UP,
                above.getOpacity()
        );
        return opacity < 15;
    }
}
