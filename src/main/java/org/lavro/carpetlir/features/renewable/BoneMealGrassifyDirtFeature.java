package org.lavro.carpetlir.features.renewable;

import net.fabricmc.fabric.api.event.player.UseBlockCallback;
import net.minecraft.block.Blocks;
import net.minecraft.entity.player.PlayerEntity;
import net.minecraft.item.ItemStack;
import net.minecraft.item.Items;
import net.minecraft.particle.ParticleTypes;
import net.minecraft.server.world.ServerWorld;
import net.minecraft.sound.SoundCategory;
import net.minecraft.sound.SoundEvents;
import net.minecraft.util.ActionResult;
import net.minecraft.util.Hand;
import net.minecraft.util.hit.BlockHitResult;
import net.minecraft.util.math.BlockPos;
import net.minecraft.world.World;
import org.lavro.carpetlir.LIRSettings;

public final class BoneMealGrassifyDirtFeature {
    private BoneMealGrassifyDirtFeature() {
    }

    public static void register() {
        UseBlockCallback.EVENT.register(BoneMealGrassifyDirtFeature::onUseBlock);
    }

    private static ActionResult onUseBlock(PlayerEntity player, World world, Hand hand, BlockHitResult hitResult) {
        if (!LIRSettings.boneMealGrassifyDirt) {
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

        if (!Blocks.GRASS_BLOCK.getDefaultState().canPlaceAt(world, pos)) {
            return ActionResult.PASS;
        }

        if (world.isClient()) {
            return ActionResult.SUCCESS;
        }

        world.setBlockState(pos, Blocks.GRASS_BLOCK.getDefaultState());
        if (!player.getAbilities().creativeMode) {
            stack.decrement(1);
        }
        world.playSound(null, pos, SoundEvents.ITEM_BONE_MEAL_USE, SoundCategory.BLOCKS, 1.0F, 1.0F);
        ((ServerWorld) world).spawnParticles(
                ParticleTypes.HAPPY_VILLAGER,
                pos.getX() + 0.5,
                pos.getY() + 0.8,
                pos.getZ() + 0.5,
                8,
                0.35,
                0.25,
                0.35,
                0.0
        );
        return ActionResult.SUCCESS_SERVER;
    }
}
