{admcab.i}
def var varquivo as char format "x(20)".
def var totecf like plani.platot.
def var i as i.
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def var totvis like titold.titvlcob.
def var totpra like titold.titvlcob.
def var totent like titold.titvlcob.
def var totjur like titold.titjuro.
def var totpre like titold.titvlcob.

def var x as i.
def var vcx as int.
def var totglo like globa.gloval.
def var vlpres      like titulo.titvlcob.
def var vcta01      as char format "99999".
def var vcta02      as char format "99999".
def var vdata       like titold.titdtemi.
def var vpago       like titold.titvlpag.
def var vdesc       like titold.titdesc.
def var vjuro       like titold.titjuro.
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .
def var vcxacod     like titold.cxacod.
def var vmodcod     like titold.modcod.
def var vlvist      like plani.platot.
def var vlpraz      like plani.platot.
def var vlentr      like plani.platot.
def var vljuro      like plani.platot.
def var vldesc      like plani.platot.
def var vlpred      like plani.platot.
def var vljurpre    like plani.platot.
def var vlsubtot    like plani.platot.
def var vtot        like plani.platot.
def var vnumtra     like plani.platot.
def var vdtexp      as   date format "99/99/9999".
def var vdtimp      as   date  format "99/99/9999".
def var vdt1        as   date  format "99/99/9999". 
def var vdt2        as   date  format "99/99/9999".
def stream tela.

def temp-table wf-atu
             field imp      as date
             field exporta  as date.

def buffer bimporta for importa.
def buffer bexporta for exporta.

output stream tela to terminal.

form wf-atu.imp label "Falta Importar do CPD"
     wf-atu.exporta label "Falta Exportar para CPD"
     with frame fatu centered no-box down.

repeat with 1 down side-label width 80 row 4 color blue/white:
    update vetbi label "Filial" colon 20
           vetbf label "Filial".
    x = 0.
    totvis = 0.
    totpra = 0.
    totjur = 0.
    totpre = 0.
    totent = 0.

    update vdt1 label "Data Inicial" colon 20
           vdt2 label "Data Final" colon 20.
     if opsys = "UNIX"
     then varquivo = "../relat/res05" + string(day(today)).   
     else varquivo = "..~\relat~\res00" + string(day(today)).

     {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""res00""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE """
            &Tit-Rel   = """RESUMO GERAL POR FILIAL - PERIODO DE "" +
                                  string(vdt1,""99/99/9999"") + "" A "" +
                                  string(vdt2,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:

        vlpres = 0.
        vljuro = 0.
        vlentr = 0.
        totpra = 0.
        totvis = 0.

        assign vcta01 = string(estab.prazo,"99999")
               vcta02 = string(estab.vista,"99999").
        
        do vdata = vdt1 to vdt2:
            vlvist = 0.
            vlpraz = 0.
            totecf = 0.
            for each plani use-index pladat 
                                     where plani.movtdc = 5 and
                                           plani.etbcod = estab.etbcod and
                                           plani.pladat = vdata no-lock.

                if plani.crecod = 1
                then vlvist = vlvist + plani.platot.
                if plani.crecod = 2
                then vlpraz = vlpraz + plani.platot.

            end.
            for each titold where titold.etbcobra = estab.etbcod and
                                  titold.titdtpag = vdata        no-lock.
                if titold.clifor = 1
                then next.
                if titold.titnat = yes
                then next.
                if titold.modcod <> "CRE"
                then next.
                if titold.etbcod = estab.etbcod and
                   titold.titpar = 0
                then vlentr = vlentr  + titold.titvlcob.
                else do:
                    assign
                        vlpres = vlpres + titold.titvlcob /* titold.titvlpag
                                      - titold.titjuro + titold.titdesc */
                        vljuro = vljuro + titold.titjuro.
                end.
            end.
            
            for each mapctb where mapctb.etbcod = estab.etbcod and
                                  mapctb.datmov = vdata no-lock.

                if mapctb.ch2 = "E"                 
                then next.
                 
                totecf = totecf + 
                        (mapctb.t01 + 
                         mapctb.t02 + 
                         mapctb.t03 +
                         mapctb.vlsub).
            
            end.
            
            if vlpraz > 0
            then do:
                if vlvist < vlpraz
                then do:
                    vlvist = (vlvist / vlpraz) * totecf.
                    vlpraz = totecf - vlvist.
                end.
                else do:
                    vlpraz = (vlpraz / vlvist) * totecf.
                    vlvist = totecf - vlpraz.
                end.
            end.
            else vlvist = totecf.
            
            totvis = totvis + vlvist.
            totpra = totpra + vlpraz.
            
        end.

        if totpra = 0 and
           totvis = 0 and
           vljuro = 0 and
           vlpres = 0 and
           vlentr = 0
        then next.


        display estab.etbcod column-label "Filial"
                totpra(total)  column-label "Venda Prazo" 
                string("(" + vcta01 + ")","x(07)") column-label "Cta CR"
                totvis(total)  column-label "Venda Vista" 
                string("(" + vcta02 + ")","x(07)") column-label "Cta CR"
                vlentr(total) column-label "Entrada (169)"
                vlpres(total) column-label "Prestac (169)"
                vljuro(total) column-label "Juros (169)"
               (totpra + totvis + vlentr + vlpres + vljuro)
                        column-label "Valor" format "->>,>>>,>>9.99"
                 with frame f3 down width 200.
    end.
    output close.

    if opsys = "UNIX"
    then run visurel.p( varquivo, "").
    else do:
        {mrod.i}
    end.
    

end.
