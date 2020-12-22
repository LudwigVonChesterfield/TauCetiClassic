/mob/living
	var/list/tackle_degree_to_move

/mob/living/proc/perform_tackle(mob/living/target)
	if(!tackle_degree_to_move)
		to_chat(world, "IMPROPER SETUP. CALLING TACKLE WITHOUT SETTING TACKLE DEGREE MOVE LIST.")
		return

	var/degree = 0

	var/armor_attacker = getarmor(null, "melee")
	var/armor_victim = getarmor(null, "melee")

	degree = round((armor_attacker - armor_victim) * 0.1)

	degree = CLAMP(degree, 0, tackle_degree_to_move.len - 1)

	var/move = tackle_degree_to_move[degree]

	to_chat(world, "TACKLE DEGREE IS [degree]")

/mob/living/proc/react_to_tackle(mob/living/assailant)

