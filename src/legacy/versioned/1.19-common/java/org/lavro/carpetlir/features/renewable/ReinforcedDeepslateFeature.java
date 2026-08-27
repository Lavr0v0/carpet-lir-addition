package org.lavro.carpetlir.features.renewable;

import net.minecraft.block.AbstractBlock;
import net.minecraft.block.Block;
import net.minecraft.block.Blocks;
import net.minecraft.enchantment.EnchantmentHelper;
import net.minecraft.enchantment.Enchantments;
import net.minecraft.entity.LivingEntity;
import net.minecraft.entity.mob.WardenEntity;
import net.minecraft.item.ItemStack;
import net.minecraft.loot.context.LootContext;
import net.minecraft.loot.context.LootContextParameters;
import net.minecraft.server.world.ServerWorld;
import net.minecraft.util.math.BlockPos;
import net.minecraft.world.BlockView;
import net.minecraft.world.GameRules;
import org.lavro.carpetlir.LIRSettings;

import java.util.List;

public final class ReinforcedDeepslateFeature {
    private ReinforcedDeepslateFeature() {
    }

    public static void register() {
        WardenDeathCompatibility.register();
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

    public static boolean shouldDropWithSilkTouch(AbstractBlock.AbstractBlockState state, LootContext.Builder builder) {
        if (!LIRSettings.silkTouchableReinforcedDeepslate || !state.isOf(Blocks.REINFORCED_DEEPSLATE)) {
            return false;
        }

        ItemStack tool = builder.getNullable(LootContextParameters.TOOL);
        return tool != null
                && !tool.isEmpty()
                && EnchantmentHelper.getLevel(Enchantments.SILK_TOUCH, tool) > 0;
    }

    public static List<ItemStack> getSilkTouchDrops() {
        return List.of(new ItemStack(Blocks.REINFORCED_DEEPSLATE));
    }

    /** Called by exactly one target-selected death adapter. */
    public static void handleWardenDeath(LivingEntity entity) {
        if (!LIRSettings.wardensDropReinforcedDeepslate || !(entity instanceof WardenEntity)) {
            return;
        }
        if (!(entity.getEntityWorld() instanceof ServerWorld world)
                || !world.getGameRules().getBoolean(GameRules.DO_MOB_LOOT)) {
            return;
        }

        int count = 1 + entity.getRandom().nextInt(4);
        Block.dropStack(world, entity.getBlockPos(), new ItemStack(Blocks.REINFORCED_DEEPSLATE, count));
    }
}
