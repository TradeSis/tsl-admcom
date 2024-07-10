/********************************************************************
** Programa : CorkVen9.p
** Data ....: 09/10/2001
** Descricao: Consulta de Ranking de Vendedor por Loja
** Autor ...: Andre Mendes Baldini
*********************************************************************/

{admcab.i}

def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var val_fin like plani.platot.

def var vcatcod like categoria.catcod.
def var v-total     as dec.
def var d           as date.
def var varqsai     as char.
def var varquivo    as char.

def temp-table ttvend
    field etbcod    like plani.etbcod
    field platot    like plani.platot
    field funcod    like plani.vencod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field vlmeta    as dec
    field vlmdia    as dec 
    field numseq    like movim.movseq
    field numloj    like movim.movseq 
    field qtddev    like movim.movqtm
    index valor     platot desc
    index vencod    funcod etbcod.
    
def var v-totger    as dec.
def var v-totdia    as dec.
def var v-nome      like estab.etbnom.
def var v-titven    as char.
def var v-titvenpro as char.
def var v-perc      as dec.
def var v-perdia    as dec.
def var v-tot       as dec.
def var p-vende     like func.funcod.
def var i           as int.
def var vdti        as date format "99/99/9999" no-undo label "Dt.Ini".
def var vdtf        as date format "99/99/9999" no-undo label "Dt.Fin".
def var v-valor     as dec.

def buffer sclase   for clase.
def buffer grupo    for clase.
def var p-loja      like estab.etbcod.

{anset.i}.

form
    ttvend.numseq   column-label "Rk" format ">>9" 
    ttvend.numloj   column-label "RLj" format ">>9" 
    ttvend.etbcod   column-label "L" format ">>9" 
    ttvend.funcod   column-label "Cod" format ">>9"
         help " F4 = Impressao" 
    func.funnom     format "x(9)" column-label "Nome" 
    ttvend.qtd      format ">>>9" column-label "Qtd"
    ttvend.pladia   format ">>>>,>>9.9" column-label "Vnd.Dia" 
    ttvend.platot   format ">>>>,>>9.9"  column-label "Vnd.Acum" 
    ttvend.vlmeta   format ">>,>>9.9" column-label "Met.Vnd" 
    v-perdia        column-label "%Met" format "->>9.99" 
    v-perc          column-label "%Ac"    format "->>9.99"
    with frame f-vend centered down  title v-titven.
    

        
form
    p-loja label "Lj" 
    estab.etbnom no-label format "x(15)"
    vcatcod label "Cat" format ">>" 
    categoria.catnom no-label format "x(7)"
    vdti
    vdtf
    with frame f-loja
        centered
        1 down side-labels title "Dados Iniciais". 

hide frame f-opcao. clear frame f-opcao all.

repeat :
    for each ttvend :
        delete ttvend.
    end.    
    clear frame f-loja all.
    
    update
        p-loja 
        with frame f-loja.
    
    if p-loja = 0 
    then disp "GERAL" @ estab.etbnom with frame f-loja.
    else do :
        find first estab where estab.etbcod = p-loja no-lock.
        disp estab.etbnom with frame f-loja.
    end.    

    vcatcod = ?.
    update vcatcod with frame f-loja.  
    
    if vcatcod <> ? 
    then do: 
        find categoria where categoria.catcod = vcatcod no-lock no-error. 
        if not avail categoria 
        then do: 
            message "Categoria nao Cadastrada". 
            undo. 
        end. 
        else disp categoria.catnom with frame f-loja.
    end.
    else disp "Geral" @ categoria.catnom with frame f-loja.

    vdti = today.
    vdtf = today.
    
    update vdti
           vdtf with frame f-loja.

    if vdti = ? or vdtf = ? or vdti > vdtf 
    then do :
        bell. bell.
        message "Datas informadas invalidas".
        pause. clear frame f-loja all.
        next.
    end.    

  IF VCATCOD = ?
  THEN DO:
    if p-loja <> 0
    then do:
    
        find first estab where estab.etbcod = p-loja no-lock.

    do d = vdti to vdtf :

        for each plani where plani.movtdc = 5 
                         and  plani.etbcod = estab.etbcod and
                               plani.pladat = d 
                           no-lock  
                           use-index pladat:


          disp "Processando ...."
                plani.etbcod plani.pladat with frame f11 
                    centered row 10 1 down no-labels. pause 0.

            find first func where func.funcod = plani.vencod 
                                  and func.etbcod = plani.etbcod  
                                no-lock no-error.
            if not avail func
            then do :
                find first func where func.etbcod = 0                                                and func.funcod = plani.vencod
                                    no-lock no-error.
                if not avail func
                then next.
            end.
                    
            v-valor = if plani.biss > 0
                      then plani.biss
                      else plani.platot.
                
            find first ttvend where ttvend.funcod = func.funcod                                    and ttvend.etbcod = func.etbcod
                                    use-index vencod
                                  no-error.
            if not avail ttvend
            then do:
                create ttvend.
                ttvend.etbcod = func.etbcod.
                ttvend.funcod = func.funcod.
            end.
            if plani.movtdc = 5 
            then do :
                ttvend.qtd = ttvend.qtd + 1.                                                    ttvend.platot = ttvend.platot + v-valor.
                if plani.pladat = vdtf
                then ttvend.pladia = ttvend.pladia + v-valor.
            end.    
                    
        end.
    
        for each plani where plani.movtdc = 12
                     and  plani.etbcod = estab.etbcod                                                 and  plani.pladat = d
                           no-lock  
                           use-index pladat:
                          
            disp "Processando ...."
                plani.etbcod plani.pladat with frame f21
                    centered row 10 1 down no-labels. pause 0.
                     
            find first func where func.funcod = plani.vencod 
                                  and func.etbcod = plani.etbcod
                                no-lock no-error.
            if not avail func 
            then do :
                find first func where func.etbcod = 0
                                      and func.funcod = plani.vencod
                                    no-lock no-error.
                if not avail func
                then next.
            end.
            v-valor = plani.platot.
            find first ttvend where ttvend.funcod = func.funcod
                                    and ttvend.etbcod = func.etbcod
                                  use-index vencod  
                                  no-error.
            if not avail ttvend
            then do:
                create ttvend.
                ttvend.etbcod = func.etbcod.
                ttvend.funcod = func.funcod.
            end.
            if plani.movtdc = 12 
            then do :
                ttvend.qtd = ttvend.qtd - 1.
                ttvend.platot = ttvend.platot - v-valor.
                if plani.pladat = vdtf
                then  ttvend.pladia = ttvend.pladia - v-valor.
            end.    
        end.
    end.
    end.
    
        
    if p-loja = 0
    then do:
    
    for each estab no-lock.

    do d = vdti to vdtf :
        for each plani where plani.movtdc = 5 
                         and  plani.etbcod = estab.etbcod and
                               plani.pladat = d 
                           no-lock  
                           use-index pladat:
                          
            disp "Processando ...."
                plani.etbcod plani.pladat with frame f1 
                    centered row 10 1 down no-labels. pause 0.
            find first func where func.funcod = plani.vencod 
                                  and func.etbcod = plani.etbcod  
                                no-lock no-error. 
            if not avail func
            then do :
                find first func where func.etbcod = 0   
                                      and func.funcod = plani.vencod
                                    no-lock no-error.
                if not avail func
                then next.
            end.
                    
            v-valor = if plani.biss > 0
                      then plani.biss
                      else plani.platot.
                
            find first ttvend where ttvend.funcod = func.funcod
                                    and ttvend.etbcod = func.etbcod
                                    use-index vencod
                                  no-error.
            if not avail ttvend
            then do:
                create ttvend.
                ttvend.etbcod = func.etbcod.
                ttvend.funcod = func.funcod.
            end.
            if plani.movtdc = 5 
            then do :
                ttvend.qtd = ttvend.qtd + 1.
                ttvend.platot = ttvend.platot + v-valor.
                if plani.pladat = vdtf
                then ttvend.pladia = ttvend.pladia + v-valor.
            end.    
                    
        end.
    
        for each plani where plani.movtdc = 12
                     and  plani.etbcod = estab.etbcod and
                           plani.pladat = d
                           no-lock  
                           use-index pladat:
                          
            disp "Processando ...."
                plani.etbcod plani.pladat with frame f2
                    centered row 10 1 down no-labels. pause 0.
                     
            find first func where func.funcod = plani.vencod 
                                and func.etbcod = plani.etbcod
                                no-lock no-error.
            if not avail func 
            then do :
                find first func where func.etbcod = 0
                                   and func.funcod = plani.vencod
                                    no-lock no-error.
                if not avail func
                then next.
            end.
            v-valor = plani.platot.
            find first ttvend where ttvend.funcod = func.funcod
                                  and ttvend.etbcod = func.etbcod
                                  use-index vencod  
                                  no-error.
            if not avail ttvend
            then do:
                create ttvend.
                ttvend.etbcod = func.etbcod.
                ttvend.funcod = func.funcod.
            end.
            if plani.movtdc = 12 
            then do :
                ttvend.qtd = ttvend.qtd - 1.
                ttvend.platot = ttvend.platot - v-valor.
                if plani.pladat = vdtf
                then  ttvend.pladia = ttvend.pladia - v-valor.
            end.    
        end.
    end.
    end.
    end.
   END.
   ELSE RUN PROCAT.
  
    /*
    for each ttvend : 
        v-total = 0.
        for each metven where metven.funcod = ttvend.funcod 
                          and metven.dtcomp >= vdti
                          and metven.dtcomp <= vdtf
                          and metven.etbcod = ttvend.etbcod no-lock :
            v-total = v-total + metven.vlmeta.
            if metven.dtcomp = vdtf 
            then ttvend.vlmdia = metven.vlmeta.
        end.
        ttvend.vlmeta = v-total.
    end.  
    */
    
    hide frame f1.
    hide frame f2.
    hide frame f11.
    hide frame f21.
    
    repeat :
        if p-loja <> 0 
        then do :
            find first estab where estab.etbcod = p-loja no-lock.
            v-nome = estab.etbnom. 
        end.
        else v-nome = "EMPRESA".
       
        assign an-seeid = -1 an-recid = -1 an-seerec = ?
               v-titven  = "VENDEDORES DA LOJA " + string(v-nome)
            v-totger = 0 v-totdia = 0 i = 1.

        for each ttvend break by ttvend.platot desc :
            ttvend.numseq = i.
            i = i + 1.
            assign  v-totdia = v-totdia + ttvend.pladia
                    v-totger = v-totger + ttvend.platot.
        end.           
        i = 0.                
        for each ttvend break by ttvend.etbcod
                                 by ttvend.platot desc :
            if first-of(ttvend.etbcod) 
            then i = 1.
            ttvend.numloj = i.
            i = i + 1.
        end.                            

            
        {anbrowse.i
            &File   = ttvend
            &CField = ttvend.funcod
            &Ofield = " ttvend.platot func.funnom ttvend.pladia ttvend.numseq 
        ttvend.vlmeta v-perc v-perdia ttvend.qtd ttvend.etbcod ttvend.numloj "
            &Where = "true"
            &NonCharacter = /*
            &AftFnd = " find first func where 
                            func.funcod = ttvend.funcod 
                           and func.etbcod = ttvend.etbcod no-lock no-error.
                  if not avail func
                  then find first func where func.funcod = ttvend.funcod
                                         and func.etbcod = 0 no-lock. 
                assign   v-perc = ttvend.platot * 100 / v-totger
                         v-perdia = ttvend.platot * 100 / ttvend.vlmeta. "
            &AftSelect1 = "p-vende = ttvend.funcod. 
                           leave keys-loop. "
            &Otherkeys1 = "corkven9.ok"
            &LockType = "use-index valor"           
            &Form = " frame f-vend"}.
        
        if keyfunction(lastkey) = "END-ERROR" 
        then leave.
    end.
    message "Deseja Imprimir Relatorio" update sresp.
    if sresp
    then do:
      
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/corkven" + string(time).
    else varquivo = "..\relat\corkven" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "60"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = ""CORKVEN9""
        &Nom-Sis   = """SISTEMA COMERCIAL"""  
        &Tit-Rel   = """RANKING DE VENDEDORES "" +
                        ""DATA: "" + string(vdti,""99/99/9999"") + 
                        "" A "" +    string(vdtf,""99/99/9999"")"
        &Width     = "80"
        &Form      = "frame f-cabcab"}

   
/*   
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "60"
            &Cond-Var  = "80"
            &Page-Line = "66"
            &Nom-Rel   = ""CORKVEN9""
            &Nom-Sis   = """SISTEMA COMERCIAL"""
            &Tit-Rel   = """RANKING DE VENDEDORES "" +
                            ""DATA: "" + string(vdti,""99/99/9999"") +
                            "" A "" +    string(vdtf,""99/99/9999"")"
            &Width     = "80"
            &Form      = "frame f-cabcab"}.
*/
        for each ttvend:

           find func where func.funcod = ttvend.funcod and
                           func.etbcod = ttvend.etbcod no-lock no-error.

           assign   v-perc = ttvend.platot * 100 / v-totger
                    v-perdia = ttvend.platot * 100 / ttvend.vlmeta.
                         
           disp ttvend.numseq
                ttvend.numloj
                ttvend.etbcod
                ttvend.funcod
                func.funnom when avail func
                ttvend.qtd
                ttvend.pladia
                ttvend.platot
                ttvend.vlmeta
                v-perdia
                v-perc with frame f-vend.
            
           down with frame f-vend.
    end.
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        
    {mrod.i}
    end.            

    end.
    
end.
 
procedure procat:

    if p-loja <> 0
    then do:
    
        find first estab where estab.etbcod = p-loja no-lock.

    do d = vdti to vdtf :

        for each plani where plani.movtdc = 5 
                         and  plani.etbcod = estab.etbcod and
                               plani.pladat = d 
                           no-lock  
                           use-index pladat:

          disp "Processando ...."
                plani.etbcod plani.pladat with frame f11 
                    centered row 10 1 down no-labels. pause 0.

            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock.

                find produ where produ.procod = movim.procod no-lock.
                if produ.catcod <> vcatcod then next.

            find first func where func.funcod = plani.vencod 
                                  and func.etbcod = plani.etbcod  
                                no-lock no-error.
            if not avail func
            then do :
                find first func where func.etbcod = 0                          ~                      and func.funcod = plani.vencod
                                    no-lock no-error.
                if not avail func
                then next.
            end.
                    
            v-valor = (movim.movpc * movim.movqtm).
                
            find first ttvend where ttvend.funcod = func.funcod                ~                    and ttvend.etbcod = func.etbcod
                                    use-index vencod
                                  no-error.
            if not avail ttvend
            then do:
                create ttvend.
                ttvend.etbcod = func.etbcod.
                ttvend.funcod = func.funcod.
            end.
            if plani.movtdc = 5 
            then do :
                ttvend.qtd = ttvend.qtd + 1.                                   

                /**acres*/
                
                val_fin = 0.                   
                val_des = 0.  
                val_dev = 0.  
                val_acr = 0. 
                         
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
                then
                    val_fin =  ((((movim.movpc * movim.movqtm) 
                            - val_dev - val_des) / 
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
                if val_fin = ? then val_fin = 0.
                
                val_com = (movim.movpc * movim.movqtm) - 
                          val_dev - val_des + val_acr + val_fin. 
                if val_com = ? then val_com = 0.
                
                ttvend.platot = ttvend.platot + val_com.
                if plani.pladat = vdtf
                then ttvend.pladia = ttvend.pladia + val_com.
                
                /*******/
                
                /*ttvend.platot = ttvend.platot + v-valor.
                if plani.pladat = vdtf
                then ttvend.pladia = ttvend.pladia + v-valor.*/
            end.    

          end.          
          
        end.
    
        for each plani where plani.movtdc = 12
                     and  plani.etbcod = estab.etbcod                          ~                       and  plani.pladat = d
                           no-lock  
                           use-index pladat:
                          
            disp "Processando ...."
                plani.etbcod plani.pladat with frame f21
                    centered row 10 1 down no-labels. pause 0.

            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock.
                find produ where produ.procod = movim.procod no-lock.
                if produ.catcod <> vcatcod then next.
                     
            find first func where func.funcod = plani.vencod 
                                  and func.etbcod = plani.etbcod
                                no-lock no-error.
            if not avail func 
            then do :
                find first func where func.etbcod = 0
                                      and func.funcod = plani.vencod
                                    no-lock no-error.
                if not avail func
                then next.
            end.
            v-valor = (movim.movpc * movim.movqtm).
            
            find first ttvend where ttvend.funcod = func.funcod
                                    and ttvend.etbcod = func.etbcod
                                  use-index vencod  
                                  no-error.
            if not avail ttvend
            then do:
                create ttvend.
                ttvend.etbcod = func.etbcod.
                ttvend.funcod = func.funcod.
            end.
            if plani.movtdc = 12 
            then do :
                ttvend.qtd = ttvend.qtd - 1.
                ttvend.platot = ttvend.platot - v-valor.
                if plani.pladat = vdtf
                then  ttvend.pladia = ttvend.pladia - v-valor.
            end.    
        end. 
       end.
    end.
    end.
    
        
    if p-loja = 0
    then do:
    
    for each estab no-lock.

    do d = vdti to vdtf :
        for each plani where plani.movtdc = 5 
                         and  plani.etbcod = estab.etbcod and
                               plani.pladat = d 
                           no-lock  
                           use-index pladat:
                          
            disp "Processando ...."
                plani.etbcod plani.pladat with frame f1 
                    centered row 10 1 down no-labels. pause 0.

            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock.
                find produ where produ.procod = movim.procod no-lock.
                if produ.catcod <> vcatcod then next.
            
            find first func where func.funcod = plani.vencod 
                                  and func.etbcod = plani.etbcod  
                                no-lock no-error. 
            if not avail func
            then do :
                find first func where func.etbcod = 0   
                                      and func.funcod = plani.vencod
                                    no-lock no-error.
                if not avail func
                then next.
            end.
                    
            v-valor = (movim.movpc * movim.movqtm).
                
            find first ttvend where ttvend.funcod = func.funcod
                                    and ttvend.etbcod = func.etbcod
                                    use-index vencod
                                  no-error.
            if not avail ttvend
            then do:
                create ttvend.
                ttvend.etbcod = func.etbcod.
                ttvend.funcod = func.funcod.
            end.
            if plani.movtdc = 5 
            then do :
                ttvend.qtd = ttvend.qtd + 1.

                /**acres*/
                
                val_fin = 0.                   
                val_des = 0.  
                val_dev = 0.  
                val_acr = 0. 
                         
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
                then
                    val_fin =  ((((movim.movpc * movim.movqtm) 
                            - val_dev - val_des) / 
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
                if val_fin = ? then val_fin = 0.
                
                val_com = (movim.movpc * movim.movqtm) - 
                          val_dev - val_des + val_acr + val_fin. 

                if val_com = ? then val_com = 0.
                
                ttvend.platot = ttvend.platot + val_com.
                if plani.pladat = vdtf
                then ttvend.pladia = ttvend.pladia + val_com.
                
                /*******/
                
                /*ttvend.platot = ttvend.platot + v-valor.
                if plani.pladat = vdtf
                then ttvend.pladia = ttvend.pladia + v-valor.*/
            end.    
           end.         
        end.
    
        for each plani where plani.movtdc = 12
                     and  plani.etbcod = estab.etbcod and
                           plani.pladat = d
                           no-lock  
                           use-index pladat:
                          
            disp "Processando ...."
                plani.etbcod plani.pladat with frame f2
                    centered row 10 1 down no-labels. pause 0.

            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock.

                find produ where produ.procod = movim.procod no-lock.
                if produ.catcod <> vcatcod then next.
                     
            find first func where func.funcod = plani.vencod 
                                and func.etbcod = plani.etbcod
                                no-lock no-error.
            if not avail func 
            then do :
                find first func where func.etbcod = 0
                                   and func.funcod = plani.vencod
                                    no-lock no-error.
                if not avail func
                then next.
            end.
            v-valor = (movim.movpc * movim.movqtm).

            find first ttvend where ttvend.funcod = func.funcod
                                  and ttvend.etbcod = func.etbcod
                                  use-index vencod  
                                  no-error.
            if not avail ttvend
            then do:
                create ttvend.
                ttvend.etbcod = func.etbcod.
                ttvend.funcod = func.funcod.
            end.
            if plani.movtdc = 12 
            then do :
                ttvend.qtd = ttvend.qtd - 1.
                ttvend.platot = ttvend.platot - v-valor.
                if plani.pladat = vdtf
                then  ttvend.pladia = ttvend.pladia - v-valor.
            end.    
          end.        
        end.
    end.
    end.
    end.

end procedure.