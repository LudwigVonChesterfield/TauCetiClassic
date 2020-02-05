var/global/datum/meme/list/memes_by_id = list()

/proc/populate_meme_list()
	for(var/meme_type in subtypesof(/datum/meme))
		var/datum/meme/M = new meme_type
		global.memes_by_id[M.id] = M

	for(var/obj/machinery/message_server/server in message_servers)
		if(!isnull(server) && !isnull(server.decryptkey))
			create_meme(/datum/meme/memory/PDA_password, "PDA_password_" + server.decryptkey)



/datum/meme
	var/name
	var/desc

	// The unique ID of this very meme. No two memes share it.
	var/id
	// The ID used to determine whether two memes should somehow collide/stack over a spot.
	var/stack_id

	var/stack_type = MEME_STACK_KEEP_NEW

	var/list/atom/hosts

	var/list/flags = list()

	var/category = MEME_CATEGORY_MEME

	// Whether the mob infected with this meme
	// can know, and interact with it.
	var/hidden = TRUE
	// Whether the mob can voluntarily forget this meme.
	var/can_forget = FALSE

	// Some memes should cease existing if there are no hosts
	// of them.
	var/destroy_on_no_hosts = FALSE

/datum/meme/Destroy()
	var/list/prev_hosts = hosts.Copy()
	for(var/atom/old_host in prev_hosts)
		on_detach(old_host)

	global.memes_by_id -= id

	hosts = null
	return ..()

// Here we register Signals, and perhaps add some visual cues
// the the atom is a carrier of a meme.
/datum/meme/proc/on_attach(atom/host, ...)
	if(!host)
		return FALSE

	LAZYADD(hosts, host)

	if(!host.attached_memes)
		host.attached_memes = list()
	host.attached_memes[id] = src

	if(ismob(host) && !hidden)
		var/mob/M = host
		LAZYADD(M.browseable_memes, src)

	if(flags[MEME_SPREAD_INSPECTION])
		RegisterSignal(host, list(COMSIG_PRE_EXAMINE), .proc/affect)
	if(flags[MEME_SPREAD_READING])
		RegisterSignal(host, list(COMSIG_PAPER_READ), .proc/affect)

	return TRUE

// Here we unregister Signals,
// remove the visual cues, and perhaps say something
// to the thing we attached to(if it's a mob).
/datum/meme/proc/on_detach(atom/old_host)
	LAZYREMOVE(hosts, old_host)
	old_host.attached_memes -= id
	if(!old_host.attached_memes.len)
		old_host.attached_memes = null

	if(old_host.stacked_memes && old_host.stacked_memes[stack_id])
		old_host.stacked_memes[stack_id] -= src
		if(!length(old_host.stacked_memes[stack_id]))
			old_host.stacked_memes -= stack_id
		if(!old_host.stacked_memes.len)
			old_host.stacked_memes = null

	if(ismob(old_host) && !hidden)
		var/mob/M = host
		LAZYREMOVE(M.browseable_memes, src)

	if(flags[MEME_SPREAD_INSPECTION])
		UnregisterSignal(host, list(COMSIG_PRE_EXAMINE))

	if(!QDELING(src) && destroy_on_no_hosts && !hosts)
		qdel(src)

// How we react to a new meme with same stack_id.
/datum/meme/proc/on_stack(datum/meme/other_meme)
	qdel(other_meme)

// How the meme affects the thing that
// perceived it, or is spreading it.
/datum/meme/proc/affect(atom/host, atom/A)
	to_chat(world,  "[src] infects ([A]) via [host]")
	. = NONE
	if(flags[MEME_PREVENT_INSPECTION])
		. |= COMPONENT_CANCEL_EXAMINE
	if(flags[MEME_STAR_TEXT])
		. |= COMPONENT_STAR_TEXT

// How is this meme displayed in text, such as
// in speech, on paper, etc.
/datum/meme/proc/get_meme_text()
	return "<span style='color: #ffffff; background-color: #341c3a'>[name]</span>"


/atom
	// All the memes that this object carries.
	var/list/attached_memes
	var/list/stacked_memes

/mob
	// The memes that this mob can view.
	var/list/browseable_memes

/*
	HELPER PROCS
*/
/proc/create_meme(meme_type, meme_id)
	if(global.memes_by_id[meme_id])
		return global.memes_by_id[meme_id]

	var/datum/meme/M = new meme_type
	M.id = meme_id
	global.memes_by_id[M.id] = M

	return M

/atom/proc/attach_meme(meme_id, ...)
	var/datum/meme/M = global.memes_by_id[meme_id]
	if(!M)
		return null

	if(stacked_memes && stacked_memes[M.stack_id])
		var/list/to_check = stacked_memes[M.stack_id].Copy()
		for(var/datum/meme/stack_meme in to_check)
			switch(stack_meme.stack_type)
				if(MEME_STACK_KEEP_OLD)
					stack_meme.on_stack(M)
					return stack_meme

				if(MEME_STACK_KEEP_NEW)
					M.on_stack(stack_meme)

	else
		var/list/to_check = attached_memes.Copy()
		for(var/datum/meme/other_meme in to_check)
			if(M.stack_id == other_meme.stack_id)
				switch(other_meme.stack_type)
					if(MEME_STACK_KEEP_OLD)
						other_meme.on_stack(M)
						return other_meme

					if(MEME_STACK_KEEP_NEW)
						M.on_stack(other_meme)

					if(MEME_STACK_KEEP_BOTH)
						if(!stacked_memes)
							stacked_memes = list()
						if(!stacked_memes[M.stack_id])
							stacked_memes[M.stack_id] = list()
						stacked_memes[M.stack_id] += M
						stacked_memes[M.stack_id] += other_meme

	var/list/arguments = args.Copy()
	arguments[1] = src

	M.on_attach(arglist(arguments))
	return M

/atom/proc/remove_meme(meme_id)
	var/datum/meme/M = attached_memes[meme_id]
	if(M)
		M.on_detach(src)

/atom/proc/has_meme(meme_id)
	if(!attached_memes)
		return null
	return attached_memes[meme_id]

/atom/proc/get_stacked_memes(memes_stack_id)
	if(!attached_memes)
		return null
	return