{admcab.i}

def input parameter par-rec as recid.

find plani where recid(plani) = par-rec no-lock.
find tipmov of plani no-lock.

def var vtitnum like titulo.titnum.

def temp-table wffatura
    field fatnum    as char format "x(15)"
    field fatdtemi  as date
    field rectitulo as recid
    field recfatura as recid
    field dtven     as date
    field dtpag     as date
    field vlcob     as dec
    field vlpag     as dec
    field saldo     as dec
    field dias      as int format ">>>"
    field contrato  as log format "C/".

/* Venda a vista sem contrato */
if tipmov.movtvenda and
   tipmov.movtdev = no and
   plani.crecod = 1
then do.    
    create wffatura.
    for each titulo where titulo.empcod = 19
                      and titulo.titnat = tipmov.movtnat
                      and titulo.modcod = plani.modcod
                      and titulo.etbcod = plani.etbcod
                      and titulo.clifor = plani.desti
                      and titulo.titnum = plani.serie + string(plani.numero)
                      and titulo.titdtemi = plani.pladat
                    no-lock.
        assign
            wffatura.fatnum   = titulo.titnum
            wffatura.fatdtemi = titulo.titdtemi
            wffatura.rectitulo = recid(titulo)
            wffatura.dtven    = titulo.titdtven
            wffatura.dtpag    = titulo.titdtpag
            wffatura.vlcob    = wffatura.vlcob + titulo.titvlcob
            wffatura.vlpag    = wffatura.vlpag + titulo.titvlpag.
    end.
end.
else if tipmov.movtvenda and
        tipmov.movtdev = no and
        plani.crecod = 2
then do.
    for each contnf where contnf.etbcod = plani.etbcod
                      and contnf.placod = plani.placod
                    no-lock.
        find contrato of contnf no-lock.
        create wffatura.
        assign
            wffatura.fatnum   = string(contrato.contnum)
            wffatura.fatdtemi = plani.dtincl
            wffatura.recfatura = recid(contrato)
            wffatura.vlcob    = contrato.vltotal
            wffatura.contrato = contrato.banco = 10.

        for each titulo where titulo.empcod = 19
                          and titulo.titnat = tipmov.movtnat
                          and titulo.modcod = plani.modcod
                          and titulo.etbcod = plani.etbcod
                          and titulo.clifor = plani.desti
                          and titulo.titnum = string(contrato.contnum)
                        no-lock
                        by titulo.titdtpag.
            assign
                wffatura.dtpag    = if titulo.titdtpag <> ?
                                    then titulo.titdtpag else wffatura.dtpag
                wffatura.vlpag    = wffatura.vlpag + titulo.titvlpag.
        end.
    end.
end.
else if tipmov.movtvenda and
        tipmov.movtdev
then do.
    create wffatura.
    for each titulo where titulo.empcod = 19
                      and titulo.titnat = tipmov.movtnat
                      and titulo.modcod = plani.modcod
                      and titulo.etbcod = plani.etbcod
                      and titulo.titnum = string(plani.numero)
                      and titulo.titdtemi = plani.pladat
                    no-lock.
        assign
            wffatura.fatnum   = titulo.titnum
            wffatura.fatdtemi = titulo.titdtemi
            wffatura.rectitulo = recid(titulo)
            wffatura.dtven    = titulo.titdtven
            wffatura.dtpag    = titulo.titdtpag
            wffatura.vlpag    = wffatura.vlpag + titulo.titvlpag
            wffatura.vlcob    = wffatura.vlcob + titulo.titvlcob.
    end.
end.
else do.
    create wffatura.
    for each titulo where titulo.empcod = 19
                      and titulo.titnat = tipmov.movtnat
                      and titulo.modcod = tipmov.modcod
                      and titulo.etbcod = plani.etbcod
                      and titulo.clifor = plani.emite
                      and titulo.titnum = string(plani.numero)
                    no-lock.
        assign
            wffatura.fatnum   = titulo.titnum
            wffatura.fatdtemi = titulo.titdtemi
            wffatura.rectitulo = recid(titulo)
            wffatura.dtven    = titulo.titdtven
            wffatura.dtpag    = titulo.titdtpag
            wffatura.vlcob    = wffatura.vlcob + titulo.titvlcob
            wffatura.vlpag    = wffatura.vlpag + titulo.titvlpag.
    end.
end.

/*
*
*    wffatura.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    init [" Consulta ", " Contrato "," Moedas ", ""].

form
    esqcom1 with frame f-com1 row 11 no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find wffatura where recid(wffatura) = recatu1 no-lock.
    if not available wffatura
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(wffatura).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available wffatura
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find wffatura where recid(wffatura) = recatu1 no-lock.
            if wffatura.recfatura <> ?
            then esqcom1[2] = " Contrato ".
            else esqcom1[2] = "".
            disp esqcom1 with frame f-com1.

            status default "".

            run color-message.
            choose field wffatura.fatnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            run color-normal.

            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
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
                    if not avail wffatura
                    then leave.
                    recatu1 = recid(wffatura).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail wffatura
                    then leave.
                    recatu1 = recid(wffatura).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail wffatura
                then next.
                color display white/red wffatura.fatnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail wffatura
                then next.
                color display white/red wffatura.fatnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
            hide frame f-com1  no-pause.
/***
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
***/

            if esqcom1[esqpos1] = " Consulta "
            then do:
/***
                     run fatsitco.p (input recid(fatura),
                                     input 3 /* row 3 */ ) .
***/
                 if wffatura.recfatura = ?
                 then run bsfqtitulo.p (wffatura.rectitulo).
                 else run fqtitfat.p (wffatura.recfatura,
                                      input 11 /* row f-com1 */).
            end.
/*            if esqcom1[esqpos1] = " Contrato "
            then run contratoimp.p (wffatura.recfatura).*/

            if esqcom1[esqpos1] = " Contrato "
            then do with frame f-contrato row 6 2 col centered.
                find contrato where recid(contrato) = wffatura.recfatura
                              no-lock.
                disp contrato.
                disp contrato.contnum format ">>>>>>>>>9".
            end.

            if esqcom1[esqpos1] = " Moedas "
            then do.
                find cmon where cmon.etbcod = plani.etbcod
                            and cmon.cxacod = int(plani.serie)
                          no-lock no-error.
                if avail cmon
                then do.
                    find first pdvdoc where pdvdoc.etbcod  = plani.etbcod
                                        and pdvdoc.cmocod  = cmon.cmocod
                                        and pdvdoc.datamov = plani.dtincl
                                        and pdvdoc.placod  = plani.placod
                                      no-lock no-error.
                    if avail pdvdoc
                    then do.
                        find pdvmov of pdvdoc no-lock.
                        hide frame f-com1 no-pause.
                        disp
                            cmon.cxacod
                            pdvdoc.sequencia
                            pdvmov.valortroco
                            with frame f-lancpdv side-label no-box centered
                                row 11.
                        run dpdv/pdvcforma.p (input recid(pdvdoc)).
                        hide frame f-lancpdv.
                    end.
                end.
            end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(wffatura).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    display
        wffatura.fatnum          column-label "Numero"
        wffatura.fatdtemi        column-label "Emissao"  format "99/99/99"
        wffatura.vlcob           column-label "Total"    format ">>>>>9.99"
        wffatura.dtpag           column-label "Ult.Pgto" format "99/99/99"
        wffatura.vlpag           column-label "Vlr.Pago" format ">>>>>9.99"
        wffatura.dtven           column-label "Prox.Vto" format "99/99/99"
        wffatura.dias            column-label "Atr"      format ">>>"
        wffatura.saldo           column-label "Saldo"    format ">>>>>9.99"
        wffatura.contrato        no-label
        with frame frame-a 6 down centered color white/red row 12.
end procedure.


procedure color-message.
color display message
        wffatura.fatnum
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        wffatura.fatnum
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then   find first wffatura  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then   find next wffatura   no-lock no-error. 

if par-tipo = "up" 
then   find prev wffatura   no-lock no-error.
        
end procedure.

