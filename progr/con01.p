{admcab.i}
def var vcont as int.
def var vsaldo  like plani.platot.
def var vcon    as   int.
def var vfincod like finan.fincod extent 40.
def var vlmin   like titulo.titvlcob.
def var vlmax   like titulo.titvlcob.
def var i as    i.
def var v as    i.
def var vdt     as date format "99/99/9999".
def var vdtven  as date format "99/99/9999".
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vlcont  like titulo.titvlcob.
def var vvlent   like titulo.titvlcob format ">,>>9.99".
def var vok     as l.
def var vok1    as l.
def stream      stela.
def buffer bcontnf for contnf.
def var vtotal like titulo.titvlcob.
repeat:
    VCONT = 0.
    VCON  = 0.
    update vdti label "Data"
           vlmax label "Valor Maximo"
                with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".
        {mdconcab.i
            &Saida     = "i:\ADMCOM\relat\con01.rel"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = "".""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE                          ""
                         + ""      SALDO DE CLIENTES EM ABERTO EM "" +
                            string(vdtI,""99/99/9999"")"
            &Tit-Rel   =
                  """CODIGO   NOME                                           ""
                     + ""SALDO           ""  +
                  ""     CODIGO   NOME                                       ""
                  + ""   SALDO"""
            &Width     = "160"
            &Form      = "frame f-cabcab"}

        for each titulo use-index iclicod no-lock break by titulo.clifor:

            if titulo.titnat = yes
            then next.
            if  titulo.modcod <> "CRE"
            then next.

            if titulo.titdtpag < vdti
            then next.

            if titulo.titdtemi > vdti
            then next.
            vsaldo = vsaldo + titulo.titvlcob.
            vtotal = vtotal + titulo.titvlcob.
            if vtotal >= vlmax
            then leave.
            if last-of(titulo.clifor)
            then do:
                find clien where clien.clicod = titulo.clifor no-lock no-error.
                if not avail clien
                then next.
                vcon = vcon + 1.
                if vcon = 1
                then do:
                     put clien.clicod at 10 space(3)
                         clien.clinom
                         vsaldo.
                end.
                else do:
                    vcont = vcont + 1.
                    put clien.clicod at 86 space(3)
                        clien.clinom
                        vsaldo skip.

                    vcon = 0.
                end.
                vsaldo = 0.
            end.
        end.
        display vlmax label "Total Geral" at 45
                with frame f-b width 160 side-label.
    output close.
    message "Deseja imprimir relatorio?"  update sresp.
    if sresp 
       then dos silent value( "type i:\admcom\relat\con01.rel >prn" ).
end.

 
