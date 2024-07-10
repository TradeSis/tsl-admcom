{admcab.i}


def var vdep like plani.platot.
def var vchqdia like plani.platot.
def var vchqpre like plani.platot.
def var vinfdia like plani.platot.
def var vinfpre like plani.platot.

def temp-table tt-chq like chq.
                    
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
         
repeat:    

    update vdti label "Data Inicial" colon 15
           vdtf label "Data Final"
                with frame fdata side-label width 80 row 3.
   
    
    assign vchqdia = 0
           vinfdia = 0
           vchqpre = 0
           vinfpre = 0.
    
    /**
    for each chq use-index chqdatemi
                 where chq.datemi >= vdti        and
                       chq.datemi <= vdtf no-lock.
                          
        vinfdia = vinfdia + chq.valor.
        find first chqtit use-index ind-1
                          where chqtit.banco   = chq.banco    and
                                chqtit.agencia = chq.agencia  and
                                chqtit.conta   = chq.conta    and
                                chqtit.numero  = chq.numero no-lock no-error.
        if not avail chqtit
        then next.
        if chq.datemi = chq.data
        then.
        else next.

        /* confirmado */
        find deposito where deposito.etbcod = chqtit.etbcod and
                                deposito.datmov = chq.datemi no-lock no-error.
        if avail deposito and
           deposito.datcon <> ?
        then.
        else do:
            create tt-chq.
            buffer-copy chq to tt-chq. 
        end.    

        vchqdia       = vchqdia       + chq.valor.
               
    end.
    **/
    for each chq use-index chqdata
                 where chq.data >= vdti        and
                       chq.data <= vdtf no-lock.
                          
        if chq.datemi <> chq.data
        then.
        else next. 
 
 
        vinfpre = vinfpre + chq.valor.

        create tt-chq.
        buffer-copy chq to tt-chq.

        find first chqtit use-index ind-1
                          where chqtit.banco   = chq.banco    and
                                chqtit.agencia = chq.agencia  and
                                chqtit.conta   = chq.conta    and
                                chqtit.numero  = chq.numero no-lock no-error.
        if not avail chqtit
        then next.

        find deposito where deposito.etbcod = chqtit.etbcod and
                                deposito.datmov = chq.datemi no-lock no-error.
        if avail deposito and
        deposito.datcon <> ?
        then.
        else next.

        vchqpre       = vchqpre       + chq.valor.
        delete tt-chq.
               
    end.
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/rdifchq0" + string(time).
    else varquivo = "l:\relat\rdifchq0" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "100"
        &Page-Line = "0"
        &Nom-Rel   = ""rdifchq0""
        &Nom-Sis   = """SISTEMA FINANCEIRO"""
        &Tit-Rel   = """ DIVERGENCIAS CONTROLE DE CHEQUES """
        &Width     = "120"
        &Form      = "frame f-cabcab"}

     DISP WITH FRAME FDATA.
     PAUSE 0.
     disp 
         vinfpre label "Valor Informado"
         vchqpre label "Valor Confirmado"
         with frame f-1 1 down side-label
         .
    pause 0.
 
    for each tt-chq break by tt-chq.banco 
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
             tt-chq.valor(total) column-label "Valor"
             chqtit.etbcod when avail chqtit  column-label "Fil"
             chqtit.clifor when avail chqtit  column-label "Cliente"
             with frame f-dis width 120 down 
             .
        
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
