{admcab.i}

/*def input parameter p-etbcod as int.*/
def input parameter p-acaocod as int.

def var varquivo as char.

run emite-listagem.

procedure emite-listagem:

    if opsys = "UNIX"
    then assign
            varquivo = "/admcom/relat/crm20-con" + string(time).
    else assign
            varquivo = "l:\relat\crm20-con" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "0"
        &Cond-Var  = "160"
        &Page-Line = "0"
        &Nom-Rel   = ""CRM""  
        &Nom-Sis   = """CRM"""  
        &Tit-Rel   = """ANIVERSARIO CONJUGE OUTUBRO"""
        &Width     = "160"
        &Form      = "frame f-cabcab"}

        for each acao-cli where acao-cli.acaocod = p-acaocod,

            first clien where
                  clien.clicod = acao-cli.clicod no-lock
                  break by day(clien.nascon):
                 
            display
                  clien.clicod     column-label "Codigo"
                  clien.clinom     column-label "Cliente" format "x(30)"
                  clien.fone         column-label "Telefone" when avail clien
                  clien.fax          column-label "Celular" when avail clien
                  clien.conjuge column-label "Conjuge" format "x(30)"
                            when avail clien
                  clien.nascon column-label "Aniver.!Conjuge" 
                        format "99/99/9999" when avail clien
                  acao-cli.recencia   column-label "Recencia"
                    format "99/99/9999"
                  acao-cli.frequencia column-label "Frequencia" format ">>>9"
                  (total)
                  acao-cli.valor      column-label "Valor" format ">>>,>>9.99"
                  (total)
                  with frame f-imp-con width 160 down.

            down with frame f-imp-con.
        
        end.    


    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo,
                       input "").
    end.
    else do:
        {mrod.i}.
    end.        
end.
