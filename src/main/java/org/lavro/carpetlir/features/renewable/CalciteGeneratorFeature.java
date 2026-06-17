package org.lavro.carpetlir.features.renewable;

import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.material.FluidState;
import net.minecraft.tags.FluidTags;
import net.minecraft.core.BlockPos;
import net.minecraft.core.Direction;
import net.minecraft.world.level.Level;
import org.lavro.carpetlir.LIRSettings;

import java.util.List;

public final class CalciteGeneratorFeature {
    private static final List<Direction> FLOW_DIRECTIONS = List.of(
            Direction.DOWN,
            Direction.SOUTH,
            Direction.NORTH,
            Direction.EAST,
            Direction.WEST
    );

    private CalciteGeneratorFeature() {
    }

    public static boolean receiveNeighborFluids(Level world, BlockPos pos) {
        BlockState blockBelow = world.getBlockState(pos.below());
        boolean canGenerateBasalt = blockBelow.is(Blocks.SOUL_SOIL);
        boolean canGenerateCalcite = LIRSettings.renewableCalcite && blockBelow.is(Blocks.BONE_BLOCK);

        for (Direction direction : FLOW_DIRECTIONS) {
            BlockPos checkPos = pos.relative(direction.getOpposite());
            FluidState neighborFluid = world.getFluidState(checkPos);
            if (neighborFluid.is(FluidTags.WATER)) {
                Block generatedBlock = world.getFluidState(pos).isSource() ? Blocks.OBSIDIAN : Blocks.COBBLESTONE;
                generate(world, pos, generatedBlock);
                return true;
            }

            BlockState neighborState = world.getBlockState(checkPos);
            if (canGenerateBasalt && neighborState.is(Blocks.BLUE_ICE)) {
                generate(world, pos, Blocks.BASALT);
                return true;
            }

            if (canGenerateCalcite && neighborState.is(Blocks.AMETHYST_BLOCK)) {
                generate(world, pos, Blocks.CALCITE);
                return true;
            }
        }

        return false;
    }

    private static void generate(Level world, BlockPos pos, Block generatedBlock) {
        world.setBlockAndUpdate(pos, generatedBlock.defaultBlockState());
        world.levelEvent(1501, pos, 0);
    }
}

