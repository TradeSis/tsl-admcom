/* */
{admcab.i} 

def var vimprimir as log format "Impressora/Tela".

def var vok        as   log.
def var vcatcod    like com.produ.catcod.
def var i          as   integer.
def var varquivo   as   char format "x(20)".
def var vtotal     like com.plani.platot.

def var vcontra    as   integer.

def var vdata      like com.plani.pladat.
def var vdtini     like com.plani.pladat         initial today.
def var vdtfim     like com.plani.pladat         initial today.
def var vetbi      like estab.etbcod.
def var vetbf      like estab.etbcod.

def var val_fin as dec.
def var val_des as dec.
def var val_dev as dec.
def var val_acr as dec.
def var val_com as dec.
def var valtotal as dec. 

def var vdec-tot-plan-bis as dec  .

def stream stela.

def temp-table tt-ven
    field etbcod like estab.etbcod
    field vencod like ger.func.funcod
    field valor  as   dec format ">>,>>>,>>9.99"
    field contra as   integer
    field acr      as dec 
    field venda    as dec  .

def temp-table tt-plano
    
    field etbcod   like estab.etbcod
    field vencod   like ger.func.funcod
    
    field fincod   like finan.fincod 
    field contra   as integer 
    field valor    as dec format ">>,>>>,>>9.99"
    field acr      as dec 
    field venda    as dec  .
    
                                /*****fab******/
def temp-table tt-total-plano
    field etbcod   like estab.etbcod
    field vencod   like ger.func.funcod
    field fincod   like finan.fincod     
    field valor    as dec format ">>,>>>,>>9.99"   
    field contra   as integer
    field acr      as dec 
    field venda    as dec  .
    
def temp-table tt-total-ven
    field etbcod    like estab.etbcod
    field vencod    like ger.func.funcod
    field valor     as dec format ">>,>>>,>>9.99"
    field contra    as integer
    field acr      as dec 
    field venda    as dec 
    field biss     as dec.

                                       /******fab*******/

repeat:

    assign vtotal = 0
           vcontra = 0
           i      = 0.
    
    for each tt-ven. delete tt-ven. end.
    for each tt-total-plano. delete tt-total-plano. end.
    for each tt-total-ven. delete tt-total-ven. end.
    for each tt-plano:
        delete tt-plano.
        i = i + 1.
        display "AGUARDE, ZERANDO ARQUIVOS   " i
                with frame f-disp side-label row 15 centered.
        pause 0.
    end.
    
    hide frame f-disp no-pause.

    update vcatcod label "Departamento"
           with frame f1.
    
    find com.categoria
               where com.categoria.catcod = vcatcod no-lock no-error.
    if not avail com.categoria
    then do:
        message "Departamento nao Cadastrado".
        undo.
    end.
    else display com.categoria.catnom no-label with frame f1.

    /* assign vetbi   = setbcod
           vetbf   = setbcod. */
    
    update vetbi label "Filial Inicial"
           with frame f1.              
    
     update vetbf label "Filial Final"   
             with frame f1.                 
    
    disp vetbi colon 13 label "Filial"
         /*vetbf label "Filial"*/
           with frame f1 side-label width 80 color white/cyan.

    update vdtini    label "Data Inicial"
           vdtfim    label "Data Final" with frame f2
                        side-label width 80 color white/cyan.
    def var p-valor as dec.
    p-valor = 0.
    vimprimir = no.
    update vimprimir       no-label
           help " [ I ]   Impressora     [ T ]   Tela       "
           with frame f2.
              
                            /*
        do vdata = vdtini to vdtfim:
                          */
                          
           for each com.plani use-index pladat 
                          where com.plani.movtdc = 5
                            and com.plani.etbcod = vetbi
                            and com.plani.pladat >= vdtini
                            and com.plani.pladat <= vdtfim no-lock:
                            
               vok = no.

              valtotal = 0.

               for each com.movim where 
                        com.movim.placod = com.plani.placod
                    and com.movim.etbcod = com.plani.etbcod
                    and com.movim.movtdc = com.plani.movtdc
                    and com.movim.movdat = com.plani.pladat no-lock:
                                
                   find com.produ where
                        com.produ.procod = com.movim.procod
                                                        no-lock no-error.
                   if not avail com.produ
                   then next.
                   if com.produ.catcod = vcatcod 
                   then vok = yes.
                   else next.
                   
                   assign val_fin = 0 
                       val_des = 0
                       val_dev = 0
                       val_acr = 0
                       val_com = 0.
                         
                val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.acfprod.
                val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.descprod.
                val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.vlserv.
    
                if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
                then
                    val_fin =  ((((movim.movpc * movim.movqtm) 
                        - val_dev - val_des) /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).

                val_com = (movim.movpc * movim.movqtm) 
                        - val_dev - val_des + val_acr + val_fin. 
                if val_com = ?
                then val_com = 0.
                
                valtotal = valtotal + val_com.
                   
               end.
               
               if vok = no 
               then next.

               val_acr  = com.plani.acfprod.
               if com.plani.biss > (com.plani.platot - com.plani.vlserv)  
               then val_acr  = com.plani.biss  - 
                               (com.plani.platot - com.plani.vlserv).
                                      
               
               output stream stela to terminal.
                   display stream stela
                           com.plani.etbcod
                           com.plani.pladat
                           com.plani.numero format ">>>>>>>>>"
                           with frame f-stream row 10 centered side-label.
                   pause 0.
               output stream stela close.
               
               if com.plani.crecod = 2
               then do:
                   find first tt-plano where 
                              tt-plano.etbcod = com.plani.etbcod
                          and tt-plano.vencod = com.plani.vencod
                          and tt-plano.fincod = com.plani.pedcod no-error.

                   if not avail tt-plano
                   then do:
                       create tt-plano.
                       assign tt-plano.etbcod = com.plani.etbcod
                              tt-plano.vencod = com.plani.vencod
                              tt-plano.fincod = com.plani.pedcod.
                   end.
                       
                   assign tt-plano.contra = tt-plano.contra + 1
                          tt-plano.valor  = tt-plano.valor 
                                          + com.plani.biss
                          tt-plano.acr    = tt-plano.acr + val_acr
                          tt-plano.venda  = tt-plano.venda + valtotal.

                          
                   find tt-ven where tt-ven.etbcod = com.plani.etbcod
                                 and tt-ven.vencod = com.plani.vencod
                                 no-error.
                   if not avail tt-ven
                   then do:
                       create tt-ven.
                       assign tt-ven.etbcod = com.plani.etbcod
                              tt-ven.vencod = com.plani.vencod.
                   end.

                   assign tt-ven.valor   = tt-ven.valor + com.plani.biss
                          tt-ven.contra  = tt-ven.contra + 1
                          tt-ven.acr     = tt-ven.acr + val_acr
                          tt-ven.venda   = tt-ven.venda + valtotal.
                   
               end.
               else do:
                    
                    find first tt-plano where 
                               tt-plano.etbcod = com.plani.etbcod
                           and tt-plano.vencod = com.plani.vencod
                           and tt-plano.fincod = 0 no-error.

                    if not avail tt-plano
                    then do:
                        create tt-plano.
                        assign tt-plano.etbcod = com.plani.etbcod
                               tt-plano.vencod = com.plani.vencod
                               tt-plano.fincod = 0.
                    end.
                    
                    assign tt-plano.contra = tt-plano.contra + 1
                           tt-plano.valor  = tt-plano.valor 
                                           + com.plani.platot
                                           - com.plani.vlserv
                                           - com.plani.descprod
                                           + com.plani.acfprod
                           tt-plano.acr    = tt-plano.acr + val_acr
                           tt-plano.venda  = tt-plano.venda + valtotal.

                   find tt-ven where tt-ven.etbcod = com.plani.etbcod
                                 and tt-ven.vencod = com.plani.vencod
                                 no-error.
                   if not avail tt-ven
                   then do:
                       create tt-ven.
                       assign tt-ven.etbcod = com.plani.etbcod
                              tt-ven.vencod = com.plani.vencod.
                   end.
                
                   assign tt-ven.contra = tt-ven.contra + 1
                          tt-ven.valor = tt-ven.valor
                                       + (com.plani.platot 
                                       -  com.plani.vlserv 
                                       -  com.plani.descprod
                                       +  com.plani.acfprod)
                          tt-ven.acr    = tt-ven.acr + val_acr
                          tt-ven.venda  = tt-ven.venda + valtotal.
                                       
                                           
                end.
                
            end.
/*        end.*/

    for each tt-plano:
        vtotal = vtotal + tt-plano.valor.
        vcontra = vcontra + tt-plano.contra.
    end.
    
    def var v-valor as dec.
    def var pct as dec.
    def var mpct as dec.
    def var etb-contra as int.
    def var etb-valor  as dec.
    def var etb-acr    as dec.
    def var etb-venda  as dec.
    
    
    form 
         tt-plano.fincod        label "Condicao"  format ">99"
         finan.finnom          format "x(25)"
         tt-plano.contra   column-label "N.Contratos." 
                                  (total by tt-plano.vencod
                                         by tt-plano.etbcod)
         tt-plano.valor    column-label "Valor Total"
                                  (total by tt-plano.vencod
                                         by tt-plano.etbcod)
         pct label " % "  format ">>9.99 %"
          mpct             column-label " M %"  format "->>>9.99%"
                with frame ff.
                
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/anaplaveg" + string(month(today)).
    else varquivo = "l:\relat\anaplaveg" + string(month(today)).

    {mdadmcab.i
             &Saida = "value(varquivo)"
             &Page-Size = "64" 
             &Cond-Var  = "80" 
             &Page-Line = "66" 
             &Nom-Rel   = ""anaplave"" 
             &Nom-Sis   = """SISTEMA CREDIARIO""" 
             &Tit-Rel   = """ ANALISE DE PLANOS POR VENDEDOR - FILIAL ""
                        + string(vetbi) + "" DE "" +
                          string(vdtini) + "" A "" + string(vdtfim)
                        "
             &Width     = "80"
             &Form      = "frame f-cabc1"}

  assign val_acr = 0
         valtotal = 0.

    for each tt-plano break by tt-plano.etbcod
                            by tt-plano.vencod
                            by tt-plano.fincod:
                            
        find finan where finan.fincod = tt-plano.fincod no-lock no-error.
        
        if first-of(tt-plano.etbcod)
        then do:
    
            find estab where estab.etbcod = tt-plano.etbcod no-lock no-error.

            disp skip(1)
                 tt-plano.etbcod label "Filial"
                 estab.etbnom no-label when avail estab
                 skip
                 with frame f-lj side-labels.
        end.

        if first-of(tt-plano.vencod)
        then do:
            find ger.func where
                 ger.func.etbcod = tt-plano.etbcod
             and ger.func.funcod = tt-plano.vencod no-lock no-error.

            disp skip(1) space(2)
                 tt-plano.vencod label "Vendedor"
                 func.funnom no-label when avail func
                 skip(1)
                 with frame f-ve side-labels.
                 
            assign vdec-tot-plan-bis = 0.     
                 
        end.
        
        find tt-ven where tt-ven.etbcod = tt-plano.etbcod
                      and tt-ven.vencod = tt-plano.vencod no-lock no-error.
                      
        pct = (tt-plano.valor / tt-ven.valor) * 100.
        
        mpct = ((tt-plano.acr / tt-plano.venda) * 100). 

        /*
        if tt-plano.fincod = 21
            or tt-plano.fincod = 24
            or tt-plano.fincod = 42
            or tt-plano.fincod = 43
            or tt-plano.fincod = 87
            or tt-plano.fincod = 88
            or tt-plano.fincod = 86            
            or tt-plano.fincod = 15
            or tt-plano.fincod = 17
            or tt-plano.fincod = 44
            or tt-plano.fincod = 46
            or tt-plano.fincod = 66
            or tt-plano.fincod = 67
            or tt-plano.fincod = 68
            or tt-plano.fincod = 76
            or tt-plano.fincod = 77
            or tt-plano.fincod = 89
            or tt-plano.fincod = 90
            or tt-plano.fincod = 91
        then do:
        
            assign vdec-tot-plan-bis = vdec-tot-plan-bis + tt-plano.valor.
            
        end.
        */

        find first tabaux where tabaux.tabela = "PLANOBIZ" and
                                tabaux.valor_campo = string(tt-plano.fincod)
                                no-lock no-error.
        if avail tabaux
        then vdec-tot-plan-bis = vdec-tot-plan-bis + tt-plano.valor.                        
        display 
                tt-plano.fincod        label "Condicao"  format ">99"
                finan.finnom when avail finan  format "x(25)"
                tt-plano.contra   column-label "N.Contratos." 
                              /*    (total by tt-plano.vencod
                                         by tt-plano.etbcod) */
                tt-plano.valor    column-label "Valor Total"
                              /*    (total by tt-plano.vencod
                                         by tt-plano.etbcod) */
                pct label " % "  format ">>9.99 %"
                                 mpct
                with frame ff color white/red width 90
                            /*200*/ row 8 centered down.
                            
            down with frame ff. 
            
            p-valor = p-valor + tt-plano.valor.
            v-valor = v-valor + tt-ven.valor.
            val_acr = val_acr + tt-plano.acr.
            valtotal = valtotal + tt-plano.venda.


       /***fabio*28/04/08 *ch:20093 *inicio***/
        find tt-total-plano where tt-total-plano.etbcod = tt-plano.etbcod and
                                  tt-total-plano.fincod = tt-plano.fincod
                                   no-error.
        if not avail tt-total-plano
        then create tt-total-plano.
        tt-total-plano.etbcod = tt-plano.etbcod.
        tt-total-plano.fincod = tt-plano.fincod.
        tt-total-plano.contra  = tt-total-plano.contra + tt-plano.contra.
        tt-total-plano.valor  = tt-total-plano.valor + tt-plano.valor.
        tt-total-plano.acr   = tt-total-plano.acr   + tt-plano.acr.
        tt-total-plano.venda = tt-total-plano.venda + tt-plano.venda.

        find tt-total-ven where tt-total-ven.etbcod = tt-plano.etbcod and
                                tt-total-ven.vencod =
                                tt-plano.vencod no-error.
        if not avail tt-total-ven
        then create tt-total-ven.
        tt-total-ven.etbcod = tt-plano.etbcod.
        tt-total-ven.vencod = tt-plano.vencod.
        tt-total-ven.valor = tt-total-ven.valor + tt-plano.valor.
        tt-total-ven.contra = tt-total-ven.contra + tt-plano.contra.
        tt-total-ven.acr   = tt-total-ven.acr   + tt-plano.acr.
        tt-total-ven.venda = tt-total-ven.venda + tt-plano.venda.
        tt-total-ven.biss  = tt-total-ven.biss  + tt-ven.valor.

       if last-of(tt-plano.vencod)
       then do:
            find tt-total-ven where tt-total-ven.etbcod = tt-plano.etbcod and
                                    tt-total-ven.vencod = tt-plano.vencod
                                      no-error.
            put "------------"  at 31
                "-------------" at 44
                "--------"      at 58 
                "---------"     at 67.

            disp  "TOTAL GERAL "      @ finan.finnom 
                  tt-total-ven.contra @ tt-plano.contra
                  tt-total-ven.valor  @ tt-plano.valor
                  ((tt-total-ven.valor / tt-total-ven.biss) * 100) 
                                      @ pct
                   ((tt-total-ven.acr / tt-total-ven.venda) * 100) 
                                      @  mpct with frame ff.
            
            put "------------"  at 31
                "-------------" at 44
                "--------"      at 58
                "---------"     at 67.

            down with frame ff.
            
            disp "TOTAL PLANO BISS " at 05
                  vdec-tot-plan-bis  at 47  no-label
        (vdec-tot-plan-bis * 100 / tt-total-ven.valor) format ">>9.99" at 58 no-label
                  "%" at 65
                                     with frame f02  .                
       end.
       
 

    end.

    down(2) with frame ff.
    pct = (p-valor / v-valor) * 100.
    disp "Total " @ finan.finnom
         p-valor @ tt-plano.valor
         pct
        ((val_acr / valtotal) * 100) @ mpct

        with frame ff.
    put skip(1)
            "PERCENTUAL POR PLANO" at 3 
            skip.
    for each tt-total-plano by tt-total-plano.valor desc:            
        find finan where finan.fincod = tt-total-plano.fincod no-lock no-error. 
        disp tt-total-plano.etbcod
             tt-total-plano.fincod
             finan.finnom when avail finan  format "x(25)".
        disp tt-total-plano.valor(total)
             tt-total-plano.valor / p-valor * 100
             label " % "  format ">>9.99 %"
        ((tt-total-plano.acr / tt-total-plano.venda) * 100) 
                                 column-label " M %"  format "->>>9.99%".
    
    end.
    put skip(1)
            "PERCENTUAL POR VENDEDOR" at 3 
            skip.
    for each tt-total-ven  by tt-total-ven.valor 
                              desc .
        find ger.func where
                 ger.func.etbcod = tt-total-ven.etbcod
             and ger.func.funcod = tt-total-ven.vencod no-lock no-error.        
        disp tt-total-ven.etbcod
             tt-total-ven.vencod
             func.funnom no-label when avail func format "x(25)".
        disp tt-total-ven.valor(total)
             tt-total-ven.valor / p-valor * 100
             label " % "  format ">>9.99 %"
       ((tt-total-ven.acr / tt-total-ven.venda) * 100) 
                            column-label " M %"  format "->>>9.99%".

    end.


    
    
    output close.
    
    
    if opsys = "UNIX"
    then do:
    
        if not vimprimir
        then run visurel.p (input varquivo, input "").
        else os-command silent /fiscal/lp value(varquivo).
        
    end.
    
  message "Arquivo gerado: " + varquivo.
    pause.
     {mrod.i}


end. 

