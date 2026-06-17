package org.lavro.carpetlir.features.renewable;

import net.fabricmc.fabric.api.event.player.UseBlockCallback;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;
import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.sounds.SoundSource;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.world.InteractionResult;
import net.minecraft.world.InteractionHand;
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
        world.playSound(null, pos, SoundEvents.BONE_MEAL_USE, SoundSource.BLOCKS, 1.0F, 1.0F);
        ((ServerLevel) world).sendParticles(
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
        return InteractionResult.SUCCESS_SERVER;
    }
}

