{admcab.i}. 

def var vetbcod like estab.etbcod.
def var vdataini as date label "Dt.Inicial" format "99/99/9999".
def var vdatafin as date label "Dt.Final"   format "99/99/9999".
def var varquivo as char.


def stream stela.
def var i as date.

form
    vetbcod
    estab.etbnom no-label
    vdataini     label "Periodo"
    vdatafin     no-label 
    with frame f-data 
        centered 1 down side-labels title "Datas".

repeat:
    update vetbcod 
           vdataini
           vdatafin with frame f-data.

    find estab where estab.etbcod = vetbcod no-lock no-error.
    disp estab.etbnom with frame f-data.

    varquivo = "..\relat\cli" + string(time).

    output stream stela to terminal.
    
    {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "147"
            &Page-Line = "66"
            &Nom-Rel   = ""magcli""
            &Nom-Sis   = """SISTEMA CONTABILIDADE"""
            &Tit-Rel   = """ARQUIVO MAGNETICO CLIENTES "" +
                        ""  - Data: "" + string(vdataini) + "" A "" +
                            string(vdatafin)"
            &Width     = "147"
            &Form      = "frame f-cabcab1"}


    
    do i = vdataini to vdatafin: 

        for each titulo where titulo.titnat = no
                          and titulo.titdtpag = i
                          and titulo.etbcod = estab.etbcod
                          and titulo.modcod = "CRE"
                          and titulo.empcod = 19 use-index titdtpag no-lock:

            find contrato where contrato.contnum = int(titulo.titnum)
                        no-lock no-error.
            if not avail contrato 
            then next.

            find first contnf where contnf.etbcod = contrato.etbcod
                                and contnf.contnum = contrato.contnum
                                   use-index codigo no-lock no-error.
            if not avail contnf 
            then next.
               
            find first plani where plani.etbcod = contrato.etbcod
                               and plani.placod = contnf.placod
                                  use-index plani no-lock no-error.

            if avail plani
            then do:
                if plani.notped <> "C" 
                then next.
            end.
            else next.
    
            disp stream stela "Titulo" 
                titulo.clifor    
                titulo.titdtemi
                titulo.titdtpag
                    with 1 down  centered row 10 no-labels overlay.
            pause 0.
    
            display titulo.clifor  
                    titulo.titdtpag
                    titulo.titvlpag(total)
                    titulo.titnum 
                    titulo.titvlcob(total)
                    titulo.titdtemi
                    titulo.titdtven with frame f-tit down width 137.
        end.
    end.

    for each plani where plani.pladat >= vdataini and
                         plani.pladat <= vdatafin and
                         plani.notped = "C"       and
                         plani.desti = 1          and
                         plani.movtdc = 5         and
                         plani.etbcod = estab.etbcod 
                                use-index plasai no-lock:

        disp stream stela "V.Vista " 
                    plani.desti   
                    plani.pladat
                        with 1 down centered row 10 no-labels overlay.
        pause 0.

        display plani.desti
                plani.pladat
                plani.platot(total) 
                plani.numero format ">>>>>>9"
                        with frame f-pla down width 137.
    end.               
    
    output close.
    {mrod_l.i}

end.

    