package org.lavro.carpetlir.helpers;

import java.util.function.Supplier;

public final class PistonHarvestContext {
    private static final ThreadLocal<Integer> DEPTH = ThreadLocal.withInitial(() -> 0);

    private PistonHarvestContext() {
    }

    private static void enter() {
        DEPTH.set(DEPTH.get() + 1);
    }

    private static void exit() {
        int nextDepth = DEPTH.get() - 1;
        if (nextDepth <= 0) {
            DEPTH.remove();
            return;
        }
        DEPTH.set(nextDepth);
    }

    public static <T> T run(Supplier<T> operation) {
        enter();
        try {
            return operation.get();
        } finally {
            exit();
        }
    }

    public static boolean isActive() {
        return DEPTH.get() > 0;
    }
}

