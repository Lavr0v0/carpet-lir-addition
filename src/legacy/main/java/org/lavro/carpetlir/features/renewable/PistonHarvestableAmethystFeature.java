package org.lavro.carpetlir.features.renewable;

import net.minecraft.block.AbstractBlock;
import net.minecraft.block.Block;
import net.minecraft.block.BlockState;
import net.minecraft.block.Blocks;
import net.minecraft.item.ItemStack;
import net.minecraft.item.Items;
import net.minecraft.util.math.BlockPos;
import net.minecraft.world.World;
import net.minecraft.world.WorldAccess;
import org.lavro.carpetlir.LIRSettings;
import org.lavro.carpetlir.helpers.PistonHarvestContext;

public final class PistonHarvestableAmethystFeature {
    private PistonHarvestableAmethystFeature() {
    }

    public static boolean shouldBreakWhenPushed(AbstractBlock.AbstractBlockState state) {
        return shouldHarvestBuddingAmethyst(state.isOf(Blocks.BUDDING_AMETHYST));
    }

    public static boolean shouldDropSelf(BlockState state) {
        return shouldHarvestBuddingAmethyst(state.isOf(Blocks.BUDDING_AMETHYST))
                && PistonHarvestContext.isActive();
    }

    static boolean shouldHarvestBuddingAmethyst(boolean buddingAmethyst) {
        return LIRSettings.pistonHarvestableAmethysts && buddingAmethyst;
    }

    public static void dropSelf(WorldAccess world, BlockPos pos) {
        if (world instanceof World actualWorld && !actualWorld.isClient()) {
            Block.dropStack(actualWorld, pos, new ItemStack(Items.BUDDING_AMETHYST));
        }
    }
}
