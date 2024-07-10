{admcab.i} 

def var vpdf as char no-undo.

def buffer btitulo for fin.titulo.

def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var tot01 like plani.platot.
def var tot02 like plani.platot format ">,>>9.99".
def var tot03 like plani.platot.
def var tot-cli as int.
def var cob-tot as int extent 3.

def var iTotQbr01   like plani.platot                    no-undo.
def var iTotQbr02   like plani.platot                    no-undo.
def var iTotQbr03   like plani.platot                    no-undo.
def var iTotQbA01   like plani.platot                    no-undo.
def var iTotQbA02   like plani.platot                    no-undo.
def var iTotQbA03   like plani.platot                    no-undo.

def buffer bcobranca for cobranca.
def stream stela.

def var varquivo as char format "x(20)".
def var vnomearquivo as char.
def var saldo-vencer like plani.platot.
def var saldo-vencido like plani.platot.

def var vetbcod like estab.etbcod.
def var vcobcod like cobfil.cobcod.
    
    vetbcod = setbcod.
    disp vetbcod with frame f1.
    if vetbcod = 999
    then update vetbcod label "Filial" 
        colon 16 with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    update vcobcod label "Cobrador" colon 16 with frame f1.
    find cobfil where cobfil.etbcod = estab.etbcod and
                      cobfil.cobcod = vcobcod no-lock.
    disp cobfil.cobnom no-label with frame f1.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1.

    vnomearquivo = "comicob_" + string(vetbcod) + "_" + replace(string(time,"HH:MM:SS"),":","").
    if opsys = "UNIX"
    then varquivo = "../relat/" + vnomearquivo + ".txt".
    else varquivo = "l:~\relat~\" + vnomearquivo.

    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "133"
            &Page-Line = "66"
            &Nom-Rel   = ""comi-cob""
            &Nom-Sis   = """SISTEMA DE COBRANCA"""
            &Tit-Rel   = """COBRADOR:  "" +
                            string(cobfil.cobcod,""999"") + ""  "" +
                            string(cobfil.cobnom,""x(20)"") + "" Filial: "" +
                            string(vetbcod,""999"") + ""   PERIODO: "" +
                            string(vdti,""99/99/9999"") + "" A "" +
                            string(vdtf,""99/99/9999"") "
            &Width     = "133"
            &Form      = "frame f-cabcab"}

    tot01 = 0.
    tot02 = 0.
    tot03 = 0.

    for each cobranca where cobranca.etbcod = vetbcod and
                            cobranca.cobcod = vcobcod
                                              break by cobranca.etbcod
                                              by cobranca.cobeta
                                              by cobranca.cobatr:

        find first fin.titulo use-index iclicod
                          where fin.titulo.clifor   = cobranca.clicod and
                                fin.titulo.titdtpag >= vdti           and
                                fin.titulo.titdtpag <= vdtf           and
                                fin.titulo.titdtven <= 
                                        (fin.titulo.titdtpag - 60) 
                                            no-lock no-error.
                                            
        if avail fin.titulo
        then.
        else next.
        
        for each fin.titulo where fin.titulo.clifor = cobranca.clicod no-lock:


            if fin.titulo.titpar = 0
            then do:
                find first btitulo where btitulo.empcod = 19 and
                                         btitulo.titnat = no and
                                         btitulo.modcod = "CRE" and
                                         btitulo.etbcod = vetbcod and
                                         btitulo.clifor = fin.titulo.clifor and
                                         btitulo.titnum = fin.titulo.titnum and
                                         btitulo.titpar > 30
                                         no-lock no-error.
            end.
            if fin.titulo.moecod = "NOV"
            then next.
            
            if fin.titulo.etbcobra >= 900
            then next.
            if fin.titulo.etbcobra = 993
            then next.
            if fin.titulo.etbcobra = 995
            then next.
            if fin.titulo.etbcobra = 996
            then next.
            if fin.titulo.etbcobra = 998
            then next.
            if fin.titulo.etbcobra >= 999
            then next.
            if fin.titulo.etbcod = 100
            then next.
            
            
            if fin.titulo.titsit = "LIB"
            then next.

            if fin.titulo.titvlpag = 0 then next.

            if fin.titulo.titdtpag < vdti or
               fin.titulo.titdtpag > vdtf
            then next.
            if fin.titulo.titdtven > vdtf
            then next.
            
            if fin.titulo.titpar = 0 /** and
               fin.titulo.moecod = "NOV" **/
            then.
            else do:   
                if (fin.titulo.titdtven + 10) >= fin.titulo.titdtpag
                then next.
            end.
          
            output stream stela to terminal.
                display stream stela
                        fin.titulo.clifor
                        fin.titulo.titnum
                        fin.titulo.titpar with frame ff side-label 1 down.
                pause 0.
            output stream stela close.
            find clien where clien.clicod = cobranca.clicod no-lock.
            tot01 = tot01 + fin.titulo.titvlcob.
            tot02 = tot02 + (fin.titulo.titvlpag - fin.titulo.titvlcob).
            tot03 = tot03 + fin.titulo.titvlpag.
            display clien.clicod
                    clien.clinom
                    fin.titulo.titnum
                    fin.titulo.titpar
                    fin.titulo.titdtven
                    fin.titulo.titdtpag
                    fin.titulo.titvlcob
                    (fin.titulo.titvlpag - fin.titulo.titvlcob)
                        format "->,>>9.99" column-label "Juros"
                    fin.titulo.titvlpag format ">,>>>,>>9.99"
                                        column-label "Total"
                                with frame f2 down width 200.

            assign iTotQbr01 = iTotQbr01 + fin.titulo.titvlcob
                   iTotQbr02 = iTotQbr02 + (fin.titulo.titvlpag - 
                                            fin.titulo.titvlcob)
                   iTotQbr03 = iTotQbr03 + fin.titulo.titvlpag.
            assign iTotQbA01 = iTotQbA01 + fin.titulo.titvlcob
                   iTotQbA02 = iTotQbA02 + (fin.titulo.titvlpag - 
                                            fin.titulo.titvlcob)
                   iTotQbA03 = iTotQbA03 + fin.titulo.titvlpag.                
            if line-counter = 63 
            then do:
                    put "Total Pagina    = [ Valor Cobrado: "
                        iTotQbr01 form ">,>>>,>>9.99"
                        " Juros: " 
                        iTotQbr02 form "->>,>>9.99"
                        " Total: "
                        iTotQbr03 form ">,>>>,>>9.99"
                        " ]"
                        skip
                        "Total Acumulado = [ Valor Cobrado: "
                        iTotQbA01 form ">,>>>,>>9.99"
                        " Juros: " 
                        iTotQbA02 form "->>,>>9.99"
                        " Total: "
                        iTotQbA03 form ">,>>>,>>9.99"
                        " ]"
                        skip.
                    assign iTotQbr01 = 0
                           iTotQbr02 = 0
                           iTotQbr03 = 0.    
            end.
        end.
    end.
    put "Total Pagina    = [ Valor Cobrado: "
        iTotQbr01 form ">,>>>,>>9.99"
        " Juros: " 
        iTotQbr02 form "->,>>>,>>9.99"
        " Total: "
        iTotQbr03 form ">,>>>,>>9.99"
        " ]"
        skip.    
    put skip fill("-",133) format "x(133)" skip
        tot01 to 108
        tot02 /*to 120*/  form "->,>>>,>>9.99"
        tot03 /*to 130*/ skip
        fill("-",133) format "x(133)" skip.

    output close.
    

    if sremoto /* #3 */
    then do:
        run pdfout.p (input varquivo,
                  input "/admcom/kbase/pdfout/",
                  input vnomearquivo + ".pdf",
                  input "Portrait",
                  input 7.4,
                  input 1,
                  output vpdf).
    end.
    else 
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo , "").
        varquivo = "l:~\relat~\" + substr(varquivo,10,15).
        message skip "Arquivo gerado: " varquivo view-as alert-box.
    end.
    
              
              
