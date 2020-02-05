/datum/meme/memory/PDA_password
	name = "PDA servers password"
	desc = "A password you can use to log into the PDA servers."

	stack_id = "PDA_password"

	gain_txt = "You now know the password to PDA servers."
	lose_txt = "You forget the password to PDA servers."

	flags = list(
				MEME_SPREAD_VERBALLY = TRUE,
				MEME_SPREAD_READING = TRUE,
			)

	destroy_on_no_hosts = TRUE
