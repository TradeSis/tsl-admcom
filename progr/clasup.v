if clasup = 0
    then true
    else {dv.v &c="clase.clasup"} and
	 can-find(clase where clase.clacod = input clase.clasup)
