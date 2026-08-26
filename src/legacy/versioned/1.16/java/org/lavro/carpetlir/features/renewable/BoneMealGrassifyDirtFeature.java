package org.lavro.carpetlir.features.renewable;

import net.fabricmc.fabric.api.event.player.UseBlockCallback;
import net.minecraft.block.BlockState;
import net.minecraft.block.Blocks;
import net.minecraft.block.SnowBlock;
import net.minecraft.block.SnowyBlock;
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
        if (stack.getItem() != Items.BONE_MEAL) {
            return ActionResult.PASS;
        }

        BlockPos pos = hitResult.getBlockPos();
        BlockState above = world.getBlockState(pos.up());
        if (world.getBlockState(pos).getBlock() != Blocks.DIRT || !canGrassSurvive(world, pos, above)) {
            return ActionResult.PASS;
        }

        if (!world.isClient) {
            world.setBlockState(
                    pos,
                    Blocks.GRASS_BLOCK.getDefaultState().with(SnowyBlock.SNOWY, above.getBlock() == Blocks.SNOW)
            );
            if (!player.isCreative()) {
                stack.decrement(1);
            }
            world.syncWorldEvent(2005, pos, 0);
        }
        return ActionResult.success(world.isClient);
    }

    static boolean canHandleInteraction(boolean ruleEnabled, boolean spectator) {
        return ruleEnabled && !spectator;
    }

    /** Mirrors the 1.16 grass survival predicate, including snow and full water checks. */
    private static boolean canGrassSurvive(World world, BlockPos pos, BlockState above) {
        if (above.getBlock() == Blocks.SNOW && above.get(SnowBlock.LAYERS) == 1) {
            return true;
        }
        if (above.getFluidState().getLevel() == 8) {
            return false;
        }

        int opacity = ChunkLightProvider.getRealisticOpacity(
                world,
                Blocks.GRASS_BLOCK.getDefaultState(),
                pos,
                above,
                pos.up(),
                Direction.UP,
                above.getOpacity(world, pos.up())
        );
        return opacity < world.getMaxLightLevel();
    }
}
