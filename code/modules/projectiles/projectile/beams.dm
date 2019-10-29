/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 40
	damage_type = BURN
	sharp = TRUE // concentrated burns
	flag = "laser"
	eyeblur = 4
	var/frequency = 1
	hitscan = 1

	w_class = ITEM_SIZE_NORMAL

	muzzle_type = /obj/effect/projectile/laser/muzzle
	tracer_type = /obj/effect/projectile/laser/tracer
	impact_type = /obj/effect/projectile/laser/impact

/obj/item/projectile/beam/atom_init()
	. = ..()
	proj_act_sound = SOUNDIN_LASERACT

/obj/item/projectile/beam/practice
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	fake = 1
	flag = "laser"
	eyeblur = 2

/obj/item/projectile/beam/practice/atom_init()
	. = ..()
	proj_act_sound = null

/obj/item/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 5

/obj/item/projectile/beam/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 60

	muzzle_type = /obj/effect/projectile/laser_heavy/muzzle
	tracer_type = /obj/effect/projectile/laser_heavy/tracer
	impact_type = /obj/effect/projectile/laser_heavy/impact

/obj/item/projectile/beam/xray
	name = "xray beam"
	icon_state = "xray"
	damage = 30

	muzzle_type = /obj/effect/projectile/xray/muzzle
	tracer_type = /obj/effect/projectile/xray/tracer
	impact_type = /obj/effect/projectile/xray/impact

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50

	muzzle_type = /obj/effect/projectile/laser_pulse/muzzle
	tracer_type = /obj/effect/projectile/laser_pulse/tracer
	impact_type = /obj/effect/projectile/laser_pulse/impact

/obj/item/projectile/beam/deathlaser
	name = "death laser"
	icon_state = "heavylaser"
	damage = 60

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30

	muzzle_type = /obj/effect/projectile/emitter/muzzle
	tracer_type = /obj/effect/projectile/emitter/tracer
	impact_type = /obj/effect/projectile/emitter/impact

/obj/item/projectile/beam/emitter/singularity_pull()
	return //don't want the emitters to miss

/obj/item/projectile/beam/lasertag
	name = "lasertag beam"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	fake = TRUE
	flag = "laser"

	var/lasertag_color = "none"

/obj/item/projectile/beam/lasertag/atom_init()
	. = ..()
	proj_act_sound = null

/obj/item/projectile/beam/lasertag/on_hit(atom/target, blocked = 0)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(istype(H.wear_suit, /obj/item/clothing/suit/lasertag))
			var/obj/item/clothing/suit/lasertag/L = H.wear_suit
			if(L.lasertag_color != lasertag_color)
				H.Weaken(5)
	return TRUE

/obj/item/projectile/beam/lasertag/blue
	icon_state = "bluelaser"
	lasertag_color = "blue"

	muzzle_type = /obj/effect/projectile/laser_blue/muzzle
	tracer_type = /obj/effect/projectile/laser_blue/tracer
	impact_type = /obj/effect/projectile/laser_blue/impact

/obj/item/projectile/beam/lasertag/red
	icon_state = "laser"

	lasertag_color = "red"

	/*
	We don't announce seperate muzzle_types, since parent's laser is already red.
	*/

/obj/item/projectile/beam/lasertag/omni//A laser tag bolt that stuns EVERYONE
	icon_state = "omnilaser"

	muzzle_type = /obj/effect/projectile/laser_omni/muzzle
	tracer_type = /obj/effect/projectile/laser_omni/tracer
	impact_type = /obj/effect/projectile/laser_omni/impact

/obj/item/projectile/beam/sniper
	name = "sniper beam"
	icon_state = "laser"
	damage = 60
	stun = 5
	weaken = 5
	stutter = 5

	muzzle_type = /obj/effect/projectile/laser/muzzle
	tracer_type = /obj/effect/projectile/laser/tracer
	impact_type = /obj/effect/projectile/laser/impact

/obj/item/projectile/beam/rails
	name = "rails beam"
	icon_state = "omnilaser"
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE

	damage = 50
	stun = 5
	weaken = 5
	stutter = 5

	flag = "bullet"
	pass_flags = PASSTABLE
	damage_type = BRUTE
	sharp = TRUE

	muzzle_type = /obj/effect/projectile/rails/tracer // yes, tracer as muzzle!
	tracer_type = /obj/effect/projectile/rails/tracer
	impact_type = /obj/effect/projectile/rails/impact

/obj/item/projectile/beam/stun
	name = "stun beam"
	icon_state = "stun"
	nodamage = 1
	damage = 0
	agony = 40
	damage_type = HALLOSS
	sharp = FALSE // not a laser
	stutter = 5

	muzzle_type = /obj/effect/projectile/stun/muzzle
	tracer_type = /obj/effect/projectile/stun/tracer
	impact_type = /obj/effect/projectile/stun/impact

/obj/item/projectile/beam/stun/atom_init()
	. = ..()
	proj_act_sound = null




/obj/item/projectile/beam/magic
	flag = "magic"
	var/power_of_spell = 1.0

/obj/item/projectile/beam/magic/atom_init(atom/target, spell_power)
	src.power_of_spell = spell_power
	. = ..()

/obj/item/projectile/beam/magic/muh_lazur
	name = "muh lazur"
	icon_state = "laser"

	damage = 2
	stutter = 2
	agony = 2
	nodamage = FALSE

	muzzle_type = /obj/effect/projectile/laser/muzzle
	tracer_type = /obj/effect/projectile/laser/tracer
	impact_type = /obj/effect/projectile/laser/impact

	light_color = COLOR_RED

/obj/item/projectile/beam/magic/muh_lazur/atom_init()
	color = TO_NEGATIVE_COLOR
	. = ..()

/obj/item/projectile/beam/magic/healing
	name = "healing beam"
	icon_state = "xray"

	damage = 0.0
	nodamage = TRUE

	muzzle_type = /obj/effect/projectile/xray/muzzle
	tracer_type = /obj/effect/projectile/xray/tracer
	impact_type = /obj/effect/projectile/xray/impact

/obj/item/projectile/beam/magic/healing/on_hit(mob/living/target, blocked = 0)
	if(!istype(target) || target.stat == DEAD || issilicon(target))
		return

	var/hamt = -2.0 * power_of_spell
	var/reduced_heal = (power_of_spell >= 7.0)
	if(reduced_heal)
		hamt *= 0.15 // healing everything 85% less, because most of healing power goes into regeneration of limbs which also full heals them.
		target.restore_all_bodyparts()
		target.regenerate_icons()

	if(prob(power_of_spell)) // critical hit!!
		hamt *= 2

	if(power_of_spell >= 4)
		hamt *= 0.8
		target.cure_all_viruses()
	if(power_of_spell >= 5)
		hamt *= 0.7
		target.remove_any_mutations()

	target.apply_damages(reduced_heal ? 0 : hamt, reduced_heal ? 0 : hamt, hamt, hamt, hamt, hamt) // zero is for brute and burn in case of restoring bodyparts, because no point to heal them, since body parts restoration does that.
	target.apply_effects(hamt, hamt, hamt, hamt, hamt, hamt, hamt, hamt)

/obj/item/projectile/beam/magic/life_steal
	name = "life-steal beam"
	icon_state = "xray"

	damage = 0.0
	nodamage = TRUE

	muzzle_type = /obj/effect/projectile/xray/muzzle
	tracer_type = /obj/effect/projectile/xray/tracer
	impact_type = /obj/effect/projectile/xray/impact

	light_color = COLOR_PURPLE

/obj/item/projectile/beam/magic/life_steal/atom_init()
	color = TO_NEGATIVE_COLOR
	. = ..()

/obj/item/projectile/beam/magic/life_steal/on_hit(mob/living/target, blocked = 0)
	if(!istype(target) || target.stat == DEAD || issilicon(target))
		return

	var/dam_hit = -1.0 * power_of_spell

	if(prob(power_of_spell)) // critical hit!!
		dam_hit *= 2

	target.apply_damage(damage = -dam_hit, damagetype = OXY, used_weapon = "High power suffocant")

	if(firer && isliving(firer))
		var/mob/living/L = firer
		L.apply_damages(dam_hit, dam_hit, dam_hit, dam_hit, dam_hit, dam_hit) // zero is for brute and burn in case of restoring bodyparts, because no point to heal them, since body parts restoration does that.
		L.apply_effects(dam_hit, dam_hit, dam_hit, dam_hit, dam_hit, dam_hit, dam_hit, dam_hit)
