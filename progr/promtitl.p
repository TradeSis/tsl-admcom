/*
*
*    Esqueletao de Programacao
*
*/

{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Relatorio","","","",""]
            .
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


form
        esqcom1
            with frame f-com1
                 row 8 no-box no-labels side-labels centered.
form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
esqregua  = yes.
esqpos1  = 1.
esqpos2  = 1.

def temp-table tt-promo
    field etbcod like estab.etbcod
    field vencod as int
    field nome   as char
    field valor  as dec
    field premiov as dec
    field premiog as dec
    field numero like plani.numero
    index i1 etbcod nome
    .

def var vdatven as date init today.
def var vdatveni as date.
def var vdatvenf as date.
def var vetbcod like estab.etbcod        .
def var vforcod like foraut.forcod.
                           .
def buffer bestab for estab.

update vetbcod label "Filial"
       with frame ff1.
if vetbcod > 0
then do:
    find bestab where bestab.etbcod = vetbcod no-lock .
    disp bestab.etbnom no-label with frame ff1.
         
end.
update vforcod at 1 label "Fornecedor"
       with frame ff1.
find foraut where foraut.forcod = vforcod no-lock.
disp foraut.fornom no-label with frame ff1.

vdatveni = 06/01/08.
vdatvenf = today - 1.
update
       vdatveni at 1 label "Periodo de"  format "99/99/9999"
       vdatvenf label "Ate"                        format "99/99/9999"
    with frame ff1 side-label width 80.
if vdatvenf > 12/31/08
then return.
def var vok as log.
for each bestab where
        (if vetbcod > 0
        then bestab.etbcod = vetbcod else true) no-lock:
    disp "Processando vendas... Aguarde! --> " bestab.etbcod
        with frame f-pro 1 down centered row 10 color message no-box.
    pause 0. 
    for each titluc where titluc.etbcobra = bestab.etbcod and
                          titluc.titdtpag >= vdatveni and
                          titluc.titdtpag <= vdatvenf and
                          titluc.clifor    = vforcod
                          no-lock:

        disp titluc.titdtpag titluc.titnum with frame f-pro.
        pause 0.
        /**
        find first plani where plani.movtdc = 5 and
                               plani.etbcod = bestab.etbcod and
                               plani.emite  = bestab.etbcod and
                               plani.serie = "V" and
                               plani.pladat = int(titluc.titnum) 
                               no-lock no-error.
        find func where func.funcod = plani.vencod and
                    func.etbcod = plani.etbcod
                    no-lock no-error.
        if not avail func then next.       
        **/         
        find first tt-promo where
               tt-promo.etbcod = bestab.etbcod 
               no-error.
        if not avail tt-promo
        then do:
            create tt-promo.
            tt-promo.etbcod = bestab.etbcod.
        end. 
        tt-promo.valor = tt-promo.valor + titluc.titvlpag.
    end.
end.     
for each tt-promo:
    if tt-promo.valor = 0
    then delete tt-promo.
    else  tt-promo.premiog = tt-promo.valor * .10.
end.       
def var vi as dec.

bl-princ:
repeat:

    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then find first tt-promo no-lock no-error.
    else find tt-promo where recid(tt-promo) = recatu1 no-lock no-error.

    if not available tt-promo
    then do:
        message color red/with
            "Nenhum registro encontrado"
            view-as alert-box.
        leave bl-princ.    
    end.

    clear frame frame-a all no-pause.
    
    find bestab where bestab.etbcod = tt-promo.etbcod no-lock.
    display tt-promo.etbcod column-label "Fil"  
            bestab.etbnom no-label    
            tt-promo.valor  column-label "Valor pago"
            tt-promo.premiog column-label "PG 10%"
            with frame frame-a  row 9 down centered.

    recatu1 = recid(tt-promo).
    
    color display message esqcom1[esqpos1] with frame f-com1.

    repeat:
    
        find next tt-promo no-lock no-error.
        
        if not available tt-promo
        then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        
        down with frame frame-a.
        
        find bestab where bestab.etbcod = tt-promo.etbcod no-lock.
        display 
            tt-promo.etbcod
            bestab.etbnom
            tt-promo.valor  
            tt-promo.premiog
            with frame frame-a.

    end.
    
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-promo where recid(tt-promo) = recatu1 no-lock no-error.

        choose field tt-promo.etbcod go-on(cursor-down cursor-up 
                                         cursor-left cursor-right 
                                         tab PF4 F4 ESC return).

        if keyfunction(lastkey) = "TAB"
        then do:
        
            if esqregua
            then do:
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
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 6
                          then 6
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
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
        
        if keyfunction(lastkey) = "cursor-down"
        then do:
        
            find next tt-promo
                        no-lock no-error.
            
            if not avail tt-promo
            then next.
            
            color display normal tt-promo.etbcod.
            
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.

        end.

        if keyfunction(lastkey) = "cursor-up"
        then do:
        
            find prev tt-promo
                            no-lock no-error.
            if not avail tt-promo
            then next.
            
            color display normal tt-promo.etbcod.
            
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
            
        end.
        
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        
        hide frame frame-a no-pause.

        if esqregua
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Relatorio"
            then do:
                sresp = no.
                message "Confirma Imprimir ?" update sresp.
                if sresp 
                then do:
                    run relatorio.
                end.
                recatu1 = recid(tt-promo).
                leave.
            end.
            
            if esqcom1[esqpos1] = "Gera Despesa"
            then do:
                sresp = no.
                message "Confirma gerar despesa? " update sresp.
                if sresp then run gerardespesa.    
                recatu1 = recid(tt-promo).
                leave.
            end.
            
            if esqcom1[esqpos1] = "Confirma"
            then do: 
                leave.
            end.
        end. 
        else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
        end.
          view frame frame-a .
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        find bestab where bestab.etbcod = tt-promo.etbcod no-lock.
        display 
            tt-promo.etbcod
            bestab.etbnom
            tt-promo.valor  
            tt-promo.premiog
            with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-promo).
   end.
end.

procedure relatorio:
    
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/prom"  + string(time).
    else varquivo = "l:\relat\prom" + string(time).
                                    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""promtitl"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """PREMIO GERENTE""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}
    disp with frame ff1.
    for each tt-promo use-index i1:
        find bestab where bestab.etbcod = tt-promo.etbcod no-lock.
        disp tt-promo.etbcod column-label "Fil"
             bestab.etbnom
             tt-promo.valor   (total) column-label "Quant.!Vendida"
             tt-promo.premiog(total)  column-label "PG 10%"
            with frame f-disp down width 100.
        down with frame f-disp.    
    end.
    
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.     

end procedure.

procedure gerardespesa:
    def var varquivo as char.
    def var vttv as dec.
    def var vttg as dec.
    
    def var vtv as dec.
    def var vtg as dec.
    def var vvalor as dec.
    def var vnumero as int.
    for each tt-promo use-index i1:
        vtv = vtv + tt-promo.premiov.
        vtg = vtg + tt-promo.premiog.
    end.
    vvalor = vtv + vtg.
    /*
    vnumero = int(string(day(vdatven),"99") + 
                  string(month(vdatven),"99") + 
                  substr(string(year(vdatven),"9999"),3,2) + 
                  string(setbcod,"999")).
                   
                  
                find titluc where titluc.empcod = 19  
                              and titluc.titnat = yes  
                              and titluc.modcod = "COM"  
                              and titluc.etbcod = setbcod  
                              and titluc.clifor = 110658 
                              and titluc.titnum = string(vnumero) 
                              and titluc.titpar = 1 no-error.
                if not avail titluc
                then do:
                    do transaction:
                    create titluc.  
                    assign titluc.empcod   = 19  
                           titluc.titnat   = yes  
                           titluc.modcod   = "COM"  
                           titluc.etbcod   = setbcod  
                           titluc.clifor   = 110658
                           titluc.titnum   = string(vnumero)
                           titluc.titpar   = 1  
                           titluc.titdtemi = today 
                           titluc.titdtven = today
                           titluc.titvlcob = vvalor
                           titluc.titvlpag = vvalor
                           titluc.titdtpag = today
                           titluc.cobcod   = 1  
                           titluc.titsit   = "PAG"  
                           titluc.cxacod   = scxacod  
                           titluc.cobcod   = 1
                           titluc.evecod   = 4  
                           titluc.cxmdat   = today  
                           titluc.etbcobra = setbcod  
                           titluc.datexp   = today 
                           titluc.titobs[1] = "".
                end.
    find current titluc no-lock no-error.
    varquivo = "/usr/admcom/spool/" + "vale-dinmao1." + string(time).
    
    output to value(varquivo).

        put chr(29) + chr(33) + chr(0) skip.      /* tamanho da fonte */

        put chr(27) + chr(97) + chr(49) skip.       /* centraliza */
   
        put chr(27) + "!" + chr(48) skip.
       
        put "RECIBO" skip.

        put chr(27) + chr(64) skip.     
       
        put chr(27) + chr(50) skip.
        put chr(29) + chr(33) + chr(10) skip.      /* tamanho da fonte */
        put chr(27) + chr(77) + chr(49) skip.
    
        put chr(27) + chr(97) + chr(48) skip.    /* justifica esquerda */ 

        put "Filial         : " at 1 setbcod       format ">>9"         skip.
        put "Data Premiacao : " at 1 vdatven       format "99/99/9999" skip.
        put "--------------------------------------" skip.
        put "Vendedor                     Valor    " skip.
        put "--------------------------------------" skip.
        for each tt-promo use-index i1:
            put 
                tt-promo.nome    format "x(25)"
                tt-promo.premiov skip.
            vttv = vttv + tt-promo.premiov.
            vttg = vttg + tt-promo.premiog.
        end.
        put "--------------------------------------" skip.
        put "Total Gerente             " format "x(25)" vttg skip.     
        put "--------------------------------------" skip.
        put "Data  Pagamento: " titluc.titdtpag skip.
        put "Caixa Pagamento: " titluc.cxacod skip.
        put chr(10) skip.

        put chr(27) + chr(97) + chr(49) skip.       /* centraliza */

        put chr(29) + chr(86) + chr(66) skip.      /* corta */ 
        put chr(27) + chr(64) skip.                /* reseta */

    output close.
    
    if scarne = "local"
    then unix silent /fiscal/lp value(varquivo).
    else unix silent /fiscal/lp value(varquivo) 1.
    /*
    run recibdesfv.p (input recid(plani),
                      input vtv,
                      input vtg,
                      input 0).
    */
    end.
    else do:
        message color red/with
        "DESPESA JA FOI GERADA."
        view-as alert-box.
    end. */   
end procedure.
