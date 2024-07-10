/*
*
*    lotcretit.p    -    Esqueleto de Programacao    com esqvazio


            substituir    lotcretit
                          tit
*
*/
{admcab.i}
/***
{banrisul.i}
***/

def input parameter par-recclifor     as recid.
def input parameter par-reclotcre     as recid.
def var vtitnum as char format "x(11)" label "Titulo".

def new shared temp-table tt-titulo like fin.titulo.




def var vclfnom           as char format "x(30)".
def var vcgccpf           as char.
def var vclfcod           as int.
find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

run clifor.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Titulo "," Consulta "," Cod.Barras "," "," "].
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

/* TITULOS LP */         

    
if connected ("d") then disconnect d.    
run conecta_d.p.
if connected ("d")
then do:

    for each lotcretit of lotcre 
    where lotcretit.clfcod = vclfcod no-lock.
    
        run lotcre3lp.p (input recid(lotcretit)).

    end.
disconnect d.
hide message no-pause.
end.

/* TITULOS DO BANCO FIN*/
for each lotcretit of lotcre no-lock.
    find last titulo where titulo.empcod = 19
                  and titulo.titnat = lotcretp.titnat
                  and titulo.modcod = lotcretit.modcod
                  and titulo.etbcod = lotcretit.etbcod
                  and titulo.clifor = lotcretit.clfcod
                  and titulo.titnum = lotcretit.titnum
                  and titulo.titpar = lotcretit.titpar

                no-lock no-error.

     if not avail titulo then next.
     if avail titulo 
     then do:
        create tt-titulo.
        buffer-copy titulo to tt-titulo.
     end.


end.

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
          find first lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod and
                                     lotcretit.clfcod = vclfcod
                                                               no-lock no-error.
        else
          find last lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod and
                                       lotcretit.clfcod = vclfcod
                                                               no-lock no-error.
    else
        find lotcretit where recid(lotcretit) = recatu1 no-lock.
    if not available lotcretit
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.
    else do:
        message color red/with
        "Nenhum registro encontrado."
        view-as alert-box
        .
        leave bl-princ.
    end.    
    recatu1 = recid(lotcretit).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod and
                                         lotcretit.clfcod = vclfcod
                                                                        no-lock.
        else
            find prev lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod and
                                         lotcretit.clfcod = vclfcod
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
/***
            find titulo of lotcretit no-lock.
***/
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(lotcretit.titcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(lotcretit.titcod)
                                        else "".
            vtitnum = trim(tt-titulo.titnum + (if tt-titulo.titpar > 0
                                  then "/" + string(tt-titulo.titpar)
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
                   &where  = " lotcretit.ltcrecod = lotcre.ltcrecod and
                               lotcretit.clfcod = vclfcod"
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
    find tt-titulo where tt-titulo.empcod = wempre.empcod
                  and tt-titulo.titnat = lotcretp.titnat
                  and tt-titulo.modcod = lotcretit.modcod
                  and tt-titulo.etbcod = lotcretit.etbcod
                  and tt-titulo.clifor = lotcretit.clfcod
                  and tt-titulo.titnum = lotcretit.titnum
                  and tt-titulo.titpar = lotcretit.titpar
                no-lock no-error.

    
    if avail tt-titulo then do:
    vsituacao = lotcreag.ltsituacao = yes /* clifor marcado */ and
                lotcreag.ltvalida   = ""  /* valido */   and
                lotcretit.ltsituacao      /* titulo marcado */.

    assign
        vdias  = today - tt-titulo.titdtven
        vsaldo = tt-titulo.titvlcob - tt-titulo.titvlpag
        vltvalidacao = lotcretit.ltvalidacao.
    
    if lotcretp.ltcretcod = "ACCESS_PG"
    then if vsaldo < 0 
         then do:
            vsaldo = 0.
         end.
         vltvalidacao = "PAGO".
    
    vtitnum = trim(tt-titulo.titnum + (if tt-titulo.titpar > 0
                                  then "/" + string(tt-titulo.titpar)
                                  else "")).
    disp
        vtitnum
        /* {titnum.i} */
        vsituacao @ lotcretit.ltsituacao no-label
        tt-titulo.etbcod   format ">>9" column-label "Est"
        tt-titulo.modcod
        tt-titulo.titdtemi format "99/99/99" 
        tt-titulo.titdtven format "99/99/99" column-label "Vencim"
        vdias           format "->>>" column-label "Dias"
        tt-titulo.titvlcob format ">>>,>>9.99" column-label "Vlr.Cobrado"
        vsaldo          format "->>>,>>9.99" column-label "Saldo"
        /*vltvalidacao format "x(9)" column-label "Validacao"*/
        with frame frame-a 10 down centered color white/red row 6.
     end.
end procedure.

procedure clifor.
    if lotcretp.titnat
    then do.
        find forne where recid(forne) = par-recclifor no-lock.
        assign
            vclfcod = forne.forcod
            vcgccpf = forne.forcgc
            vclfnom = forne.fornom.
    end.
    else do.
        find clien where recid(clien) = par-recclifor no-lock.
        assign
            vclfcod = clien.clicod
            vcgccpf = clien.ciinsc
            vclfnom = clien.clinom.
    end.
end.

/***
procedure codbarras.

    def var vbarras    as char.
    def var vdoc-valor as dec.
    def var vbancod    as int.
    def var vvcto      as date format "99/99/9999".
    def var vdoc-d1    as char.
    def var vdoc-d2    as char.
    def var vdoc-d3    as char.
    def var vdoc-d4    as char.
    def var vdoc-d5    as char.

    def var consorcio-nossonro as dec  format "9999999999" label "Nosso Nr".

    find titulo2 where titulo2.empcod = wempre.empcod
                           and titulo2.titnat = lotcretp.titnat
                           and titulo2.modcod = lotcretit.modcod
                           and titulo2.etbcod = lotcretit.etbcod
                           and titulo2.clifor = lotcretit.clfcod
                           and titulo2.titnum = lotcretit.titnum
                           and titulo2.titpar = lotcretit.titpar
                exclusive no-error.
    if avail titulo2
    then do.
        if acha("Bar", titulo2.codbarras) <> ?
        then vbarras = acha("Bar", titulo2.codbarras).
        else do.
            vbarras = acha("Dig", titulo2.codbarras).
            vdoc-d1 = substr(vbarras,  1, 10).
            vdoc-d2 = substr(vbarras, 11, 11).
            vdoc-d3 = substr(vbarras, 22, 11).
            vdoc-d4 = substr(vbarras, 33, 1).
            vdoc-d5 = substr(vbarras, 34, 14).
            vbarras = "".
        end.
    end.

do on error undo with frame fcons side-label.

    if vdoc-d1 = ""
    then update vbarras format "x(44)" label "  Cod.Barras" colon 19
               help "Coloque DOC na Leitora de Barras"
               with frame fcons.
    if vbarras <> ""
    then do:
        if length(vbarras) <> 44 and
           length(vbarras) > 0
        then do.
            message "Tamanho do codigo de barras invalido" view-as alert-box.
            undo.
        end.
        if not banrisulbarra(vbarras,
                         output vbancod,
                         output vdoc-valor,
                         output vvcto,
                         output consorcio-nossonro)
        then do:
            vbarras = "".
            message "Erro na Leitura codigo de Barras, tentar Novamente?"
                    update sresp.
            if sresp
            then leave.
            undo.
        end.    

    end.
    else do.
        message "Digite Linha Digitavel do DOC Bancario".
        update vdoc-d1
               format "999999999.9" auto-return colon 19 label "Digitavel".
        if vdoc-d1 <> ""
        then do:
            update
                vdoc-d2 format "9999999999.9" auto-return no-label
                vdoc-d3 format "9999999999.9" auto-return no-label
                vdoc-d4 format "9"            auto-return no-label
                vdoc-d5 format "99999999999999" no-label
                with frame fcons.

/***
            if banrisuldigitavel(vdoc-d1 + vdoc-d2 + vdoc-d3 + vdoc-d4 +
                                 vdoc-d5,
                                 output vbancod,
                                 output vdoc-valor,
                                 output vvcto,
                                 output consorcio-nossonro)
            then do:
                 vdoc-d1 = "".
                 message "Erro na Digitacao, Tentar Novamente?"
                    update sresp.
                 if sresp
                 then leave.
                 undo.
            end.
***/

        end.
        else undo.
    end.

    find titulo2 where titulo2.empcod = wempre.empcod
                           and titulo2.titnat = lotcretp.titnat
                           and titulo2.modcod = lotcretit.modcod
                           and titulo2.etbcod = lotcretit.etbcod
                           and titulo2.clifor = lotcretit.clfcod
                           and titulo2.titnum = lotcretit.titnum
                           and titulo2.titpar = lotcretit.titpar
                exclusive no-error.
    if not avail titulo2
    then do.
        create titulo2.
        assign
            titulo2.empcod = wempre.empcod
            titulo2.titnat = lotcretp.titnat
            titulo2.modcod = lotcretit.modcod
            titulo2.etbcod = lotcretit.etbcod
            titulo2.clifor = lotcretit.clfcod
            titulo2.titnum = lotcretit.titnum
            titulo2.titpar = lotcretit.titpar.
    end.
    if vbarras <> ""
    then titulo2.codbarras = "Bar=" + vbarras.
    else titulo2.codbarras = "Dig=" + vdoc-d1 + vdoc-d2 + vdoc-d3 + vdoc-d4 +
                             vdoc-d5.
end.

end procedure.

***/
