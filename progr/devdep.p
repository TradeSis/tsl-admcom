{admcab.i new}
/***************************************************************************/
/* devdep.p - Devoluçao das filiais p/ deposito                           */
/***************************************************************************/

def var recimp   as recid.
def var vtela    as log format "Tela/Impressora".
 
def var vetbcod  like estab.etbcod.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var vclacod  like clase.clacod. 
def var vprocod  as int format ">>>>>>>9".
def var vetbnom  like estab.etbnom.
def var vlabel as char format "x(12)".

def temp-table tt-resumo
   field movqt as int
   field procod like produ.procod
   index ind1 is primary unique
       procod.
 


def var fila           as char.
def var varquivo       as char.

def temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def temp-table tt-asstec
    field oscod like asstec.oscod
    index ind is primary unique oscod.
 
assign vetbcod = 0
       vdti = today
       vdtf = today
       vetbnom = "GERAL".

disp vetbcod 
     vetbnom  no-label
     with frame f1 side-label width 80.

repeat:
    
    update vetbcod label "Filial" colon 14
                with frame f1.

    if vetbcod = 0
    then vetbnom = "GERAL".
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        vetbnom = estab.etbnom.
    end.
    disp vetbnom with frame f1.
    do on error undo:
        update vdti label "Periodo" colon 14
               vdtf 
                no-label colon 30 with frame f1.
        if vdti = ? or vdtf = ?
        or vdti > vdtf
        then do:
             message "Data invalida".
             undo.
        end.
                
    end.

    do on error undo. 
        update vclacod colon 14 with frame f1.
        if vclacod <> 0
        then do:
            find clase where clase.clacod = vclacod no-lock no-error.
            if not avail clase
            then do:
                message "Classe nao cadastrada".
                undo, retry.
            end.
            else display clase.clanom format "x(15)" no-label with frame f1.
        end.
        else disp "Geral" @ clase.clanom with frame f1.
    end.

    do on error undo.
       update vprocod  label "Produto" colon 14 
              with frame f1.

       if vprocod > 0
       then do:
            find produ where produ.procod = vprocod no-lock no-error.
            if not avail produ
            then do:
                 message "Produto nao Cadastrado".
                 undo, retry.
            end.                                
            display produ.pronom format "x(30)"  no-label with frame f1.
        end.
        else display "Geral" @ produ.pronom no-label with frame f1.

    end.

    if vclacod > 0
    then run cria-tt-clase.

    for each tt-resumo:
        delete tt-resumo.
     end.   
        

    if opsys = "unix"
    then do:
        vtela = yes.
/*        message "Saida do relatorio [T]Tela [I]Impressora? " update vtela.
  */      
        if not vtela
        then do:
           find first impress where impress.codimp = setbcod no-lock no-error. 
           if avail impress
           then do:
                run acha_imp.p (input recid(impress), 
                                output recimp).
                find impress where recid(impress) = recimp no-lock no-error.
                assign fila = string(impress.dfimp). 
           end.
           else do:
                message "Impressora nao cadastrada".
                vtela = yes.
           end.
        end.
   
        varquivo = "../relat/devdep" + string(time).
        
       {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "63"
            &Cond-Var  = "80" 
            &Page-Line = "66" 
            &Nom-Rel   = ""devdep"" 
            &Nom-Sis   = """SISTEMA DEPOSITO""" 
            &Tit-Rel   = """DEVOLUCAO DE PRODUTOS"" +
                          ""  - "" + string(vdti) + "" A "" + string(vdtf) +
                          ""FILIAL""  + vetbnom "
            &Width     = "90"
            &Form      = "frame f-cabcab"}
     end.                    
     else do:
        assign fila = "" 
               varquivo = "l:\relat\devdep" + string(time).
    
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "76"
            &Page-Line = "66"
            &Nom-Rel   = ""devdep"" 
            &Nom-Sis   = """SISTEMA DEPOSITO""" 
            &Tit-Rel   = """DEVOLUCAO DE PRODUTOS"" +
                          ""  - "" + string(vdti) + "" A "" + string(vdtf) +
                          ""FILIAL""  + vetbnom "
            &Width     = "90"
            &Form      = "frame f-cabcab1"}
     end.
 

    for each plani where plani.movtdc = 6
                    and plani.dest = 995 
                    and plani.pladat >= vdti
                    and plani.pladat <= vdtf
                    no-lock:
        if plani.etbcod = 993 or 
           plani.etbcod = 22 
        then next.
       
        if vetbcod <> 0 and
        vetbcod <> plani.etbcod 
        then next.
                
        for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod 
                         no-lock,
            first produ where produ.procod = movim.procod
                     no-lock:
                      
            if vprocod <> 0 and
               vprocod <> produ.procod 
            then next.
        
            if vclacod > 0 and
               not can-find(first tt-clase where 
                                  tt-clase.clacod = produ.clacod)
            then next.

         disp plani.etbcod column-label "Estab"
              plani.numero column-label "NF" 
              plani.pladat format "99/99/99" 
              movim.procod format ">>>>>>>9" 
              produ.pronom format "x(40)" 
              movim.movqt column-label "Qtde" format ">>,>>9"
              with frame f-cab wiDth 90 down  .

        find tt-resumo where tt-resumo.procod = movim.procod no-lock no-error.
        if not avail tt-resumo
        then do:
             create tt-resumo.
             assign tt-resumo.procod = movim.procod.
        end.

        assign tt-resumo.movqt = tt-resumo.movqt + movim.movqt.
    
        end.
    end.
    PUT UNFORMAT skip(2)
        "TOTAL POR PRODUTO" AT 01 SKIP.
    for each tt-resumo,
        first produ where produ.procod = tt-resumo.procod 
                      no-lock.
        
        disp produ.procod format ">>>>>>>9" 
             produ.pronom 
             tt-resumo.movqt (total).
             
    end.
    
    put skip(2).

    output close.
    
    if opsys = "unix"
    then do:
        if vtela
        then run visurel.p (input varquivo, input "").
        else os-command silent lpr value(fila + " " + varquivo).
    end.
    else do:
        {mrod.i}
    end.
   
   
end.           
    

procedure cria-tt-clase.
 def buffer bclase for clase.
 def buffer cclase for clase.
 def buffer dclase for clase.
 def buffer eclase for clase.
 def buffer fclase for clase.
 def buffer gclase for clase.

 for each clase where clase.clacod = vclacod no-lock:
 
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
                             find tt-clase where tt-clase.clacod =
                                            gclase.clacod no-error.
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


