package org.lavro.carpetlir;

import org.lavro.carpetlir.features.renewable.BoneMealGrassifyDirtFeature;

/** Registers the only event-backed feature available in the 1.15 capability tier. */
public final class LegacyFeatureBootstrap {
    private LegacyFeatureBootstrap() {
    }

    public static void register() {
        BoneMealGrassifyDirtFeature.register();
    }
}
