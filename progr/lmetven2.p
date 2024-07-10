{admcab.i}

def var vtiporel as log format "Analitico/Sintetico".

def var vclacod like clase.clacod.
def buffer xclase for clase.
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.

def var v-opcao as char format "x(20)" extent 2 initial
    [" 1. Tela/Impressora "," 2. Excel "].



def temp-table tt-cla
    field clacod like clase.clacod
    field clanom like clase.clanom
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


def var vsinal  as char.
def var totcomi like plani.platot.
def var totrepo like plani.platot.
def var totven  like plani.platot.
def var vfer    as int.
def var vdia    as int.
def var vv      as date.
def var xx as int.
def var varquivo as char.
def var tipo as int format "99".
def buffer bcontnf for contnf.
def buffer xplani for plani.
def var vvltotal    like contrato.vltotal.
def var vdtini      like plani.pladat.
def var vok         as log initial yes.
def var vdtfin      like plani.pladat.
def var vtotcom     as dec.
def var vtipo       as char             format "x(11)".
def var vtprcod     like comis.tprcod.
def var vvencod     like func.funcod label "Vendedor".
def var vdomfer     as integer  label "Dom/Fer".
def var vdiatra     as integer  label "Dias Trab.".
def var vdt         as date.
def var vcatcod     as int.
def var vtotal      like plani.platot.
def var vetbcod like estab.etbcod.
def var vforcod like forne.forcod.

def temp-table tt-num
    field etbcod like estab.etbcod
    field numven as int.

def temp-table tt-ven
    field etbcod like plani.etbcod
    field vencod like plani.vencod
    field venda  like plani.platot.

def temp-table tt-sint
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field dias-uteis as int
    field dias as int
    field venda like plani.platot
    field previsto like plani.platot
    field perc as dec format ">>>9.99 %"
    field metval like metven.metval
    field numven as int
    index ietbcod is primary unique etbcod.

repeat:
    for each tt-sint. delete tt-sint. end.
    for each tt-ven:
        delete tt-ven.
    end.
    for each tt-num:
        delete tt-num.
    end.

    vetbcod = 0.
    update vetbcod label "Filial" colon 20
           with frame f1 side-label width 80.

    if vetbcod = 0
    then do:
            repeat on endkey undo, leave with frame f-browse: 
               
               assign ietbcod:visible = no. 
               
               if  keyfunction(lastkey) = "copy"
               then do:
                       status input "Selecione tecle barra de espaco para apaga~r e <F1>".                         update bbrowse with frame f-browse.
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
     
    
    do on error undo:    
        vforcod = 0.
        update vforcod label "Fornecedor" colon 20 with frame f1.
        find forne where forne.forcod = vforcod no-lock no-error.
        if avail forne
        then display forne.fornom no-label with frame f1.
        else do:
            message "Fornecedor nao cadastrado.".
            undo.
        end.
    end.
    
    do on error undo:
        
        for each tt-cla. delete tt-cla. end.

        update vclacod colon 20
               with frame f1.

        find xclase where xclase.clacod = vclacod  no-lock no-error.
        disp xclase.clanom no-label with frame f1.
    
        /******/
        if vclacod <> 0
        then do:
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
                assign tt-cla.clacod = clase.clacod
                       tt-cla.clanom = clase.clanom.

            end.
        end.
        /******/

    end.
        
    if vetbcod = 0
    then display "Meta Geral" @ metven.metval with frame f1.
    else do:
        find last metven where metven.etbcod = vetbcod and
                               metven.forcod = vforcod no-lock no-error.
        if not avail metven
        then do:
            message "Meta nao Cadastrada".
            undo, retry.
        end.
        display metven.metval colon 20 with frame f1.
    end.
            

    update vdtini colon 20 label "Data Inicial"
           vdtfin colon 45 label "Data Final" with frame f1.
    
    update vtiporel no-label 
           help "[A] Analitico   [S] Sintetico "
           with frame f1.
    
    if vetbcod = 0
    then do:
    
    for each produ where produ.fabcod = vforcod no-lock, 
        each tt-browse no-lock,
        each estab where estab.etbcod = tt-browse.etbcod no-lock,
        each movim where movim.etbcod = estab.etbcod and
                         movim.movtdc = 05           and
                         movim.procod = produ.procod and 
                         movim.movdat >= vdtini      and
                         movim.movdat <= vdtfin no-lock:
                         
        if vclacod <> 0
        then do:
            find first tt-cla where
                       tt-cla.clacod = produ.clacod no-lock no-error.
            if not avail tt-cla
            then next.
        end.
            
        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.movtdc = movim.movtdc and
                               plani.pladat = movim.movdat no-lock no-error.
        if not avail plani
        then next.
                                        
        display estab.etbcod
                movim.movdat
                produ.procod with 1 down centered. pause 0.
        
        find func where func.etbcod = plani.etbcod and
                        func.funcod = plani.vencod no-lock no-error.
        if not avail func
        then next.
                        
        
        find first tt-ven where tt-ven.etbcod = movim.etbcod and
                                tt-ven.vencod = plani.vencod no-error.
                                
        if not avail tt-ven
        then do:
            create tt-ven.
            assign tt-ven.etbcod = movim.etbcod 
                   tt-ven.vencod = plani.vencod.
        end.
        assign tt-ven.venda = tt-ven.venda + (movim.movqtm * movim.movpc).
        
    end.



    end.
    else do:
    
    for each produ where produ.fabcod = vforcod no-lock, 
        each estab where estab.etbcod = vetbcod no-lock,
        each movim where movim.etbcod = estab.etbcod and
                         movim.movtdc = 05           and
                         movim.procod = produ.procod and 
                         movim.movdat >= vdtini      and
                         movim.movdat <= vdtfin no-lock:
                         
        if vclacod <> 0
        then do:
            find first tt-cla where
                       tt-cla.clacod = produ.clacod no-lock no-error.
            if not avail tt-cla
            then next.
        end.
            
        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.movtdc = movim.movtdc and
                               plani.pladat = movim.movdat no-lock no-error.
        if not avail plani
        then next.
                                        
        display estab.etbcod
                movim.movdat
                produ.procod 
                produ.clacod with 1 down centered. pause 0.
        
        find func where func.etbcod = plani.etbcod and
                        func.funcod = plani.vencod no-lock no-error.
        if not avail func
        then next.
                        
        
        find first tt-ven where tt-ven.etbcod = movim.etbcod and
                                tt-ven.vencod = plani.vencod no-error.
                                
        if not avail tt-ven
        then do:
            create tt-ven.
            assign tt-ven.etbcod = movim.etbcod 
                   tt-ven.vencod = plani.vencod.
        end.
        assign tt-ven.venda = tt-ven.venda + (movim.movqtm * movim.movpc).
        
    end.
   end.
   
   for each tt-ven:
                          
        find func where func.etbcod = tt-ven.etbcod and
                        func.funcod = tt-ven.vencod no-lock no-error.
        if func.funsit = no
        then do:
            delete tt-ven.
            next.
        end.
        
        if tt-ven.venda < 1
        then do:
            delete tt-ven.
            next.
        end.
        find first tt-num where tt-num.etbcod = tt-ven.etbcod no-error.
        if not avail tt-num
        then do:
            create tt-num.
            assign tt-num.etbcod = tt-ven.etbcod.
        end.
        assign tt-num.numven = tt-num.numven + 1.
   end.


IF VTIPOREL
THEN DO:
   /*Analitico*/ 
   for each tt-ven break by tt-ven.etbcod 
                         by tt-ven.vencod:
                          
        find func where func.etbcod = tt-ven.etbcod and
                        func.funcod = tt-ven.vencod no-lock no-error.
        
        find last metven where metven.etbcod = tt-ven.etbcod and
                               metven.forcod = forne.forcod no-lock no-error.

        if avail metven
        then do:
            xx   = 0.
            vfer = 0. 
            vdia = 0. 
            do vv = vdtini to vdtfin:
                if weekday(vv) = 1
                then xx = xx + 1.
                find dtextra where dtextra.exdata  = vv no-error.
                if avail dtextra
                then vfer = vfer + 1.
                find dtesp where dtesp.datesp = vv and
                                 dtesp.etbcod = tt-ven.etbcod no-lock no-error.
                if avail dtesp
                then vfer = vfer + 1.
            end.
        
            vdia = int(day(vdtfin)) - xx - vfer.

        
            find first duplic where duplic.duppc = month(vdtfin) and
                                    duplic.fatnum = tt-ven.etbcod 
                                            no-lock no-error.
                                
            if first-of(tt-ven.etbcod)
            then display tt-ven.etbcod  column-label "Fil"
                         duplic.dupdia  column-label "Dias!Uteis" 
                                     format ">>>>9"
                         vdia column-label "Dias" format ">>>9" 
                                    with frame fcom.

           display tt-ven.vencod column-label "Cod"
                    func.funnom format "x(15)" when avail func
                    tt-ven.venda(total by tt-ven.etbcod) column-label "Venda" 
                    ( ( (metven.metval / tt-num.numven) / duplic.dupdia) * vdia)
                            column-label "Previsto" when avail duplic
                    /******
                    ( ( tt-ven.venda /
                      ( ( (metven.metval / tt-num.numven) / duplic.dupdia) 
                      * vdia) ) * 100) 
                    *******/   

                         /*venda / previsto - 1 * 100*/
                         (((tt-ven.venda / (((metven.metval / tt-num.numven) 
                                            / duplic.dupdia) * vdia))
                            - 1) * 100)
                      
                      
                      column-label "Perc." format "->>>9.99"
                                with frame fcom centered down
                                        color white/red width 80 row 9.
        end.
    end.

END.
ELSE DO:
    /*Sintetico*/
    
   for each tt-ven break by tt-ven.etbcod 
                         by tt-ven.vencod:
                          
        find func where func.etbcod = tt-ven.etbcod and
                        func.funcod = tt-ven.vencod no-lock no-error.
        
        find last metven where metven.etbcod = tt-ven.etbcod and
                               metven.forcod = forne.forcod  no-lock no-error.

        if avail metven
        then do:
            xx   = 0.
            vfer = 0. 
            vdia = 0. 
            do vv = vdtini to vdtfin:
                if weekday(vv) = 1
                then xx = xx + 1.
                find dtextra where dtextra.exdata  = vv no-error.
                if avail dtextra
                then vfer = vfer + 1.
                find dtesp where dtesp.datesp = vv and
                                 dtesp.etbcod = tt-ven.etbcod no-lock no-error.
                if avail dtesp
                then vfer = vfer + 1.
            end.
        
            vdia = int(day(vdtfin)) - xx - vfer.

        
            find first duplic where duplic.duppc = month(vdtfin) and
                                    duplic.fatnum = tt-ven.etbcod 
                                            no-lock no-error.
                                
            find tt-sint where tt-sint.etbcod = tt-ven.etbcod no-error.
            if not avail tt-sint
            then do:
                find estab where
                     estab.etbcod = tt-ven.etbcod no-lock no-error.
                     
                create tt-sint.
                assign tt-sint.etbcod     = tt-ven.etbcod
                       tt-sint.etbnom     = estab.etbnom
                       tt-sint.dias-uteis = duplic.dupdia
                       tt-sint.dias        = vdia
                       tt-sint.venda      = tt-ven.venda
                       tt-sint.metval     = metven.metval
                       tt-sint.numven     = tt-num.numven
                       tt-sint.previsto   = (((metven.metval 
                                        /*/ tt-num.numven */ )
                                          / duplic.dupdia) * vdia).
            end.
            else tt-sint.venda = tt-sint.venda + tt-ven.venda.
            
        end.
    end.
    
    for each tt-sint:

        find first duplic where 
                   duplic.duppc = month(vdtfin) and 
                   duplic.fatnum = tt-sint.etbcod no-lock no-error.
        tt-sint.perc =

                         /*venda / previsto - 1 * 100*/
                         (((tt-sint.venda / (((metven.metval / tt-num.numven) 
                                            / duplic.dupdia) * tt-sint.dias))
                            - 1) * 100).
        
        
        /*******
        ((tt-sint.venda / (((tt-sint.metval /* / tt-sint.numven*/) / duplic.dupdia) 
                      * tt-sint.dias) ) * 100).
        **********/                      
    end.

    for each tt-sint break by tt-sint.etbcod:
        disp tt-sint.etbcod     column-label "Cod" format ">>9"
             tt-sint.etbnom     column-label "Filial"
             tt-sint.dias-uteis column-label "Dias!Uteis" format ">>>>9"
             tt-sint.dias       column-label "Dias" format ">>>9"
             tt-sint.venda      column-label "Venda"
             tt-sint.previsto   column-label "Previsto"
             tt-sint.perc       column-label "Perc."
             with frame fcom-sint centered down color white/red
                                  width 80 row 9.
    end.

END.

    sresp = no.
    message "Deseja Imprimir o Relatorio ?" update sresp.
    if sresp
    then do:
    
        
      disp skip(1) space(2)
           v-opcao[1] space(2) skip space(2)
           v-opcao[2] space(2)
           skip(1)
           with frame f-opcao centered row 8 no-label color white/red.

      choose field v-opcao auto-return with frame f-opcao.
      hide frame f-opcao no-pause.
        
      if frame-index = 1 /*inicio impressao*/
      then do:
        
        if opsys = "UNIX"
        then varquivo = "../relat/nef" + string(time).
        else varquivo = "..\relat\nef" + string(time).

        {mdad.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "135"
                &Page-Line = "66"
                &Nom-Rel   = ""lmetven2""
                &Nom-Sis   = """SISTEMA DE COMISSAO"""
                &Tit-Rel   = """LISTAGEM DE META DE VENDA "" 
                           + string(vdtini) + "" A "" + string(vdtfin) 
                           + "" "" + string(forne.fornom) "
                &Width     = "135"
                &Form      = "frame f-cabcab"}

        IF VTIPOREL
        THEN DO:
    
            /*ANALITICO*/
        
            for each tt-ven break by tt-ven.etbcod 
                                  by tt-ven.vencod:
                          
                find func where func.etbcod = tt-ven.etbcod and
                                func.funcod = tt-ven.vencod no-lock no-error.
        
                find last metven where metven.etbcod = tt-ven.etbcod and
                                       metven.forcod = forne.forcod 
                                                no-lock no-error.

                if avail metven
                then do:
                    xx   = 0.
                    vfer = 0. 
                    vdia = 0. 
                    do vv = vdtini to vdtfin:
                        if weekday(vv) = 1
                        then xx = xx + 1.
                        find dtextra where dtextra.exdata  = vv no-error.
                        if avail dtextra
                        then vfer = vfer + 1.
                        find dtesp where dtesp.datesp = vv and
                                         dtesp.etbcod = tt-ven.etbcod 
                                                 no-lock no-error.
                        if avail dtesp
                        then vfer = vfer + 1.
                    end.    
                        
                    vdia = int(day(vdtfin)) - xx - vfer.
        
            
                    find first duplic where duplic.duppc = month(vdtfin) and
                                            duplic.fatnum = tt-ven.etbcod 
                                                        no-lock no-error.
                                
                    if first-of(tt-ven.etbcod)
                    then display tt-ven.etbcod  column-label "Fil"
                                 duplic.dupdia  column-label "Dias!Uteis" 
                                                                 format ">>>>9"
                                 vdia column-label "Dias" format ">>>9"
                                                 with frame fcom1.
                    find first tt-num where tt-num.etbcod = tt-ven.etbcod.
 
                    if  ( ( tt-ven.venda /
                          ( ( (metven.metval / tt-num.numven) / duplic.dupdia) 
                             * vdia) ) * 100) >= 100
                    then vsinal = "  +  ".
                    else vsinal = "     ".
                 
                
                    display tt-ven.vencod column-label "Cod"
                            func.funnom format "x(15)" when avail func
                            tt-ven.venda(total by tt-ven.etbcod) 
                                    column-label "Venda" 
                        ( ( (metven.metval / tt-num.numven) / duplic.dupdia) 
                            * vdia) column-label "Previsto" when avail duplic
                         
                         /************
                            ( ( tt-ven.venda /
                          ( ( (metven.metval / tt-num.numven) / duplic.dupdia) 
                         * vdia) ) * 100) 
                         *****/
                         /*venda / previsto - 1 * 100*/
                         (((tt-ven.venda / (((metven.metval / tt-num.numven) 
                                            / duplic.dupdia) * vdia))
                            - 1) * 100)
                         
                         column-label "Perc." format "->>>9.99"
                            vsinal no-label
                                       with frame fcom1 centered down
                                                color white/red width 200.
                end.
            end.
        
        END.
        ELSE DO:
            /*SINTETICO*/
            
            for each tt-sint break by tt-sint.etbcod:

                disp tt-sint.etbcod     column-label "Cod" format ">>9"
                     tt-sint.etbnom     column-label "Filial"
                 tt-sint.dias-uteis column-label "Dias!Uteis" format ">>>>9"
                     tt-sint.dias       column-label "Dias" format ">>>9"
                     tt-sint.venda      column-label "Venda"
                     tt-sint.previsto   column-label "Previsto"
                     tt-sint.perc       column-label "Perc."
                     with frame fcom-sint1 centered down color white/red
                                          width 80 row 9.

            end.
            
        END.            
        
        if opsys <> "UNIX"
        then do:
            {mrod.i}
        end.
        else do:
            output close.
            run visurel.p(input varquivo , input "")).
        end.

      end. /*final impressao*/
      else do: /*inicio excel*/
      

        run p-excel.
        

      end. /*final excel*/
      
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




procedure p-excel:

    if opsys = "UNIX"
    then assign
            varquivo = "/admcom/relat/lmetven2.csv".
    else assign
            varquivo = "l:\relat\lmetven2.csv".

    output to value(varquivo) page-size 0.

    
       IF VTIPOREL
       THEN DO:
    
            /*ANALITICO*/
            
            put "Codigo;Vendedor;Filial;Dias Uteis;Dias;Venda;Previsto;Perc." skip.

        
            for each tt-ven break by tt-ven.etbcod 
                                  by tt-ven.vencod:
                          
                find func where func.etbcod = tt-ven.etbcod and
                                func.funcod = tt-ven.vencod no-lock no-error.
        
                find last metven where metven.etbcod = tt-ven.etbcod and
                                       metven.forcod = forne.forcod 
                                                no-lock no-error.

                if avail metven
                then do:
                    xx   = 0.
                    vfer = 0. 
                    vdia = 0. 
                    do vv = vdtini to vdtfin:
                        if weekday(vv) = 1
                        then xx = xx + 1.
                        find dtextra where dtextra.exdata  = vv no-error.
                        if avail dtextra
                        then vfer = vfer + 1.
                        find dtesp where dtesp.datesp = vv and
                                         dtesp.etbcod = tt-ven.etbcod 
                                                 no-lock no-error.
                        if avail dtesp
                        then vfer = vfer + 1.
                    end.    
                        
                    vdia = int(day(vdtfin)) - xx - vfer.
        
            
                    find first duplic where duplic.duppc = month(vdtfin) and
                                            duplic.fatnum = tt-ven.etbcod 
                                                        no-lock no-error.
                                
                    find first tt-num where tt-num.etbcod = tt-ven.etbcod.
 
                
                    display 
                            tt-ven.vencod column-label "Codigo" ";"
                            func.funnom format "x(15)" when avail func 
                                    column-label "Vendedor"
                            ";"


                            tt-ven.etbcod  column-label "Filial" ";"
                                 duplic.dupdia  column-label "Dias Uteis" 
                                                                 format ">>>>9"
                                 ";"
                                 vdia column-label "Dias" format ">>>9"
                            ";"

                            
                            tt-ven.venda  column-label "Venda" ";"
                        ( ( (metven.metval / tt-num.numven) / duplic.dupdia) 
                            * vdia) column-label "Previsto" when avail duplic
                            ";"
                          /*********************
                            ( ( tt-ven.venda /
                          ( ( (metven.metval / tt-num.numven) / duplic.dupdia) 
                         * vdia) ) * 100) 
                         ******************/
                         
                         /*venda / previsto - 1 * 100*/
                         (((tt-ven.venda / (((metven.metval / tt-num.numven) 
                                            / duplic.dupdia) * vdia))
                            - 1) * 100)

                         
                         
                         column-label "Perc." format "->>>9.99"
                                       
                                       with frame fcom1e centered down
                                                color white/red width 200
                                                no-labels.
                end.
            end.
        
       END.
       ELSE DO:
            /*SINTETICO*/
            
            put "Codigo;Filial;Dias Uteis;Dias;Venda;Previsto;Perc." skip.
            
            for each tt-sint break by tt-sint.etbcod:

                disp
                    tt-sint.etbcod     column-label "Codigo" format ">>9" ";"
                    tt-sint.etbnom     column-label "Filial"           ";"
                    tt-sint.dias-uteis column-label "Dias Uteis" format ">>>>9"
                     ";"
                     tt-sint.dias       column-label "Dias" format ">>>9"
                     ";"
                     tt-sint.venda      column-label "Venda"
                     ";"
                     tt-sint.previsto   column-label "Previsto"
                     ";"
                     tt-sint.perc       column-label "Perc."
                     
                     with frame fcom-sint1e centered down color white/red
                                          width 200 row 9 no-labels.

            end.
            
       END.            
        
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(input varquivo, input "").
    end.
    else do:
        os-command silent start value(varquivo).
    end.        
end.

