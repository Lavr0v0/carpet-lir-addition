package org.lavro.carpetlir.helpers;

public final class PistonHarvestContext {
    private static final ThreadLocal<Integer> DEPTH = ThreadLocal.withInitial(() -> 0);

    private PistonHarvestContext() {
    }

    public static void enter() {
        DEPTH.set(DEPTH.get() + 1);
    }

    public static void exit() {
        int nextDepth = DEPTH.get() - 1;
        if (nextDepth <= 0) {
            DEPTH.remove();
            return;
        }
        DEPTH.set(nextDepth);
    }

    public static boolean isActive() {
        return DEPTH.get() > 0;
    }
}
