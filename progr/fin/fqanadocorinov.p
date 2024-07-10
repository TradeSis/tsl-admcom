/*
*
*
*/
{admcab.i}

def input param vtitle     as char.
def input param pestorno   as log.

def var vpg as log.
def shared temp-table ttcontrato
    field contnum   like contrato.contnum
    index x is unique primary contnum asc.

def var vvlrorigem  as dec.
def var vvlrnovacao as dec.


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5.

esqcom1 = "".

assign  esqcom1[1] = " Consulta "
        esqcom1[2] = " Operacao" 
        esqcom1[3] = " csv".


        
pause 0.

disp
    vtitle no-label format "x(50)"
    with frame fcab
    row 6 no-box
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




def new shared temp-table ttnovacao no-undo
    field tipo      as char
    field contnum   like contrato.contnum format ">>>>>>>>>>9"
    field valor     like contrato.vltotal
    field saldoabe  like titulo.titvlcob  
    index idx is unique primary tipo desc contnum asc.

def new shared temp-table ttpdvmov no-undo
    field rec    as recid
    field tipo      as char
    field contnum   like contrato.contnum format ">>>>>>>>>>9"
    field valor     like contrato.vltotal
    field primeiro  as log
    field saldoabe  like titulo.titvlcob  
        index idx is unique primary rec asc tipo desc contnum asc.


run gravatt.
find first ttpdvmov no-error.

if not avail ttpdvmov
then do:
    message "nenhuma novacao encontrada.".
    pause 3 no-message.
    return.
end.

disp 
    space(32)
    vvlrorigem label "origem"         format   "-zzzzzzz9.99"
    vvlrnovacao label "novacao"        format   "-zzzzzzz9.99"
        with frame ftot
            side-labels
            row screen-lines - 2
            width 80
            no-box.



bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find  ttpdvmov where recid(ttpdvmov) = recatu1 no-lock.
    if not available ttpdvmov
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

    recatu1 = recid(ttpdvmov).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttpdvmov
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
            find ttpdvmov where recid(ttpdvmov) = recatu1 no-lock.
            find pdvmov where recid(pdvmov) = ttpdvmov.rec no-lock.

            status default "".
            color disp message  pdvmov.datamov
        pdvmov.etbcod
        cmon.cxacod 
        pdvmov.datamov 
        pdvtmov.ctmnom 
        pdvmov.sequencia 
        ttpdvmov.tipo
        ttpdvmov.contnum
        ttpdvmov.valor
         ttpdvmov.saldoabe.
            
            esqcom1[4] = "".    
            if ttpdvmov.tipo = "NOVO"
            then do:
                vpg = no.
                for each titulo where titulo.contnum = ttpdvmov.contnum no-lock.
                    if titulo.titpar = 0 then next.
                    if titulo.tittotpag = 0 
                    then.
                    else vpg = yes.
                end.    
                
                if vpg = no and setbcod = 999 and pestorno 
                then do:
                    esqcom1[4] = " estorna nov".
                end.    
                else esqcom1[4] = " -----------".
            end.

            disp esqcom1 with frame f-com1.
            
            
            choose field pdvmov.etbcod  help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            color disp normal pdvmov.etbcod pdvmov.datamov
                    pdvmov.etbcod
        cmon.cxacod 
        pdvmov.datamov 
        pdvtmov.ctmnom 
        pdvmov.sequencia 
        ttpdvmov.tipo
        ttpdvmov.contnum
        ttpdvmov.valor 
        ttpdvmov.saldoabe.
            

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
                    if not avail ttpdvmov
                    then leave.
                    recatu1 = recid(ttpdvmov).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttpdvmov
                    then leave.
                    recatu1 = recid(ttpdvmov).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttpdvmov
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttpdvmov
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

                        run conco_v1701.p (string(ttpdvmov.contnum)).
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
                        run dpdv/pdvcope.p ( input recid(pdvmov)).
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
                    if esqcom1[esqpos1] = " estorna nov"
                    then do:
                        
                        hide message no-pause.
                        sresp = no.
                        run sys/message.p (input-output sresp,
                           input "confirma estorno completo " +
                                 " da novacao ?",
                                   input " !! ATENCAO !! ",
                                   input "    SIM",
                                   input "    NAO").
                        run fin/estornanovacao.p (input ttpdvmov.rec).
                        return.
                    end.
                    
                    
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttpdvmov).
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
        find first ttpdvmov where 
                    true
                                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
        find next ttpdvmov  where
                true
                                       no-lock no-error.
             
if par-tipo = "up" 
then                  
        find prev ttpdvmov where 
                true
        
                                 no-lock no-error.
        
end procedure.

procedure frame-a.  

    find pdvmov where recid(pdvmov) = ttpdvmov.rec no-lock.
    find cmon   of pdvmov no-lock.
    find pdvtmov of pdvmov no-lock.

    if ttpdvmov.primeiro
    then display
        pdvmov.etbcod   column-label "Etb" format ">>9"
        cmon.cxacod   column-label "Cx" format ">>"
        pdvmov.datamov  column-label "Data" format "999999"
        pdvtmov.ctmnom format "x(7)" column-label "movim"
        pdvmov.sequencia format ">>9"
            with frame frame-a.
     disp       
        ttpdvmov.tipo
        ttpdvmov.contnum
        ttpdvmov.valor column-label "Original"     format "->>>>>9.99"      
        ttpdvmov.saldoabe column-label "em aberto"     format "->>>>>9.99"      
        
                with frame frame-a 8 down centered row 7 
                width 80 overlay no-box.

end procedure.




procedure gravatt.
def var vprimeiro as log.
hide message no-pause.
message "fazendo calculos... aguarde...".
for each ttpdvmov.
    delete ttpdvmov.
end.

for each ttcontrato no-lock.
    for each pdvdoc where pdvdoc.contnum = string(ttcontrato.contnum) no-lock.
            if pdvdoc.pstatus = yes
            then.
            else next.    
            if pdvdoc.valor <> 0 and pdvdoc.placod = 0
            then.
            else next.

                find pdvmov of pdvdoc no-lock.
                find pdvtmov of pdvmov no-lock.
                if pdvtmov.novacao = no 
                then next.
                
                if pdvtmov.ctmcod <> "ENO"
                then do: 
                run fin/montattnov.p (recid(pdvmov),NO).
                vprimeiro = yes.
                for each ttnovacao.
                    find first ttpdvmov where
                        ttpdvmov.rec        = recid(pdvmov) and
                        ttpdvmov.tipo       = ttnovacao.tipo and
                        ttpdvmov.contnum    = ttnovacao.contnum
                        no-error.
                    if not avail ttpdvmov
                    then do:
                        create ttpdvmov.
                        ttpdvmov.rec        = recid(pdvmov).
                        ttpdvmov.tipo       = ttnovacao.tipo.
                        ttpdvmov.contnum    = ttnovacao.contnum.
                        ttpdvmov.valor      = ttnovacao.valor.
                        ttpdvmov.saldoabe   = ttnovacao.saldoabe.
                        ttpdvmov.primeiro   = vprimeiro.
                        vprimeiro = no.
                        if ttnovacao.tipo = "ORIGINAL"
                        then vvlrorigem   = vvlrorigem  + ttnovacao.valor.
                        else vvlrnovacao  = vvlrnovacao + ttnovacao.valor.
                    end.
                    delete ttnovacao.       
                end.
                end.
                 
                
    end.

    find contrato where contrato.contnum = ttcontrato.contnum no-lock.
                             
                find first pdvmoeda where pdvmoeda.modcod = contrato.modcod                and
                                    pdvmoeda.titnum = string(contrato.contnum)
                                    no-lock no-error.
            
                if avail pdvmoe
                then do:
                                       
                    find first pdvmov of pdvmoe no-lock no-error.
                
                    if not avail pdvmov then next.
                    find pdvtmov of pdvmov no-lock.
                    if pdvtmov.novacao = no
                    then next.
                
                
                    run fin/montattnov.p (recid(pdvmov),NO).
                    vprimeiro = yes.
                    for each ttnovacao.
                        find first ttpdvmov where
                            ttpdvmov.rec        = recid(pdvmov) and
                            ttpdvmov.tipo       = ttnovacao.tipo and
                            ttpdvmov.contnum    = ttnovacao.contnum
                            no-error.
                        if not avail ttpdvmov
                        then do:
                            create ttpdvmov.
                            ttpdvmov.rec        = recid(pdvmov).
                            ttpdvmov.tipo       = ttnovacao.tipo.
                            ttpdvmov.contnum    = ttnovacao.contnum.
                            ttpdvmov.valor      = ttnovacao.valor.
                            ttpdvmov.saldoabe   = ttnovacao.saldoabe.
                            ttpdvmov.primeiro   = vprimeiro.
                            vprimeiro = no.
                            if ttnovacao.tipo = "ORIGINAL"
                            then vvlrorigem   = vvlrorigem  + ttnovacao.valor.
                            else vvlrnovacao  = vvlrnovacao + ttnovacao.valor.
                        end.
                    delete ttnovacao.       
                end.
        end.           

end.
    
hide message no-pause.
end procedure.




procedure geracsv.
def var vprimeiro as log.
def var vvlf_acrescimo as dec.

    
   def var varq as char format "x(60)".
   def var vcp  as char init ";".
   varq = "/admcom/relat/" + "novori_" + string(today,"999999")  + string(time) +
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
        "Filial"   vcp
        "Cx"      vcp
        "DataMov"  vcp
        "NomeMov"  vcp 
        "Seq"      vcp
        "Tipo Contrato" vcp 
    
        "Contrato (Original)" vcp
        "Parcela" vcp
        "codProp" vcp
        "propriedade" vcp
        "Vlr Nominal" vcp
        "Vlr Juros" vcp
        "Vlr Desconto" vcp
        "Vlr Movimento" vcp                       
        "Contrato (Novacao)" vcp

                    "Dt Novacao" vcp
                    "Entrada"  vcp
                    "codProp" vcp
                    "propriedade" vcp
                    "acrescimo" vcp
                    "vlr total" vcp
                    "vlr seguro" vcp
        
            skip.        

    
    for each ttpdvmov.

        find pdvmov where recid(pdvmov) = ttpdvmov.rec no-lock.
        find cmon   of pdvmov no-lock.
        find pdvtmov of pdvmov no-lock.

        put unformatted
            pdvmov.etbcod  vcp
            cmon.cxacod    vcp
            pdvmov.datamov format "99/99/9999" vcp 
            pdvtmov.ctmnom vcp
            pdvmov.sequencia vcp
            ttpdvmov.tipo  vcp.
        if ttpdvmov.tipo = "ORIGINAL"
        then do:
            vprimeiro = yes.
            for each pdvdoc of pdvmov 
                    where pdvdoc.contnum = string(ttpdvmov.contnum)
                    no-lock
                    by pdvdoc.contnum by pdvdoc.titpar.
                    
                if vprimeiro = no
                then do:
                    put unformatted                 
                        pdvmov.etbcod vcp
                        cmon.cxacod   vcp
                        pdvmov.datamov format "99/99/9999" vcp
                        pdvtmov.ctmnom vcp
                        pdvmov.sequencia vcp
                        ttpdvmov.tipo  vcp.
                           
                end.
                release cobra.
                find titulo where titulo.contnum = int(pdvdoc.contnum) and titulo.titpar = pdvdoc.titpar no-lock no-error.
                if avail titulo
                then find cobra of titulo no-lock.
                
                put unformatted
                    trim(string(pdvdoc.contnum)) vcp 
                    pdvdoc.titpar vcp
                    if avail titulo then titulo.cobcod else ""  vcp
                    if avail cobra then cobra.cobnom else "" vcp
                    pdvdoc.titvlcob vcp
                    pdvdoc.valor_encargo    vcp
                    pdvdoc.desconto         vcp
                    pdvdoc.valor            vcp
                    skip.
                    
                vprimeiro = no.
                 
                    
            end.
        end.
        else do: 
        
            vprimeiro = yes.
            for each contrato where contrato.contnum = ttpdvmov.contnum no-lock.
                            
                if vprimeiro = no
                then do:
                    put unformatted                 
                        pdvmov.etbcod vcp
                        cmon.cxacod   vcp
                        pdvmov.datamov format "99/99/9999" vcp
                        pdvtmov.ctmnom vcp
                        pdvmov.sequencia vcp
                        ttpdvmov.tipo  vcp.
                end.
                release cobra.
                find first sicred_contrato where sicred_contrato.contnum = contrato.contnum no-lock no-error.
                if avail sicred_contrato
                then find cobra where cobra.cobcod = sicred_contrato.cobcod no-lock no-error.

                vvlf_acrescimo = contrato.vltotal - contrato.vlentra - contrato.vlf_principal - contrato.vlseguro - contrato.vliof.
                if vvlf_acrescimo < 0
                then vvlf_acrescimo = 0.
                
                put unformatted
                
                    "" vcp 
                    "" vcp
                    "" vcp
                    "" vcp
                    "" vcp
                    "" vcp
                    "" vcp
                    "" vcp

                    trim(string(contrato.contnum)) vcp 
                    contrato.dtinicial format "99/99/9999" vcp
                    contrato.vlentra    vcp
                    if avail sicred_contrato then sicred_contrato.cobcod else ""  vcp
                    if avail cobra then cobra.cobnom else "" vcp
                    vvlf_acrescimo vcp
                    contrato.vltotal vcp
                    contrato.vlseguro vcp
                     skip.
            end.         
        end.      
    end.
    
    output close.
    message varq "gerado com sucesso.".
    pause 2 no-message.

end procedure.


