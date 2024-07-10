{admcab.i }


def input parameter vetbcod like estab.etbcod.
def input parameter vdata   like plani.pladat.
def input parameter vcatcod like coletor.catcod.
def var vpend   as int format "->>>9".
def var vqtd like estoq.estinvctm format "->,>>9.99".


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

def var vpro like produ.procod. 
def var vq like estoq.estatual. 
def var vc as char format "x(20)".

 
    
    find estab where estab.etbcod = vetbcod no-lock no-error.
    
    update vesc label "Ordem" 
            with frame f1 side-label centered.

         
    message "Imprimir tudo" update sresp.
    if sresp 
    then vimp = yes.
    else vimp = no.
    
    varquivo = "..\relat\col" + string (vetbcod,">>9") 
                              + string(day(today)).
                             
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "150"
        &Page-Line = "66"
        &Nom-Rel   = """COLETA3"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONFRONTO DE ESTOQUE - "" + estab.etbnom + ""  "" +
                        string(vdata,""99/99/9999"")"
        &Width     = "150"
        &Form      = "frame f-cab"}

    output stream stela to terminal.
    
    if vesc
    then do:
        
        for each coletor where coletor.etbcod = vetbcod and
                               coletor.coldat = vdata   and
                               coletor.catcod = vcatcod 
                                        no-lock by coletor.pronom.
    

    
        
            if vimp = no
            then do:
                if coletor.estatual = coletor.colqtd
                then next.
            end.
            else do:
                /*
                if coletor.estatual = 0 and coletor.colqtd = 0
                then next.
                */
                if coletor.colqtd = 0 then next.
            end.
        
            tot = 0.

            if coletor.colacr > 0
            then assign tot1 = tot1 + (coletor.estcusto * coletor.colacr)
                        vac  = vac  + coletor.colacr
                        tot  = coletor.colacr.

            if coletor.coldec > 0
            then assign tot2 = tot2 + (coletor.estcusto * coletor.coldec)
                        vde  = vde  + coletor.coldec
                        tot  = coletor.coldec.

            assign v-falta = 0
                   v-sobra = 0.
                   
            if coletor.estatual > coletor.colqtd 
            then v-falta = coletor.coldec. 
            else if coletor.estatual < coletor.colqtd
                 then v-sobra = coletor.colacr.
            
            
            
            
            display coletor.procod column-label "Codigo"
                    coletor.pronom FORMAT "x(35)"
                    coletor.estatual(TOTAL) column-label "Qtd." format "->>>>9"
                    coletor.colqtd(total) column-label "Dig." format "->>>>9"
                    coletor.colacr(total)  format "->>>>>9"
                        when colacr > 0 column-label "Acresc."
                    coletor.coldec(total)         format "->>>>>9"
                            when coldec > 0 column-label "Decres."
                    coletor.estcusto column-label "Pc.Custo" format ">,>>9.99"
                    v-sobra(total) column-label "Sobra" format ">>>>>"
                        when v-sobra > 0
                    v-falta(total) column-label "Falta" format ">>>>>"
                        when v-falta > 0
                    (coletor.estcusto * tot)(total)
                       column-label "Total Custo" format ">,>>>,>>9.99"
                                with frame f2 down width 130.
    
    
            display stream stela
                 tot1 label "TOTAL VL. ACRESCIMO : " 
                 vac   label "TOTAL ACRESCIMO     : "  
                 tot2  label "TOTAL VL. DECRESCIMO: " 
                 vde   label "TOTAL DECRESCIMO    : " 
                        with frame f-tt centered 1 column no-label.
            pause 0.
                
        end.
    end.
    else do:
        
        for each coletor where coletor.etbcod = vetbcod and
                               coletor.coldat = vdata   and
                               coletor.catcod = vcatcod 
                                    no-lock by coletor.procod.
    

    
        
            if vimp = no
            then do:
                if coletor.estatual = coletor.colqtd
                then next.
            end.
            else do:
                /*
                if coletor.estatual = 0 and coletor.colqtd = 0
                then next.
                */
                if coletor.colqtd = 0 then next.
            end.
        
            tot = 0.

            if coletor.colacr > 0
            then assign tot1 = tot1 + (coletor.estcusto * coletor.colacr)
                        vac  = vac  + coletor.colacr
                        tot  = coletor.colacr.

            if coletor.coldec > 0
            then assign tot2 = tot2 + (coletor.estcusto * coletor.coldec)
                        vde  = vde  + coletor.coldec
                        tot  = coletor.coldec.

            assign v-falta = 0
                   v-sobra = 0.
                   
            if coletor.estatual > coletor.colqtd 
            then v-falta = coletor.coldec. 
            else if coletor.estatual < coletor.colqtd
                 then v-sobra = coletor.colacr.
            
             
            display coletor.procod column-label "Codigo"
                    coletor.pronom FORMAT "x(35)"
                    coletor.estatual(TOTAL) column-label "Qtd." format "->>>>9"
                    coletor.colqtd(total) column-label "Dig." format "->>>>9"
                    coletor.colacr(total) format "->>>>>9"
                        when colacr > 0 column-label "Acresc."
                    coletor.coldec(total)  format "->>>>>>9"
                        when coldec > 0 column-label "Decres."
                    coletor.estcusto column-label "Pc.Custo" format ">,>>9.99"
                    v-sobra(total) column-label "Sobra" format ">>>>>"
                        when v-sobra > 0
                    v-falta(total) column-label "Falta" format ">>>>>"
                        when v-falta > 0
                    (coletor.estcusto * tot)(total)
                       column-label "Total Custo" format ">,>>>,>>9.99"
                                with frame f5 down width 130.
    
    
            display stream stela
                 tot1 label "TOTAL VL. ACRESCIMO : " 
                 vac   label "TOTAL ACRESCIMO     : "  
                 tot2  label "TOTAL VL. DECRESCIMO: " 
                 vde   label "TOTAL DECRESCIMO    : " 
                        with frame f-ttt centered 1 column no-label.
            pause 0.
                
        end.
       
    end.
    
    
    
    output stream stela close.
    put skip "TOTAL VL. ACRESCIMO : " at 40 tot1
             "TOTAL ACRESCIMO     : "       vac skip
             "TOTAL VL. DECRESCIMO: " at 40 tot2
             "TOTAL DECRESCIMO    : "       vde.
    output close.
    
    {mrod.i}
