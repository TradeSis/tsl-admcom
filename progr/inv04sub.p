/* Relatorio listar por classe Manutencao de confronto */
{admcab.i}


def input parameter vetbcod like estab.etbcod.
def input parameter vdata   like plani.pladat.
def input parameter vcatcod like coletor.catcod.
def var vpend   as int format "->>>9".
def var vqtd like estoq.estinvctm format "->,>>9.99".

def shared temp-table tt-coletor like coletor.

def temp-table tt-clase 
    field clacod like clase.clacod
    field procod like produ.procod.

def var v-falta as int.
def var v-sobra as int.
def var vimp as l.
def stream stela.
def var varquivo as char.
def var vest like estoq.estatual.
def var vant like estoq.estatual.
def var vmes as int.
def var vano as int.
def var vprocod like produ.procod.
def var vquan   like estoq.estatual.
def var vpath as char format "x(30)".
def temp-table wcol
    field wcol as char format "x(2)".
def var vcol as char format "x(2)".

def buffer bprodu for produ.

def var vtotsobra as int.
def var vtotfalta as int.
def var vtotvsobra as dec format "->,>>>,>>9.99".
def var vtotvfalta as dec format "->,>>>,>>9.99".
def var vtotestcusto as dec format "->,>>>,>>9.99".
def var vtotcusto as dec format "->,>>>,>>9.99".


def var vlei            as char format "x(26)".
def var vetb            as i    format ">>9".
def var vcod            as i    format "9999999".
def var vcod2           as i    format "999999".
def var ac  as i.
def var tot as i.
def var de  as i.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var est like estoq.estatual.
def var tot1 like titulo.titvlcob format "->,>>>,>>9.99".
def var tot2 like titulo.titvlcob format "->,>>>,>>9.99".
def var vde like titulo.titvlcob format "->>>>>>>>>9".
def var vac like titulo.titvlcob format "->>>>>>>>>9".
def var vesc as log format "Alfabetica/Codigo".
def var vsubclasse as log format "Sim/Nao".
def buffer cprodu for produ.

def var vpro like produ.procod. 
def var vq like estoq.estatual. 
def var vc as char format "x(20)".

    find estab where estab.etbcod = vetbcod no-lock no-error.
    
    message "Imprimir tudo" update sresp.
    if sresp 
    then vimp = yes.
    else vimp = no.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/col" + string (vetbcod,"999") + "." 
                            + string(day(today)) + "." + string(time).
    else varquivo = "..~\relat~\col" + string (vetbcod,"999") + "." 
                              + string(day(today)).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "150"
        &Page-Line = "66"
        &Nom-Rel   = """COLETA3"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONFRONTO DE ESTOQUE POR SUBCLASSE- "" 
        + estab.etbnom + ""  "" +
                        string(vdata,""99/99/9999"")"
        &Width     = "150"
        &Form      = "frame f-cab"}
    
    for each tt-coletor no-lock.
        if vimp = no
        then do:
            if tt-coletor.estatual = tt-coletor.colqtd
            then next.
            end.
            else do:
            if tt-coletor.estatual = 0 and tt-coletor.colqtd = 0
            then next.
        end.
        find first produ where  produ.procod = tt-coletor.procod and
                                produ.catcod = vcatcod no-lock no-error.           
        find first tt-clase where tt-clase.clacod = produ.clacod no-lock               no-error.
        
        if not avail tt-clase
        then do:
                create tt-clase.
                assign  tt-clase.clacod = produ.clacod.
        end.        
    end.

    output stream stela to terminal.
    
    for each tt-clase
    no-lock break by tt-clase.clacod.
        
        find clase where clase.clacod = tt-clase.clacod no-lock no-error.
        if avail clase
        then disp clase.clacod label "Sub Classe" 
                  clase.clanom no-label with frame f1 side-labels.

        vtotfalta  = 0.
        vtotsobra  = 0.
        vtotestcusto = 0.
        vtotcusto = 0.
        for each produ where produ.clacod = tt-clase.clacod no-lock
        by produ.pronom.
        

            for each tt-coletor where tt-coletor.etbcod = vetbcod   and
                               tt-coletor.coldat = vdata            and
                               tt-coletor.catcod = vcatcod          and
                               tt-coletor.procod = produ.procod
                               no-lock
                               break by tt-clase.clacod by tt-coletor.pronom.

                if vimp = no
                then do:
                    if tt-coletor.estatual = tt-coletor.colqtd
                    then next.
                end.
                else do:
                    if tt-coletor.estatual = 0 and tt-coletor.colqtd = 0
                    then next.
                end.
                tot = 0.

                if tt-coletor.colacr > 0
                then assign tot1 = tot1 + 
                (tt-coletor.estcusto * tt-coletor.colacr)
                        vac  = vac  + tt-coletor.colacr
                        tot  = tt-coletor.colacr.

                if tt-coletor.coldec > 0
                then assign tot2 = tot2 + 
                (tt-coletor.estcusto * tt-coletor.coldec)
                        vde  = vde  + tt-coletor.coldec
                        tot  = tt-coletor.coldec.

                assign  v-falta = 0
                        v-sobra = 0.
                   
                if tt-coletor.estatual > tt-coletor.colqtd 
                then v-falta = tt-coletor.coldec. 
                else if tt-coletor.estatual < tt-coletor.colqtd
                then v-sobra = tt-coletor.colacr.
            
                find cprodu where cprodu.procod = tt-coletor.procod no-lock
                no-error.
            
                display tt-clase.clacod
                    tt-coletor.procod column-label "Codigo"
                    cprodu.pronom format "x(35)"
                    /*tt-coletor.pronom FORMAT "x(35)"*/
                    tt-coletor.estatual /*(TOTAL)*/ column-label "Qtd." 
                    format "->>>>9"
                    tt-coletor.colqtd /*(total)*/ column-label "Dig." format                                                                     "->>>>9"
                    tt-coletor.colacr /*(total)*/  format "->>>>>9"
                        when colacr > 0 column-label "Acresc."
                    tt-coletor.coldec /*(total)*/         format "->>>>>9"
                            when coldec > 0 column-label "Decres."
                    tt-coletor.estcusto column-label "Pc.Custo" 
                    format ">,>>9.99"
                    v-sobra /*(total)*/ column-label "Sobra" format ">>>>>"
                        when v-sobra > 0
                    v-falta /*(total)*/ column-label "Falta" format ">>>>>"
                        when v-falta > 0
                    (tt-coletor.estcusto * tot) /*(total)*/
                       column-label "Total Custo" format ">,>>>,>>9.99"
                                with frame f2 down width 130.

                vtotsobra = vtotsobra + v-sobra.
                vtotfalta = vtotfalta + v-falta.
                vtotestcusto = vtotestcusto + tt-coletor.estcusto.        
                vtotcusto = vtotcusto + (tt-coletor.estcusto * tot). 
                
                display stream stela
                 tot1 label "TOTAL VL. ACRESCIMO : " 
                 vac   label "TOTAL ACRESCIMO     : "  
                 tot2  label "TOTAL VL. DECRESCIMO: " 
                 vde   label "TOTAL DECRESCIMO    : " 
                        with frame f-tt centered 1 column no-label.
                pause 0.
            
                   
                if tt-coletor.estatual > tt-coletor.colqtd 
                then vtotvfalta = vtotvfalta + tt-coletor.estcusto * tot . 
                else if tt-coletor.estatual < tt-coletor.colqtd
                then vtotvsobra = vtotvsobra + tt-coletor.estcusto * tot .
            
             
            end. /*tt-coletor*/
        
       end. /*produto*/
       disp vtotsobra       label "Total Sobras:" 
            vtotvsobra      label "Tot.Custo Sobras:"
            vtotfalta       label "Total Faltas:"
            vtotvfalta      label "Tot.Custo Faltas:"
            vtotestcusto    label "Total Pc.custo:" 
            vtotcusto       label "Total Custo:"      
            with frame f3 side-labels 1 col.
        
            vtotvsobra = 0.
            vtotvfalta = 0.

    end.  /*tt-clase*/

    output stream stela close.
    put skip "TOTAL VL. ACRESCIMO : " at 40 tot1
             "TOTAL ACRESCIMO     : "       vac skip
             "TOTAL VL. DECRESCIMO: " at 40 tot2
             "TOTAL DECRESCIMO    : "       vde.
    output close.
    
    if opsys = "UNIX"
    then do:
        message "Arquivo gerado em: " varquivo.
        pause.
        run visurel.p(varquivo,"").
    end.
    else do:    
    {mrod.i}
    end.
