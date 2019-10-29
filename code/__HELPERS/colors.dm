/proc/mix_colors(list/color_list, list/color_weights)
	if(!color_list || !length(color_list))
		return 0

	if(!color_weights)
		color_weights = list()

	while(color_weights.len < color_list.len)
		color_weights += 1.0

	var/contents = length(color_list)
	var/list/weight = new /list(contents)
	var/list/redcolor = new /list(contents)
	var/list/greencolor = new /list(contents)
	var/list/bluecolor = new /list(contents)
	var/i

	//fill the list of weights
	for(i = 1; i <= contents; i++)
		// var/this_color = color_list[i]
		// var/colorweight = color_list[this_color] * color_weights[i]
		weight[i] = color_weights[i]


	//fill the lists of colours
	for(i = 1; i <= contents; i++)
		var/hue = color_list[i]
		if(length(hue) != 7)
			world.log << "[hue] caused return 0"
			return 0
		redcolor[i] = hex2num(copytext(hue, 2, 4))
		greencolor[i] = hex2num(copytext(hue, 4, 6))
		bluecolor[i] = hex2num(copytext(hue, 6, 8))

	//mix all the colors
	var/red = mixOneColor(weight, redcolor)
	var/green = mixOneColor(weight, greencolor)
	var/blue = mixOneColor(weight, bluecolor)

	//assemble all the pieces
	var/finalcolor = "#[red][green][blue]"
	return finalcolor

/proc/mixOneColor(list/weight, list/color)
	if(!weight || !color || length(weight) != length(color))
		world.log << "length(weight) != length(color)"
		return 0

	var/contents = length(weight)
	var/i

	//normalize weights
	var/listsum = 0
	for(i=1; i<=contents; i++)
		listsum += weight[i]
	for(i=1; i<=contents; i++)
		weight[i] /= listsum

	//mix them
	var/mixedcolor = 0
	for(i=1; i<=contents; i++)
		mixedcolor += weight[i]*color[i]
	mixedcolor = round(mixedcolor)

	//until someone writes a formal proof for this algorithm, let's keep this in
	if(mixedcolor<0x00 || mixedcolor>0xFF)
		world.log << "some bullshit magic cause this"
		return 0

	var/finalcolor = num2hex(mixedcolor)
	while(length(finalcolor)<2)
		finalcolor = text("0[]",finalcolor) //Takes care of leading zeroes
	return finalcolor
