{admcab.i}

def var v-filial as integer.
def var v-nota as integer.

update v-filial label "Filial" format ">>>9".
update v-nota label "Num Nota" format ">>>>>>>>>9".
          

/***********  Número da Nota e Imeis   **************/

   
for each tbprice where etb_venda = v-filial and nota_venda = v-nota no-lock.   
disp etb_venda nota_venda Serial.                                        

end.
pause.