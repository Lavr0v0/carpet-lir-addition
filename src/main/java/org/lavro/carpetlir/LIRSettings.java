package org.lavro.carpetlir;

import carpet.api.settings.Rule;

public class LIRSettings {
    private LIRSettings() {
    }

    @Rule(
            desc = "Debug sample rule. When enabled, joining players receive a short confirmation message.",
            category = {"LIR", "FEATURE"}
    )
    public static boolean renewableDebugSample = false;
}
