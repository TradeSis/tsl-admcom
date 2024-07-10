{admcab.i}
/***************************************************************************/
/*  relass3.p -Relatório de Envio /Retorno Assitencia ténica             */
/***************************************************************************/

def var recimp   as recid.
def var vtela    as log format "Tela/Impressora".
def var vetbcod  like estab.etbcod.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var vforcod  like forne.forcod.
def var vfornome like forne.fornom.
def var vclicod  like clien.clicod.
def var vfabcod  like fabri.fabcod.
def var vclacod  like clase.clacod. 
def var vprocod  as int format ">>>>>>>9".
def var os-totenv      as int.
def var os-totret      as int.
def var os-envass      as int.
def var os-retass      as int.

def var os-fechada   as int.
def var os-total   as int.
def var vdiaass    as int.
def var vqtdass   as int.
def var vdiadep   as int.
def var vqtddep   as int.
def var vdiacli   as int.
def var vqtdcli   as int.

def var vlabel as char format "x(12)".
def var vperc  as dec format ">>,>>9.99".

def var fila           as char.
def var varquivo       as char.

def temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def temp-table tt-asstec
    field oscod like asstec.oscod
    index ind is primary unique oscod.

repeat:
    
    update vetbcod label "Filial" colon 14
                with frame f1 side-label width 80.

    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.

    update vdti label "Periodo" colon 14
           vdtf /* validate(vdti <= vdtf,"Data inválida") */
                no-label colon 30 with frame f1.
   
    update vclicod label "Cliente" colon 14 with frame f1.

    if vclicod > 0
    then do:
         find clien where clien.clicod = vclicod no-lock
               no-error. 
         if not avail clien
         then do:
              message "Cliente não cadastrado".
              next.
         end.
         disp clien.clinom format "x(20)" no-label with frame f1.
    
    end.
    else disp "Geral" @ clien.clinom with frame f1.

    do on error undo. 
        update vclacod colon 55 with frame f1.
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
       update vfabcod label "Fabricante" colon 14 with frame f1.
       if vfabcod > 0
       then do:
            find fabri where fabri.fabcod = vfabcod no-lock no-error.
            if avail fabri
            then do:
                 disp fabri.fabnom no-label with frame f1.
            end.
            else do: 
                 message "Fabricante nao cadastrado" .
                 undo, retry.
           end.      
        end.        
        else display "Geral" @ fabri.fabnom no-label with frame f1.
     end.    
    do on error undo.
       update vforcod label "Posto Ass.Tec" colon 14 with frame f1.
       if vforcod > 0
       then do:                 
            find forne where forne.forcod = vforcod no-lock no-error.       
            if avail forne                                                  
            then do:  
                 vfornome = forne.fornom. 
                 disp forne.fornom format "x(20)" no-label with frame f1.
            end.
            else do:
                 message "Posto nao cadastrado".
                 undo, retry.
            end.
       end.
       else display "Geral" @ forne.fornom no-label with frame f1.
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
    
    assign 
           os-totenv      = 0
           os-totret      = 0
           os-envass      = 0
           os-retass      = 0.

   for each tt-clase:
       delete tt-clase.
   end.

   if vclacod > 0
   then run cria-tt-clase.

    assign os-total = 0
           os-fechada = 0
           vdiaass =  0
           vqtdass = 0
           vdiadep = 0
           vqtddep = 0
           vdiacli = 0
           vqtdcli = 0.

    for each estab where estab.etbcod = (if vetbcod = 0 
                         then estab.etbcod else vetbcod ) no-lock:
                         
           for each asstec use-index ietbdt4
                           where asstec.etbcod = estab.etbcod 
                             and asstec.dtenvfil >= vdti
                             and asstec.dtenvfil <= vdtf /*  = auxdt */         
                                           no-lock.
               run p-acumula. 
            
           end.
           for each asstec use-index ind-4
                           where asstec.datexp >= vdti /*  = auxdt */
                             and asstec.datexp <= vdtf
                             and asstec.etbcod = estab.etbcod 
                                           no-lock.
               if not can-find( first tt-asstec where tt-asstec.oscod =
                                            asstec.oscod)
               then run p-acumula.
           end.
     end.                  
                         
procedure p-acumula.                         
                                             
        if vforcod > 0
        and vforcod <> asstec.forcod 
        then next.
       
        if vclicod > 0 and
        vclicod <> asstec.clicod then next.

        if vprocod > 0
        and vprocod <> asstec.procod
        then next .
        
        find produ where produ.procod = asstec.procod no-lock no-error.
        if not avail produ then next.

        if vclacod > 0
        and not can-find(first tt-clase where 
                               tt-clase.clacod = produ.clacod)
        then next.
        
        if vfabcod > 0 
        and produ.fabcod <> vfabcod
        then next.
        
        find tt-asstec where tt-asstec.oscod = asstec.oscod
                            no-error.
        if not avail tt-asstec
        then do:
             create tt-asstec.
             assign tt-asstec.oscod = asstec.oscod.
        end.                    

        if asstec.datexp >= vdti and 
           asstec.datexp <= vdtf and
           asstec.datexp <> ?
        then os-total = os-total + 1.
      
        if asstec.dtenvfil <> ? and
           asstec.dtenvfil >= vdti and
           asstec.dtenvfil <= vdtf  
        then os-fechada = os-fechada + 1.       
        
        if  asstec.dtenvass <> ? and asstec.dtretass <> ? and
            asstec.dtretass >= vdti and 
            asstec.dtretass <= vdtf  
        then assign vdiaass = vdiaass + (asstec.dtretass - asstec.dtenvass)
                    vqtdass = vqtdass + 1.

        if asstec.dtenvfil <> ? and asstec.dtentdep <> ? and
           asstec.dtenvfil >= vdti and
           asstec.dtenvfil <= vdtf  
        then assign vdiadep = vdiadep + (asstec.dtenvfil - asstec.dtentdep)
                    vqtddep = vqtddep + 1.
            
        if asstec.datexp <> ? and asstec.dtenvfil <> ? and
           asstec.dtenvfil >= vdti and
           asstec.dtenvfil <= vdtf  
        then do:
             assign vdiacli = vdiacli + (asstec.dtenvfil - asstec.datexp)
                    vqtdcli = vqtdcli + 1.
/*             disp asstec.dtenvfil asstec.datexp with frame fx 10 down.       
*/  
             end.       
                    
                    
                    
/*
        if asstec.datexp = ?
           or asstec.dtenvfil = ?
           or asstec.dtretass = ?
           or asstec.dtenvass = ?
 then disp  asstec.datexp
  asstec.dtenvfil
  asstec.dtretass
  asstec.dtenvass.
                    
*/
                    
 end procedure.

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
   
        varquivo = "../relat/relass2" + string(time).
        
       {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "63"
            &Cond-Var  = "80" 
            &Page-Line = "66" 
            &Nom-Rel   = ""relass2"" 
            &Nom-Sis   = """SISTEMA DEPOSITO - ASSISTENCIA TECNICA""" 
            &Tit-Rel   = """ESTATISTICA DE ASSISTENCIA TECNICA"" +
                          ""  - "" + string(vdti) + "" A "" + string(vdtf)"
            &Width     = "76"
            &Form      = "frame f-cabcab"}
     end.                    
     else do:
        assign fila = "" 
               varquivo = "l:\relat\relass2" + string(time).
    
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "76"
            &Page-Line = "66"
            &Nom-Rel   = ""relass3"" 
            &Nom-Sis   = """SISTEMA DEPOSITO - ASSISTENCIA TECNICA""" 
            &Tit-Rel   = """ESTATISTICA DE ASSISTENCIA TECNICA"" +
                          ""  - "" + string(vdti) + "" A "" + string(vdtf)"
            &Width     = "76"
            &Form      = "frame f-cabcab1"}
     end.
               
    put unformat skip (1)
        " Abertas no Periodo: " os-total format ">>>,>>>,>>9" skip
        "Fechadas no Periodo: " os-fechada format ">>>,>>>,>>9" skip
        "          Diferença: " (os-total - os-fechada) format "->>,>>>,>>9" 
        skip(1).

    vperc = (vdiacli / vqtdcli).
    vlabel = "Cliente".
    disp vlabel column-label "Visao" 
         space(3)
         vqtdcli column-label "Quantidade" format ">>>,>>>,>>9"
         space(3) 
         vperc    column-label "Media Dias" format "->>,>>9.99"
          with frame fx 10 down.
          down 1 with frame fx.

    Disp "Deposito" @ vlabel
          vqtddep  @ vqtdcli
         (vdiadep / vqtddep) @ vperc
              with frame fx.
          down 1 with frame fx.    
          
    Disp "Ass.Tecnica" @ vlabel
          vqtdass  @ vqtdcli
         (vdiaass / vqtdass) @ vperc
              with frame fx.
          down 1 with frame fx.    
    put skip(3).

    output close.
    
    if opsys = "unix"
    then do:
        if vtela
        then run visurel.p (input varquivo, input "").
        else os-command silent lpr value(fila + " " + varquivo).
    end.
    else do:
        {mrod_l.i}
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


