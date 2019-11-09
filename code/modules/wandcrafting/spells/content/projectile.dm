/obj/item/spell/projectile
	category = "Projectile"

	var/projectile_type = /obj/item/projectile

	spell_components_slots = 1
	compatible_flags = list(
		WAND_SPELL_TRIGGER_ON_IMPACT = TRUE,
		WAND_SPELL_TRIGGER_ON_STEP = TRUE,
		WAND_SPELL_TIMER = TRUE,
		)

	on_trigger_cast_type = WAND_COMP_OTHERSCAST
	timer_before_cast = FALSE

/obj/item/spell/projectile/proc/get_proj_type()
	return projectile_type

/obj/item/spell/projectile/proc/process_projectile(obj/item/projectile/P, obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	issue_event(WAND_SPELL_TIMER, holder, P, list(target), cur_mod.get_copy(), next_mod.get_copy())

	if(spell_flags[WAND_SPELL_TRIGGER_ON_IMPACT])
		P.on_impact_callback = CALLBACK(src, /obj/item/spell.proc/issue_event, WAND_SPELL_TRIGGER_ON_IMPACT, holder, P, list(target), cur_mod.get_copy(), next_mod.get_copy())
	if(spell_flags[WAND_SPELL_TRIGGER_ON_STEP])
		P.on_step_callback = CALLBACK(src, /obj/item/spell.proc/issue_event, WAND_SPELL_TRIGGER_ON_STEP, holder, P, list(target), cur_mod.get_copy(), next_mod.get_copy())

/obj/item/spell/projectile/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	var/mob/caster = get_caster(casting_obj)

	if(caster)
		var/proj_type = get_proj_type()
		var/obj/item/projectile/P = new proj_type(isturf(casting_obj) ? casting_obj : casting_obj.loc, 1.0 * cur_mod.mult_power + cur_mod.add_power)
		process_projectile(P, holder, casting_obj, target, cur_mod, next_mod)

		P.damage += cur_mod.add_power
		P.damage *= cur_mod.mult_power
		P.Fire(target, caster)



/obj/item/spell/projectile/fireball
	name = "fireball spell"
	desc = "This spell fires a fireball that flies to the target."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "fireball"

	projectile_type = /obj/item/projectile/magic/fireball

	mana_cost = 20
	additional_delay = 1

/obj/item/spell/projectile/fireball/trigger
	spawn_with_component_types = list(/obj/item/spell/spell_component/trigger/impact)
	can_be_crafted = FALSE



/obj/item/spell/projectile/tesla
	name = "lightning bolt spell"
	desc = "Fire a high powered lightning bolt at your foes!"

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "lightning"

	projectile_type =  /obj/item/projectile/magic/lightning

	mana_cost = 30
	additional_delay = 2

/obj/item/spell/projectile/tesla/trigger
	spawn_with_component_types = list(/obj/item/spell/spell_component/trigger/impact)
	can_be_crafted = FALSE



/obj/item/spell/projectile/meteor
	name = "meteor spell"
	desc = "Summon a meteor flying into thy enemies!"

	spell_icon = 'icons/obj/meteor.dmi'
	spell_icon_state = "smallf"

	projectile_type =  /obj/item/projectile/meteor

	mana_cost = 50
	additional_delay = 3



/obj/item/spell/projectile/arcane_barrage
	name = "arcane barrage spell"
	desc = "Fire a torrent of arcane energy at your foes with this  spell."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "arcane_barrage"

	projectile_type =  /obj/item/projectile/magic/Arcane_barrage

	mana_cost = 10
	additional_delay = -1

/obj/item/spell/projectile/arcane_barrage/trigger
	spawn_with_component_types = list(/obj/item/spell/spell_component/trigger/impact)
	can_be_crafted = FALSE



/obj/item/spell/projectile/bullet
	name = "summon bullet spell"
	desc = "It's like summoning an arrow, but on a whole other level."

	spell_icon = 'icons/obj/ammo.dmi'
	spell_icon_state = "357"

	projectile_type =  /obj/item/projectile/bullet/weakbullet

	mana_cost = 5
	additional_delay = 0

/obj/item/spell/projectile/bullet/get_proj_type()
	return pick(subtypesof(/obj/item/projectile/bullet))



/obj/item/spell/projectile/muh_lazur
	name = "muh lazur spell"
	desc = "Prepare to be FIRIN' DAH LAZUH."

	spell_icon = 'icons/obj/projectiles.dmi'
	spell_icon_state = "heavylaser"

	projectile_type =  /obj/item/projectile/beam/magic/muh_lazur

	mana_cost = 2
	additional_delay = 0

/obj/item/spell/projectile/muh_lazur/trigger
	spawn_with_component_types = list(/obj/item/spell/spell_component/trigger/impact)
	can_be_crafted = FALSE



/obj/item/spell/projectile/teleport
	name = "teleport spell"
	desc = "Shoot out a little contained bluespace anomaly to transport."

	spell_icon = 'icons/obj/projectiles.dmi'
	spell_icon_state = "bluespace"

	projectile_type =  /obj/item/projectile/magic/teleport

	mana_cost = 20
	additional_delay = 2



/obj/item/spell/projectile/heal_ball
	name = "healing ball spell"
	desc = "Throw a healing ball, healing stuff."

	spell_icon = 'icons/obj/wizard.dmi'
	spell_icon_state = "heal_7"

	projectile_type = /obj/item/projectile/magic/healing_ball

	mana_cost = 20
	additional_delay = 2

/obj/item/spell/projectile/heal_ball/trigger
	spawn_with_component_types = list(/obj/item/spell/spell_component/trigger/impact)
	can_be_crafted = FALSE



/obj/item/spell/projectile/healing_beam
	name = "healing beam spell"
	desc = "Shoot out a healing beam."

	spell_icon = 'icons/obj/projectiles.dmi'
	spell_icon_state = "xray"

	projectile_type =  /obj/item/projectile/beam/magic/healing

	mana_cost = 2
	additional_delay = 0

/obj/item/spell/projectile/healing_beam/trigger
	spawn_with_component_types = list(/obj/item/spell/spell_component/trigger/impact)
	can_be_crafted = FALSE



/obj/item/spell/projectile/life_steal_beam
	name = "life-steal spell"
	desc = "Shoot out a life-stealing beam."

	spell_icon = 'icons/obj/projectiles.dmi'
	spell_icon_state = "xray"

	projectile_type =  /obj/item/projectile/beam/magic/life_steal

	mana_cost = 3
	additional_delay = 1

/obj/item/spell/projectile/life_steal_beam/trigger
	spawn_with_component_types = list(/obj/item/spell/spell_component/trigger/impact)
	can_be_crafted = FALSE
