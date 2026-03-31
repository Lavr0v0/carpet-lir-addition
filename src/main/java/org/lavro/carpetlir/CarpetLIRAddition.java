package org.lavro.carpetlir;

import carpet.CarpetExtension;
import carpet.CarpetServer;
import carpet.api.settings.SettingsManager;
import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.networking.v1.ServerPlayConnectionEvents;

public class CarpetLIRAddition implements CarpetExtension, ModInitializer {
    public static final String MOD_ID = "carpetlir";
    public static final String MOD_NAME = "Carpet LIR Addition";
    public static final String MOD_VERSION = "${version}";

    public static final SettingsManager SETTINGS_MANAGER =
            new SettingsManager(MOD_VERSION, MOD_ID, MOD_NAME);

    @Override
    public void onInitialize() {
        CarpetServer.manageExtension(this);
        ServerPlayConnectionEvents.JOIN.register((handler, sender, server) -> {
            if (LIRSettings.renewableDebugSample) {
                handler.player.sendMessage(
                        net.minecraft.text.Text.literal("[LIR] renewableDebugSample is enabled."),
                        false
                );
            }
        });
    }

    @Override
    public void onGameStarted() {
        SETTINGS_MANAGER.parseSettingsClass(LIRSettings.class);
    }

    @Override
    public String version() {
        return MOD_VERSION;
    }
}
