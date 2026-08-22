package org.lavro.carpetlir.helpers;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PistonHarvestContextTest {
    @Test
    void scopesAndReturnsOperationResult() {
        assertFalse(PistonHarvestContext.isActive());

        int result = PistonHarvestContext.run(() -> {
            assertTrue(PistonHarvestContext.isActive());
            return 42;
        });

        assertEquals(42, result);
        assertFalse(PistonHarvestContext.isActive());
    }

    @Test
    void supportsNestedPistonOperations() {
        PistonHarvestContext.run(() -> {
            assertTrue(PistonHarvestContext.isActive());
            PistonHarvestContext.run(() -> {
                assertTrue(PistonHarvestContext.isActive());
                return null;
            });
            assertTrue(PistonHarvestContext.isActive());
            return null;
        });

        assertFalse(PistonHarvestContext.isActive());
    }

    @Test
    void clearsContextWhenOperationThrows() {
        assertThrows(IllegalStateException.class, () -> PistonHarvestContext.run(() -> {
            throw new IllegalStateException("test failure");
        }));

        assertFalse(PistonHarvestContext.isActive());
    }
}
