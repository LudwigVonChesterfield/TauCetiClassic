/datum/wand_spellbook_entry
	var/spell_name
	var/full_spell_name
	var/spell_desc

	var/category

	var/additional_info

	var/spell_word
	var/colorized_spell_word
	var/spell_word_unlocked = FALSE

	var/enchantment_info
	var/enchantment_info_unlocked = FALSE

/datum/wand_spellbook_entry/New(spell_type, obj/item/weapon/storage/spellbook/SB)
	var/obj/item/spell/S = new spell_type(null)
	if(!S.spell_word)
		return
	if(S.name == "this spell name doesn't exist")
		return
	if(!S.can_be_crafted)
		return
	if(!S.category)
		return

	category = S.category

	spell_name = S.name
	full_spell_name = S.full_name
	spell_desc = S.desc

	spell_word = S.spell_word

	var/rune_txt = ""
	var/i = 1
	for(var/rune in global.runes_by_spell_word[spell_word])
		rune_txt += "<font color=[global.rune_to_color[rune]]>[rune]</font>"
		if(i != global.runes_by_spell_word[spell_word].len)
			rune_txt += "`"
		i++

	colorized_spell_word = capitalize(rune_txt)

	additional_info = S.get_additional_info(SB)

/datum/wand_spellbook_entry/proc/get_info()
	var/spell_info = ""
	spell_info += "<b>Name</b>: [full_spell_name]<BR>"
	spell_info += "<b>Desc</b>: [spell_desc]<BR>"
	if(spell_word_unlocked)
		spell_info += "<b>Rune word</b>: <font color='red'><b>[colorized_spell_word]</b></font><BR>"
	else
		spell_info += "<b>Rune word</b>: <font color='red'><i>Unknown yet</i></font><BR>"
	spell_info += "<BR>"
	spell_info += additional_info

	spell_info += "<hr>"
	return spell_info



/obj/item/weapon/storage/spellbook
	name = "spellbook"
	desc = "In case of emergency: Apply to head repeatedly."
	icon_state = "kingyellow"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BOX_STORAGE

	var/list/known_spell_type_to_runes = list()
	var/list/known_letter_to_rune = list()

	var/list/spawn_entries_types = list(
		/obj/item/spell/sparks,
		/obj/item/spell/on_caster/lumos,
		/obj/item/spell/projectile/muh_lazur,
		)

	var/tab = null
	var/list/entries = list()
	var/list/entries_by_category = list()
	var/list/categories = list()

	var/list/known_types = list()
	var/list/known_spell_words = list()

	var/list/known_runes_by_letter = list(
	"OTHER" = "voita",
	"NOREPEAT" = "jada",
	"NONE" = "aleph",)

	var/chosen_spell = ""

	var/shine_on_new_spell = FALSE

/obj/item/weapon/storage/spellbook/atom_init()
	. = ..()
	init_ui()

	new /obj/item/weapon/paper/alchemic_precursor_recipe(src)
	// handle_item_insertion(APR)
	new /obj/item/weapon/reagent_containers/glass/bottle/mana_catalyst(src)
	// handle_item_insertion(MCB)

/obj/item/weapon/storage/spellbook/Destroy()
	entries = null
	QDEL_LIST_ASSOC_VAL(entries_by_category)
	return ..()

/obj/item/weapon/storage/spellbook/proc/init_ui()
	for(var/spell_type in spawn_entries_types)
		learn_spell(spell_type, reveal_rune_word=TRUE)
	shine_on_new_spell = TRUE

	if(categories.len > 0)
		tab = categories[1]

/obj/item/weapon/storage/spellbook/proc/learn_spell(spell_type, reveal_rune_word=FALSE)
	var/datum/wand_spellbook_entry/SE = new(spell_type, src)
	if(reveal_rune_word)
		if(entries[SE.full_spell_name])
			entries[SE.full_spell_name].spell_word_unlocked = TRUE
			return
		SE.spell_word_unlocked = TRUE
	if(!SE.category)
		return
	if(known_types[spell_type] && known_spell_words[SE.spell_word])
		return
	known_types[spell_type] = TRUE
	known_spell_words[SE.spell_word] = TRUE
	if(shine_on_new_spell)
		loc.visible_message("<span class='notice'>[src] [pick("shines", "shimmers", "chachings")].</span>")

	categories |= SE.category
	entries[SE.full_spell_name] = SE
	if(entries_by_category[SE.category])
		entries_by_category[SE.category] += SE
	else
		entries_by_category[SE.category] = list(SE)

	if(reveal_rune_word)
		var/has_unique_runes = FALSE
		for(var/rune in global.runes_by_spell_word[SE.spell_word])
			if(!known_runes_by_letter[global.rune_to_letter[rune]])
				known_runes_by_letter[global.rune_to_letter[rune]] = rune
				has_unique_runes = TRUE
		if(has_unique_runes)
			known_runes_by_letter = sortList(known_runes_by_letter)

			var/known_runes = list()
			for(var/letter in known_runes_by_letter)
				known_runes += known_runes_by_letter[letter]

			for(var/spell_word in global.runes_by_spell_word)
				var/has_all_runes = TRUE
				rune_search_loop:
					for(var/rune in global.runes_by_spell_word[spell_word])
						if(!(rune in known_runes))
							has_all_runes = FALSE
							break rune_search_loop
				if(has_all_runes)
					for(var/new_spell_type in global.spell_types_by_spell_word[spell_word])
						learn_spell(new_spell_type)

/obj/item/weapon/storage/spellbook/proc/get_known_runes_txt(mob/user)
	var/dat = ""
	for(var/letter in global.letter_to_rune)
		var/rune = known_runes_by_letter[letter]
		if(rune)
			dat += "[letter] is <font color='[global.rune_to_color[rune]]'>[rune]</font><BR>"
		else
			dat += "[letter] is <font color='red'><i>Unknown yet</i></font><BR>"
	return dat

/obj/item/weapon/storage/spellbook/proc/ui_wrap(content)
	var/dat = ""
	dat += {"
	<head>
		<title>[name]</title>
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

/obj/item/weapon/storage/spellbook/proc/get_category_header(category)
	var/dat = ""
	switch(category)
		if("Runes")
			dat += "Runes and their corresponding letters that thy have uncovered.<BR>"
		if("Conjure")
			dat += "Spells that create other entities."
		if("Miscellaneous")
			dat += "Spells that can not be easily grouped into other categories due to sheer mystery,<BR>"
			dat += "and perhaps uniqueness of what they bring to the table.<BR>"
		if("Projectile")
			dat += "Spells that are projectile-based, usually the modifier influence the projectile conjured<BR>"
			dat += "by this spell."
		if("Modifier")
			dat += "Spells that do not have an influence on what's around, but on what's in, they modify whatever<BR>"
			dat += "about the next non-stackable spells in a cast.<BR>"
		if("Passive")
			dat += "Spells that do not require actions to be cast, and are cast by the wand, if possibly constantly,<BR>"
			dat += "even if it is not in thy hands.<BR>"
		if("Component")
			dat += "Spells that are a component to other spells, and sometimes can be cast on their own."
		if("Ancient")
			dat += "Spells that are so old, arcane, event ancient, that most rules applied to other spells do not apply to them.<BR>"
	return dat

/obj/item/weapon/storage/spellbook/proc/get_ui(mob/user)
	var/dat = ""

	dat += "<ul id=\"tabs\">"
	var/list/cat_dat = list()
	for(var/category in categories)
		cat_dat[category] = "<hr>"
		dat += "<li><a [tab == category ? "class=selected" : ""] href='?src=\ref[src];page=[category]'>[category] ([entries_by_category[category].len])</a></li>"

	dat += "<li><a [tab == "Runes" ? "class=selected" : ""] href='?src=\ref[src];page=Runes'>Runes known ([known_runes_by_letter.len])</a></li>"
	cat_dat["Runes"] = "<hr>" + get_known_runes_txt(user)

	if(chosen_spell != "")
		dat += "<li><font color='blue'><a [tab == chosen_spell ? "class=selected" : ""] href='?src=\ref[src];spell=[chosen_spell];action=switch_to'>[chosen_spell]</a></font></li>"
		cat_dat[chosen_spell] = "<hr>" + entries[chosen_spell].get_info()
	dat += "</ul>"

	for(var/full_spell_name in entries)
		var/datum/wand_spellbook_entry/SE = entries[full_spell_name]
		cat_dat[SE.category] += "<a href='?src=\ref[src];spell=[SE.full_spell_name];action=switch_to'>[SE.full_spell_name]</a><HR>"

	for(var/category in categories)
		dat += "<div class=\"[tab == category ? "tabContent" : "tabContent hide"]\" id=\"[category]\">"
		dat += get_category_header(category)
		dat += cat_dat[category]
		dat += "</div>"

	dat += "<div class=\"[tab == "Runes" ? "tabContent" : "tabContent hide"]\" id=\"Runes\">"
	dat += get_category_header("Runes")
	dat += cat_dat["Runes"]
	dat += "</div>"

	if(chosen_spell != "")
		dat += "<div class=\"[tab == chosen_spell ? "tabContent" : "tabContent hide"]\" id=\"[chosen_spell]\">"
		dat += cat_dat[chosen_spell]
		dat += "</div>"

	return dat

/obj/item/weapon/storage/spellbook/proc/browse_ui(mob/user)
	user.set_machine(src)
	var/dat = entity_ja(ui_wrap(get_ui(user)))
	user << browse(dat, "window=[name];size=700x500")
	onclose(user, "[name]")

/obj/item/weapon/storage/spellbook/Topic(href, href_list)
	..()
	var/mob/living/L = usr
	if(!istype(L) || L.incapacitated())
		return

	if(loc == L || (in_range(src, L) && isturf(loc)))
		L.set_machine(src)
		if(href_list["spell"])
			switch(href_list["action"])
				if("switch_to")
					chosen_spell = href_list["spell"]
					tab = chosen_spell
					browse_ui(L)
		else if(href_list["page"])
			tab = sanitize(href_list["page"])
			browse_ui(L)

/obj/item/weapon/storage/spellbook/attack_self(mob/user)
	browse_ui(user)

/obj/item/weapon/storage/spellbook/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/spell))
		learn_spell(I.type)
		if(user.machine == src)
			browse_ui(user)
		return
	if(istype(I, /obj/item/rune))
		var/obj/item/rune/R = I
		if(global.spell_types_by_spell_word[R.rune_word])
			var/spell_type = pick(global.spell_types_by_spell_word[R.rune_word])
			learn_spell(spell_type, reveal_rune_word=TRUE)
			if(user.machine == src)
				browse_ui(user)
		return
	return ..()



/obj/item/weapon/storage/spellbook/full

/obj/item/weapon/storage/spellbook/full/atom_init()
	spawn_entries_types = subtypesof(/obj/item/spell)
	return ..()
