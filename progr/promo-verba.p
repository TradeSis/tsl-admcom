{admcab.i}

def input parameter p-tipo as char.
def input parameter p-procod like produ.procod.

def buffer bprodu for produ.
def buffer bclase for clase.
def var vdti as date.
def var vdtf as date.
def var vetbcod like estab.etbcod.
def var vnovo-preco as dec.
def var vestatual like estoq.estatual.
def var vpreco-ant like estoq.estvenda.
def var vpreco-atu like estoq.estvenda.
def var valor-verba as dec.
def var vok as log.
def var vacum-verba as dec.
def buffer bctpromoc for ctpromoc.
def buffer ectpromoc for ctpromoc.
def buffer pctpromoc for ctpromoc.
def var vestvenda like estoq.estvenda.
def var vclacod like clase.clacod.

def temp-table tt-classe 
    field clacod like clase.clacod .

def var vokp as int.

def buffer cclase for clase.
def buffer dclase for clase.

if p-tipo ="preco"
then do:
    find produ where produ.procod = p-procod no-lock.
    find first estoq where estoq.procod = produ.procod and
                           estoq.etbcod > 0
                           no-lock.
    vokp = 0.
    run classe-promo.
    if vokp = 0
    then do:
        message color red/with
            "Favor cadastrar uma promocao(20) no modulo de promocoes."
            view-as alert-box.
    end.
    else do:
    find last ctpromoc where ctpromoc.promocod = 20 and
                             ctpromoc.linha = 0 and
                             ctpromoc.situacao <> "C" and
                             ctpromoc.sequencia = vokp
                             no-lock no-error.
    if not avail ctpromoc or
        ctpromoc.situacao <> "M"
    then do:                            
        message color red/with
            "Favor cadastrar uma promocao(20) no modulo de promocoes."
            view-as alert-box.
    end.
    else if ctpromoc.situacao = "M"
    then do:
        
        find last  pctpromoc where
                   pctpromoc.promocod  = 20     and
                   pctpromoc.procod    = produ.procod and
                   pctpromoc.sequencia < ctpromoc.sequencia
                   no-lock no-error.
        /*if avail pctpromoc
        then vestvenda = pctpromoc.precosugerido.
        else*/ vestvenda = estoq.estvenda.

        find first bctpromoc where
                   bctpromoc.sequencia = ctpromoc.sequencia and
                   bctpromoc.procod    = produ.procod 
                   no-lock no-error.
        if avail bctpromoc
        then vnovo-preco = bctpromoc.precosugerido.
                    
        disp "       "  at 1
             produ.procod at 7
             produ.pronom no-label  format "x(40)"
             ctpromoc.dtini  at 3  label "Vigencia de"
             ctpromoc.dtfim  label "Ate"
             vestvenda at 3 label "Preco Atual"
             vnovo-preco    at 4 label "Novo preco"
             " " at 1
             with frame f-preco row 8 1 down side-label
             centered no-box color message overlay.
        pause 0.
        
        update vnovo-preco  with frame f-preco.

        if vnovo-preco > 0
        then do:
            find first bctpromoc where
                   bctpromoc.sequencia = ctpromoc.sequencia and
                   bctpromoc.procod    = produ.procod
                    no-error.
            if avail bctpromoc
            then bctpromoc.precosugerido = vnovo-preco.
            else do:
                find last ectpromoc where 
                          ectpromoc.sequencia = ctpromoc.sequencia 
                          no-lock no-error.
                create bctpromoc. 
                assign bctpromoc.promocod  = ctpromoc.promocod
                       bctpromoc.sequencia = ctpromoc.sequencia
                       bctpromoc.linha     = ectpromoc.linha + 1 
                       bctpromoc.fincod = ? 
                       bctpromoc.procod = produ.procod
                       bctpromoc.precosugerido = vnovo-preco.
            end.
        end.
    end.
    end.
end.
else if p-tipo = "Verba"
then do:
    disp "         "  at 1
         vetbcod at 8 label "Filial" 
         estab.etbnom no-label        format "x(20)"
         vclacod at 8 label "Classe"
         "" @ clase.clanom no-label format "x(20)"
         vdti    at 3 label "Periodo de"
         vdtf         label "Ate"
         
         " " at 1
         with frame f-verba row 8 1 down side-label
             centered no-box color message overlay width 40.
    pause 0.
    disp "" @ estab.etbnom with frame f-verba.
    update vetbcod with frame f-verba.
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom with frame f-verba.
    end.
    else disp "Geral" @ estab.etbnom with frame f-verba.    
    do on error undo:
        update vclacod with frame f-verba.
        if vclacod > 0
        then do:
            find clase where clase.clacod = vclacod no-lock.
            disp clase.clanom with frame f-verba.
        end.
        else disp "Geral" @ clase.clanom with frame f-verba.
        
        update vdti vdtf with frame f-verba.
        if vdti = ? or 
           vdtf = ? or
           vdtf < vdti
        then undo.   
    end.

    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "../relat/prom" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999")
                                       + "." + string(time).
    else varquivo = "..\relat\prom" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999")
                                       + "." + string(time).
                                  
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "100" 
                &Page-Line = "66" 
                &Nom-Rel   = ""ctpromoc"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """LISTAGEM DE VERBA DE PROMOCOES""" 
                &Width     = "100"
                &Form      = "frame f-cabcab"}

    disp with frame f-verba.     
    for each bctpromoc where bctpromoc.promocod = 20 and
                            bctpromoc.dtinicio = vdti and
                            bctpromoc.dtinicio = vdtf
                            no-lock,
        each ctpromoc where
                 ctpromoc.sequencia = bctpromoc.sequencia and
                 ctpromoc.procod > 0 and
                 ctpromoc.linha > 0
                 no-lock:           
        if ctpromoc.procod = 0 or
           ctpromoc.procod = ? or
           ctpromoc.precosugerido = 0
        then next.

        find produ where produ.procod = ctpromoc.procod no-lock.
        vok = yes.
        if vclacod > 0
        then do:
            find first bprodu where bprodu.clacod = vclacod no-lock no-error.
            if avail bprodu and
               vclacod <> produ.clacod
            then next.
            if not avail bprodu
            then do:
                vok = no.
                for each bclase where bclase.clasup = vclacod no-lock:
                    if bclase.clacod = produ.clacod
                    then do:
                        vok = yes.
                        leave.
                    end.
                end.
            end.
        end.     
        if vok = no then next.
        vestatual = 0.
        vpreco-ant = 0.
        /*find last hispre where 
                  hispre.procod = produ.procod and
                  hispre.estvenda-nov = ctpromoc.precosugerido 
                  no-lock no-error.
        if not avail hispre
        then find last hispre where 
                  hispre.procod = produ.procod and
                  hispre.estvenda-nov = ctpromoc.precosugerido 
                  no-lock no-error.
 
        if avail hispre
        then vpreco-ant = hispre.estvenda-ant.*/
        if vetbcod = 0
        then do:
            for each estoq where estoq.procod = produ.procod
                             and estoq.etbcod <> 22 no-lock:
                vestatual = vestatual + estoq.estatual.
                if vpreco-ant = 0 and
                   estoq.estvenda > 0
                then vpreco-ant = estoq.estvenda.   
            end.
        end.
        else do:
            find estoq where estoq.procod = produ.procod and
                             estoq.etbcod = vetbcod no-lock no-error.
            if avail estoq
            then do:
                    vestatual = estoq.estatual.
                    
                    if vpreco-ant = 0
                    then vpreco-ant = estoq.estvenda. 
            end.                                    
        end.
        vpreco-atu = ctpromoc.precosugerido. 
        valor-verba = (vpreco-ant - vpreco-atu) * vestatual.
        vacum-verba = vacum-verba + valor-verba.
        disp produ.procod
             produ.pronom no-label  format "x(30)"
             vpreco-ant  column-label "Preco!Antes"   format ">>,>>9.99"
             vpreco-atu  column-label "Preco!Atual" format ">>,>>9.99"
             vestatual   column-label "Estoque"      format ">>>,>>9"
             valor-verba column-label "Verba"  (total) format ">>,>>>,>>9.99"
             vacum-verba  column-label "Acumulado"     format ">>,>>>,>>9.99"
             with frame f-disp down width 110.
    end. 

    output close.
    
    IF opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"") .
    end.
    else do:
        {mrod.i}
    end.
        
end.

procedure classe-promo:
    
    vokp = 0.
    find bclase where bclase.clacod = produ.clacod no-lock .
    find cclase where cclase.clacod = bclase.clasup no-lock.
    find dclase where dclase.clacod = cclase.clasup no-lock.
    find clase where clase.clacod = dclase.clasup no-lock.
    
    for each ctpromoc where ctpromoc.promocod = 20 and
                            ctpromoc.linha = 0 and
                            ctpromoc.situacao = "M" no-lock:
        find last  pctpromoc where
                   pctpromoc.promocod  = 20     and
                   pctpromoc.clacod    = clase.clacod and
                   pctpromoc.sequencia = ctpromoc.sequencia
                   no-lock no-error.
        if avail pctpromoc
        then vokp = pctpromoc.sequencia.
        else do:
            find last  pctpromoc where
                   pctpromoc.promocod  = 20     and
                   pctpromoc.clacod    = dclase.clacod and
                   pctpromoc.sequencia = ctpromoc.sequencia
                   no-lock no-error.
            if avail pctpromoc
            then vokp = pctpromoc.sequencia.
        end.           
    end.
end procedure.