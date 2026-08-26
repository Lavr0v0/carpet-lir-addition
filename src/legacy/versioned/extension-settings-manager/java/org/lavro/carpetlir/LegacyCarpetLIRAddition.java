package org.lavro.carpetlir;

import carpet.CarpetExtension;
import carpet.CarpetServer;
import carpet.settings.SettingsManager;
import com.google.gson.Gson;
import com.google.gson.JsonParseException;
import com.google.gson.reflect.TypeToken;
import net.fabricmc.api.ModInitializer;
import net.fabricmc.loader.api.FabricLoader;
import net.minecraft.server.MinecraftServer;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Type;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/** Uses the extension-owned SettingsManager required by Carpet's Java 8 command API. */
public final class LegacyCarpetLIRAddition implements CarpetExtension, ModInitializer {
    private final SettingsManager settingsManager;

    public LegacyCarpetLIRAddition() {
        settingsManager = new SettingsManager(
                version(),
                CarpetLIRAddition.MOD_ID,
                CarpetLIRAddition.MOD_NAME
        );
        // Early Carpet releases can register extension commands before onGameStarted.
        settingsManager.parseSettingsClass(LIRSettings.class);
    }

    @Override
    public void onInitialize() {
        CarpetServer.manageExtension(this);
        LegacyFeatureBootstrap.register();
    }

    @Override
    public void onGameStarted() {
        // Re-parsing is idempotent and covers Carpet's normal game-start lifecycle.
        settingsManager.parseSettingsClass(LIRSettings.class);
    }

    @Override
    public SettingsManager customSettingsManager() {
        return settingsManager;
    }

    @Override
    public void onServerClosed(MinecraftServer server) {
        settingsManager.detachServer();
    }

    @Override
    public String version() {
        return FabricLoader.getInstance()
                .getModContainer(CarpetLIRAddition.MOD_ID)
                .map(container -> container.getMetadata().getVersion().getFriendlyString())
                .orElse("unknown");
    }

    public Map<String, String> canHasTranslations(String lang) {
        Map<String, String> translations = new HashMap<>(loadTranslations("en_us"));
        if (!"en_us".equals(lang)) {
            translations.putAll(loadTranslations(lang));
        }
        return translations;
    }

    private static Map<String, String> loadTranslations(String lang) {
        String resourcePath = "/assets/" + CarpetLIRAddition.MOD_ID + "/lang/" + lang + ".json";
        try (InputStream stream = LegacyCarpetLIRAddition.class.getResourceAsStream(resourcePath)) {
            if (stream == null) {
                return Collections.emptyMap();
            }
            Type mapType = new TypeToken<Map<String, String>>() { }.getType();
            try (InputStreamReader reader = new InputStreamReader(stream, StandardCharsets.UTF_8)) {
                Map<String, String> loaded = new Gson().fromJson(reader, mapType);
                return loaded == null ? Collections.emptyMap() : toLegacyTranslationKeys(loaded);
            }
        } catch (IOException | JsonParseException exception) {
            throw new IllegalStateException("Unable to read Carpet LIR translations from " + resourcePath, exception);
        }
    }

    /** Carpet 1.15.2-1.16 predates the modern carpet.rule/carpet.category key prefixes. */
    static Map<String, String> toLegacyTranslationKeys(Map<String, String> translations) {
        Map<String, String> legacyTranslations = new HashMap<>();
        for (Map.Entry<String, String> entry : translations.entrySet()) {
            String key = entry.getKey();
            if (key.startsWith("carpet.rule.") || key.startsWith("carpet.category.")) {
                key = key.substring("carpet.".length());
            }
            legacyTranslations.put(key, entry.getValue());
        }
        return legacyTranslations;
    }
}
