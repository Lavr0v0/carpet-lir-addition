package org.lavro.carpetlir;

import org.junit.jupiter.api.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

class LegacyCarpetLIRAdditionTest {
    @Test
    void convertsOnlyCarpetRuleAndCategoryKeysForLegacySettingsManagers() {
        Map<String, String> modern = new HashMap<>();
        modern.put("carpet.rule.boneMealGrassifyDirt.name", "boneMealGrassifyDirt");
        modern.put("carpet.category.RENEWABLE", "Renewable");
        modern.put("modmenu.nameTranslation.carpetlir", "Carpet LIR Addition");

        Map<String, String> legacy = LegacyCarpetLIRAddition.toLegacyTranslationKeys(modern);

        assertEquals("boneMealGrassifyDirt", legacy.get("rule.boneMealGrassifyDirt.name"));
        assertEquals("Renewable", legacy.get("category.RENEWABLE"));
        assertEquals("Carpet LIR Addition", legacy.get("modmenu.nameTranslation.carpetlir"));
        assertFalse(legacy.containsKey("carpet.rule.boneMealGrassifyDirt.name"));
        assertFalse(legacy.containsKey("carpet.category.RENEWABLE"));
    }
}
