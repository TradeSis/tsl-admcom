{admcab.i}

def var vopecod like operadoras.opecod.

def var vqtd-nf as int format ">>>>>>>>9".
def var varquivo as char.
def var vetbcod like estab.etbcod.
def var varq as char.

def var vtipviv like plaviv.tipviv.
def var vcodviv like plaviv.codviv.

def var vdata   as   date format "99/99/9999".
def var vdti    as   date format "99/99/9999".
def var vdtf    as   date format "99/99/9999".

def temp-table tt-cel
    field etbcod like plani.etbcod
    field etbnom like estab.etbnom
    field tipviv like plaviv.tipviv
    field codviv like plaviv.codviv
    field procod like produ.procod
    field pronom like produ.pronom
    field tipo   as char format "X(8)"
    field placod like plani.placod
    field numero like plani.numero
    field pladat like plani.pladat
    field movpc  like movim.movpc
    field movqtm like movim.movqtm
    field prepro like plaviv.prepro
    field pretab like plaviv.pretab
    field vencod like plani.vencod.

def temp-table tt-ven
    field etbcod like plani.etbcod
    field vencod like plani.vencod
    field movpc  like movim.movpc
    field movqtm like movim.movqtm.

def temp-table tt-venpro
    field etbcod like plani.etbcod
    field vencod like plani.vencod
    field procod like produ.procod
    field pronom like produ.pronom
    field movpc  like movim.movpc
    field pre-uni  like movim.movpc
    field movqtm like movim.movqtm.
    
    
def var v-resvenpro as log format "Sim/Nao".
def var v-pula4-18  as log format "Sim/Nao".


repeat:
    for each tt-venpro: delete tt-venpro. end.
    for each tt-cel: delete tt-cel. end.
    for each tt-ven: delete tt-ven. end.
    
    do on error undo:

        update vetbcod label "Filial......" 
               with frame fdata.
               
        if vetbcod <> 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Filial nao Cadastrada".
                undo.
            end.
            else disp estab.etbnom no-label with frame fdata.
        end.
        else disp "TODAS" @ estab.etbnom with frame fdata.
        
    end.           

/*    vdti = today - 1. vdtf = today - 1.*/
    
    update skip
           vdti    label "Data Inicial"
           vdtf    label "Data Final"
           with frame fdata side-label width 80 row 3.


    do on error undo:

        vopecod = 0.         
        update skip vopecod label "Operadora..." 
               with frame fdata side-labels.

        if vopecod = 0
        then disp "Geral" @ operadoras.openom with frame fdata.
        else do:
            find operadoras where operadoras.opecod = vopecod no-lock no-error.
            if not avail operadoras
            then do:
                message "Operadora nao Cadastrada".
                undo.
            end.
            else disp operadoras.openom no-label with frame fdata.
        end.
    end.    
     
    
    update skip
           vtipviv label "Promocao...." format ">>>9"
           with frame fdata.
           
    update skip
           vcodviv label "Plano......."  format ">>>9"
           with frame fdata.

    v-pula4-18 = yes.
    
    update v-resvenpro label "Incluir no relatorio TOTAIS VENDEDOR/PRODUTO"
           v-pula4-18  label "Considerar PROMOCAO 4 e PLANO 18............"
           with frame f-excecoes centered side-labels. 
    
    for each estab where estab.etbcod = (if vetbcod <> 0
                                         then vetbcod
                                         else estab.etbcod) no-lock:
        if estab.etbcod >= 90
        then next.
        
        disp estab.etbcod label "Loja"
             with frame f-mostra centered side-labels. pause 0.
             
        do vdata = vdti to vdtf:
            disp vdata no-label
                 with frame f-mostra. pause 0.
        
            for each plani where plani.movtdc = 5
                             and plani.etbcod = estab.etbcod
                             and plani.pladat = vdata no-lock:
/**
                if vtipviv <> 0
                then if int(acha("TIPVIV",plani.notobs[3])) <> vtipviv
                     then next.
                
                if vcodviv <> 0
                then if int(acha("CODVIV",plani.notobs[3])) <> vcodviv
                     then next.
                 
                if not v-pula4-18
                then do:
                    if int(acha("TIPVIV",plani.notobs[3])) = 4 and
                       int(acha("CODVIV",plani.notobs[3])) = 18
                    then next.
                end.

                if vopecod <> 0
                then do:
                    find promoviv where promoviv.opecod = vopecod
                                    and promoviv.tipviv =
                                     int(acha("TIPVIV",plani.notobs[3]))
                                    no-lock no-error.
                    if not avail promoviv
                    then next.
                end.
**/                
                for each movim where movim.etbcod = plani.etbcod
                                 and movim.placod = plani.placod
                                 and movim.movdat = plani.pladat
                                 and movim.movtdc = plani.movtdc no-lock:

                    /****/
                    find produ where produ.procod = movim.procod no-lock no-error.
                    
                    if vtipviv <> 0
                    then if movim.ocnum[8] <> vtipviv
                         then next.
                 
                    if vcodviv <> 0
                    then if movim.ocnum[9] <> vcodviv
                         then next.
                  
                    if not v-pula4-18
                    then do:
                        if movim.ocnum[8] = 4 and
                           movim.ocnum[9] = 18
                        then next.
                    end.
               
                    if vopecod <> 0
                    then do: 
                        if vopecod = 2 
                        then do:
                        
                            if produ.fabcod <> 104655
                            then next.
                        
                        end.
                        else do:
                        find promoviv where promoviv.opecod = vopecod
                                        and promoviv.tipviv = movim.ocnum[8]
                                     no-lock no-error.
                        if not avail promoviv
                        then next.
                    end. end.
                     
                    /****/
                    
                    find produ where
                         produ.procod = movim.procod no-lock no-error.
                         
                    if not avail produ
                    then next.

                    if produ.clacod <> 100 and
                       produ.clacod <> 101 and
                       produ.clacod <> 102 and 
                       produ.clacod <> 103 and
                       produ.clacod <> 106 and
                       produ.clacod <> 108
                    then next.
                    
                    find first tt-cel where
                               tt-cel.etbcod = movim.etbcod
                           and tt-cel.procod = movim.procod
                           and tt-cel.placod = movim.placod
                           no-error.
                    if not avail tt-cel
                    then do:
                        find plaviv where 
                             plaviv.tipviv = movim.ocnum[8]
                         and plaviv.codviv = movim.ocnum[9]
                         and plaviv.procod = produ.procod no-lock no-error.
                         
                        create tt-cel.
                        assign tt-cel.etbcod = movim.etbcod
                               tt-cel.etbnom = estab.etbnom
                               tt-cel.placod = movim.placod
                               tt-cel.procod = movim.procod
                               tt-cel.pronom = produ.pronom
                               tt-cel.tipviv = movim.ocnum[8]
                               tt-cel.codviv = movim.ocnum[9]
                               tt-cel.numero = plani.numero
                               tt-cel.pladat = plani.pladat
                               tt-cel.movpc  = movim.movpc
                               tt-cel.movqtm  = movim.movqtm
                               tt-cel.pretab = 
                              (if int(acha("PRETAB",plani.notobs[3])) <> ?
                               then int(acha("PRETAB",plani.notobs[3]))
                               else (if avail plaviv
                                     then plaviv.pretab
                                     else 0 ))
                               tt-cel.prepro =
                              (if int(acha("PREPRO",plani.notobs[3])) <> ?
                               then int(acha("PREPRO",plani.notobs[3]))
                               else (if avail plaviv
                                     then plaviv.prepro
                                     else 0)).

                            tt-cel.vencod = plani.vencod.
                             
                            if tt-cel.tipviv <> ? and tt-cel.codviv <> ?
                            then do:
                               if produ.clacod = 102
                               then tt-cel.tipo = "PRE".
                               else do:
                                   if produ.clacod = 101
                                   then do:
                                       if tt-cel.tipviv = 4 and
                                          tt-cel.codviv = 18
                                       then tt-cel.tipo = "POS".
                                       else tt-cel.tipo = "POS->PRE".
                                   end.
                               end.
                               
                               if tt-cel.codviv = 1001 or
                                  tt-cel.codviv = 1002
                               then tt-cel.tipo = "PRE".
                               if tt-cel.codviv = 1003 or
                                  tt-cel.codviv = 1004 or
                                  tt-cel.codviv = 1005
                               then tt-cel.tipo = "POS".
                               
                            end.    
                    end.
                end.
            end.
        end.             
    end.

    for each tt-cel:
        if tt-cel.tipviv = ? and tt-cel.codviv = ?
        then assign tt-cel.tipviv = 0
                    tt-cel.codviv = 0.
        /*** TT-VEN ***/
        find tt-ven where tt-ven.etbcod = tt-cel.etbcod
                      and tt-ven.vencod = tt-cel.vencod no-error.
        if not avail tt-ven
        then do:
            create tt-ven.
            assign tt-ven.etbcod = tt-cel.etbcod
                   tt-ven.vencod = tt-cel.vencod.
        end.            
                              
        assign tt-ven.movqtm = tt-ven.movqtm + tt-cel.movqtm 
               tt-ven.movpc  = tt-ven.movpc  + tt-cel.movpc.
        /*** TT-VEN ***/
        
        /*** TT-VENPRO ***/
        find tt-venpro where tt-venpro.etbcod = tt-cel.etbcod
                         and tt-venpro.vencod = tt-cel.vencod
                         and tt-venpro.procod = tt-cel.procod no-error.
        if not avail tt-venpro
        then do:
            create tt-venpro.
            assign tt-venpro.etbcod = tt-cel.etbcod
                   tt-venpro.vencod = tt-cel.vencod
                   tt-venpro.procod = tt-cel.procod
                   tt-venpro.pre-uni = tt-cel.movpc
                   tt-venpro.pronom = tt-cel.pronom.
        end.            
                              
        assign tt-venpro.movqtm = tt-venpro.movqtm + tt-cel.movqtm 
               tt-venpro.movpc  = tt-venpro.movpc  + 
                    (tt-cel.movpc * tt-cel.movqtm).

        /*** TT-VENPRO ***/
        
    end.        
        
    if opsys = "UNIX"
    then varquivo = "../relat/rel-vivo." + string(time).
    else varquivo = "..\relat\rel-vivo." + string(time).
 
    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""rel-vivo""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """LISTAGEM DE CELULARES VENDIDOS - DE "" 
                   + string(vdti,""99/99/9999"") + "" A ""
                   + string(vdtf,""99/99/9999"")"
        &Width     = "130"
        &Form      = "frame f-cabcab"}

    vqtd-nf = 0. 
    for each tt-cel break by tt-cel.etbcod
                          by tt-cel.pladat
                          by tt-cel.tipviv
                          by tt-cel.codviv 
                          by tt-cel.numero
                          by tt-cel.procod:
              /*
        if first-of(tt-cel.numero)
        then*/ vqtd-nf = vqtd-nf + tt-cel.movqtm.
        
        if first-of(tt-cel.etbcod)
        then
            disp skip(1)
                 tt-cel.etbcod label "Filial" format ">>9"
                 tt-cel.etbnom no-label
                 skip(1)
                 with frame f-etb1 side-labels.
                
        if first-of(tt-cel.pladat)
        then
            disp space(3) tt-cel.pladat label "Dia"
                 with frame f-dt1 side-labels.
        
        
        disp space(6)
             tt-cel.tipviv column-label "Pro" format ">>>9"
             tt-cel.codviv column-label "Pla" format ">>>9"
             tt-cel.numero column-label "Número NF" format ">>>>>>9"
             tt-cel.procod column-label "Produto" format ">>>>>>9"
             tt-cel.pronom column-label "Descrição" format "x(40)"
             tt-cel.tipo   column-label "Tipo"
             tt-cel.pretab column-label "Preço!Tabela"
             tt-cel.prepro column-label "Preço!Promoção"
             tt-cel.movpc  column-label "Preço!Vendido"
             with frame f-cel width 130 down.
        down with frame f-cel.
    

    
    end.

    disp vqtd-nf label "QTD" 
         with frame f-tot centered side-labels.
         
    disp skip(3) 
         "RESUMO POR VENDEDOR"
         with frame f-cab-ven centered side-labels.       
         
    for each tt-ven break by tt-ven.etbcod
                          by tt-ven.vencod.
         
        if first-of(tt-ven.etbcod)
        then do:
            find estab where estab.etbcod = tt-ven.etbcod no-lock no-error.
            disp skip(1)
                 tt-ven.etbcod label "Filial" format ">>9"
                 estab.etbnom  no-label when avail estab
                 skip(1)
                 with frame f-etb-ven side-labels.
        end.
        
        find func where func.etbcod = tt-ven.etbcod
                    and func.funcod = tt-ven.vencod no-lock no-error.

        disp tt-ven.vencod               column-label "Codigo"
             func.funnom when avail func column-label "Vendedor"
             tt-ven.movqtm    column-label "Qtd"   (total by tt-ven.etbcod)
             tt-ven.movpc     column-label "Valor" (total by tt-ven.etbcod)
             with frame f-ven centered down.
        down with frame f-ven.
         
    end.
        
        
    /**** TOTAIS VENDEDOR/PRODUTOS ****/    
        
    if v-resvenpro
    then do:        
        
        disp skip(3) 
             "TOTAIS - VENDEDOR / PRODUTOS"
             with frame f-cab-ven1 centered side-labels.       
         
        for each tt-venpro break by tt-venpro.etbcod
                                 by tt-venpro.vencod
                                 by tt-venpro.procod.
         
            if first-of(tt-venpro.etbcod)
            then do:
                find estab where 
                     estab.etbcod = tt-venpro.etbcod no-lock no-error.

                disp skip(1)
                     tt-venpro.etbcod label "Filial" format ">>9"
                     estab.etbnom  no-label when avail estab
                     skip(1)
                     with frame f-etb-ven1 side-labels.
            end.
        
            if first-of(tt-venpro.vencod)
            then do:
                find func where func.etbcod = tt-venpro.etbcod
                        and func.funcod = tt-venpro.vencod no-lock no-error.

                disp skip(1)
                     tt-venpro.vencod label "Vendedor"
                     func.funnom no-label when avail func
                     skip(1)
                     with frame f-ven-ven1 side-labels.
            end.
                                          /*
            tt-venpro.pre-uni = (tt-venpro.movpc / tt-venpro.movqtm).
                                            */
            disp 
                 tt-venpro.procod    column-label "Produto"
                 tt-venpro.pronom    column-label "Descricao" format "x(40)"
                 tt-venpro.movqtm    column-label "Qtd"
                                     (total by tt-venpro.vencod)
                 tt-venpro.pre-uni   column-label "Preco!Unitario"
                                                   (total by tt-venpro.vencod)

                 tt-venpro.movpc     column-label "Valor" 
                                     (total by tt-venpro.vencod)
                 with frame f-ven1 centered down width 100.
            down with frame f-ven1.
         
    end.
        
        
    end.
            
    /****                          ****/        
        
    if opsys = "UNIX"
    then do:
        output close.
        run visurel.p (input varquivo,
                       input "").
    end.                       
    else do:
        {mrod.i}.
    end.
end.