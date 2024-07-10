{admcab.i}

def var vopecod like operadoras.opecod.

def temp-table tt-planos
    field codviv as int format ">>>9"
    index ch-codviv codviv.

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
    field vencod like plani.vencod
    field numhab as char.

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
           
    do on error undo:

      repeat:
        vcodviv = 0.
        update skip
               vcodviv label "Plano......."  format ">>>9"
               help "Informe os planos desejados ou 0 para continuar."
               with frame fdata.
        if vcodviv = 0
        then leave.
        else do:
            find tt-planos where tt-planos.codviv = vcodviv no-error.
            if not avail tt-planos
            then do:
                create tt-planos.
                assign tt-planos.codviv = vcodviv.
            end.
        end.
        
        disp tt-planos.codviv column-label "Planos"  with centered down.
        
      end.

    end.
    
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
                 
                    find first tt-planos no-error.
                    if not avail tt-planos
                    then do:  
                        if vcodviv <> 0 
                        then if movim.ocnum[9] <> vcodviv 
                             then next.
                    end.
                    else do:
                        find first tt-planos where
                                   tt-planos.codviv = movim.ocnum[9] no-error.
                        if not avail tt-planos
                        then next. 
                    end.
                    
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
                       produ.clacod <> 107 and
                       produ.clacod <> 191 and
                       produ.clacod <> 104 and
                       produ.clacod <> 192 and
                       produ.clacod <> 193 and
                       produ.clacod <> 108 and
                       produ.clacod <> 109 and
                       produ.clacod <> 201
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

                               
                               find first tbprice where 
                                          tbprice.etb_venda  = movim.etbcod
                                      and tbprice.data_venda = plani.pladat
                                      and tbprice.nota_venda = plani.numero  
                                          no-lock no-error.
                               if avail tbprice then    
                assign tt-cel.numhab = if acha("CEL-NUMERO",tbprice.char2) = ? then "" else acha("CEL-NUMERO",tbprice.char2).
                               else 
                                     tt-cel.numhab = "".
                               
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
        
        
        disp 
             tt-cel.tipviv column-label "Pro" format ">>>9"
             tt-cel.codviv column-label "Pla" format ">>>9"
             tt-cel.numero column-label "Núm NF" format ">>>>>>9"
             tt-cel.procod column-label "Produto" format ">>>>>>9"
             tt-cel.pronom column-label "Descrição" format "x(40)"
             tt-cel.tipo   column-label "Tipo"
             tt-cel.pretab column-label "Preço!Tabela"
             tt-cel.prepro column-label "Preço!Promoção"
             tt-cel.movpc  column-label "Preço!Vendido"
             tt-cel.numhab column-label "Numero" format "99999999999"
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

/****
procedure p-brw:


def button btn-inc label "INCLUI".  
def button btn-exc label "EXCLUI".  
def button btn-sai label "SAIR".
def button btn-tod label "TODOS".
def button btn-atu label "ATUALIZA".


def query qbrowse for tt-browse
    fields(tt-browse.marca tt-browse.codviv).

def browse bbrowse query qbrowse no-lock
    display tt-browse.marca  
            tt-browse.codviv
    enable  tt-browse.marca 
    with width 25 3 down no-row-markers.

def var icodviv  as int format ">>>9".

def frame f-browse
    icodviv label "Plano "
    skip
    bbrowse                                          at 25
    btn-inc                                          at 01
    btn-exc                                          at 20
    btn-tod                                          at 36
    "[F5 DELETE LINHA]"                              at 45
    btn-sai                                          at 68 
    with side-labels width 80 col 1 row 10. 

&scoped-define frame-name f-browse
&scoped-define open-query open query qbrowse for each tt-browse no-lock
&scoped-define list-1 btn-inc btn-exc btn-tod btn-sai 



/* ------------------------------------------------------------------------ */

               assign icodviv:visible = no. 
               


on choose of btn-inc in frame {&frame-name} /* Insert */
do:
                       assign icodviv = 0.
                        assign icodviv:visible = yes. 
                        update icodviv with frame f-browse.
                       /* if icodviv = 0
                        then do:
                                leave.
                        end.*/        
                        find first planoviv where
                                   planoviv.codviv = icodviv no-lock no-error.
                        if not avail planoviv
                        then do:
                                message "Plano nao encontrado!"
                                        view-as alert-box.
                                undo, retry.
                        end.   
                        create tt-browse.
                        assign tt-browse.codviv = icodviv
                               tt-browse.marca  = "*".
                        open query qbrowse for each tt-browse.
                        disp bbrowse with frame f-browse.
                        assign icodviv:visible = no.
                        {&open-query}.
                        message "AQUI" view-as alert-box.
end. 

on F5 of bbrowse /* Delete */
do:
           find current tt-browse  exclusive-lock no-error.
           if avail tt-browse
           then do:
                   delete tt-browse.
                   open query qbrowse for each tt-browse.
                   enable bbrowse 
                          {&list-1} with frame {&frame-name}.
                   apply "entry" to browse bbrowse.

           end.  
 end.

on choose of btn-tod in frame {&frame-name} /* Todos */
do:
   for each planoviv no-lock:
      find first tt-browse where
                 tt-browse.codviv = planoviv.codviv exclusive-lock no-error.
      if not avail tt-browse
      then do:           
              create tt-browse.
              assign tt-browse.marca = "*"
                     tt-browse.codviv = planoviv.codviv.
              open query qbrowse for each tt-browse.
              assign icodviv:visible = no.
      end.
   end.
end.

on choose of btn-sai in frame {&frame-name} /* Sair */
do:
     apply "window-close" to current-window.
end.

/* ------------- MAIN ------------------------------------------------------- */
     
{&open-query}.

assign icodviv:visible = no.
  
enable bbrowse 
       {&list-1} with frame {&frame-name}.
apply "value-changed" to browse bbrowse.

wait-for window-close of current-window.


end procedure.

***/