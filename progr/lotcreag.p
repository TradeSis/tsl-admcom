/*
*
*    lotcreag.p    -    Lotes de Controle de Credito p/Agente Comercial


            substituir    lotcreag
                          ltcre
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
    initial [" Inclui "," Titulos "," Desmarca "," Cliente "," Historico "].
def var esqcom2         as char format "x(12)" extent 5
    initial [" Pesquisa ", " Consulta ", " "].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclui Novo Cliente ao Lote ",
             " Consulta Titulos do Cliente ",
             " Desmarca Cliente do Lote ",
             " Informacoes do Cliente ",
             " Historico Lotes do Cliente "].
def var esqhel2         as char format "x(12)" extent 5.

{admcab.i}

def buffer blotcreag      for lotcreag.
def var vlotcreag         like lotcreag.ltcrecod.
def var vnum              as int.
def var vlotcre           as recid.

def var vclfnom           as char format "x(30)".
def var vcgccpf           as char.

def input parameter par-reclotcre  as recid.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.
form with frame f-lotcreag.

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
            find first lotcreag of lotcre no-lock no-error.
        else
            find last lotcreag of lotcre no-lock no-error.
    else
        find lotcreag where recid(lotcreag) = recatu1 no-lock.
    if not available lotcreag
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(lotcreag).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next lotcreag of lotcre no-lock.
        else
            find prev lotcreag of lotcre no-lock.
        if not available lotcreag
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
            find lotcreag where recid(lotcreag) = recatu1 no-lock.
            if lotcretp.titnat = no
            then do.
                find clien where clien.clicod = lotcreag.clfcod no-lock                 no-error.
                if avail clien then
                disp clien.ciccgc
                     /*** clien.tdoccod label "Documento" **/
                     space(0) "/" space(0) clien.ciinsc no-label
                     clien.dtnasc format "99/99/9999"
                     with frame f-sub row 20 no-box side-label color message.
            end.
            if lotcre.ltdtenvio <> ? or
               lotcreag.ltvalidacao <> ""
            then esqcom1[3] = "".
            else if lotcreag.ltsituacao
                 then esqcom1[3] = " Desmarca ".
                 else esqcom1[3] = " Marca ".
            disp esqcom1 with frame f-com1.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(lotcreag.ltcrecod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(lotcreag.clfcod)
                                        else "".

            choose field lotcreag.clfcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).

            status default "".

        end.
        {esquema.i &tabela = "lotcreag"
                   &campo  = "lotcreag.clfcod"
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
                    recatu1 = recid(lotcreag).
                    leave.
                end.
                if esqcom1[esqpos1] = " Desmarca " or
                   esqcom1[esqpos1] = " Marca " or
                   esqcom1[esqpos1] = " Consulta "
                then do with frame f-lotcreag
                            centered row 6 side-label width 60:
                    run clifor.
                    if lotcretp.titnat
                    then lotcreag.clfcod:label = "Fornecedor".
                    else lotcreag.clfcod:label = "Cliente".
                    disp
                        lotcreag.ltcrecod           label "Lote"     colon  14
                        lotcre.ltcredt
                        skip (1)
                        lotcreag.clfcod             label "Cliente"  colon  14
                        vclfnom   format "x(33)" no-label
                        vcgccpf   label "CGC/CPF" colon 14
                        skip (1)
                        lotcreag.indsit colon 14    label "Situacao"
                        skip (1)
                        lotcreag.ltcremot format "x(38)" label "Motivo" 
                                colon 14
                        skip (1).
                    if esqcom1[esqpos1] = " Consulta "
                    then pause.
                end.
                if esqcom1[esqpos1] = " Desmarca " or
                   esqcom1[esqpos1] = " Marca "
                then do with on error undo:
                    if lotcretp.ltcretblo and
                       lotcreag.ltsituacao
                    then prompt-for lotcreag.data-can 
                                label "Agendar envio do SPC"
                                validate (input lotcreag.data-can = ? or
                                          input lotcreag.data-can > today,
                                          "Data invalida")
                            with frame f-canc side-label.
                    message "Confirma "
                            (if lotcreag.ltsituacao then "des" else "") +
                            "marcar o cliente" lotcreag.clfcod " ?"
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find current lotcreag exclusive.
                    assign
                        lotcreag.ltsituacao = not lotcreag.ltsituacao.
                    if lotcreag.ltsituacao
                    then assign
                            lotcreag.funcod-can = 0
                            lotcreag.data-can   = ?
                            lotcreag.hora-can   = 0.
                    else assign
                            lotcreag.funcod-can = sfuncod
                            lotcreag.data-can   = if lotcretp.ltcretblo
                                                  then input lotcreag.data-can
                                                  else ?
                            lotcreag.hora-can   = time.

                    find current lotcreag no-lock.
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
                    prompt-for lotcreag.clfcod validate(true, "")
                               with frame f-pesq side-label.
                    find blotcreag where 
                                     blotcreag.ltcrecod = lotcreag.ltcrecod
                                 and blotcreag.clfcod   = input lotcreag.clfcod
                                   no-lock no-error.
                    if avail blotcreag
                    then recatu1 = recid(blotcreag).
                    leave.
                end.
                if esqcom2[esqpos2] = " Consulta "
                then do.
                    disp lotcreag except lotcreag.clfcod with frame f-lotcreag.
                    disp    lotcreag.clfcod format "9999999999" 
                            vcgccpf format "99999999999999"
                            with frame f-lotcreag.
                end.
            end.
        end.
        if not esqvazio
        then run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(lotcreag).
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
    vsituacao = lotcreag.ltsituacao = yes /* marcado */ and
                lotcreag.ltvalida   = ""  /* valido */.
    run clifor.
    
    
    display
        lotcreag.clfcod   format "9999999999"
        vclfnom           format "x(20)"
        vsituacao @ lotcreag.ltsituacao     no-label
        lotcreag.ltvalida format "x(17)"
        lotcreag.indsit
        lotcreag.ltcremot when lotcreag.indsit = no format "x(15)"
        with frame frame-a 11 down centered row 5.

    if lotcretp.titnat
    then vclfnom:label in frame frame-a = "Fornecedor".
    else vclfnom:label = "Cliente".


end procedure.

procedure historico.
    def var vok     as log.
    def var vmtbnom like motblo.mtbnom.

    run clifor.
    disp lotcreag.clfcod label "Cliente" colon 10
         vclfnom no-label format "x(40)"
         vcgccpf colon 10
         with frame f-cab3 color message centered side-label row 4 no-box 
              width 81.

    for each lotcaghist where lotcaghist.clfcod = lotcreag.clfcod no-lock
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

procedure clifor.
    if lotcretp.titnat
    then do.
        find forne where forne.forcod = lotcreag.clfcod no-lock.
        assign
            vcgccpf = forne.forcgc
            vclfnom = forne.fornom.
    end.
    else do.
        find clien where clien.clicod = lotcreag.clfcod no-lock no-error.
        if avail clien then
        assign
            vcgccpf = clien.ciccgc 
            vclfnom = clien.clinom.
    end.
end.

