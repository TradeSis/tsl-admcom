{admcab.i}


def var varquivo as char format "x(30)".
def var vdti   as date format "99/99/9999".
def var vdtf   as date format "99/99/9999".
def stream stela.
def var vetbcod like estab.etbcod.

repeat:
    update vetbcod label "Filial" colon 16 with frame f-data.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f-data.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" 
            with frame f-data centered color blue/cyan side-label width 80.
    
    {mdadmcab.i
         &Saida     = "i:\admcom\relat\conf3.txt"
         &Page-Size = "64"
         &Cond-Var  = "130"
         &Page-Line = "66"
         &Nom-Rel   = ""CONF3.P""
         &Nom-Sis   = """SISTEMA FINANCEIRO"""
         &Tit-Rel   = """CONFIRMACOES  PERIODO "" + 
                          string(vdti,""99/99/9999"") + "" A "" + 
                          string(vdtf,""99/99/9999"") + ""  "" + 
                          string(estab.etbnom,""x(25)"")"  
         &Width     = "130"
         &Form      = "frame dep1"}

    for each deposito where deposito.datcon >= vdti and
                            deposito.datcon <= vdtf and
                            deposito.etbcod = vetbcod no-lock
                                        by deposito.datmov:

        display deposito.datcon    column-label "Confimacao"
                deposito.chedia(total)     column-label "Cheq Dia"
                deposito.chedre(total)     column-label "Cheq Pre"
                deposito.cheglo(total)     column-label "Cheq Glo"
                deposito.deppag(total)     column-label "Pgtos"
                    with frame f2 down width 200.
    end.
    
    display " N A O    C O N F I M A D O S" 
                            with frame f-top centered width 200.
    
    for each deposito where deposito.datmov >= vdti and
                            deposito.datmov <= vdtf and
                            deposito.depsit = no no-lock by deposito.datmov
                                                         by deposito.etbcod:

        display deposito.etbcod            column-label "Filial"
                deposito.datmov            column-label "Movimentacao"
                deposito.chedia(total)     column-label "Cheq Dia"
                deposito.chedre(total)     column-label "Cheq Pre"
                deposito.cheglo(total)     column-label "Cheq Glo"
                deposito.deppag(total)     column-label "Pgtos"
                    with frame f3 down width 200.
    end.
   

    
    output close.

    message "Confirma listagem" update sresp.
    if sresp
    then dos silent type i:\admcom\relat\conf3.txt > prn.

end.
