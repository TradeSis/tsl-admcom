{admcab.i}

def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var val_fin like plani.platot.
def var v-valor like plani.platot.

def var vforcod  like forne.forcod.
def var vetbcod  like estab.etbcod.
def var varquivo as char.

def var dias-uteis as int.

def var vdata-i  as date format "99/99/9999".
def var vdata-f  as date format "99/99/9999".

def temp-table tt-new
    field etbcod   like estab.etbcod
    field meta     like metven.metval  format ">>,>>>,>>9.99"
    field venda    as   dec            format ">>>,>>>,>>9.99"
    field previsto as   dec            format "->>,>>>,>>9.99"
    field falta    as   dec            format "->>,>>>,>>9.99"
    field perc     as   dec            format "->>9.99"
    field estfor   like estoq.estvenda format ">>,>>>,>>9.99" 
    field estger   like estoq.estvenda format ">>,>>>,>>9.99"
    field parti    as   int            format ">>>9"
    field giro     as   dec            format ">>9.99"
    field real     as   dec format "->>,>>>,>>9.99"
    field dias-uteis-hoje    as int
    field dias-uteis-periodo as int
    index i-new    is   primary unique etbcod.

repeat:

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/rmetfree.txt".
    else varquivo = "l:\relat\rmetfree.txt".
    
    do on error undo:

        vforcod = 5027.
    
        update vforcod label "Fornecedor.."
               help "Informe o codigo do fornecedor ou zero para todos" 
               with frame f-dados width 80 side-labels.
        if vforcod = 0
        then disp "TODOS" @ forne.fornom with frame f-dados.
        else do:
            find forne where forne.forcod = vforcod no-lock no-error.
            if not avail forne
            then do:
                message "Fornecedor nao Cadastrado".
                undo.
            end.
            else disp forne.fornom no-label with frame f-dados.
        end.        
    
    end.
    
    update vdata-i label "Data Inicial"
           vdata-f label "Data Final"
           with frame f-dados. 
    
    disp string(time,"hh:mm:ss") label "Inicio"
         with frame f-ini centered side-labels.
         
    message "Calculando Metas...".            
    run p-metas(input month(vdata-i), input year(vdata-i), input vforcod).
    hide message no-pause.
                     
    find first tt-new where tt-new.etbcod = 0 no-error.
    if avail tt-new
    then delete tt-new.

    message "Calculando Estoque...".
    run p-estoque.
    hide message no-pause.

    message "Calculando Vendas...".
    run p-vendas(input vdata-i, input vdata-f).
    hide message no-pause.
    
    run p-grava-dias-uteis(input vdata-i, input vdata-f).
    
    run p-calculos.

    disp string(time,"hh:mm:ss") label "Fim..."
         with frame f-fim centered side-labels. pause 2 no-message.

    hide frame f-ini no-pause.
    hide frame f-fim no-pause.
    
    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "63" 
        &Cond-Var  = "125"  
        &Page-Line = "66"
        &Nom-Rel   = ""rmetfree""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""  
        &Tit-Rel   = """PROMO FREE - PERIODO DE ""
                   + string(vdata-i,""99/99/9999"") 
                   + "" A ""
                   + string(vdata-f,""99/99/9999"")"
        &Width     = "140"
        &Form      = "frame f-cabcab"}

        for each tt-new.
            disp tt-new.etbcod   column-label "FIL" format ">>9"
                 tt-new.meta     column-label "META"                (total)
                 tt-new.venda    column-label "VENDA"               (total)
                 tt-new.previsto column-label "PREVISTO"            (total)
                 tt-new.falta    column-label "FALTA"               (total)

                 tt-new.perc     column-label "%" 
                 tt-new.estfor   column-label "ESTOQUE!FORNECEDOR"  (total)
                 tt-new.estger   column-label "ESTOQUE!GERAL"       (total)
                 tt-new.parti    column-label "PARTIC!IPACAO"        
                 tt-new.giro     column-label "GIRO"
                 tt-new.real     column-label "REAL"
                 
                 with frame f-tt-new width 140 down.
                 down with frame f-tt-new.
                 
        end.
    output close.
    
    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else do:
        {mrod.i}
    end.        

end.                                 

procedure p-metas:

    def input parameter p-mes as int format "99".
    def input parameter p-ano as int format "9999".
    def input parameter p-forcod  like forne.forcod.
    
    for each estab no-lock:
        for each metven use-index ind-1
                        where metven.etbcod =  estab.etbcod 
                          and metven.forcod = (if p-forcod <> 0
                                               then p-forcod
                                               else metven.forcod)
                          and metven.metano =  p-ano
                          and metven.metmes =  p-mes no-lock:
            
            find tt-new where tt-new.etbcod = metven.etbcod no-error.
            if not avail tt-new
            then do:
           
                create tt-new.
                assign tt-new.etbcod = metven.etbcod.

            end.
            tt-new.meta = tt-new.meta + metven.metval.
            
        end.
    end.

end procedure.

procedure p-estoque:
   
   for each tt-new:
       for each estoq where estoq.etbcod = tt-new.etbcod 
                     and estoq.estatual > 0 no-lock.
    
           find produ of estoq no-lock no-error.
           if not avail produ
           then next.

           if produ.catcod = 41
           then
           tt-new.estger = tt-new.estger + (estoq.estatual * estoq.estvenda).

           if vforcod <> 0
           then if vforcod = produ.fabcod
                then tt-new.estfor = tt-new.estfor 
                                   + (estoq.estatual * estoq.estvenda).

       end.
   end.
end procedure.

procedure p-vendas:
    def input parameter p-data-i as date format "99/99/9999".
    def input parameter p-data-f as date format "99/99/9999".        
        
    for each tt-new:
        for each plani where plani.movtdc  = 5
                         and plani.etbcod  = tt-new.etbcod
                         and plani.pladat >= p-data-i
                         and plani.pladat <= p-data-f no-lock:

            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock:
            
                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ
                then next.
                
                if vforcod <> 0
                then if vforcod <> produ.fabcod
                     then next.

              
/*****************/
                
            val_fin = 0.                    
            val_des = 0.   
            val_dev = 0.   
            val_acr = 0. 
            val_com = 0.
            v-valor = 0.
                         
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

            val_com = (movim.movpc * movim.movqtm) - 
                      val_dev - val_des + val_acr +  val_fin. 

            v-valor = val_com.
                
            tt-new.venda = tt-new.venda + v-valor.
                
/****************/                
                
/*                tt-new.venda = tt-new.venda + (movim.movpc * movim.movqtm). */
                
                
                /*
                if plani.biss > 0
                then tt-new.venda = tt-new.venda +  plani.biss.
                else tt-new.venda = tt-new.venda 
                                  + (plani.platot - plani.vlserv).
                */
            end.
        end.
    end.
    
end procedure.

procedure p-calculos:

    for each tt-new:
        
        assign
            tt-new.previsto = (tt-new.meta / tt-new.dias-uteis-hoje) 
                            * tt-new.dias-uteis-periodo
            tt-new.falta    = (tt-new.venda - tt-new.previsto)
            tt-new.perc     = (((tt-new.venda / tt-new.previsto) - 1) * 100)
            tt-new.parti    = ((tt-new.estfor / tt-new.estger) * 100)
            tt-new.giro     = (tt-new.estfor / tt-new.meta)
            tt-new.real     = ((tt-new.estfor / tt-new.venda) - tt-new.meta).
    
    end.

end procedure.

procedure p-grava-dias-uteis:
    def input  parameter p-datai      as   date format "99/99/9999".
    def input  parameter p-dataf      as   date format "99/99/9999".
    def var vdias-uteis as int.
    
    for each tt-new:

        vdias-uteis = 0.
        run p-dias-uteis(input tt-new.etbcod,
                         input p-datai,
                         input (if today < p-dataf
                                then today
                                else p-dataf),
                         output vdias-uteis).
                         
        tt-new.dias-uteis-periodo = vdias-uteis.

        vdias-uteis = 0.
        run p-dias-uteis(input tt-new.etbcod,
                         input p-datai,
                         input (if today < p-dataf
                                then today
                                else p-dataf),
                         output vdias-uteis).
                         
        tt-new.dias-uteis-hoje = vdias-uteis.


    end.
    
end procedure.


procedure p-dias-uteis:
    def input  parameter p-etbcod      like estab.etbcod.
    def input  parameter p-datai      as   date format "99/99/9999".
    def input  parameter p-dataf      as   date format "99/99/9999".
    def output parameter p-dias-uteis as   int.
    def var ii as int.
    def var vfer as int. 
    def var vv as date.
    
    assign ii   = 0 
           vfer = 0 
           p-dias-uteis = 0.
        
    do vv = p-datai to p-dataf:

        if weekday(vv) = 1 
        then ii = ii + 1. 
        
        find dtesp where dtesp.datesp = vv 
                     and dtesp.etbcod = p-etbcod no-lock no-error.
        if avail dtesp
        then vfer = vfer + 1.
           
    end.

    p-dias-uteis = int(day(p-dataf)) - ii - vfer.
end procedure.

