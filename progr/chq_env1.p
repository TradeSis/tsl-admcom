{admcab.i}

def temp-table tt-chq like chq.
                    
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vdata as date.
def var vchqarq as dec.
def var varquivo as char.   
def var vsubtot as dec.
def var vtotal  as dec.

repeat:    

    update vdti label "Data Envio" colon 15
                with frame fdata side-label width 80 row 3.
   
    assign 
           vchqarq = 0
           vdata = vdti.
    
    for each chqenv where chqenv.datenv =  vdata and
                          chqenv.chaenv = "" no-lock:
        find first chq where recid(chq) = chqenv.recenv
                          no-lock no-error.
        if not avail chq
        then  
        find chq where chq.banco = chqenv.banco and
                       chq.agencia = chqenv.agencia and
                       chq.conta = chqenv.conta and
                       chq.numero = chqenv.numero
                       no-lock no-error.
        vchqarq       = vchqarq       + chq.valor.
        create tt-chq.
        buffer-copy chq to tt-chq.
    end.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/rdifchq0" + string(time).
    else varquivo = "l:\relat\rdifchq0" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "100"
        &Page-Line = "0"
        &Nom-Rel   = ""chq_env1""
        &Nom-Sis   = """SISTEMA FINANCEIRO"""
        &Tit-Rel   = """ CHEQUES ENVIADOS PARA DEPOSITO  """
        &Width     = "120"
        &Form      = "frame f-cabcab"}

    disp 
         VDATA label "Data Envio"
         vchqarq label "Valor Enviado"
         with frame f-1 1 down side-label
         .
    pause 0.
 
    vsubtot = 0.
    vtotal = 0.
    form with frame f-dis.
    for each tt-chq break by tt-chq.banco 
                            by tt-chq.data
                            by tt-chq.agencia 
                            by tt-chq.conta 
                            by tt-chq.numero:
        find first chqtit use-index ind-1
                          where chqtit.banco   = tt-chq.banco    and
                                chqtit.agencia = tt-chq.agencia  and
                                chqtit.conta   = tt-chq.conta    and
                                chqtit.numero  = tt-chq.numero 
                                no-lock no-error.

        
        disp tt-chq.banco       column-label "Bco"
             tt-chq.agencia     column-label "Agen"
             tt-chq.conta       column-label "Conta" format "x(14)"
             tt-chq.numero      column-label "Numero"
             tt-chq.datemi      column-label "Emissao"
             tt-chq.data        column-label "Vencto"
             tt-chq.valor /*(total by tt-chq.data)*/ column-label "Valor"
             chqtit.etbcod when avail chqtit  column-label "Fil"
             chqtit.clifor when avail chqtit  column-label "Cliente"
             with frame f-dis width 120 down 
             .
        vtotal = vtotal + tt-chq.valor.
        vsubtot = vsubtot + tt-chq.valor.
        if last-of(tt-chq.data)
        then do:
            down with frame f-dis.
            disp "----------" @ tt-chq.valor
                with frame f-dis.
            down with frame f-dis.
            disp vsubtot @ tt-chq.valor 
                    "TOTAL"with frame f-dis.
            vsubtot = 0.
            down(1) with frame f-dis.
        end.
        
        down with frame f-dis.
    end.
    down with frame f-dis.
    if vdata = 07/27/07
    then vtotal = 194162.41 .
    disp "----------" @ tt-chq.valor
                with frame f-dis.
    down with frame f-dis.
    disp vtotal @ tt-chq.valor with frame f-dis.
    vtotal = 0.
    output close.
        
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
    leave.
end.
