{admcab.i}

def buffer bclase for clase.
def var vpre as dec.
def var vclacod like clase.clacod.
def buffer xclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.

def temp-table tcla
    field clacod like clase.clacod
    field pre    like plani.platot
    index icla is primary unique clacod.

def temp-table ttclase
    field clacod like clase.clacod
    field clanom like clase.clanom
    field pre    like plani.platot
    index iclase is primary unique clacod.

def temp-table tt-browse
    field marca  as    char form "x(1)" column-label "Marca"
    field etbcod like estab.etbcod      column-label "Estabelecimento"
    index ch-etbcod   etbcod.

def query qbrowse for tt-browse
    fields(tt-browse.marca tt-browse.etbcod).

def browse bbrowse query qbrowse no-lock
    display tt-browse.marca  
            tt-browse.etbcod 
    enable  tt-browse.marca 
    with width 25 3 down no-row-markers.

def var ietbcod  like estab.etbcod.

def frame f-browse
    ietbcod label "Estabelecimento "
    skip
    bbrowse                                          at 25
    "<Insert - Inclui>"                              at 01
    "<F11 - Exclui>"                                 at 20
    "<F12 - Todos>"                                  at 36
    "<F1 - Atualiza>"                                at 51
    "<F4 - Sair>"                                    at 68 
    with side-labels width 80 col 1 row 10. 

def var vclasup1 like clase.clasup.
def var vclasup2 like clase.clasup.
def var vpremio like movim.movpc.
def var vacr    as log format "Sim/Nao".
def var totqtd like movim.movqtm.
def var totval like movim.movpc.

def var vven like plani.platot.

def var vtipo as char format "x(10)" extent 3
        initial["Sintetico","Analitico","Vendedor"].
        
def var totven like plani.platot.

def var vresp as l format "C/R" initial yes.

def var varquivo as char format "x(20)".

def var vesc as char format "x(10)" extent 3 
            initial["Fornecedor","Produto","Classe"].
            
def var vprocod   like produ.procod.
def var vetbcod   like estab.etbcod.
def var vfuncod   like func.funcod.
def var vmovqtm   like movim.movqtm.
def var vfunc     like titulo.titvlcob.
def var vdti      like plani.pladat.
def var vdtf      like plani.pladat.
def var vforcod   like forne.forcod.
def var vtotal like plani.platot.
def var vqtd   like movim.movqtm.

def temp-table tt-produ
    field procod like produ.procod
    field pre    like plani.platot.
    
def temp-table tt-venda
    field etbcod like estab.etbcod
    field funcod like func.funcod
    field procod like produ.procod
    field pronom like produ.pronom
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    field numero like plani.numero
    field movdat like movim.movdat
    field clasup like clase.clasup.

def temp-table tt-cla
    field clacod like clase.clasup
    field qtd    as int
    field ven like plani.platot
    field pre like plani.platot.
    
def temp-table tt-clase
    field clacod like clase.clacod
    field clasup like clase.clasup.

repeat:

    for each ttclase. delete ttclase. end.
    
    assign vmovqtm = 0 vtotal = 0 vqtd = 0  vprocod = 0  vforcod = 0.
    
    for each tt-venda:
        delete tt-venda.
    end.
    
    for each tt-produ:
        delete tt-produ.
    end.
    
    for each tcla. delete tcla. end.
    
    for each tt-clase:
        delete tt-clase.
    end.

    for each tt-browse:
        delete tt-browse.
    end.    
   
    update vetbcod colon 18 with frame f1 centered side-label
                   color blue/cyan row 4 width 80.
    /*
    if vetbcod = 0
    then display "geral" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message  "Estabelecimento nao cadastrado".
            undo.
        end.
        disp estab.etbnom no-label with frame f1.
    end.
    */
    if vetbcod = 0
    then do:
            repeat on endkey undo, leave with frame f-browse: 
               
               assign ietbcod:visible = no. 
               
               if  keyfunction(lastkey) = "copy"
               then do:
                       status input "Selecione tecle barra de espaco para apagar e <F1>".                         update bbrowse with frame f-browse.
                       for each tt-browse where
                                tt-browse.marca = "":
                                 delete tt-browse.
                       end.
                       open query qbrowse for each tt-browse.
                       disp bbrowse with frame f-browse.
               end.
               if  keyfunction(lastkey) = "insert-mode"
               then do:
                        assign ietbcod = 0.
                        assign ietbcod:visible = yes. 
                        update ietbcod with frame f-browse.
                        if ietbcod = 0
                        then do:
                                leave.
                        end.        
                        create tt-browse.
                        assign tt-browse.etbcod = ietbcod
                               tt-browse.marca  = "*".
                        open query qbrowse for each tt-browse.
                        disp bbrowse with frame f-browse.
                        assign ietbcod:visible = no.
               end.
               if keyfunction(lastkey) = "end-error"
               then leave.
               if keyfunction(lastkey) = "paste"
               then do:
                       for each estab no-lock:
                           find first tt-browse where
                                      tt-browse.etbcod = estab.etbcod
                                      exclusive-lock no-error.
                           if not avail tt-browse
                           then do:           
                                   create tt-browse.
                                   assign tt-browse.marca = "*"
                                          tt-browse.etbcod = estab.etbcod.
                                   open query qbrowse for each tt-browse.
                                   assign ietbcod:visible = no.
                           end.
                       end.
                       update bbrowse with frame f-browse.
               end.
               disp bbrowse with frame f-browse.
            
            end.
    end.
    hide frame f-browse.
    
    if vetbcod = 0
    then do:
             find first tt-browse no-lock no-error.
             if not avail tt-browse
             then do:
                     message "Nenhum estabelecimento foi selecionado!"
                             view-as alert-box.
                     undo, retry.         
             end.
             else do:
                     if can-find(tt-browse where tt-browse.etbcod = 0)
                     then do:
                             for each tt-browse where
                                      tt-browse.etbcod = 0 exclusive-lock:
                                 delete tt-browse.
                             end.             
                     end.                 
             end.
    end.
    
    vacr = no.
    update vacr label "Val. C/ Acrescimo" colon 18 with frame f1.

    update vfuncod label "Vendedor" colon 18 with frame f1.

    if vfuncod = 0
    then display "TODOS VENDEDORES" @ func.funnom with frame f1.
    else do:
        find first tt-browse no-lock no-error.
        if not avail tt-browse
        then do:
                find func where func.funcod = vfuncod and
                                func.etbcod = vetbcod no-lock no-error.
                disp func.funnom when avail func no-label with frame f1.
        end.        
    end.
    
    update vdti label "Dt.Inicial" colon 18
           vdtf label "Dt.Final" with frame f1.

    display vesc with frame f-e side-label no-label.
    choose field vesc with frame f-e.
    if frame-index = 1
    then do:
    
        update vforcod label "Fornecedor" 
                    with frame f12 side-label.
        find forne where forne.forcod = vforcod no-lock.
        disp forne.forfant no-label format "x(25)" 
            with frame f12 column 25 width 50.
        pause 0 no-message.
        repeat:        
            update vclacod at 01 label "Classe" 
            help "Informe o codigo de uma ou mais Classe - F4 para Continuar"
                   with frame f12 side-label.

            if vclacod <> 0
            then do:
                find xclase where xclase.clacod = vclacod no-lock no-error.
                display xclase.clanom no-label with frame f12.
            end.
            else disp "Todas" @ xclase.clanom with frame f12.
                             pause 0.
 
            find tcla where tcla.clacod = vclacod no-error.
            if not avail tcla
            then do:
                create tcla.
                assign tcla.clacod = vclacod
                       tcla.pre    = vpremio.
            end.
                
        end.

        
        for each tcla no-lock.
            vclacod = tcla.clacod.

            find first clase where clase.clasup = vclacod no-lock no-error. 
            if avail clase 
            then do: 
                        
                run cria-ttclase.  
                hide message no-pause. 
                
            end. 
            else do:
                find clase where clase.clacod = vclacod no-lock no-error. 
                if not avail clase 
                then do: 
                    message "Classe nao Cadastrada". 
                    undo. 
                end. 
        
                create ttclase. 
                assign ttclase.clacod = clase.clacod 
                       ttclase.clanom = clase.clanom
                       ttclase.pre    = tcla.pre.

            end.
    
                                        
        end. 
    end.
    if frame-index = 2
    then do:
        repeat:
            update vprocod label "Produto" with frame f13 side-label.
            find produ where produ.procod = vprocod no-lock.
            disp produ.pronom no-label format "x(25)"
                    with frame f13 column 25 width 50.
                
            vpremio = 0.
            update vpremio label "Premio" with frame f13.
            
            find first tt-produ where tt-produ.procod = produ.procod no-error.
            if not avail tt-produ
            then do:
                create tt-produ.
                assign tt-produ.procod = produ.procod
                       tt-produ.pre    = vpremio.
            end.    
            
        end.        
    end.

    if frame-index = 3
    then do:
        repeat:        
            update vclacod at 01 label "Classe" 
            help "Informe o codigo de uma ou mais Classe - F4 para Continuar"
                   with frame f-dat side-label.

            if vclacod <> 0
            then do:
                find xclase where xclase.clacod = vclacod no-lock no-error.
                display xclase.clanom no-label with frame f-dat.
            end.
            else disp "Todas" @ xclase.clanom with frame f-dat.
                             pause 0.
 
            vpremio = 0.
            update vpremio label "Premio" with frame f-dat.
             
            find tcla where tcla.clacod = vclacod no-error.
            if not avail tcla
            then do:
                create tcla.
                assign tcla.clacod = vclacod
                       tcla.pre    = vpremio.
            end.
                
        end.

        
        for each tcla no-lock.
            vclacod = tcla.clacod.

            find first clase where clase.clasup = vclacod no-lock no-error. 
            if avail clase 
            then do: 
                        
                run cria-ttclase.  
                hide message no-pause. 
                
            end. 
            else do:
                find clase where clase.clacod = vclacod no-lock no-error. 
                if not avail clase 
                then do: 
                    message "Classe nao Cadastrada". 
                    undo. 
                end. 
        
                create ttclase. 
                assign ttclase.clacod = clase.clacod 
                       ttclase.clanom = clase.clanom
                       ttclase.pre    = tcla.pre.

            end.
    
                                        
        end.                                
    
    end.
    if vforcod <> 0
    then do:
        for each produ where produ.fabcod = vforcod no-lock:
            find first ttclase where 
                       ttclase.clacod = produ.clacod
                        no-lock no-error.
           if not avail ttclase 
           then next.            
          if vetbcod = 0
          then do:
          for each tt-browse no-lock:  
            for each estab where 
                     estab.etbcod = tt-browse.etbcod no-lock:
                for each movim where movim.procod = produ.procod and
                                     movim.etbcod = estab.etbcod and
                                     movim.movtdc = 5            and
                                     movim.movdat >= vdti        and
                                     movim.movdat <= vdtf no-lock:
        
                     find plani where plani.movtdc = 5            and
                                      plani.placod = movim.placod and
                                      plani.etbcod = movim.etbcod and
                                      plani.pladat = movim.movdat 
                                          no-lock no-error.
                     if not avail plani
                     then next.

                     if vfuncod <> 0 
                     then do:
                         if plani.vencod <> vfuncod 
                         then next.
                     end.    
                     
                     create tt-venda.
                     assign tt-venda.etbcod = plani.etbcod
                            tt-venda.funcod = plani.vencod
                            tt-venda.procod = produ.procod
                            tt-venda.pronom = produ.pronom
                            tt-venda.movqtm = movim.movqtm
                            tt-venda.movpc  = movim.movpc
                            tt-venda.movdat = movim.movdat
                            tt-venda.numero = plani.numero.
                            
                     if plani.biss > 0 and vacr and
                        (plani.platot - plani.vlserv - 
                         plani.descprod + plani.acfprod) >= 1

                        
                     then tt-venda.movpc = (tt-venda.movpc *
                                            tt-venda.movqtm) * 
                                          (plani.biss / 
                                           ( plani.platot - plani.vlserv - 
                                             plani.descprod + plani.acfprod)) .
                                       
                end.
            end.
          end.
          end.
          else do:
          for each estab where 
                   estab.etbcod = vetbcod no-lock:
              for each movim where movim.procod = produ.procod and
                                   movim.etbcod = estab.etbcod and
                                   movim.movtdc = 5            and
                                   movim.movdat >= vdti        and
                                   movim.movdat <= vdtf no-lock:
       
                   find plani where plani.movtdc = 5            and
                                    plani.placod = movim.placod and
                                    plani.etbcod = movim.etbcod and
                                    plani.pladat = movim.movdat 
                                    no-lock no-error.
                   if not avail plani
                   then next.
                   
                   if vfuncod <> 0 
                   then do: 
                       if plani.vencod <> vfuncod 
                       then next.
                   end.   
                    
                   create tt-venda.
                   assign tt-venda.etbcod = plani.etbcod
                          tt-venda.funcod = plani.vencod
                          tt-venda.procod = produ.procod
                          tt-venda.pronom = produ.pronom
                          tt-venda.movqtm = movim.movqtm
                          tt-venda.movpc  = movim.movpc
                          tt-venda.movdat = movim.movdat
                          tt-venda.numero = plani.numero.
                          
                   if plani.biss > 0 and vacr and
                      (plani.platot - plani.vlserv - 
                       plani.descprod + plani.acfprod) >= 1

                        
                   then tt-venda.movpc = (tt-venda.movpc *
                                          tt-venda.movqtm) * 
                                        (plani.biss / 
                                         ( plani.platot - plani.vlserv - 
                                           plani.descprod + plani.acfprod)) .
                                       
              end.
          end.
          end.
        end.
    end.
    
    if vprocod <> 0
    then do:
        for each tt-produ,
            each produ where produ.procod = tt-produ.procod no-lock:
            
            if vetbcod = 0
            then do:
            for each tt-browse no-lock:
            
            for each estab where 
                     estab.etbcod = tt-browse.etbcod no-lock: 

            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 5            and
                                 movim.etbcod = estab.etbcod and
                                 movim.movdat >= vdti        and
                                 movim.movdat <= vdtf no-lock:
        
                find plani where plani.movtdc = 5            and
                                 plani.placod = movim.placod and
                                 plani.etbcod = movim.etbcod and
                                 plani.pladat = movim.movdat 
                                     no-lock no-error.
                if not avail plani
                then next.
                
                if vfuncod <> 0 
                then do: 
                    if plani.vencod <> vfuncod 
                    then next.
                end.
                
                create tt-venda.
                assign tt-venda.etbcod = plani.etbcod
                       tt-venda.funcod = plani.vencod
                       tt-venda.procod = produ.procod
                       tt-venda.pronom = produ.pronom
                       tt-venda.movqtm = movim.movqtm
                       tt-venda.movpc  = movim.movpc
                       tt-venda.movdat = movim.movdat
                       tt-venda.numero = plani.numero.
                       
                 if plani.biss > 0 and vacr and
                   (plani.platot - plani.vlserv - 
                    plani.descprod + plani.acfprod) >= 1

                 then tt-venda.movpc = (tt-venda.movpc *
                                        tt-venda.movqtm) * 
                                      (plani.biss / 
                                       ( plani.platot - plani.vlserv - 
                                         plani.descprod + plani.acfprod)).
                      
                                   
            end.
            end.
            end.
            end.
            else do:
            for each estab where 
                     estab.etbcod = vetbcod no-lock: 

            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 5            and
                                 movim.etbcod = estab.etbcod and
                                 movim.movdat >= vdti        and
                                 movim.movdat <= vdtf no-lock:
        
                find plani where plani.movtdc = 5            and
                                 plani.placod = movim.placod and
                                 plani.etbcod = movim.etbcod and
                                 plani.pladat = movim.movdat 
                                     no-lock no-error.
                if not avail plani
                then next.
                
                if vfuncod <> 0 
                then do: 
                    if plani.vencod <> vfuncod 
                    then next.
                end.

                create tt-venda.
                assign tt-venda.etbcod = plani.etbcod
                       tt-venda.funcod = plani.vencod
                       tt-venda.procod = produ.procod
                       tt-venda.pronom = produ.pronom
                       tt-venda.movqtm = movim.movqtm
                       tt-venda.movpc  = movim.movpc
                       tt-venda.movdat = movim.movdat
                       tt-venda.numero = plani.numero.
                       
                 if plani.biss > 0 and vacr and
                   (plani.platot - plani.vlserv - 
                    plani.descprod + plani.acfprod) >= 1

                 then tt-venda.movpc = (tt-venda.movpc *
                                        tt-venda.movqtm) * 
                                      (plani.biss / 
                                       ( plani.platot - plani.vlserv - 
                                         plani.descprod + plani.acfprod)).
                      
                                   
            end.
            end.
            end.
        end.
    end.
    
    
    if vclacod <> 0  and vforcod = 0
    then do:
        for each ttclase:
            for each produ where produ.clacod = ttclase.clacod no-lock:
               if vetbcod = 0
               then do:
               for each tt-browse no-lock: 
                for each estab where 
                         estab.etbcod = tt-browse.etbcod no-lock:
                        for each movim where movim.procod = produ.procod and
                                             movim.movtdc = 5            and
                                             movim.etbcod = estab.etbcod and
                                             movim.movdat >= vdti        and
                                             movim.movdat <= vdtf no-lock:
        
                            find plani where plani.movtdc = 5            and
                                             plani.placod = movim.placod and
                                             plani.etbcod = movim.etbcod and
                                             plani.pladat = movim.movdat 
                                                     no-lock no-error.
                            if not avail plani
                            then next.
                            
                            if vfuncod <> 0  
                            then do: 
                                if plani.vencod <> vfuncod 
                                then next.
                            end.
                            
                            create tt-venda.
                            assign tt-venda.etbcod = plani.etbcod
                                   tt-venda.funcod = plani.vencod
                                   tt-venda.procod = produ.procod
                                   tt-venda.pronom = produ.pronom
                                   tt-venda.movqtm = movim.movqtm
                                   tt-venda.movpc  = movim.movpc
                                   tt-venda.movdat = movim.movdat
                                   tt-venda.numero = plani.numero
                                   tt-venda.clasup = produ.clacod.
                       
                       
                            if plani.biss > 0 and vacr and
                              (plani.platot - plani.vlserv - 
                               plani.descprod + plani.acfprod) >= 1
                   
                            then tt-venda.movpc = (tt-venda.movpc *
                                                   tt-venda.movqtm) * 
                                               (plani.biss / 
                                               ( plani.platot - plani.vlserv - 
                                             plani.descprod + plani.acfprod) ).
                         
                        end.
                    end.
                end.
               end.
               else do: 
                for each estab where 
                         estab.etbcod = vetbcod no-lock:

                        for each movim where movim.procod = produ.procod and
                                             movim.movtdc = 5            and
                                             movim.etbcod = estab.etbcod and
                                             movim.movdat >= vdti        and
                                             movim.movdat <= vdtf no-lock:
        
                            find plani where plani.movtdc = 5            and
                                             plani.placod = movim.placod and
                                             plani.etbcod = movim.etbcod and
                                             plani.pladat = movim.movdat 
                                                     no-lock no-error.
                            if not avail plani
                            then next.
                            
                            if vfuncod <> 0  
                            then do: 
                                if plani.vencod <> vfuncod 
                                then next.
                            end.

                            create tt-venda.
                            assign tt-venda.etbcod = plani.etbcod
                                   tt-venda.funcod = plani.vencod
                                   tt-venda.procod = produ.procod
                                   tt-venda.pronom = produ.pronom
                                   tt-venda.movqtm = movim.movqtm
                                   tt-venda.movpc  = movim.movpc
                                   tt-venda.movdat = movim.movdat
                                   tt-venda.numero = plani.numero
                                   tt-venda.clasup = produ.clacod.
                       
                       
                            if plani.biss > 0 and vacr and
                              (plani.platot - plani.vlserv - 
                               plani.descprod + plani.acfprod) >= 1
                   
                            then tt-venda.movpc = (tt-venda.movpc *
                                                   tt-venda.movqtm) * 
                                               (plani.biss / 
                                               ( plani.platot - plani.vlserv - 
                                             plani.descprod + plani.acfprod) ).
                         
                        end.
                    end.
                end.
               end.
        end.
    end.

    display vtipo no-label with frame f-esc side-label centered row 15.
    choose field vtipo with frame f-esc.
    
    if opsys = "UNIX"
    then do:
            assign varquivo = "/admcom/relat/pre" + string(day(today)) + 
                              string(vetbcod,"999").
    end.
    else do:
            assign varquivo = "..\relat\prew" + string(day(today)) + 
                              string(vetbcod,"999").
    end.                          

    {mdad_l.i 
            &Saida     = "value(varquivo)" 
            &Page-Size = "66"
            &Cond-Var  = "120"
            &Page-Line = "66" 
            &Nom-Rel   = ""premio""
            &Nom-Sis   = """SISTEMA DE VENDAS"""
            &Tit-Rel   = """VENDAS -  "" +
                                  string(vetbcod,"">>9"") +
                          "" DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "120"
            &Form      = "frame f-cabcab"}
                       
    if frame-index = 2
    then do:
        for each tt-venda break by  tt-venda.etbcod
                                by  tt-venda.funcod
                                by  tt-venda.pronom
                                by  tt-venda.movdat:

                              
            if first-of(tt-venda.etbcod)
            then do:       
                page.
                find estab where estab.etbcod = tt-venda.etbcod 
                    no-lock no-error.   
                disp estab.etbcod label "Filial"
                     estab.etbnom when avail estab
                    no-label  with frame f-estab side-label.  
            end.                    
                             
                    
            if first-of(tt-venda.funcod)
            then do: 
                find func where func.funcod = tt-venda.funcod and
                                func.etbcod = tt-venda.etbcod no-lock no-error.
                disp tt-venda.funcod label "Vendedor"
                     func.funnom when avail func
                    no-label format "x(20)" with frame f-princ2 side-label.  
            end.            
                    
            assign totqtd = totqtd + tt-venda.movqtm
                   totval = totval + tt-venda.movpc.
            
            if last-of(tt-venda.pronom)
            then do:
                vpremio = 0.
                find first tt-produ where tt-produ.procod = tt-venda.procod
                                            no-error.
                if avail tt-produ
                then vpremio = tt-produ.pre.
 
                if vpremio = 0
                then do:
                    find first ttclase where 
                               ttclase.clacod = tt-venda.clasup no-error.
                    if avail ttclase
                    then vpremio = ttclase.pre.
                end.
                
                if vpremio > 0
                then totval = vpremio * totqtd.

                 
                disp tt-venda.procod
                     tt-venda.pronom format "x(40)"
                     totqtd(total by tt-venda.funcod) 
                            column-label "QTD" format ">>>>>9"
                     totval(total by tt-venda.funcod)  
                            column-label "Valor" format ">>,>>>,>>9.99" 
                                  with frame f-princ down width 200.
                
                assign totqtd = 0 
                       totval = 0.
                
            end.
            
            /*
            if last-of(tt-venda.etbcod)
            then page.
            */
            
        end.
    end.

    if frame-index = 1
    then do:
        for each tt-venda break by  tt-venda.etbcod
                                by  tt-venda.funcod
                                by  tt-venda.procod
                                by  tt-venda.movdat:
                                
            if first-of(tt-venda.etbcod)
            then page.
            
            if first-of(tt-venda.funcod)
            then do:                 
                find func where func.funcod = tt-venda.funcod and
                                func.etbcod = vetbcod no-lock no-error.
                disp func.funnom when avail func
                    no-label format "x(10)" with frame f-princ3.  
            end.    

            assign totqtd = totqtd + tt-venda.movqtm
                   totven = totven + (tt-venda.movpc * tt-venda.movqtm).
            
            if last-of(tt-venda.procod)
            then do:
                find produ where produ.procod = tt-venda.procod no-lock.

                vpremio = 0.
                find first tt-produ where tt-produ.procod = tt-venda.procod
                                            no-error.
                if avail tt-produ
                then vpremio = tt-produ.pre.
 
                if vpremio = 0
                then do:
                    find first ttclase where 
                               ttclase.clacod = tt-venda.clasup no-error.
                    if avail ttclase
                    then vpremio = ttclase.pre.
                end.
                
                if vpremio > 0
                then totven = vpremio * totqtd.
 
                
                disp tt-venda.procod
                     produ.pronom 
                     totqtd(total by tt-venda.funcod)
                                        column-label "Quantidade" 
                                        format ">>>>>>9"
                     totven(total by tt-venda.funcod)
                                        column-label "Valor"
                                        format ">>,>>>,>>9.99"    
                        with frame f-princ3 down width 200.
                
                assign totqtd = 0 
                       totven = 0.
                       
            end.
        end.
    end.

    
    if frame-index = 3 
    then do:
        assign vven = 0 
               vqtd = 0.
               
        for each tt-venda break by tt-venda.etbcod
                                by tt-venda.funcod
                                by tt-venda.procod
                                by tt-venda.movdat:
                                

            if first-of(tt-venda.etbcod)
            then do:
                page.
                display tt-venda.etbcod label "Filial" 
                    with frame f-princ5 side-label.
            end.        
            assign totqtd = totqtd + tt-venda.movqtm
                   totven = totven + (tt-venda.movpc * tt-venda.movqtm)
                   vqtd   = vqtd + tt-venda.movqtm 
                   vven   = vven + (tt-venda.movpc * tt-venda.movqtm).

            if last-of(tt-venda.funcod)
            then do:

                vpremio = 0.
                find first tt-produ where tt-produ.procod = tt-venda.procod
                                            no-error.
                if avail tt-produ
                then vpremio = tt-produ.pre.
 
                if vpremio = 0
                then do:
                    find first ttclase where 
                               ttclase.clacod = tt-venda.clasup no-error.
                    if avail ttclase
                    then vpremio = ttclase.pre.
                end.
 
                if vpremio > 0
                then totven = vpremio * totqtd.
                
                vpre = 0.
                vpre = int((totqtd / 50) - 0.5).
                if vpre < 1
                then vpre = 0.
                
                find func where func.funcod = tt-venda.funcod and
                                func.etbcod = tt-venda.etbcod no-lock no-error.
                disp tt-venda.funcod column-label "Vend"
                     func.funnom when avail func column-label "Nome"
                     totqtd(total by tt-venda.etbcod) column-label "Quantidade"
                            format ">>>>>>9"
                     vpre(total by tt-venda.etbcod) column-label "Premio" 
                     (50 * vpre)(total by tt-venda.etbcod) 
                            column-label "Premio R$" format ">>,>>>,>>9.99"
                   totven(total by tt-venda.etbcod) column-label "Valor" 
                            format ">>,>>>,>>9.99"
                        with frame f-princ51 down width 200.

                assign totqtd = 0
                       totven = 0.
            
            end.
        end.
        
        put skip fill("-",65) format "x(65)" skip
            "TOTAL..............."
            vqtd to 52
            vven to 65 skip
            fill("-",65) format "x(65)".
            
    end.

    
    /****
    if frame-index = 3 and vclasup1 <> 0
    then do:
        vven = 0.
        vqtd = 0.
        for each tt-venda break by tt-venda.etbcod
                                by tt-venda.funcod
                                by tt-venda.clasup:
                                

            
            if first-of(tt-venda.etbcod)
            then do:
                page.
                display tt-venda.etbcod label "Filial" 
                    with frame f-princ44 side-label.
            end.
                    
            totqtd = totqtd + tt-venda.movqtm.
            totven = totven + (tt-venda.movpc * tt-venda.movqtm).

                              
            vqtd = vqtd + tt-venda.movqtm.
            vven = vven + (tt-venda.movpc * tt-venda.movqtm).
            
            find first tt-cla where tt-cla.clacod = tt-venda.clasup no-error.
            if not avail tt-cla
            then do:
                create tt-cla.
                assign tt-cla.clacod = tt-venda.clasup.
            end.
            assign tt-cla.qtd = tt-cla.qtd + tt-venda.movqtm.
                   tt-cla.ven = tt-cla.ven + (tt-venda.movpc * tt-venda.movqtm).

            if last-of(tt-venda.funcod)
            then do:
                find func where func.funcod = tt-venda.funcod and
                                func.etbcod = tt-venda.etbcod no-lock no-error.
                display tt-venda.funcod column-label "Vend"
                        func.funnom when avail func column-label "Nome"
                            with frame f-ven side-label .
                for each tt-cla:
                    find clase where clase.clacod = tt-cla.clacod no-lock.
                    
                    display clase.clanom column-label "Classe"
                            tt-cla.qtd(total) column-label "Qtd"
                            tt-cla.ven(total) column-label "Venda"
                                with frame f-cla down width 200.
                end.
                for each tt-cla:
                    delete tt-cla.
                end.
                                
            
            end.                
            
        end.
    end.
    ***/
                           
    
    output close.
    
    if opsys = "UNIX"
    then do:
            run visurel.p (input varquivo, input "").
    end.
    else do:
            {mrod.i}
    end.

end.


procedure cria-ttclase.

 for each clase where clase.clasup = vclacod no-lock:
   find first bclase where bclase.clasup = clase.clacod no-lock no-error.
   if not avail bclase
   then do: 
     find ttclase where ttclase.clacod = clase.clacod no-error. 
     if not avail ttclase 
     then do: 
       create ttclase. 
       assign ttclase.clacod = clase.clacod 
              ttclase.clanom = clase.clanom
              ttclase.pre    = tcla.pre.
     end.
   end.
   else do: 
     for each bclase where bclase.clasup = clase.clacod no-lock: 
         find first cclase where cclase.clasup = bclase.clacod no-lock no-error.
         if not avail cclase
         then do: 
           find ttclase where ttclase.clacod = bclase.clacod no-error. 
           if not avail ttclase 
           then do: 
             create ttclase. 
             assign ttclase.clacod = bclase.clacod 
                    ttclase.clanom = bclase.clanom
                    ttclase.pre    = tcla.pre.
           end.
         end.
         else do: 
           for each cclase where cclase.clasup = bclase.clacod no-lock: 
             find first dclase where dclase.clasup = cclase.clacod 
                                                     no-lock no-error. 
             if not avail dclase 
             then do: 
               find ttclase where ttclase.clacod = cclase.clacod no-error. 
               if not avail ttclase 
               then do: 
                 create ttclase. 
                 assign ttclase.clacod = cclase.clacod 
                        ttclase.clanom = cclase.clanom
                        ttclase.pre    = tcla.pre.
               end.                          
             end.
             else do: 
               for each dclase where dclase.clasup = cclase.clacod no-lock: 
                 find first eclase where eclase.clasup = dclase.clacod 
                                                         no-lock no-error. 
                 if not avail eclase 
                 then do: 
                   find ttclase where ttclase.clacod = dclase.clacod no-error.
                   if not avail ttclase 
                   then do: 
                     create ttclase. 
                     assign ttclase.clacod = dclase.clacod 
                            ttclase.clanom = dclase.clanom
                            ttclase.pre    = tcla.pre. 
                   end.       
                 end. 
                 else do:  
                   for each eclase where eclase.clasup = dclase.clacod no-lock:
                     find first fclase where fclase.clasup = eclase.clacod 
                                                             no-lock no-error.
                     if not avail fclase 
                     then do: 
                       find ttclase where ttclase.clacod = eclase.clacod
                                                             no-error.
                       if not avail ttclase 
                       then do: 
                         create ttclase. 
                         assign ttclase.clacod = eclase.clacod 
                                ttclase.clanom = eclase.clanom
                                ttclase.pre    = tcla.pre.
                       end.
                     end.
                     else do:
                     
                       for each fclase where fclase.clasup = eclase.clacod
                                    no-lock:
                         find first gclase where gclase.clasup = fclase.clacod 
                                                             no-lock no-error.
                         if not avail gclase 
                         then do: 
                           find ttclase where ttclase.clacod = fclase.clacod
                                                                 no-error.
                           if not avail ttclase 
                           then do: 
                             create ttclase. 
                             assign ttclase.clacod = fclase.clacod 
                                    ttclase.clanom = fclase.clanom
                                    ttclase.pre    = tcla.pre.
                           end.
                         end.
                         else do:
                             find ttclase where ttclase.clacod = gclase.clacod 
                                                        no-error.
                             if not avail ttclase
                             then do:
                                 create ttclase. 
                                 assign ttclase.clacod = gclase.clacod 
                                        ttclase.clanom = gclase.clanom
                                        ttclase.pre    = tcla.pre.
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
