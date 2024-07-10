{admcab.i}

def var tot-blo as dec.
def var tot-lib as dec.
def var tot-exc as dec.
def var tot-pen as dec.
def var vtot-marcado as dec.
def var vqtd-marcado as int.

def var sit-premio as char format "x(22)" extent 5.
assign
    sit-premio[1] = "BLO - Bloqueado"
    sit-premio[2] = "LIB - Liberado"
    sit-premio[3] = "EXC - Excluido"
    sit-premio[4] = "NEG - Negado"
    sit-premio[5] = "PEN - Bloqueado P.Bis".
def var sit-p as char format "x(15)" extent 5.
assign
    sit-p[1] = "BLO"
    sit-p[2] = "LIB"
    sit-p[3] = "EXC"
    sit-p[4] = "NEG"
    sit-p[5] = "PEN".
    
def var vetbcod like estab.etbcod.
def var vdti    as date.
def var vdtf    as date.
def var vforcod like foraut.forcod.
def var vtitsit like titluc.titsit init "".

def temp-table tt-titsit
    field titsit like titulo.titsit.
create tt-titsit.
tt-titsit.titsit = "LIB".
create tt-titsit.
tt-titsit.titsit = "BLO".
create tt-titsit.
tt-titsit.titsit = "PEN".
create tt-titsit.
tt-titsit.titsit = "EXC". /*** Novo ***/
create tt-titsit.
tt-titsit.titsit = "AUT". /*** 04/12/2014 ***/

/*
assign
    vdti = today - 80.
*/

do on error undo with frame fopcoes side-label no-box row 3.
    update vetbcod label "Filial".

    update vdti label "Vencim. de" format "99/99/9999" validate(vdti <> ?, "")
           vdtf label "Ate"        format "99/99/9999".

    update vforcod.
    if vforcod > 0
    then do.
        find foraut where foraut.forcod = vforcod no-lock no-error.
        if not avail foraut
        then do.
            message "Fornecedor invalido" view-as alert-box.
            undo.
        end.
    end.

    update vtitsit label "Sit".
    if vtitsit <> ""
    then do.
        find first tt-titsit where tt-titsit.titsit = vtitsit no-lock no-error.
        if not avail tt-titsit
        then do.
            message "Situacao invalida" view-as alert-box.
            undo.
        end.
    end.
end.

def temp-table tt-titluc like titluc
   index i1 titdtven .

form tt-titluc.agecod   format "x" no-label
     tt-titluc.etbcod   column-label "Etb"   format ">>9"
     tt-titluc.vencod
     tt-titluc.titnum   column-label "Venda"
     tt-titluc.titdtven column-label "Data"  format "99/99/99"
     tt-titluc.titvlcob column-label "Valor" format ">>>9.99"
     tt-titluc.titobs[2] format "x(18)" no-label 
     tt-titluc.titnumger no-label format "x(13)"     
     tt-titluc.titsit column-label "Sit"
     with frame frame-a screen-lines - 14 down centered row 8 width 80 overlay.
                                                                                
def var vquem as char format "x(23)"  extent 7 
    init["VENDEDOR","GERENTE","PROMOTOR","CREDIARISTA",
         "TREINEE CREDIARIO","TREINEE CONFECCAO","CREDIARISTA PLANO BIS"].
def var vindex as int.

disp vquem
     with frame f-quem 1 down no-label 1 col.
choose field vquem with frame f-quem.
vindex = frame-index.
hide frame f-quem.
disp vquem[vindex] with frame fff 1 down no-label .
 
def var vfuncod like func.funcod.
if vquem[vindex] = "CREDIARISTA"
THEN VFUNCOD = 150.
if vquem[vindex] = "VENDEDOR" or
  vquem[vindex] = "CREDIARISTA PLANO BIS"
THEN DO on error undo:
    update vfuncod with frame f10 1 down side-label column 27.
    if vfuncod > 0 and vetbcod > 0
    then do.
        find func where func.etbcod = vetbcod and
                        func.funcod = vfuncod
                        no-lock no-error.
        if not avail func
        then do.
            message "Vendedor invalido" view-as alert-box.
            next.
        end.
        disp func.funnom no-label with frame f10.
    end.
    PAUSE 0.
end.

def temp-table tt-modal 
    field modcod like modal.modcod.
    
def buffer bmodgru for modgru.
find first modgru where modgru.modcod = "PEM" and
                        modgru.mogsup = 0
        no-lock no-error.
if avail modgru
then
    for each bmodgru where bmodgru.mogsup = modgru.mogcod  no-lock:
        create tt-modal.
        tt-modal.modcod = bmodgru.modcod.
    end. 

find first tt-modal where tt-modal.modcod = "COM" no-error.
if not avail tt-modal
then do:
    create tt-modal.
    tt-modal.modcod = "COM".
end.
find first tt-modal where tt-modal.modcod = "PBM" no-error.
if not avail tt-modal
then do:
    create tt-modal.
    tt-modal.modcod = "PBM".
end. 
find first tt-modal where tt-modal.modcod = "PBC" no-error.
if not avail tt-modal
then do:
    create tt-modal.
    tt-modal.modcod = "PBC".
end. 

for each tt-titluc: delete tt-titluc. end.
def var vtotal-premio as dec init 0.

for each estab no-lock.
    if vetbcod > 0 and estab.etbcod <> vetbcod
    then next.
for each tt-modal:
for each titluc where titluc.empcod = 19 and
                      titluc.titnat = yes and
                      titluc.modcod = tt-modal.modcod and
                      titluc.etbcod = estab.etbcod and
                      titluc.titdtven >= vdti /*** today - 80 ***/ and
                      titluc.titdtven < 01/01/2010 and
                      titluc.titsit = "LIB" and
                      (if vfuncod > 0 and 
                          (vquem[vindex] = "VENDEDOR" or
                           vquem[vindex] = "CREDIARISTA PLANO BIS")
                      then titluc.vencod = func.funcod
                      else true)
                      no-lock:

    if vforcod > 0 and titluc.clifor <> vforcod
    then next.

    if vtitsit <> "" and vtitsit <> titluc.titsit
    then next.

    if acha("PREMIO",titluc.titobs[2]) <> vquem[vindex]
    then do:
        if (vquem[vindex] = "VENDEDOR" or
            vquem[vindex] = "CREDIARISTA PLANO BIS") and
           titluc.evecod =  5
        then.
        else next.
    end.

    create tt-titluc.
    buffer-copy titluc to tt-titluc.
    tt-titluc.agecod = "".
    if tt-titluc.clifor = 110876 or
       tt-titluc.clifor = 111281
    then tt-titluc.titnumger = "CLARO".
    if tt-titluc.clifor = 110875 or
       tt-titluc.clifor = 111282
    then tt-titluc.titnumger = "VIVO".
    if tt-titluc.clifor = 111764
    then tt-titluc.titnumger = "TRAINEE CONF.".
    find foraut where foraut.forcod =  titluc.clifor no-lock no-error.
    if avail foraut
    then tt-titluc.titobs[2] = foraut.fornom.
end.
end.
end. /* estab */

for each estab no-lock.
    if vetbcod > 0 and estab.etbcod <> vetbcod
    then next.
for each tt-modal: 
for each titluc where titluc.empcod = 19 and
                      titluc.titnat = yes and
                      titluc.modcod = tt-modal.modcod and
                      titluc.etbcod = estab.etbcod and
                      titluc.titdtven >= vdti /***today - 80***/  and
                      titluc.evecod = 5
                      no-lock,
        first tt-titsit where tt-titsit.titsit = titluc.titsit no-lock:

    if vdtf <> ? and titluc.titdtven > vdtf
    then next.

    if vforcod > 0 and titluc.clifor <> vforcod
    then next.

    if vfuncod > 0 and titluc.vencod <> vfuncod
    then next.

    if vtitsit <> "" and vtitsit <> titluc.titsit
    then next.
                      
    if acha("PREMIO",titluc.titobs[2]) <> vquem[vindex]
    then do:
        if vquem[vindex] = "VENDEDOR" and
           acha("PREMIO",titluc.titobs[2]) = ? and
           titluc.evecod =  5
        then.
        else if vquem[vindex] = "GERENTE" and
                acha("PREMIO",titluc.titobs[2]) = ? and
                titluc.vencod = 0 and
                titluc.evecod =  5 and
                (titluc.modcod = "PTP" or
                 titluc.modcod = "PGE") and
                titluc.clifor <> 110876 and
                titluc.clifor <> 111281 and
                titluc.clifor <> 110875 and
                titluc.clifor <> 111282 and
                titluc.clifor <> 111764
             then .                          
             else next.
    end.
                                                            
    create tt-titluc.
    buffer-copy titluc to tt-titluc.
    tt-titluc.agecod = "".

    if tt-titluc.clifor = 110876 or
       tt-titluc.clifor = 111281
    then tt-titluc.titnumger = "CLARO".
    if tt-titluc.clifor = 110875 or
       tt-titluc.clifor = 111282
    then tt-titluc.titnumger = "VIVO".
    if tt-titluc.clifor = 111764
    then tt-titluc.titnumger = "TRAINEE CONF.".
    find foraut where foraut.forcod =  titluc.clifor no-lock no-error.
    if avail foraut
    then tt-titluc.titobs[2] = foraut.fornom.
end.  
end.                         
end. /* estab */

/*
*
*    tt-titluc.p    -    Esqueleto de Programacao
*
*/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Marca", " Marca Tudo"," Situacao"," "].
def buffer btt-titluc for tt-titluc.

form
    esqcom1
    with frame f-com1 row 7 no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    run totaliza.
    disp "TOTAIS:"
         tot-lib label "  LIB" format ">>>,>>9.99" 
         tot-blo label "  BLO" format ">>>,>>9.99"
         tot-exc label "  EXC" format ">>>,>>9.99"
         tot-pen label "  PEN" format ">>>,>>9.99"
         vqtd-marcado label "Total marcado ..."
         vtot-marcado no-label
         with frame ff-total no-box row screen-lines - 2 side-label centered.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-titluc where recid(tt-titluc) = recatu1 no-lock.
    if not available tt-titluc
    then do.
        message "Nenhum premio encontrado" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(tt-titluc).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-titluc
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-titluc where recid(tt-titluc) = recatu1 no-lock.

        status default "".
        run color-message.
        choose field tt-titluc.titnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
        run color-normal.
        status default "".

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
                if not avail tt-titluc
                then leave.
                recatu1 = recid(tt-titluc).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                run leitura (input "up").
                if not avail tt-titluc
                then leave.
                recatu1 = recid(tt-titluc).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            run leitura (input "down").
            if not avail tt-titluc
            then next.
            color display white/red tt-titluc.titnum with frame frame-a.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            run leitura (input "up").
            if not avail tt-titluc
            then next.
            color display white/red tt-titluc.titnum with frame frame-a.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                    with frame f-com1.

            if esqcom1[esqpos1] = " MARCA"
            THEN DO:
                IF tt-titluc.agecod = "*"
                then assign
                        tt-titluc.agecod = ""
                        vtot-marcado = vtot-marcado - tt-titluc.titvlcob
                        vqtd-marcado = vqtd-marcado - 1.
                else assign 
                        tt-titluc.agecod = "*"
                        vtot-marcado = vtot-marcado + tt-titluc.titvlcob
                        vqtd-marcado = vqtd-marcado + 1.
                disp vtot-marcado vqtd-marcado with frame ff-total.
            END.

            if esqcom1[esqpos1] = " MARCA TUDO"
            THEN DO:
                find first tt-titluc where tt-titluc.agecod = "*" no-error.
                if not avail tt-titluc
                then
                    for each tt-titluc /***where tt-titluc.titsit = "LIB"***/.
                        tt-titluc.agecod = "*".
                    end.
                else
                    for each tt-titluc where tt-titluc.agecod = "*":
                        tt-titluc.agecod = "".
                    end. 
                recatu1 = ?.
                leave.
            END.

            if esqcom1[esqpos1] = " Situacao"
            THEN DO on error undo:
                find first btt-titluc where btt-titluc.agecod = "*" no-error.
                if not avail btt-titluc
                then do.
                    message "Nenhum premio marcado" view-as alert-box.
                    next.
                end.
                pause 0.
                disp sit-premio with frame fsit 1 down row 10 no-label
                      overlay 1 column column 35.
                choose field sit-premio with frame fsit.
                vindex = frame-index.
                hide frame fsit no-pause.
                sresp = no.
                message "Confirma troca de situacao?" update sresp.
                if not sresp
                then next.

                for each tt-titluc where tt-titluc.agecod = "*":
                    find titluc where titluc.empcod = tt-titluc.empcod and
                                      titluc.titnat = tt-titluc.titnat and
                                      titluc.modcod = tt-titluc.modcod and
                                      titluc.etbcod = tt-titluc.etbcod and
                                      titluc.clifor = tt-titluc.clifor and
                                  titluc.titnum = tt-titluc.titnum and
                                  titluc.titpar = tt-titluc.titpar
                                  no-error.
                    if avail titluc
                    then do:
                        assign
                            tt-titluc.titsit = sit-p[vindex]
                            tt-titluc.agecod = "".
                        assign
                            titluc.titsit = tt-titluc.titsit
                            titluc.datexp = today.
                    end.
                end.
                recatu1 = ?.
                leave.
            end.

            if esqcom1[esqpos1] = " PAGAMENTO"
            THEN do:
                if time < 61200
                then message "Pagamento somente apos as 17:00hs."
                             view-as alert-box.
                else RUN pagamento.
            END.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-titluc).
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
        tt-titluc.etbcod
        tt-titluc.titnum
        tt-titluc.vencod
        tt-titluc.titdtven
        tt-titluc.titvlcob 
        tt-titluc.titobs[2]
        tt-titluc.titnumger 
        tt-titluc.agecod 
        tt-titluc.titsit 
    with frame frame-a /*11 down centered color white/red row 5*/.
end procedure.


procedure color-message.
color display message
        tt-titluc.titnum
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        tt-titluc.titnum
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first tt-titluc use-index i1 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next tt-titluc use-index i1 no-lock no-error.
             
if par-tipo = "up" 
then find prev tt-titluc use-index i1 no-lock no-error.
        
end procedure.
         

procedure totaliza:

    assign
        tot-lib = 0
        tot-blo = 0
        tot-exc = 0
        tot-pen = 0
        vtotal-premio = 0
        vtot-marcado = 0
        vqtd-marcado = 0.

    for each btt-titluc.
        if btt-titluc.titsit = "BLO"
        then tot-blo = tot-blo + btt-titluc.titvlcob.
        if btt-titluc.titsit = "EXC"
        then tot-exc = tot-exc + btt-titluc.titvlcob.
        else if btt-titluc.titsit = "LIB"
        then tot-lib = tot-lib + btt-titluc.titvlcob.
        else if btt-titluc.titsit = "PEN"
        then tot-pen = tot-pen + btt-titluc.titvlcob.
                 

        if btt-titluc.agecod = "*"
        then assign
            vtot-marcado = vtot-marcado + btt-titluc.titvlcob
            vqtd-marcado = vqtd-marcado + 1.
end.


end procedure.        


procedure pagamento:
    /**********
    DEF VAR VNOME AS CHAR FORMAT "X(30)".
    def var vparam as char.
    def var vdescontar as dec.
    def var vtotalpagar as dec.
    def var vutiliza as log.
    vtotal-premio = 0.
    for each tt-titluc where
             tt-titluc.agecod = "*":
        vtotal-premio = vtotal-premio + tt-titluc.titvlcob.
    end.
    
    if vtotal-premio = 0
    then do:
        message color red/with
        "VOCE DEVE MARCAR AS DESPESAS PARA PAGAMENTO."
         view-as alert-box.
    end.
    else do:
    for each tp-contacor: delete tp-contacor. end.
    if vfuncod > 0
    then do:
        vparam = "C" + string(setbcod,"999") +
                   string(vfuncod,"999999") + "00000000" .
                   
        run agil4_WG.p("contacor", vparam).
    end.
    find first tp-contacor no-error.
    vutiliza = no.
    if avail tp-contacor and
        tp-contacor.valor > 0
    then do:
        vdescontar = vtotal-premio * (tp-contacor.pct / 100).
        if vdescontar > tp-contacor.valor
        then vdescontar = tp-contacor.valor.
        vtotalpagar = vtotal-premio - vdescontar. 
        run mensagem.p (input-output vutiliza,
                           input "CONSULTOR EM DEBITO.      " +
                                 "!VALOR DEBITO R$ " + 
                                  string(tp-contacor.valor,">>,>>9.99") +
                                 "!" + string(tp-contacor.pct,">>9%") +
                                  " DO VALOR DO PREMIO SERA " +
                                 "!DESTINADO A COMPENSACAO ." +
                                 "!!VALOR DO PREMIO =" + 
                                 string(vtotal-premio,">>>>,>>9.99")
                                 +  "!VALOR DESCONTAR = " +
                                 string(vdescontar,">>>,>>9.99")
                              +  "!TOTAL A PAGAR   = " + 
                              string(vtotalpagar,">>>,>>9.99")
                              +  "!!        CONFIRMA PAGAMENTO ? ",
                                 input "",
                                 input "Sim", 
                                 input "Nao").
        if vutiliza = yes
        then do:
            vparam = "A" + string(setbcod,"999") +
                   string(vfuncod,"999999") + 
                   string(vdescontar * 100,"99999999") .
            for each tp-contacor: delete tp-contacor. end.       
            run agil4_WG.p("contacor", vparam).
            find first tp-contacor no-error.
            if tp-contacor.confirma = "SIM"
            then.
            else do:
                vtotalpagar = vtotal-premio.
                vutiliza = no.
                run mensagem.p (input-output vutiliza,
                           input  
                           "NAO FOI POSSIVEL FAZER A COMPENSACAO." +
                                    "!!TOTAL A PAGAR  = " + 
                                    string(vtotalpagar,">>>,>>9.99")
                                 + "!!        CONFIRMA PAGAMENTO ? ",
                                 input "",
                                 input "Sim", 
                                 input "Nao").
 
            end.
        end.
    end.    
    else do:
        vtotalpagar = vtotal-premio.
        run mensagem.p (input-output vutiliza,
                           input "!!TOTAL A PAGAR  = " + 
                                    string(vtotalpagar,">>>,>>9.99")
                                 + "!!        CONFIRMA PAGAMENTO ? ",
                                 input "",
                                 input "Sim", 
                                 input "Nao").
    end.
    if vutiliza = yes
    then do:
        if vfuncod > 0
        then vnome = func.funnom.
        repeat on endkey undo:
            update vnome LABEL "NOME" 
                with frame f-nome title "    " + VQUEM[VINDEX] + "    "
                     SIDE-LABEL CENTERED ROW 18 OVERLAY.
            if vnome = ""
            then next.
            else leave.
        end.    
        for each tt-titluc where
             tt-titluc.agecod = "*":
            find titluc where 
                 titluc.empcod = tt-titluc.empcod and
                 titluc.titnat = tt-titluc.titnat and
                 titluc.modcod = tt-titluc.modcod and
                 titluc.etbcod = tt-titluc.etbcod and
                 titluc.clifor = tt-titluc.clifor and
                 titluc.titnum = tt-titluc.titnum and
                 titluc.titpar = tt-titluc.titpar
                 no-error.
            if avail titluc
            then do:
                assign
                    titluc.titvlpag = titluc.titvlcob *
                            (vtotalpagar / vtotal-premio)
                    titluc.titdtpag = today
                    titluc.etbcobra = setbcod
                    titluc.cxacod   = scxacod
                    titluc.titsit = "PAG"
                    titluc.datexp = today
                    .
                if titluc.titvlcob > titluc.titvlpag
                then titluc.titvldes = titluc.titvlcob  - titluc.titvlpag.
            end.     
            delete tt-titluc.
        end.
        if vquem[vindex] = "VENDEDOR"  or
        vquem[vindex] = "CREDIARISTA PLANO BIS"
        THEN run recibopremio.p (input vnome,
                      input vtotalpagar,
                      input 0,
                      input 0,
                      input 0).
        ELSE if vquem[vindex] = "GERENTE"
        THEN run recibopremio.p (input vnome,
                      input 0,
                      input vtotalpagar,
                      input 0,
                      input 0).
        ELSE if vquem[vindex] = "PROMOTOR"
        THEN run recibopremio.p (input vnome,
                      input 0,
                      input 0,
                      input 0,
                      input vtotalpagar).
    END.
    end.
    ***/
end procedure.
