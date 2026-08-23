package org.lavro.carpetlir.features.renewable;

import net.minecraft.Bootstrap;
import net.minecraft.SharedConstants;
import net.minecraft.block.Blocks;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.lavro.carpetlir.LIRSettings;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PistonHarvestableAmethystFeatureTest {
    @BeforeAll
    static void bootstrapMinecraftRegistries() {
        SharedConstants.createGameVersion();
        Bootstrap.initialize();
    }

    @AfterEach
    void resetRule() {
        LIRSettings.pistonHarvestableAmethysts = false;
    }

    @Test
    void buddingAmethystIsNotDestroyableByDefault() {
        assertFalse(PistonHarvestableAmethystFeature.shouldBreakWhenPushed(
                Blocks.BUDDING_AMETHYST.getDefaultState()
        ));
    }

    @Test
    void ruleMakesOnlyBuddingAmethystDestroyable() {
        LIRSettings.pistonHarvestableAmethysts = true;

        assertTrue(PistonHarvestableAmethystFeature.shouldBreakWhenPushed(
                Blocks.BUDDING_AMETHYST.getDefaultState()
        ));
        assertFalse(PistonHarvestableAmethystFeature.shouldBreakWhenPushed(
                Blocks.AMETHYST_BLOCK.getDefaultState()
        ));
    }

    @Test
    void disablingRuleTakesEffectImmediately() {
        LIRSettings.pistonHarvestableAmethysts = true;
        assertTrue(PistonHarvestableAmethystFeature.shouldBreakWhenPushed(
                Blocks.BUDDING_AMETHYST.getDefaultState()
        ));

        LIRSettings.pistonHarvestableAmethysts = false;
        assertFalse(PistonHarvestableAmethystFeature.shouldBreakWhenPushed(
                Blocks.BUDDING_AMETHYST.getDefaultState()
        ));
    }
}
