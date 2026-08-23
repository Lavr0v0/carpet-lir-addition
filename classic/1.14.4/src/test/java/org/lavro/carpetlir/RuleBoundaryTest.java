package org.lavro.carpetlir;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

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
        Set<String> ruleNames = Arrays.stream(LIRSettings.class.getDeclaredFields())
                .filter(field -> field.isAnnotationPresent(Rule.class))
                .map(Field::getName)
                .collect(Collectors.toSet());

        assertEquals(new HashSet<>(Arrays.asList(
                "boneMealGrassifyDirt",
                "renewableLeavesCrafting"
        )), ruleNames);
        for (Field field : LIRSettings.class.getDeclaredFields()) {
            if (field.isAnnotationPresent(Rule.class) && Modifier.isStatic(field.getModifiers())) {
                assertFalse(field.getBoolean(null), field.getName() + " must default to false");
            }
        }
    }
}
