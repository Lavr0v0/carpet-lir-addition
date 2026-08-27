package org.lavro.carpetlir.features.renewable;

/** The old target's thin death Mixin invokes the shared Warden helper directly. */
public final class WardenDeathCompatibility {
    private WardenDeathCompatibility() {
    }

    public static void register() {
        // Registration is supplied by LivingEntityDeathMixin on Fabric API 0.58.x.
    }
}
