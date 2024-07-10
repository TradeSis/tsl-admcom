{admcab.i}

def var varquivo as char.    
def var vetbcod like estab.etbcod.
def var vdt1        as   date.
def var vdt2        as   date.
def temp-table wclien
    field clicod like clien.clicod.

repeat:

    for each wclien:
        delete wclien.
    end.
        
    update vetbcod colon 20 with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vdt1 label "Data Inicial" colon 20
           vdt2 label "Data Final" colon 20 with frame f1.
    
    repeat:
        create wclien.
        update wclien.clicod label "Conta"
                with frame f-1 side-label centered down.
        find clien where clien.clicod = wclien.clicod no-lock no-error.
        if not avail clien
        then do:
            bell.
            message "Cliente nao cadastrado".
            undo, retry.
            disp clien.clinom no-label with frame f-1.
         end.
    end.
    
    varquivo = "i:\admcom\relat\cli".

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""con-fil""
        &Nom-Sis   = """SISTEMA DE CREDIARIO"""
        &Tit-Rel   = """CADASTRO PARA COBRADOR  FILIAL "" + 
                        string(estab.etbcod,"">>9"") + ""  "" +
                        string(vdt1,""99/99/9999"") +
                        string(vdt2,""99/99/9999"")"
     
        &Width     = "130"}
    
    for each wclien break by wclien.clicod:
        if wclien.clicod = 0
        then next.
        if first-of(wclien.clicod)
        then do:
            find clien where clien.clicod = wclien.clicod no-lock no-error.
            disp wclien.clicod
                 clien.clinom when avail clien
                    with frame f-down1 width 200 side-label.
        end.
            
        
        for each contrato where contrato.clicod = wclien.clicod and
                                contrato.etbcod = estab.etbcod no-lock,
                                        
                                                     
            each titulo where titulo.empcod = 19 and
                                    titulo.titnat = no and
                                    titulo.modcod = "CRE" and
                                    titulo.etbcod = estab.etbcod and
                                    titulo.clifor = wclien.clicod and
                                    titulo.titnum = 
                                                string(contrato.contnum) and
                                    titulo.titdtven >= vdt1 and
                                    titulo.titdtven <= vdt2 no-lock
                                        break by titulo.titdtven .
            if avail titulo
            then do:
                disp contrato.contnum
                     titulo.titpar
                     titulo.titdtven
                     titulo.titvlcob(total)
                        with frame f-down down width 200.
            end.
        end.
    end.

    output to close.    
    dos silent value("type " + varquivo + "> prn"). 
end.
