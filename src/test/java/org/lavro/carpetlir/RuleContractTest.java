package org.lavro.carpetlir;

import carpet.api.settings.Rule;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RuleContractTest {
    private static final Set<String> NON_RENEWABLE_RECOVERY_RULES = Set.of(
            "obsidianHardnessReinforcedDeepslate",
            "silkTouchableReinforcedDeepslate",
            "pistonHarvestableAmethysts"
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
            assertTrue(field.isAnnotationPresent(Rule.class), field.getName() + " must have @Rule");
            Set<String> expectedCategories = new HashSet<>(Arrays.asList("LIR", "FEATURE"));
            if (!NON_RENEWABLE_RECOVERY_RULES.contains(field.getName())) {
                expectedCategories.add("RENEWABLE");
            }
            Set<String> actualCategories = new HashSet<>(Arrays.asList(
                    field.getAnnotation(Rule.class).categories()
            ));
            assertEquals(expectedCategories, actualCategories,
                    field.getName() + " must use categories that match its resource semantics");
            assertFalse(field.getBoolean(null), field.getName() + " must default to false");
        }
    }
}
