{admcab.i}

def var ii as int.
def var vtsint as logical format "Sim/Nao".
def var vvt1 as int init 0 format ">>>>9".
def var vvt2 as int init 0 format ">>>>9".
def var vvt3 like titulo.titvlcob init 0 format ">>,>>>,>>9.99".
def var vvt4 like titulo.titvlcob init 0 format ">>,>>>,>>9.99".
def var vvt5 like titulo.titvlcob init 0 format ">>>,>>9.99".

def buffer bstitulo for titulo.
def buffer bestab   for estab.

def var par-paga as int.
def var pag-atraso as log.
def buffer ctitulo for fin.titulo.

def temp-table tt-estab
    field etbcod like estab.etbcod
    .
    
def temp-table tt-prod no-undo
    field etbcod like plani.etbcod 
    field movdat like movim.movdat
    field procod like produ.procod
    field rec-plani as recid
    field rec-movim as recid
    field rec-contrato as recid
    field movpc like movim.movpc
    field codfis like produ.codfis
    field mva    as dec
    field ult-cmp like plani.numero
    field forcod  like forne.forcod
    field estcusto like estoq.estcusto 
    field vlvenda as dec
    field vlacrescimo as dec
    field tipo as log format "F/D"
    field pronom like produ.pronom
    index etbcod movdat procod
    .

def var vtipo as log.

def var vlmax like titulo.titvlcob.

def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vsubtot  like titulo.titvlcob.
def var vetbcod  like estab.etbcod.
def var vetbcod1 like estab.etbcod.

def var valfa    as log.
def var varquivo as char.

def var varqsai as char.

def var qtd-cli as int.
def var qtd-par as int.
def var val-cob as dec.

def var vdifer as dec.
def var tqtd-cli as int.
def var tqtd-par as int.
def var tval-cob as dec.
def var p-principal as dec.
def var p-acrescimo as dec.
def var p-seguro as dec.
def var p-juros as dec.
def var p-crepes as dec.
def var vdata as date.
def var vrec-contrato as recid. 
def var p-novacao as log.
def var p-financiado as dec.
def var p-clientes as dec.

form "Aguarde processamento..."
    with frame f-disp row 10 1 down centered no-box color message width 80
    .
repeat:
    
    update vetbcod colon 20 vetbcod1 label 'até' with frame f2.
    find estab where 
         estab.etbcod = vetbcod 
         no-lock no-error.
    if not avail estab
    then do:
        message "Primeiro estabelecimento invalido.".
        undo.
    end.
    find bestab where
         bestab.etbcod = vetbcod1
         no-lock no-error.
    if not avail bestab then do:
        message "Segundo estabelecimento inválido.". 
    end.      
    if vetbcod > vetbcod1 then do:
        message "Primeiro estabelecimento deve ser menor que o segundo.".
        undo.
    end. 
    display  skip estab.etbnom  no-label at 22 ' - ' 
        bestab.etbnom no-label with frame f2.
    
    for each tt-estab: delete tt-estab. end.
    for each estab where estab.etbcod >= vetbcod and
                         estab.etbcod <= vetbcod1
                         no-lock:
        create tt-estab.
        tt-estab.etbcod = estab.etbcod.
    end.                     
    
    update vdtvenini label "Data venda inicial" colon 20
           vdtvenfim label "Final"
                with row 4 side-labels width 80 
                 frame f2.

    vlmax = 0.
    
    assign
        qtd-cli = 0
        qtd-par = 0
        val-cob = 0
        tqtd-cli = 0
        tqtd-par = 0
        tval-cob = 0
        .
         
    for each tt-prod : delete tt-prod. end.
    
    do vdata = vdtvenini to vdtvenfim:
        disp vdata with frame f-disp no-label. 
        pause 0.
        for each tt-estab where tt-estab.etbcod > 0
                       no-lock:
            disp tt-estab.etbcod with frame f-disp.
            pause 0.           
            for each plani where
                 plani.movtdc = 5 and
                 plani.etbcod = tt-estab.etbcod and
                 plani.pladat = vdata
                 no-lock:
                 
            assign
                p-novacao = no
                p-financiado = 0
                p-clientes = 0
                p-principal = 0
                p-acrescimo = 0
                p-seguro = 0
                p-crepes = 0
                .

            vtipo = no.
            find first contnf where contnf.etbcod = plani.etbcod and
                            contnf.placod = plani.placod 
                            no-lock no-error.
            if avail contnf
            then do:
                find contrato where contrato.contnum = contnf.contnum and
                            contrato.dtinicial = plani.pladat
                            no-lock no-error.
                if avail contrato
                then do:
                    if contrato.banco = 10
                    then vtipo = yes.

                    vrec-contrato = recid(contrato).
                    run ret-principal-acrescimo-contrato-gerencial.p
                        (input recid(contrato),
                         output p-novacao,
                         output p-financiado,
                         output p-clientes,
                         output p-principal,
                         output p-acrescimo,
                         output p-seguro,
                         output p-crepes).
                end.
            end.
                 
            for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc
                             no-lock,
                first produ where produ.procod = movim.procod and
                              produ.proipiper = 99 and
                              produ.codfis <> 99999999
                              no-lock:
                              
                if produ.pronom matches "*RECARGA*"
                then next.
                if produ.pronom matches "*CHIP*"
                then next.
                if produ.pronom matches "*TESTE*"
                then next.
                
                create tt-prod.
                assign
                    tt-prod.etbcod = plani.etbcod 
                    tt-prod.movdat = movim.movdat
                    tt-prod.procod = produ.procod
                    tt-prod.pronom = produ.pronom
                    tt-prod.rec-plani = recid(plani)
                    tt-prod.rec-movim = recid(movim)
                    tt-prod.rec-contrato = vrec-contrato
                    tt-prod.vlvenda = movim.movpc * movim.movqtm
                    tt-prod.movpc = movim.movpc
                    tt-prod.tipo = vtipo
                    . 
                        
                if p-acrescimo <> ? and
                   p-acrescimo > 0
                then tt-prod.vlacrescimo = p-acrescimo *
                        ((movim.movpc * movim.movqtm) / plani.protot).
            
            end.
            end.
        end.
    end.
    for each tt-prod:
        find produ where produ.procod = tt-prod.procod no-lock no-error.
        if not avail produ then next.
        tt-prod.codfis = produ.codfis.
        find clafis where clafis.codfis = produ.codfis no-lock no-error.
        if avail clafis
        then tt-prod.mva = clafis.mva_estado1.
        find last movim where movim.procod = produ.procod and
                              movim.movtdc = 4 no-lock no-error.
        if avail movim 
        then do:
            find plani where plani.etbcod = movim.etbcod and
                             plani.placod = movim.placod and
                             plani.movtdc = movim.movtdc
                             no-lock no-error.
            if avail plani
            then assign
                    tt-prod.ult-cmp = plani.numero 
                    tt-prod.forcod  = plani.emite
                    .
                    
        end. 
        find first estoq where estoq.procod = produ.procod no-lock no-error.
        if avail estoq
        then tt-prod.estcusto = estoq.estcusto.
        
    end.    
    
    hide frame f-disp no-pause.
    
    varquivo = "/admcom/relat/rel-acrescimo-ctb." + string(time).
    
        /* Sintetico */
        assign vvt1 = 0
               vvt2 = 0
               vvt3 = 0
               vvt4 = 0
               vvt5 = 0.

    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = ""rel-acrescimo-ctb""
        &Nom-Sis   = """SISTEMA CONTABILIDADE"""  
        &Tit-Rel   = """RELATORIO VENDA PRODUTOS ST""" 
        &Width     = "120"
        &Form      = "frame f-cabcab"}

    disp with frame f2.
        
    for each tt-prod:
        disp tt-prod.vlvenda(total)  format ">>>,>>9.99"    
                                  column-label "VlorVenda!Principal"
             tt-prod.vlacrescimo(total)  format ">>>,>>9.99"
                                  column-label "Acrescimo"
             tt-prod.tipo         column-label "Tipo"
             tt-prod.mva          column-label "MVA"
             tt-prod.estcusto format ">>>,>>9.99"    
                                  column-label "Custo!Nota"
             tt-prod.ult-cmp  format ">>>>>>>>9"  
                                  column-label "Nf.Ultima!Compra"
             tt-prod.procod       column-label "Codigo!Produto"
             tt-prod.forcod       column-label "Codigo!Fornecedor"
             tt-prod.codfis format ">>>>>>>>>9"
                                  column-label "NCM"  
             with frame fd down width 130.
        down with frame fd.      
    end.
    
    output close.                                   
    
    run visurel.p(varquivo,"").
    leave.    
end.
return.

