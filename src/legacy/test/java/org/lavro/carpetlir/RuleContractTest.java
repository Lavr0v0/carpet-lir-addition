package org.lavro.carpetlir;

import org.junit.jupiter.api.Test;

import java.lang.annotation.Annotation;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RuleContractTest {
    private static final Set<String> SUPPORTED_RULE_ANNOTATIONS = Set.of(
            "carpet.api.settings.Rule",
            "carpet.settings.Rule"
    );
    private static final Set<String> EXPECTED_CATEGORIES = Set.of("LIR", "FEATURE", "RENEWABLE");

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
                    .toList();
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
            assertEquals(EXPECTED_CATEGORIES, Set.copyOf(Arrays.asList(categories)),
                    field.getName() + " must use exactly the LIR, FEATURE, and RENEWABLE categories");

            if (usesLegacyRule) {
                String description = (String) ruleAnnotation.annotationType()
                        .getMethod("desc")
                        .invoke(ruleAnnotation);
                assertFalse(description.isBlank(),
                        field.getName() + " legacy @Rule description must not be blank");
            }

            assertFalse(field.getBoolean(null), field.getName() + " must default to false");
        }
    }
}
