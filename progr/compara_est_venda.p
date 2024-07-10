{admcab.i new}

def var vetbi    as integer.
def var vetbf    as integer.

def var vclacod   as integer.
def var vforcod   as integer.
def var vcatcod   as integer.

def var vdti      as date.
def var vdtf      as date.

def var varquivo  as char.

def buffer xclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.
def buffer bclase for clase.

def temp-table tt-cla
    field clacod like clase.clacod
    field clanom like clase.clanom
     index iclase is primary unique clacod.

def temp-table tt-produ 
    field etbcod         as integer
    field procod         as integer
    field pronom         as character
    field estatual       as integer
    field estcusto       as decimal
    field est-perc       as decimal
    field platot        like plani.platot
    index idx01 etbcod procod.

assign vdti = date(month(today),01,year(today))
       vdtf = date(today) .

find last estab where estab.etbcod < 189 no-lock no-error.

assign vetbi = 1
       vetbf = estab.etbcod. 


form vdti       format "99/99/9999" label "Data"     at 7
     " a "
     vdtf       format "99/99/9999"   no-label
     vetbi      format ">>>>9"   label "Filial"      at 5
     " a "                                           at 24
     vetbf      format ">>>>9"   no-label                        skip
     vcatcod    format ">>>>9"   label "Depto"       at 6
     categoria.catnom   no-label
     vclacod                     label "Classe"      at 5      
     clase.clanom       no-label                                    skip
     vforcod                     label "Fornecedor"
     forne.fornom       no-label  
         with frame f01 row 5 centered side-labels .

update vdti
       vdtf 
       vetbi
       vetbf
        with frame f01.

repeat on error undo,return with frame f01:        

    update vcatcod
            with frame f01.
    
    find first categoria where categoria.catcod = vcatcod no-lock no-error.    
    
    if not avail categoria
    then do:
    
        message "Departamento inválido!"
                    view-as alert-box.
                    
        next.
    
    end.
    else display categoria.catnom.
    
    update vclacod
            with frame f01.
    
    find first clase where clase.clacod = vclacod no-lock no-error.
        
    if not avail clase
    then do:
        
        message "Classe inválida!"
                  view-as alert-box.
                                    
        next.
                                            
    end.    
    else display clase.clanom.
    
    if vclacod > 0
    then run cria-tt-cla.
    
    update vforcod
            with frame f01.
            
    if vforcod > 0
    then do:
        find first forne where forne.forcod = vforcod no-lock no-error.
           
        if not avail forne
        then do:
    
            message "Fornecedor Inválido!"
                      view-as alert-box.
                      
            next.          
        
        end.
        else display forne.fornom.
    
    end.
    else display "Todos".
    leave.

end.

if keyfunction(lastkey) = "end-error"
then return.

for each estab where estab.etbcod >= vetbi
                 and estab.etbcod <= vetbf no-lock.
    
    display "Processando Estoque da Filial: "
            estab.etbcod no-label
            with frame f-mostra overlay centered row 12. pause 0.

    for each produ no-lock.

        if vcatcod > 0
            and produ.catcod <> vcatcod
        then next.

        if vclacod = 0
        then.
        else do:
            find tt-cla where tt-cla.clacod = produ.clacod no-lock no-error.
            if not avail tt-cla
            then next.
        end.
        
        if vforcod > 0
            and produ.fabcod <> vforcod
        then next.                       
        
        for each estoq where estoq.etbcod = estab.etbcod
                         and estoq.procod = produ.procod
                         and estoq.estatual <> 0    no-lock:
                                 
        
        find first tt-produ where tt-produ.etbcod = estoq.etbcod
                              and tt-produ.procod = produ.procod
                                        exclusive-lock no-error.
        
        if not avail tt-produ
        then do:
        
            create tt-produ.
            assign
                tt-produ.etbcod = estoq.etbcod
                tt-produ.procod = produ.procod
                tt-produ.pronom = produ.pronom.
                
        end.
        
        assign tt-produ.estatual = estoq.estatual
               tt-produ.estcusto = estoq.estcusto. 
        
        end.         
        
    end.

end.

hide frame f-mostra.

display "Processando Estoque da Filial: Ok..." no-label
             with frame f-mostra2 overlay centered row 12. pause 0.

for each estab no-lock:

    
    display "Processando Venda da Filial: "
            estab.etbcod no-label
            with frame f-mostra3 overlay centered row 15. pause 0.

    
    for each tt-produ where tt-produ.etbcod = estab.etbcod
                    exclusive-lock :

    for each movim where movim.etbcod = tt-produ.etbcod
                     and movim.procod = tt-produ.procod
                     and movim.movtdc = 5
                     and movim.movdat >= vdti
                     and movim.movdat <= vdtf no-lock.
                     
       assign tt-produ.platot = tt-produ.platot + (movim.movqtm * movim.movpc).  
    end.
    end.
end.

for each tt-produ exclusive-lock.

    assign tt-produ.est-perc = round(tt-produ.platot * 100
                                / (tt-produ.estcusto * tt-produ.estatual),2).

    if tt-produ.est-perc = ?
    then assign tt-produ.est-perc = 0.

end.

if opsys = "UNIX"
then varquivo = "/admcom/relat/relat_compara_estoq_" + string(time).
else varquivo = "l:\relat\relat_compara_estoque_" + string(time).

{mdad.i
      &Saida     = "value(varquivo)"
      &Page-Size = "64"
      &Cond-Var  = "120"
      &Page-Line = "64"
      &Nom-Rel   = ""compara_est_venda.p""
      &Nom-Sis   = """SISTEMA AUDITORIA"""
      &Tit-Rel   = """COMPARA ESTOQUE ATUAL COM A VENDA DE "" +
                     string(vdti,""99/99/9999"") + "" ATE "" +
                     string(vdtf,""99/99/9999"") "
      &Width     = "120"
      &Form      = "frame f-cabcab"}


for each tt-produ exclusive-lock.

    display
    tt-produ.etbcod     column-label "Fil"        format ">>>9"
    tt-produ.procod     column-label "Cod"        format ">>>>>>>9"  
    tt-produ.pronom     column-label "Produto"    format "x(40)"
    tt-produ.estatual   column-label "Estoque"    format "->>,>>>,>>9"
    tt-produ.estcusto   column-label "Est Custo"   format "->>>,>>>,>>9.99"   
    tt-produ.platot     column-label "Venda Total" format "->>>,>>>,>>9.99"
    tt-produ.est-perc   column-label "% Part"      format "->>>,>>9,99%"
      skip
     with frame f02 down width 120.

end.

output close.

if opsys = "UNIX"
then do:

    message "Arquivo gerado: " varquivo. pause 0.
    
    run visurel.p (input varquivo, input "").
        
end.
else do:
    {mrod.i}
end.

            

procedure cria-tt-cla.
 for each clase where clase.clasup = vclacod no-lock:
   find first bclase where bclase.clasup = clase.clacod no-lock no-error.
   if not avail bclase
   then do: 
     find tt-cla where tt-cla.clacod = clase.clacod no-error. 
     if not avail tt-cla 
     then do: 
       create tt-cla. 
       assign tt-cla.clacod = clase.clacod 
              tt-cla.clanom = clase.clanom.
     end.
   end.
   else do: 
     for each bclase where bclase.clasup = clase.clacod no-lock: 
         find first cclase where cclase.clasup = bclase.clacod no-lock no-error.
         if not avail cclase
         then do: 
           find tt-cla where tt-cla.clacod = bclase.clacod no-error. 
           if not avail tt-cla 
           then do: 
             create tt-cla. 
             assign tt-cla.clacod = bclase.clacod 
                    tt-cla.clanom = bclase.clanom.
           end.
         end.
         else do: 
           for each cclase where cclase.clasup = bclase.clacod no-lock: 
             find first dclase where dclase.clasup = cclase.clacod 
                                                     no-lock no-error. 
             if not avail dclase 
             then do: 
               find tt-cla where tt-cla.clacod = cclase.clacod no-error. 
               if not avail tt-cla 
               then do: 
                 create tt-cla. 
                 assign tt-cla.clacod = cclase.clacod 
                        tt-cla.clanom = cclase.clanom.
               end.                          
             end.
             else do: 
               for each dclase where dclase.clasup = cclase.clacod no-lock: 
                 find first eclase where eclase.clasup = dclase.clacod 
                                                         no-lock no-error. 
                 if not avail eclase 
                 then do: 
                   find tt-cla where tt-cla.clacod = dclase.clacod no-error.
                   if not avail tt-cla 
                   then do: 
                     create tt-cla. 
                     assign tt-cla.clacod = dclase.clacod 
                            tt-cla.clanom = dclase.clanom. 
                   end.       
                 end. 
                 else do:  
                   for each eclase where eclase.clasup = dclase.clacod no-lock:
                     find first fclase where fclase.clasup = eclase.clacod 
                                                             no-lock no-error.
                     if not avail fclase 
                     then do: 
                       find tt-cla where tt-cla.clacod = eclase.clacod
                                                             no-error.
                       if not avail tt-cla 
                       then do: 
                         create tt-cla. 
                         assign tt-cla.clacod = eclase.clacod 
                                tt-cla.clanom = eclase.clanom.
                       end.
                     end.
                     else do:
                     
                       for each fclase where fclase.clasup = eclase.clacod
                                    no-lock:
                         find first gclase where gclase.clasup = fclase.clacod 
                                                             no-lock no-error.
                         if not avail gclase 
                         then do: 
                           find tt-cla where tt-cla.clacod = fclase.clacod
                                                                 no-error.
                           if not avail tt-cla 
                           then do: 
                             create tt-cla. 
                             assign tt-cla.clacod = fclase.clacod 
                                    tt-cla.clanom = fclase.clanom.
                           end.
                         end.
                         else do:
                             find tt-cla where tt-cla.clacod = gclase.clacod 
                                                        no-error.
                             if not avail tt-cla
                             then do:
                             
                                 create tt-cla. 
                                 assign tt-cla.clacod = gclase.clacod 
                                        tt-cla.clanom = gclase.clanom.
                                        
                             end.  
                         end.
                       end.
                     end.
                   end.
                 end.
               end.
             end.
           end.                                  
         end.
     end.
   end.
 end.
end procedure.


            
