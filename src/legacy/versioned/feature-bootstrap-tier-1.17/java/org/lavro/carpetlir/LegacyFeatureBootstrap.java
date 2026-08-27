package org.lavro.carpetlir;

import org.lavro.carpetlir.features.renewable.BoneMealGrassifyDirtFeature;

/** Registers the event-backed features that exist before reinforced deepslate and Wardens. */
public final class LegacyFeatureBootstrap {
    private LegacyFeatureBootstrap() {
    }

    public static void register() {
        BoneMealGrassifyDirtFeature.register();
    }
}
