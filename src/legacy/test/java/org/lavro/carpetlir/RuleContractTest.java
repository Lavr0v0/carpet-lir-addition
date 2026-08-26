package org.lavro.carpetlir;

import org.junit.jupiter.api.Test;

import java.lang.annotation.Annotation;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RuleContractTest {
    private static final Set<String> SUPPORTED_RULE_ANNOTATIONS = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            "carpet.api.settings.Rule",
            "carpet.settings.Rule"
    )));
    private static final Set<String> EXPECTED_CATEGORIES = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            "LIR",
            "FEATURE",
            "RENEWABLE"
    )));

    @Test
    void everyRuleIsPublicStaticAnnotatedCategorizedAndDisabledByDefault() throws ReflectiveOperationException {
        Field[] ruleFields = Arrays.stream(LIRSettings.class.getDeclaredFields())
                .filter(field -> field.getType() == boolean.class)
                .toArray(Field[]::new);

        assertTrue(ruleFields.length > 0, "LIRSettings must expose at least one boolean rule");
        for (Field field : ruleFields) {
            int modifiers = field.getModifiers();
            assertTrue(Modifier.isPublic(modifiers), field.getName() + " must be public");
            assertTrue(Modifier.isStatic(modifiers), field.getName() + " must be static");

            List<Annotation> ruleAnnotations = Arrays.stream(field.getDeclaredAnnotations())
                    .filter(annotation -> SUPPORTED_RULE_ANNOTATIONS.contains(annotation.annotationType().getName()))
                    .collect(Collectors.toList());
            assertEquals(1, ruleAnnotations.size(),
                    field.getName() + " must have exactly one supported @Rule annotation");

            Annotation ruleAnnotation = ruleAnnotations.get(0);
            boolean usesLegacyRule = ruleAnnotation.annotationType().getName().equals("carpet.settings.Rule");
            String categoryAttribute = usesLegacyRule ? "category" : "categories";
            Object categoryValue = ruleAnnotation.annotationType()
                    .getMethod(categoryAttribute)
                    .invoke(ruleAnnotation);
            assertTrue(categoryValue instanceof String[],
                    field.getName() + " @Rule categories must be a String array");
            String[] categories = (String[]) categoryValue;
            assertEquals(EXPECTED_CATEGORIES.size(), categories.length,
                    field.getName() + " must not repeat or add rule categories");
            assertEquals(EXPECTED_CATEGORIES, new HashSet<>(Arrays.asList(categories)),
                    field.getName() + " must use exactly the LIR, FEATURE, and RENEWABLE categories");

            if (usesLegacyRule) {
                String description = (String) ruleAnnotation.annotationType()
                        .getMethod("desc")
                        .invoke(ruleAnnotation);
                assertFalse(description.trim().isEmpty(),
                        field.getName() + " legacy @Rule description must not be blank");
            }

            assertFalse(field.getBoolean(null), field.getName() + " must default to false");
        }
    }

    @Test
    void bundledEnglishTranslationsMatchTheSelectedRuleTier() {
        Set<String> ruleNames = Arrays.stream(LIRSettings.class.getDeclaredFields())
                .filter(field -> field.getType() == boolean.class)
                .map(Field::getName)
                .collect(Collectors.toSet());
        Map<String, String> translations = new CarpetLIRAddition().canHasTranslations("en_us");

        for (String ruleName : ruleNames) {
            assertTrue(translations.containsKey("carpet.rule." + ruleName + ".name"),
                    ruleName + " must have an English name");
            assertTrue(translations.containsKey("carpet.rule." + ruleName + ".desc"),
                    ruleName + " must have an English description");
        }

        Set<String> translatedRuleNames = translations.keySet().stream()
                .filter(key -> key.startsWith("carpet.rule."))
                .filter(key -> key.endsWith(".name") || key.endsWith(".desc"))
                .map(key -> key.substring("carpet.rule.".length(), key.lastIndexOf('.')))
                .collect(Collectors.toSet());
        assertEquals(ruleNames, translatedRuleNames,
                "translation resources must not expose rules omitted by the selected capability tier");
    }
}
