{admcab.i}

def var total_loja     as int.
def var vqtd-vendedor as int format ">>>>9".
def var vqtd-loja  as int format ">>>>9".
def var varquivo as char.
def var vetbcod like estab.etbcod.
def var vdtini  as   date format "99/99/9999".
def var vdtfin  as   date format "99/99/9999".
def var vop     as   log  format "Habilitacao/Migracao" init yes.
def var vgercod like habil.gercod.

def var vtipviv like habil.tipviv.
def var vcodviv like habil.codviv.

def var voperacao as char format "x(12)".

def temp-table t-vend
    field etbcod like estab.etbcod
    field vencod like plani.vencod
    field qtd    as   int
    index ivend is primary unique etbcod vencod.

def temp-table t-etb
    field etbcod like estab.etbcod
    field qtd    as   int
    index ietb is primary unique etbcod.
    
def temp-table t-pro
    field tipviv  like promoviv.tipviv
    field etbcod like estab.etbcod
    field qtd as int
    index ipro is primary unique etbcod tipviv.

def temp-table t-pla
    field codviv  like planoviv.codviv
    field etbcod like estab.etbcod
    field qtd as int
    index ipla is primary unique etbcod codviv.
    

repeat: 
    for each t-vend. delete t-vend. end.
    for each t-pla. delete t-pla. end.
    for each t-pro. delete t-pro. end.
    for each t-etb. delete t-etb. end.
    
    assign
        vetbcod       = 0
        vtipviv       = 0
        vcodviv       = 0
        vgercod       = 0
        vdtini        = today - 7
        vdtfin        = today
        vqtd-vendedor = 0
        vqtd-loja     = 0
        voperacao     = ""
        vop           = yes.
        
    do on error undo:

        total_loja     = 0.
        update vetbcod label "Loja......" 
               with frame f-dados side-labels.
        if vetbcod = 0
        then disp "Geral" @ estab.etbnom with frame f-dados.
        else do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Estabelecimento nao Cadastrado".
                undo.
            end.
            else disp estab.etbnom no-label with frame f-dados.
        end.
    end.    

    do on error undo:
        update skip vtipviv label "Promocao.." space(1)
               with frame f-dados.
        if vtipviv <> 0
        then do:
            find promoviv where promoviv.tipviv = vtipviv no-lock no-error.
            if not avail promoviv
            then do:
                message "Promocao nao cadastrada.".
                undo.
            end.
            else disp promoviv.provivnom no-label
                      with frame f-dados.
        end.
        else disp "Geral" @ promoviv.provivnom
                  with frame f-dados.
    end.

    do on error undo:
        update skip vcodviv label "Plano....." space(1)
               with frame f-dados side-labels width 80.
        if vcodviv <> 0
        then do:
            
            find planoviv where
                 planoviv.codviv = vcodviv no-lock no-error.
            if not avail planoviv
            then do:
                message "Plano nao cadastrado.".
                undo.
            end.
            else disp planoviv.planomviv no-label
                      with frame f-dados.
        
        end.
        else disp "Geral" @ planoviv.planomviv
                  with frame f-dados.
    
    end.
               
               
    update skip 
           vdtini label "Dt.Inicial"
           vdtfin label "Dt.Final"
           with frame f-dados side-labels width 80.

               
    if opsys = "UNIX" 
    then 
        varquivo = "/admcom/relat/relhabil" + string(day(today)).
    else 
        varquivo = "l:\relat\relhabil" + string(day(today)).
            
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""relhabil""
        &Nom-Sis   = """HABILITACAO [VIVO]"""
        &Tit-Rel   = """RELATORIO DE HABILITACOES - FILIAL "" +
                        string(vetbcod,"">>9"")
                        + "" PERIODO DE "" +
                         string(vdtini,""99/99/9999"") + "" A "" +
                         string(vdtfin,""99/99/9999"") "
       &Width     = "130"
       &Form      = "frame f-cabcab"}
 
    for each habil use-index ihabdat
             where habil.habdat >= vdtini 
               and habil.habdat <= vdtfin no-lock
               break by habil.etbcod
                     by habil.vencod
                     by habil.gercod
                     by habil.tipviv
                     by habil.codviv:

        if vetbcod <> 0
        then 
            if habil.etbcod <> vetbcod
            then next.

        if vtipviv <> 0
        then
            if habil.tipviv <> vtipviv
            then next.
        
        if vcodviv <> 0
        then
            if habil.codviv <> vcodviv
            then next.
        
        find func where func.etbcod = habil.etbcod
                    and func.funcod = habil.vencod no-lock no-error.
        
        if habil.gercod = 1
        then voperacao = "HAB".
        else
            if habil.gercod = 2
            then voperacao = "MIG".
            else
                if habil.gercod = 3
                then voperacao = "CAN".
                else voperacao = "".
        
        find first t-vend where
                   t-vend.etbcod = habil.etbcod
               and t-vend.vencod = habil.vencod no-error.
        if not avail t-vend
        then do:
            create t-vend.
            assign t-vend.etbcod = habil.etbcod
                   t-vend.vencod = habil.vencod.
        end.
        t-vend.qtd = t-vend.qtd + 1.
               
        find first t-etb where
                   t-etb.etbcod = habil.etbcod no-error.
        if not avail t-etb
        then do:
            create t-etb.
            assign t-etb.etbcod = habil.etbcod.
        end.
        t-etb.qtd = t-etb.qtd + 1.

        find first t-pro where
                   t-pro.etbcod = habil.etbcod
               and t-pro.tipviv = habil.tipviv no-error.
        if not avail t-pro
        then do:
            create t-pro.
            assign t-pro.etbcod = habil.etbcod
                   t-pro.tipviv = habil.tipviv.
        end.
        t-pro.qtd = t-pro.qtd + 1.

        find first t-pla where
                   t-pla.etbcod = habil.etbcod
               and t-pla.codviv = habil.codviv no-error.
        if not avail t-pla
        then do:
            create t-pla.
            assign t-pla.etbcod = habil.etbcod
                   t-pla.codviv = habil.codviv.
        end.
        t-pla.qtd = t-pla.qtd + 1.
        
        find promoviv where promoviv.tipviv = habil.tipviv no-lock no-error.
        find planoviv where planoviv.codviv = habil.codviv no-lock no-error.
        
        /*
        find first clien where clien.ciccgc = habil.ciccgc no-lock no-error.
        */
        
        disp habil.etbcod   column-label "Fl" format ">9"
             habil.vencod   column-label "Codigo"
             func.funnom when avail func column-label "Vendedor"
             format "x(15)"
             voperacao      column-label "Tipo!Oper" format "x(4)"
             
             (if avail promoviv
              then promoviv.provivnom
              else "NAO INFORMADO") column-label "Promocao" format "x(20)"
              
             (if avail planoviv
              then planoviv.planomviv
              else "NAO INFORMADO") column-label "Plano" format "x(20)"
             habil.habval   column-label "Valor!Venda"
             habil.celular  column-label "Telefone"
        /*     clien.clinom   column-label "Cliente"
             when avail clien*/
             with frame f-habil width 130 down.
             
        down with frame f-habil.     
             
    end.

    disp  skip(1)
          " T O T A I S "
          skip(1)
          with frame f-cab-t centered side-labels.
    
    for each t-etb:
        disp t-etb.etbcod column-label "Filial"
             t-etb.qtd    column-label "Qtd." (total)
             with frame f-tf centered title "TOTAIS POR FILIAIS" down .
             down with frame f-tf.
    end.
    put skip(2).
    for each t-vend by t-vend.etbcod by t-vend.vencod:
        find func where func.etbcod = t-vend.etbcod
                    and func.funcod = t-vend.vencod no-lock no-error.
        
        disp t-vend.etbcod column-label "Filial"
             t-vend.vencod column-label "Codigo"
             (if avail func
              then func.funnom
              else "NAO CADASTRADO") format "x(40)" column-label "Vendedor"
             t-vend.qtd    column-label "Qtd." (total)
             with frame f-tfunc centered title "TOTAIS POR VENDEDORES" down .
             down with frame f-tfunc.
    end.
    
    put skip(2).
    for each t-pro by t-pro.etbcod by t-pro.tipviv:
    
        find promoviv where promoviv.tipviv = t-pro.tipviv no-lock no-error.
        
        disp t-pro.etbcod column-label "Filial"
             t-pro.tipviv column-label "Codigo"
             (if avail promoviv
              then promoviv.provivnom
              else "NAO CADASTRADO") format "x(40)" column-label "Promocao"
             t-pro.qtd    column-label "Qtd." (total)
             with frame f-tpro centered title "TOTAIS POR PROMOCOES" down .
             down with frame f-tpro.
    end.
    
    put skip(2).
    for each t-pla by t-pla.etbcod by t-pla.codviv:
    
        find planoviv where 
             planoviv.codviv = t-pla.codviv no-lock no-error.
        
        disp t-pla.etbcod column-label "Filial"
             t-pla.codviv column-label "Codigo"
             (if avail planoviv
              then planoviv.planomviv
              else "NAO CADASTRADO") format "x(40)" column-label "Plano"
             t-pla.qtd    column-label "Qtd." (total)
             with frame f-tpla centered title "TOTAIS POR PLANOS" down .
             down with frame f-tpla.
    end.


    output close.
    if opsys = "UNIX"
    then do: 
        /* output close. */
        run visurel.p (input varquivo, 
                       input "RELATORIO DE HABILITACOES [VIVO]").     
    end. 
    else do: 
        {mrod.i} 
    end.


end.