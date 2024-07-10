{admcab.i}

def var v-procod like produ.procod.
def var vclacod like clase.clacod.
def var vfabcod like fabri.fabcod.

def buffer xclase for clase.
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.

def new shared temp-table tt-cla
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.



def var v-per as dec.
def new shared var v-full as int.

def new shared var v-empty as int.

def var totlote as int format ">>>>>9".
def var vlote    as int.
def var vdiminui as int.
def var xx as dec.
def var vsoma as int.
def var vprocod like produ.procod.
def var vqtd    like movim.movqtm.
def var vv as int.
def var vgrupo as int.
def var vtot as int extent 30 format ">>>>>>>>999".
def var vtotal as char format "x(120)".
def var vpro as char format "x(120)".

def new shared temp-table tt-produ
    field procod like produ.procod.


def var varquivo as char format "x(20)".
def var ii as int. 
def var i as int.

def new shared temp-table tt-estab
    field etbcod   like estab.etbcod
    field estatual like estoq.estatual
    field qtd-cal  as dec 
    field saldo    as dec
    field per-ori  as dec
    field qtd-dis  as int
    field per-cal  as dec
    field crijaime as dec
    index iestab crijaime desc
                 per-ori  desc
                 saldo    desc
                 estatual.
    

def var vdif  as int.
def var q     as dec.
def var e     as dec.
def var tot01 as int.

def var vest as dec.
repeat:
    for each tt-cla:
        delete tt-cla.
    end.
    
    assign e = 0
           q = 0
           vdif = 0
           ii = 0
           vpro = ""
           ii = ii + 1
           vqtd    = 0
           vlote   = 1
           totlote = 0.
     
    
    for each tt-estab:
        delete tt-estab.
    end.

    for each tt-produ:
        delete tt-produ.
    end.
      
    
    update vprocod label "Produto..." 
           with frame f1 side-label width 80.
    
    find produ where produ.procod = vprocod no-lock.
    display produ.pronom no-label with frame f1.
    create tt-produ.
    assign tt-produ.procod = produ.procod.
    
    do on error undo:
            
        update vfabcod label "Fabricante" with frame f1.
        if vfabcod <> 0 
        then do:

            find fabri where fabri.fabcod = vfabcod no-lock no-error.
            if not avail fabri
            then do:
                message "Fabricante nao Cadastrado".
                undo.
            end.
            else disp fabri.fabnom no-label with frame f1.
                
        end.
        else disp "" @ fabri.fabnom with frame f1.
            
    end.
    
    do on error undo:
    
        update skip vclacod label "Classe...." with frame f1.
        if vclacod = 0
        then disp "" @ xclase.clanom with frame f1.

        else do:

            find xclase where xclase.clacod = vclacod no-lock no-error.
            display xclase.clanom no-label with frame f1.

            find first clase where 
                       clase.clasup = vclacod no-lock no-error. 
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
                assign tt-cla.clacod = clase.clacod
                       tt-cla.clanom = clase.clanom.
            end.
        end.
    end.
    repeat:
        
        for each tt-produ:
            find produ where produ.procod = tt-produ.procod no-lock.
            display tt-produ.procod
                    produ.pronom with frame f3 8 down 
                                    color white/black overlay column 20.
            down with frame f3.

        end.
        v-procod = 0.
        update v-procod label "Produto" with frame f2 side-label
                                overlay.
        find produ where produ.procod = v-procod no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao cadastrado".
            undo, retry.
        end.
        find first tt-produ where tt-produ.procod = produ.procod no-error.
        if avail tt-produ
        then do:
            message "Produto ja incluido".
            undo, retry.
        end.
        else do:
            create tt-produ.
            assign tt-produ.procod = produ.procod.
        end.
    
    end.
        
    
    
    
    update vqtd   label "Quantidade"  
           vlote  label "Lote"  
                with frame f4 side-label row 20 centered.
           
    if vlote = 0
    then vlote = 1.
    
    if vqtd mod vlote <> 0
    then do:
        message "Lote nao confere com quantidade informada".
        undo, retry.
    end.       
     
    vqtd = vqtd / vlote.    
    

    for each estab where estab.etbcod < 900 no-lock:    
       if {conv_igual.i estab.etbcod} then next.

        for each tt-cla:
            for each produ where produ.clacod = tt-cla.clacod no-lock:
            
                find first tt-produ where tt-produ.procod = produ.procod
                            no-error.
                if avail tt-produ
                then next.
                if vfabcod <> 0
                then if produ.fabcod <> vfabcod then next.
                    
                find estoq where estoq.etbcod = estab.etbcod and
                                 estoq.procod = produ.procod 
                                     no-lock no-error.

                if not avail estoq or estoq.estatual <= 0
                then next.
            
                e = e + (estoq.estatual / vlote).
        
            end.
        end.
    end.
    
    
    
    for each tt-produ:
        for each estab where estab.etbcod < 900 no-lock:
            if {conv_igual.i estab.etbcod} then next.
           find estoq where estoq.etbcod = estab.etbcod and
                            estoq.procod = tt-produ.procod no-lock no-error.
           if not avail estoq or estoq.estatual <= 0
           then next.
            
           e = e + (estoq.estatual / vlote).
        
        end.
    end.
 

    
    
    e = e + vqtd. 

    vgrupo = 0.
   
    if vprocod <> 0
    then do:
        find produ where produ.procod = vprocod no-lock.
        find clase where clase.clacod = produ.clacod no-lock.
        find tipdis where tipdis.tipcod = clase.clacod no-lock no-error.

        if avail tipdis 
        then vgrupo = clase.clacod.
        else do:
        
            find tipdis where tipdis.tipcod = clase.clasup no-lock no-error.
            if avail tipdis
            then vgrupo = clase.clasup.
        
        end.
    end.
       
    if vgrupo = 0
    then do:
        if vqtd > 150
        then vgrupo = 0.
        else do:
            if e >= 200
            then vgrupo = 0.
            else vgrupo = 99.
        end.
    end.

        
    update vgrupo label "Distribuicao" with frame f4.
          
    
    if vprocod <> 0
    then do:
    
     for each estab where estab.etbcod < 900 and
                         estab.etbcod <> 22 no-lock:
         if {conv_igual.i estab.etbcod} then next.
                
       
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
       
        
        find distr where distr.etbcod = estab.etbcod and
                         distr.clacod = vgrupo no-lock no-error.
        if not avail distr
        then do: 
            e = e - (estoq.estatual / vlote). 
            next.
        end.
        
        if estoq.estatual <= 0
        then vest = 0.
        else vest = (estoq.estatual / vlote).

        q = (( e * (distr.proper / 100))).
        if q < 0
        then q = 0.
        
     end.
    
    end.
    else do:
    
     for each estab where estab.etbcod < 900 and
                         estab.etbcod <> 22 no-lock:
         if {conv_igual.i estab.etbcod} then next.
         for each tt-cla:
             for each produ where produ.clacod = tt-cla.clacod no-lock:
            
                 if vfabcod <> 0
                 then if produ.fabcod <> vfabcod then next.
        
        
                 find estoq where estoq.etbcod = estab.etbcod and
                                  estoq.procod = produ.procod 
                                  no-lock no-error.
                 if not avail estoq
                 then next.
       
                 disp produ.procod produ.pronom     
                        with frame fprod 1 down centered. pause 0.
                        
                 
                 find distr where distr.etbcod = estab.etbcod and
                                  distr.clacod = vgrupo no-lock no-error.
                 if not avail distr
                 then do: 
                     e = e - (estoq.estatual / vlote).  
                     next.
                 end.
        
                 if estoq.estatual <= 0
                 then vest = 0.
                 else vest = (estoq.estatual / vlote).

                 q = (( e * (distr.proper / 100))).
                 if q < 0
                 then q = 0.
        
             end.    
         end.
     end.
    end.
    
    
    if vprocod <> 0
    then do:
     for each estab where estab.etbcod < 900 and
                         estab.etbcod <> 22 no-lock:
         if {conv_igual.i estab.etbcod} then next.
        
        find distr where distr.etbcod = estab.etbcod and
                         distr.clacod = vgrupo no-lock no-error.
        if not avail distr
        then next.


        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.

        
        if estoq.estatual <= 0
        then vest = 0.
        else vest = (estoq.estatual / vlote).

        q = (( e * (distr.proper / 100))).
        if q < 0
        then q = 0.


        if vest >= q
        then next.
        
        create tt-estab.
        assign tt-estab.etbcod     = estab.etbcod
               tt-estab.estatual   = vest
               tt-estab.qtd-cal   = int(q) 
               tt-estab.saldo      = int(q) - vest
               tt-estab.per-ori    = distr.proper. 
               
                              
     end. 
    
    end.
    else do:
    
        for each estab where estab.etbcod < 900 and
                             estab.etbcod <> 22 no-lock:
            if {conv_igual.i estab.etbcod} then next.
            for each tt-cla:
                for each produ where produ.clacod = tt-cla.clacod no-lock:
            
                    if vfabcod <> 0
                    then if produ.fabcod <> vfabcod then next.
          
                    find distr where distr.etbcod = estab.etbcod and
                                     distr.clacod = vgrupo no-lock no-error.
                    if not avail distr
                    then next.


                    find estoq where estoq.etbcod = estab.etbcod and
                                     estoq.procod = produ.procod 
                                                    no-lock no-error.
                    if not avail estoq 
                    then next.

                    disp produ.procod produ.pronom     
                        with frame fprod1 1 down centered. pause 0.


                    if estoq.estatual <= 0 
                    then vest = 0. 
                    else vest = (estoq.estatual / vlote).

                    q = (( e * (distr.proper / 100))). 
                    if q < 0 
                    then q = 0.

                    if vest >= q 
                    then next.
        
                    find tt-estab where tt-estab.etbcod = estab.etbcod 
                            no-error. 
                    if not avail tt-estab 
                    then do:
                        create tt-estab.
                        assign tt-estab.etbcod = estab.etbcod. 
                    end. 
                    assign tt-estab.estatual  = tt-estab.estatual + vest
                           tt-estab.qtd-cal   = tt-estab.qtd-cal  + int(q) 
                           tt-estab.saldo  = tt-estab.saldo + (int(q) - vest)
                           tt-estab.per-ori   = distr.proper. 
                end.  
         end.                     
     end. 
    
    end.
    
    hide frame fprod  no-pause.
    hide frame fprod1 no-pause.
    
    v-full  = 0. 
    v-empty = vqtd. 
    v-per   = 0.

    e = vqtd.
    for each tt-estab.
    
        v-per = v-per + tt-estab.per-ori.
        e = e + tt-estab.estatual.
        
    end.
    
    display e label "Estoque Geral" with frame f1.

                         
    for each tt-estab:

         tt-estab.per-cal = ((tt-estab.per-ori * 100) / v-per).
        
         q = (( e * (tt-estab.per-cal / 100))).

         assign tt-estab.qtd-cal   = int(q) 
                tt-estab.saldo     = int(q) - tt-estab.estatual.
                
         assign tt-estab.crijaime = tt-estab.saldo * tt-estab.per-cal.
    
    end.                   


    for each tt-estab where tt-estab.saldo > 0
                      by tt-estab.crijaime desc
                      by tt-estab.per-ori  desc 
                      by tt-estab.saldo  desc
                      by tt-estab.estatual:

            
                    
        if tt-estab.estatual < tt-estab.qtd-cal and v-empty > 0
        then do:

            if v-empty < (tt-estab.qtd-cal - tt-estab.estatual)
            then do:

                tt-estab.qtd-dis = v-empty.
                v-full = v-full + v-empty.
                v-empty = 0.
                
            end.
            else do:
    
                tt-estab.qtd-dis = tt-estab.qtd-cal - tt-estab.estatual.
                v-empty = v-empty - tt-estab.qtd-dis.
                    /* (tt-estab.qtd-cal - tt-estab.estatual). */ 
                v-full  = v-full + tt-estab.qtd-dis.
                    /* (tt-estab.qtd-cal - tt-estab.estatual). */
            end.
        
        end.

        
        /*disp tt-estab.etbcod   column-label "Filial"     format ">>9"
             tt-estab.estatual(total)  
                column-label "Estoque"    format ">>>>9.99" 
             tt-estab.qtd-cal(total)
                  column-label "Calculado"  format ">>>9.99"
             tt-estab.qtd-dis(total)   
                column-label "Enviado"    format ">>>9.99"
             tt-estab.saldo(total)
                 column-label "Dif"        format "->>9.99"
             tt-estab.per-ori(total) column-label "1§ Per"     format ">>9.99"
             tt-estab.per-cal(total) column-label "2§ Per"     format ">>9.99"
             tt-estab.crijaime(total) column-label "Crit"      format "->>9.99"
             /* v-full                                      format ">>>9.99"
             v-empty                                     format ">>>9.99" */
              with frame f-disp centered down.*/
              
    end.
    
       
    if v-empty > 0
    then do:
        
        for each tt-estab by tt-estab.saldo  desc
                          by tt-estab.per-ori desc
                          by tt-estab.estatual:


            
            
            tt-estab.qtd-dis = tt-estab.qtd-dis + 1.
            
            v-empty = v-empty  - 1.
            v-full  = v-full + 1.
        
            /*
            disp tt-estab.etbcod   column-label "Filial"     format ">>9"
                 tt-estab.estatual column-label "Estoque" format ">>>>9.99"
                 tt-estab.qtd-cal  column-label "Calculado"  format ">>>9.99"
                 tt-estab.qtd-dis   column-label "Enviado"    format ">>>9.99"
                 tt-estab.saldo    column-label "Dif"      format "->>9.99"
                 tt-estab.per-ori(total) column-label "1§ Per" format ">>9.99"
             tt-estab.per-cal(total) column-label "2§ Per"     format ">>9.99"
                 v-full                                      format ">>>9.99"
                 v-empty                                     format ">>>9.99"
                    with frame f-disp1 centered down.
            */
            
            if v-empty = 0
            then do:
                pause.
                leave.

            end.    
    
        end.
    end.    
    hide frame f4 no-pause.
    hide frame f3 no-pause.
    hide frame f2 no-pause.
    run disdep7a.p(input vprocod).      
    
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
