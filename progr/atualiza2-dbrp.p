
{admcab.i}

def shared var vdti as date.
def shared var vdtf as date.

for each supdbrp.arqclien where  supdbrp.arqclien.mes = month(vdti) and
                        supdbrp.arqclien.ano = year(vdti):
    delete supdbrp.arqclien.
end.    
                            
for each suporte.arqclien where suporte.arqclien.mes = month(vdti) and
                                suporte.arqclien.ano = year(vdti)
                                no-lock.
    /*
    find supdbrp where supdbrp.arqclien.mes = suporte.arqclien.mes and
                       supdbrp.arqclien.ano = suporte.arqclien.ano and
                       supdbrp.arqclien.tipo = suporte.arqclien.tipo and
                       supdbrp.arqclien.etbcod = suporte.arqclien.etbcod and
                       supdbrp.arqclien.data = suporte.arqclien.data
                       no-error.
    */
    create supdbrp.arqclien.
    buffer-copy suporte.arqclien to supdbrp.arqclien.

end.

for each findbrp.contrato where findbrp.contrato.dtinicial >= vdti and
                        findbrp.contrato.dtinicial <= vdtf
                        no-lock:
    find first supdbrp.arqclien use-index indx-1
         where supdbrp.arqclien.mes = month(findbrp.contrato.dtinicial) and
               supdbrp.arqclien.ano = year(findbrp.contrato.dtinicial) and
               supdbrp.arqclien.tipo = "RECEBIMENTO" and 
               supdbrp.arqclien.etbcod = findbrp.contrato.etbcod and
               supdbrp.arqclien.data = findbrp.contrato.dtinicial and
               int(substr(supdbrp.arqclien.campo2,2,10)) = 
                                findbrp.contrato.clicod and
               int(supdbrp.arqclien.campo5) = findbrp.contrato.contnum
               no-lock no-error.
    
    if avail supdbrp.arqclien
    then.
    else do:
        find first supdbrp.arqclien use-index indx-1
         where supdbrp.arqclien.mes = month(findbrp.contrato.dtinicial) and
               supdbrp.arqclien.ano = year(findbrp.contrato.dtinicial) and
               supdbrp.arqclien.tipo = "EMISSAO" and 
               supdbrp.arqclien.etbcod = findbrp.contrato.etbcod and
               supdbrp.arqclien.data = findbrp.contrato.dtinicial and
               int(substr(supdbrp.arqclien.campo2,2,10)) = 
                            findbrp.contrato.clicod and
               int(supdbrp.arqclien.campo5) = findbrp.contrato.contnum
               no-lock no-error.
        if avail supdbrp.arqclien
        then.
        else do: 
 
        find first findbrp.contnf where 
                   findbrp.contnf.etbcod = findbrp.contrato.etbcod and
                   findbrp.contnf.contnum = findbrp.contrato.contnum no-error.
        if avail findbrp.contnf
        then do:
            find first comdbrp.plani where 
                       comdbrp.plani.etbcod = findbrp.contnf.etbcod and
                       comdbrp.plani.placod = findbrp.contnf.placod and
                       comdbrp.plani.serie = "V"
                             no-error.
            if avail comdbrp.plani
            then do:
                for each    comdbrp.movim where 
                            comdbrp.movim.etbcod = plani.etbcod and
                            comdbrp.movim.placod = plani.placod and
                            comdbrp.movim.movtdc = plani.movtdc
                                     .
                    delete comdbrp.movim.
                end.
                delete comdbrp.plani.                         
            end.             
            delete findbrp.contnf.    
        end.
        for each findbrp.titulo where 
                 findbrp.titulo.empcod = 19 and
                 findbrp.titulo.titnat = no and
                 findbrp.titulo.modcod = "CRE" and
                 findbrp.titulo.etbcod = findbrp.contrato.etbcod and
                 findbrp.titulo.clifor = findbrp.contrato.clicod and
                 findbrp.titulo.titnum = string(findbrp.contrato.contnum):
            delete findbrp.titulo.
        end.         
        delete findbrp.contrato.
        end.
    end.
end.            

