def input parameter vfuncod as integer format "999".
def input parameter vetbcod as integer format "999".
def input parameter vsenha as char format "x(8)".
def output parameter vstatus as char format "x(40)".      


/* ----- TESTA SE FUNCIONARIO OU ESTAB EXISTEM --------- */
find gerloja.func where funcod = vfuncod and
                        etbcod = vetbcod no-error.
     if not avail gerloja.func
     then do:
            vstatus = "FUNCIONARIO OU ESTABELECIMENTO INVALIDOS!".
            disconnect gerloja.
            return.
      end. 

 disable triggers for load of gerloja.func.
 for each gerloja.func where funcod = vfuncod and 
                            etbcod = vetbcod.
             assign gerloja.func.senha = vsenha.
             vstatus = "SENHA ALTERADA COM SUCESSO".
             disconnect gerloja.
      end.                               
             
                          

