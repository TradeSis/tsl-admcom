def var vendcod like wmsender.endcod.
vendcod = int(SESSION:PARAM).
pause 0 before-hide.
def var vdiretorio  as char format "x(60)" label "Diretorio".
def var varquivo    as char format "x(20)" label "Arquivo".

varquivo = "/admcom/relat/end_" + string(vendcod) + "." + string(time).

def var vtip as char format "X".
def var vabast as char format "X".

def var vcont as int.
vcont = 0.
for each wmsender no-lock .
    vcont = vcont + 1.
end.    
def var xcont as int.
output to value(vdiretorio + "/" + varquivo).
find wmsender where wmsender.endcod  = vendcod no-lock no-error.
if avail wmsender
then do:
    find wmstipend where 
            wmstipend.tipcod = wmsender.endtip no-lock no-error. 
    if  avail wmstipend 
    then do:
        for each wmsendpro of wmsender no-lock.
            find produ where produ.procod = wmsendpro.procod
                            no-lock no-error.
            if avail produ
            then do:          
                put unformatted 
                    produ.procod
                    ";"
                    produ.pronom
                    ";"
                    wmsender.endand
                    ";"
                    wmsendpro.qtdest skip.
                
            end.
        end.
    end.                 
end.    

output close.
