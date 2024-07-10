def input parameter p-clicod like dragao.titulo.clifor.

def shared var vtotvencido as dec.
def shared var vparvencido as int.
def shared var vencvencido as dec.
def shared var totalvencido as dec.

def shared var vtotvencer as dec.
def shared var vparvencer as int.

def shared var vtotpagas as dec.
def shared var vparpagas as int.
def shared var vencpagas as dec.

   if connected("dragao")
   then do:
        for each dragao.titulo where dragao.titulo.clifor = p-clicod
                                 and dragao.titulo.empcod = 19
                                 and dragao.titulo.titsit = "LIB" 
                                 /*and dragao.titulo.titdtven < today*/ no-lock.
            if dragao.titulo.titdtven < today 
            then do:
                vtotvencido = vtotvencido + dragao.titulo.titvlcob.
                vparvencido = vparvencido + 1.
            end.
            else do:
                vtotvencer = vtotvencer + dragao.titulo.titvlcob.
                vparvencer = vparvencer + 1.
            end.
        end.
        
for each dragao.titulo where dragao.titulo.clifor = p-clicod
                      and dragao.titulo.empcod = 19
                      and dragao.titulo.titsit <> "LIB" no-lock.
    vtotpagas = vtotpagas + dragao.titulo.titvlcob.                      
    vparpagas = vparpagas + 1. 
    vencpagas = vencpagas + dragao.titulo.titjur.
end.
        
    end.
