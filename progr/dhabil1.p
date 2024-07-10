{admcab.i}

def input parameter vetbcod  like ger.estab.etbcod.
def input parameter vcelular like adm.habil.celular format "x(15)".
 
 for each adm.habil where adm.habil.etbcod = vetbcod and 
                          adm.habil.celular = vcelular.
                             
     for each admloja.habil where admloja.habil.etbcod = vetbcod and
                                  admloja.habil.celular = vcelular.
         
         disp admloja.habil.etbcod admloja.habil.ciccgc 
              admloja.habil.celular admloja.habil.vencod 
              admloja.habil.habdat. 

message "Deseja deletar este registro? " update sresp.
    if sresp
    then do:
       delete admloja.habil.
       delete adm.habil.
    end.
 
 end. 
    end. 