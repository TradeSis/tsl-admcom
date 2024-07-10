/*
*
*    Esqueletao de Programacao
*
*/

{admcab.i new}

def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Relatorio","Gera Despesa","","",""]
            .
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
esqregua  = yes.
esqpos1  = 1.
esqpos2  = 1.

def temp-table tt-promo
    field vencod as int
    field nome   as char
    field valor  as dec
    field premiov as dec
    field premiog as dec
    field numero like plani.numero
    index i1 nome
    .

def var vdatven as date init today.
def var vdatveni as date.
def var vdatvenf as date.

update vdatveni label "Informe o Periodo de"
       vdatvenf label "Ate"
    with frame ff1 side-label WIDTH 80.
if vdatvenf > 05/31/08
then return.
def var vok as log.
for each estab no-lock:
    disp " Processando vendas... Aguarde! --> "
        estab.etbcod with frame f-pro 
        no-label 1 down color message centered row 10 no-box
        .
    pause 0.    
for each plani where plani.movtdc = 5 and
                     plani.etbcod = estab.etbcod and
                     plani.pladat >= vdatveni and
                     plani.pladat <= vdatvenf
                     no-lock.
    disp plani.pladat plani.numero format ">>>>>>9"
        with frame f-pro.
    pause 0.    
    find func where func.funcod = plani.vencod and
                    func.etbcod = plani.etbcod
                    no-lock no-error.
    if not avail func then next.                
    find first tt-promo where
               tt-promo.vencod = plani.vencod 
               no-error.
    if not avail tt-promo
    then do:
        create tt-promo.
        tt-promo.vencod = plani.vencod.
        tt-promo.nome   = func.funnom.
        tt-promo.numero = plani.numero.
    end. 
    vok = no.           
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat
                         no-lock:
        find produ where produ.procod = movim.procod no-lock no-error.
        if not avail produ then next.
        if produ.clacod = 201
        then do:
            vok = yes.
            leave.
        end.
    end.   
    if vok
    then tt-promo.valor = tt-promo.valor + 1.
end.     
end.         
for each tt-promo  where tt-promo.valor < 35:
       delete tt-promo.
end.       
def var vi as dec.
for each tt-promo:
    vi = tt-promo.valor / 35.
    vi = int(substr(string(vi,">>9.99"),1,3)).
    tt-promo.premiov = 100 * vi.
    tt-promo.premiog = 30 * vi.
end.
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
    
    display tt-promo.vencod column-label "Codigo"
            tt-promo.nome   column-label "Nome Vendedor"  format "x(30)"
            tt-promo.valor  column-label "Valor venda"
            tt-promo.premiov column-label "Premio!Vendedor"
            tt-promo.premiog column-label "Premio!Gerente"
            with frame frame-a 13 down centered.

    recatu1 = recid(tt-promo).
    
    color display message esqcom1[esqpos1] with frame f-com1.

    repeat:
    
        find next tt-promo no-lock no-error.
        
        if not available tt-promo
        then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        
        down with frame frame-a.
        
        display tt-promo.vencod
            tt-promo.nome 
            tt-promo.valor  
            tt-promo.premiov
            tt-promo.premiog 
            with frame frame-a.

    end.
    
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-promo where recid(tt-promo) = recatu1 no-lock no-error.

        choose field tt-promo.vencod go-on(cursor-down cursor-up 
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
            
            color display normal tt-promo.vencod.
            
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
            
            color display normal tt-promo.vencod.
            
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
                if sresp then run relatorio.
                recatu1 = recid(chq).
                leave.
            end.
            
            if esqcom1[esqpos1] = "Gera Despesa"
            then do:
                sresp = no.
                message "Confirma gerar despesa? " update sresp.
                if sresp then run gerardespesa.    
                recatu1 = recid(chq).
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
        display tt-promo.vencod
            tt-promo.nome 
            tt-promo.valor  
            tt-promo.premiov
            tt-promo.premiog 
            with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(chq).
   end.
end.

procedure relatorio:
    
    def var varquivo as char.
    
    varquivo = "/usr/admcom/relat/rbon" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999").
                                    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "100" 
                &Page-Line = "66" 
                &Nom-Rel   = ""RELPSEL1"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """PREMIACAO VENDAS CELULAR CLARO"" 
                           + "" - LOJA "" 
                           + string(estab.etbcod) + "" - "" 
                           + estab.etbnom " 
                &Width     = "100"
                &Form      = "frame f-cabcab"}

    for each tt-promo use-index i1:
        disp tt-promo.vencod column-label "Codigo"
             tt-promo.nome   column-label "Nome Vendedor"
             tt-promo.valor  column-label "Total Venda"
             tt-promo.premiov (total) column-label "Premio!Vendedor"
             tt-promo.premiog (total) column-label "Premio!Gerente" 
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
    
    vnumero = int(string(day(vdatven),"99") + 
                  string(month(vdatven),"99") + 
                  substr(string(year(vdatven),"9999"),3,2) + 
                  string(setbcod,"999")).
                   
                  
                find titluc where titluc.empcod = 19  
                              and titluc.titnat = yes  
                              and titluc.modcod = "COM"  
                              and titluc.etbcod = 999  
                              and titluc.clifor = 110706
                              and titluc.titnum = string(vnumero) 
                              and titluc.titpar = 1 no-error.
                if not avail titluc
                then do:
                    do transaction:
                    create titluc.  
                    assign titluc.empcod   = 19  
                           titluc.titnat   = yes  
                           titluc.modcod   = "COM"  
                           titluc.etbcod   = 999  
                           titluc.clifor   = 110706
                           titluc.titnum   = string(vnumero)
                           titluc.titpar   = 1  
                           titluc.titdtemi = today 
                           titluc.titdtven = today
                           titluc.titvlcob = vvalor
                           titluc.titvlpag = 0 
                           titluc.titdtpag = ?
                           titluc.cobcod   = 1  
                           titluc.titsit   = "LIB"  
                           titluc.cxacod   = 0  
                           titluc.evecod   = 4  
                           titluc.cxmdat   = ?   
                           titluc.etbcobra = 0  
                           titluc.datexp   = today 
                           titluc.titobs[1] = "".
                end.
    find current titluc no-lock no-error.
    /*
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
    end.    
end procedure.
