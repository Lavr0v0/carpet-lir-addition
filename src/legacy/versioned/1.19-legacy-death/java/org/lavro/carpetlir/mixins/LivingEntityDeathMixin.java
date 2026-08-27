package org.lavro.carpetlir.mixins;

import net.minecraft.entity.LivingEntity;
import net.minecraft.entity.damage.DamageSource;
import org.lavro.carpetlir.features.renewable.ReinforcedDeepslateFeature;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(LivingEntity.class)
public abstract class LivingEntityDeathMixin {
    /** Mirrors Fabric API's later AFTER_DEATH injection for versions where that event is unavailable. */
    @Inject(
            method = "onDeath",
            at = @At(
                    value = "INVOKE",
                    target = "Lnet/minecraft/world/World;sendEntityStatus(Lnet/minecraft/entity/Entity;B)V"
            )
    )
    private void carpetlir$handleWardenDeath(DamageSource source, CallbackInfo ci) {
        ReinforcedDeepslateFeature.handleWardenDeath((LivingEntity) (Object) this);
    }
}
