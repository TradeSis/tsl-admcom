{admcab.i}





def var vopecod like operadoras.opecod.

def temp-table tt-habil
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field vencod like habil.vencod
    field gercod like habil.gercod
    field funnom like func.funnom
    field operacao as char format "x(12)"
    field celular like habil.celular
    field habsit  like habil.habsit
    field codviv like habil.codviv
    field habdat  like habil.habdat.

def var total_loja     as int.
def var vqtd-vendedor as int format ">>>>9".
def var vqtd-loja  as int format ">>>>9".
def var varquivo as char.
def var vetbcod like estab.etbcod.
def var vdtini  as   date format "99/99/9999".
def var vdtfin  as   date format "99/99/9999".
def var vop     as   log  format "Habilitacao/Migracao" init yes.
def var vgercod like habil.gercod.

def var nomedofunc as char.

def var voperacao as char format "x(12)".

def var vtiprel as char format "x(15)" extent 2
    init [" POR FILIAL "," POR PLANO"].
def var vindex as int.     
repeat: 
    for each tt-habil. delete tt-habil. end.
    assign
        vetbcod = 0
        vgercod = 0
        vdtini = today - 7
        vdtfin = today
        vqtd-vendedor = 0
        vqtd-loja = 0
        voperacao = ""
        vop     = yes.
        
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

        vopecod = 0.         
        update skip vopecod label "Operadora." 
               with frame f-dados side-labels.

        if vopecod = 0
        then disp "Geral" @ operadoras.openom with frame f-dados.
        else do:
            find operadoras where operadoras.opecod = vopecod no-lock no-error.
            if not avail operadoras
            then do:
                message "Operadora nao Cadastrada".
                undo.
            end.
            else disp operadoras.openom no-label with frame f-dados.
        end.
    end.    
    
    update skip 
           vdtini label "Dt.Inicial"
           vdtfin label "Dt.Final"
           with frame f-dados side-labels width 80.

    disp vtiprel no-label
         with frame f-tiprel 1 down centered side-label.
    choose field vtiprel with frame f-tiprel.
    vindex = frame-index.
         
    if opsys = "UNIX" 
    then 
        varquivo = "/admcom/relat/relhabil." + string(time).
    else 
        varquivo = "l:\relat\relhabil" + string(day(today)).
            
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""relhabil""
        &Nom-Sis   = """HABILITACAO"""
        &Tit-Rel   = """RELATORIO DE HABILITACOES - FILIAL "" +
                        string(vetbcod,"">>9"")
                        + "" PERIODO DE "" +
                         string(vdtini,""99/99/9999"") + "" A "" +
                         string(vdtfin,""99/99/9999"") "
       &Width     = "100"
       &Form      = "frame f-cabcab"}
 
    for each habil use-index ihabdat
             where habil.habdat >= vdtini 
               and habil.habdat <= vdtfin no-lock
               break by habil.etbcod
                     by habil.vencod
                     by habil.gercod:
                          
        if vetbcod <> 0
        then
            if habil.etbcod <> vetbcod
            then next.
                            
        if vopecod <> 0
        then do:
            find promoviv where promoviv.opecod = vopecod
                            and promoviv.tipviv = habil.tipviv 
                          /*  and promoviv.exportado = yes*/
                            no-lock no-error.
            if not avail promoviv
            then next.
            find plano where plano.codviv = habil.codviv no-lock.
             if vopecod = 1 and
                plano.planomviv begins "CLARO"
            then next.    
            if promoviv.tipviv  = 25 then next.
        end.

        find first func where func.etbcod = habil.etbcod
                    and func.funcod = habil.vencod no-lock no-error.

              if avail func then do:
                  nomedofunc = func.funnom.
              end.
              else do:
                  nomedofunc = " ".
              end.

        if habil.gercod = 1
        then voperacao = "Habilitacao".
        else
            if habil.gercod = 2
            then voperacao = "Migracao".
            else
                if habil.gercod = 3
                then voperacao = "Cancelada".
                else voperacao = "".
        /*
        vqtd-vendedor = vqtd-vendedor + 1.
        vqtd-loja = vqtd-loja + 1.
        total_loja     = total_loja     + 1.
        */
        
        create tt-habil.
        assign tt-habil.etbcod = habil.etbcod
               tt-habil.etbnom = estab.etbnom
               tt-habil.vencod = habil.vencod
               tt-habil.gercod = habil.gercod
               tt-habil.funnom = nomedofunc
               tt-habil.operacao = voperacao
               tt-habil.celular = habil.celular
               tt-habil.habsit = habil.habsit
               tt-habil.codviv = habil.codviv
               tt-habil.habdat = habil.habdat.
        
        /*
        if first-of(habil.etbcod)
        then do:

            disp habil.etbcod label "Filial" 
                 estab.etbnom no-label 
                 with frame fc side-labels.
            
        end.
        
        disp
              tt-habil.etbcod    column-label "Fil" format ">>9"     
             space(5) tt-habil.codviv  column-label "Plano"   
             space(5) habil.vencod       column-label "Codigo"
             nomedofunc column-label "Vendedor"
             voperacao                   column-label "Operacao" format "x(12)"
             habil.celular               column-label "Telefone"
             habil.habsit                column-label "Situacao" format "x(12)"
             with frame f-habil width 130 down.
        down with frame f-habil.

        if last-of(habil.vencod)
        then do:

            disp space(5)
                 vqtd-vendedor
                 label "Total Vendedor"
                 with frame f-vend width 100 side-labels.
            vqtd-vendedor = 0.
        
        end.

        if last-of(habil.etbcod)
        then do:

            disp space(5)
                 "Total Loja " + string(habil.etbcod,">>9") + ".:"
                 format "x(15)"
                 vqtd-loja  no-label
                 with frame f-etb width 100 side-labels.

            vqtd-loja = 0.
            
        end.
        */
        
    end.
    if vindex = 1
    then do:
    for each tt-habil break by tt-habil.etbcod
                            by tt-habil.vencod
                            by tt-habil.gercod:

        
        vqtd-vendedor = vqtd-vendedor + 1.
        vqtd-loja     = vqtd-loja     + 1.
        total_loja    = total_loja    + 1.
        
        if first-of(tt-habil.etbcod)
        then do:

            disp tt-habil.etbcod label "Filial" 
                 tt-habil.etbnom no-label 
                 with frame fc side-labels.
            
        end.
        
        disp
          tt-habil.etbcod    column-label "Fil" format ">>9"     
               space(5) tt-habil.codviv  column-label "Plano"  
              space(5) tt-habil.vencod    column-label "Codigo"
            
             tt-habil.funnom             column-label "Vendedor"
             tt-habil.operacao           column-label "Operacao" format "x(12)"
             tt-habil.habdat     column-label "Dt.Habil" format "99/99/9999"
             tt-habil.celular            column-label "Telefone"
             /*tt-habil.habsit   column-label "Situacao" format "x(12)"*/
             tt-habil.codviv     column-label "Plano" format ">>>9"
             with frame f-habil width 130 down.
        down with frame f-habil.

        if last-of(tt-habil.vencod)
        then do:

            disp space(5)
                 vqtd-vendedor
                 label "Total Vendedor"
                 with frame f-vend width 100 side-labels.
            vqtd-vendedor = 0.
        
        end.

        if last-of(tt-habil.etbcod)
        then do:

            disp space(5)
                 "Total Loja " + string(tt-habil.etbcod,">>9") + ".:"
                 format "x(15)"
                 vqtd-loja  no-label
                 with frame f-etb width 100 side-labels.

            vqtd-loja = 0.
            
        end.

    end.
    
    put "     Total Geral...: " total_loja format ">>>>9".
    end.
    else do:
    for each tt-habil break by tt-habil.codviv
                            by tt-habil.operacao
                            by tt-habil.etbcod:

        /*
        vqtd-vendedor = vqtd-vendedor + 1.
        vqtd-loja     = vqtd-loja     + 1.
        */
        
        total_loja    = total_loja    + 1.
        
        if first-of(tt-habil.codviv)
        then do:
            find plano where plano.codviv = tt-habil.codviv no-lock.
            disp tt-habil.codviv label "Plano"  format ">>>>>9"
                 plano.planomviv no-label
            with frame fcv side-label.
            vqtd-loja = 0.
        end.
        vqtd-loja = vqtd-loja + 1.
        
        disp space(5) 
             tt-habil.etbcod    column-label "Fil" format ">>9"
               space(5) tt-habil.codviv  column-label "Plano" format ">>>>9"       
             tt-habil.vencod    column-label "Codigo"
             tt-habil.funnom             column-label "Vendedor"
             tt-habil.operacao           column-label "Operacao" format "x(12)"
             tt-habil.habdat     column-label "Dt.Habil" format "99/99/9999"
             tt-habil.celular            column-label "Telefone"
             /*tt-habil.habsit   column-label "Situacao" format "x(12)"
             tt-habil.codviv     column-label "Plano" format ">>>9" */
             with frame f-habil1 width 130 down.
        down with frame f-habil1.

        if last-of(tt-habil.codviv)
        then do:

            disp space(5)
                 vqtd-loja
                 label "Total do plano"
                 with frame f-vend1 width 100 side-labels.
            vqtd-loja = 0.
        
        end.

        /**
        if last-of(tt-habil.etbcod)
        then do:

            disp space(5)
                 "Total Loja " + string(tt-habil.etbcod,">>9") + ".:"
                 format "x(15)"
                 vqtd-loja  no-label
                 with frame f-etb1 width 100 side-labels.

            vqtd-loja = 0.
            
        end.
        **/
    end.
    
    put "     Total Geral...: " total_loja format ">>>>9".
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