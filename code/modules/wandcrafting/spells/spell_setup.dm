/datum/spell_setup_entry
	var/name = "Entry Name"
	var/desc = ""
	var/category = "Technical"

	var/setup_word = "Set"

/datum/spell_setup_entry/proc/can_setup(mob/user, obj/item/spell/holder)
	return TRUE

/datum/spell_setup_entry/proc/on_setup(mob/user, obj/item/spell/holder, option)
	return

/datum/spell_setup_entry/proc/get_setup_line(mob/user, obj/item/spell/holder, i)
	return "<a href='?src=\ref[holder];setup=[i]'>[setup_word]</a><br>"

/datum/spell_setup_entry/proc/get_info()
	var/dat =""
	dat += "<b>[name]</b><br>"
	dat += "<i>[desc]</i><br>"
	return dat



/obj/item/spell
	var/list/spawn_entries_types = list()

	var/tab = null
	var/list/entries = list()
	var/list/categories = list()

/obj/item/spell/react_to_enchantment(obj/item/weapon/wand/holder, obj/item/spell/enchanting_with)
	if(isliving(holder.loc) && categories.len > 0)
		var/mob/living/user = holder.loc
		browse_setup_ui(user)

/obj/item/spell/proc/init_setup_ui()
	for(var/entry_type in spawn_entries_types)
		var/datum/spellbook_entry/E = new entry_type

		entries += E
		categories |= E.category
	if(categories.len > 0)
		tab = categories[1]

/obj/item/spell/proc/setup_ui_wrap(content)
	var/dat = ""
	dat +="<html><head><title>[name]</title></head>"
	dat += {"
	<head>
		<style type="text/css">
      		body { font-size: 80%; font-family: 'Lucida Grande', Verdana, Arial, Sans-Serif; }
      		ul#tabs { list-style-type: none; margin: 30px 0 0 0; padding: 0 0 0.3em 0; }
      		ul#tabs li { display: inline; }
      		ul#tabs li a { color: #42454a; background-color: #dedbde; border: 1px solid #c9c3ba; border-bottom: none; padding: 0.3em; text-decoration: none; }
      		ul#tabs li a:hover { background-color: #f1f0ee; }
      		ul#tabs li a.selected { color: #000; background-color: #f1f0ee; font-weight: bold; padding: 0.7em 0.3em 0.38em 0.3em; }
      		div.tabContent { border: 1px solid #c9c3ba; padding: 0.5em; background-color: #f1f0ee; }
      		div.tabContent.hide { display: none; }
    	</style>
  	</head>
	"}
	dat += {"[content]</body></html>"}
	return dat

/obj/item/spell/proc/get_category_header(category)
	var/dat = ""
	switch(category)
		if("Technical")
			dat += "Spells configurations that do not directly influence anything, but have a huge implication.<BR><BR>"
	return dat

/obj/item/spell/proc/get_setup_ui(mob/user)
	var/dat = ""

	dat += "<ul id=\"tabs\">"
	var/list/cat_dat = list()
	for(var/category in categories)
		cat_dat[category] = "<hr>"
		dat += "<li><a [tab == category ? "class=selected" : ""] href='?src=\ref[src];page=[category]'>[category]</a></li>"

	dat += "<li><a><b>Components installed: [spell_components.len]/[spell_components_slots]</b></a></li>"
	dat += "</ul>"

	for(var/i in 1 to entries.len)
		var/datum/spell_setup_entry/SSE = entries[i]
		var/spell_info = ""
		spell_info += SSE.get_info()
		if(SSE.can_setup(user, src))
			spell_info += SSE.get_setup_line(user, src, i)
		else
			spell_info += "<span>Can't [SSE.setup_word]</span><br>"

		spell_info += "<hr>"
		if(cat_dat[SSE.category])
			cat_dat[SSE.category] += spell_info

	for(var/category in categories)
		dat += "<div class=\"[tab == category ? "tabContent" : "tabContent hide"]\" id=\"[category]\">"
		dat += get_category_header(category)
		dat += cat_dat[category]
		dat += "</div>"

	return dat

/obj/item/spell/proc/browse_setup_ui(mob/user)
	user.set_machine(src)
	var/dat = setup_ui_wrap(get_setup_ui(user))
	user << browse(dat, "window=[name];size=700x500")
	onclose(user, "spellbook")

/obj/item/spell/Topic(href, href_list)
	..()
	var/mob/living/L = usr
	if(!istype(L) || L.incapacitated())
		return

	var/datum/spell_setup_entry/SSE
	if(loc == L || (in_range(src, L) && isturf(loc)))
		L.set_machine(src)
		if(href_list["setup"])
			SSE = entries[text2num(href_list["setup"])]
			to_chat(world, "[text2num(href_list["setup"])] [entries[text2num(href_list["setup"])]]")
			if(SSE && SSE.can_setup(L, src))
				SSE.on_setup(L, src, href_list["option"])
			browse_setup_ui(L)
		else if(href_list["page"])
			tab = sanitize(href_list["page"])
			browse_setup_ui(L)
