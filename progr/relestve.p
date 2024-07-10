/* Relatorio Estoque x Venda */
{admcab.i}
def var v-tipo      as int.
def var vetbi       like estab.etbcod.
def var vetbf       like estab.etbcod.
def var vdtini      as date format "99/99/9999".
def var vdtfim      as date format "99/99/9999".
def var vetbcod     like estab.etbcod.
def var vcatcod     like categoria.catcod.
def var vfabcod     like fabri.fabcod.
def var vclacod     like clase.clacod.
def var varquivo    as char.
def var vtip as char format "x(12)" extent  
        initial ["Classe","Fornecedor"].


def temp-table tt-estab
       field etbcod as int.



def temp-table tt-estoq
    field procod        like produ.procod
    field etbcod        like estab.etbcod
    field fabcod        like produ.fabcod
    field valorprodu    like estoq.estcusto
    field clacod        like produ.clacod
    field estatual      like estoq.estatual
    field venda         like plani.platot
    field valorestoq    like estoq.estven
    field movqtm        like movim.movqtm    .
    



def buffer bestab for estab.
/*
form vetbcod label "Filial" colon 25 with frame f1 side-label width 80.
*/

for each tt-estab.
    delete tt-estab.
end.


    update vetbi label "Filial" to 30 
           "ate"
           vetbf no-label with frame f1.
    /*     
    {selestab.i vetbcod f1}.
    */ 
         
    do on error undo, retry:
          update vdtini to 36  label "Data Inicial"
                 vdtfim label "Data Final" skip with frame f1.
          if  vdtini > vdtfim
          then do:
                message color red/with 
                "Data inválida" view-as alert-box.
                undo.
          end.
          if  vdtini = ? or vdtfim = ?
          then do:
                message color red/with 
                "Data deve ser informada" view-as alert-box.
                undo.
          end.

          
    end.
    
    
    update vcatcod to 29 label "Departamento" 
                with frame f1.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f1.

 
        
    update vfabcod to 32 label "Fabricante"  
                    with frame f1 side-label width 80.
    if vfabcod <> 0
    then do:
        find fabri where fabri.fabcod = vfabcod no-lock.
        display fabri.fabnom format "x(30)" no-label with frame f1.
    end.
    else disp "Todos" @ fabri.fabnom with frame f1.
    
    update vclacod to 30 label "Classe" with frame f1.
    if vclacod <> 0
    then do:
        find first clase where clase.clacod = vclacod no-lock no-error.
        display clase.clanom format "x(30)" no-label with frame f1.
    end.
    else disp "Todas" @ clase.clanom with frame f1.
    
    /*
    if vetbcod > 0
    then do:
        for each bestab where bestab.etbcod = vetbcod no-lock:
            create tt-estab.
            buffer-copy bestab to tt-estab.
        end.    
    end.
    else do:
        find first tt-lj where tt-lj.etbcod > 0 no-error.
        if not avail tt-lj
        then  for each bestab no-lock:
                create tt-estab.
                buffer-copy bestab to tt-estab.
        end. 
        else for each tt-lj where tt-lj.etbcod > 0 no-lock:
                create tt-estab.
                buffer-copy tt-lj to tt-estab.
        end.
    end.
    */
 
    for each tt-estab: delete tt-estab. end.
   
    for each estab no-lock.

        if estab.etbcod < vetbi or
           estab.etbcod > vetbf
        then next.
        
        create tt-estab.
        assign tt-estab.etbcod = estab.etbcod.             
    end.
    

    
    display vtip with frame f-tip no-label.
    choose field vtip with frame f-tip centered title "Listar por".
    v-tipo = frame-index.


varquivo = "/admcom/relat/relprodmov" + string(time).
{mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "140"
            &Page-Line = "66"
            &Nom-Rel   = ""relestven""
            &Nom-Sis   = """MODULO AUDITORIA"""
            &Tit-Rel   = """RELATORIO ESTOQUE X VENDA "" + ""Filial "" +  
                                  string(vetbi,"">>9"") + "" ate "" +
                                  string(vetbf,"">>9"") + 
                          "" PERIODO DE "" +
                                  string(vdtini,""99/99/9999"")" + "" ate "" +
                                  string(vdtfim,""99/99/9999"")"
            &Width     = "140"
            &Form      = "frame f-cabcab"}

for each tt-estab no-lock.
    
    disp "Estabelecimento :" tt-estab.etbcod no-label
    with frame f4 row 11 centered.
    pause 0.

 

    for each produ where produ.catcod = vcatcod 
    no-lock.
        
        if vfabcod <> 0
        then do:
            if produ.fabcod <> vfabcod then next.
        end.
                
        if vclacod <> 0
        then do:
            if produ.clacod <> vclacod then next.
        end.    
 
        
        find last hiest where hiest.etbcod = tt-estab.etbcod       and
                              hiest.procod = produ.procod       and
                              hiest.hiemes = int(month(vdtfim)) and
                              hiest.hieano = int(year(vdtfim))
                              no-lock no-error. 
        

        if not avail hiest then next.
        
        find first estoq where estoq.procod = produ.procod and
                               estoq.etbcod = tt-estab.etbcod no-lock no-error.
                               
        if not avail estoq then next.                       
        
        
        find first tt-estoq where tt-estoq.procod = produ.procod and
        tt-estoq.etbcod = tt-estab.etbcod no-error.
            if not avail tt-estoq 
            then do:
              
                create tt-estoq.
                assign 
                    tt-estoq.procod     = produ.procod      
                    tt-estoq.etbcod     = tt-estab.etbcod    
                    tt-estoq.fabcod     = produ.fabcod      
                    tt-estoq.clacod     = produ.clacod      
                    tt-estoq.estatual   = hiest.hiestf
                    tt-estoq.valorestoq = estoq.estcusto * hiest.hiestf. 
            end.
        
        for each movim where movim.procod = produ.procod            and
                                 movim.movtdc = 5                   and
                                 movim.movdat >= vdtini             and
                                 movim.movdat <= vdtfim             and
                                 movim.etbcod = tt-estab.etbcod                                                 no-lock.
        

            find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat
                                       no-lock no-error.


    
             assign
                    tt-estoq.venda = tt-estoq.venda + 
                                     (estoq.estcusto * movim.movqtm)   
                    tt-estoq.movqtm = tt-estoq.movqtm + movim.movqtm. 
    
        end.
    
    end.
    
    
end.    

def var vestatual as dec.
def var vmovqtm as dec.
def var vvenda as  dec.
def var vvalorestoq as dec.

def var vtotest as dec format "->>>,>>>,>>9.99".
def var vtotvest as dec format "->>>,>>>,>>9.99".
def var vtotmovqtm as dec format "->>>,>>>,>>9.99".
def var vtotvenda as dec format "->>>,>>>,>>9.99".
form with frame f-dados1. 
form with frame f-dados2.
if v-tipo = 1
then do:
/*Classe*/

for each tt-estab no-lock.
for each tt-estoq where tt-estoq.etbcod = tt-estab.etbcod 
break by tt-estoq.clacod .

    find first clase where clase.clacod = tt-estoq.clacod no-lock no-error.
    if not avail clase then next.
    
    find produ where produ.procod = tt-estoq.procod no-lock.
    
    vestatual = vestatual + tt-estoq.estatual.
    vvalorestoq = vvalorestoq + tt-estoq.valorestoq.
    vmovqtm = vmovqtm + tt-estoq.movqtm.
    vvenda = vvenda + tt-estoq.venda.

    if last-of(tt-estoq.clacod)
    then do:
         
         disp   clase.clacod 
                clase.clanom
                tt-estoq.etbcod         label "Estab"
                vestatual               label "Qtd. Estoque"
                vvalorestoq             label "Valor Estoque"
                vmovqtm                 label "Qtd. Vendida"
                vvenda                  label "Venda"
                with frame f-dados1 width 200 down.
                down with frame f-dados1.
         
         vtotest = vtotest + vestatual.
         vtotvest = vtotvest + vvalorestoq.
         vtotmovqtm = vtotmovqtm + vmovqtm.
         vtotvenda = vtotvenda + vvenda.
         
         vetbcod        = 0.
         vestatual      = 0.       
         vvalorestoq    = 0.
         vmovqtm        = 0.
         vvenda         = 0.
    end.            

    /*
    vvalorestoq = tt-estoq.valorestoq.
    if tt-estoq.estatual < 0 then vvalorestoq = 0.
    disp    produ.pronom  format "x(10)"
            tt-estoq.etbcod
            tt-estoq.estatual       format "->>,>>9.99"
            tt-estoq.valorprodu
            vvalorestoq
            tt-estoq.movqtm         label "QTD.Vendida"
            tt-estoq.venda          label "Venda R$"
            with frame f2 width 200 down.
            down with frame f2.
     */

end. /*estoq*/
end. /*estab*/
    down  2 with frame f-dados1.
    disp    vtotest     @ vestatual
        vtotvest    @ vvalorestoq format "->>>,>>>,>>9.99"
        vtotmovqtm  @ vmovqtm
        vtotvenda   @ vvenda format "->>,>>>,>>9.99"
        with frame f-dados1 width 200 down. 
    
end. /*if*/

else do:
/*Fornecedor*/
for each tt-estab no-lock.

for each tt-estoq where tt-estoq.etbcod = tt-estab.etbcod
break by tt-estoq.fabcod .

    find fabri where fabri.fabcod = tt-estoq.fabcod no-lock no-error.
    find clase where clase.clacod = tt-estoq.clacod no-lock no-error.
    find produ where produ.procod = tt-estoq.procod no-lock.
    
    if not avail clase then next.
    
    vestatual = vestatual + tt-estoq.estatual.
    vvalorestoq = vvalorestoq + tt-estoq.valorestoq.
    vmovqtm = vmovqtm + tt-estoq.movqtm.
    vvenda = vvenda + tt-estoq.venda.

    if last-of(tt-estoq.fabcod)
    then do:
         
         disp   fabri.fabcod 
                fabri.fabnom
                tt-estoq.etbcod        label "Estab"
                vestatual      label "Qtd. Estoque"
                vvalorestoq    label "Valor Estoque"
                vmovqtm        label "Qtd. Vendida"
                vvenda         label "Venda"
                with frame f-dados2 width 200 down.
                down with frame f-dados2.
         
         
         vtotest = vtotest + vestatual.
         vtotvest = vtotvest + vvalorestoq.
         vtotmovqtm = vtotmovqtm + vmovqtm.
         vtotvenda = vtotvenda + vvenda.
         

         
         vetbcod = 0.
         vestatual = 0.       
         vvalorestoq = 0.
         vmovqtm = 0.
         vvenda  = 0.
    end.            

    /*
    vvalorestoq = tt-estoq.valorestoq.
    if tt-estoq.estatual < 0 then vvalorestoq = 0.
    disp    produ.pronom  format "x(10)"
            tt-estoq.etbcod
            tt-estoq.estatual       format "->>,>>9.99"
            tt-estoq.valorprodu
            vvalorestoq
            tt-estoq.movqtm         label "QTD.Vendida"
            tt-estoq.venda          label "Venda R$"
            with frame f2 width 200 down.
            down with frame f2.
     */

end.
end.

    down  2 with frame f-dados2.
    disp    vtotest     @ vestatual
        vtotvest    @ vvalorestoq
        vtotmovqtm  @ vmovqtm
        vtotvenda   @ vvenda format "->>,>>>,>>9.99"
        with frame f-dados2 width 200 down. 

end.
if opsys = "UNIX"
then do:
    output close.
    run visurel.p (varquivo,"").
end.
else do:
    {mrod.i}
end.    



