package org.lavro.carpetlir.features.renewable;

import net.minecraft.block.Block;
import net.minecraft.block.BlockState;
import net.minecraft.block.Blocks;
import net.minecraft.fluid.FluidState;
import net.minecraft.registry.tag.FluidTags;
import net.minecraft.util.math.BlockPos;
import net.minecraft.util.math.Direction;
import net.minecraft.world.World;
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

    public static boolean receiveNeighborFluids(World world, BlockPos pos) {
        BlockState blockBelow = world.getBlockState(pos.down());
        boolean canGenerateBasalt = blockBelow.isOf(Blocks.SOUL_SOIL);
        boolean canGenerateCalcite = LIRSettings.renewableCalcite && blockBelow.isOf(Blocks.BONE_BLOCK);

        for (Direction direction : FLOW_DIRECTIONS) {
            BlockPos checkPos = pos.offset(direction.getOpposite());
            FluidState neighborFluid = world.getFluidState(checkPos);
            if (neighborFluid.isIn(FluidTags.WATER)) {
                Block generatedBlock = world.getFluidState(pos).isStill() ? Blocks.OBSIDIAN : Blocks.COBBLESTONE;
                generate(world, pos, generatedBlock);
                return true;
            }

            BlockState neighborState = world.getBlockState(checkPos);
            if (canGenerateBasalt && neighborState.isOf(Blocks.BLUE_ICE)) {
                generate(world, pos, Blocks.BASALT);
                return true;
            }

            if (canGenerateCalcite && neighborState.isOf(Blocks.AMETHYST_BLOCK)) {
                generate(world, pos, Blocks.CALCITE);
                return true;
            }
        }

        return false;
    }

    private static void generate(World world, BlockPos pos, Block generatedBlock) {
        world.setBlockState(pos, generatedBlock.getDefaultState());
        world.syncWorldEvent(1501, pos, 0);
    }
}
