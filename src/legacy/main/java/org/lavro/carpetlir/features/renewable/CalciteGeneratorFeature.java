package org.lavro.carpetlir.features.renewable;

import net.minecraft.block.BlockState;
import net.minecraft.block.Blocks;
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

    public static boolean tryGenerateCalcite(World world, BlockPos pos) {
        if (!LIRSettings.renewableCalcite || !world.getBlockState(pos.down()).isOf(Blocks.BONE_BLOCK)) {
            return false;
        }

        for (Direction direction : FLOW_DIRECTIONS) {
            BlockPos checkPos = pos.offset(direction.getOpposite());
            BlockState neighborState = world.getBlockState(checkPos);
            if (neighborState.isOf(Blocks.AMETHYST_BLOCK)) {
                world.setBlockState(pos, Blocks.CALCITE.getDefaultState());
                world.syncWorldEvent(1501, pos, 0);
                return true;
            }
        }

        return false;
    }
}
