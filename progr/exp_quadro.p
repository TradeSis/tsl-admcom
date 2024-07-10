/*por Lucas Leote*/

{admcab.i new}

def var vmes as int init 0.
def var vano as int init 0.

/* Formulario */
form vmes label "Mes" format ">9"
	 vano label "Ano" format ">>>9"

with frame f01 title "Informe os dados abaixo:" with 3 col width 80.

/* Atualiza variaveis */
update vmes 
	   vano
with frame f01.

/*hide frame f01 no-pause.*/

for each metven where metmes = vmes and metano = vano no-lock.

find first tvendfil where
           tvendfil.anoref = vano and
           tvendfil.mesref = vmes and
           tvendfil.etbcod = metven.etbcod
no-lock no-error.

disp 
	metven.etbcod column-label "Estab"
	metven.aux-cha1 format "x(4)" column-label "Moveis ideal" 
	metven.aux-cha2 format "x(4)" column-label "Moda ideal" 
	tvendfil.moveis column-label "Moveis presente" format ">>>>>9"
	tvendfil.moda column-label "Moda presente" format ">>>>>9".
	
end.

