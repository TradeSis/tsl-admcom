{admcab.i}
def var total_geral_custo like plani.platot.
def var total_geral_venda like plani.platot.
def var total_geral_dif   like plani.platot.
def var total_geral_qtd   like movim.movqtm.
def var vdti    like plani.pladat.
def var vdtf    like plani.pladat.
def var vetbcod like estab.etbcod.
def var vfabcod like fabri.fabcod.
def var varquivo as char.
def var vcodviv like planoviv.codviv.

def buffer xclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.
def buffer bclase for clase.

def var vclacod like clase.clacod.

def var vclasup like clase.clasup.



def temp-table tt-cla
    field clacod like clase.clacod
    index iclase is primary unique clacod.

def temp-table tt-produ
    field recmov as recid 
    field etbcod like movim.etbcod
    field codviv like planoviv.codviv
    field numero like plani.numero
    field vencod like plani.vencod.
    
def temp-table tt-estab
    field etbcod like estab.etbcod
    field totcus like plani.platot
    field totven like plani.platot
    field totdif like plani.platot
    field totqtd like movim.movqtm.
    

repeat:

    for each tt-estab:
        delete tt-estab.
    end.    

    for each tt-produ:
        delete tt-produ.
    end.    

    for each tt-cla:
        delete tt-cla.
    end.
        
    vfabcod = 104655.
    vetbcod = 0.
    
    
    vcodviv = 0. 
    update vcodviv label "Plano....."  format ">>>9"
            help "Informe os planos desejados ou 0 para continuar."
                with frame f1.
    if vcodviv = 0
    then display "Geral" @ planoviv.planomviv with frame f1.
    else do:
        find planoviv where planoviv.codviv = vcodviv no-lock no-error.
        display planoviv.planomviv no-label with frame f1.
    end.    
    
    update vetbcod label "Filial...." at 1 with frame f1.
    if vetbcod = 0
    then display "Geral" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom with frame f1.
    end.
    update vfabcod label "Fabricante" at 1
                with frame f1 side-label width 80.
                
    find fabri where fabri.fabcod = vfabcod no-lock.
    display fabri.fabnom no-label with frame f1.

    update vclacod at 01 label "Classe...." with frame f1.

    if vclacod <> 0
    then do:
        find xclase where xclase.clacod = vclacod no-lock no-error.
        display xclase.clanom no-label with frame f1.
    end.
    else disp "Geral" @ xclase.clanom with frame f1.
    
    
    find first clase where clase.clasup = vclacod no-lock no-error.  
    if avail clase  
    then do: 
        run cria-tt-cla.  
        hide message no-pause.
    end.  
    else do: 
        find clase where clase.clacod = vclacod no-lock no-error. 
        if not avail clase 
        then do: 
            message "Classe nao Cadastrada". 
            undo.
        end.

        create tt-cla. 
        assign tt-cla.clacod = clase.clacod.

    end.

    
    
    update vdti label "Periodo..." at 1
           "a"
           vdtf no-label with frame f1.
         
    for each tt-cla no-lock,
 
        each produ where produ.fabcod = vfabcod and
                         produ.clacod = tt-cla.clacod no-lock: 
        
        find estoq where estoq.etbcod = 995 and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq 
        then next.
            
        for each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock,
            each movim where movim.procod = produ.procod and
                             movim.etbcod = estab.etbcod and
                             movim.movtdc = 5 and
                             movim.movdat >= vdti and
                             movim.movdat <= vdtf no-lock:
            if movim.ocnum[9] = 0
            then next.
            
                             
            if vcodviv = 0
            then.
            else if vcodviv = movim.ocnum[9]
                 then.
                 else next.
                 
 
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat
                                            no-lock no-error.
                                            
            find first tt-produ where tt-produ.recmov = recid(movim)
                                no-error.
            if not avail tt-produ
            then do:
                create tt-produ.
                assign tt-produ.recmov = recid(movim)
                       tt-produ.etbcod = movim.etbcod
                       tt-produ.codviv = movim.ocnum[9]
                       tt-produ.numero = plani.numero
                       tt-produ.vencod = plani.vencod.
            
            end.
        end.

    end.
    
    for each tt-produ:
        
        find movim where recid(movim) = tt-produ.recmov no-lock.
        find produ where produ.procod = movim.procod no-lock.
        find estoq where estoq.etbcod = 995 and
                         estoq.procod = produ.procod no-lock no-error.
         
        find first tt-estab 
                   where tt-estab.etbcod = tt-produ.etbcod no-error.
        if not avail tt-estab
        then do:
            create tt-estab.
            tt-estab.etbcod = tt-produ.etbcod.
        end.    
        assign tt-estab.totqtd = tt-estab.totqtd + movim.movqtm
               tt-estab.totcus = tt-estab.totcus +
                                  (movim.movqtm * estoq.estcusto)
               tt-estab.totven = tt-estab.totven +
                                  (movim.movqtm * movim.movpc)
               tt-estab.totdif =  tt-estab.totdif + 
                                  ( (movim.movqtm * movim.movpc) -
                                    (movim.movqtm * estoq.estcusto) ).
                                  
    end.

    assign total_geral_custo = 0 
           total_geral_venda = 0
           total_geral_qtd   = 0.
    for each tt-estab:
        assign total_geral_custo = total_geral_custo + tt-estab.totcus
               total_geral_venda = total_geral_venda + tt-estab.totven
               total_geral_qtd   = total_geral_qtd   + tt-estab.totqtd
               total_geral_dif   = total_geral_dif   + tt-estab.totdif.
    end.
                                    
    
    if opsys = "UNIX"
    then
        varquivo = "/admcom/progr/celu." + string(time).
    else
        varquivo = "l:\relat\celu." + string(time).

    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "140"
            &Page-Line = "66"
            &Nom-Rel   = ""bati_cel""
            &Nom-Sis   = """MODULO DE COMPRAS"""
            &Tit-Rel   = """FABRICANTE: "" + string(vfabcod,"">>>>99"") +
                          "" PLANO:  "" + string(vcodviv,"">>>9"") + 
                            "" FILIAL: "" + string(vetbcod,"">>9"") + 
                          "" PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "140"
            &Form      = "frame f-cabcab"}

     for each tt-estab by tt-estab.etbcod:
        for each tt-produ where tt-produ.etbcod = tt-estab.etbcod
                                break by tt-produ.codviv:
        
     
            find movim where recid(movim) = tt-produ.recmov no-lock.
            find func where func.etbcod = movim.etbcod and
                            func.funcod = tt-produ.vencod no-lock no-error.
                            
            find produ where produ.procod = movim.procod no-lock.
            find estoq where estoq.etbcod = 995 and
                             estoq.procod = produ.procod no-lock no-error.
                            
            display tt-produ.etbcod column-label "Fl" format ">9"
                    movim.ocnum[9] column-label "Plano" 
                    produ.procod 
                    produ.pronom format "x(30)"
                    tt-produ.vencod column-label "Vend." format ">>9"
                    func.funnom when avail func 
                        column-label "Nome" format "x(15)" 
                    tt-produ.numero format ">>>>>>9"
                    movim.movqtm   column-label "Qtd" 
                    (movim.movqtm * estoq.estcusto)(total by tt-produ.codviv)
                        column-label "Preco!Custo" format ">,>>>,>>9.99"
                    (movim.movqtm * movim.movpc)(total by tt-produ.codviv)
                        column-label "Preco!Venda" format ">,>>>,>>9.99" 
                    ( (movim.movqtm * movim.movpc) -
                  (movim.movqtm * estoq.estcusto) )(total by tt-produ.codviv)
                            column-label "Diferenca" format "->,>>>,>>9.99"
                                          with frame f2 down width 140.
        end.
        
        put skip fill("-",140) format "x(140)" skip
        "Total..............................................................."  
             tt-estab.totqtd format ">>>>>9" at 81
             tt-estab.totcus format ">,>>>,>>9.99" at 88
             tt-estab.totven format ">,>>>,>>9.99" at 101 
             tt-estab.totdif format "->,>>>,>>9.99" at 114 skip.
        put skip fill("-",140) format "x(140)" skip(1).     
    end.
    
        
    put skip fill("-",140) format "x(140)" skip 
        "Total Geral........................................................."  
         total_geral_qtd   format ">>>>>9" at 81
         total_geral_custo format ">,>>>,>>9.99" at 88
         total_geral_venda format ">,>>>,>>9.99" at 101 
         total_geral_dif   format "->,>>>,>>9.99" at 114 skip.
        put skip fill("-",140) format "x(140)" skip(1).     


    
    
    output close.
    
    if opsys = "UNIX" 
    then run visurel.p (input varquivo, input ""). 
    else do: 
        {mrod.i}. 
    end.    
    
    
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
       assign tt-cla.clacod = clase.clacod.
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
             assign tt-cla.clacod = bclase.clacod.
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
                 assign tt-cla.clacod = cclase.clacod.
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
                     assign tt-cla.clacod = dclase.clacod.
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
                         assign tt-cla.clacod = eclase.clacod.
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
                             assign tt-cla.clacod = fclase.clacod.
                           end.
                         end.
                         else do:
                             find tt-cla where tt-cla.clacod = gclase.clacod 
                                                        no-error.
                             if not avail tt-cla
                             then do:
                             
                                 create tt-cla. 
                                 assign tt-cla.clacod = gclase.clacod.
                                        
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
