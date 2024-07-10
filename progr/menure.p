output to helio.
def buffer bmenu for menu.
for each aplicativo:
    displa aplinom aplicod column-label "Diretorio" with column 1 no-labels.
    for each menu of aplicativo where menniv = 1:
	display menu.mentit with col 10 no-labels.
	for each bmenu of aplicativo where
	    bmenu.ordsup = menu.menord and bmenu.menniv = 2:
	    display bmenu.mentit menare
			menpro with no-box col 20.
	end.
    end.
end.
