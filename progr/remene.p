{admcab.i}
def var vtot like com.plani.platot.
def var vdti like com.plani.pladat.
def var vdtf like com.plani.pladat.
def var vetbcod like estab.etbcod.
def var vip     as char.
def var vrec    as recid.
def var vnum    like plani.numero.
def temp-table tt-plani
    field rec as recid
    field numero like plani.numero.
def var vnumero like plani.numero.     
repeat:

    update vetbcod label "Filial"
        with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Filial nao Cadastrada".
        undo, retry.
    end.
    display estab.etbnom no-label with frame f1.
    vdti = date(month(today),1,year(today)).
    if month(today) = 12
    then vdtf = date(1,1,year(today) + 1) - 1.
    else vdtf = date(month(today) + 1,1,year(today)) - 1.
    
    for each tt-plani:
        delete tt-plani.
    end.

    for each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = 11           and
                         plani.pladat >= vdti        and
                         plani.pladat <= vdtf        and
                         plani.platot  = 0 no-lock:
        display plani.numero
                plani.icms
                plani.pladat
                plani.hiccod format "9999" column-label "Oper.Fiscal"
                    with frame f2 8 down centered.
           
                    
        create tt-plani.
        assign tt-plani.rec = recid(plani)
               tt-plani.numero = plani.numero.
        vnumero = plani.numero.
        
    end.
    do on error undo, retry:
        update vnumero label "Numero Nota Fiscal" format ">>>>>9"
                with frame f3 side-label centered color message no-box.
            
        find first tt-plani where tt-plani.numero = vnumero no-error.
        if not avail tt-plani
        then do:
            message "Nota nao encontrada".
            pause.
            undo, retry.
        end.                
    end.
    
    vrec = tt-plani.rec.
        
    
    sresp = no.  
    message "Confirma Emissao da Nota " vnumero update sresp.  
    if sresp  
    then run imptra_e.p (input vrec).
    
         
end.        