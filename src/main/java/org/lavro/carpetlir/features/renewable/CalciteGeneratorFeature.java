package org.lavro.carpetlir.features.renewable;

import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.Blocks;
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

    public static boolean tryGenerateCalcite(Level world, BlockPos pos) {
        if (!LIRSettings.renewableCalcite || !world.getBlockState(pos.below()).is(Blocks.BONE_BLOCK)) {
            return false;
        }

        for (Direction direction : FLOW_DIRECTIONS) {
            BlockPos checkPos = pos.relative(direction.getOpposite());
            BlockState neighborState = world.getBlockState(checkPos);
            if (neighborState.is(Blocks.AMETHYST_BLOCK)) {
                world.setBlockAndUpdate(pos, Blocks.CALCITE.defaultBlockState());
                world.levelEvent(1501, pos, 0);
                return true;
            }
        }

        return false;
    }
}

