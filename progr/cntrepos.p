{admcab.i}
{setbrw.i}

def var vsit as log format "Ativo/Inativo".

form cntrepos.etbcod  column-label "Filial"
     estab.etbnom     no-label
     vsit             column-label "Situacao"
     with frame f-linha down  centered row 6
     title " Controle reposicao produtos novos ".

for each estab where estab.etbnom begins "DREBES-FIL" NO-LOCK.
    find first cntrepos where 
               cntrepos.etbcod = estab.etbcod and
               cntrepos.tipo = 1
                no-lock no-error.
    if not avail cntrepos
    then do:
        create cntrepos.
        assign
            cntrepos.etbcod = estab.etbcod 
            cntrepos.tipo = 1
            cntrepos.campo1[1] = "Inativo"
            .
            
    end.            
end.     
assign
    a-seeid = -1
    a-recid = -1
    a-seerec = ?
    .

{sklcls.i
    &help = "                  F1=Ativa/Inativa    F4=Retorna"
    &file = cntrepos
    &cfield = cntrepos.etbcod
    &noncharacter = /*
    &ofield = " estab.etbnom when avail estab 
                vsit
            "
    &where  = " cntrepos.tipo = 1 and
                cntrepos.etbcod > 0 "
    &aftfnd1 = " find estab where estab.etbcod = cntrepos.etbcod
                    no-lock no-error.
                 vsit = yes.    
                 if cntrepos.campo1[1] = ""Inativo""
                 then vsit = no.  
                    
                    "
    &otherkeys1 = "
        find cntrepos where recid(cntrepos) = a-seerec[frame-line].
        if keyfunction(lastkey) = ""GO""
        then do:
            if cntrepos.campo1[1] = """" or
               cntrepos.campo1[1] = ""Ativo""
            then do:
                cntrepos.campo1[1] = ""Inativo"".
                vsit = no.
            end.
            else do:
                cntrepos.campo1[1] = ""Ativo"" .
                vsit = yes.
            end.
            disp vsit with frame f-linha.   
            next keys-loop.
        end.
              "
    &form = " frame f-linha "

}