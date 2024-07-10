{admcab.i}

def temp-table tt-chq like chq.
                    
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdtvi as date format "99/99/9999".
def var vdtvf as date format "99/99/9999".
def var vdata as date.
def var vchqarq as dec.
def var varquivo as char.      

repeat:    

    update vdti label "Data Arquivo de"  colon 25
           vdtf label "Ate"
           with frame fdata side-label width 80 row 3.
           
    if vdtf < vdti then undo.
    
    if vdti = ?
    then               
    update vdtvi label "Data vencimento de" colon 25
           vdtvf label "Ate"
                with frame fdata side-label width 80 row 3.

    if vdti = ? and
       vdtvi = ?
    then undo.
       
    if vdtvf < vdtvi
    then undo.
    
    assign 
           vchqarq = 0
           vdata = ?.
    if vdti <> ?
    then
    do vdata = vdti to vdtf:
    for each chqenv where chqenv.datenv =  vdata and
                          chqenv.chaenv = "COFRE" no-lock:
        find chq where recid(chq) = chqenv.recenv no-lock no-error.
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
    end.
    else if vdtvi <> ?
    then
    do vdata = vdtvi to vdtvf:
    for each chq use-index chqdata
                         where chq.data = vdata no-lock:
        find chqenv where chqenv.recenv = int(recid(chq)) and
                          chqenv.chaenv = "COFRE" 
                          no-lock no-error.
        if not avail chqenv
        then find chqenv where chqenv.banco = chq.banco and
                       chqenv.agencia = chq.agencia and
                       chqenv.conta = chq.conta and
                       chqenv.numero = chq.numero and
                       chqenv.chaenv = "COFRE"
                       no-lock no-error.
        if not avail chqenv
        then next.
        
        vchqarq       = vchqarq       + chq.valor.
        create tt-chq.
        buffer-copy chq to tt-chq.

    end.
    end.
     if opsys = "UNIX"
    then varquivo = "/admcom/relat/chqcof1" + string(time).
    else varquivo = "l:\relat\chqcof1" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "100"
        &Page-Line = "0"
        &Nom-Rel   = ""chq_cof1""
        &Nom-Sis   = """SISTEMA FINANCEIRO"""
        &Tit-Rel   = """ CHEQUES ENVIADOS PARA ARQUIVO  """
        &Width     = "120"
        &Form      = "frame f-cabcab"}

    
    disp 
         vdti label "Data Envio de"
         vdtf label "Ate"
         vchqarq label "Valor "
         with frame f-1 1 down side-label
         .
    pause 0.
 
    for each tt-chq break by tt-chq.data:
        find first chqtit use-index ind-1
                          where chqtit.banco   = tt-chq.banco    and
                                chqtit.agencia = tt-chq.agencia  and
                                chqtit.conta   = tt-chq.conta    and
                                chqtit.numero  = tt-chq.numero 
                                no-lock no-error.

        if first-of(tt-chq.data)
        then do:
            disp tt-chq.data column-label "Vencto" with frame f-dis.
        end.
        disp tt-chq.banco       column-label "Bco"
             tt-chq.agencia     column-label "Agen"
             tt-chq.conta       column-label "Conta" format "x(14)"
             tt-chq.numero      column-label "Numero"
             tt-chq.datemi      column-label "Emissao"
             chqtit.etbcod when avail chqtit  column-label "Fil"
             chqtit.clifor when avail chqtit  column-label "Cliente"
             tt-chq.valor(total by tt-chq.data) column-label "Valor"
             with frame f-dis width 120 down 
             .
        down with frame f-dis.
        /**
        if last-of(tt-chq.data)
        then do:
            put fill("-",100) format "x(100)".
        end.             
        **/
    end.
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
