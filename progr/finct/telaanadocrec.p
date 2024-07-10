/* helio 082023 - CESSÃO BARU - ORQUESTRA 536437 */
/* helio 15052023 - IOF na base diária da Carteira */
/* helio 28022022 - iepro */
/*26022021 helio*/
{admcab.i}

def input param vtitle     as char.
def input param poldfiltro as char.
def input param pfiltro    as char.
def input param poldctmcod  as char.
def input param poldmodcod   as char.
def input param poldtpcontrato as char.
def input param poldetbcod as int. 
def input param poldcobcod  as int.
def shared var vetbcod like estab.etbcod.
def shared var vdtini as date format "99/99/9999" label "De".
def shared var vdtfin as date format "99/99/9999" label "Ate".              
def var vvliof as dec.
def var vnro_parcela as int.

def buffer opdvdoc for pdvdoc.
def buffer ocmon for cmon.
def buffer opdvmov for pdvmov.

def new shared temp-table ttcontrato
    field contnum   like contrato.contnum
    index x is unique primary contnum asc.


def var pctmcod  as char.
def var pmodcod   as char.
def var ptpcontrato as char.
def var petbcod as int. 
def var pcobcod  as int.


def var vtitvlcob as dec.
def var vjuros as dec.
def var vdescontos as dec.
def var vtotal  as dec.


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5.

esqcom1 = "".

assign  esqcom1[1] = " consulta "
        esqcom1[2] = " operacao" .


        
def var vfiltro as char.
    find pdvtmov where pdvtmov.ctmcod = poldctmcod no-lock no-error.
    if avail pdvtmov
    then vfiltro = pdvtmov.ctmnom.
    else vfiltro = "".
    vfiltro = vfiltro + 
            if poldmodcod <> ?
            then "/" + poldmodcod
            else "".
    vfiltro = vfiltro + 
            if poldtpcontrato <> ?
            then "/" + if poldtpcontrato = "F"
                 then "FEI"
                 else if poldtpcontrato = "N"
                      then "NOV"
                      else if poldtpcontrato = "L"
                           then "LP "
                           else "   "
            else "".

    find cobra where cobra.cobcod = poldcobcod no-lock no-error.
    vfiltro = vfiltro + 
            (if poldcobcod <> ?
             then "/" + string(poldcobcod) + if avail cobra 
                                       then ("-" + cobra.cobnom)
                                       else ""
             else "").


disp
    vfiltro no-label format "x(50)"
        poldetbcod when poldetbcod <> ?
            label "Fil" format ">>>>"

    with frame fcab
    row 4 no-box
        side-labels
        width 80
        color underline.
def var par-dtini as date.
        
def new shared frame f-cmon.
    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "PDV" format ">>9"
         CMon.cxanom    no-label
         par-dtini          label "Dt Ini"
         CMon.cxadt         colon 65 format "99/99/9999" label "Data"
         with frame f-CMon row 3 width 81
                         side-labels no-box.
def new shared frame f-banco.
    form
        CMon.bancod    colon 12    label "Bco/Age/Cta"
        CMon.agecod             no-label
        CMon.ccornum            no-label format "x(15)"
        CMon.cxanom              format "x(16)" no-label
        func.funape             format "x(10)" no-label
        CMon.cxadt          format "99/99/9999" no-label
         with frame f-banco row 3 width 81 /*color messages*/
                         side-labels no-box.



form
    esqcom1
    with frame f-com1 width 81
                 row screen-lines no-box no-labels column 1 centered overlay.

assign
    esqpos1  = 1.


def temp-table ttpdvdoc no-undo
    field pdvdoc    as recid
    field contnum   like pdvdoc.contnum
    field titpar    like pdvdoc.titpar
    field datamov   like pdvdoc.datamov
    field horamov   like pdvmov.horamov
    field emissao   as log
    field permiteestorno as log 
    index x contnum asc titpar asc datamov asc horamov asc.
def buffer bttpdvdoc for ttpdvdoc.
    
def var vbusca like ttpdvdoc.contnum.
def var primeiro as log.
def var vtitpar like ttpdvdoc.titpar.

run gravatt.

if vtitle = "Origem"
then do:
    run fin/fqanadocorinov.p ("Origem",yes).
    return.
end. 

disp 
    space(32)
    vtitvlcob    no-label          format   "-zzzzzzz9.99"
    vjuros       no-label           format     "-zzzzz9.99"
    vdescontos   no-label        format     "-zzzzz9.99"
    vtotal       no-label          format   "-zzzzzzz9.99"
        with frame ftot
            side-labels
            row screen-lines - 1
            width 80
            no-box.



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
        pause 1 no-message.
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

            /*disp vtotal label "SALDO" 
                with frame f-sub side-label row 19 no-box.
              */
            find titulo where titulo.contnum = int(pdvdoc.contnum) and
                              titulo.titpar  = pdvdoc.titpar
                              no-lock no-error.
            if not avail titulo 
            then do: 
                esqcom1[3] = "".
                find contrato where contrato.contnum = int(pdvdoc.contnum) no-l~ock no-error.
                if avail contrato then
                find first titulo where titulo.empcod     = 19 and titulo.titna~t     = no and 
                    titulo.modcod     = contrato.modcod and 
                    titulo.etbcod     = contrato.etbcod and 
                    titulo.clifor     = contrato.clicod and 
                    titulo.titnum     = string(pdvdoc.contnum) and 
                    titulo.titpar     = pdvdoc.titpar
                    no-lock no-error.
            end.  
            else esqcom1[3] = "-".
            if ttpdvdoc.permiteestorno
            then do:
                if avail titulo   and pdvdoc.titvlcob > 0 
                then do:
                    if titulo.tittotpag >= pdvdoc.titvlcob or
                       (titulo.tittotpag = 0 and (titulo.titvlpag >= pdvdoc.titvlcob))
                    then esqcom1[3] = " estorno".
                end.    
            end.
            
                disp esqcom1 with frame f-com1.
            
            status default "".
            color disp message  pdvdoc.datamov.
            choose field pdvdoc.etbcod  
                                  help "[E]xporta para Arquivo csv"

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up         1 2 3 4 5 6 7 8 9 0
                        E e
                      PF4 F4 ESC return).
        if keyfunction(lastkey) = "0" or keyfunction(lastkey) = "1" or
           keyfunction(lastkey) = "2" or keyfunction(lastkey) = "3" or
           keyfunction(lastkey) = "4" or keyfunction(lastkey) = "5" or
           keyfunction(lastkey) = "6" or keyfunction(lastkey) = "7" or
           keyfunction(lastkey) = "8" or keyfunction(lastkey) = "9" 
        then do with centered row 8 color message
                                frame f-procura side-label overlay.
            vbusca = keyfunction(lastkey).
            pause 0.
            primeiro = yes.
            vtitpar = 0.
            update vbusca vtitpar label "Parcela"
                editing:
                    if primeiro
                    then do:
                        apply keycode("cursor-right").
                        primeiro = no.
                    end.
                readkey.
                apply lastkey.
            end.
            recatu2 = recatu1.
            recatu1 = ?.
            find first bttpdvdoc where bttpdvdoc.contnum = vbusca and 
                                bttpdvdoc.titpar = vtitpar
                                no-error.
            if avail bttpdvdoc
            then recatu1 = recid(bttpdvdoc).
            else do:
                recatu1 = recatu2.
                hide message no-pause.
                message "titulo nao encontrado nesta Selecao".
                pause 2 no-message.
                hide message no-pause.
            end.
            hide frame f-procura.
            leave.
        end.
        hide frame f-procura.

            color disp normal pdvdoc.etbcod pdvdoc.datamov.

            status default "".


        end.
                            if keyfunction(lastkey) = "E"
            then do:
                run geracsv.
                leave.
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

                    if esqcom1[esqpos1] = " Consulta "
                    then do:
                        hide frame f-com2   no-pause.
                        hide frame f-com1   no-pause.
                        hide frame frame-a  no-pause.
                        hide frame fcab     no-pause.
                        hide frame f1       no-pause.
                        find pdvmov of pdvdoc no-lock.
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

                        if avail titulo then  run bsfqtitulo.p ( input recid(titulo)).
                        pause 0.
                        view frame f-com2   . pause 0.
                        view frame f-com1   . pause 0.
                        view frame frame-a  . pause 0.
                        view frame fcab     . pause 0.
                        view frame f1       . pause 0.
                    end.
                     

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
                    
                    if esqcom1[esqpos1] = " Estorno "
                    then do:
                        /**
                        message "Confirma Estorno?" update sresp. 
                        if sresp
                        then do:
                            run fin/estornatitulo.p (recid(pdvdoc)).
                            return.
                        end.    
                        **/
                        hide frame f-com2   no-pause.
                        hide frame f-com1   no-pause.
                        hide frame frame-a  no-pause.
                        hide frame fcab     no-pause.
                        hide frame f1       no-pause.
                         
                        find titulo where titulo.contnum = int(pdvdoc.contnum) and titulo.titpar = pdvdoc.titpar no-lock no-error.
                        if avail titulo
                        then run fin/fqtitdoc.p (recid(titulo)).
                       pause 0.
                        view frame f-com2   . pause 0.
                        view frame f-com1   . pause 0.
                        view frame frame-a  . pause 0.
                        view frame fcab     . pause 0.
                        view frame f1       . pause 0.
                        
                        
                    end.
                    if esqcom1[esqpos1] = " csv"
                    then do:
                        recatu2 = recatu1.
                        run geracsv.
                        recatu1 = recatu2.
                        leave.
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
    find pdvtmov of pdvmov no-lock no-error.
    release cobra.
        find titulo where titulo.contnum = int(pdvdoc.contnum) and titulo.titpar = pdvdoc.titpar no-lock no-error.
        if avail titulo
        then find cobra of titulo no-lock.
    
        vjuros      = if pdvdoc.valor_encargo > 0 then pdvdoc.valor_encargo else 0.
        vdescontos  = if pdvdoc.valor_encargo < 0 then pdvdoc.valor_encargo * -1 else 0.  
    
    display
        pdvdoc.etbcod   column-label "Etb" format ">>9"
        cmon.cxacod   column-label "Cx" format ">>"
        pdvdoc.datamov  column-label "Data" format "999999"
        pdvtmov.ctmnom format "x(6)" when avail pdvtmov
            trim(string(pdvdoc.contnum) + (if pdvdoc.titpar > 0
                                  then "/" + string(pdvdoc.titpar)
                                  else "")) @ titulo.titnum
        cobra.cobnom when avail cobra format "x(04)" column-label "prop"                
        
        pdvdoc.titvlcob column-label "Vlr!Nominal"     format "->>>>9.99"      
        vjuros    column-label "Juro" format "->>>9.99"
        vdescontos column-label "Desc"         format "->>>9.99"
        pdvdoc.pago_parcial column-label "P" format "x(1)" when pdvdoc.pago_parcial <> "N"
        pdvdoc.valor   column-label "Total!Pago" format "->>>>9.99"
            when pdvdoc.placod = 0 or pdvdoc.placod = ?
                with frame frame-a 8 down centered row 7 
                width 80 overlay no-box.

end procedure.




procedure gravatt.

for each ttpdvdoc.
    delete ttpdvdoc.
end.

for each ttcontrato.
    delete ttcontrato.
end.
    
for each cmon 
    where if vetbcod = 0
          then true
          else cmon.etbcod = vetbcod
    no-lock.
        if not poldfiltro = "geral"
        then if poldetbcod <> ?
             then if cmon.etbcod <> poldetbcod
                  then next.
        for each pdvdoc where pdvdoc.etbcod = cmon.etbcod and pdvdoc.cmocod = cmon.cmocod and 
                pdvdoc.datamov >= vdtini and
                pdvdoc.datamov <= vdtfin no-lock.
            find pdvmov of pdvdoc no-lock.    
            
            find pdvtmov of pdvmov no-lock no-error.
            if not avail pdvtmov then next.
            if pdvtmov.novacao then next.
            
            if pdvdoc.pstatus = yes
            then.
            else next.    
            if pdvdoc.valor <> 0 and pdvdoc.placod = 0
            then.
            else next.
            if int(pdvdoc.contnum) = 0 or
               pdvdoc.contnum = ?
            then next.   
            release titulo.
            
            find titulo where titulo.contnum = int(pdvdoc.contnum) and
                                  titulo.titpar  = pdvdoc.titpar
                                  no-lock no-error.
            if not avail titulo
            then do:                           
                find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock no-error.
                if avail contrato
                then do: 
                    find titulo where
                            titulo.empcod = 19 and
                            titulo.titnat = no and
                            titulo.etbcod = contrato.etbcod and
                            titulo.clifor = contrato.clicod and
                            titulo.modcod = contrato.modcod and
                            titulo.titnum = pdvdoc.contnum and
                            titulo.titpar = pdvdoc.titpar and
                            titulo.titdtemi = contrato.dtinicial
                        no-lock no-error.
                end.
            end.                                                   
            
            if vtitle = "Origem"
            then do:
                find ttcontrato where ttcontrato.contnum = int(titulo.titnum) no-error.
                if not avail ttcontrato
                then do:
                    create ttcontrato.
                    ttcontrato.contnum = int(titulo.titnum).
                end.
                next.                            
            end.
            
            if pfiltro = "geral"
            then do:
                
            end.                 
            else do:
                ptpcontrato = if avail titulo then titulo.tpcontrato else "".
                pmodcod = if avail titulo then titulo.modcod else "".
                pcobcod = if avail titulo then titulo.cobcod else 0.
                pctmcod = pdvdoc.ctmcod.
                if poldtpcontrato <> ? and poldtpcontrato <> ptpcontrato then next. 
                if poldmodcod     <> ? and poldmodcod     <> pmodcod     then next.
                if poldcobcod     <> ? and poldcobcod     <> pcobcod     then next.
                if poldctmcod     <> ? and poldctmcod     <> pctmcod     then next.                        
            end.
                  
                vtitvlcob = vtitvlcob + pdvdoc.titvlcob.
                vjuros      = if pdvdoc.valor_encargo > 0 then pdvdoc.valor_encargo else 0.
                vdescontos  = if pdvdoc.valor_encargo < 0 then pdvdoc.valor_encargo * -1 else 0.  

                vtotal = vtotal + pdvdoc.valor.
                create ttpdvdoc.
                ttpdvdoc.pdvdoc = recid(pdvdoc).
                ttpdvdoc.contnum = pdvdoc.contnum.
                ttpdvdoc.titpar  = pdvdoc.titpar.
                ttpdvdoc.datamov = pdvdoc.datamov.
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
end.            

for each ttpdvdoc
    break by ttpdvdoc.contnum by ttpdvdoc.titpar by ttpdvdoc.datamov by ttpdvdoc.horamov.
    if ttpdvdoc.permiteestorno
    then if not last-of(ttpdvdoc.titpar)
         then ttpdvdoc.permiteestorno = no.

end.
           
end procedure.



procedure geracsv.
   def var varq as char format "x(76)".
   def var vcp  as char init ";".

   varq = "/admcom/tmp/ctb/conciliacao" + ( if vetbcod = 0 then "ger" else string(vetbcod)) + 
                             "_baixas" + string(vdtini,"99999999") + "_" + string(vdtfin,"99999999")  + "_" +
                             string(today,"999999")  +  replace(string(time,"HH:MM:SS"),":","") +
                             ".csv" .
                               
    pause 0.
    update skip(2) varq skip(2)
        with
        centered 
        overlay
        color messages
        no-labels
        row 8
        title "arquivo de saida".
        
    output to value(varq).    
        put unformatted 
            vfiltro skip.
            
        put unformatted
        "Fililal"   vcp
        "Cx"      vcp
        "DataMov"  vcp
        "TipoMov" vcp
        "NomeMov"  vcp 
        "Contrato" vcp
        "Parcela" vcp
        "codProp" vcp
        "propriedade" vcp
        "Vlr Nominal" vcp
        "Vlr Juros" vcp
        "Vlr Desconto" vcp
        "Vlr Movimento" vcp                       
        "parcial?" vcp
        "cliente" vcp 
        "codigoPedido-Ecom" vcp
        "vlr custas " vcp
        "vlr iof" vcp
        "Baru" vcp
            skip.        
    
    for each ttpdvdoc.

    
        find pdvdoc where recid(pdvdoc) = ttpdvdoc.pdvdoc no-lock.
        find pdvmov of pdvdoc no-lock.
        find cmon   of pdvmov no-lock.
        find pdvtmov of pdvmov no-lock.
        release cobra.
        
        
        
        find titulo where titulo.contnum = int(pdvdoc.contnum) and titulo.titpar = pdvdoc.titpar no-lock no-error.

        /* helio 15052023 */
        find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock.
        
            if not avail titulo 
            then do: 
                if avail contrato then
                find first titulo where titulo.empcod     = 19 and titulo.titnat     = no and 
                    titulo.modcod     = contrato.modcod and 
                    titulo.etbcod     = contrato.etbcod and 
                    titulo.clifor     = contrato.clicod and 
                    titulo.titnum     = string(pdvdoc.contnum) and 
                    titulo.titpar     = pdvdoc.titpar
                    no-lock no-error.
            end.  
        
        if avail titulo
        then do:
            find cobra of titulo no-lock.
            find first contrsite where contrsite.contnum = int(titulo.titnum)  no-lock no-error.
       end.
        
        
        vvliof = 0. 
        vnro_parcela = contrato.nro_parcela.
        if vnro_parcela = 0
        then do:
            def buffer xtitulo for titulo.
                for each  xtitulo where
                        xtitulo.empcod = 19 and
                        xtitulo.titnat = no and
                        xtitulo.etbcod = contrato.etbcod and
                        xtitulo.clifor = contrato.clicod and
                        xtitulo.modcod = contrato.modcod and
                        xtitulo.titnum = string(contrato.contnum) and
                        xtitulo.titdtemi = contrato.dtinicial
                        no-lock.
                        vnro_parcela = vnro_parcela + 1.    
                end.                        
    
        end.
        if contrato.vliof > 0
        then vvliof = contrato.vliof / vnro_parcela.
        /* helio 15052023 */

        vjuros      = if pdvdoc.valor_encargo > 0 then pdvdoc.valor_encargo else 0.
        vdescontos  = if pdvdoc.valor_encargo < 0 then pdvdoc.valor_encargo * -1 else 0.  
               
        put unformatted
        pdvdoc.etbcod   vcp
        cmon.cxacod     vcp
        pdvdoc.datamov format "99/99/9999" vcp
        pdvtmov.ctmcod  vcp
        pdvtmov.ctmnom  vcp 
        trim(string(pdvdoc.contnum)) vcp
         pdvdoc.titpar vcp
        if avail titulo then titulo.cobcod else ""  vcp
        if avail cobra then cobra.cobnom else "" vcp
                
        pdvdoc.titvlcob vcp
        vjuros    vcp
        vdescontos         vcp
        pdvdoc.valor            vcp
        pdvdoc.pago_parcial     vcp
        if avail titulo then titulo.clifor else pdvdoc.clifor vcp
            (if avail contrsite
             then contrsite.codigoPedido
             else "" ) vcp
        pdvdoc.titvlrcustas vcp            
        trim(string(vvliof,"->>>>>>>>>>>>>>>>>>>>9.99")) vcp /* helio 15052023 */
        string(titulo.cessaobaru,"Sim/Nao") vcp
            skip.        
    end.
    
    output close.
    message varq "gerado com sucesso.".
    pause 2 no-message.

end procedure.
