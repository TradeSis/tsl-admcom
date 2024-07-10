/*por Lucas Leote*/

{admcab.i}

def var vfuncod like func.funcod.
def var vmatricula as int format ">>>>9".

/* Formulario */
form vfuncod label "Cod. Func."
	 vmatricula label "Matricula"
with frame f01 title "Informe os dados abaixo:" with 3 col width 80.

/* Atualiza variaveis */
update vfuncod 
	   vmatricula
with frame f01.

find first func where func.etbcod = setbcod
				  and func.funcod = vfuncod
no-error.

for each tbclube where etbcod = setbcod
				   and funcod = vfuncod
				   and funmat = vmatricula.

find first clien where clien.clicod = tbclube.clicod
no-error.

disp 
	tbclube.etbcod   
	tbclube.funcod    
	func.funnom when avail func
	tbclube.funmat label "Matricula"   
	/* tbclube.tpassoc    */
	tbclube.clicod    
	clien.clinom when avail clien
	clien.ciccgc when avail clien label "CPF"
	clien.dtnasc when avail clien label "Dt Nasc"
	tbclube.email     
	tbclube.char1 label "Celular"
	/* tbclube.pontuacao   */
	/* tbclube.modalidade  */
	/* tbclube.dtinclu label "Data Cad" */
with 1 col.

update
	func.funnom when avail func
	tbclube.email     
	tbclube.char1 label "Celular"
	/* tbclube.dtinclu label "Data Cad" */
with 1 col.

end.