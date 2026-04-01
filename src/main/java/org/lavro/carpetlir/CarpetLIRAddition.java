package org.lavro.carpetlir;

import carpet.CarpetExtension;
import carpet.CarpetServer;
import carpet.utils.Translations;
import net.fabricmc.api.ModInitializer;
import org.lavro.carpetlir.features.renewable.BoneMealGrassifyDirtFeature;
import org.lavro.carpetlir.features.renewable.ReinforcedDeepslateFeature;

import java.util.HashMap;
import java.util.Map;

public class CarpetLIRAddition implements CarpetExtension, ModInitializer {
    public static final String MOD_ID = "carpetlir";
    public static final String MOD_NAME = "Carpet LIR Addition";
    public static final String MOD_VERSION = "${version}";

    @Override
    public void onInitialize() {
        CarpetServer.manageExtension(this);
        BoneMealGrassifyDirtFeature.register();
        ReinforcedDeepslateFeature.register();
    }

    @Override
    public void onGameStarted() {
        CarpetServer.settingsManager.parseSettingsClass(LIRSettings.class);
    }

    @Override
    public String version() {
        return MOD_VERSION;
    }

    @Override
    public Map<String, String> canHasTranslations(String lang) {
        Map<String, String> translations = new HashMap<>(
                Translations.getTranslationFromResourcePath("assets/%s/lang/en_us.json".formatted(MOD_ID))
        );
        if (!"en_us".equals(lang)) {
            translations.putAll(
                    Translations.getTranslationFromResourcePath("assets/%s/lang/%s.json".formatted(MOD_ID, lang))
            );
        }
        return translations;
    }
}
