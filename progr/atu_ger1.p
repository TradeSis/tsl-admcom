def input parameter vetbcod like ger.estab.etbcod.
def input parameter vdti    like plani.pladat.
def input parameter vdtf    like plani.pladat.
def var sresp as log format "Sim/Nao".
def stream scli.
def stream sfla.
def var vclicod  like ger.clien.clicod.
def var vcontnum as int.
def var vdata like plani.pladat.

output to l:\dados\func.d.
for each ger.func where ger.func.etbcod = vetbcod no-lock:
    export func.
end.
output close.
        

vclicod = 0.
vcontnum = 0.
for each clien where clien.dtcad >= today - 15 no-lock:

    if int(substring(string(clien.clicod),7,2)) = vetbcod
    then do:
        if vclicod < clien.clicod
        then vclicod = clien.clicod. 
    end.
    
end.    

for each contrato where contrato.etbcod = vetbcod and
                        contrato.dtinicial >= today - 10 no-lock:
                                
    if vcontnum < int(contrato.contnum)
    then vcontnum = int(contrato.contnum). 

end.

vclicod  = int(substring(string(vclicod),1,6)) + 1000. 
vcontnum = int(substring(string(vcontnum),1,6)) + 1000.
       
display vclicod label "Cliente Gerado"
        vcontnum label "Contrato Gerado" format ">>>>>>>>>9"
                    with frame f-ger3 1 column centered
                        title "Geranum Sugerido".
    
output to l:\dados\estab.d.
for each estab no-lock.

    export estab. 
        
end.
output close.
    

output stream sfla to l:\dados\flag.d.
for each flag no-lock. 
    display "Exportando..." flag.clicod 
                with 1 down title "IMPORTANDO FLAG". pause 0.
        
    export stream sfla flag.
        
end.
output stream sfla close.


output stream scli to l:\dados\clien.d.
do vdata = vdti to vdtf:
    for each clien where clien.dtcad = vdata no-lock:
    
        display "Atualizando Clientes...." vdata no-label
                     with frame f2 1 down centered.
    
        pause 0. 
        export stream scli clien.
    end.
end.
output stream scli to close.
hide frame f2 no-pause.

                    

                                    
                                    
 



    



         

                       
