{admcab.i}

def var vpc as log format "Sim/Nao".
def var vpv as log format "Sim/Nao".

def var vdata like plani.pladat.

def var vtip as char format "x(20)" extent 2 initial ["Numerico","Alfabetico"].
def var vtipo as int.
def var vestacao like produ.etccod.

def new shared temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.
def buffer scalse for clase.

def var vclacod like clase.clacod.
def var vcla-cod like clase.clacod.

repeat:

    prompt-for estab.etbcod
                with frame f1 side-label width 80 color white/red.
    find estab using estab.etbcod no-lock.
    disp estab.etbnom no-label skip with frame f1.

    prompt-for categoria.catcod label "Categoria      "
                with frame f1.
    find categoria using categoria.catcod no-lock.
    disp space(2) categoria.catnom no-label with frame f1.

    update vestacao at 1 label "Estacao        " with frame f1 .
    if vestacao <> 0
    then do:
            find first estac where estac.etccod = vestacao no-lock no-error.
            if not avail estac
            then do:
                message "Estacao Invalida" view-as alert-box.
                undo, retry.
            end.
            else disp estac.etcnom no-label with frame f1.
    end.
    else disp "Geral" @ estac.etcnom with frame f1.

    update vcla-cod at 1 label "Classe         " with frame f1.
    vclacod = vcla-cod.
    if vclacod <> 0
    then do:
        find clase where clase.clacod = vclacod no-lock no-error.
        display clase.clanom format "x(20)" no-label with frame f1.
        find first bclase where bclase.clasup = vclacod no-lock no-error. 
        if avail bclase 
        then do:
            message "Montando Tabela Temporaria de Classes...".
            pause 2 no-message.
            for each tt-clase.
                delete tt-clase.
            end.    
            run cria-tt-clase. 
            hide message no-pause.
        end. 
        else do:
            create tt-clase.
            assign tt-clase.clacod = clase.clacod
                   tt-clase.clanom = clase.clanom.
        end.

    end.
    else disp "Todas" @ clase.clanom with frame f1.
 
    update vdata with frame f1.
    
    vpc = yes. vpv = yes.
    
    update vpc label "Mostrar Preco de Custo ?" skip
           vpv label "Mostrar Preco de Venda ?"
           with frame f1-a centered side-labels row 8 color white/red.
    
    if vpc = no and vpv = no
    then undo.
    
    display vtip with frame f-tip no-label.
    choose field vtip with frame f-tip centered row 4.

    vtipo = frame-index.

    if vpc = yes and   /* Com preco de custos e preco de venda */
       vpv = yes
    then
        run relinv2a.p(input estab.etbcod,
                       input categoria.catcod,
                       input vdata,
                       input vtipo,
                       input vestacao,
                       input vclacod).
                  
    if vpc = yes and   /* Com preco de custos e sem preco de venda */
       vpv = no
    then
        run relinv2b.p(input estab.etbcod,
                       input categoria.catcod,
                       input vdata,
                       input vtipo,
                       input vestacao,
                       input vclacod).
    
    if vpc = no  and   /* Sem preco de custos e preco de venda */
       vpv = yes
    then
        run relinv2c.p(input estab.etbcod,
                       input categoria.catcod,
                       input vdata,
                       input vtipo,
                       input vestacao,
                       input vclacod).

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
                             find tt-clase where tt-clase.clacod = gclase.claco~d 
                                                        no-error.
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

