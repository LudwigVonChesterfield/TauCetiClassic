/datum/combat_combo/wake_up
	name = COMBO_WAKE_UP
	desc = "A move in which you pull your opponent up, shaking off all his pain and stuns."
	combo_icon_state = "spin_throw"
	fullness_lose_on_execute = 20
	combo_elements = list(INTENT_HELP, INTENT_HELP, INTENT_HELP, INTENT_GRAB)

	allowed_target_zones = list(BP_CHEST)

	heavy_animation = TRUE

	// How much time does each shake take.
	var/shake_delay = 1
	var/delay_offset = 1
	// How many shakes should be performed.
	var/total_shakes = 16

	// How much "stuns" should go away per tick spent shaking.
	var/effectiveness = 1.5

/datum/combat_combo/wake_up/animate_combo(mob/living/victim, mob/living/attacker)
	var/list/attack_obj = attacker.get_unarmed_attack()

	var/obj/item/weapon/grab/victim_G = prepare_grab(victim, attacker, GRAB_PASSIVE)
	if(!istype(victim_G))
		return

	var/started_shaking = world.time

	victim.forceMove(attacker.loc)

	attacker.visible_message("<span class='notice'>[attacker] is shaking [victim] with visible force!</span>")

	if(victim.lying)
		var/matrix/M = matrix(victim.transform)
		M.Turn(-victim.lying_current)
		victim.transform = M

	attacker.set_dir(pick(list(WEST, EAST)))
	victim.set_dir(turn(attacker.dir, 180))
	for(var/shake_num in 1 to total_shakes)
		if(QDELETED(victim_G))
			return

		var/delay = shake_delay + rand(-delay_offset, delay_offset)
		// replace 1 with delay when Stun( will be reworked. ~Luduk
		victim.Stun(1)

		victim_G.adjust_position(adjust_time = 0, force_loc = TRUE, force_dir = turn(attacker.dir, 180))
		// Currently grab position adjusting changes your pixel_y to 0.
		victim.pixel_y += 4

		var/shake_degree = min(scale_value(15, scale_damage_coeff, victim, attacker, attack_obj), 30)
		var/max_shake_height = min(scale_value(4, scale_damage_coeff, victim, attacker, attack_obj), 8)

		var/matrix/prev_transform = matrix(victim.transform)
		var/prev_pixel_y = victim.pixel_y

		var/matrix/prev_attacker_transform = matrix(attacker.transform)
		var/shake_attacker = (prob(0))

		var/matrix/M_attacker = matrix(attacker.transform)
		if(shake_attacker)
			M_attacker.Turn(pick(-shake_degree * 0.5, shake_degree * 0.5))

		var/matrix/M = matrix(victim.transform)
		M.Turn(pick(-shake_degree, shake_degree))

		var/shake_height = rand(0, max_shake_height)

		animate(victim, transform = M, pixel_y = victim.pixel_y + shake_height, time = delay)
		if(shake_attacker)
			animate(attacker, transform = M_attacker, time = delay * pick(0.6, 0.8, 1.0))

		if(!do_after(attacker, shake_delay, target = victim, progress = FALSE, extra_checks = CALLBACK(src, .proc/continue_checks)))
			return

		animate(victim, transform = prev_transform, pixel_y = prev_pixel_y, time = 1)
		if(shake_attacker)
			animate(attacker, transform = prev_attacker_transform, time = 1)
		if(!do_after(attacker, 1, target = victim, progress = FALSE, extra_checks = CALLBACK(src, .proc/continue_checks)))
			return

	var/shake_time = world.time - started_shaking

	var/wake_up_amount = -shake_time * effectiveness

	victim.adjustHalLoss(wake_up_amount)
	victim.AdjustStunned(wake_up_amount)
	victim.AdjustWeakened(wake_up_amount)

	step_away(victim, attacker)

	destroy_grabs(victim, attacker)

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/wake_up/execute(mob/living/victim, mob/living/attacker)
	return
