disable triggers for load of nfeloja.tab_ini.
def input parameter i like estab.etbcod.

/*create nfeloja.tab_ini.                              
assign etbcod = i                              
       cxacod = 0                              
       parametro = "HOST - AGILIDADE"          
       valor = "agi3.lebes.com.br"             
       dtinclu = today                         
       dtexp = today                           
       exportar = no.*/

for each nfeloja.tab_ini where parametro matches "*agil*" no-lock.
	disp i etbcod parametro valor.
	/*delete tab_ini.*/
	pause 0.
end.