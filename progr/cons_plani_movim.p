/*por Lucas Leote*/

{admcab.i}

def var valtotal like movim.movpc.
def var vfilial like estab.etbcod.
def var vnota as int.
def var vserie as char.

/* Formulario */
form vfilial label "Filial"
	vnota label "NF nro"
	vserie label "NF serie"

with frame f01 title "Informe os dados abaixo:" with 3 col width 80.

/* Atualiza variaveis */
update vfilial 
	vnota
	vserie
with frame f01.

hide frame f01 no-pause.

for each plani where etbcod = vfilial and numero = vnota and serie = vserie no-lock.
find clien where clien.clicod = plani.desti no-lock.
/*find func where func.funcod = plani.vencod and func.etbcod = plani.etbcod no-lock.
if not avail func then next.*/
disp 
	plani.etbcod 
	plani.desti format ">>>>>>>>>>9"
	clien.clinom label "Cliente"
	/*clien.ciccgc label "CPF"*/
	plani.numero 
	plani.serie 
	plani.platot
	plani.biss
	plani.descprod
	/*plani.plades*/
	plani.vencod format ">>>>9"
	/*func.funnom*/
	plani.pladat 
	plani.plades with 3 col width 80.

for each movim where movim.movtdc = plani.movtdc and
                     movim.etbcod = plani.etbcod and
                     movim.movdat = plani.pladat and
                     movim.placod = plani.placod no-lock by movseq.
valtotal = movqtm * movpc.
find produ where produ.procod = movim.procod.
disp 
	movim.procod(count)
	/*produ.pronom format "x(10)"*/
	movim.movpc(total)
	movim.movqtm format ">>>>>>>9"
	valtotal(total) label "V.Total"
	movim.movdes(total) 
	movim.movpdesc with width 80.          

end.
end.

pause.