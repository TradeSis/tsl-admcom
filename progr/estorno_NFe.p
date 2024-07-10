{admcab.i}

def input parameter par-rowid as rowid. 
def buffer A01_infnfe for A01_infnfe.
def var p-ok as log.

find A01_infnfe where rowid(A01_infnfe) = par-rowid no-lock.
if not avail A01_infnfe or
    A01_infnfe.sitnfe = 91
then do:
    message color red/with "NFe ja estornada." view-as alert-box.
    return.
end.    
find B01_IdeNFe of A01_infnfe no-lock.

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-nfref
    field chave-nfe as char.

create tt-nfref.
tt-nfref.chave-nfe = A01_infnfe.id.    

def new shared var v-justif-est as char.

find plani where  plani.etbcod = A01_infnfe.etbcod and
                  plani.emite  = A01_infnfe.etbcod and
                  plani.serie  = A01_infnfe.serie and
                  plani.numero = A01_infnfe.numero
                  no-lock no-error.
if avail plani
then do:
    if plani.movtdc <> 11 and
       plani.movtdc <> 12 and
       plani.movtdc <> 13 and
       plani.movtdc <> 16 and
       plani.movtdc <> 24 and
       plani.movtdc <> 26 and
       plani.movtdc <> 27 and
       plani.movtdc <> 31 and
       plani.movtdc <> 61 and
       plani.movtdc <> 73 and
       plani.movtdc <> 75 and
       plani.movtdc <> 6  and
       plani.movtdc <> 80
    then do:
        message color red/with
            "Estorno nao disponivel para tipo " plani.movtdc 
             view-as alert-box.
        return.     
    end.   

    repeat on endkey undo, return.
    
        update v-justif-est format "x(70)" no-label
          with frame f01 title "Informe o motivo do ESTORNO." row 8.

        if v-justif-est = "" 
        then undo.
        leave.            
    end.
    
    if v-justif-est = ""
    then return.
    
    buffer-copy plani to tt-plani.
    
    if tt-plani.emite = 22 and tt-plani.serie = "1"
    then assign tt-plani.serie = "55".

    assign
        tt-plani.desti   = tt-plani.emite
        tt-plani.pladat  = today
        tt-plani.datexp  = today
        tt-plani.dtinclu = today
        tt-plani.horincl = time
        tt-plani.placod  = ?
        tt-plani.numero  = ?.
    
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         (movim.movtdc = plani.movtdc or
                          movim.movtdc = 50)
                         no-lock.
        create tt-movim.
        buffer-copy movim to tt-movim.
        tt-movim.desti  = tt-plani.emite.
        tt-movim.movhr  = tt-plani.horincl.
    end.

    if plani.movtdc = 12
    then do:
        for each tt-movim.
            tt-movim.movtdc = 59.
            tt-movim.movdat = tt-plani.pladat.
            tt-movim.placod = tt-plani.placod.
            tt-movim.datexp = tt-plani.datexp.
        end.    
        assign
            tt-plani.opccod = 5949
            tt-plani.hiccod = 5949
            tt-plani.movtdc = 59.

        find first tt-movim where tt-movim.etbcod = tt-plani.etbcod and
                                 tt-movim.placod = tt-plani.placod and
                                 tt-movim.movtdc = tt-plani.movtdc and
                                 tt-movim.movdat = tt-plani.pladat and
                                 tt-movim.procod > 0
                                 no-error.
        if avail tt-movim
        then run manager_nfe.p (input "5949_e",
                               input ?,
                               output p-ok).
    end.
    
    else if plani.movtdc = 13
    then do:        
        if plani.opccod = 5202 or
           plani.opccod = 6202
        then do:
            for each tt-movim.
                tt-movim.movtdc = 60.
                tt-movim.movdat = tt-plani.pladat.
                tt-movim.placod = tt-plani.placod.
                tt-movim.datexp = tt-plani.datexp.
            end.
            assign
                tt-plani.opccod = 1949
                tt-plani.hiccod = 1949
                tt-plani.movtdc = 60.

            run manager_nfe.p (input "1949_e",
                               input ?,
                               output p-ok).
        end.
        if plani.opccod = 5411 or
           plani.opccod = 6411
        then do:
            for each tt-movim.
                tt-movim.movtdc = 60.
                tt-movim.movdat = tt-plani.pladat.
                tt-movim.placod = tt-plani.placod.
                tt-movim.datexp = tt-plani.datexp.
            end.
            assign
                tt-plani.opccod = 1949
                tt-plani.hiccod = 1949
                tt-plani.movtdc = 60.

            run manager_nfe.p (input "1949_e",
                               input ?,
                               output p-ok).
        end.    
    end.
    
    else if plani.movtdc = 31
    then do:
        if plani.opccod = 5202 or
           plani.opccod = 6202
        then do:
            for each tt-movim.
                tt-movim.movtdc = 65.
                tt-movim.movdat = tt-plani.pladat.
                tt-movim.placod = tt-plani.placod.
                tt-movim.datexp = tt-plani.datexp.
            end.
            assign
                tt-plani.opccod = 1949
                tt-plani.hiccod = 1949
                tt-plani.movtdc = 65.
            run manager_nfe.p (input "1949_e",
                               input ?,
                               output p-ok).
        end.
        if plani.opccod = 5411 or
           plani.opccod = 6411
        then do:
            for each tt-movim.
                tt-movim.movtdc = 65.
                tt-movim.movdat = tt-plani.pladat.
                tt-movim.placod = tt-plani.placod.
                tt-movim.datexp = tt-plani.datexp.
            end.
            assign
                tt-plani.opccod = 1949
                tt-plani.hiccod = 1949
                tt-plani.movtdc = 65.
            run manager_nfe.p (input "1949_e",
                               input ?,
                              output p-ok).
        end.    
    end.

    else if plani.movtdc = 24
    then do:
        if plani.opccod = 5602 
        then do:
            for each tt-movim.
                tt-movim.movtdc = 61.
                tt-movim.movdat = tt-plani.pladat.
                tt-movim.placod = tt-plani.placod.
                tt-movim.datexp = tt-plani.datexp.
                tt-plani.icms = tt-movim.movicms.
            end.
            assign
                tt-plani.opccod = 1949
                tt-plani.hiccod = 1949
                tt-plani.movtdc = 61.

            if tt-plani.icms = 0
            then assign tt-plani.icms = plani.icms.

            run manager_nfe.p (input "1949_e",
                               input ?,
                               output p-ok).
        end.
    end.
    else if plani.movtdc = 16
    then do:
        if plani.opccod = 5915 
            or plani.opccod = 6915
        then do:
            for each tt-movim.
                tt-movim.movtdc = 62.
                tt-movim.movdat = tt-plani.pladat.
                tt-movim.placod = tt-plani.placod.
                tt-movim.datexp = tt-plani.datexp.
                tt-plani.icms = tt-movim.movicms.
            end.
            assign
                tt-plani.opccod = 1949
                tt-plani.hiccod = 1949
                tt-plani.movtdc = 62.
            run manager_nfe.p (input "1949_e",
                               input ?,
                               output p-ok).
        end.
        
        /******** Dentro ou fora do estado o opccod (CFOP) será sempre 1949
        if plani.opccod = 6915 
        then do:
            for each tt-movim.
                tt-movim.movtdc = 62.
                tt-movim.movdat = tt-plani.pladat.
                tt-movim.placod = tt-plani.placod.
                tt-movim.datexp = tt-plani.datexp.
                tt-plani.icms = tt-movim.movicms.
            end.
            assign
                tt-plani.opccod = 2949
                tt-plani.hiccod = 2949
                tt-plani.movtdc = 62.
            run manager_nfe.p (input "1949_e",
                               input ?,
                               output p-ok).
        end.
        ***/
    end.
    
    else if plani.movtdc = 61
    then do:
        for each tt-movim.
            tt-movim.movtdc = 66.
            tt-movim.movdat = tt-plani.pladat.
            tt-movim.placod = tt-plani.placod.
            tt-movim.datexp = tt-plani.datexp.
        end.    
        assign
            tt-plani.opccod = 5949
            tt-plani.hiccod = 5949
            tt-plani.movtdc = 66
            .
        find first tt-movim where tt-movim.etbcod = tt-plani.etbcod and
                                 tt-movim.placod = tt-plani.placod and
                                 tt-movim.movtdc = tt-plani.movtdc and
                                 tt-movim.movdat = tt-plani.pladat and
                                 tt-movim.procod > 0
                                 no-error.
        if avail tt-movim
        then run manager_nfe.p (input "5949_e",
                               input ?,
                               output p-ok).
    end.

    else if plani.movtdc = 53
    then do:
        for each tt-movim.
            tt-movim.movtdc = 68.
            tt-movim.movdat = tt-plani.pladat.
            tt-movim.placod = tt-plani.placod.
            tt-movim.datexp = tt-plani.datexp.
        end.    
        assign
            tt-plani.opccod = 5949
            tt-plani.hiccod = 5949
            tt-plani.movtdc = 68.
        find first tt-movim where tt-movim.etbcod = tt-plani.etbcod and
                                 tt-movim.placod = tt-plani.placod and
                                 tt-movim.movtdc = tt-plani.movtdc and
                                 tt-movim.movdat = tt-plani.pladat and
                                 tt-movim.procod > 0
                                 no-error.
        if avail tt-movim
        then run manager_nfe.p (input "5949_e",
                               input ?,
                               output p-ok).
    end.

    else if plani.movtdc = 27
    then do:
        if plani.opccod = 5603 or
           plani.opccod = 6603 
        then do:
            for each tt-movim.
                tt-movim.movtdc = 67.
                tt-movim.movdat = tt-plani.pladat.
                tt-movim.placod = tt-plani.placod.
                tt-movim.datexp = tt-plani.datexp.
                tt-plani.icms = tt-movim.movicms.
            end.
            assign
                tt-plani.opccod = 1949
                tt-plani.hiccod = 1949
                tt-plani.movtdc = 67.
                
            run manager_nfe.p (input "1949_e",
                               input ?,
                               output p-ok).
        end.
        else if plani.opccod = 1603 
        then do:
            for each tt-movim.
                tt-movim.movtdc = 69.
                tt-movim.movdat = tt-plani.pladat.
                tt-movim.placod = tt-plani.placod.
                tt-movim.datexp = tt-plani.datexp.
                tt-plani.icms = tt-movim.movicms.
            end.
            assign
                tt-plani.opccod = 5949
                tt-plani.hiccod = 5949
                tt-plani.movtdc = 69.
                
            run manager_nfe.p (input "5949_e",
                               input ?,
                               output p-ok).
        end.
    end.
    else if plani.movtdc = 11 or
            plani.movtdc = 26 or
            plani.movtdc = 75 or
            plani.movtdc = 80
    then do:
        if plani.opccod = 5949 or
           plani.opccod = 6949 
        then do:
            for each tt-movim.
                tt-movim.movtdc = 11.
                tt-movim.movdat = tt-plani.pladat.
                tt-movim.placod = tt-plani.placod.
                tt-movim.datexp = tt-plani.datexp.
                tt-plani.icms = tt-movim.movicms.
            end.
            assign
                tt-plani.opccod = 1949
                tt-plani.hiccod = 1949
                tt-plani.movtdc = 11.
                
            run manager_nfe.p (input "1949_e",
                               input ?,
                               output p-ok).
        end.
        else if plani.opccod = 5912 or
           plani.opccod = 6912 
        then do:
            for each tt-movim.
                tt-movim.movtdc = 11.
                tt-movim.movdat = tt-plani.pladat.
                tt-movim.placod = tt-plani.placod.
                tt-movim.datexp = tt-plani.datexp.
                tt-plani.icms = tt-movim.movicms.
            end.
            assign
                tt-plani.opccod = 1912
                tt-plani.hiccod = 1912
                tt-plani.movtdc = 11.
                
            run manager_nfe.p (input "1949_e",
                               input ?,
                               output p-ok).
        end.
        else if plani.opccod = 1949 or
                plani.opccod = 2949
        then do:
            for each tt-movim.
                tt-movim.movtdc = 26.
                tt-movim.movdat = tt-plani.pladat.
                tt-movim.placod = tt-plani.placod.
                tt-movim.datexp = tt-plani.datexp.
                tt-plani.icms = tt-movim.movicms.
            end.
            assign
                tt-plani.opccod = 5949
                tt-plani.hiccod = 5949
                tt-plani.movtdc = 26.
                
            run manager_nfe.p (input "5949_e",
                               input ?,
                               output p-ok).
        end.
    end.
    else if plani.movtdc = 73
    then do:
        if plani.opccod = 5905
        then do:
            for each tt-movim.
                tt-movim.movtdc = 78.
                tt-movim.movdat = tt-plani.pladat.
                tt-movim.placod = tt-plani.placod.
                tt-movim.datexp = tt-plani.datexp.
                tt-plani.icms = tt-movim.movicms.
            end.
            assign
                tt-plani.opccod = 1905
                tt-plani.hiccod = 1905
                tt-plani.movtdc = 78.
                
            run manager_nfe.p (input "1949_e",
                               input ?,
                               output p-ok).
        end.
    end.
    else if plani.movtdc = 6
    then do:
        if plani.opccod = 5152
        then do:
            for each tt-movim.
                tt-movim.movtdc = 79.
                tt-movim.movdat = tt-plani.pladat.
                tt-movim.placod = tt-plani.placod.
                tt-movim.datexp = tt-plani.datexp.
                tt-plani.icms = tt-movim.movicms.
            end.
            assign
                tt-plani.opccod = 1152
                tt-plani.hiccod = 1152
                tt-plani.movtdc = 79
                tt-plani.bicms = 0
                tt-plani.icms  = 0
                .
                
            run manager_nfe.p (input "1152_e",
                               input ?,
                               output p-ok).
        end.
    end.
    if p-ok
    then do on error undo:
        find current A01_infnfe.
        A01_infnfe.sitnfe = 91.
    end.    
    find current A01_infnfe no-lock.    
end.


 
procedure p-mostra-nota:

    display tt-plani.bicms  
            tt-plani.icms 
            tt-plani.bsubst
            tt-plani.icmssubst
            tt-plani.protot   
                with frame f-mostra-1 overlay row 8 width 80.
                
            pause 0.

    display tt-plani.frete 
            tt-plani.seguro 
            tt-plani.desacess
            tt-plani.ipi     
            tt-plani.platot  
            with frame f-mostra-2 overlay row 12 width 80.

    pause 0.

    sresp = no.

    for each tt-movim.
        display tt-movim.procod
                tt-movim.movpc
                tt-movim.movdes
                tt-movim.movipi
                tt-movim.movalipi
                tt-movim.movicms
                tt-movim.movalicms 
                tt-movim.movdev label "Frete" with 1 col.
    end.

    message "Deseja alterar as informacoes? " update sresp.
    if sresp
    then do:
        update tt-plani.bicms  
               tt-plani.icms 
               tt-plani.bsubst
               tt-plani.icmssubst
               tt-plani.protot   
                  with frame f-mostra-1 overlay row 8 width 80.

        update tt-plani.frete 
               tt-plani.seguro 
               tt-plani.desacess
               tt-plani.ipi     
               tt-plani.platot  
               with frame f-mostra-2 overlay row 12 width 80.
    
        for each tt-movim.
    
            update tt-movim.procod
                   tt-movim.movpc
                   tt-movim.movdes
                   tt-movim.movipi
                   tt-movim.movalipi
                   tt-movim.movicms
                   tt-movim.movalicms
                   tt-movim.movdev label "Frete" with 1 col.
        end.
    end.

end procedure.

