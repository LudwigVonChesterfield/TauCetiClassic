/datum/meme/memory
	category = MEME_CATEGORY_MEMORY

	hidden = FALSE
	can_forget = TRUE

	stack_type = MEME_STACK_KEEP_BOTH

	var/gain_txt
	var/lose_txt

	// Memory can be degraded by brainLoss, head trauma.
	var/list/reliabilities = list()

/datum/meme/memory/on_attach(atom/host, reliability=100)
	. = ..()
	if(. && ismob(host))
		if(gain_txt)
			to_chat(host, "<span class='notice'>[gain_txt]</span>")
		reliabilities[host] = reliability

/datum/meme/memory/on_detach(atom/old_host)
	if(ismob(old_host))
		if(lose_txt)
			to_chat(host, "<span class='warning'>[lose_txt]</span>")
		reliabilities -= old_host
	..()

/datum/meme/memory/affect(atom/host, atom/A)
	. = ..()
	if(ismob(A))
		on_attach(A)
