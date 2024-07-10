{admcab.i}
def var varquivo as char.
def var vdti   as date format "99/99/9999".
def var vdtf   as date format "99/99/9999".
def var vetbcod like estab.etbcod.
repeat:

    update vetbcod label "Filial" 
            with frame f1 width 80 side-label.

    vdti = today.
    vdtf = today.
    
    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".

    varquivo = "..\relat\desac" + string(time).

    {mdad.i &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""des_aces""
            &Nom-Sis   = """CONTABILIDADE"""
            &Tit-Rel   = """FILIAL "" + string(vetbcod,"">>9"") +
                          "" DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}


    for each plani where plani.movtdc = 4             and
                         plani.etbcod = vetbcod       and 
                         plani.dtinclu >= vdti        and
                         plani.dtinclu <= vdtf no-lock:

        if plani.biss = 0
        then next.

        find forne where forne.forcod = plani.emite no-lock.
        

        display plani.emite format ">>>>>9"
                forne.fornom
                plani.dtinclu column-label "Data!Recebimento"
                plani.numero
                plani.serie format "x(03)" column-label "Sr."
                plani.biss(total) column-label "Despesas!Acessorias" 
                    with frame f2 width 140 down.
        
    end.
    output close.
    {mrod.i} 
end.
