package org.lavro.carpetlir.helpers;

import net.minecraft.fluid.FluidState;
import net.minecraft.registry.tag.FluidTags;

public final class FluidTagCompatibility {
    private FluidTagCompatibility() {
    }

    public static boolean isLava(FluidState state) {
        return state.isIn(FluidTags.LAVA);
    }
}
