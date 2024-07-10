/* helio 13022023 - ID GLPI 156585 e 156556 Orquestra 456067 e 456058 - soh altera cpf */

{admcab.i}
def new global shared var xfuncod    like func.funcod.
def var vsenha like func.senha label "Senha".

repeat with side-label width 80 row 3 frame f-altera 1 down centered.
    prompt-for clien.clicod colon 20.
    find clien using clien.clicod.
        disp clien.clinom
               clien.tippes colon 20
                with color white/cyan
                              title "ALTERACAO CPF/CNPJ DE CLIENTES".



/* antigo clioutb4.p */
clien.datexp = today.

if clien.tippes
then do:
    
    /* antonio - sol 26210 */                        
    run Pi-cic-number(input-output clien.ciccgc).    
    update clien.ciccgc  colon 14 with frame f2
     row 10 side-label title " CPF "
                color white/cyan.
.
end.
else do:
    update clien.ciccgc   with frame f3
     width 80  color white/cyan
     title "CNPJ".
end.           
       
        
        update xfuncod label "Matricula" 
                    with frame ffunc row 10 centered color messages side-labels.
        find func where func.etbcod = setbcod and func.funcod = xfuncod no-lock no-error.
        if not avail func
        then do:
            message "matricula invalida".
            pause 1.
            undo.
        end.    
        update vsenha blank
            with frame ffunc.
        if vsenha <> func.senha
        then do:
            message "senha invalida".
            pause 1.
            undo.
        end.    
                
end.


Procedure Pi-cic-number.                                                    
                                                                            
def input-output  parameter p-ciccgc  like clien.ciccgc.                    
def var v-ciccgc like clien.ciccgc.                                         
def var jj          as int.                                                 
def var ii          as int.                                                 
def var v-carac     as char format "x(1)".                                  
                                                                            
                                                                            assign v-ciccgc = "".                                                       
do ii = 1 to length(p-ciccgc):                                              
   assign v-carac = string(substr(p-ciccgc,ii,1)).                          
      do jj = 1 to 10:                                                         
        if string(jj - 1) = v-carac then assign v-ciccgc = v-ciccgc + v-carac.
      end.                                                                     
end.                                                                        
assign p-ciccgc = v-ciccgc.                                                 
end procedure.                                                              

 
