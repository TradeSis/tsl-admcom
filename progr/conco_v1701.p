/* HUBSEG 19/10/2021 */

{admcab.i}

def input parameter par-menu as char.


def new shared temp-table ttcontrato
    field contnum   like contrato.contnum
    index x is unique primary contnum asc.


def var wcon like contrato.contnum format ">>>>>>>>>9" init 0.
def var vmenu as log.
def buffer btitulo for titulo.
def var vvlraberto  as dec.
/*def var vvlrabertopresente  as dec.*/


if par-menu <> "Menu"
then do.
    wcon = dec(par-menu) no-error.
    if wcon > 0
    then do.
        find contrato where contrato.contnum = wcon use-index iconcon
                      no-lock no-error.
        if avail contrato
        then vmenu = yes.
    end.
end.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 4
    initial [" Consulta "," Associadas","", "Atualizado"].

form
    esqcom1
    with frame f-com1 row 9 no-box no-labels col 32.

form
    wcon colon 13 validate (wcon > 0, "")
    with frame f-contrato1 width 80 title " Contrato " side-label row 3.

repeat:
    hide frame f-contrato2 no-pause.
    if not vmenu
    then do with frame f-contrato1.
        update wcon.
        find contrato where contrato.contnum = wcon use-index iconcon
                      no-lock no-error.
        if not available contrato
        then do:
            message "Contrato nao cadastrado".
            undo,retry.
        end.
    end.
    
        find clien of contrato no-lock no-error.
        display
            wcon
            contrato.idAdesaoHubSeg colon 55
            contrato.clicod colon 13 label "Cliente"
            clien.clinom no-label when avail clien format "x(41)"
            clien.ciccgc no-label when avail clien format "x(11)"
            contrato.dtinicial format "99/99/9999" colon 13
            contrato.etbcod colon 45
            contrato.banco  colon 13
            contrato.modcod colon 45
            contrato.nro_parcelas  label "Qtd Parcelas" format ">>>"
            
            with frame f-contrato1.

run calculo_aberto.

    display
        contrato.vltotal colon 12 label "Vlr Total"
        contrato.vlentra colon 12 label "Vlr Entrada"
        contrato.vltotal - contrato.vlentra
                 label "Vlr liquido" format "->>>>>,>>9.99" 
        contrato.vlf_principal - contrato.vlf_hubseg @ contrato.vlf_principal label "Principal" colon 12
        contrato.vlf_acrescimo label "Acrescimo" colon 12 format "->>>>>,>>9.99" 

                 
        contrato.vlseguro colon 12 
        contrato.vliof colon 8
        contrato.cet 
        contrato.txjuros colon 12
                                                        skip(1)
        vvlraberto   colon 12 label "Em Aberto"  format "->>>,>>9.99"
        /*vvlrabertopresente   colon 12 label "Vl presente"  format "->>>,>>9.99"                                                       */
        
        

        with side-label width 30 frame f-contrato2 row 09 title " Valores ".
    /***
    if contrato.vlmontante = 0
    then contrato.vlmontante:visible = no.
    if contrato.nroparc = 0
    then contrato.nroparc:visible = no.
    ***/
    pause 0.

esqcom1[3] = "".
find first titulo where titulo.empcod = 19 and
                        titulo.titnat = no and
                        titulo.modcod = contrato.modcod and
                        titulo.etbcod = contrato.etbcod and
                        titulo.clifor = contrato.clicod and
                        titulo.titnum = string(contrato.contnum) and
                        titulo.titpar > 0
                  no-lock no-error.
if avail titulo
then do.
    find first tit_novacao where tit_novacao.ger_contnum = contrato.contnum
                             and tit_novacao.etbnova     = contrato.etbcod
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

            status default "".
            run color-message.
            choose field titulo.titpar help ""
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
                hide frame f-contrato2 no-pause.
                hide frame f-com1 no-pause.
                run bsfqtitulo.p (recid(titulo)).
            end.

            if esqcom1[esqpos1] = " Associadas "
            then do.
                run con_ass.p (recid(contrato)).
            end.

            if esqcom1[esqpos1] = " Novacao "
            then do:
                run novacao.
                view frame f-contrato1.
                view frame f-contrato2.
                view frame f-com1.
                recatu1 = ?.
                leave.
            end.
            if esqcom1[esqpos1] = "Atualizado"
            then do.
                hide frame f-contrato2 no-pause.
                hide frame f-com1 no-pause.
                run con_vpres.p (recid(contrato)).
                pause 0.
                display
                    contrato.txjuros 
                   with frame f-contrato2.
                pause 0.
            end.
            view frame f-contrato1.
            view frame f-contrato2.
            view frame f-com1.
            view frame frame-a.
            pause 0.
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
hide frame frame-b no-pause.
hide frame f-contrato1 no-pause.
hide frame f-contrato2 no-pause.

if vmenu
then leave.

end. /* repeat */


procedure frame-a.
    def var vdias as int.
    if titulo.titdtpag <> ?
    then vdias = titulo.titdtpag - titulo.titdtven.
    else vdias = today - titulo.titdtven.

    
    display
        titulo.etbcod     column-label "Etb" format ">>9"
        titulo.etbcobra   column-label "Cob" format ">>9"
        titulo.titpar
        titulo.titparger when titulo.titparger > 0 column-label "Ori"
        titulo.titsit
        if titulo.titdtpag <> ?
        then titulo.titdtpag  
        else titulo.titdtven  @ titulo.titdtpag column-label "DtVenPag"
        format "99/99/99"
        if titulo.titdtpag <> ?
        then titulo.titvlpag
        else titulo.titvlcob @ titulo.titvlcob column-label "Valor"
                            format "->>,>>9.99"
        titulo.tpcontrato
        vdias label "Dias" format "->>>>9"
        with frame frame-a 8 down
              column 31 width 50 color white/red row 10
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
                                                no-lock no-error.
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then find next titulo  where titulo.empcod = 19 and
                       titulo.titnat = no and
                       titulo.modcod = contrato.modcod and
                       titulo.etbcod = contrato.etbcod and
                       titulo.clifor = contrato.clicod and
                       titulo.titnum = string(contrato.contnum)
                                                no-lock no-error.
             
    if par-tipo = "up" 
    then find prev titulo where titulo.empcod = 19 and
                       titulo.titnat = no and
                       titulo.modcod = contrato.modcod and
                       titulo.etbcod = contrato.etbcod and
                       titulo.clifor = contrato.clicod and
                       titulo.titnum = string(contrato.contnum) 
                                        no-lock no-error.
end procedure.


procedure novacao.
    
    sresp = no.
    message "deseja consultar operacao de novacao completa?" update sresp.
    if sresp
    then do:    
        create ttcontrato.
        ttcontrato.contnum = contrato.contnum.
        run fin/fqanadocorinov.p ("Origem",yes).
        delete ttcontrato.
        return.
    end.

    for each tit_novacao where
                     tit_novacao.ger_contnum = contrato.contnum and
                     tit_novacao.etbnova     = contrato.etbcod
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
            /*btitulo.moecod   when avail btitulo*/
            
            with frame f-titn down centered
                             title " parcelas renegociadas ".
    end.

end procedure.



procedure calculo_aberto.
def var vvlpresente as dec.
    def var vdias as dec.
    def buffer btitulo for titulo.
    vvlraberto = 0.
    for each btitulo where btitulo.empcod = 19 and
                          btitulo.titnat = no and
                          btitulo.modcod = contrato.modcod and
                          btitulo.etbcod = contrato.etbcod and
                          btitulo.clifor = contrato.clicod and
                          btitulo.titnum = string(contrato.contnum) and
                          btitulo.titsit = "LIB"
                    no-lock.
        vvlpresente = btitulo.titvlcob.
        if btitulo.titdtpag = ? and
           btitulo.titdtven > today
        then
            if contrato.txjuro > 0
            then do.
               vdias = (btitulo.titdtven - today) / 30.
               vvlpresente = btitulo.titvlcob / exp(1 + contrato.txjuro / 100,vdias).
            end.
       /* vvlrabertopresente = vvlrabertopresente + vvlpresente.*/
        vvlraberto = vvlraberto + btitulo.titvlcob.
        
    end.
end procedure.


