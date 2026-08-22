package org.lavro.carpetlir;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Set;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ResourceIntegrityTest {
    private static final Path LANGUAGE_DIRECTORY = Path.of(
            "src", "main", "resources", "assets", CarpetLIRAddition.MOD_ID, "lang"
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
