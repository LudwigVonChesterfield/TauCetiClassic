// <orbital>
/datum/role/orbital_traitor
	name = ORBITAL_TRAITOR
	id = ORBITAL_TRAITOR
	logo_state = "synd-logo"

	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "traitor"

	skillset_type = /datum/skillset/max
	moveset_type = /datum/combat_moveset/cqc
	change_to_maximum_skills = FALSE

/datum/role/orbital_traitor/forgeObjectives()
	AppendObjective(/datum/objective/interrupt)

	AppendObjective(/datum/objective/provoke_evac)

	AppendObjective(/datum/objective/hijack/orbital)

	return TRUE

/datum/role/orbital_traitor/Greet(greeting = GREET_DEFAULT, custom)
	antag.current.playsound_local(null, 'sound/antag/tatoralert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	return TRUE

/datum/role/orbital_traitor/OnPostSetup(laterole)
	. = ..()

	ADD_TRAIT(antag.current, TRAIT_HIDDEN_STASH, ROLE_TRAIT)

	to_chat(antag, "<span class='notice'>Точно! В какой-то из мусорок я оставлял свое снаряжение. Только в какой?..</span>")

/proc/show_orbital_traitor_blurb(client/C)
	set waitfor = FALSE

	if(!C)
		return

	var/style = "font-family: 'Fixedsys'; -dm-text-outline: 1 black; font-size: 11px;"
	var/obj/effect/overlay/blurb/B = new()

	var/list/style_for_line[4]
	var/list/lines[4]

	lines[1] = "Мысли проясняются..."

	lines[2] = "Воспоминания возвращаются..."
	style_for_line[2] = "color:red;"

	lines[3] = "ЦК не должно узнать."
	style_for_line[3] = "color:red;"

	lines[4] = "Они не сбегут живьем."
	style_for_line[4] = "color:red;"

	C.screen += B

	var/newline_flag = TRUE
	for(var/j in 1 to lines.len)
		var/new_line = uppertext(lines[j])
		var/old_line = j > 1 ? "<span style=\"[style_for_line[j - 1]]\">[uppertext(lines[j - 1])]</span>" : null
		animate(B, alpha = 255, time = 10)
		newline_flag = !newline_flag
		for(var/i = 2 to length_char(new_line) + 1)
			var/cur_line = "<span style=\"[style_for_line[j]]\">[copytext_char(new_line, 1, i)]</span>"
			if(newline_flag)
				B.maptext = "<div style=\"[style]\">[old_line]<br>[cur_line]</div>"
			else
				B.maptext = "<div style=\"line-height: 0.9;[style]\">[cur_line]</div><br><br></br>"
			sleep(1)
		if(newline_flag || j == lines.len)
			sleep(15)
			animate(B, alpha = 0, time = 15)
			sleep(15)

	if(C)
		C.screen -= B
	qdel(B)
