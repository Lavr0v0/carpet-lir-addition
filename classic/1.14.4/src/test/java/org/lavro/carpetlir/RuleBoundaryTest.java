package org.lavro.carpetlir;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import carpet.settings.Rule;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;
import org.junit.jupiter.api.Test;

class RuleBoundaryTest {
    @Test
    void classicTargetExportsOnlyTwoDisabledByDefaultRules() throws IllegalAccessException {
        Field[] ruleFields = Arrays.stream(LIRSettings.class.getDeclaredFields())
                .filter(field -> field.getType() == boolean.class)
                .toArray(Field[]::new);
        Set<String> ruleNames = Arrays.stream(ruleFields)
                .map(Field::getName)
                .collect(Collectors.toSet());

        assertEquals(new HashSet<>(Arrays.asList(
                "boneMealGrassifyDirt",
                "renewableLeavesCrafting"
        )), ruleNames);
        for (Field field : ruleFields) {
            int modifiers = field.getModifiers();
            assertTrue(Modifier.isPublic(modifiers), field.getName() + " must be public");
            assertTrue(Modifier.isStatic(modifiers), field.getName() + " must be static");
            assertTrue(field.isAnnotationPresent(Rule.class), field.getName() + " must have @Rule");
            assertFalse(field.getBoolean(null), field.getName() + " must default to false");
        }
    }
}
