var/global/list/obj/effect/letter/red_ready_letters = list()
var/global/list/obj/effect/letter/blue_ready_letters = list()

/obj/effect/letter
	icon = 'code/modules/rugby/icons/letters.dmi'
	icon_state = "r"

	anchored = TRUE
	unacidable = TRUE

	var/outline
	var/outline_col
	var/outline_col_alpha
	var/team_color

/obj/effect/letter/atom_init()
	. = ..()
	if(team_color == "red")
		red_ready_letters += src
		outline_col = "#ff0000a1"
		outline_col_alpha = "#ff000000"
	else
		blue_ready_letters += src
		outline_col = "#0000ffa1"
		outline_col_alpha = "#0000ff00"

	outline = filter(type = "outline", size = 1, color = outline_col_alpha)
	filters += outline

	hide_letter()

/obj/effect/letter/proc/set_team_light()
	if(team_color == "red")
		set_light(1, 2, "#ff0000")
	else
		set_light(1, 2, "#0000ff")

/obj/effect/letter/proc/show_letter()
	alpha = 255
	set_team_light()
	animate(filters[1], color = outline_col, time = 1 SECOND)

/obj/effect/letter/proc/hide_letter()
	alpha = 0
	set_light(0)
	animate(filters[1], color = outline_col_alpha, time = 0)



/obj/machinery/ready_button
	name = "ready button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A switch to display that your team is ready to play!"

	anchored = TRUE
	use_power = NO_POWER_USE

	var/ready = FALSE
	var/team_color

	var/next_toggle

/obj/machinery/ready_button/attack_hand(mob/user)
	if(next_toggle > world.time)
		to_chat(user, "<span class='notice'>You can not toggle your ready state for next [(world.time - next_toggle) * 0.1] seconds.</span>")
		return
	next_toggle = world.time + 1 SECOND

	if(ready)
		ready = FALSE
		icon_state = "launcherbtt"
		mark_unready()
	else
		ready = TRUE
		icon_state = "launcheract"
		mark_ready()

/obj/machinery/ready_button/proc/get_letters()
	if(team_color == "red")
		return red_ready_letters
	return blue_ready_letters

/obj/machinery/ready_button/proc/mark_ready()
	for(var/l in get_letters())
		var/obj/effect/letter/L = l
		L.show_letter()

	if(team_color == "red")
		match.red_ready = TRUE
	else
		match.blue_ready = TRUE

/obj/machinery/ready_button/proc/mark_unready()
	for(var/l in get_letters())
		var/obj/effect/letter/L = l
		L.hide_letter()

	if(team_color == "red")
		match.red_ready = FALSE
	else
		match.blue_ready = FALSE



/obj/machinery/ready_button/red
	team_color = "red"

/obj/machinery/ready_button/blue
	team_color = "blue"
