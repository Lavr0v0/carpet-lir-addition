package org.lavro.carpetlir.features.renewable;

import net.fabricmc.fabric.api.entity.event.v1.ServerLivingEntityEvents;

/** Uses Fabric API's server-only death event on versions where it exists. */
public final class WardenDeathCompatibility {
    private WardenDeathCompatibility() {
    }

    public static void register() {
        ServerLivingEntityEvents.AFTER_DEATH.register(
                (entity, damageSource) -> ReinforcedDeepslateFeature.handleWardenDeath(entity)
        );
    }
}
