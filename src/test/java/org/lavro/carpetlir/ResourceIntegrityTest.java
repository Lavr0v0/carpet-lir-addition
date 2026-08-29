package org.lavro.carpetlir;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;
import java.util.Set;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ResourceIntegrityTest {
    private static final Path LANGUAGE_DIRECTORY = Path.of(
            "src", "main", "resources", "assets", CarpetLIRAddition.MOD_ID, "lang"
    );
    private static final Map<String, String> CALCITE_NO_WATER_PHRASES = Map.of(
            "en_us.json", "Water is not required",
            "es_ar.json", "No requiere agua",
            "fr_fr.json", "Aucune eau n'est requise",
            "pt_br.json", "Não requer água",
            "zh_cn.json", "不需要水",
            "zh_tw.json", "不需要水"
    );

    @Test
    void translationsStayInKeyParityWithEnglish() throws IOException {
        JsonObject english = readJson(LANGUAGE_DIRECTORY.resolve("en_us.json"));
        Set<String> expectedKeys = english.keySet();

        try (Stream<Path> files = Files.list(LANGUAGE_DIRECTORY)) {
            files.filter(path -> path.getFileName().toString().endsWith(".json"))
                    .forEach(path -> assertEquals(expectedKeys, readJsonUnchecked(path).keySet(), path.toString()));
        }
    }

    @Test
    void translationFilesContainRuleNamesAndDescriptions() throws IOException {
        JsonObject english = readJson(LANGUAGE_DIRECTORY.resolve("en_us.json"));

        for (var field : LIRSettings.class.getDeclaredFields()) {
            if (field.getType() != boolean.class) {
                continue;
            }
            assertTrue(english.has("carpet.rule." + field.getName() + ".name"), field.getName() + " name");
            assertTrue(english.has("carpet.rule." + field.getName() + ".desc"), field.getName() + " description");
        }
    }

    @Test
    void calciteTranslationsExplicitlyRejectTheOldWaterRequirement() throws IOException {
        String descriptionKey = "carpet.rule.renewableCalcite.desc";
        for (Map.Entry<String, String> entry : CALCITE_NO_WATER_PHRASES.entrySet()) {
            JsonObject language = readJson(LANGUAGE_DIRECTORY.resolve(entry.getKey()));
            String description = language.get(descriptionKey).getAsString();
            assertTrue(description.contains(entry.getValue()),
                    entry.getKey() + " must state that calcite generation does not require water");
        }
    }

    @Test
    void userDocumentationExplainsRulePersistenceAndIndependentSources() throws IOException {
        String readme = Files.readString(Path.of("README.md"));
        assertTrue(readme.contains("/carpet setDefault renewableCalcite true"),
                "README must document persistent modern rule configuration");
        assertTrue(readme.contains("/carpet removeDefault renewableCalcite"),
                "README must document removal of persistent modern rule configuration");
        assertTrue(readme.contains("There is no single \"renewable deepslate\" rule"),
                "README must distinguish the three reinforced-deepslate rules");

        String summary = Files.readString(Path.of("LIR_Renewable_Features_Summary.md"));
        assertFalse(summary.contains("用于触发熔岩转化的水流结构"),
                "technical summary must not reintroduce the incorrect water requirement");
        assertTrue(summary.contains("不需要水"),
                "technical summary must explicitly state that calcite does not require water");
        assertTrue(summary.contains("以下三条强化深板岩规则彼此独立"),
                "technical summary must distinguish the reinforced-deepslate rules");
    }

    private static JsonObject readJson(Path path) throws IOException {
        return JsonParser.parseString(Files.readString(path)).getAsJsonObject();
    }

    private static JsonObject readJsonUnchecked(Path path) {
        try {
            return readJson(path);
        } catch (IOException exception) {
            throw new AssertionError("Failed to read " + path, exception);
        }
    }
}
