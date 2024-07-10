/*
Set/2017 - Nova novacao
*/
{admcab.i}

def input parameter par-recid as recid.

/*def var auxtxcalculo  as dec.*/
def var auxtxoperacao as dec format ">>>>>9.99999".
def var vvlrttcontr as dec.
def var auxvlrfinanc  as dec.
def var auxqtdparcela as dec format ">>>9".
def var vvlpresente as dec decimals 2.
def var vtipo_txjur as log.
def var vvlraberto  as dec.
def var vvlrdivida  as dec.

def var vjuros as dec.
find contrato where recid(contrato) = par-recid no-lock.
find clien of contrato no-lock.

if contrato.txjuros = 0
then do:
    run credprjuros.p (par-recid,
                       "Grava",
                       output auxvlrfinanc,
                       output vvlrttcontr,
                       output auxqtdparcela,
                       output auxtxoperacao).
                               
    find current contrato no-lock.
end.

vvlrttcontr = contrato.vltotal - contrato.vlentra.
 
disp
    contrato.vltotal colon 15 format ">>>,>>9.99"
    contrato.vlentra colon 15 format ">>>,>>9.99"
    contrato.txjuros colon 15
    with frame f-contrato1 side-label width 30 row 9 title " Contrato ".

disp
    contrato.vlf_principal colon 15 label "Vlr Financiado" format ">>>,>>9.99"
    
    vvlrttcontr  colon 15 label "Contrato s/ent" 
    contrato.nro_parcela  colon 15 label "Qtde Parcelas"
    skip(1)
    vvlraberto   colon 15 label "Saldo aberto"
    vvlrdivida   colon 15 label "Divida"

    contrato.txjuro  colon 15 label "Juro ao Mes"
    with frame f-result side-label width 30 row 14 title " Calculo ".

pause 0.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(16)" extent 3
    initial [" Consulta ",/**"Troca Taxa Juro",**/ ""].

form
    esqcom1
    with frame f-com1 row 9 no-box no-labels col 31.

run calculo_aberto.

assign
    recatu1 = ?
    esqpos1 = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find titulo where recid(titulo) = recatu1 no-lock.
    if not available titulo
    then do.
        message "Sem titulos para o contrato" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(titulo).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find titulo where recid(titulo) = recatu1 no-lock.

            status default "Taxa de Juros=" + string(auxtxoperacao).

            run color-message.
            choose field titulo.titpar help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            run color-normal.
            status default "".

            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 3 then 3 else esqpos1 + 1.
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
                    if not avail titulo
                    then leave.
                    recatu1 = recid(titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail titulo
                    then leave.
                    recatu1 = recid(titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail titulo
                then next.
                color display white/red titulo.titpar with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail titulo
                then next.
                color display white/red titulo.titpar with frame frame-a.
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
                hide frame f-resuilt   no-pause.
                run bsfqtitulo.p (recid(titulo)).
                view frame f-contrato1.
                view frame f-result.
                pause 0.
            end.
            /*
            if esqcom1[esqpos1] = "Troca Taxa Juro"
            then do.
                vtipo_txjur = not vtipo_txjur.
                if vtipo_txjur
                then auxtxcalculo = contrato.txjuros.
                else auxtxcalculo = auxtxoperacao.
                run calculo_aberto.
                leave.
            end.
            */
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(titulo).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.


procedure calculo_aberto.

    def var vdias as dec.
    def buffer btitulo for titulo.
    vvlraberto = 0.
    vvlrdivida = 0.
    for each btitulo where btitulo.empcod = 19 and
                          btitulo.titnat = no and
                          btitulo.modcod = contrato.modcod and
                          btitulo.etbcod = contrato.etbcod and
                          btitulo.clifor = contrato.clicod and
                          btitulo.titnum = string(contrato.contnum) and
                          btitulo.titsit = "LIB"
                    no-lock.
        vvlraberto = vvlraberto + btitulo.titvlcob.

        vvlpresente = btitulo.titvlcob.
        if btitulo.titdtpag = ? and
           btitulo.titdtven > today
        then
            if contrato.txjuro > 0
            then do.
               vdias = (btitulo.titdtven - today) / 30.
               vvlpresente = btitulo.titvlcob / exp(1 + contrato.txjuro / 100,vdias).
            end.

        if btitulo.titdtven < today
        then do:
            run juro_titulo.p (if clien.etbcad = 0 then btitulo.etbcod else clien.etbcad,
                               btitulo.titdtven,
                               btitulo.titvlcob,
                               output vjuros).
            vvlpresente = vvlpresente + vjuros. 
        end.    
            
        vvlrdivida = vvlrdivida + vvlpresente.
    end.
    disp vvlraberto vvlrdivida with frame f-result.
    pause 0.
end procedure.


procedure frame-a.
    def var vdias as dec.

    if titulo.titsit = "LIB"
    then vvlpresente = titulo.titvlcob.
    else vvlpresente = 0.

    if titulo.titdtpag = ? and
       titulo.titdtven > today
    then
        if contrato.txjuro > 0
        then do.
            vdias = (titulo.titdtven - today) / 30.
            vvlpresente = titulo.titvlcob / exp(1 + contrato.txjuro / 100, vdias).
        end.

    if titulo.titdtpag <> ?
    then vdias = titulo.titdtpag - titulo.titdtven.
    else vdias = today - titulo.titdtven.

    if titulo.titdtven < today
    then do:
        run juro_titulo.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad,
                           titulo.titdtven,
                           titulo.titvlcob,
                           output vjuros).
        vvlpresente = vvlpresente + vjuros. 
        
    end.    
    display
        titulo.etbcod     column-label "Etb" format ">>9"
        titulo.etbcobra   column-label "Cob" format ">>9"
        titulo.titpar     format ">9"
        titulo.titsit
        if titulo.titdtpag <> ?
        then titulo.titdtpag
        else titulo.titdtven  @ titulo.titdtpag column-label "Vect/Pag"
                                                format "99/99/99"
        if titulo.titdtpag <> ?
        then titulo.titvlpag
        else titulo.titvlcob @ titulo.titvlcob column-label "Valor"
                            format ">>>>9.99"
        titulo.tpcontrato
        vvlpresente label "V.Pres." format ">>>>9.99"
        vdias label "Dias" format "->>>9"
        with frame frame-a /*9*/ screen-lines - 13 down
              column 30 width 51 color white/red row 10
              overlay title " Parcelas ".

end procedure.


procedure color-message.
    color display message
        titulo.titpar
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        titulo.titpar
        with frame frame-a.
end procedure.


procedure leitura.
    def input parameter par-tipo as char.
        
    if par-tipo = "pri" 
    then find first titulo where titulo.empcod = 19 and
                                titulo.titnat = no and
                                titulo.modcod = contrato.modcod and
                                titulo.etbcod = contrato.etbcod and
                                titulo.clifor = contrato.clicod and
                                titulo.titnum = string(contrato.contnum)
                                and titulo.titsit = "LIB"
                          no-lock no-error.
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then find next titulo where titulo.empcod = 19 and
                                titulo.titnat = no and
                                titulo.modcod = contrato.modcod and
                                titulo.etbcod = contrato.etbcod and
                                titulo.clifor = contrato.clicod and
                                titulo.titnum = string(contrato.contnum)
                                and titulo.titsit = "LIB"
                                
                          no-lock no-error.
             
    if par-tipo = "up" 
    then find prev titulo where titulo.empcod = 19 and
                                titulo.titnat = no and
                                titulo.modcod = contrato.modcod and
                                titulo.etbcod = contrato.etbcod and
                                titulo.clifor = contrato.clicod and
                                titulo.titnum = string(contrato.contnum) 
                                and titulo.titsit = "LIB"
                                
                          no-lock no-error.
end procedure.

