/*
*
*    banfin.titulo.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
           initial ["Inclusao","Alteracao","Exclusao","Consulta","Agendamento"].
def var esqcom2         as char format "x(22)" extent 3
            initial ["Pagamento/Cancelamento", "Bloqueio/Liberacao",
                        "Data Exportacao"].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de banfin.titulo ",
             " Alteracao da banfin.titulo ",
             " Exclusao  da banfin.titulo ",
             " Consulta  da banfin.titulo ",
             " Listagem  Geral de banfin.titulo "].
def var esqhel2         as char format "x(12)" extent 5.

{admcab.i}

def var vfunfol like func.usercod label "Matricula".
 
def var ii as i.
def var vt   as dec format "->>>,>>>,>>9.99".
def var vtot as dec format "->>>,>>>,>>9.99".
def var vforcod like forne.forcod.
def var i as i.
def var vtotal  as dec format "->>>,>>>,>>9.99".
def var vtitnum like banfin.titulo.titnum.
def var vtitpar like banfin.titulo.titpar.
def var vtitdtemi like banfin.titulo.titdtemi.
def var vcobcod   like banfin.titulo.cobcod.
def var vbancod   like banco.bancod.
def var vagecod   like agenc.agecod.
def var vevecod   like banfin.event.evecod.
def var vtitdtven like banfin.titulo.titdtven.
def var vtitvljur as dec format "->>>,>>>,>>9.99" label "Valor Cobrado".
def var vtitdtdes like banfin.titulo.titdtdes.
def var vtitvldes like banfin.titulo.titvlcob.
def var vtitobs   like banfin.titulo.titobs.
def var vmeta     as char format "x(35)".
def var vrealizada as char format "x(35)".
def buffer xtitulo for banfin.titulo.
def workfile wtit field wrec as recid.
def var vvenc  like banfin.titulo.titdtven.
def var vdia   as int.
def var vpar   like banfin.titulo.titpar.
def var vlog   as log.
def var vok as log.
def var vinicio         as  log initial no.

def shared var vtipo-documento as int.

def shared var vsetcod like setaut.setcod.
def buffer btitulo      for banfin.titulo.
def buffer ctitulo      for banfin.titulo.
def buffer b-titu       for banfin.titulo.
def shared var vempcod         like banfin.titulo.empcod.
def shared var vetbcod         like banfin.titulo.etbcod.
def shared var vmodcod         like banfin.titulo.modcod initial "PEA".
def shared var vtitnat         like banfin.titulo.titnat.
def var vcliforlab      as char format "x(12)".
def var vclifornom      as char format "x(30)".
def shared var vclifor         like banfin.titulo.clifor.
def var wperdes         as dec format "->9.99 %" label "Perc. Desc.".
def var wperjur         as dec format "->9.99 %" label "Perc. Juros".
def var vtitvlpag       as dec format "->>>,>>>,>>9.99".
def var vtitvlcob       as dec format "->>>,>>>,>>9.99".
def var vdtpag          like banfin.titulo.titdtpag.
def var vdate           as   date.
def var vetbcobra       like banfin.titulo.etbcobra initial 0.
def var vcontrola       as   log initial no.
form esqcom1
    with frame f-com1
    row 6 no-box no-labels side-labels column 1.
form esqcom2
    with frame f-com2
        row screen-lines - 1 /*title " OPERACOES " */
        no-labels side-labels column 1
        no-box centered.

FORM banfin.titulo.clifor    colon 15 label "Fornec."
    banfin.titulo.titnum     colon 15
    banfin.titulo.titpar     colon 15
/***    banfin.titulo.titdtemi   colon 15***/
    banfin.titulo.titdtven   colon 15
    banfin.titulo.titvlcob   colon 15 format "->>>,>>>,>>9.99"
/*    banfin.titulo.cobcod     colon 15*/
    with frame ftitulo
        overlay row 7 color
        white/cyan side-label width 39.

FORM vforcod     colon 15 label "Fornecedor"
     vclifornom  no-label format "x(25)"
     vfunfol     label "Matricula" colon 15
     func.funnom no-label
     vmeta       label "Meta"
     vrealizada  label "Realizada"
     vtitnum     colon 15
     vtitpar     colon 15
/***     vtitdtemi   colon 15***/
     vtitdtven   colon 15
     vtitvlcob   colon 15 format "->>>,>>>,>>9.99" 
     /***
     vcobcod     colon 15
     banfin.cobra.cobnom no-label format "x(15)"
     banfin.titulo.modcod colon 15
     banfin.modal.modnom no-label format "x(15)"
     banfin.titulo.evecod colon 15
     banfin.event.evenom no-label format "x(15)"
     ***/
     with frame ftit overlay row 7 color white/cyan side-label width 60.

FORM vforcod     colon 15
     vclifornom  no-label format "x(25)"
     vfunfol     label "Matricula" colon 15
     func.funnom no-label colon 15 format "x(20)"
     vmeta       colon 15 label "Meta"
     vrealizada  colon 15 label "Realizada"
     vtitnum     colon 15
     vtitpar     colon 15
/***     vtitdtemi   colon 15***/
     vtotal      colon 15
     /***
     vcobcod     colon 15
     banfin.cobra.cobnom no-label format "x(15)"
     vevecod colon 15
     banfin.event.evenom no-label format "x(15)"
     ***/
     with frame ftit2 overlay row 7 color white/cyan side-label width 60.

form banfin.titulo.titbanpag colon 15
    banco.bandesc no-label
    banfin.titulo.titagepag colon 15
    agenc.agedesc no-label
    banfin.titulo.titchepag colon 15
    with frame fbancpg centered
         side-labels 1 down overlay
         color white/cyan row 16
         title " Banco Pago " width 80.

form banfin.titulo.bancod   colon 15
    banco.bandesc           no-label
    banfin.titulo.agecod   colon 15
    agenc.agedesc         no-label
    with frame fbanco centered
         side-labels 1 down
         color white/cyan row 16 .

form vbancod   colon 15
    banco.bandesc           no-label
    vagecod   colon 15
    agenc.agedesc         no-label
    with frame fbanco2 centered
         side-labels 1 down
         color white/cyan row 16 .
         /***
form wperjur         colon 16
    banfin.titulo.titvljur colon 16 skip(1)
    banfin.titulo.titdtdes colon 16
    wperdes         colon 16
    banfin.titulo.titvldes colon 16
    with frame fjurdes
         overlay row 7 column 41 side-label
         color white/cyan  width 40.
         ***/

form wperjur         colon 16
    vtitvljur colon 16 skip(1)
    vtitdtdes colon 16
    wperdes         colon 16
    vtitvldes colon 16 with frame fjurdes2
         overlay row 7 column 41 side-label
         color white/cyan  width 40.

form
    vtitobs[1] at 1
    vtitobs[2] at 1
    with no-labels width 80 row 16
         title " Observacoes " frame fobs2
         color white/cyan .

form
    banfin.titulo.titobs[1] at 1
    banfin.titulo.titobs[2] at 1
    with no-labels width 80 row 16
         title " Observacoes " frame fobs
         color white/cyan .

form
    banfin.titulo.titdtpag colon 15 label "Dt.Pagam"
    banfin.titulo.titvlpag  colon 15 format "->>>,>>>,>>9.99"
    /***
    banfin.titulo.cobcod    colon 15
    banfin.titulo.titvljur  colon 15 column-label "Juros"
    banfin.titulo.titvldes  colon 15 column-label "Desconto"
    ***/
    with frame fpag1 side-label
         row 10 color white/cyan
         overlay column 42 width 39 title " Pagamento " .

esqcom1[5] = "".
esqcom2 = "".

def var v-agendado as char format "x" label "A".
def var taxa-ante as dec format ">>9.99".
def var deletou-lancxa as log.
def var vfrecod like frete.frecod.
def var vv as int.
def var vlfrete like plani.platot.
def var vfre as int format "9" initial 1.
def buffer ftitulo for banfin.titulo.
def buffer ztitulo for banfin.titulo.
def var vdt like plani.pladat.
def var vcompl like lancxa.comhis format "x(50)".
def var vlanhis like lancxa.lanhis.
def var vnumlan as int.
def buffer blancxa for lancxa.
def var vlancod like lancxa.lancod.
def var vtitle  as char.
if avail setaut
then vtitle = setaut.setnom.
else vtitle = "FINANCEIRO".
form with frame ff1 title "   " + vtitle  + "   ".

def buffer bbtitulo       for banfin.titulo.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels column 1 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find banfin.titulo where recid(banfin.titulo) = recatu1 no-lock.
    if not available banfin.titulo
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(banfin.titulo).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available banfin.titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find banfin.titulo where recid(banfin.titulo) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(banfin.titulo.titnum)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(banfin.titulo.titnum)
                                        else "".
            run color-message.
            choose field banfin.titulo.titnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) color white/black.
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail banfin.titulo
                    then leave.
                    recatu1 = recid(banfin.titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail banfin.titulo
                    then leave.
                    recatu1 = recid(banfin.titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail banfin.titulo
                then next.
                color display white/red banfin.titulo.titnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail banfin.titulo
                then next.
                color display white/red banfin.titulo.titnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
                form banfin.titulo.modcod
                     banfin.modal.modnom no-label
                     banfin.titulo.titnum
                     banfin.titulo.titpar
/*                     banfin.titulo.titdtemi*/
                     banfin.titulo.titdtven
                     banfin.titulo.titvlcob format "->>>,>>>,>>9.99"
                     /***
                     banfin.titulo.cobcod ***/ 
                 with frame f-titulo color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-titulo on error undo.
                    create banfin.titulo.

                    recatu1 = recid(banfin.titulo).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-titulo.
                find banfin.modal of banfin.titulo no-lock no-error.
                disp banfin.titulo.modcod
                     modal.modnom when available modal no-label
                     banfin.titulo.titnum
                     banfin.titulo.titpar
/*                     banfin.titulo.titdtemi*/
                     banfin.titulo.titdtven
                     banfin.titulo.titvlcob format "->>>,>>>,>>9.99"
                     /***
                     banfin.titulo.cobcod ***/ with frame f-titulo.                    
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" banfin.titulo.titnum
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next banfin.titulo where true no-error.
                    if not available banfin.titulo
                    then do:
                        find banfin.titulo where recid(banfin.titulo) = recatu1.
                        find prev banfin.titulo where true no-error.
                    end.
                    recatu2 = if available banfin.titulo
                              then recid(banfin.titulo)
                              else ?.
                    find banfin.titulo where recid(banfin.titulo) = recatu1
                            exclusive.
                    delete banfin.titulo.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    /***
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run lbanfin.titulo.p (input 0).
                    else run lbanfin.titulo.p (input banfin.titulo.<tab>cod).
                    ***/
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(banfin.titulo).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    if acha("AGENDAR",banfin.titulo.titobs[2]) <> ? and
       banfin.titulo.titdtven <> date(acha("AGENDAR",banfin.titulo.titobs[2])) 
    then v-agendado = "*".
    else v-agendado = "".
    display banfin.titulo.titnum format "x(7)"
            banfin.titulo.titpar   format ">9"
        banfin.titulo.titvlcob format "->>,>>9.99" column-label "Vl.Cobrado"
        banfin.titulo.titdtven format "99/99/9999"   column-label "Dt.Vecto"
        banfin.titulo.titdtpag format "99/99/9999"   column-label "Dt.Pagto"
        banfin.titulo.titvlpag 
        when banfin.titulo.titvlpag > 0 format "->>,>>9.99"
                                            column-label "Valor Pago"
        banfin.titulo.titvljur column-label "Juros" format "->,>>9.9"
        banfin.titulo.titvldes column-label "Desc"  format ">>,>>9.9"
        banfin.titulo.titsit column-label "S" format "X"
        v-agendado
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        banfin.titulo.titnum
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        banfin.titulo.titnum
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        if vclifor = ?
        then find first banfin.titulo use-index titsit where 
                       banfin.titulo.empcod = wempre.empcod   and
                       banfin.titulo.titnat   = vtitnat       and
                       banfin.titulo.modcod   = vmodcod       and
                       banfin.titulo.titsit   = "LIB"         and
                       banfin.titulo.etbcod   = vetbcod       and
                       recid(banfin.titulo) <> recatu1 and
                       banfin.titulo.titbanpag = vsetcod no-error.
        else find first banfin.titulo use-index titsit
                where banfin.titulo.empcod   = wempre.empcod and
                      banfin.titulo.titnat   = vtitnat       and
                      banfin.titulo.modcod   = vmodcod       and
                      banfin.titulo.titsit   = "LIB"         and
                      banfin.titulo.etbcod   = vetbcod       and
                       recid(banfin.titulo) <> recatu1 and                      
                      banfin.titulo.clifor   = vclifor no-error.
    else  
        if vclifor = ?
        then find last banfin.titulo use-index titsit where 
                       banfin.titulo.empcod = wempre.empcod   and
                       banfin.titulo.titnat   = vtitnat       and
                       banfin.titulo.modcod   = vmodcod       and
                       banfin.titulo.titsit   = "LIB"         and
                       banfin.titulo.etbcod   = vetbcod       and
                       recid(banfin.titulo) <> recatu1 and
                       banfin.titulo.titbanpag = vsetcod no-error.
        else find last banfin.titulo use-index titsit
                where banfin.titulo.empcod   = wempre.empcod and
                      banfin.titulo.titnat   = vtitnat       and
                      banfin.titulo.modcod   = vmodcod       and
                      banfin.titulo.titsit   = "LIB"         and
                      banfin.titulo.etbcod   = vetbcod       and
                       recid(banfin.titulo) <> recatu1 and                      
                      banfin.titulo.clifor   = vclifor no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        if vclifor = ?
        then find next banfin.titulo use-index titsit where 
                       banfin.titulo.empcod = wempre.empcod   and
                       banfin.titulo.titnat   = vtitnat       and
                       banfin.titulo.modcod   = vmodcod       and
                       banfin.titulo.titsit   = "LIB"         and
                       banfin.titulo.etbcod   = vetbcod       and
                       recid(banfin.titulo) <> recatu1 and
                       banfin.titulo.titbanpag = vsetcod no-error.
        else find next banfin.titulo use-index titsit
                where banfin.titulo.empcod   = wempre.empcod and
                      banfin.titulo.titnat   = vtitnat       and
                      banfin.titulo.modcod   = vmodcod       and
                      banfin.titulo.titsit   = "LIB"         and
                      banfin.titulo.etbcod   = vetbcod       and
                       recid(banfin.titulo) <> recatu1 and                      
                      banfin.titulo.clifor   = vclifor no-error.
    else  
        if vclifor = ?
        then find prev banfin.titulo use-index titsit where 
                       banfin.titulo.empcod = wempre.empcod   and
                       banfin.titulo.titnat   = vtitnat       and
                       banfin.titulo.modcod   = vmodcod       and
                       banfin.titulo.titsit   = "LIB"         and
                       banfin.titulo.etbcod   = vetbcod       and
                       /*banfin.titulo.clifor   = vclifor       and*/
                       recid(banfin.titulo) <> recatu1 and
                       banfin.titulo.titbanpag = vsetcod no-error.
        else find prev banfin.titulo use-index titsit
                where banfin.titulo.empcod   = wempre.empcod and
                      banfin.titulo.titnat   = vtitnat       and
                      banfin.titulo.modcod   = vmodcod       and
                      banfin.titulo.titsit   = "LIB"         and
                      banfin.titulo.etbcod   = vetbcod       and
                       recid(banfin.titulo) <> recatu1 and                      
                      banfin.titulo.clifor   = vclifor no-error.
if par-tipo = "up" 
then                  
    if esqascend   
    then 
        if vclifor = ?
        then find prev banfin.titulo use-index titsit where 
                       banfin.titulo.empcod = wempre.empcod   and
                       banfin.titulo.titnat   = vtitnat       and
                       banfin.titulo.modcod   = vmodcod       and
                       banfin.titulo.titsit   = "LIB"         and
                       banfin.titulo.etbcod   = vetbcod       and
                       recid(banfin.titulo) <> recatu1 and
                       banfin.titulo.titbanpag = vsetcod no-error.
        else find prev banfin.titulo use-index titsit
                where banfin.titulo.empcod   = wempre.empcod and
                      banfin.titulo.titnat   = vtitnat       and
                      banfin.titulo.modcod   = vmodcod       and
                      banfin.titulo.titsit   = "LIB"         and 
                      banfin.titulo.etbcod   = vetbcod       and
                       recid(banfin.titulo) <> recatu1 and                      
                      banfin.titulo.clifor   = vclifor no-error.
    else   
        if vclifor = ?
        then find next banfin.titulo use-index titsit where 
                       banfin.titulo.empcod = wempre.empcod   and
                       banfin.titulo.titnat   = vtitnat       and
                       banfin.titulo.modcod   = vmodcod       and
                       banfin.titulo.titsit   = "LIB"         and
                       banfin.titulo.etbcod   = vetbcod       and
                       recid(banfin.titulo) <> recatu1 and
                       banfin.titulo.titbanpag = vsetcod no-error.
                       
        else find next banfin.titulo use-index titsit
                where banfin.titulo.empcod   = wempre.empcod and
                      banfin.titulo.titnat   = vtitnat       and
                      banfin.titulo.modcod   = vmodcod       and
                      banfin.titulo.titsit   = "LIB"         and
                      banfin.titulo.etbcod   = vetbcod       and
                      recid(banfin.titulo) <> recatu1        and
                      banfin.titulo.clifor   = vclifor no-error.

message par-tipo avail banfin.titulo esqascend wempre.empcod vtitnat vmodcod vetbcod recatu1 vclifor 
view-as alert-box.         

end procedure.
         
