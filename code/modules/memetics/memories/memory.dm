/datum/meme/memory
	category = MEME_CATEGORY_MEMORY

	hidden = FALSE
	can_forget = TRUE

	stack_type = MEME_STACK_KEEP_BOTH

	// A message displayed to player when they gain the memory.
	var/gain_txt
	// A message displayed to player when they lose the memory.
	var/lose_txt

	// Possible strings of text shown to player when they try to remember the memory and fail.
	var/list/forgetting_txts

	// Memory can be degraded by brainLoss, head trauma.
	var/list/reliabilities = list()
	var/list/display_name = list()

/datum/meme/memory/get_name(mob/user)
	var/dis_name = name
	if(ismob(user))
		dis_name = display_name[user]
		var/star_coeff = 100 - reliabilities[user]
		if(star_coeff > 0)
			dis_name = stars(dis_name, star_coeff)
	return dis_name

/datum/meme/memory/on_attach(atom/host, reliability=100)
	. = ..()
	if(. && ismob(host))
		if(gain_txt)
			to_chat(host, "<span class='notice'>[gain_txt]</span>")

		reliabilities[host] = reliability

		var/dis_name = name
		if(host.stacked_memes && host.stacked_memes[stack_id])
			dis_name += " #[length(host.stacked_memes[stack_id])]"

		display_name[host] = dis_name

/datum/meme/memory/on_detach(atom/old_host)
	if(ismob(old_host))
		if(lose_txt)
			to_chat(host, "<span class='warning'>[lose_txt]</span>")
		reliabilities -= old_host
		display_name -= old_host
	..()

/datum/meme/memory/on_pass(atom/host, atom/new_host)
	if(ismob(host) && ismob(new_host))
		reliabilities[new_host] = reliabilities[host]
		display_name[new_host] = display_name[host]

/datum/meme/memory/affect(atom/host, atom/A)
	if(ismob(A))
		host.pass_memes(A, list(id))

/datum/meme/memory/proc/get_forgetting_txt()
	return pick(forgetting_txts)

/datum/meme/memory/proc/adjustReliability(mob/host, value)
	reliabilities[host] += value
	if(reliabilities[host] <= 0)
		host.remove_meme(id)

/datum/meme/memory/proc/try_remember(mob/user)
	if(prob(reliabilities[user]))
		return TRUE

	to_chat(user, "<span class='warning'>[get_forgetting_txt()]</span>")
	adjustReliability(user, -10)
	return FALSE



/mob
	// The list of memories that are actively remembered.
	var/list/active_memes

/*
 * HELPER PROCS
 */
/mob/proc/forget_memories(value)
	var/list/memories = list()
	for(var/meme_id in attached_memes)
		var/datum/meme/M = attached_memes[meme_id]
		if(istype(M, /datum/meme/memory))
			memories += M

	if(!memories.len)
		return

	while(value > 0)
		var/datum/meme/memory/M = pick(memories)
		var/adjust_val = pick(0, M.reliabilities[src])

		M.adjustReliability(src, -adjust_val)

		value -= adjust_val
