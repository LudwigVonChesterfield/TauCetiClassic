var/global/list/combat_combos = list()
var/global/list/combat_combos_by_name = list()

/datum/combat_combo
	var/name = "Combat_Combo" // These are used as combo_elements...
	var/desc = "A move that does combo cool stuff."
	var/fullness_lose_on_execute = 50
	var/list/combo_elements = list()

	var/list/allowed_to_mob_types = list(/mob/living)
	var/list/allowed_on_mob_types = list(/mob/living)

	var/combo_icon_state = "combo"

	var/armor_pierce = FALSE
	// If true, checks the entire body, not just targetzone.
	var/check_bodyarmor = FALSE

	// If TRUE, this combo can be performed on enemies bigger than you.
	var/ignore_size = FALSE

	// Attacker's damage are multiplied with these to determine how much
	// damage/stun should be added from their base attack.
	var/scale_damage_coeff = 0.0
	var/scale_effect_coeff = 0.0
	// Determines exponential growth of size ratio when multiplying with base damage.
	var/scale_size_exponent = 1.0

	// TOTAL FORMULA FOR STUN/DAMAGE GOES SOMETHING LIKE THIS:
	// val = (base_damage * (size_ratio ** scale_size_exponent)) + attacker.damage * scale_damage_coeff

	// Whether damage flags of unarmed attack should be applied by this combo. (Unath uppercut making a cut)
	var/apply_dam_flags = FALSE
	// If set to any value, will force damType of applied damage to be this
	var/force_dam_type

	var/list/allowed_target_zones = TARGET_ZONE_ALL
	var/require_head = FALSE
	var/require_arm = FALSE
	var/require_leg = FALSE

	var/require_head_to_perform = FALSE
	var/require_arm_to_perform = FALSE
	var/require_leg_to_perform = FALSE

	var/heavy_animation = FALSE // Determines whether we call the before_animation and after_animation procs.
	var/needs_logging = TRUE // Do we need to PM admins about this combo?

/datum/combat_combo/proc/get_hash()
	. = list()
	for(var/TZ in allowed_target_zones)
		var/cur_hash = "[TZ]|"
		for(var/CE in combo_elements)
			cur_hash += "[CE]#"
		. += cur_hash

/datum/combat_combo/proc/can_execute(datum/combo_saved/CS, show_warning = FALSE)
	if(heavy_animation)
		if(CS.attacker.pinned.len)
			if(show_warning)
				to_chat(CS.attacker, "<span class='notice'>Can't perform <b>[name]</b> because you are pinned to a wall.</span>")
			return FALSE
		if(CS.victim.pinned.len)
			if(show_warning)
				to_chat(CS.attacker, "<span class='notice'>Can't perform <b>[name]</b> because they are pinned to a wall.</span>")
			return FALSE
		if(CS.attacker.anchored || !CS.attacker.canmove)
			if(show_warning)
				to_chat(CS.attacker, "<span class='notice'>Can't perform <b>[name]</b> while not being able to move.</span>")
			return FALSE

	if(CS.attacker.incapacitated())
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>Can't perform <b>[name]</b> while being incapacitated.</span>")
		return FALSE
	if(CS.attacker.is_busy(CS.victim, show_warning))
		return FALSE
	if(CS.attacker.attack_animation || CS.attacker.combo_animation)
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>Can't perform <b>[name]</b> while performing something else.</span>")
		return FALSE
	if(CS.victim.attack_animation || CS.victim.combo_animation)
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>Can't perform <b>[name]</b> while [CS.victim] is performing something.</span>")
		return FALSE
	if(!ignore_size && CS.victim.is_bigger_than(CS.attacker))
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>[CS.victim] is too big for you to perform <b>[name]</b> on them.</span>")
		return FALSE
	if(CS.fullness < fullness_lose_on_execute)
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>You don't have enough combopoints for <b>[name]</b>.</span>")
		return FALSE

	if(!is_type_in_list(CS.attacker, allowed_to_mob_types))
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>You can't perform <b>[name]</b>.</span>")
		return FALSE
	if(!is_type_in_list(CS.victim, allowed_on_mob_types))
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>You can't perform <b>[name]</b> on [CS.victim].</span>")
		return FALSE

	var/target_zone = CS.attacker.get_targetzone()

	if(!(target_zone in allowed_target_zones))
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>You can't perform <b>[name]</b> on [CS.victim]'s [parse_zone(target_zone)].</span>")
		return FALSE

	if(require_head && !CS.victim.has_bodypart(target_zone))
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>You can't perform <b>[name]</b> on [CS.victim], since they don't have a head...</span>")
		return FALSE
	if(require_arm && !CS.victim.has_bodypart(target_zone))
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>You can't perform <b>[name]</b> on [CS.victim], since they don't have an arm...</span>")
		return FALSE
	if(require_leg && !CS.victim.has_bodypart(target_zone))
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>You can't perform <b>[name]</b> on [CS.victim], since they don't have a leg...</span>")
		return FALSE

	if(require_head_to_perform && !CS.attacker.is_usable_head())
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>You can't perform <b>[name]</b>, since you don't have a head...</span>")
		return FALSE

	if(require_arm_to_perform && !CS.attacker.is_usable_arm(CS.attacker.hand ? BP_L_ARM : BP_R_ARM))
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>You can't perform <b>[name]</b>, since you don't have an arm...</span>")
		return FALSE

	if(require_leg_to_perform && !CS.attacker.is_usable_leg())
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>You can't perform <b>[name]</b>, since you don't have a leg...</span>")
		return FALSE

	return TRUE

// This proc scales damage/stun based on size/damage/whatever relevant to this combo.
// base_dam - base damage to scale. min_value - how much damage should there be for it to be applied in the first place(if set to -1, ignores this arg)
// Returns TRUE if damage was dealt.
/datum/combat_combo/proc/apply_damage(base_dam, mob/living/victim, mob/living/attacker, zone = null, min_value = -1)
	var/val = base_dam
	if(scale_size_exponent != 0.0)
		val *= get_size_ratio(attacker, victim) ** scale_size_exponent

	var/list/attack_obj = attacker.get_unarmed_attack()
	val += attack_obj["damage"] * scale_damage_coeff

	if(min_value < 0 || val >= min_value)
		var/armor_check = 0
		if(!armor_pierce)
			armor_check = victim.run_armor_check(check_bodyarmor ? null : zone, "melee")
		return victim.apply_damage(val, force_dam_type ? force_dam_type : attack_obj["type"],
			def_zone = zone,
			blocked = armor_check,
			damage_flags = apply_dam_flags ? attack_obj["flags"] : 0,
			used_weapon = name
		)
	return FALSE

// effect - effect to apply, duration - base duration to scale. min_value - how much damage should there be for it to be applied in the first place(if set to -1, ignores this arg)
// Returns TRUE if effect was applied.
/datum/combat_combo/proc/apply_effect(duration, effect, mob/living/victim, mob/living/attacker, min_value = -1)
	var/val = duration
	if(scale_size_exponent != 0.0)
		val *= get_size_ratio(attacker, victim) ** scale_size_exponent

	var/list/attack_obj = attacker.get_unarmed_attack()
	val += attack_obj["damage"] * scale_effect_coeff

	to_chat(attacker, "YOU DEALT [val] OUT OF [min_value] DAMAGE")
	if(min_value < 0 || val >= min_value)
		var/armor_check = 0
		if(!armor_pierce)
			armor_check = victim.run_armor_check(check_bodyarmor ? null : attacker.get_targetzone(), "melee")
		return victim.apply_effect(duration, effect, blocked = armor_check)
	return FALSE

/datum/combat_combo/proc/do_combo(mob/living/victim, mob/living/attacker, delay)
	var/endtime = world.time + delay
	while(world.time < endtime)
		stoplag()
		if(QDELING(victim))
			return FALSE
		if(QDELING(attacker))
			return FALSE
		if(victim.notransform || attacker.notransform)
			return FALSE
		if(!attacker.combo_animation)
			return FALSE
		if(additional_checks(victim, attacker))
			return FALSE
	return TRUE

/datum/combat_combo/proc/additional_checks(mob/living/victim, mob/living/attacker)
	return FALSE

/datum/combat_combo/proc/get_combo_icon()
	var/image/I = image(icon='icons/mob/unarmed_combat_combos.dmi', icon_state=combo_icon_state)
	I.layer = ABOVE_HUD_LAYER
	I.plane = ABOVE_HUD_PLANE
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	I.pixel_x = 16
	I.pixel_y = 16
	return I

/datum/combat_combo/proc/on_ready(mob/living/victim, mob/living/attacker)
	attacker.emote("scream")

/datum/combat_combo/proc/before_animation(mob/living/victim, mob/living/attacker)
	if(heavy_animation)
		victim.Stun(2)

		if(victim.buckled)
			victim.buckled.unbuckle_mob()
		if(attacker.buckled)
			attacker.buckled.unbuckle_mob()

		attacker.become_busy(_hand = 0)
		attacker.become_busy(_hand = 1)
		victim.in_use_action = TRUE

		attacker.combo_animation = TRUE

// Please remember, that the default animation of attack takes 3 ticks. So put at least sleep(3) here
// before anything.
/datum/combat_combo/proc/animate_combo(mob/living/victim, mob/living/attacker)
	return

// THIS SHOULD BE CALLED MANUALLY FROM ALL RETURN POINTS IN ANIMATE_COMBO
// SINCE IT IS ASYNC.
/datum/combat_combo/proc/after_animation(mob/living/victim, mob/living/attacker)
	if(heavy_animation)
		victim.transform = victim.default_transform
		victim.pixel_x = victim.default_pixel_x
		victim.pixel_y = victim.default_pixel_y
		victim.layer = victim.default_layer

		attacker.transform = attacker.default_transform
		attacker.pixel_x = attacker.default_pixel_x
		attacker.pixel_y = attacker.default_pixel_y
		attacker.layer = attacker.default_layer

		attacker.become_not_busy(_hand = 0)
		attacker.become_not_busy(_hand = 1)
		victim.in_use_action = FALSE

		attacker.combo_animation = FALSE

// This is for technical stuff, such as fingerprints leaving, admin PM.
/datum/combat_combo/proc/pre_execute(mob/living/victim, mob/living/attacker)
	attacker.attack_log += text("\[[time_stamp()]\] <font color='red'>Used [name] on [victim.name] ([victim.ckey])</font>")
	victim.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [attacker.name]'s ([attacker.ckey]) [name]</font>")

	msg_admin_attack("[key_name(attacker)] used [name] on [victim.name] ([victim.ckey])", attacker)

	victim.add_fingerprint(attacker)

/datum/combat_combo/proc/execute(mob/living/victim, mob/living/attacker)
	return
