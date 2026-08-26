package org.lavro.carpetlir;

import org.lavro.carpetlir.features.renewable.BoneMealGrassifyDirtFeature;
import org.lavro.carpetlir.features.renewable.ReinforcedDeepslateFeature;

/** Registers only the event-backed features available from Minecraft 1.19 onward. */
public final class LegacyFeatureBootstrap {
    private LegacyFeatureBootstrap() {
    }

    public static void register() {
        BoneMealGrassifyDirtFeature.register();
        ReinforcedDeepslateFeature.register();
    }
}
