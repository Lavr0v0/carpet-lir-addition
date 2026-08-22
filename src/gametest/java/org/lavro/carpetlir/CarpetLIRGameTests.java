package org.lavro.carpetlir;

import net.fabricmc.fabric.api.event.player.UseBlockCallback;
import net.fabricmc.fabric.api.gametest.v1.GameTest;
import net.minecraft.core.BlockPos;
import net.minecraft.gametest.framework.GameTestHelper;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.InteractionResult;
import net.minecraft.world.entity.EntityTypes;
import net.minecraft.world.entity.monster.warden.Warden;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;
import net.minecraft.world.item.crafting.RecipeType;
import net.minecraft.world.item.crafting.SingleRecipeInput;
import net.minecraft.world.level.GameType;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.piston.PistonBaseBlock;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.gamerules.GameRules;
import net.minecraft.world.phys.BlockHitResult;
import net.minecraft.world.phys.Vec3;

public final class CarpetLIRGameTests {
    private static final BlockPos TEST_POS = new BlockPos(1, 2, 1);

    @GameTest
    public void calciteGeneratesWhenRuleAndStructureMatch(GameTestHelper helper) {
        try {
            LIRSettings.renewableCalcite = true;
            placeCalciteGenerator(helper, true);

            helper.assertBlockPresent(Blocks.CALCITE, TEST_POS);
            helper.succeed();
        } finally {
            LIRSettings.renewableCalcite = false;
        }
    }

    @GameTest
    public void calciteRuleOffLeavesLavaToVanilla(GameTestHelper helper) {
        LIRSettings.renewableCalcite = false;
        placeCalciteGenerator(helper, true);

        helper.assertBlockPresent(Blocks.LAVA, TEST_POS);
        helper.succeed();
    }

    @GameTest
    public void calciteRequiresAdjacentAmethyst(GameTestHelper helper) {
        try {
            LIRSettings.renewableCalcite = true;
            placeCalciteGenerator(helper, false);

            helper.assertBlockPresent(Blocks.LAVA, TEST_POS);
            helper.succeed();
        } finally {
            LIRSettings.renewableCalcite = false;
        }
    }

    @GameTest
    public void boneMealGrassifiesDirtAndConsumesOneItem(GameTestHelper helper) {
        try {
            LIRSettings.boneMealGrassifyDirt = true;
            helper.setBlock(TEST_POS, Blocks.DIRT);
            Player player = boneMealPlayer(helper, 2);

            InteractionResult result = useBoneMealCallback(helper, player);

            helper.assertTrue(result == InteractionResult.SUCCESS_SERVER, "Expected server success result");
            helper.assertBlockPresent(Blocks.GRASS_BLOCK, TEST_POS);
            helper.assertTrue(player.getMainHandItem().getCount() == 1, "Expected one bone meal to be consumed");
            helper.succeed();
        } finally {
            LIRSettings.boneMealGrassifyDirt = false;
        }
    }

    @GameTest
    public void boneMealRuleOffPreservesDirtAndItem(GameTestHelper helper) {
        LIRSettings.boneMealGrassifyDirt = false;
        helper.setBlock(TEST_POS, Blocks.DIRT);
        Player player = boneMealPlayer(helper, 2);

        InteractionResult result = useBoneMealCallback(helper, player);

        helper.assertTrue(result == InteractionResult.PASS, "Expected callback to pass through");
        helper.assertBlockPresent(Blocks.DIRT, TEST_POS);
        helper.assertTrue(player.getMainHandItem().getCount() == 2, "Expected no bone meal consumption");
        helper.succeed();
    }

    @GameTest
    public void boneMealRequiresGrassSurvivalSpace(GameTestHelper helper) {
        try {
            LIRSettings.boneMealGrassifyDirt = true;
            helper.setBlock(TEST_POS, Blocks.DIRT);
            helper.setBlock(TEST_POS.above(), Blocks.WATER);
            Player player = boneMealPlayer(helper, 2);

            InteractionResult result = useBoneMealCallback(helper, player);

            helper.assertTrue(result == InteractionResult.PASS, "Expected blocked dirt to pass through");
            helper.assertBlockPresent(Blocks.DIRT, TEST_POS);
            helper.assertTrue(player.getMainHandItem().getCount() == 2, "Expected no bone meal consumption");
            helper.succeed();
        } finally {
            LIRSettings.boneMealGrassifyDirt = false;
        }
    }

    @GameTest
    public void wardenDropsReinforcedDeepslateWhenEnabled(GameTestHelper helper) {
        ServerLevel level = helper.getLevel();
        try {
            LIRSettings.wardensDropReinforcedDeepslate = true;
            level.getGameRules().set(GameRules.MOB_DROPS, true, level.getServer());
            Warden warden = helper.spawn(EntityTypes.WARDEN, TEST_POS);

            warden.kill(level);

            helper.assertItemEntityPresent(Items.REINFORCED_DEEPSLATE, TEST_POS, 3.0);
            helper.succeed();
        } finally {
            resetWardenDropState(level);
        }
    }

    @GameTest
    public void wardenRuleOffDoesNotAddReinforcedDeepslate(GameTestHelper helper) {
        ServerLevel level = helper.getLevel();
        try {
            LIRSettings.wardensDropReinforcedDeepslate = false;
            level.getGameRules().set(GameRules.MOB_DROPS, true, level.getServer());
            Warden warden = helper.spawn(EntityTypes.WARDEN, TEST_POS);

            warden.kill(level);

            helper.assertItemEntityNotPresent(Items.REINFORCED_DEEPSLATE, TEST_POS, 3.0);
            helper.succeed();
        } finally {
            resetWardenDropState(level);
        }
    }

    @GameTest
    public void wardenDropRespectsMobDropsGameRule(GameTestHelper helper) {
        ServerLevel level = helper.getLevel();
        try {
            LIRSettings.wardensDropReinforcedDeepslate = true;
            level.getGameRules().set(GameRules.MOB_DROPS, false, level.getServer());
            Warden warden = helper.spawn(EntityTypes.WARDEN, TEST_POS);

            warden.kill(level);

            helper.assertItemEntityNotPresent(Items.REINFORCED_DEEPSLATE, TEST_POS, 3.0);
            helper.succeed();
        } finally {
            resetWardenDropState(level);
        }
    }

    @GameTest
    public void recipeRuleEnablesAndDisablesSmeltingMatch(GameTestHelper helper) {
        ServerLevel level = helper.getLevel();
        SingleRecipeInput gravel = new SingleRecipeInput(new ItemStack(Items.GRAVEL));
        try {
            LIRSettings.renewableTuff = false;
            helper.assertTrue(
                    level.recipeAccess().getRecipeFor(RecipeType.SMELTING, gravel, level).isEmpty(),
                    "Expected the tuff recipe to be absent while disabled"
            );

            LIRSettings.renewableTuff = true;
            var enabled = level.recipeAccess().getRecipeFor(RecipeType.SMELTING, gravel, level);
            helper.assertTrue(enabled.isPresent(), "Expected the tuff recipe while enabled");
            helper.assertTrue(
                    enabled.orElseThrow().id().identifier().getPath().equals("gravel_to_tuff_smelting"),
                    "Expected Carpet LIR's gravel-to-tuff recipe"
            );
            helper.succeed();
        } finally {
            LIRSettings.renewableTuff = false;
        }
    }

    @GameTest
    public void reinforcedDeepslateHardnessFollowsRule(GameTestHelper helper) {
        try {
            helper.setBlock(TEST_POS, Blocks.REINFORCED_DEEPSLATE);
            BlockPos absolutePos = helper.absolutePos(TEST_POS);
            LIRSettings.obsidianHardnessReinforcedDeepslate = false;
            float vanilla = helper.getBlockState(TEST_POS).getDestroySpeed(helper.getLevel(), absolutePos);
            float expected = Blocks.OBSIDIAN.defaultBlockState().getDestroySpeed(helper.getLevel(), absolutePos);

            LIRSettings.obsidianHardnessReinforcedDeepslate = true;
            float actual = helper.getBlockState(TEST_POS).getDestroySpeed(helper.getLevel(), absolutePos);

            helper.assertTrue(Float.compare(expected, vanilla) != 0, "Expected vanilla reinforced deepslate hardness while disabled");
            helper.assertTrue(Float.compare(expected, actual) == 0, "Expected obsidian hardness");
            helper.succeed();
        } finally {
            LIRSettings.obsidianHardnessReinforcedDeepslate = false;
        }
    }

    @GameTest(maxTicks = 40)
    public void pistonHarvestingFollowsRule(GameTestHelper helper) {
        LIRSettings.pistonHarvestableAmethysts = false;
        powerPistonFacingBuddingAmethyst(helper);

        helper.runAfterDelay(4, () -> {
            helper.assertBlockNotPresent(Blocks.BUDDING_AMETHYST, TEST_POS.east());
            helper.assertItemEntityNotPresent(Items.BUDDING_AMETHYST, TEST_POS.east(), 3.0);

            helper.setBlock(TEST_POS.west(), Blocks.AIR);
            helper.setBlock(TEST_POS, Blocks.AIR);
            helper.setBlock(TEST_POS.east(), Blocks.AIR);
            LIRSettings.pistonHarvestableAmethysts = true;
            powerPistonFacingBuddingAmethyst(helper);
        });

        helper.runAfterDelay(8, () -> {
            try {
                helper.assertBlockNotPresent(Blocks.BUDDING_AMETHYST, TEST_POS.east());
                helper.assertItemEntityPresent(Items.BUDDING_AMETHYST, TEST_POS.east(), 3.0);
                helper.succeed();
            } finally {
                LIRSettings.pistonHarvestableAmethysts = false;
            }
        });
    }

    private static void placeCalciteGenerator(GameTestHelper helper, boolean includeAmethyst) {
        helper.setBlock(TEST_POS.below(), Blocks.BONE_BLOCK);
        if (includeAmethyst) {
            helper.setBlock(TEST_POS.east(), Blocks.AMETHYST_BLOCK);
        }
        helper.setBlock(TEST_POS, Blocks.LAVA);
    }

    private static Player boneMealPlayer(GameTestHelper helper, int count) {
        Player player = helper.makeMockPlayer(GameType.SURVIVAL);
        player.setItemInHand(InteractionHand.MAIN_HAND, new ItemStack(Items.BONE_MEAL, count));
        return player;
    }

    private static InteractionResult useBoneMealCallback(GameTestHelper helper, Player player) {
        BlockPos absolutePos = helper.absolutePos(TEST_POS);
        BlockHitResult hit = new BlockHitResult(Vec3.atCenterOf(absolutePos), net.minecraft.core.Direction.UP, absolutePos, false);
        return UseBlockCallback.EVENT.invoker().interact(player, helper.getLevel(), InteractionHand.MAIN_HAND, hit);
    }

    private static void resetWardenDropState(ServerLevel level) {
        LIRSettings.wardensDropReinforcedDeepslate = false;
        level.getGameRules().set(GameRules.MOB_DROPS, true, level.getServer());
    }

    private static void powerPistonFacingBuddingAmethyst(GameTestHelper helper) {
        BlockState piston = Blocks.PISTON.defaultBlockState().setValue(PistonBaseBlock.FACING, net.minecraft.core.Direction.EAST);
        helper.setBlock(TEST_POS.east(), Blocks.BUDDING_AMETHYST);
        helper.setBlock(TEST_POS, piston);
        helper.setBlock(TEST_POS.west(), Blocks.REDSTONE_BLOCK);
    }
}
