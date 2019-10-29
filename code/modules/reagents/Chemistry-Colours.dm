/proc/mix_color_from_reagents(list/reagent_list)
	if(!reagent_list || !length(reagent_list))
		return 0

	var/contents = length(reagent_list)
	var/list/weight = new /list(contents)
	var/list/redcolor = new /list(contents)
	var/list/greencolor = new /list(contents)
	var/list/bluecolor = new /list(contents)
	var/i

	//fill the list of weights
	for(i=1; i<=contents; i++)
		var/datum/reagent/re = reagent_list[i]
		var/reagentweight = re.volume * re.color_weight
		weight[i] = reagentweight


	//fill the lists of colours
	for(i=1; i<=contents; i++)
		var/datum/reagent/re = reagent_list[i]
		var/hue = re.color
		if(length(hue) != 7)
			return 0
		redcolor[i]=hex2num(copytext(hue,2,4))
		greencolor[i]=hex2num(copytext(hue,4,6))
		bluecolor[i]=hex2num(copytext(hue,6,8))

	//mix all the colors
	var/red = mixOneColor(weight,redcolor)
	var/green = mixOneColor(weight,greencolor)
	var/blue = mixOneColor(weight,bluecolor)

	//assemble all the pieces
	var/finalcolor = "#[red][green][blue]"
	return finalcolor
