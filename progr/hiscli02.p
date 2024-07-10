/* helio 26092022 - melhorias - ordenacao por vencimento - ajuste leitura */

/**    Esqueletao de Programacao                          titulo.p */
{/admcom/progr/admcab.i.ssh}
def input parameter par-rec as recid.

def var vinicio         as  log initial no.
def var reccont         as  int.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(14)" extent 5
            initial ["",""].
def var esqcom2         as char format "x(22)" extent 3
            initial ["", "", "Data Exportacao"].
def buffer btitulo      for titulo.
def buffer ctitulo      for titulo.
def buffer b-titu       for titulo.
def var vempcod         like titulo.empcod.
def var vetbcod         like titulo.etbcod.
def var vmodcod         like titulo.modcod.
def var vtitnat         like titulo.titnat.
def var vcliforlab      as char format "x(12)".
def var vclifornom      as char format "x(30)".
def var vclifor         like titulo.clifor.
def var wperdes         as dec format ">9.99 %" label "Perc. Desc.".
def var wperjur         as dec format ">9.99 %" label "Perc. Juros".
def var vtitvlpag       like titulo.titvlpag.
def var vtitvlcob       like titulo.titvlcob.
def var vdtpag          like titulo.titdtpag.
def var vdate           as   date.
def var vetbcobra       like titulo.etbcobra initial 0.
def var vcontrola       as   log initial no.
form esqcom1
    with frame f-com1
    row 3 no-box no-labels side-labels column 1.
form esqcom2
    with frame f-com2
        row screen-lines /*- 2 title " OPERACOES "*/ 
        no-labels side-labels column 1
        centered.

FORM titulo.titnum      colon 15
    titulo.titpar       colon 15
    titulo.titdtemi     colon 15
    titulo.titdtven     colon 15
    titulo.titvlcob     colon 15
    titulo.titnumger    colon 15 label "Tit.Gerado"
    titulo.titparger    colon 15 label "Parc."
    with frame ftitulo
        overlay row 7 color
        white/cyan side-label /*width 39*/.
form titulo.titbanpag colon 15
    banco.bandesc no-label
    titulo.titagepag colon 15
    agenc.agedesc no-label
    titulo.titchepag colon 15
    with frame fbancpg centered
         side-labels 1 down overlay
         color white/cyan row 16
         title " Banco Pago " width 80.
form titulo.bancod   colon 15
    banco.bandesc           no-label
    titulo.agecod   colon 15
    agenc.agedesc         no-label
    with frame fbanco centered
         side-labels 1 down
         color white/cyan row 16 .
form wperjur         colon 16
    titulo.titvljur colon 16 skip(1)
    titulo.titdtdes colon 16
    wperdes         colon 16
    titulo.titvldes colon 16
    with frame fjurdes
         overlay row 7 column 41 side-label
         color white/cyan  width 40.
form
    titulo.titobs[1] at 1
    titulo.titobs[2] at 1
    with no-labels width 80 row 16
         title " Observacoes " frame fobs
         color white/cyan .

form
    titulo.titdtpag colon 13 label "Dt.Pagam"
    titulo.titvlpag  colon 13
    titulo.cobcod    colon 13
    with frame fpag1 side-label
         row 10 color white/cyan
         overlay column 42 width 39 title " Pagamento " .
find contrato where recid(contrato) = par-rec no-lock.
find clien of contrato no-lock.
pause 0.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1
    recatu1  = ?.
bl-princ:
repeat :
    disp esqcom1 with frame f-com1.
    /*
    disp esqcom2 with frame f-com2.
    */ 
    if  recatu1 = ? then
        find first titulo where
            titulo.titnat = no and titulo.empcod = 19 and
            titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
            titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) 
            no-lock no-error.
    else
        find titulo where recid(titulo) = recatu1.
    vinicio = no.
    if  not available titulo then do:
        message "Cadastro de Titulos Vazio".
        pause.
        leave.
    end.
    clear frame frame-a all no-pause.
    display
        titulo.titnum
        titulo.titpar   format ">9" column-label "Fl"
        titulo.titdtemi format "99/99/9999"   column-label "Dt.Emis"
        titulo.titvlcob format ">>>,>>9.99" column-label "Vl Cobrado"
        titulo.titdtven format "99/99/9999"   column-label "Dt.Vecto"
        titulo.titdtpag format "99/99/9999"   column-label "Dt.Pagto"
        titulo.titvlpag when titulo.titvlpag > 0 format ">,>>>,>>9.99"
                                            column-label "Valor Pago"
        titulo.titsit
            with frame frame-a down centered color white/red
                     overlay
            title " Cod. " + string(clien.clicod) + " " + clien.clinom + " " + string(contrato.contnum).

    pause 0.
    recatu1 = recid(titulo).

    if  esqregua then do:
        display esqcom1[esqpos1] with frame f-com1.
        color  display message esqcom1[esqpos1] with frame f-com1.
    end.
    else do:
        display esqcom2[esqpos2] with frame f-com2.
        color display message esqcom2[esqpos2] with frame f-com2.
    end.

    repeat:
        find next titulo where
            titulo.titnat = no and titulo.empcod = 19 and
            titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
            titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) 
            no-lock no-error.
        if not available titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if not vinicio
        then down with frame frame-a.
        display
            titulo.titnum
            titulo.titpar
            titulo.titdtemi
            titulo.titvlcob
            titulo.titdtven
            titulo.titdtpag
            titulo.titvlpag when titulo.titvlpag > 0
            titulo.titsit
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    repeat with frame frame-a:
        find titulo where recid(titulo) = recatu1 no-lock.
        color display messages 
            titulo.titnum titulo.titpar titulo.titdtemi titulo.titvlcob 
            titulo.titdtven titulo.titdtpag titulo.titvlpag  titulo.titsit .
        on f7 recall.
        choose field titulo.titnum
            go-on(cursor-down cursor-up cursor-left cursor-right F7 PF7
                  page-up       page-down
                  tab PF4 F4 ESC return).

        color display normal
            titulo.titnum titulo.titpar titulo.titdtemi titulo.titvlcob 
            titulo.titdtven titulo.titdtpag titulo.titvlpag  titulo.titsit .

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next  titulo where 
                    titulo.titnat = no and titulo.empcod = 19 and
                    titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
                    titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) 
                    no-lock                  no-error.
                if not avail titulo
                then leave.
                recatu1 = recid(titulo).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev  titulo where
                    titulo.titnat = no and titulo.empcod = 19 and
                    titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
                    titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) 
                    no-lock                  no-error.
                if not avail titulo
                then leave.
                recatu1 = recid(titulo).
            end.
            leave.
        end.
        if  keyfunction(lastkey) = "RECALL"
        then do with frame fproc centered row 5 overlay color message
                            side-label:
            prompt-for titulo.titnum colon 10.
            find first titulo where
                        titulo.empcod   = wempre.empcod and
                        titulo.titnat   = vtitnat       and
                        titulo.modcod   = vmodcod       and
                        titulo.etbcod   = vetbcod       and
                        titulo.clifor   = vclifor       and
                        titulo.titnum  >= input titulo.titnum
                        no-lock  no-error.
            recatu1 = if avail titulo
                      then recid(titulo) else ?. leave.
        end.
        on f7 help.
        if  keyfunction(lastkey) = "TAB" then do:
            if  esqregua then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right" then do:
            if  esqregua then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 3
                          then 3
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left" then do:
            if esqregua then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down" then do:
            find next  titulo where
                titulo.titnat = no and titulo.empcod = 19 and
                titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
                titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) 
                no-lock              no-error.
            if  not avail titulo then
                next.
            color display white/red
                titulo.titnum titulo.titpar.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if  keyfunction(lastkey) = "cursor-up" then do:
            find prev titulo where
                titulo.titnat = no and titulo.empcod = 19 and
                titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
                titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) 
                no-lock              no-error.
            if not avail titulo
            then next.
            color display white/red
                titulo.titnum titulo.titpar.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
        
        
        /* helio 26092022 
        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.

          if esqcom2[esqpos2] <> "Pagamento/Cancelamento" or
             esqcom2[esqpos2] <> "Bloqueio/Liberacao"
          then
            hide frame frame-a no-pause.
          display vcliforlab at 6 vclifornom
                with frame frame-b 1 down centered color blue/gray
                width 81 no-box no-label row 5 overlay.
          if  esqregua then do:
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao"
            then do:
                disp
                    titulo.titnum
                    titulo.titpar
                    titulo.titdtemi
                    titulo.titdtven
                    titulo.titvlcob
                    titulo.titnumger
                    titulo.titparger
                        with frame ftitulo.
                disp
                    titulo.titvljur
                    titulo.titdtdes
                    titulo.titvldes
                        with frame fjurdes.
                if titulo.titsit = "PAG"
                then
                    display titulo.etbcobra     colon 20    label "Cobradora"
                            titulo.titdtpag     colon 20    label "Dt.Pagto"
                            titulo.titvlpag     colon 20    label "Vl.Pago"
                            titulo.titjuro      colon 20    label "Juro"
                            titulo.titdesc                  label "Desc"
                            titulo.cxacod       colon 20    label "Caixa"
                            titulo.cxmdat       colon 20    label "Data"
                            titulo.clifor
                            with frame fpag centered row 10 overlay
                                title " Dados de Pagamento " side-label.
            end.

          end.
          else do:
            hide frame f-com2 no-pause.
            if esqcom2[esqpos2]  = "Data Exportacao"
            then do:
                display titulo.datexp
                        with side-label centered row 10 color white/cyan
                             frame fexpo.
                bell.
                message "Deseja marcar para exportar ?" update sresp.
                if sresp
                then do:
                    find titulo where recid(titulo) = recatu1.
                    titulo.datexp = today.
                end.
            end.
          end.
          view frame frame-a.
          view frame f-com2 .
        end.
        */
        
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        display
            titulo.titnum
            titulo.titpar
            titulo.titdtemi
            titulo.titvlcob
            titulo.titdtven
            titulo.titdtpag
            titulo.titvlpag when titulo.titvlpag > 0
            titulo.titsit
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(titulo).
   end.
end.

hide frame f-com1 no-pause.
hide frame f-com2 no-pause.
hide frame frame-a no-pause.

