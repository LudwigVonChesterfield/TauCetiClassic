/mob
	var/datum/browser/memes/my_memes

/mob/verb/manage_memes()
	set name = "Manage Memes"
	set desc = "Gaze upon the deepest corners of thy mind to see thy everything. The thoughts, the memories, the mind itself, the \"you\"."
	set category = "IC"

	if(!my_memes)
		my_memes = new(src, "my_memes", "Fortress of the Mind", 800, 600)

	my_memes.open()

/datum/asset/simple/memes
	assets = list(
		"memetic1.jpg" = 'html/prefs/memetic1.jpg',
		"memetic2.jpg" = 'html/prefs/memetic2.jpg',
		"memetic3.jpg" = 'html/prefs/memetic3.jpg',
		"uiMaskBackground.png" = 'nano/images/uiMaskBackground.png',
		"header1.jpg" = 'html/prefs/header1.jpg'
	)

/datum/browser/memes
	var/selected_meme_category = ""
	var/selected_meme_block
	var/search_meme = ""

/datum/browser/memes/New(nuser, nwindow_id, ntitle = 0, nwidth = 0, nheight = 0, atom/nref, ntheme)
	..()
	add_stylesheet("memetic", 'html/browser/memetic.css')
	RegisterSignal(nuser, list(COMSIG_MEME_ADDED, COMSIG_MEME_REMOVED), .proc/update)
	update()

/datum/browser/memes/proc/can_use()
	if(isliving(user) && user.stat == DEAD)
		return FALSE
	return TRUE

/datum/browser/memes/proc/update()
	var/dat = ""
	dat += "<div class=\"memeticCategoriesContainer\"><table><tr>"
	for(var/category in user.browseable_memes)//We scroll through the categories and check each meme for visibility, if at least one is visible, then the category is displayed
		var/hidden = TRUE
		for(var/datum/meme/M in user.browseable_memes[category])
			if(!M.hidden)
				hidden = FALSE
				break
		if(!hidden)
			var/selected = category==selected_meme_category ? "" : "-notSelected"
			dat += "<td style=\"padding:0px;\"><A class=\"memeticCategorySelected[selected]\" href='?src=\ref[src];action=select_category;category=[category]'><b>[category]</b></A></td>"
	dat += "</tr></table></div>"
	dat += "<div class=\"memeticCategoryContainer memeticType-[selected_meme_category]\">"
	dat += "<A class=\"memeticButton memeticType-[selected_meme_category]\" href='?src=\ref[src];action=search;'>Search:</A> [search_meme] <A class=\"memeticButton memeticType-[selected_meme_category]\" href='?src=\ref[src];action=search;reset=1'>Reset</A>"
	for(var/datum/meme/M in user.browseable_memes[selected_meme_category])//We scroll through the memes from the selected category and check the possibility of their display, and the available functionality
		if(findtext(M.name, search_meme) && !M.hidden)
			var/selected = ""
			if(selected_meme_block && M.id == selected_meme_block)//If the meme is highlighted, then it stands out among all the others using the frame
				selected = "memeticTypeSelected-[selected_meme_category]"
			dat += "<div class=\"memeticItem [selected_meme_category] memeticType-[selected_meme_category] [selected]\">"
			dat += "<table width=\"100%\">"
			dat += "<tr>"
			dat += "<hr><td style=\"line-height:30px;\" width=\"75%\" onclick=\"location.href='?src=\ref[src];action=more_info;block=[M.id]';\">Name: <A class=\"memeticButton\" href='?src=\ref[src];action=set_name;meme=[M.id]'><b>[M.name]</b></A></td>"
			dat += "<td onclick=\"location.href='?src=\ref[src];action=more_info;block=[M.id]';\">[M.desc]</td>"
			dat += "</tr>"
			if(selected_meme_block && M.id == selected_meme_block)
				dat += "<tr>"
				dat += "<td width=\"75%\" onclick=\"location.href='?src=\ref[src];action=more_info;block=null';\">[M.long_desc]</td>"
				dat += "<td style=\"line-height:30px;\" onclick=\"location.href='?src=\ref[src];action=more_info;block=null';\">"
				for(var/flag in M.flags)//We scroll through the flags of the meme, to check the functionality, here it is very flexible for configuration, an important place for the encoder
					var/text = flag == MEME_SPREAD_VERBALLY ? "Pass meme verbally" : flag == MEME_SPREAD_READING ? "Write a meme on paper" : ""
					if(flag == MEME_SPREAD_VERBALLY || flag == MEME_SPREAD_READING)
						dat += "<A class=\"memeticButton memeticType-[selected_meme_category]\" href='?src=\ref[src];action=meme_action;type_action=[flag]'>[text]</A><br>"
				if(M.can_forget)		
					dat += "<A class=\"memeticButton memeticType-[selected_meme_category]\" href='?src=\ref[src];action=meme_action;type_action=\"Forget\"'>Forget meme</A><br>"
				dat += "</td>"
				dat += "</tr>"
			dat += "</table>"
			dat += "</div>"
	dat += "</div>"
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/memes)
	assets.send(user)
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
		if("more_info")
			selected_meme_block = href_list["block"]
			needs_update = TRUE
		if("set_name")
			for(var/datum/meme/M in user.browseable_memes[selected_meme_category])
				if(href_list["meme"] == M.id)
					var/name = sanitize_safe(input(user, "Pick a name","Name", M.name) as null|text, 25)
					if(name != "")
						M.name = name
					break
			needs_update = TRUE
		if("search")
			if(href_list["reset"])
				search_meme = ""
			else
				search_meme = sanitize_safe(input(user, "Search","Name") as null|text, 25)
			needs_update = TRUE
		if("meme_action")
			switch(href_list["type_action"])
				if(MEME_SPREAD_READING)
					needs_update = TRUE
				if(MEME_SPREAD_VERBALLY)
					needs_update = TRUE
				if("Forget")
					needs_update = TRUE

	if(needs_update)
		update()
