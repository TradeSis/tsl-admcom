{admcab.i}

def input parameter p-recid as recid.

find plani where recid(plani) = p-recid no-lock no-error.
if not avail plani then return.

disp plani.numero label "Numero Conhecimento" with frame f-c 1 down
                row 5 no-box side-label.
pause 0.
 
def temp-table tt-plani like plani.
def temp-table tt-movim like movim.

def buffer bplani for plani.

def var vtot-produ as dec.

def var vplatot like plani.platot.
def var vnumero like plani.numero.
def var simpnota as log format "Sim/Nao" init no.
def var vsaldo as dec.
def var vpladat like plani.pladat.
def var i as int.
def var vi as int.
def var vzes as int.

def var vezes as int.
def var vtotpag as dec format ">>,>>>,>>9.99".
def var vdesval as dec.
def var prazo as dec.
def var vtot-tit as dec.
def var vtot-par as int.

def var vdtemi as date.

def temp-table tt-titulo like titulo.

form tt-titulo.titpar
     tt-titulo.titnum
     prazo
     tt-titulo.titdtven
        validate(tt-titulo.titdtven > tt-titulo.titdtemi,
                            "Data para vencimento deve ser maior que emissao.")
     tt-titulo.titvlcob 
     validate(tt-titulo.titvlcob <= vplatot,
                    "Valor da parcela deve ser menor ou igual ao total da NF.")
     with frame ftitulo down centered color white/cyan.

for each docrefer where
         docrefer.etbcod = plani.etbcod and
         docrefer.codrefer = string(plani.emite) and
         docrefer.serierefer = plani.serie and
         docrefer.numerodr = plani.numero 
         no-lock .
    
    find first bplani where
                    bplani.etbcod = docrefer.etbcod and
                    bplani.emite = int(docrefer.codedori) and
                    bplani.serie = docrefer.serieori and
                    bplani.numero = int(docrefer.numori)
                    no-lock no-error.
    if avail bplani
    then do:
        create tt-plani.
        buffer-copy bplani to tt-plani.    
        for each movim where movim.movtdc = bplani.movtdc and
                             movim.etbcod = bplani.etbcod and
                             movim.placod = bplani.placod and
                             movim.movdat = bplani.pladat
                             no-lock:
            create tt-movim.
            buffer-copy movim to tt-movim.
            vtot-produ = vtot-produ + (movim.movpc * movim.movqtm).
        end.                     
    end.    

    find forne where forne.forcod = int(docrefer.codrefer) no-lock.
    disp docrefer.numori column-label "Numero"   format ">>>>>>>>9"
         docrefer.codedori column-label "Emitente" format ">>>>>>>>>9"
         forne.fornom when avail forne no-label
         docrefer.serieori column-label "Serie"
         docrefer.dtemiori column-label "Emissao"
         with frame f-as centered down
         title " Notas Fiscais associadas ao CT ".
end.         

pause 0.

def var vtot-frete as dec.

sresp = no.
message "Confirma Fechar Conhecimento de Frete?" update sresp.

if sresp
then do :
    vtot-frete = 0.
    for each tt-plani where tt-plani.etbcod > 0 :
        for each tt-movim where
                 tt-movim.etbcod = tt-plani.etbcod and
                 tt-movim.placod = tt-plani.placod and
                 tt-movim.movtdc = tt-plani.movtdc
                 .

            tt-movim.movdev = plani.platot * 
                    ((tt-movim.movpc * tt-movim.movqtm) / vtot-produ).
            vtot-frete = vtot-frete + tt-movim.movdev.
        end.
    end.          

    if  vtot-frete <> plani.platot and
        vtot-frete - 0.01 <> plani.platot and
        vtot-frete - 0.02 <> plani.platot and
        vtot-frete + 0.01 <> plani.platot and
        vtot-frete + 0.02 <> plani.platot 
    then do:
        message color red/with
        "Total nao fecha:" vtot-frete plani.platot  
        view-as alert-box.
    end.    
    else do:
        vplatot = plani.platot.
        vnumero = plani.numero.
        find forne where forne.forcod = plani.emite no-lock.
        find estab where estab.etbcod = plani.etbcod no-lock.

        run atu-fat-finan.

        for each tt-movim where tt-movim.etbcod > 0 no-lock:
            find movim where movim.etbcod = tt-movim.etbcod and
                             movim.placod = tt-movim.placod and
                             movim.procod = tt-movim.procod
                             exclusive-lock no-error.
            if avail movim
            then do on error undo:
                movim.movdev = tt-movim.movdev.
                for each estoq where estoq.procod = movim.procod.
                    estoq.estcusto = estoq.estcusto + 
                                (tt-movim.movdev / movim.movqtm).
                end. 
            end.
        end.
        do on error undo:       
            find plani where recid(plani) = p-recid exclusive-lock.
            plani.notsit = no.
            for each tt-titulo where tt-titulo.titvlcob > 0 no-lock:
                create titulo.
                buffer-copy tt-titulo to titulo.
            end.
        end.
        for each tt-movim where tt-movim.etbcod > 0 no-lock:
            find movim where movim.etbcod = tt-movim.etbcod and
                             movim.placod = tt-movim.placod and
                             movim.procod = tt-movim.procod
                             no-lock no-error.
            if avail movim
            then do:
                find first plani where 
                           plani.etbcod = movim.etbcod and
                           plani.placod = movim.placod and
                           plani.movtdc = movim.movtdc
                           no-lock no-error.
                if avail plani
                then do:
                    run /admcom/progr/calctom-pro.p(input movim.procod,
                                                    input plani.dtinclu,
                                                    input today ,
                                                    input "").
                end.
            end.
        end.
    end.             
end.

hide frame f-c no-pause.
hide frame f-as no-pause.

procedure atu-fat-finan:
    
    
    vdtemi = today.
    
    if simpnota
    then do:
        
        for each tt-titulo:
            delete tt-titulo.
        end.    
                do vi = 1 to 20:
                    if acha("DUP-" + string(vi,"999"),placon.notobs[1]) = ?
                    then leave.
                    do transaction:
                        create tt-titulo.
                        assign 
                            tt-titulo.etbcod = estab.etbcod
                            tt-titulo.titnat = yes
                            tt-titulo.modcod = "DUP"
                            tt-titulo.clifor = forne.forcod
                            tt-titulo.titsit = "LIB"
                            tt-titulo.agecod = "FRETE"
                            tt-titulo.empcod = wempre.empcod
                            tt-titulo.titdtemi = vdtemi
                            tt-titulo.titnum = string(vnumero)
                            tt-titulo.titpar = vi  
                            tt-titulo.titvlcob = dec(acha("VAL-" + 
                                string(vi,"999"),placon.notobs[1])) 
                            titulo.titdtven = date(acha("DTV-" + 
                                string(vi,"999"),placon.notobs[1])) 
                            vezes = vi        
                            vtotpag = vtotpag + tt-titulo.titvlcob
                            .
                    end.
                end.
                run man-titulo.
    end.
    else repeat on endkey undo:
    
        vtotpag = vplatot.

        disp vezes vtotpag label "Total Faturamento" with frame f-pag.
        update vezes label "Parcelas"
                validate(vezes > 0,"Favor informar quantidade de parcelas.")
                with frame f-pag width 80 side-label centered color white/red
                row 6
                title " Informe os dados para faturamento  ".
    
        do on error undo, retry:
            update vtotpag with frame f-pag.
    
            if vtotpag < vplatot
            then do:
                message "Verifique os valores da nota".
                undo, retry.
            end.
            vsaldo = 0.
            
            for each tt-titulo: delete tt-titulo. end.
            
            do i = 1 to vezes:
                
                create tt-titulo.
                assign 
                    tt-titulo.etbcod = estab.etbcod
                    tt-titulo.titnat = yes
                    tt-titulo.modcod = "DUP"
                    tt-titulo.clifor = forne.forcod
                    tt-titulo.titsit = "LIB"
                    tt-titulo.agecod = "FRETE"
                    tt-titulo.empcod = wempre.empcod
                    tt-titulo.titdtemi = vdtemi
                    tt-titulo.titnum = string(vnumero)
                    tt-titulo.titpar = i.
                    if prazo <> 0
                    then assign 
                             tt-titulo.titvlcob = vtotpag
                             tt-titulo.titdtven = tt-titulo.titdtemi + prazo.
                    else assign 
                             tt-titulo.titvlcob = vtotpag / vezes
                             tt-titulo.titdtven = tt-titulo.titdtemi + 
                                        (30 * i).
                    vsaldo = vsaldo + tt-titulo.titvlcob.
            end.
                     
            hide frame ftitulo no-pause.
            clear frame ftitulo all.
            run man-titulo.
                    
        end.
        vtot-tit = 0.
        vtot-par = 0.
        for each tt-titulo where tt-titulo.empcod = wempre.empcod and
                              tt-titulo.titnat = yes and
                              tt-titulo.modcod = "DUP" and
                              tt-titulo.etbcod = estab.etbcod and
                              tt-titulo.clifor = forne.forcod and
                              tt-titulo.titnum = string(vnumero) and
                              tt-titulo.titdtemi = vdtemi
                              no-lock.
                    vtot-tit = vtot-tit + tt-titulo.titvlcob.
                    if tt-titulo.titvlcob > 0
                    then vtot-par = vtot-par + 1.
        end.
        if vtot-par <> vezes
        then do:
            message color red/with
                    "Numero de parcelas " vtot-par 
                    "difere do valor informdo " vezes
                    view-as alert-box.
        end.
        else if vtot-tit = vtotpag
             then leave.
             else do:
                 message color red/with
                        "Total informado " vtotpag
                        "Difere do total parcelado " vtot-tit
                        view-as alert-box.
                        next.
             end.
    end.
end procedure.

procedure man-titulo:

        for each tt-titulo where tt-titulo.empcod = wempre.empcod and
                              tt-titulo.titnat = yes and
                              tt-titulo.modcod = "DUP" and
                              tt-titulo.etbcod = estab.etbcod and
                              tt-titulo.clifor = forne.forcod and
                              tt-titulo.titnum = string(vnumero) and
                              tt-titulo.titdtemi = vdtemi.
            display tt-titulo.titpar
                    tt-titulo.titnum
                        with frame ftitulo down centered
                                color white/cyan.
            prazo = 0.
            repeat on endkey undo, retry:
                update prazo with frame ftitulo.
                tt-titulo.titdtven = vpladat + prazo.
                tt-titulo.titvlcob = vsaldo.
                repeat on endkey undo, retry:
                    update tt-titulo.titdtven
                       tt-titulo.titvlcob 
                       with frame ftitulo no-validate.
                    leave.       
                end.
                leave.
            end.
            vsaldo = vsaldo - tt-titulo.titvlcob.
        
            down with frame ftitulo.
        end.        
        
end procedure.


