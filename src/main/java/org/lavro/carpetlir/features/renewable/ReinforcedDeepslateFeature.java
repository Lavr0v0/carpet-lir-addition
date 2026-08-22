package org.lavro.carpetlir.features.renewable;

import net.fabricmc.fabric.api.entity.event.v1.ServerLivingEntityEvents;
import net.minecraft.world.level.block.state.BlockBehaviour;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.item.enchantment.Enchantment;
import net.minecraft.world.item.enchantment.EnchantmentHelper;
import net.minecraft.world.item.enchantment.Enchantments;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.damagesource.DamageSource;
import net.minecraft.world.entity.monster.warden.Warden;
import net.minecraft.world.item.ItemInstance;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.level.storage.loot.parameters.LootContextParams;
import net.minecraft.world.level.storage.loot.LootParams;
import net.minecraft.core.registries.Registries;
import net.minecraft.core.Holder;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.core.BlockPos;
import net.minecraft.world.level.BlockGetter;
import net.minecraft.world.level.gamerules.GameRules;
import org.lavro.carpetlir.LIRSettings;

import java.util.List;

public final class ReinforcedDeepslateFeature {
    private ReinforcedDeepslateFeature() {
    }

    public static void register() {
        ServerLivingEntityEvents.AFTER_DEATH.register(ReinforcedDeepslateFeature::dropFromWarden);
    }

    public static boolean shouldUseObsidianHardness(BlockBehaviour.BlockStateBase state) {
        return LIRSettings.obsidianHardnessReinforcedDeepslate && state.is(Blocks.REINFORCED_DEEPSLATE);
    }

    public static float getObsidianHardness(BlockGetter world, BlockPos pos) {
        return Blocks.OBSIDIAN.defaultBlockState().getDestroySpeed(world, pos);
    }

    public static float getObsidianMiningDelta(net.minecraft.world.entity.player.Player player, BlockGetter world, BlockPos pos) {
        return Blocks.OBSIDIAN.defaultBlockState().getDestroyProgress(player, world, pos);
    }

    public static boolean shouldDropWithSilkTouch(BlockBehaviour.BlockStateBase state, LootParams.Builder builder) {
        if (!LIRSettings.silkTouchableReinforcedDeepslate || !state.is(Blocks.REINFORCED_DEEPSLATE)) {
            return false;
        }

        ItemInstance tool = builder.getOptionalParameter(LootContextParams.TOOL);
        if (tool == null || tool.count() <= 0) {
            return false;
        }

        Holder<Enchantment> silkTouch = builder.getLevel()
                .registryAccess()
                .lookupOrThrow(Registries.ENCHANTMENT)
                .getOrThrow(Enchantments.SILK_TOUCH);
        return EnchantmentHelper.getItemEnchantmentLevel(silkTouch, tool) > 0;
    }

    public static List<ItemStack> getSilkTouchDrops() {
        return List.of(new ItemStack(Blocks.REINFORCED_DEEPSLATE));
    }

    private static void dropFromWarden(LivingEntity entity, DamageSource damageSource) {
        if (!LIRSettings.wardensDropReinforcedDeepslate || !(entity instanceof Warden)) {
            return;
        }

        ServerLevel world = (ServerLevel) entity.level();
        if (!world.getGameRules().get(GameRules.MOB_DROPS)) {
            return;
        }

        int count = 1 + entity.getRandom().nextInt(4);
        entity.spawnAtLocation(world, new ItemStack(Blocks.REINFORCED_DEEPSLATE, count));
    }
}

