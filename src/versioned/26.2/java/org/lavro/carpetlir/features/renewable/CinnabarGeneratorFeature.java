package org.lavro.carpetlir.features.renewable;

import net.minecraft.core.BlockPos;
import net.minecraft.core.Direction;
import net.minecraft.tags.FluidTags;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.state.BlockState;
import org.lavro.carpetlir.LIRSettings;

import java.util.List;

public final class CinnabarGeneratorFeature {
    private static final List<Direction> HORIZONTAL_DIRECTIONS = List.of(
            Direction.NORTH,
            Direction.SOUTH,
            Direction.WEST,
            Direction.EAST
    );

    private CinnabarGeneratorFeature() {
    }

    public static boolean tryGenerateCinnabar(Level world, BlockPos lavaPos) {
        if (!LIRSettings.renewableCinnabar
                || !world.getBlockState(lavaPos.below()).is(Blocks.POTENT_SULFUR)) {
            return false;
        }

        boolean touchesWater = false;
        boolean touchesNetherrack = false;
        for (Direction direction : HORIZONTAL_DIRECTIONS) {
            BlockState neighbor = world.getBlockState(lavaPos.relative(direction));
            touchesWater |= neighbor.getFluidState().is(FluidTags.WATER);
            touchesNetherrack |= neighbor.is(Blocks.NETHERRACK);
        }

        if (!touchesWater || !touchesNetherrack) {
            return false;
        }

        world.setBlockAndUpdate(lavaPos, Blocks.CINNABAR.defaultBlockState());
        world.levelEvent(1501, lavaPos, 0);
        return true;
    }
}
