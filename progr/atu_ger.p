disable triggers for load of gerloja.clien.
disable triggers for load of gerloja.func.
def input parameter vetbcod like ger.estab.etbcod.
def input parameter vdti    like plani.pladat.
def input parameter vdtf    like plani.pladat.
def var sresp as log format "Sim/Nao".

def var vclicod  like ger.clien.clicod.
def var vcontnum as int.
def var vdata like plani.pladat.


for each ger.func where ger.func.etbcod = vetbcod no-lock:

    do transaction:
        find gerloja.func where gerloja.func.etbcod = ger.func.etbcod and
                                gerloja.func.funcod = ger.func.funcod 
                                                no-error.
                                            
        if not avail gerloja.func
        then do:
            create gerloja.func.
            assign gerloja.func.funcod = ger.func.funcod
                   gerloja.func.etbcod = ger.func.etbcod.
        end.
        assign gerloja.func.FunNom   = ger.func.FunNom 
               gerloja.func.FunApe   = ger.func.FunApe  
               gerloja.func.EtbCod   = ger.func.EtbCod  
               gerloja.func.FunFunc  = ger.func.FunFunc  
               gerloja.func.FunMec   = ger.func.FunMec  
               gerloja.func.FunSit   = ger.func.FunSit  
               gerloja.func.FunDtCad = ger.func.FunDtCad  
               gerloja.func.UserCod  = ger.func.UserCod  
               gerloja.func.Senha    = ger.func.Senha  
               gerloja.func.opatual  = ger.func.opatual  
               gerloja.func.aplicod  = ger.func.aplicod
               gerloja.func.exportado = yes.
    end.
end.
        

vclicod = 0.
vcontnum = 0.
for each ger.clien where ger.clien.dtcad >= today - 15 no-lock:

    if int(substring(string(clien.clicod),7,2)) = vetbcod
    then do:
        if vclicod < ger.clien.clicod
        then vclicod = ger.clien.clicod. 
    end.
    
end.    

for each contrato where contrato.etbcod = vetbcod and
                        contrato.dtinicial >= today - 10 no-lock:
                                
    if vcontnum < int(contrato.contnum)
    then vcontnum = int(contrato.contnum). 

end.

find gerloja.geranum where gerloja.geranum.etbcod = vetbcod no-error.
if not avail gerloja.geranum
then do:
    message "Controle de Numeracao na existe, Deseja Criar" update sresp.
    if not sresp
    then return.
    else do transaction:
        create gerloja.geranum.
        assign gerloja.geranum.etbcod = vetbcod
               gerloja.geranum.contnum = 100000
               gerloja.geranum.clicod  = 100000.
               
        display gerloja.geranum.etbcod label "Filial"
                    with frame f-geranum side-label centered.
        update gerloja.geranum.contnum label "Contrato"
               gerloja.geranum.clicod label "Cliente"
                    with frame f-geranum.
    end.
end.
else do:

    /*
    display gerloja.geranum.clicod  label "Cliente"
            gerloja.geranum.contnum label "Contrato"
                with frame f-ger1 1 column centered
                    title "Geranum Encontrado".
    */                

    vclicod  = int(substring(string(vclicod),1,6)).
    vcontnum = int(substring(string(vcontnum),1,6)).
   
  
    /*
    display vclicod label "Cliente Gerado"
            vcontnum label "Contrato Gerado" format ">>>>>>>>>9"
                    with frame f-ger2 1 column centered
                        title "Geranum Gerado".
    */                



    vclicod  = int(substring(string(vclicod),1,6)) + 1000.
    vcontnum = int(substring(string(vcontnum),1,6)) + 1000.
    do on error undo:
       
        update vclicod label "Cliente Gerado"
               vcontnum label "Contrato Gerado" format ">>>>>>>>>9"
                    with frame f-ger3 1 column centered
                        title "Geranum Sugerido".
        message "Confirma nova numeracao" update sresp.
        if sresp
        then do:
            assign gerloja.geranum.clicod  = vclicod
                   gerloja.geranum.contnum = vcontnum
                   gerloja.geranum.datexp  = today.
        end.
    end.
end.        
    
for each gerloja.estab:  
    display "deletando..." gerloja.estab.etbcod with 1 down. pause 0.  
    
    do transaction: 
        delete gerloja.estab.
    end.

end.

for each ger.estab no-lock.

    display "Importando..." ger.estab.etbcod with 1 down. pause 0.
        
    create gerloja.estab. 
    {tt-estab.i gerloja.estab ger.estab}.
        
end.
    
for each gerloja.flag: 
    display "deletando..." gerloja.flag.clicod  
        with 1 down title "DELETANDO FLAG". pause 0.
    do transaction: 
        delete gerloja.flag.
    end.
end.

for each ger.flag no-lock. 
    display "Importando..." ger.flag.clicod 
                with 1 down title "IMPORTANDO FLAG". pause 0.
        
    create gerloja.flag.
    {tt-flag.i gerloja.flag ger.flag}.
        
end.

do vdata = vdti to vdtf:
    for each ger.clien where ger.clien.dtcad = vdata no-lock:
    
        display "Atualizando Clientes...." vdata no-label
                     with frame f2 1 down centered.
    
        pause 0. 
        find gerloja.clien where gerloja.clien.clicod = ger.clien.clicod
                                                                no-error.
        if not avail gerloja.clien 
        then do transaction: 
            create gerloja.clien.  
            {clien.i gerloja.clien ger.clien}.
            gerloja.clien.exportado = yes.
        end.
    end.
end.
hide frame f2 no-pause.

                    

                                    
                                    
 



    



         

                       
