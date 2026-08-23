package org.lavro.carpetlir.helpers;

import net.minecraft.core.Direction;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.lighting.LightEngine;

import java.lang.invoke.MethodHandle;
import java.lang.invoke.MethodHandles;
import java.lang.invoke.MethodType;

/**
 * Resolves the one renamed light-occlusion helper across the 26.1 and 26.2 source-compatible
 * lines. The handle is resolved once at class initialization; bone-meal interactions do not
 * perform repeated reflective lookups.
 */
public final class GrassSurvivalCompatibility {
    private static final MethodType LIGHT_BLOCK_METHOD = MethodType.methodType(
            int.class,
            BlockState.class,
            BlockState.class,
            Direction.class,
            int.class
    );
    private static final MethodHandle GET_LIGHT_BLOCK_INTO = resolveLightBlockMethod();

    private GrassSurvivalCompatibility() {
    }

    public static int getLightBlockInto(
            BlockState fromState,
            BlockState toState,
            Direction direction,
            int simpleOpacity
    ) {
        try {
            return (int) GET_LIGHT_BLOCK_INTO.invokeExact(fromState, toState, direction, simpleOpacity);
        } catch (Throwable throwable) {
            throw new IllegalStateException("Unable to evaluate grass light occlusion", throwable);
        }
    }

    private static MethodHandle resolveLightBlockMethod() {
        MethodHandles.Lookup lookup = MethodHandles.publicLookup();
        for (String methodName : new String[]{"getLightDampeningInto", "getLightBlockInto"}) {
            try {
                return lookup.findStatic(LightEngine.class, methodName, LIGHT_BLOCK_METHOD);
            } catch (NoSuchMethodException | IllegalAccessException ignored) {
                // Try the name used by the other supported 26.x line.
            }
        }
        throw new ExceptionInInitializerError("Unsupported 26.x LightEngine API");
    }
}
