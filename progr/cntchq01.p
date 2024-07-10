{admcab.i}


def var varquivo as char.
def var vdata as date.
def temp-table tt-chq like chq
    field dtref as date
    field etbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vdtr as date.
def var vtipo as log format "Analitico/Sintetico".
def var vtotal as dec.
def var ttotal as dec.

def temp-table tt-tt
    field rec as recid.

form with frame f3.

vdtr = 05/01/07.
update vdtr      label "Data Referencia"   format "99/99/9999"
        skip(1)
       vdti at 1 label "   Data Inicial"   format "99/99/9999"
       vdtf      label "Data Final"        format "99/99/9999"
    with frame f1 side-label 1 down width 80 .
    
    if vdti = ? or
       vdtf = ?
    then undo.
    update "     " vtipo label "Tipo" with frame f1.
    /*vdtr = 05/01/07.*/
    for each tt-tt: delete tt-tt. end.
    do vdata = vdtr - 30 to vdtf:
        run envio-banco.
    end.
    do vdata = vdtr to vdtf: 
        disp "Processando.......>>>>"  vdata
            with frame f-pro 1 down centered row 10 no-label no-box.
        pause 0.   
        run selcheque. 
    end.
             
    if opsys = "UNIX"
    then  varquivo = "../relat/cntchq001." + string(time).
    else  varquivo = "..~\relat~\cntchq001." + string(time).

    {mdad.i
         &Saida     = "value(varquivo)"
         &Page-Size = "64"
         &Cond-Var  = "130"
         &Page-Line = "66"
         &Nom-Rel   = ""CNTCHQ01.P""
         &Nom-Sis   = """SISTEMA FINANCEIRO"""
         &Tit-Rel   = """RELATORIO DE CHEQUES PRE"""
         &Width     = "130"
         &Form      = "frame dep1"}

     DISP WITH FRAME F1.
     
     if vtipo 
     then do:
        vtotal = 0.
        ttotal = 0.
     for each tt-chq break by tt-chq.dtref
                                by tt-chq.data:
        if first-of(tt-chq.dtref)
        then display  tt-chq.dtref label "Vencto"
                with frame f2.
        disp        
                tt-chq.etbcod column-label "Fil" format ">>9"
                tt-chq.datemi column-label "Emissao"
                tt-chq.comp
                tt-chq.banco
                tt-chq.agencia format ">>>>>>9"
                tt-chq.controle1
                tt-chq.conta format "x(15)"
                tt-chq.controle2
                tt-chq.numero
                tt-chq.controle3
                tt-chq.valor(total by tt-chq.dtref) format ">>,>>>,>>9.99" 
                    with frame f2 down width 200.
        assign
            vtotal = vtotal + tt-chq.valor
            ttotal = ttotal + tt-chq.valor.
            
        if last-of(tt-chq.data)
        then do:
            down with frame f2.
            disp 
                 vtotal @ tt-chq.valor 
                 tt-chq.data no-label
                 with frame f2.
            vtotal = 0.     
        end.
        down with frame f2.
    end.
    end.               
    else do:
    vtotal = 0.
    ttotal = 0.
    for each tt-chq break   by tt-chq.dtref
                            by tt-chq.data:
        vtotal = vtotal + tt-chq.valor.
        ttotal = ttotal + tt-chq.valor.
        if last-of(tt-chq.dtref)
        then do:
            
            display  tt-chq.data label "Vencto"
                     vtotal label "Valor" format ">>>,>>>,>>9.99"
                with frame f3 down.
            down with frame f3.
            vtotal = 0.
        end.
    end.               
    down(1) with frame f3.
    disp ttotal @ vtotal with frame f3.
    end.                    
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}.
    end.


procedure envio-banco:

    def var vlinha as char.    

    varquivo = "/admcom/banrisul/" + string(day(vdata - 1),"99")
                            + string(month(vdata - 1),"99") +
                            string(year(vdata - 1),"9999") + ".txt".

    if search(varquivo) <> ?
    then do:
        input from value(varquivo).
        repeat:
            import vlinha.
    
            create tt-tt.
            tt-tt.rec = int(substr(string(vlinha),1,10)).
        end.
        input close.
    end.
    varquivo = "/admcom/banrisul/" + string(day(vdata),"99")
                            + string(month(vdata),"99") +
                            string(year(vdata),"9999") + ".txt".

    if search(varquivo) <> ?
    then do:
        input from value(varquivo).
        repeat:
            import vlinha.
    
            create tt-tt.
            tt-tt.rec = int(substr(string(vlinha),1,10)).
        end.
        input close.
    end.

end procedure.

procedure selcheque:
    for each chq use-index chqdata 
                 where chq.data = vdata no-lock:
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

        if chq.datemi = chq.data
        then next.
        find chqenv where chqenv.recenv = int(recid(chq)) and
                    chqenv.chaenv = "" no-lock no-error.
        if not avail chqenv
        then find chqenv where chqenv.banco = chq.banco and
                           chqenv.agencia = chq.agencia and
                           chqenv.conta = chq.conta and
                           chqenv.numero = chq.numero   and
                           chqenv.chaenv = ""
                           no-lock no-error.
            
        if avail chqenv and chqenv.intenv = 0
        then next.
        find first tt-tt where tt-tt.rec = int(recid(chq)) no-error.
        if avail tt-tt then next.
        create tt-chq.
        buffer-copy chq to tt-chq. 
        if vdata <= vdti
        then dtref = vdti.
        else dtref = vdata.       
        tt-chq.etbcod = chqtit.etbcod.
    end.
end procedure.