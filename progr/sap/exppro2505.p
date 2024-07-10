def var vsaida  as char             init "/admcom/tmp/produtos2505.csv".
def var vdtcad  like produ.prodtcad init 04/01/2019.
                                     /*  MM/DD/AAAA */


def var vcp as char init ";".
def var vx as int.
def var vcar as char extent 3.
def var vsub as char extent 3.

hide message no-pause.
message color normal "lendo produto2 cadastrados desde" vdtcad " exportando arquivo " vsaida ".".
message "Aguarde...".

output to value(vsaida).

    put unformatted 
        "DESDE " + string(vdtcad,"99/99/9999") + ":" skip
        "Código"        vcp
        "Descrição"    vcp
        "Código Subclasse"    vcp
        "NCM"   vcp
        "Característica = ENTRADA"           vcp
        "Valor da caracteristica"  vcp
        "Caracteristica = ESTILO"           vcp
        "Valor da caracteristica"           vcp
        "Caracteristica = TEM"           vcp
        "Valor da caracteristica"      vcp
                 skip.

for each produ no-lock.
    
    if produ.catcod = 31 or
       produ.catcod = 41
    then.
    else do:
        next.
    end.    
    
    if produ.proseq = 0
    then.
    else do:
        next.
    end.    

    if produ.prodtcad < vdtcad
    then next.
    
        
            
    do vx = 1 to 3:
            
        vcar[vx] = if vx = 1 then "ENTRADA" else
                   if vx = 2 then "ESTILO"  else
                                  "TEM".
        vsub[vx] = "".
        find caract where caract.cardes = vcar[vx] no-lock no-error.
        if avail caract
        then do:
            for each subcaract of caract no-lock.
                find procaract of produ where
                    procarac.subcod = subcaract.subcod
                    no-lock no-error.
                if avail procaract
                then vsub[vx] = subcaract.subdes.
            end.
        end.
    end.

    put unformatted 
        produ.procod    vcp
        produ.pronom    vcp
        produ.clacod    vcp
        produ.codfis    vcp
        vcar[1]           vcp
        vsub[1]           vcp
        vcar[2]           vcp
        vsub[2]           vcp
        vcar[3]           vcp
        vsub[3]           vcp
                 skip.

end.

put unformatted "FIM;".

output close.
        


