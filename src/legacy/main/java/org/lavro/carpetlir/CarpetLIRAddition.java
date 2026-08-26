package org.lavro.carpetlir;

import carpet.CarpetExtension;
import carpet.CarpetServer;
import com.google.gson.Gson;
import com.google.gson.JsonParseException;
import com.google.gson.reflect.TypeToken;
import net.fabricmc.api.ModInitializer;
import net.fabricmc.loader.api.FabricLoader;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Type;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class CarpetLIRAddition implements CarpetExtension, ModInitializer {
    public static final String MOD_ID = "carpetlir";
    public static final String MOD_NAME = "Carpet LIR Addition";

    @Override
    public void onInitialize() {
        CarpetServer.manageExtension(this);
        LegacyFeatureBootstrap.register();
    }

    @Override
    public void onGameStarted() {
        CarpetServer.settingsManager.parseSettingsClass(LIRSettings.class);
    }

    @Override
    public String version() {
        return FabricLoader.getInstance()
                .getModContainer(MOD_ID)
                .map(container -> container.getMetadata().getVersion().getFriendlyString())
                .orElse("unknown");
    }

    @Override
    public Map<String, String> canHasTranslations(String lang) {
        Map<String, String> translations = new HashMap<>(loadTranslations("en_us"));
        if (!"en_us".equals(lang)) {
            translations.putAll(loadTranslations(lang));
        }
        return translations;
    }

    /** Carpet 1.18 ignores the supplied path in its translation helper, so read our own resources. */
    private static Map<String, String> loadTranslations(String lang) {
        String resourcePath = "/assets/" + MOD_ID + "/lang/" + lang + ".json";
        try (InputStream stream = CarpetLIRAddition.class.getResourceAsStream(resourcePath)) {
            if (stream == null) {
                return Collections.emptyMap();
            }
            Type mapType = new TypeToken<Map<String, String>>() { }.getType();
            try (InputStreamReader reader = new InputStreamReader(stream, StandardCharsets.UTF_8)) {
                Map<String, String> loaded = new Gson().fromJson(reader, mapType);
                return loaded == null ? Collections.emptyMap() : loaded;
            }
        } catch (IOException | JsonParseException exception) {
            throw new IllegalStateException("Unable to read Carpet LIR translations from " + resourcePath, exception);
        }
    }
}
