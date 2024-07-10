/* Solicitacao 37936 Listar Acrescimos de decrescimos */
{admcab.i}


def temp-table tt-produ
    field etbcod   like estab.etbcod 
    field procod   like produ.procod
    field pronom   like produ.pronom
    field catcod   like produ.catcod
    field clacod   like produ.clacod    
    field fabcod   like produ.fabcod
    field movtdc   like tipmov.movtdc 
    field vacr     as dec
    field vdecr    as dec
    field qtd-acr  as int
    field qtd-decr as int.

def buffer bestab for estab.

def var vdata       like plani.pladat.
def var vetbcod     like estab.etbcod.
def var vdtini      as date.
def var vdtfin      as date.
def var vcatcod     like produ.catcod.
def var varquivo    as char.
def var vtotprodu   as int.
def var vtotitens   as int.
def var vgtotprodu  as int.
def var vgtotitens  as int.
def var vtroca      as log format "Sim/Nao".
def var vfabcod      as int.
def var vclacod      as int.

def temp-table tt-estab
       field etbcod as int.

for each tt-estab:
    delete tt-estab.
end.

form vetbcod label "Filial" colon 18 with frame f1 side-label width 80.
{selestab.i vetbcod f1}.
display estab.etbnom no-label with frame f1.

update vcatcod colon 18 with frame f1 color white/cyan width 80.
    find categoria where categoria.catcod = vcatcod no-lock.
    display categoria.catnom no-label with frame f1.



update vdtini label "Periodo" colon 18
           vdtfin no-label with frame f1.

update vclacod label "Classe" colon 18 with frame f1.
if vclacod > 0 then do:
    find clase where clase.clacod = vclacod no-lock no-error.
    if avail clase
    then do:
        disp clase.clanom no-label with frame f1.
    end.
end.
else disp "Todas " @ clase.clanom with frame f1.

    
    
update vfabcod label "Fabricante" colon 18 with frame f1.
if vfabcod > 0
then do:
    find fabri where fabri.fabcod = vfabcod no-lock no-error.
    if avail fabri
    then do:
        disp fabri.fabnom no-label with frame f1.
    end.
end. 
else do:
    if vfabcod = 0
    then display "Todos" @ fabri.fabnom no-label with frame f1.
end.  

update vtroca label "Separar Trocas" colon 18 with frame f1.           


varquivo = "/admcom/relat/relprodmov" + string(time).
{mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "140"
            &Page-Line = "66"
            &Nom-Rel   = ""listaacrdecr""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """RELATORIO DE ACRRESCIMOS E DECRESCIMOS "" +
                                  string(vetbcod,"">>9"") +
                          "" PERIODO DE "" +
                                  string(vdtini,""99/99/9999"")" 
            &Width     = "140"
            &Form      = "frame f-cabcab"}



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


for each tipmov where tipmov.movtdc = 7  or /* ajuste acrescimo */
                      tipmov.movtdc = 8  or /* ajuste decrescimo */
                      tipmov.movtdc = 17 or /* troca entrada */
                      tipmov.movtdc = 18 or /* troca saida   */
                      tipmov.movtdc = 19 or /* entrada ajuste */
                      tipmov.movtdc = 20    /* saida ajuste  */
                      no-lock.
                                                    
    for each tt-estab no-lock.

        for each plani where plani.movtdc = tipmov.movtdc and 
                             plani.etbcod = tt-estab.etbcod and
                             plani.pladat >= vdtini and
                             plani.pladat <= vdtfin  
                             no-lock.
    

            for each movim where movim.movtdc = plani.movtdc and 
                                 movim.placod = plani.placod and 
                                 movim.etbcod = plani.etbcod no-lock.
                                 
                find first produ where produ.procod = movim.procod and
                                        (if vfabcod = 0 then True else
                                        produ.fabcod = vfabcod) and
                                        (if vclacod = 0 then true else
                                        produ.clacod = vclacod) and
                                        produ.catcod = vcatcod     
                                        no-lock no-error.
                
                if not avail produ then next. 
                
                create tt-produ.                     
                assign
                    tt-produ.etbcod   = tt-estab.etbcod
                    tt-produ.procod   = produ.procod
                    tt-produ.pronom   = produ.pronom
                    tt-produ.catcod   = produ.catcod
                    tt-produ.clacod   = produ.clacod
                    tt-produ.fabcod   = produ.fabcod
                    tt-produ.movtdc   = movim.movtdc.    
                
                if movim.movtdc = 7 or movim.movtdc = 17 or movim.movtdc = 19
                then assign       
                        tt-produ.qtd-acr  = movim.movqtm
                        tt-produ.vacr     = movim.movqtm * movim.movpc.
            
                if movim.movtdc = 8 or movim.movtdc = 18 or movim.movtdc = 20
                then assign       
                        tt-produ.qtd-decr = movim.movqtm
                        tt-produ.vdecr    = movim.movqtm * movim.movpc.

            end. /* movim */
        end. /* plani */
    end. /* estab */
end. /* tipmov */

def var vtotacre  as int.
def var vtotdecr  as int.
def var vtotvacr  as dec.
def var vtotvdecr as dec.
def var vgtotacre as int.
def var vgtotvacr as dec.
def var vgtotdecr as int.
def var vgtotvdecr as dec.

if vtroca = no
then do:
    for each tt-produ no-lock 
    break by tt-produ.etbcod by tt-produ.clacod by tt-produ.fabcod.

        if first-of(tt-produ.etbcod)
        then do:
            find estab where estab.etbcod = tt-produ.etbcod no-lock.
            disp estab.etbnom  with frame f-estab side-labels width 100.
        end.
        find clase where tt-produ.clacod = clase.clacod no-lock.
        find fabri where tt-produ.fabcod = fabri.fabcod no-lock.

        if first-of(tt-produ.clacod)
        then disp clase.clanom with frame f-cab side-labels.

        disp fabri.fabnom at 10 label "Fabricante"
             tt-produ.pronom 
             tt-produ.qtd-acr   label "Acresc"      
             tt-produ.vacr      label "Valor Acre." 
             tt-produ.qtd-decr  label "Decresc"
             tt-produ.vdecr     label "Valor Decre."
             with frame f-rel width 200 down.
         
        vtotacre   = vtotacre  + tt-produ.qtd-acr.
        vtotdecr   = vtotdecr  + tt-produ.qtd-decr.     
        vtotvacr   = vtotvacr + tt-produ.vacr.
        vtotvdecr  = vtotvdecr + tt-produ.vdecr.
         
         
        if last-of(tt-produ.clacod)
        then do: 
            disp vtotacre  no-label at 97  
                 vtotvacr  no-label at 109
                 vtotdecr  no-label at 120
                 vtotvdecr no-label at 133
                 with frame f-rel1 width 250 down.
            
            
            vgtotacre = vgtotacre + vtotacre.
            vgtotvacr = vgtotvacr + vtotvacr.
            vgtotdecr = vgtotdecr + vtotdecr.
            vgtotvdecr = vgtotvdecr + vtotvdecr.     
        
            vtotacre  = 0.
            vtotvacr  = 0.
            vtotdecr  = 0.
            vtotvdecr = 0.
        end.

    end. /* tt-produ */
    
end.
/* TROCA */
else do:

    for each tt-produ
    where tt-produ.movtdc = 17 or
          tt-produ.movtdc = 18
          break by tt-produ.etbcod
          by tt-produ.clacod 
          by tt-produ.fabcod.

        if first-of(tt-produ.etbcod)
        then do:
            find estab where estab.etbcod = tt-produ.etbcod no-lock.
            disp estab.etbnom  with frame f-estab1 side-labels width 100.
        end.
        find clase where tt-produ.clacod = clase.clacod no-lock.
        find fabri where tt-produ.fabcod = fabri.fabcod no-lock.

        if first-of(tt-produ.clacod)
        then disp clase.clanom at 5 with frame f-cab1 side-labels.

        disp     fabri.fabnom at 10 label "Fabricante"
                 tt-produ.pronom
                 /*tt-produ.movtdc*/
                 tt-produ.qtd-acr   label "Acresc"    
                 tt-produ.vacr      label "Valor Acre."
                 tt-produ.qtd-decr  label "Decresc"   
                 tt-produ.vdecr     label "Valor Decre."
                 with frame f-relt1 width 200 down title "AJUSTE TROCA".


        vtotacre   = vtotacre  + tt-produ.qtd-acr.
        vtotdecr   = vtotdecr  + tt-produ.qtd-decr.     
        vtotvacr   = vtotvacr + tt-produ.vacr.
        vtotvdecr  = vtotvdecr + tt-produ.vdecr.
         
        if last-of(tt-produ.clacod)
        then do:
           disp vtotacre  no-label at 97  
                vtotvacr  no-label at 109
                vtotdecr  no-label at 120
                vtotvdecr no-label at 133
                with frame f-relttot width 145 down.
           
           vgtotacre = vgtotacre + vtotacre.
           vgtotvacr = vgtotvacr + vtotvacr.
           vgtotdecr = vgtotdecr + vtotdecr.
           vgtotvdecr = vgtotvdecr + vtotvdecr.     
        
           vtotacre  = 0.
           vtotvacr  = 0.
           vtotdecr  = 0.
           vtotvdecr = 0.
        end.    

    end.

    for each tt-produ
    where tt-produ.movtdc <> 17 and
          tt-produ.movtdc <> 18
          break by tt-produ.etbcod
          by tt-produ.clacod 
          by tt-produ.fabcod.

        disp     fabri.fabnom at 10 label "Fabricante"
                 tt-produ.pronom
                 /*tt-produ.movtdc*/
                 tt-produ.qtd-acr   label "Acresc"    
                 tt-produ.vacr      label "Valor Acre."
                 tt-produ.qtd-decr  label "Decresc"   
                 tt-produ.vdecr     label "Valor Decre."
                 with frame f-relt2 width 200 down title "AJUSTE NORMAL".


        vtotacre   = vtotacre  + tt-produ.qtd-acr.
        vtotdecr   = vtotdecr  + tt-produ.qtd-decr.     
        vtotvacr   = vtotvacr + tt-produ.vacr.
        vtotvdecr  = vtotvdecr + tt-produ.vdecr.
         
        if last-of(tt-produ.clacod)
        then do:
           disp vtotacre  no-label at 97  
                vtotvacr  no-label at 109
                vtotdecr  no-label at 120
                vtotvdecr no-label at 133
                with frame f-relttot1 width 145 down.
           
           vgtotacre = vgtotacre + vtotacre.
           vgtotvacr = vgtotvacr + vtotvacr.
           vgtotdecr = vgtotdecr + vtotdecr.
           vgtotvdecr = vgtotvdecr + vtotvdecr.     
        
           vtotacre  = 0.
           vtotvacr  = 0.
           vtotdecr  = 0.
           vtotvdecr = 0.
        end.    

    



    end.
    

    
end.    

disp  vgtotacre  label "TOTAL Acresc.      " 
      vgtotvacr  label "TOTAL Valor Acresc."
      vgtotdecr  label "TOTAL Decresc.     " 
      vgtotvdecr label "TOTAL Valor Descre."
      with frame f-total 1 col side-labels.

if opsys = "UNIX"
then do:
    output close.
    run visurel.p (varquivo,"").
end.
else do:
    {mrod.i}
end.    


