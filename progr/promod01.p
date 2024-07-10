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
def var vok-plano as log.
def var p-fincod like plani.crecod.
def var p-etbcod like estab.etbcod.
def var p-ok as log. 
def var esqcom1         as char format "x(16)" extent 4
            initial ["  Imprime","Despesas Geradas","  Gera Despesas",""]
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
    field etbcod like estab.etbcod
    field vencod as int
    field nome   as char
    field valor  as dec
    field premiov as dec
    field premiog as dec
    field premiot as dec
    field numero like plani.numero
    field linha as int
    index i1 etbcod vencod
    .

def temp-table tt-movim like movim.

def var vdata-teste-promo as date.
def var funcao as char format "x(20)".
def var parametro as char format "x(20)".
input from ./admcom.ini no-echo.
repeat:
    set funcao parametro.
    if funcao = "DATA-TESTE-PROMOCAO"
    then vdata-teste-promo = date(parametro).
end.
input close.

def temp-table tt-promoc like ctpromoc.

{setbrw.i}

def buffer bctpromoc for ctpromoc.
def buffer fctpromoc for ctpromoc.
def buffer ectpromoc for ctpromoc.
 
form    skip(1)
        tt-promoc.sequencia   format ">>>>9"
     tt-promoc.descricao[1]      format "x(70)"
     tt-promoc.descricao[2] at 7 format "x(70)"
     with frame esc-promo down no-label
     title "             ESCOLHA PROMOCAO          " .
     
for each ctpromoc where  (if vdata-teste-promo <> ?
                              then ctpromoc.dtinicio <= vdata-teste-promo
                              else ctpromoc.dtinicio <= today) and
         ctpromoc.dtfim  >= today and
         ctpromoc.linha = 0
         no-lock:
    if ctpromoc.tipo <> "Diaria" or
       ctpromoc.situacao <> "L" 
    then next.
    create tt-promoc.
    buffer-copy ctpromoc to tt-promoc.
end.              

l1:
repeat:

    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        a-seelst = ?.
    
    {sklcls.i    
        &file   = tt-promoc
        &cfield = tt-promoc.descricao[1]
        &ofield = "tt-promoc.descricao[2]
                   tt-promoc.sequencia
                  "
        &where  = true 
        &naoexiste1 = " bell.
                message color red/with
                    ""Nenhum regsitro encontrado""
                    view-as alert-box.
                    return. "
        &aftselect1 = "
                if keyfunction(lastkey) = ""RETURN""
                THEN leave l1.
                " 
        &form = " frame esc-promo "
    }
    if keyfunction(lastkey) = "END-ERROR"
    THEN RETURN.
end.
 
find ctpromoc where 
    ctpromoc.sequencia = tt-promoc.sequencia and
    ctpromoc.linha = 0 
    no-lock no-error.
    
def var val-venda as dec.
def var val-vendaf as dec.
val-venda = ctpromoc.vendaacimade.
val-vendaf = ctpromoc.campodec2[3].
def var val-gerente as dec. 
val-gerente = ctpromoc.valgerente.
def var val-vendedor as dec.
val-vendedor = ctpromoc.valvendedor.
def var valor-vista as log.
valor-vista = ctpromoc.campolog3.
def var valor-acumulado as log.
if ctpromoc.campolog4 = yes
then valor-acumulado = no.
else valor-acumulado = yes.
def var forne-vendedor as int   format ">>>>>>>>9".
def var forne-gerente  as int   format ">>>>>>>>9".
def var forne-supervisor as int format ">>>>>>>>9".
def var forne-promotor as int   format ">>>>>>>>9".
def var cod-forne as int        format ">>>>>>>>9".
assign
    cod-forne = int(acha("FORNECEDOR",ctpromoc.campochar[2]))
    forne-vendedor   = int(acha("FORNE-VENDEDOR",ctpromoc.campochar[2]))
    forne-gerente    = int(acha("FORNE-GERENTE",ctpromoc.campochar[2]))
    forne-supervisor = int(acha("FORNE-SUPERVISOR",ctpromoc.campochar[2]))
    forne-promotor   = int(acha("FORNE-PROMOTOR",ctpromoc.campochar[2]))
    .

def var na-promocao as log.


procedure find-pro-promo:
    na-promocao = no.
    def buffer bclase for clase.
    def buffer cclase for clase.
    find clase where clase.clacod = produ.clacod no-lock no-error.
    if not avail clase
    then.
    else do:
     find bclase where bclase.clacod = clase.clasup no-lock no-error.
     find cclase where cclase.clacod = bclase.clasup no-lock no-error.

    find first fctpromoc where
               fctpromoc.sequenci = ctpromoc.sequencia and
               fctpromoc.procod = produ.procod and
               produ.procod > 0
               no-lock no-error.
    if not avail fctpromoc
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = produ.clacod and
                    fctpromoc.clacod > 0  
                    no-lock no-error.
    if not avail fctpromoc
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = clase.clasup   and
                    clase.clasup > 0
                    no-lock no-error.
    
    if not avail fctpromoc and bclase.clasup > 0
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = bclase.clasup   and
                    clase.clasup > 0
                    no-lock no-error.
    if not avail fctpromoc and cclase.clasup > 0
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = cclase.clasup   and
                    clase.clasup > 0
                    no-lock no-error.
    if not avail fctpromoc
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = 0 and
                    fctpromoc.setcod = produ.catcod and
                    produ.catcod > 0
                    no-lock no-error.
    if not avail fctpromoc
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = 0 and
                    fctpromoc.setcod = 0 and
                    fctpromoc.fabcod = produ.fabcod and
                    produ.fabcod > 0
                    no-lock no-error.
    end.
    if avail fctpromoc
    then na-promocao = yes.
end procedure.                

def var vdatven as date.
vdatven = today.
def var vetbcod like estab.etbcod.
def buffer bestab for estab.
update      vetbcod label "Filial" with frame ff1 width 80.
if vetbcod > 0
then do:
    find bestab where bestab.etbcod = vetbcod no-lock.
    disp bestab.etbnom no-label with frame ff1.
end.
update vdatven at 1 label "Informe a Data" format "99/99/9999"
    with frame ff1 side-label.
/* if vdatven < ctpromoc.dtinicio
then return. */
def var vok as log.
def var v-ind as dec.
for each estab where (if vetbcod > 0
                    then estab.etbcod = vetbcod else true)
                    no-lock:
    p-etbcod = estab.etbcod.
    p-ok = no.
    run valida-filial.
    if p-ok = no
    then next.                
    for each plani where plani.movtdc = 5 and
                     plani.etbcod = estab.etbcod and
                     plani.pladat = vdatven
                     no-lock.
    
    p-fincod = plani.pedcod.
    p-ok = no.
    run valida-plano.
    if p-ok = no then next.
    
    disp "Processando... ==>> " estab.etbcod plani.numero format ">>>>>>>>9"
        with frame f-pro 1 down centered row 10 no-box no-label.
    pause 0. 
    
    /*
    p-fincod = plani.pedcod.
    vok-plano = no.    
    run ver-plano-pag. 
    if vok-plano = no then next.   
    */
    
    find first func where func.funcod = plani.vencod and
                    func.etbcod = plani.etbcod
                    no-lock no-error.
    find first tt-promo where
               tt-promo.etbcod = plani.etbcod and 
               tt-promo.vencod = plani.vencod 
               no-error.
    if not avail tt-promo
    then do:
        create tt-promo.
        tt-promo.etbcod = plani.etbcod.
        tt-promo.vencod = plani.vencod.
        tt-promo.nome   = (if avail func
                then func.funnom else "").
        tt-promo.numero = plani.numero.
    end. 
    vok = no.           
    for each tt-movim:
        delete tt-movim.
    end.    
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat
                         no-lock:
        find produ where produ.procod = movim.procod no-lock no-error.
        if not avail produ then next.
        na-promocao = no.
        run find-pro-promo.
        
        if na-promocao
        then do:
            vok = yes.
            create tt-movim.
            buffer-copy movim to tt-movim.
            /*leave.*/
        end.
    end.   
    if vok
    then do:
        v-ind = 0.
        for each tt-movim :
            v-ind = (tt-movim.movqtm * tt-movim.movpc) / plani.protot.
            if valor-vista
            then tt-promo.valor = tt-promo.valor +  (plani.platot * v-ind).
            else tt-promo.valor = tt-promo.valor +    
                (if plani.biss > 0
                  then (plani.biss * v-ind)
                  else (plani.platot * v-ind)).
            v-ind = 0.
        end.
    end. 
    end.
end.              

for each tt-promo where tt-promo.valor <= val-venda:
       delete tt-promo.
end.
for each tt-promo where tt-promo.vencod = 150:
       delete tt-promo.
end.        
def var vi as dec.
for each tt-promo:
    if valor-acumulado or
        val-venda = val-vendaf
    then do:
        vi = tt-promo.valor / val-venda.
        vi = int(substr(string(vi,">>9.99"),1,3)).
    end.
    else vi = 1.
    tt-promo.premiov = val-vendedor * vi.
    tt-promo.premiog = val-gerente * vi.
end.
def var v-total as dec.
def var g-total as dec.
def var t-total as dec.
def var vlinha as int.
def buffer btt-promo for tt-promo.
for each tt-promo break by tt-promo.etbcod:
    tt-promo.premiot = tt-promo.premiov + tt-promo.premiog.
    v-total = v-total + tt-promo.premiov.
    g-total = g-total + tt-promo.premiog.
    t-total = t-total + tt-promo.premiot.
    vlinha = vlinha + 1.
    tt-promo.linha = vlinha.
    if last-of(tt-promo.etbcod)
    then do:
        create btt-promo.
        btt-promo.etbcod = tt-promo.etbcod.
        btt-promo.vencod = 9999.
        btt-promo.nome   = "TOTAL FILIAL " + STRING(tt-promo.etbcod).
        btt-promo.numero = 0.
        btt-promo.premiov = v-total.
        btt-promo.premiog = g-total.
        btt-promo.premiot = t-total.
        btt-promo.linha   = vlinha + 1.
        v-total = 0.
        g-total = 0.
        t-total = 0.
        vlinha = 0.
    end.
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
    
    display tt-promo.etbcod column-label "Fil"   
                when tt-promo.vencod <> 9999
            tt-promo.vencod column-label "Codigo" format ">>>9"
                when tt-promo.vencod <> 9999
            tt-promo.nome   column-label "Nome Vendedor"  format "x(20)"
            tt-promo.valor  column-label "Valor!venda"
            tt-promo.premiov column-label "Premio!Vendedor"
            tt-promo.premiog column-label "Premio!Gerente"
            tt-promo.premiot column-label "Premio!Total"
            with frame frame-a 13 down width 80.

    recatu1 = recid(tt-promo).
    
    color display message esqcom1[esqpos1] with frame f-com1.

    repeat:
    
        find next tt-promo no-lock no-error.
        
        if not available tt-promo
        then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        
        down with frame frame-a.
        
        display tt-promo.etbcod when tt-promo.linha = 1
            tt-promo.vencod  when tt-promo.vencod <> 9999
            tt-promo.nome 
            tt-promo.valor  
            tt-promo.premiov
            tt-promo.premiog 
            tt-promo.premiot
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
            
            color display normal tt-promo.vencod when tt-promo.vencod <> 9999.
            
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
            
            color display normal tt-promo.vencod when tt-promo.vencod <> 9999.
            
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
            pause 0.
            if esqcom1[esqpos1] = "  Imprime"
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
            
            if esqcom1[esqpos1] = "Despesas Geradas"
            then do:
                run promod02.p(input vetbcod, input vdatven, 
                                input ctpromoc.sequencia).    
                recatu1 = recid(tt-promo).
                leave.
            end.
            
            if esqcom1[esqpos1] = "  Gera Despesas"
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
        display 
            tt-promo.etbcod when tt-promo.vencod <> 9999
            tt-promo.vencod when tt-promo.vencod <> 9999
            tt-promo.nome 
            tt-promo.valor  
            tt-promo.premiov
            tt-promo.premiog 
            tt-promo.premiot
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
    then varquivo = "/admcom/relat/promodia" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999").
    else varquivo = "l:\relat\promodia" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999").
                                    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "100" 
                &Page-Line = "66" 
                &Nom-Rel   = ""PROMODIA"" 
                &Nom-Sis   = """SISTEMA ESTOQUE""" 
                &Tit-Rel   = """ LISTAGEM DE PREMIACAO """ 
                &Width     = "100"
                &Form      = "frame f-cabcab"}

    disp ctpromoc.descricao[1]
         ctpromoc.descricao[2]
         with frame fcc1 no-label.
    
    for each tt-promo use-index i1 
            where tt-promo.vencod <> 9999 
        break by tt-promo.etbcod      :
        if first-of(tt-promo.etbcod)
        then disp tt-promo.etbcod column-label "Fil"
            with frame f-disp.
        disp tt-promo.vencod column-label "Codigo"
             tt-promo.nome   column-label "Nome Vendedor"
             tt-promo.valor  column-label "Total Venda"
             tt-promo.premiov (total by tt-promo.etbcod)
                column-label "Premio!Vendedor"
             tt-promo.premiog (total by tt-promo.etbcod)
                column-label "Premio!Gerente" 
             tt-promo.premiot (total by tt-promo.etbcod)
                column-label "Premio!Total"
            with frame f-disp down width 100.
        down with frame f-disp.    
    end.
    
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    message "Arquivo gerado: " + varquivo.
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
    /**
    for each tt-promo use-index i1:
        vtv = vtv + tt-promo.premiov.
        vtg = vtg + tt-promo.premiog.
    end.
    vvalor = vtv + vtg.
    **/

    for each tt-promo where 
             tt-promo.vencod <> 9999 no-lock:
        find first func where 
                   func.funcod = tt-promo.vencod and
                   func.etbcod = tt-promo.etbcod no-lock no-error.
             
        vnumero = int(string(day(vdatven),"99") + 
                  string(month(vdatven),"99") + 
                  substr(string(year(vdatven),"9999"),3,2) + 
                  string(tt-promo.etbcod,"999")).
                   
        pause 1 no-message.          
        find titluc where titluc.empcod = 19  
                              and titluc.titnat = yes  
                              and titluc.modcod = "COM"  
                              and titluc.etbcod = tt-promo.etbcod  
                              and titluc.clifor = forne-vendedor 
                              and titluc.titnum = string(vnumero) 
                              and titluc.titpar = tt-promo.vencod no-error.
        if not avail titluc
        then do transaction:
                    create titluc.  
                    assign titluc.empcod   = 19  
                           titluc.titnat   = yes  
                           titluc.modcod   = "COM"  
                           titluc.etbcod   = tt-promo.etbcod  
                           titluc.clifor   = forne-vendedor
                           titluc.titnum   = string(vnumero)
                           titluc.vencod   = tt-promo.vencod
                           titluc.titpar   = tt-promo.vencod  
                           titluc.titdtemi = vdatven 
                           titluc.titdtven = today
                           titluc.titvlcob = tt-promo.premiov
                           titluc.titvlpag = 0
                           titluc.titdtpag = ?
                           titluc.cobcod   = 1  
                           titluc.titsit   = "LIB"  
                           titluc.cxacod   = 0  
                           titluc.cobcod   = 1
                           titluc.evecod   = 4  
                           titluc.cxmdat   = ?  
                           titluc.etbcobra = 0  
                           titluc.datexp   = today 
                           titluc.titobs[1] = "".
            if avail func 
            then 
                assign
                titluc.titobs[1] = string(func.funcod) + " - " + func.funnom
                titluc.titobs[2] = "|PREMIO=VENDEDOR".
                .
            
            if today >= 01/01/2010
            then assign
                         titluc.titsit = "BLO"
                         titluc.cxacod = 0
                         titluc.cobcod = 2
                         titluc.evecod = 5 .

        end.
    end.
    for each tt-promo where 
             tt-promo.vencod = 9999 no-lock:
 
            vnumero = int(string(day(vdatven),"99") + 
                  string(month(vdatven),"99") + 
                  substr(string(year(vdatven),"9999"),3,2) + 
                  string(tt-promo.etbcod,"999")).

            find titluc where titluc.empcod = 19  
                              and titluc.titnat = yes  
                              and titluc.modcod = "COM"  
                              and titluc.etbcod = tt-promo.etbcod  
                              and titluc.clifor = forne-gerente 
                              and titluc.titnum = string(vnumero) 
                              and titluc.titpar = 99 no-error.
            if not avail titluc
            then do transaction:
                    create titluc.  
                    assign titluc.empcod   = 19  
                           titluc.titnat   = yes  
                           titluc.modcod   = "COM"  
                           titluc.etbcod   = tt-promo.etbcod  
                           titluc.clifor   = forne-gerente
                           titluc.titnum   = string(vnumero)
                           titluc.titpar   = 99  
                           titluc.titdtemi = vdatven 
                           titluc.titdtven = today
                           titluc.titvlcob = tt-promo.premiog
                           titluc.titvlpag = 0
                           titluc.titdtpag = ?
                           titluc.cobcod   = 1  
                           titluc.titsit   = "LIB"  
                           titluc.cxacod   = 0 
                           titluc.cobcod   = 1
                           titluc.evecod   = 4  
                           titluc.cxmdat   = ? 
                           titluc.etbcobra = 0 
                           titluc.datexp   = today 
                           titluc.titobs[1] = " GERENTE ".

                    titluc.titobs[2] = "|PREMIO=GERENTE".
                    
                    if today >= 01/01/2010
                    then assign
                         titluc.titsit = "BLO"
                         titluc.cxacod = 0
                         titluc.cobcod = 2
                         titluc.evecod = 5 .

                end.
    end.
        
    find current titluc no-lock no-error.
    
end procedure.

procedure valida-plano:
    p-ok = no.
    find first bctpromoc where
               bctpromoc.sequenci = ctpromoc.sequencia and
               bctpromoc.linha > 0 and
               bctpromoc.fincod <> ? and
               bctpromoc.situacao <> "I" and
               bctpromoc.situacao <> "E"
               no-lock no-error.
    if avail bctpromoc
    then do:    
        find first bctpromoc where
                 bctpromoc.sequencia = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.fincod = p-fincod no-lock no-error.
        if avail bctpromoc and         
                   bctpromoc.situacao <> "I" and
                   bctpromoc.situacao <> "E"
        then  p-ok = yes.
    end.   
    else do:
        find first bctpromoc where
                 bctpromoc.sequencia = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.fincod = p-fincod no-lock no-error.
        if not avail bctpromoc
        then p-ok = yes.         
    end.
end procedure.

procedure valida-filial:
    p-ok = no.
    find first ectpromoc where
               ectpromoc.sequencia = ctpromoc.sequencia and
               ectpromoc.linha > 0 and
               ectpromoc.etbcod > 0 and
               ectpromoc.situacao <> "E" and
               ectpromoc.situacao <> "I" no-lock no-error.
    if not avail ectpromoc
    then do:
        find first ectpromoc where
                   ectpromoc.sequencia = ctpromoc.sequencia and
                   ectpromoc.linha > 0 and
                   ectpromoc.etbcod = p-etbcod 
                   no-lock no-error.
        if not avail ectpromoc
        then p-ok = yes.
    end.
    else do:   
        find first ectpromoc where
                   ectpromoc.sequencia = ctpromoc.sequencia and
                   ectpromoc.linha > 0 and
                   ectpromoc.etbcod = p-etbcod no-lock no-error.
        if avail ectpromoc and
               ectpromoc.situacao <> "I" and
               ectpromoc.situacao <> "E"
        then p-ok = yes.
    end. 
end procedure.



