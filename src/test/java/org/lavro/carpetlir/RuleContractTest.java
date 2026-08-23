package org.lavro.carpetlir;

import carpet.api.settings.Rule;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RuleContractTest {
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
            assertTrue(field.isAnnotationPresent(Rule.class), field.getName() + " must have @Rule");
            assertFalse(field.getBoolean(null), field.getName() + " must default to false");
        }
    }
}
