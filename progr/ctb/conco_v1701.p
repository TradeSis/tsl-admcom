/*
*
*    titulo.p    -    Esqueleto de Programacao    com esqvazio

* #1 Agosto/2017 - Rotina foi refeita com esquema
*/
{admcab.i new}

def var wcon like contrato.contnum format ">>>>>>>>>9".
def buffer btitulo for titulo.

def new shared temp-table tt-contrato like contrato.
def new shared temp-table tt-titulo like titulo.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 4
    initial [" Consulta "," ","",""].

form
    esqcom1
    with frame f-com1 row 9 no-box no-labels col 32.

repeat:
    assign wcon = 0.
    hide frame f-contrato2 no-pause.
    do with width 80 frame f-contrato1 title " Contrato " side-label row 3:
        update wcon colon 13 validate (wcon > 0, "").
        find contrato where contrato.contnum = wcon use-index iconcon
                      no-lock no-error.
        if avail contrato
        then do:
            create tt-contrato.
            buffer-copy contrato to tt-contrato.
            for each titulo where
                     titulo.titnat = no and
                     titulo.clifor = contrato.clicod and
                     titulo.titnum = string(contrato.contnum)
                     no-lock.
                create tt-titulo.
                buffer-copy titulo to tt-titulo.
            end.         
        end.
        else do:
            find gcontrato where gcontrato.contnum = wcon use-index iconcon
                                  no-lock no-error.
            if avail gcontrato
            then do:
                create tt-contrato.
                buffer-copy gcontrato to tt-contrato.
                for each gtitulo where
                     gtitulo.titnat = no and
                     gtitulo.clifor = gcontrato.clicod and
                     gtitulo.titnum = string(gcontrato.contnum)
                     no-lock.
                    create tt-titulo.
                    buffer-copy gtitulo to tt-titulo.
                end.             
            end.                      
        end.
        
        find first tt-contrato no-error.
        if not avail tt-contrato
        then do:
            message "Contrato nao cadastrado".
            undo,retry.
        end.

        
        find clien of tt-contrato no-lock no-error.
        display
            tt-contrato.clicod colon 13 label "Cliente"
            clien.clinom no-label when avail clien format "x(41)"
            clien.ciccgc no-label when avail clien format "x(11)".
        display tt-contrato.dtinicial format "99/99/9999" colon 13
              tt-contrato.etbcod colon 45
              tt-contrato.banco  colon 13
              tt-contrato.modcod colon 45.
    end.

    display
        tt-contrato.vltotal colon 12 label "Vlr Total"
        tt-contrato.vlentra colon 12 label "Vlr Entrada"
        tt-contrato.vltotal - tt-contrato.vlentra
                 label "Vlr liquido" format ">>>,>>>,>>9.99" skip(1)
        tt-contrato.vlseguro colon 12 skip(1)
        tt-contrato.vliof colon 9
        tt-contrato.cet  skip(1)
        tt-contrato.txjuros colon 12
        /***
        contrato.vlmontante colon 12
        contrato.nroparc colon 12
        ***/
        with side-label width 30 frame f-contrato2 row 10 title " Valores ".
    /***
    if contrato.vlmontante = 0
    then contrato.vlmontante:visible = no.
    if contrato.nroparc = 0
    then contrato.nroparc:visible = no.
    ***/
    pause 0.

    esqcom1[3] = "".
    find first tt-titulo where tt-titulo.empcod = 19 and
                        tt-titulo.titnat = no and
                        tt-titulo.modcod = tt-contrato.modcod and
                        tt-titulo.etbcod = tt-contrato.etbcod and
                        tt-titulo.clifor = tt-contrato.clicod and
                        tt-titulo.titnum = string(tt-contrato.contnum) and
                        tt-titulo.titpar > 0
                  no-lock no-error.
    if avail titulo
    then do.
        find first tit_novacao where 
                   tit_novacao.ger_contnum = tt-contrato.contnum
               and tit_novacao.etbnova     = tt-contrato.etbcod
                           no-lock no-error.
        if avail tit_novacao
        then esqcom1[3] = " Novacao ".
    end.
    
    assign
        recatu1 = ?
        esqpos1 = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-titulo where recid(tt-titulo) = recatu1 no-lock.

    if not available tt-titulo
    then do.
        message "Sem titulos para o contrato" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(tt-titulo).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-titulo where recid(tt-titulo) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field tt-titulo.titpar help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.

            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 4 then 4 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-titulo
                    then leave.
                    recatu1 = recid(tt-titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-titulo
                    then leave.
                    recatu1 = recid(tt-titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-titulo
                then next.
                color display white/red tt-titulo.titpar with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-titulo
                then next.
                color display white/red tt-titulo.titpar with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Consulta "
            then do.
                hide frame f-contrato1 no-pause.
                hide frame f-contrato2 no-pause.
                hide frame f-com1 no-pause.
                run ctb/bsfqtitulo.p (recid(tt-titulo)).
            end.

            if esqcom1[esqpos1] = " Associadas "
            then do.
                run con_ass.p (recid(tt-contrato)).
            end.

            if esqcom1[esqpos1] = " Novacao "
            then do:
                run novacao.
            end.
            if esqcom1[esqpos1] = "Vl.Presente"
            then do.
                hide frame f-contrato2 no-pause.
                hide frame f-com1 no-pause.
                run con_vpres.p (recid(tt-contrato)).
            end.
            view frame f-contrato1.
            view frame f-contrato2.
            view frame f-com1.
            view frame frame-a.
            pause 0.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-titulo).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

end. /* repeat */


procedure frame-a.
    def var vdias as int.
    if tt-titulo.titdtpag <> ?
    then vdias = tt-titulo.titdtpag - tt-titulo.titdtven.
    else vdias = today - tt-titulo.titdtven.

    display
        tt-titulo.etbcod     column-label "Etb" format ">>9"
        tt-titulo.etbcobra   column-label "Cob" format ">>9"
        tt-titulo.titpar
        tt-titulo.titparger when tt-titulo.titparger > 0 column-label "Ori"
        tt-titulo.titsit
        if tt-titulo.titdtpag <> ?
        then tt-titulo.titdtpag  
        else tt-titulo.titdtven  @ tt-titulo.titdtpag column-label "DtVenPag"
        format "99/99/99"
        if tt-titulo.titdtpag <> ?
        then tt-titulo.titvlpag
        else tt-titulo.titvlcob @ tt-titulo.titvlcob column-label "Valor"
                            format ">,>>>,>>9.99"
        tt-titulo.tpcontrato
        vdias label "Dias" format "->>9"
        with frame frame-a /*9*/ screen-lines - 13 down
              column 31 width 50 color white/red row 10
              overlay title " Parcelas ".

end procedure.


procedure color-message.
color display message
        tt-titulo.titpar
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        tt-titulo.titpar
        with frame frame-a.
end procedure.


procedure leitura.
    def input parameter par-tipo as char.
        
    if par-tipo = "pri" 
    then find first tt-titulo where tt-titulo.empcod = 19 and
                       tt-titulo.titnat = no and
                       tt-titulo.modcod = tt-contrato.modcod and
                       tt-titulo.etbcod = tt-contrato.etbcod and
                       tt-titulo.clifor = tt-contrato.clicod and
                       tt-titulo.titnum = string(tt-contrato.contnum)
                                                no-lock no-error.
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then find next tt-titulo  where tt-titulo.empcod = 19 and
                       tt-titulo.titnat = no and
                       tt-titulo.modcod = tt-contrato.modcod and
                       tt-titulo.etbcod = tt-contrato.etbcod and
                       tt-titulo.clifor = tt-contrato.clicod and
                       tt-titulo.titnum = string(tt-contrato.contnum)
                                                no-lock no-error.
             
    if par-tipo = "up" 
    then find prev tt-titulo where tt-titulo.empcod = 19 and
                       tt-titulo.titnat = no and
                       tt-titulo.modcod = tt-contrato.modcod and
                       tt-titulo.etbcod = tt-contrato.etbcod and
                       tt-titulo.clifor = tt-contrato.clicod and
                       tt-titulo.titnum = string(tt-contrato.contnum) 
                                        no-lock no-error.
end procedure.


procedure novacao.

    for each tit_novacao where
                     tit_novacao.ger_contnum = tt-contrato.contnum and
                     tit_novacao.etbnova     = tt-contrato.etbcod
                     no-lock
                     break by tit_novacao.ori_titnum
                           by tit_novacao.ori_titpar:

        find btitulo where btitulo.empcod = tit_novacao.ori_empcod
                       and btitulo.titnat = tit_novacao.ori_titnat
                       and btitulo.modcod = tit_novacao.ori_modcod
                       and btitulo.etbcod = tit_novacao.ori_etbcod
                       and btitulo.clifor = tit_novacao.ori_clifor
                       and btitulo.titnum = tit_novacao.ori_titnum
                       and btitulo.titpar = tit_novacao.ori_titpar
                       and btitulo.titdtemi = tit_novacao.ori_titdtemi
                    no-lock no-error.
        disp
            tit_novacao.ori_etbcod   column-label "Fil" format ">>9"
            tit_novacao.ori_titnum   column-label "Titulo"
            tit_novacao.ori_titpar   column-label "Par"
            tit_novacao.ori_titdtemi column-label "Emissao"
            tit_novacao.ori_titdtven column-label "Vencimen"
            tit_novacao.ori_titvlcob column-label "Val.Orig" 
                                     format ">>>,>>9.99" (total)
            btitulo.titvlpag when avail btitulo format ">>>,>>9.99" /*(total)*/
            btitulo.titjuro  when avail btitulo format ">>,>>9.99" /*(total)*/
            btitulo.moecod   when avail btitulo
            with frame f-titn down centered
                             title " parcelas renegociadas ".
    end.

end procedure.
