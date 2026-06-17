package org.lavro.carpetlir.features.renewable;

import net.minecraft.world.level.block.state.BlockBehaviour;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;
import net.minecraft.core.BlockPos;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.LevelAccessor;
import org.lavro.carpetlir.LIRSettings;
import org.lavro.carpetlir.helpers.PistonHarvestContext;

public final class PistonHarvestableAmethystFeature {
    private PistonHarvestableAmethystFeature() {
    }

    public static boolean shouldBreakWhenPushed(BlockBehaviour.BlockStateBase state) {
        return LIRSettings.pistonHarvestableAmethysts && state.is(Blocks.BUDDING_AMETHYST);
    }

    public static boolean shouldDropSelf(BlockState state) {
        return LIRSettings.pistonHarvestableAmethysts
                && PistonHarvestContext.isActive()
                && state.is(Blocks.BUDDING_AMETHYST);
    }

    public static void dropSelf(LevelAccessor world, BlockPos pos) {
        if (world instanceof Level actualWorld && !actualWorld.isClientSide()) {
            Block.popResource(actualWorld, pos, new ItemStack(Items.BUDDING_AMETHYST));
        }
    }
}

