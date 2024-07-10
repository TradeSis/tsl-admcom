/* cyber/lotcrectr_cyber.p                            */

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" ","  "," ","  ","  "].
def var esqcom2         as char format "x(12)" extent 5
    initial ["  ", " ", " "].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

{admcab.i}

def buffer bLotCreContrato      for LotCreContrato.
def var vLotCreContrato         like LotCreContrato.ltcrecod.
def var vnum              as int.
def var vlotcre           as recid.

def var vclfnom           as char format "x(30)".
def var vcgccpf           as char.

def input parameter par-reclotcre  as recid.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.
form with frame f-LotCreContrato.

def temp-table wffatura
    field contnum    like contrato.contnum
    field fatdtemi  as date
    field rectitulo as recid
    field dtven     as date
    field dtpag     as date
    field vlpag     as dec
    field saldo     as dec
    field dias      as int format ">>>"
    index contnum is primary unique contnum.

for each wffatura.
    delete wffatura.
end.

if lotcre.ltdtenvio <> ?
then assign
        esqcom1[1] = ""
        esqcom1[3] = "".

esqcom1[1] = "". /* Inclusao  */
esqcom1[4] = "". /* Cliente   */
esqcom1[5] = "". /* Historico */

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.

disp
    lotcre.ltcrecod format ">>>>>>>>9"  label "Lote" colon 8
    lotcre.ltcredt
    "- " lotcre.ltselecao no-label
    with frame f-cab2 row 3 no-box color message side-label centered.
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
        if esqascend
        then
            find first LotCreContrato of lotcre no-lock no-error.
        else
            find last LotCreContrato of lotcre no-lock no-error.
    else
        find LotCreContrato where recid(LotCreContrato) = recatu1 no-lock.
    if not available LotCreContrato
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.
    else leave. 
    recatu1 = recid(LotCreContrato).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next LotCreContrato of lotcre no-lock.
        else
            find prev LotCreContrato of lotcre no-lock.
        if not available LotCreContrato
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
            find LotCreContrato where recid(LotCreContrato) = recatu1 no-lock.
            if lotcretp.titnat = no
            then do.
            end.
            if lotcre.ltdtenvio <> ? or
               LotCreContrato.ltvalidacao <> ""
            then esqcom1[3] = "".
            else if LotCreContrato.ltsituacao
                 then esqcom1[3] = " Desmarca ".
                 else esqcom1[3] = " Marca ".
            esqcom1[3] = "".
            disp esqcom1 with frame f-com1.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(LotCreContrato.ltcrecod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(LotCreContrato.ltcrecod)
                                        else "".

            choose field LotCreContrato.contnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).

            status default "".

        end.
        {esquema.i &tabela = "LotCreContrato"
                   &campo  = "LotCreContrato.contnum"
                   &where  = "of lotcre"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:

            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclui "
                then do on error undo.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    vlotcre = recid(lotcre).
                    run value(lotcretp.selecao + ".p")
                                     (input-output vlotcre,
                                      input recid(lotcretp),
                                      input " Por Cliente ").
                    view frame f-com1.
                    view frame f-com2.
                    recatu1 = recid(LotCreContrato).
                    leave.
                end.
                if esqcom1[esqpos1] = " Titulos "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run lotcre3.p (if lotcretp.titnat
                                   then recid(forne)
                                   else recid(clien),
                                   input recid(lotcre)).
                    view frame f-com1.
                    view frame f-com2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Cliente "
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    if clien.tippes
                    then run rcpfis.p ("RECID=" + string(recid(clien))).
                    else run rcpjur.p ("RECID=" + string(recid(clien))).
                    /*run  fqtagcad.p (input recid(clien)).*/
                    view frame f-com1.
                    view frame f-com2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Historico "
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    run historico.
                    view frame f-com1.
                    view frame f-com2.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " Pesquisa "
                then do:
                    prompt-for LotCreContrato.contnum validate(true, "")
                               with frame f-pesq side-label.
                    find bLotCreContrato where 
                                     bLotCreContrato.ltcrecod = LotCreContrato.ltcrecod
                                 and bLotCreContrato.contnum   = input LotCreContrato.contnum
                                   no-lock no-error.
                    if avail bLotCreContrato
                    then recatu1 = recid(bLotCreContrato).
                    leave.
                end.
                if esqcom2[esqpos2] = " Consulta "
                then do.
                    disp LotCreContrato except 
                        LotCreContrato.contnum with frame f-LotCreContrato.
                    disp    LotCreContrato.contnum format "9999999999" 
                            vcgccpf format "99999999999999"
                            with frame f-LotCreContrato.
                end.
            end.
        end.
        if not esqvazio
        then run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(LotCreContrato).
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
hide frame f-sub   no-pause.

procedure frame-a.
    def var vsituacao as log.
    vsituacao = LotCreContrato.ltsituacao = yes /* marcado */ and
                LotCreContrato.ltvalida   = ""  /* valido */.
    
    find cyber_contrato of LotCreContrato no-lock.     

    for each wffatura.
        delete wffatura.
    end.
    create wffatura. 
    assign wffatura.contnum   = cyber_contrato.contnum 
           wffatura.fatdtemi = cyber_contrato.dtinicial .
    for each titulo where titulo.empcod = 19
                          and titulo.titnat = no
                          and titulo.modcod = "CRE"
                          and titulo.etbcod = contrato.etbcod
                          and titulo.clifor = contrato.clicod
                          and titulo.titnum = string(contrato.contnum)
                        no-lock.
            assign
                wffatura.dtpag    = if titulo.titdtpag <> ?
                                    then titulo.titdtpag else wffatura.dtpag
                wffatura.vlpag    = wffatura.vlpag + titulo.titvlpag.
    end.
    find wffatura of contrato no-lock.
    display
        LotCreContrato.contnum   format "9999999999"
        wffatura.fatdtemi        column-label "Emissao"  format "99/99/99"
        wffatura.dtpag           column-label "Ult.Pgto" format "99/99/99"
        wffatura.vlpag           column-label "Vlr.Pago" format ">>>,>>9.99"
        wffatura.dtven           column-label "Prox.Vto" format "99/99/99"
        wffatura.dias            column-label "Atr"      format ">>>"
        wffatura.saldo           column-label "Saldo"    format ">>>,>>9.99"
        with frame frame-a 11 down centered row 5.


end procedure.

procedure historico.
    def var vok     as log.
    def var vmtbnom like motblo.mtbnom.

    run clifor.
    disp LotCreContrato.contnum label "Cliente" colon 10
         vclfnom no-label format "x(40)"
         vcgccpf colon 10
         with frame f-cab3 color message centered side-label row 4 no-box 
              width 81.

    for each lotcaghist where lotcaghist.clfcod = 
                    LotCreContrato.contnum no-lock
                break by lotcaghist.ltcrecod desc
                      by lotcaghist.data desc
                      by lotcaghist.hora desc.
        find func   of lotcaghist no-lock no-error.
        find motblo of lotcaghist no-lock.
        vmtbnom = string(motblo.mtbcod) + "-" + motblo.mtbnom.
        vok = yes.
        disp
            lotcaghist.data      column-label "Data"
            string(lotcaghist.hora, "HH:MM:SS") no-label
            func.funape          column-label "Gerado por"   format "x(12)"
                                 when avail func
            lotcaghist.ltcretcod column-label "Tipo de Lote" format "x(13)"
            lotcaghist.ltcrecod  column-label "Lote"
            lotcaghist.TipSpc
            vmtbnom
            with frame f-hist centered 12 down row 6.
    end.
    if vok = no
    then message "Sem historico".
    pause.
    hide frame f-hist.

end procedure.


