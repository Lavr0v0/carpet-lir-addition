package org.lavro.carpetlir;

import org.junit.jupiter.api.Test;

import java.lang.annotation.Annotation;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RuleContractTest {
    private static final Set<String> SUPPORTED_RULE_ANNOTATIONS = Set.of(
            "carpet.api.settings.Rule",
            "carpet.settings.Rule"
    );

    @Test
    void everyRuleIsPublicStaticAnnotatedAndDisabledByDefault() throws IllegalAccessException {
        Field[] ruleFields = Arrays.stream(LIRSettings.class.getDeclaredFields())
                .filter(field -> field.getType() == boolean.class)
                .toArray(Field[]::new);

        assertTrue(ruleFields.length > 0, "LIRSettings must expose at least one boolean rule");
        for (Field field : ruleFields) {
            int modifiers = field.getModifiers();
            assertTrue(Modifier.isPublic(modifiers), field.getName() + " must be public");
            assertTrue(Modifier.isStatic(modifiers), field.getName() + " must be static");
            boolean hasRuleAnnotation = Arrays.stream(field.getDeclaredAnnotations())
                    .map(Annotation::annotationType)
                    .map(Class::getName)
                    .anyMatch(SUPPORTED_RULE_ANNOTATIONS::contains);
            assertTrue(hasRuleAnnotation, field.getName() + " must have a supported @Rule annotation");
            assertFalse(field.getBoolean(null), field.getName() + " must default to false");
        }
    }
}
