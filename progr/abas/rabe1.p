def input parameter par-wms as char.

def new shared temp-table tt-abastransf no-undo
    field box           like tab_box.box
    field dttransf      like abastransf.dttransf
    field abatpri       like abastipo.abatpri
    field dtinclu       like abastransf.dtinclu
    field hrinclu       like abastransf.hrinclu
    field etbcod        like abastransf.etbcod    
    field abtcod        like abastransf.abtcod
    field rec    as recid
    index chave is unique primary 
            dttransf asc 
            abatpri asc 
            dtinclu asc
            hrinclu asc
            abtcod asc
            etbcod asc.

def var vabtsit as int.
def var cabtsit as char extent 3
    init ["AC","IN","SE"].

for each tt-abastransf.
    delete tt-abastransf.
end.
    
find abaswms where abaswms.wms = par-wms no-lock.
for each abastwms of abaswms no-lock.
    find abastipo of abastwms no-lock no-error.
    do vabtsit = 1 to 3.
        for each abastransf where             
            abastransf.wms = abaswms.wms and 
            abastransf.abatipo = abastwms.abatipo and 
            abastransf.abtsit = cabtsit[vabtsit] and 
            abastransf.dttransf < today - 5
            no-lock.

            find first tt-abastransf where
                    tt-abastransf.etbcod = abastransf.etbcod and
                    tt-abastransf.abtcod = abastransf.abtcod
               no-error.
            if avail tt-abastransf then next.
                    
            create tt-abastransf. 
            tt-abastransf.dtinclu   = abastransf.dtinclu.
            tt-abastransf.hrinclu   = abastransf.hrinclu.
            tt-abastransf.dttransf = abastransf.dttransf. 
            tt-abastransf.abatpri = if avail abastipo
                                    then abastipo.abatpri
                                    else 99. 
            tt-abastransf.etbcod = abastransf.etbcod.
            tt-abastransf.abtcod  = abastransf.abtcod.
            tt-abastransf.rec = recid(abastransf).

        end.
    end.        
end.

run abas/rimp1.p (par-wms,"Abertos a mais de 5 dias").
