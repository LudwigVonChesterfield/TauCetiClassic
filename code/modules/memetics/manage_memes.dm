/mob
	var/datum/browser/memes/my_memes

/mob/verb/manage_memes()
	set name = "Manage Memes"
	set desc = "Gaze upon the deepest corners of thy mind to see thy everything. The thoughts, the memories, the mind itself, the \"you\"."
	set category = "IC"

	if(!my_memes)
		my_memes = new(src, "my_memes", "Fortress of the Mind", 800, 600)

	my_memes.open()

/datum/browser/memes
	var/selected_meme_category = ""

/datum/browser/memes/New(nuser, nwindow_id, ntitle = 0, nwidth = 0, nheight = 0, atom/nref, ntheme)
	..()
	RegisterSignal(nuser, list(COMSIG_MEME_ADDED, COMSIG_MEME_REMOVED), .proc/update)
	update()

/datum/browser/memes/proc/can_use()
	if(isliving(user) && user.stat == DEAD)
		return FALSE
	return TRUE

/datum/browser/memes/proc/update()
	var/dat = "<b>Hello world!</b>"

	for(var/category in user.browseable_memes)
		for(var/datum/meme/M in user.browseable_memes[category])
			dat += "<hr>I am <b>[M.name]</b>"
			dat += "<br>\"[M.desc]\""
			dat += "<br>My category is <A href='?src=\ref[src];action=select_category;category=[category]'><i>[category]</i></A>"

	set_content(dat)
	open()

/datum/browser/memes/Topic(href, href_list)
	if(!can_use())
		return

	var/needs_update = FALSE

	switch(href_list["action"])
		if("select_category")
			selected_meme_category = href_list["category"]
			needs_update = TRUE

	if(needs_update)
		update()
