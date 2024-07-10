{admcab.i }
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
def var vtotetb     as dec format "->>>>>>,>>9.99".
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
def var v-valor as dec.
repeat:

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
    then display "Todas as filiais" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.
    vforcod = 5027.
    update vforcod label "Fornecedor" colon 20 with frame f1.
    find forne where forne.forcod = vforcod no-lock no-error.
    display forne.fornom no-label with frame f1.
    
    if vetbcod = 0
    then display "Meta Geral" @ metven.metval with frame f1.
    else do:
        find last metven where metven.etbcod = vetbcod and
                               metven.forcod = vforcod and
                               metven.metano = year(today) 
                                no-lock no-error.
        if not avail metven
        then find last metven where metven.etbcod = vetbcod and
                                   metven.forcod = vforcod 
                                            no-lock no-error.
        if not avail metven
        then do:
            message "Meta nao Cadastrada".
            undo, retry.
        end.
        display metven.metval colon 20 with frame f1.
    end.                        
            

    update vdtini colon 20 label "Data Inicial"
           vdtfin colon 45 label "Data Final" with frame f1.

         
    
    for each produ where produ.fabcod = vforcod no-lock, 
        each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each movim where movim.etbcod = estab.etbcod and
                         movim.movtdc = 05           and
                         movim.procod = produ.procod and 
                         movim.movdat >= vdtini      and
                         movim.movdat <= vdtfin no-lock:

        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.movtdc = movim.movtdc and
                               plani.pladat = movim.movdat no-lock no-error.
        if not avail plani
        then next.
                                        
        display estab.etbcod
                movim.movdat
                produ.procod with frame fx 1 down centered. pause 0.
        
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
        /*
        assign tt-ven.venda = tt-ven.venda + (movim.movqtm * movim.movpc).
        */
        v-valor = 0.
        run calvenda.
        tt-ven.venda = tt-ven.venda + v-valor.
       
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

hide frame fx no-pause.
hide frame f1 no-pause.


/***********
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
                    ( ( tt-ven.venda /
                      ( ( (metven.metval / tt-num.numven) / duplic.dupdia) 
                      * vdia) ) * 100) 
                          column-label "Perc.!Previsto" format "->>>9.99"
                      
                    (( tt-ven.venda / metven.metval) * 100)
                                   column-label "Perc.!NewFree" 
                                   format "->>>9.99"
                                with frame fcom centered down
                                        color white/red width 100 row 9.
        end.
    end.

    sresp = no.
 
    message "Deseja Imprimir o Relatorio ?" update sresp.
    if sresp
    then 
        dO:
         if opsys = "unix"
         then varquivo = "../relat/metven" + string(tt-ven.etbcod) +
                                           string(time).
         else varquivo = "..\relat\metven" + string(tt-ven.etbcod) +
                                           string(time).

                {mdad.i 
                    &Saida     = "value(varquivo)"
                    &Page-Size = "64"
                    &Cond-Var  = "135"
                    &Page-Line = "66"
                    &Nom-Rel   = ""metven_l""
                    &Nom-Sis   = """SISTEMA DE COMISSAO"""
                    &Tit-Rel   = """LISTAGEM DE META DE VENDA "" +
                                    string(vdtini) + "" A "" + string(vdtfin) +
                                    "" "" + string(forne.fornom) "
                    &Width     = "135"
                    &Form      = "frame f-cabcab"}
       **********/

        for each tt-ven break by tt-ven.etbcod 
                              by tt-ven.vencod:
            
            if first-of(tt-ven.etbcod)
            then do:
                 
                 if opsys = "unix"
                 then varquivo = "../relat/metven" + 
                                 string(tt-ven.etbcod) + "." + string(time).
                 else varquivo = "..\relat\metven" +
                                string(tt-ven.etbcod) +  "." + string(time).

                {mdad.i 
                    &Saida     = "value(varquivo)"
                    &Page-Size = "64"
                    &Cond-Var  = "135"
                    &Page-Line = "66"
                    &Nom-Rel   = ""metven_l""
                    &Nom-Sis   = """SISTEMA DE COMISSAO"""
                    &Tit-Rel   = """LISTAGEM DE META DE VENDA  -  Loja: "" +
                                    string(tt-ven.etbcod)  + ""  -  "" +
                                    string(vdtini) + "" A "" + string(vdtfin) +
                                    "" "" + string(forne.fornom) "
                    &Width     = "110"
                    &Form      = "frame f-cabcab"}
          
            end.
                              
            find func where func.etbcod = tt-ven.etbcod and
                            func.funcod = tt-ven.vencod no-lock no-error.
        
            find last metven where metven.etbcod = tt-ven.etbcod and
                                   metven.forcod = forne.forcod and
                                   metven.metano = year(vdtini)
                                            no-lock no-error.
            if not avail metven
            then  find last metven where metven.etbcod = tt-ven.etbcod and
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
                 
                vtotetb = vtotetb + tt-ven.venda.
                
                display tt-ven.vencod column-label "Cod"
                        func.funnom format "x(15)" when avail func
                        tt-ven.venda /*(total by tt-ven.etbcod) */
                                column-label "Venda" 
                        ( ( (metven.metval / tt-num.numven) / duplic.dupdia) 
                        * vdia) column-label "Previsto" when avail duplic
                        ( ( tt-ven.venda /
                          ( ( (metven.metval / tt-num.numven) / duplic.dupdia) 
                         * vdia) ) * 100) column-label "Perc.!Previsto"
                                    format "->>>9.99"
                        (( tt-ven.venda / metven.metval) * 100)
                                   column-label "Perc.!NewFree" 
                                   format "->>>9.99"


                        vsinal no-label
                                   with frame fcom1 centered down
                                            color white/red width 110.
            end.

           if last-of(tt-ven.etbcod)
           then do:
                put "------------" at 37
                    vtotetb        at 35.

                put skip(2).
                output close.
                vtotetb = 0.
                
                if opsys = "unix"
                then do:
                     run visurel.p (input varquivo, input "").
                end.
               else do:
                    {mrod_l.i}
               end.
           end.

        end.
/*    end. */

end.

procedure calvenda:
    def var val_fin as dec.
    def var val_des as dec.
    def var val_dev as dec.
    def var val_acr as dec.
    def var val_com as dec.
                      
    val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.acfprod.
    if val_acr = ? then val_acr = 0.
           
    val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.descprod.
    if val_des = ? then val_des = 0.

    val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.vlserv.
    if val_dev = ? then val_dev = 0.
    if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
    then val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des) /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
    if val_fin = ? then val_fin = 0.
            
    val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + val_acr + 
                          val_fin. 

    if val_com = ? then val_com = 0.
           
    v-valor = val_com.

end.
