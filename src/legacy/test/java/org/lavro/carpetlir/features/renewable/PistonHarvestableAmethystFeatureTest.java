package org.lavro.carpetlir.features.renewable;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.lavro.carpetlir.LIRSettings;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PistonHarvestableAmethystFeatureTest {
    @AfterEach
    void resetRule() {
        LIRSettings.pistonHarvestableAmethysts = false;
    }

    @Test
    void buddingAmethystIsNotDestroyableByDefault() {
        assertFalse(PistonHarvestableAmethystFeature.shouldHarvestBuddingAmethyst(true));
    }

    @Test
    void ruleMakesOnlyBuddingAmethystDestroyable() {
        LIRSettings.pistonHarvestableAmethysts = true;

        assertTrue(PistonHarvestableAmethystFeature.shouldHarvestBuddingAmethyst(true));
        assertFalse(PistonHarvestableAmethystFeature.shouldHarvestBuddingAmethyst(false));
    }

    @Test
    void disablingRuleTakesEffectImmediately() {
        LIRSettings.pistonHarvestableAmethysts = true;
        assertTrue(PistonHarvestableAmethystFeature.shouldHarvestBuddingAmethyst(true));

        LIRSettings.pistonHarvestableAmethysts = false;
        assertFalse(PistonHarvestableAmethystFeature.shouldHarvestBuddingAmethyst(true));
    }
}
