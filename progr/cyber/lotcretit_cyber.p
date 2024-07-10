/*  cyber/lotcretit_cyber.p                                    */
{admcab.i}

def input parameter par-reclotcre     as recid.
def var vtitnum as char format "x(11)" label "Titulo".




def var vclfnom           as char format "x(30)".
def var vcgccpf           as char.
def var vclfcod           as int.
find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Titulo "," Consulta ","  "," "," "].
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5
    initial [" Consulta Titulo ",
             " ",
             " ",
             " ",
             " "].
def var esqhel2         as char format "x(12)" extent 5.

def buffer blotcretit       for lotcretit.
def var vlotcretit         like lotcretit.titcod.

form
    esqcom1
        with frame f-com1
        row 5 no-box no-labels side-labels column 1 centered.
form
    esqcom2
        with frame f-com2
        row screen-lines no-box no-labels side-labels column 1 centered.
form
    "Cliente:" colon 3
     vclfcod   format "9999999999" colon 13
     vclfnom      format "x(40)"
     vcgccpf  no-label
                with frame f-cab centered row 4 no-box width 81
                                     no-label color message.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.

    disp vclfcod
         vclfnom
         vcgccpf
         with frame f-cab.

    if recatu1 = ?
    then
        if esqascend
        then
          find first lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod 
                                                               no-lock no-error.
        else
          find last lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod 
                                                               no-lock no-error.
    else
        find lotcretit where recid(lotcretit) = recatu1 no-lock.
    if not available lotcretit
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(lotcretit).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod 
                                                                        no-lock.
        else
            find prev lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod 
                                                                        no-lock.
        if not available lotcretit
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
            find lotcretit where recid(lotcretit) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(lotcretit.titcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(lotcretit.titcod)
                                        else "".
            vtitnum = trim(lotcretit.titnum + (if lotcretit.titpar > 0
                                  then "/" + string(lotcretit.titpar)
                                  else "")).


            choose field vtitnum  help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

            status default "".

        end.
        {esquema.i &tabela = "lotcretit"
                   &campo  = "vtitnum"
                   &where  = " lotcretit.ltcrecod = lotcre.ltcrecod "
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form lotcretit except titcod
                 with frame f-lotcretit color black/cyan
                      centered side-label row 7 2 col.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Titulo "
                then do on error undo.
                    find titulo where titulo.empcod = wempre.empcod
                                  and titulo.titnat = lotcretp.titnat
                                  and titulo.modcod = lotcretit.modcod
                                  and titulo.etbcod = lotcretit.etbcod
                                  and titulo.clifor = lotcretit.clfcod
                                  and titulo.titnum = lotcretit.titnum
                                  and titulo.titpar = lotcretit.titpar
                                no-lock no-error.

                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame f-cab no-pause.
                    run bsfqtitulo.p (input recid(titulo)).
                    recatu1 = recid(lotcretit).
                    view frame f-com1.
                    view frame f-com2.
                    view frame f-cab.
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-lotcretit.
/***
                    lotcretit.titnum:label = "Spc.Docto".
***/
                    disp lotcretit except titcod clfcod.
                    disp lotcretit.clfcod format "9999999999".

                    find titulo where titulo.empcod = wempre.empcod
                                  and titulo.titnat = lotcretp.titnat
                                  and titulo.modcod = lotcretit.modcod
                                  and titulo.etbcod = lotcretit.etbcod
                                  and titulo.clifor = lotcretit.clfcod
                                  and titulo.titnum = lotcretit.titnum
                                  and titulo.titpar = lotcretit.titpar
                                no-lock no-error.
                    if avail titulo
                    then disp
                            skip(1)
                            {titnum.i}
                            titulo.etbcod.
                    pause.
                end.
                if esqcom1[esqpos1] = " Cod.Barras "
                then do.
                    find titulo where titulo.empcod = wempre.empcod
                                  and titulo.titnat = lotcretp.titnat
                                  and titulo.modcod = lotcretit.modcod
                                  and titulo.etbcod = lotcretit.etbcod
                                  and titulo.clifor = lotcretit.clfcod
                                  and titulo.titnum = lotcretit.titnum
                                  and titulo.titpar = lotcretit.titpar
                                no-lock no-error.
                    if avail titulo
                    then run fatu-codbar.p (recid(titulo)).
                                        /***run codbarras.***/
                end.
                leave.
            end.
        end.
        if not esqvazio
        then run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(lotcretit).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame f-cab   no-pause.
hide frame frame-a no-pause.

procedure frame-a.

    def var vdias     as int.
    def var vsaldo    as dec.
    def var vsituacao as log.
    def var vltvalidacao as char.

    find lotcreag of lotcretit no-lock.
    find titulo where titulo.empcod = wempre.empcod
                  and titulo.titnat = lotcretp.titnat
                  and titulo.modcod = lotcretit.modcod
                  and titulo.etbcod = lotcretit.etbcod
                  and titulo.clifor = lotcretit.clfcod
                  and titulo.titnum = lotcretit.titnum
                  and titulo.titpar = lotcretit.titpar
                no-lock no-error.

    
    if avail titulo then do:
    vsituacao = lotcreag.ltsituacao = yes /* clifor marcado */ and
                lotcreag.ltvalida   = ""  /* valido */   and
                lotcretit.ltsituacao      /* titulo marcado */.

    assign
        vdias  = today - titulo.titdtven
        vsaldo = titulo.titvlcob - titulo.titvlpag
        vltvalidacao = lotcretit.ltvalidacao.
    
    if lotcretp.ltcretcod = "ACCESS_PG"
    then if vsaldo < 0 
         then do:
            vsaldo = 0.
         end.
         vltvalidacao = "PAGO".
    
    vtitnum = trim(lotcretit.titnum + (if lotcretit.titpar > 0
                                  then "/" + string(lotcretit.titpar)
                                  else "")).
    disp
        vtitnum
        /* {titnum.i} */
        /*vsituacao @ lotcretit.ltsituacao no-label*/
        lotcretit.etbcod   format ">>9" column-label "Est"
        lotcretit.modcod
        titulo.titdtemi format "99/99/99" 
        titulo.titdtven format "99/99/99" column-label "Vencim"
        vdias           format "->>>" column-label "Dias"
        titulo.titvlcob format ">>>,>>9.99" column-label "Vlr.Cobrado"
        vsaldo          format "->>>,>>9.99" column-label "Saldo"
        /*vltvalidacao format "x(9)" column-label "Validacao"*/
        with frame frame-a 10 down centered color white/red row 6.
     end.
end procedure.


