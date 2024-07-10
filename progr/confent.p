{admcab.i}

def var recimp as recid.
def var fila as char.

def temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.
    
def buffer xclase for clase.
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.


def var vtot as dec.
def var vnome as char.
def var vtotest like estoq.estatual.
def var vresp as l format "C/R" initial yes.
def var varquivo as char format "x(20)".
def var vclacod like clase.clacod.
def var vclasup like clase.clasup.
def buffer bplani for plani.
def buffer bmovim for movim.
def var vetbcod like estab.etbcod.
def var vtotdia like plani.platot.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.
def var vdata1 like plani.pladat label "Data".
def var vdata2 like plani.pladat label "Data".
def var vtotal like plani.platot.
def var vtoticm like plani.icms.


def var vdata-aux as date format "99/99/9999".
def var vqtdvend  as int format ">>>>>9".
def var vvalvend  like movim.movpc.
def var vpercvend as dec format ">>9.99 %".

def var vforcod like fabri.fabcod.

def var val_des as dec.

repeat:
    for each tt-clase. 
        delete tt-clase.
    end.
    assign
        vtotgeral = 0 vdata-aux = ? vqtdvend = 0 vvalvend = 0 vpercvend = 0.
        
    update vetbcod colon 16 with frame f1.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.
    end.

    update vforcod label "Fornecedor" colon 16
           with frame f1.
    
    if vforcod <> 0
    then do:
        find fabri where fabri.fabcod = vforcod no-lock no-error.
        if not avail fabri
        then do:
            message "Fornecedor nao Cadastrado".
            undo.
        end.    
        display fabri.fabnom no-label with frame f1.
    end.
    else disp "Geral" @ fabri.fabnom with frame f1.
    
    update
           vdata1 colon 16
           vdata2 label "A " with frame f1 side-labe centered
                   color blue/cyan  title "Periodo" row 4 width 80.

    
    /*
    update vclasup at 01 with frame f-dat side-label.
    if vclasup = 0
    then do:
        display "GERAL" @ clase.clanom with frame f-dat.
        vnome = "  GERAL".
    end.    
    else do:
        find clase where clase.clacod = vclasup no-lock.
        display clase.clanom no-label with frame f-dat 
               centered color blue/cyan.
        vnome = "   " + clase.clanom.       
    end.
    */

    update vclacod at 01 label "Classe" with frame f-dat side-label.
    if vclacod <> 0
    then do:
        find xclase where xclase.clacod = vclacod no-lock no-error.
        display xclase.clanom no-label with frame f-dat.
    end.
    else disp "Todas" @ xclase.clanom with frame f-dat.
        
    
    find first clase where clase.clasup = vclacod no-lock no-error. 
    if avail clase 
    then run cria-tt-clase. 
    else do: 
        create tt-clase.  
        assign tt-clase.clacod = vclacod  
               tt-clase.clanom = xclase.clanom when avail xclase.
    end.
     
    if opsys = "UNIX"
    then varquivo = "../relat/conf" + string(time).
    else varquivo = "..\relat\conf" + string(time).

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = ""CONFENT""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
        &Tit-Rel   = """CONFERENCIA DAS NOTAS DE COMPRAS NA "" +
                    ""FILIAL "" + string(vetbcod) +
                    ""  - Data: "" + string(vdata1) + "" A "" +
                        string(vdata2) + string(vnome,""x(35)"")"
        &Width     = "140"
        &Form      = "frame f-cabcab"}
    
    
    vtot = 0.
    for each plani where plani.datexp >= vdata1 and
                         plani.datexp <= vdata2 no-lock.
             
                         
        if plani.etbcod = 22 or plani.etbcod = 999 and 
           (plani.desti  = 996 or
            plani.desti  = 995 or
            plani.desti  = 900) and 
           plani.movtdc = 06 and 
           (vetbcod      = 996 or
            vetbcod      = 995 or
            vetbcod      = 900)
        then. 
        else do:
            if vetbcod = 0 or plani.etbcod = vetbcod 
            then. 
            else next. 
            
            if plani.movtdc = 4 
            then. 
            else next.
        end.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
                             
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ
            then next.
            if vforcod <> 0
            then if produ.fabcod <> vforcod 
                 then next.
            if vclacod = 0
            then.
            else do:
                find tt-clase where 
                            tt-clase.clacod = produ.clacod no-lock no-error.
                if not avail tt-clase
                then next.
            end.

            vtotest = 0.
            for each estoq where estoq.procod = produ.procod and
                                 if vetbcod   = 0
                                 then true
                                 else estoq.etbcod = vetbcod no-lock.
                
                vtotest = vtotest + estoq.estatual.

            end.     
                                         
            if plani.movtdc = 4
            then
            find forne where forne.forcod = plani.emite no-lock no-error.
            else 
            find forne where forne.forcod = 5027 no-lock no-error.

            /***/
            assign
                vqtdvend  = 0 vvalvend  = 0 vpercvend = 0.
                
            do vdata-aux = plani.pladat to today:
            
                for each bmovim use-index datsai where
                         bmovim.procod = produ.procod and
                         bmovim.movtdc = 5            and
                         bmovim.movdat = vdata-aux no-lock:
        
                    assign
                        vqtdvend = vqtdvend + bmovim.movqtm
                        vvalvend = vvalvend + (bmovim.movqtm * bmovim.movpc). 

                end. 
                        
            end.
            /***/
            
            val_des = 0. 
            
            val_des = (((movim.movpc * movim.movqtm) / 
                        (plani.platot + plani.descprod)) 
                       * plani.descprod) / movim.movqtm.
            if val_des = ? then val_des = 0. 
            
            display
                plani.pladat
                plani.numero  format ">>>>>>>>9"
                plani.serie format "x(02)" column-label "Sr"
                forne.fornom when avail forne format "x(17)"
                produ.procod column-label "Codigo" 
                produ.pronom format "x(24)"
                vtotest      format "->>>>>9" column-label "Quant.!Estoq"
                movim.movqtm format ">>>>9" column-label "Qtd"
                movim.movpc - val_des 
                        format ">>>>,>>9.99" column-label "Pr.Unit"
                (movim.movpc * movim.movqtm) format ">>>>>,>>9.99"
                column-label "Total"
                vqtdvend column-label "Qtd!Venda"
                vvalvend column-label "Valor!Venda" format ">>>>,>>9.99"
                ((vqtdvend / movim.movqtm))
                format ">,>>9.99%"column-label "%"
                             with frame f-val down no-box width 150.
            down with frame f-val.
            vtot = vtot + (movim.movpc * movim.movqtm).
        end.
    end.
    put skip(1) "Total......" at 101 vtot format ">>,>>>,>>9.99".

    output close.
    
    if opsys = "UNIX"
    then do:
        
        run visurel.p (varquivo, "").

        sresp = no.
        message "Deseja imprimir ?" update sresp.
        if sresp
        then do:
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do: 
            run acha_imp.p (input recid(impress),  
                            output recimp). 
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp).
        end.    

        os-command silent lpr value(fila + " " + varquivo).
        end.
    end.
    else do:
        {mrod.i} 
    end.
    
end.

procedure cria-tt-clase.
 for each clase where clase.clasup = vclacod no-lock:
   find first bclase where bclase.clasup = clase.clacod no-lock no-error.
   if not avail bclase
   then do: 
     find tt-clase where tt-clase.clacod = clase.clacod no-error. 
     if not avail tt-clase 
     then do: 
       create tt-clase. 
       assign tt-clase.clacod = clase.clacod 
              tt-clase.clanom = clase.clanom.
     end.
   end.
   else do: 
     for each bclase where bclase.clasup = clase.clacod no-lock: 
         find first cclase where cclase.clasup = bclase.clacod no-lock no-error.
         if not avail cclase
         then do: 
           find tt-clase where tt-clase.clacod = bclase.clacod no-error. 
           if not avail tt-clase 
           then do: 
             create tt-clase. 
             assign tt-clase.clacod = bclase.clacod 
                    tt-clase.clanom = bclase.clanom.
           end.
         end.
         else do: 
           for each cclase where cclase.clasup = bclase.clacod no-lock: 
             find first dclase where dclase.clasup = cclase.clacod 
                                                     no-lock no-error. 
             if not avail dclase 
             then do: 
               find tt-clase where tt-clase.clacod = cclase.clacod no-error. 
               if not avail tt-clase 
               then do: 
                 create tt-clase. 
                 assign tt-clase.clacod = cclase.clacod 
                        tt-clase.clanom = cclase.clanom.
               end.                          
             end.
             else do: 
               for each dclase where dclase.clasup = cclase.clacod no-lock: 
                 find first eclase where eclase.clasup = dclase.clacod 
                                                         no-lock no-error. 
                 if not avail eclase 
                 then do: 
                   find tt-clase where tt-clase.clacod = dclase.clacod no-error.
                   if not avail tt-clase 
                   then do: 
                     create tt-clase. 
                     assign tt-clase.clacod = dclase.clacod 
                            tt-clase.clanom = dclase.clanom. 
                   end.       
                 end. 
                 else do:  
                   for each eclase where eclase.clasup = dclase.clacod no-lock:
                     find first fclase where fclase.clasup = eclase.clacod 
                                                             no-lock no-error.
                     if not avail fclase 
                     then do: 
                       find tt-clase where tt-clase.clacod = eclase.clacod
                                                             no-error.
                       if not avail tt-clase 
                       then do: 
                         create tt-clase. 
                         assign tt-clase.clacod = eclase.clacod 
                                tt-clase.clanom = eclase.clanom.
                       end.
                     end.
                     else do:
                       for each fclase where fclase.clasup = eclase.clacod
                                    no-lock:
                         find first gclase where gclase.clasup = fclase.clacod 
                                                             no-lock no-error.
                         if not avail gclase 
                         then do: 
                           find tt-clase where tt-clase.clacod = fclase.clacod
                                                                 no-error.
                           if not avail tt-clase 
                           then do: 
                             create tt-clase. 
                             assign tt-clase.clacod = fclase.clacod 
                                    tt-clase.clanom = fclase.clanom.
                           end.
                         end.
                         else do:
                             find tt-clase where 
                                tt-clase.clacod = gclase.clacod no-error.
                             if not avail tt-clase
                             then do:
                                 create tt-clase. 
                                 assign tt-clase.clacod = gclase.clacod 
                                        tt-clase.clanom = gclase.clanom.
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
 

