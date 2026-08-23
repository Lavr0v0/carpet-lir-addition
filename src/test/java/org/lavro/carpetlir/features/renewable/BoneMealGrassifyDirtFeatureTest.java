package org.lavro.carpetlir.features.renewable;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class BoneMealGrassifyDirtFeatureTest {
    @Test
    void interactionRequiresEnabledRuleAndNonSpectatorPlayer() {
        assertTrue(BoneMealGrassifyDirtFeature.canHandleInteraction(true, false));
        assertFalse(BoneMealGrassifyDirtFeature.canHandleInteraction(false, false));
        assertFalse(BoneMealGrassifyDirtFeature.canHandleInteraction(true, true));
    }
}
