package org.lavro.carpetlir.features.renewable;

import net.fabricmc.fabric.api.entity.event.v1.ServerLivingEntityEvents;
import net.minecraft.block.AbstractBlock;
import net.minecraft.block.Block;
import net.minecraft.block.BlockState;
import net.minecraft.block.Blocks;
import net.minecraft.enchantment.Enchantment;
import net.minecraft.enchantment.EnchantmentHelper;
import net.minecraft.enchantment.Enchantments;
import net.minecraft.entity.LivingEntity;
import net.minecraft.entity.damage.DamageSource;
import net.minecraft.entity.mob.WardenEntity;
import net.minecraft.item.ItemStack;
import net.minecraft.loot.context.LootContextParameters;
import net.minecraft.loot.context.LootWorldContext;
import net.minecraft.registry.RegistryKeys;
import net.minecraft.registry.entry.RegistryEntry;
import net.minecraft.server.world.ServerWorld;
import net.minecraft.util.math.BlockPos;
import net.minecraft.world.BlockView;
import org.lavro.carpetlir.LIRSettings;

import java.util.List;

public final class ReinforcedDeepslateFeature {
    private ReinforcedDeepslateFeature() {
    }

    public static void register() {
        ServerLivingEntityEvents.AFTER_DEATH.register(ReinforcedDeepslateFeature::dropFromWarden);
    }

    public static boolean shouldUseObsidianHardness(AbstractBlock.AbstractBlockState state) {
        return LIRSettings.obsidianHardnessReinforcedDeepslate && state.isOf(Blocks.REINFORCED_DEEPSLATE);
    }

    public static float getObsidianHardness(BlockView world, BlockPos pos) {
        return Blocks.OBSIDIAN.getDefaultState().getHardness(world, pos);
    }

    public static float getObsidianMiningDelta(net.minecraft.entity.player.PlayerEntity player, BlockView world, BlockPos pos) {
        return Blocks.OBSIDIAN.getDefaultState().calcBlockBreakingDelta(player, world, pos);
    }

    public static boolean shouldDropWithSilkTouch(AbstractBlock.AbstractBlockState state, LootWorldContext.Builder builder) {
        if (!LIRSettings.silkTouchableReinforcedDeepslate || !state.isOf(Blocks.REINFORCED_DEEPSLATE)) {
            return false;
        }

        ItemStack tool = builder.getOptional(LootContextParameters.TOOL);
        if (tool == null || tool.isEmpty()) {
            return false;
        }

        RegistryEntry<Enchantment> silkTouch = builder.getWorld()
                .getRegistryManager()
                .getOrThrow(RegistryKeys.ENCHANTMENT)
                .getOrThrow(Enchantments.SILK_TOUCH);
        return EnchantmentHelper.getLevel(silkTouch, tool) > 0;
    }

    public static List<ItemStack> getSilkTouchDrops() {
        return List.of(new ItemStack(Blocks.REINFORCED_DEEPSLATE));
    }

    private static void dropFromWarden(LivingEntity entity, DamageSource damageSource) {
        if (!LIRSettings.wardensDropReinforcedDeepslate || !(entity instanceof WardenEntity)) {
            return;
        }

        ServerWorld world = (ServerWorld) entity.getEntityWorld();
        int count = 1 + entity.getRandom().nextInt(4);
        Block.dropStack(world, entity.getBlockPos(), new ItemStack(Blocks.REINFORCED_DEEPSLATE, count));
    }
}
