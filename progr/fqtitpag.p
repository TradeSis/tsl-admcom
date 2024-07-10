/*
*
*
*/
{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5.

esqcom1 = "".

if sfuncod = 101
then assign
        esqcom1[4] = " Altera "
        esqcom1[5] = " Exclui ".

def var vhora as char format "x(5)".

def input parameter par-rec as recid.

find titulo where recid(titulo) = par-rec no-lock.

def var vtotal          like titulo.titvlcob column-label "Saldo c/Juro".
def var vcartcobra      as   char column-label "Carteira".
def var vldevido        like titulo.titvlcob.
def var vdias           as   int   format ">>>9".
def var vtottitvlpag    like titpag.titvlpag.

/***
find clifor of titulo no-lock.
display clifor.clfcod
        clifor.cgccpf
        clifor.clfnom no-label format "x(25)"
        clifor.situacao format "/BLOQUEADO" no-label
            with side-label row 3 width 81 frame f1 1 down no-hide no-box
                            color message .
***/
do:
        vtotal = titulo.titvlcob - titulo.titvlpag.
/***
        if titulo.titdtven < today and titulo.titdtpag = ?
        then do:
            run fbjuro.p (
                                input titulo.cobcod,
                                input titulo.carcod,
                                input titulo.titnat,
                            input titulo.titvlcob - titulo.titvlpag,
                          input titulo.titdtven,
                          input today,
                          output vtotal,
                          output vperc).
        end.
***/
        /***find cobra    of titulo no-lock.
        find carteira of titulo no-lock.
        vcartcobra = trim(substr(cobra.cobnom,1,5) + "/" + carteira.carnom).***/
        find banco of titulo no-lock no-error.
        if avail banco
        then
            substr(vcartcobra,1,5) = banco.banfan.
        if titulo.titdtpag = ?
        then vdias = today - titulo.titdtven.
        else vdias = titulo.titdtpag - titulo.titdtven.
        find estab where estab.etbcod = titulo.etbcod no-lock.
        if titulo.titdtpag <> ?
        then
            vcartcobra = "Liqui " + string(titdtpag,"99/99/99").
        display
            estab.etbcod  column-label "Fil"
            /***titulo.tdfcod***/
            {titnum.i}
            titulo.titdtemi format "99/99/99"
            titulo.titdtven format "99/99/99"
            vdias           when vdias > 0 column-label "Dias"
            vcartcobra      format "x(17)"
            titulo.titvlcob format ">>>>,>>9.99"
            with frame fcab 1 down centered row 4 width 81
                                 color message no-box overlay.

end.

form
    esqcom1
    with frame f-com1 width 81
                 row screen-lines no-box no-labels column 1 centered overlay.

assign
    esqpos1  = 1.

/***
def var vsaldo like titulo.titvlcob.
def workfile wfsaldo
    field rec       as   recid
    field saldo     like titulo.titvlcob.

vsaldo = titulo.titvlcob.
                view frame fobs.
                view frame frame-a.
***/

for each titpag where titpag.empcod = titulo.empcod and
                      titpag.titnat = titulo.titnat and
                      titpag.modcod = titulo.modcod and
                      titpag.etbcod = titulo.etbcod and
                      titpag.clifor = titulo.clifor and
                      titpag.titnum = titulo.titnum and
                      titpag.titpar = titulo.titpar
                no-lock:
    vtottitvlpag = vtottitvlpag + titpag.titvlpag.
/***
    create wfsaldo.
    assign wfsaldo.rec     = recid(titpag).
    assign vsaldo          = vsaldo + 
                             ( /***if titpag.cmopenat = ? /*nao soma estornado*/
                              then 0
                              else***/ - titpag.titvlpag)
           vsaldo          = if vsaldo < 0 then 0 else vsaldo.
    assign wfsaldo.saldo   = vsaldo.
***/
end.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find titpag where recid(titpag) = recatu1 no-lock.
    if not available titpag
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do on endkey undo.
        message "Nao Existe Pagamentos para o Titulo.".
        pause 3 no-message.
        leave.
    end.

    recatu1 = recid(titpag).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available titpag
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.

        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find titpag where recid(titpag) = recatu1 no-lock.
            disp vtottitvlpag label "Total" skip
                 titpag.titobs[1] no-label format "x(24)"
                 "|" titpag.titobs[2] no-label format "x(24)"
                 "|" titpag.titobs[3] no-label format "x(24)"
                with frame f-sub side-label row 20 no-box.

            status default "".

            choose field titpag.cxmdata  help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

            status default "".

        end.

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
                    if not avail titpag
                    then leave.
                    recatu1 = recid(titpag).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail titpag
                    then leave.
                    recatu1 = recid(titpag).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail titpag
                then next.
                color display white/red titpag.cxmdata with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail titpag
                then next.
                color display white/red titpag.cxmdata with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                    if esqcom1[esqpos1] = " Consulta "
                    then do:
                        hide frame f-com2   no-pause.
                        hide frame f-com1   no-pause.
                        hide frame frame-a  no-pause.
                        hide frame fcab     no-pause.
                        hide frame f1       no-pause.
                        run cocmope.p ( input recid(titpag)).
                        pause 0.
                        view frame f-com2   . pause 0.
                        view frame f-com1   . pause 0.
                        view frame frame-a  . pause 0.
                        view frame fcab     . pause 0.
                        view frame f1       . pause 0.
                    end.
                    /*
                    if esqcom1[esqpos1] = " Lancamento "
                    then do:
                        hide frame f-com2   no-pause.
                        hide frame f-com1   no-pause.
                        hide frame frame-a  no-pause.
                        hide frame fcab     no-pause.
                        hide frame f1       no-pause.
                        find cmondoc of titpag no-lock.
                        find cmon    of cmondoc no-lock.
                        find cmtdoc  of cmondoc no-lock.
                        run cmdalt.p ( input recid(CMon),
                                       input "CON",
                                       input "TIPO",
                                       input recid(cmtdoc),
                                       input cmondoc.cmddtlan,
                                       input recid(cmondoc),
                                       input ?,
                                       input ?
                                       ).
                        pause 0.
                        view frame f-com2   . pause 0.
                        view frame f-com1   . pause 0.
                        view frame frame-a  . pause 0.
                        view frame fcab     . pause 0.
                        view frame f1       . pause 0.
                    end.
                    */
            if esqcom1[esqpos1] = " Altera "
            then do on error undo.
                find current titpag exclusive.
                update titpag.moecod with frame f-altera.
            end.
            if esqcom1[esqpos1] = " Exclui "
            then do on error undo.
                sresp = no.
                message "Confirma exclusao?" update sresp.
                if sresp
                then do.
                    find current titpag exclusive.
                    delete titpag.
                    recatu1 = ?.
                    leave.
                end.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(titpag).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1 no-pause.
hide frame frame-a no-pause.
hide frame fcab    no-pause.
hide frame f1 no-pause.
hide frame f-sub no-pause.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
        find first titpag where 
                                     titpag.empcod = titulo.empcod and
                                     titpag.titnat = titulo.titnat and
                                     titpag.modcod = titulo.modcod and
                                     titpag.etbcod = titulo.etbcod and
                                     titpag.clifor = titulo.clifor and
                                     titpag.titnum = titulo.titnum and
                                     titpag.titpar = titulo.titpar
                                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
        find next titpag  where
                                     titpag.empcod = titulo.empcod and
                                     titpag.titnat = titulo.titnat and
                                     titpag.modcod = titulo.modcod and
                                     titpag.etbcod = titulo.etbcod and
                                     titpag.clifor = titulo.clifor and
                                     titpag.titnum = titulo.titnum and
                                     titpag.titpar = titulo.titpar
                                       no-lock no-error.
             
if par-tipo = "up" 
then                  
        find prev titpag where 
                                     titpag.empcod = titulo.empcod and
                                     titpag.titnat = titulo.titnat and
                                     titpag.modcod = titulo.modcod and
                                     titpag.etbcod = titulo.etbcod and
                                     titpag.clifor = titulo.clifor and
                                     titpag.titnum = titulo.titnum and
                                     titpag.titpar = titulo.titpar
                                 no-lock no-error.
        
end procedure.

procedure frame-a.  

/***    find first wfsaldo where wfsaldo.rec = recid(titpag) no-lock. ***/
    find moeda of titpag no-lock no-error.
    display
            /***titpag.titpagseq format "99999"***/
        titpag.cxmdata  column-label "Data" format "99/99/99"
        string(int(titpag.cxmhora), "hh:mm:ss")
        titpag.etbcod   column-label "Etb" format ">>9"
        titpag.titvlpag   format ">>>,>>9.99" column-label "Valor"
                /***when titpag.cmopenat <> ? /* nao mostra estornado */***/
        titpag.modcod
        titpag.moecod
        moeda.moenom    when avail moeda
        titpag.cxacod   column-label "Caixa" format ">>>"
/***
        wfsaldo.saldo   column-label "Saldo" format ">>>,>>9.99"
                when titpag.cmopenat <> ?
            titpag.titjuro when titpag.titjuro <> 0 and titpag.cmopenat <> ?
                format ">,>>9.99" column-label "Juros"
            titpag.titdesc when titpag.titdesc <> 0 and titpag.cmopenat <> ?
                format ">,>>9.99" column-label "Desconto"
***/
        with frame frame-a 8 down centered color white/red row 7 
                width 80 overlay title " Historicos de Movimentacao ".

end procedure.
