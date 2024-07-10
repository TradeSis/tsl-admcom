/* helio 26122022 - https://trello.com/c/oUZNGfoi/874-registro-de-titulo-n%C3%A3o-est%C3%A1-dispon%C
3%ADvel */

/* helio 28022022 - iepro */
{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5.
def buffer opdvdoc for pdvdoc.
def buffer ocmon for cmon.
def buffer opdvmov for pdvmov.
esqcom1 = "".

assign  esqcom1[1] = " Consulta "
        esqcom1[2] = " Operacao "
        esqcom1[3] = " Estorna ".

def var vdispensa   like pdvdoc.desconto column-label "dispensa".
def var vjuros      as dec column-label "juros!calculado". 
def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def var vjurocobrado as dec.


def var vhora as char format "x(5)".

def input parameter par-rec as recid.

find titulo where recid(titulo) = par-rec no-lock.

def var vtotal          like titulo.titvlcob column-label "Saldo c/Juro".
def var vcartcobra      as   char column-label "Carteira".
def var vldevido        like titulo.titvlcob.
def var vdias           as   int   format ">>>>>9".
def var vtottitvlpag    like pdvdoc.valor.

/***
find clifor of titulo no-lock.
display clifor.clfcod
        clifor.cgccpf
        clifor.clfnom no-label format "x(25)"
        clifor.situacao format "/BLOQUEADO" no-label
            with side-label row 3 width 81 fsgrame f1 1 down no-hide no-box
                            color message .
***/
do:
        vtotal =    (if titulo.dtultpgparcial <> ?
                     then titulo.titvltot
                     else titulo.titvlcob )  - titulo.tittotpag.
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
            if titulo.dtultpgparcial <> ?
            then titulo.titvltot
            else titulo.titvlcob @ titulo.titvltot format ">>>>,>>9.99"
            with frame fcab 1 down centered row 4 width 81
                                 color messages no-box overlay.

end.

form
    esqcom1
    with frame f-com1 width 81
                 row screen-lines no-box no-labels column 1 centered overlay.

assign
    esqpos1  = 1.


def temp-table ttpdvdoc no-undo
    field pdvdoc    as recid
    field datamov   as date
    field horamov   as int
    field emissao   as log
    field permiteestorno as log
    index x datamov asc horamov asc.
def buffer bttpdvdoc for ttpdvdoc.
for each pdvmoe where pdvmoe.modcod = titulo.modcod and
                      pdvmoe.titnum = titulo.titnum and
                      pdvmoe.titpar  = titulo.titpar
                      no-lock.
  
    find pdvmov of pdvmoe no-lock.
    /*
    if pdvmov.ctmcod = "NCY" then next.
    */
    find first pdvdoc of pdvmov no-lock.
    find first ttpdvdoc where ttpdvdoc.pdvdoc = recid(pdvdoc) no-error.
    if not avail ttpdvdoc
    then do:
        create ttpdvdoc.
        ttpdvdoc.pdvdoc = recid(pdvdoc).
        ttpdvdoc.emissao = yes.
        ttpdvdoc.permiteestorno = no.
        ttpdvdoc.datamov = pdvmov.datamov.
        ttpdvdoc.horamov = pdvmov.horamov.
    end.
end.    
for each pdvdoc where pdvdoc.contnum = titulo.titnum and
                      pdvdoc.titpar = titulo.titpar and
                      pdvdoc.pstatus = yes
                no-lock:
    find pdvmov of pdvdoc no-lock.
    
    vtottitvlpag = vtottitvlpag + pdvdoc.valor.

    create ttpdvdoc. 
    assign ttpdvdoc.pdvdoc  = recid(pdvdoc).
    
    ttpdvdoc.datamov = pdvmov.datamov.
    ttpdvdoc.horamov = pdvmov.horamov.
    
    ttpdvdoc.permiteestorno = pdvdoc.valor > 0.
    
    if pdvdoc.datamov <= 07/01/2020 /* virada sap */
    then ttpdvdoc.permiteestorno = no.
    
          if pdvdoc.orig_loja <> 0
          then do:
                find first opdvdoc where
                    opdvdoc.etbcod = pdvdoc.orig_loja and
                    opdvdoc.cmocod = pdvdoc.orig_componente and
                    opdvdoc.datamov = pdvdoc.orig_data and
                    opdvdoc.sequencia = pdvdoc.orig_nsu and
                    opdvdoc.seqreg   = pdvdoc.orig_vencod
                    no-lock no-error.
                if avail opdvdoc
                then do:
                    ttpdvdoc.permiteestorno = no.
                    find first bttpdvdoc where bttpdvdoc.pdvdoc = recid(opdvdoc) no-error.
                    if avail bttpdvdoc
                    then bttpdvdoc.permiteestorno = no.
                end.                       
           end.
            if setbcod <> 999 
            then ttpdvdoc.permiteestorno = no.
            if  pdvdoc.ctmcod = "CSE"  or  
                pdvdoc.ctmcod = "P48" /* novacao */ or 
                pdvdoc.ctmcod = "EST" /* estorno */ or 
                pdvdoc.ctmcod = "ENO" /* estorno novacao */ 
            then ttpdvdoc.permiteestorno = no.
            
      
end.
/*
for each ttpdvdoc
    break by ttpdvdoc.datamov by ttpdvdoc.horamov.
    if ttpdvdoc.permiteestorno
    then if not last(ttpdvdoc.datamov)
         then ttpdvdoc.permiteestorno = no.

end.
**/

def var p-recid-pdvdoc as recid.
find first ttpdvdoc no-error.
if not avail ttpdvdoc  and titulo.titdtpag > 07/01/20 /*virada SAP*/
then do:
    run fin/gerpdvdoctit.p(input recid(titulo),
                           output p-recid-pdvdoc).
    if p-recid-pdvdoc <> ?
    then do:
        find pdvdoc where recid(pdvdoc) = p-recid-pdvdoc no-lock.
        find pdvmov of pdvdoc no-lock.
        create ttpdvdoc.
        create ttpdvdoc. 
        assign ttpdvdoc.pdvdoc  = recid(pdvdoc)
               ttpdvdoc.datamov = pdvdoc.datamov
               ttpdvdoc.horamov = pdvmov.horamov
               ttpdvdoc.permiteestorno = pdvdoc.valor > 0.
    
        if pdvdoc.datamov <= 07/01/2020 /* virada sap */
        then ttpdvdoc.permiteestorno = no.
    end.                       
end.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find  ttpdvdoc where recid(ttpdvdoc) = recatu1 no-lock.
    if not available ttpdvdoc
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

    recatu1 = recid(ttpdvdoc).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttpdvdoc
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
            find ttpdvdoc where recid(ttpdvdoc) = recatu1 no-lock.
            find pdvdoc where recid(pdvdoc) = ttpdvdoc.pdvdoc no-lock.
            disp vtotal label "SALDO" 
                with frame f-sub side-label row 19 no-box.
            
            /**** 26122022 fora
            find titulo where titulo.contnum = int(pdvdoc.contnum) and
                              titulo.titpar  = pdvdoc.titpar
                              no-lock no-error.
            if not avail titulo 
            then do: 
                find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock no-error.
                if avail contrato then
                find first titulo where titulo.empcod     = 19 and titulo.titnat     = no and 
                    titulo.modcod     = contrato.modcod and 
                    titulo.etbcod     = contrato.etbcod and 
                    titulo.clifor     = contrato.clicod and 
                    titulo.titnum     = string(pdvdoc.contnum) and 
                    titulo.titpar     = pdvdoc.titpar
                    no-lock no-error.
            end.
            ***/                                                                               esqcom1[3] = "-".
            if ttpdvdoc.permiteestorno
            then do:
                if avail titulo   and pdvdoc.titvlcob > 0 
                then do:
                    if titulo.tittotpag >= pdvdoc.titvlcob or
                       (titulo.tittotpag = 0 and (titulo.titvlpag >= pdvdoc.titvlcob))
                    then esqcom1[3] = " Estorna".
                end.    
            end.
                         
                disp esqcom1 with frame f-com1.

            status default pdvdoc.hispaddesc.

            if pdvdoc.valor < 0 
            then do:
                find first opdvdoc where
                    opdvdoc.etbcod = pdvdoc.orig_loja and
                    opdvdoc.cmocod = pdvdoc.orig_componente and
                    opdvdoc.datamov = pdvdoc.orig_data and
                    opdvdoc.sequencia = pdvdoc.orig_nsu and
                    opdvdoc.seqreg   = pdvdoc.orig_vencod
                    no-lock no-error.
                if avail opdvdoc
                then do:
                    find first opdvmov of opdvdoc no-lock no-error.
                    find ocmon of opdvdoc no-lock.
                    status default "estornou fil: " + string(opdvdoc.etbcod) + 
                                   "/" + string(ocmon.cxacod) + 
                                   " " + string(opdvdoc.datamov,"99/99/9999") +
                                   
                                   " " + (if avail opdvmov then string(opdvmov.horamov,"HH:MM") else "") +
                                   " tipo: " + opdvdoc.ctmcod +
                                   " seq: " + string(opdvdoc.sequencia).
                end.
                                    
        
            end.            
            if pdvdoc.ctmcod = "ENO" 
            then do:
                find first opdvmov where
                    opdvmov.etbcod = pdvdoc.orig_loja and
                    opdvmov.cmocod = pdvdoc.orig_componente and
                    opdvmov.datamov = pdvdoc.orig_data and
                    opdvmov.sequencia = pdvdoc.orig_nsu
                    no-lock no-error.
                if avail opdvmov
                then do:
                    find ocmon of opdvmov no-lock.
                    status default "estornou fil: " + string(opdvmov.etbcod) + 
                                   "/" + string(ocmon.cxacod) + 
                                   " " + string(opdvmov.datamov,"99/99/9999") +
                                   
                                   " " + (if avail opdvmov then string(opdvmov.horamov,"HH:MM") else "") +
                                   " tipo: " + opdvmov.ctmcod .
                end.
                                    
        
            end.            
            
            color disp message  pdvdoc.datamov.
            choose field pdvdoc.etbcod  help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            color disp normal pdvdoc.etbcod pdvdoc.datamov.

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
                    if not avail ttpdvdoc
                    then leave.
                    recatu1 = recid(ttpdvdoc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttpdvdoc
                    then leave.
                    recatu1 = recid(ttpdvdoc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttpdvdoc
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttpdvdoc
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                    if esqcom1[esqpos1] = " Operacao "
                    then do:
                        hide frame f-com2   no-pause.
                        hide frame f-com1   no-pause.
                        hide frame frame-a  no-pause.
                        hide frame fcab     no-pause.
                        hide frame f1       no-pause.
                        find pdvmov of pdvdoc no-lock.
                        run dpdv/pdvcope.p ( input recid(pdvmov)).
                        pause 0.
                        view frame f-com2   . pause 0.
                        view frame f-com1   . pause 0.
                        view frame frame-a  . pause 0.
                        view frame fcab     . pause 0.
                        view frame f1       . pause 0.
                    end.
                    
                    if esqcom1[esqpos1] = " Consulta "
                    then do:
                        hide frame f-com2   no-pause.
                        hide frame f-com1   no-pause.
                        hide frame frame-a  no-pause.
                        hide frame fcab     no-pause.
                        hide frame f1       no-pause.
                        find pdvmov of pdvdoc no-lock.
                        
                        /***
                        find titulo where titulo.contnum = int(pdvdoc.contnum) and
                                          titulo.titpar = pdvdoc.titpar
                                          no-lock no-error.
                        find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock.
    
                        find first titulo where
                            titulo.empcod = 19 and
                            titulo.titnat = no and
                            titulo.etbcod = contrato.etbcod and
                            titulo.clifor = contrato.clicod and
                            titulo.modcod = contrato.modcod and
                            titulo.titnum = string(contrato.contnum) and
                            titulo.titpar = pdvdoc.titpar and
                            titulo.titdtemi = contrato.dtinicial
                            no-lock no-error.
                        ***/
                        if avail titulo then  run bsfqtitulo.p ( input recid(titulo)).
                        pause 0.
                        view frame f-com2   . pause 0.
                        view frame f-com1   . pause 0.
                        view frame frame-a  . pause 0.
                        view frame fcab     . pause 0.
                        view frame f1       . pause 0.
                    end.
                     
                    if esqcom1[esqpos1] = " Estorna "
                    then do:
                        message "Confirma Estorno?" update sresp. 
                        if sresp
                        then do:
                            run fin/estornatitulo.p (recid(pdvdoc)).
                            return.
                        end.    
                        
                    end.
                    
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttpdvdoc).
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
        find first ttpdvdoc where 
                    true
                                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
        find next ttpdvdoc  where
                true
                                       no-lock no-error.
             
if par-tipo = "up" 
then                  
        find prev ttpdvdoc where 
                true
        
                                 no-lock no-error.
        
end procedure.

procedure frame-a.  

    find pdvdoc where recid(pdvdoc) = ttpdvdoc.pdvdoc no-lock.
    find pdvmov of pdvdoc no-lock.
    find cmon   of pdvmov no-lock.
    find pdvtmov of pdvmov no-lock.
                vjurocobrado = 0.
                vdispensa = 0.
                if pdvdoc.desconto > 0
                then do:
                    vjurocobrado = pdvdoc.valor_encargo - pdvdoc.desconto.
                    vjuros    = pdvdoc.valor_encargo.
                    vdispensa = pdvdoc.desconto.
                end.    
                else do:
                    vjurocobrado = pdvdoc.valor_encargo.
                
                    /* helio 26102023 - calcula dispensa apenas para operacoes de matriz
                        ID 49747 - Entendimento de regra(Juro cobrado) */
                    if pdvdoc.etbcod >= 900
                    then do:
                        run juro_titulo_data.p (titulo.etbcod, titulo.titdtven, pdvdoc.titvlcob,
                                                pdvdoc.datamov, output vjuros).
                        vdispensa = vjuros - pdvdoc.valor_encargo.
                        if vdispensa < 0
                        then vdispensa = 0. 
                    end.
                    
                end.
    display
        pdvdoc.etbcod   column-label "Etb" format ">>9"
/*        cmon.cmtcod column-label "TCM" */
        cmon.cxacod   column-label "Cx" format ">>"
        pdvdoc.datamov  column-label "Data" format "999999"
/*        string(int(pdvmov.horamov), "hh:mm") @ vhora format "x(05)" column-label "Hora" */
        pdvdoc.ctmcod column-label "tip"
        pdvtmov.ctmnom format "x(10)"
        pdvdoc.titvlcob column-label "Vlr!Nominal"     format "->>>>>9.99"       when ttpdvdoc.emissao = no
        
        vjurocobrado   column-label "juros!cobrado" format "->>>9.99"   when ttpdvdoc.emissao = no

        vdispensa column-label "dispensa"         format "->>>9.99"   when ttpdvdoc.emissao = no

        pdvdoc.pago_parcial column-label "P" format "x(1)"   when ttpdvdoc.emissao = no
        pdvdoc.titvlrcustas    column-label "custas" format "->>9.99"   when ttpdvdoc.emissao = no

        pdvdoc.valor   column-label "Total!Pago" format "->>>>>9.99"   when ttpdvdoc.emissao = no

                
                with frame frame-a 8 down centered row 7 
                width 80 overlay no-box.

end procedure.
