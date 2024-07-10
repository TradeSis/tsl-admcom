{admcab.i}
def var vtotcomp    like titulo.titvlcob.
def var ventrada    like titulo.titvlcob.
def var vdata       like plani.pladat.
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .
def var vetbcod like estab.etbcod.
def var varquivo as char format "x(30)".
repeat with 1 down side-label width 80 row 3:
    vetbcod = 0.
    update vetbcod colon 20.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label.
    update vdata colon 20.
    assign
        ventrada = 0
        vtotcomp = 0.
    
    for each titulo where titulo.etbcobra = vetbcod
                      and titulo.titnat = no
                      and titulo.etbcod = vetbcod
                      and titulo.titpar = 0          
                      and titulo.titdtpag = vdata
                      and titulo.titsit = "PAG"  no-lock,
                      
        first contrato where contrato.etbcod = estab.etbcod
                         and contrato.contnum = integer(titulo.titnum) no-lock.
        
        assign ventrada = ventrada + titulo.titvlcob
               vtotcomp = vtotcomp + contrato.vltotal .      
        
    end.
                          
    if vtotcomp = 0 and
       ventrada = 0
    then do:
        message "Nenhuma compra efetuada.".
        undo.
    end.

    display vtotcomp label "Valor Compra"  colon 25
            ventrada label "Valor Entrada" colon 25
            with frame ff side-label.
    message "Imprimir Resumo ou Geral ?" update sresumo.
    if sresumo
    then do:
        
        output to printer page-size 64.
        form header
            wempre.emprazsoc
                    space(6) "CONRE"   at 60
                    "Pag.: " at 71 page-number format ">>9" skip
                    "RESUMO DE DIGITACAO DE CONTRATOS "   at 1
                    today format "99/99/9999" at 60
                    string(time,"hh:mm:ss") at 73
                    skip fill("-",80) format "x(80)" skip
                    with frame fcab no-label page-top no-box width 137.
        view frame fcab.
        display estab.etbcod
                estab.etbnom no-label  skip(1)
                vdata    label "Data"  space(3)
                vtotcomp label "Tot.Compra"
                ventrada label "Tot.Entrada"
                with frame flin side-label width 80.
        output close.
    end.
    else do:
     if opsys = "UNIX"
     then varquivo = "/admcom/relat/conre" + string(day(today)).
     else varquivo = "l:\relat\conre" + string(day(today)).
     
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "153"
            &Page-Line = "66"
            &Nom-Rel   = """CONRE"""
            &Nom-Sis   = """SISTEMA CREDIARIO"""
            &Tit-Rel   = """RESUMO DE DIGITACAO DE CONTRATOS ESTAB.: "" +
                            string(estab.etbcod) + "" - "" + estab.etbnom "
            &Width     = "153"
            &Form      = "frame f-cab"}

        for each titulo where titulo.etbcobra = vetbcod               
                          and titulo.titnat = no                      
                          and titulo.etbcod = vetbcod                 
                          and titulo.titpar = 0                       
                          and titulo.titdtpag = vdata                 
                          and titulo.titsit = "PAG"  no-lock,         
                                                                   
            first contrato where contrato.etbcod = estab.etbcod       
                             and contrato.contnum = integer(titulo.titnum)
                                no-lock
                                 with width 160 
                                 no-box                                    
                                 by contrato.contnum.                      .  
            
            find first contnf where contnf.etbcod = contrato.etbcod and
                                contnf.contnum = contrato.contnum no-error. 
            find clien where clien.clicod = contrato.clicod no-lock no-error.


            display contrato.contnum    column-label "Contr." format ">>>>>>>>>9"
                    contrato.dtinicial  
                        column-label "Dt.Venda" format "99/99/9999"
                    titulo.titpar                column-label "Par"
                    contrato.clicod     column-label "Cliente"
                    clien.clinom        column-label "Nome do Cliente"
                                        when avail clien format "x(35)"
                 /*   clien.fone          column-label "Telefone"                                                       when avail clien format "x(12)"  */
                    contrato.vltotal    column-label "Vl.Venda" (total)
                    titulo.titvlcob    column-label "Vl.Entra" (total)
                /*    if avail titulo
                    then titulo.titvlcob
                   else 0 @ titulo.titvlcob     column-label "Prim.Prest" */
                    if avail titulo
                    then titulo.titdtven
                    else ? @ titulo.titdtven     column-label "Prim.Vecto"
                    if avail contnf
                    then contnf.notanum
                    else 0 @ contnf.notanum      column-label "Nota"
                                                 format ">>>>>>>9". 
        end.
        put unformatted chr(30) "0".
        output close.
    end.
    message varquivo.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end. 
end.
