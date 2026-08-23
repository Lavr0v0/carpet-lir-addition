package org.lavro.carpetlir;

import carpet.CarpetExtension;
import carpet.CarpetServer;
import carpet.settings.SettingsManager;
import net.fabricmc.api.ModInitializer;
import net.fabricmc.loader.api.FabricLoader;
import org.lavro.carpetlir.features.renewable.BoneMealGrassifyDirtFeature;

public final class CarpetLIRAddition implements CarpetExtension, ModInitializer {
    public static final String MOD_ID = "carpetlir";
    public static final String MOD_NAME = "Carpet LIR Addition";

    private final SettingsManager settingsManager = new SettingsManager(version(), MOD_ID, MOD_NAME);

    @Override
    public void onInitialize() {
        CarpetServer.manageExtension(this);
        BoneMealGrassifyDirtFeature.register();
    }

    @Override
    public void onGameStarted() {
        settingsManager.parseSettingsClass(LIRSettings.class);
    }

    @Override
    public SettingsManager customSettingsManager() {
        return settingsManager;
    }

    @Override
    public String version() {
        return FabricLoader.getInstance()
                .getModContainer(MOD_ID)
                .map(container -> container.getMetadata().getVersion().getFriendlyString())
                .orElse("unknown");
    }
}
