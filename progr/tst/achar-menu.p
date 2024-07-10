{admcab.i}

def var c-progr as char format "x(30)".

def temp-table tt-menu
	field aplicod like menu.aplicod
	field menniv like menu.menniv
	field mentit like menu.mentit
	field menpro like menu.menpro
	field ordsup like menu.ordsup
	field menord like menu.menord
	field mencod like menu.mencod.

update c-progr label "Programa" help "Informe o nome do programa em o .p"
with frame f2 1 col centered title "  Informe os dados abaixo  ".

for each menu where menpro = c-progr no-lock.
	create tt-menu.
	tt-menu.aplicod = menu.aplicod. 
	tt-menu.menniv = menu.menniv.
	tt-menu.mentit = menu.mentit.
	tt-menu.menpro = menu.menpro.
	tt-menu.ordsup = menu.ordsup.
	tt-menu.menord = menu.menord.
	tt-menu.mencod = menu.mencod.
end.

for each tt-menu.
	find menu where menu.aplicod = tt-menu.aplicod and menu.menord = tt-menu.menord and menu.ordsup = 0 no-lock no-error.
	disp 
		menu.aplicod label "Nivel 1"
		menu.mentit label "Nivel 2"
		tt-menu.mentit label "Nivel 3"
		tt-menu.menpro + ".p" format "x(30)" label "Programa"
		with frame f1 1 col centered title "MENU ENCONTRADO".

		pause.
end.