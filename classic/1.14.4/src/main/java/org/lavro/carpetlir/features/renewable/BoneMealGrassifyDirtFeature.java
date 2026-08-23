package org.lavro.carpetlir.features.renewable;

import net.fabricmc.fabric.api.event.player.UseBlockCallback;
import net.minecraft.block.BlockState;
import net.minecraft.block.Blocks;
import net.minecraft.block.SnowBlock;
import net.minecraft.entity.player.PlayerEntity;
import net.minecraft.item.ItemStack;
import net.minecraft.item.Items;
import net.minecraft.tag.FluidTags;
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

    private static ActionResult onUseBlock(
            PlayerEntity player,
            World world,
            Hand hand,
            BlockHitResult hitResult
    ) {
        if (!LIRSettings.boneMealGrassifyDirt || player.isSpectator()) {
            return ActionResult.PASS;
        }

        ItemStack stack = player.getStackInHand(hand);
        if (stack.getItem() != Items.BONE_MEAL) {
            return ActionResult.PASS;
        }

        BlockPos pos = hitResult.getBlockPos();
        if (world.getBlockState(pos).getBlock() != Blocks.DIRT || !canGrassSpreadAt(world, pos)) {
            return ActionResult.PASS;
        }

        if (!world.isClient) {
            world.setBlockState(pos, Blocks.GRASS_BLOCK.getDefaultState(), 3);
            if (!player.isCreative()) {
                stack.decrement(1);
            }
            world.playLevelEvent(2005, pos, 0);
        }
        return ActionResult.SUCCESS;
    }

    /**
     * Mirrors the private 1.14 SpreadableBlock survival/spread predicate. Calling
     * BlockState.canPlaceAt would permit grass beneath opaque blocks or water and it would
     * immediately decay back to dirt.
     */
    private static boolean canGrassSpreadAt(World world, BlockPos pos) {
        BlockPos abovePos = pos.up();
        BlockState above = world.getBlockState(abovePos);
        if (above.getBlock() == Blocks.SNOW && above.get(SnowBlock.LAYERS) == 1) {
            return true;
        }
        if (world.getFluidState(abovePos).matches(FluidTags.WATER)) {
            return false;
        }

        int opacity = ChunkLightProvider.method_20049(
                world,
                Blocks.GRASS_BLOCK.getDefaultState(),
                pos,
                above,
                abovePos,
                Direction.UP,
                above.getOpacity(world, abovePos)
        );
        return opacity < world.getMaxLightLevel();
    }
}
