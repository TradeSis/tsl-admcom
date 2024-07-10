{admcab.i}
def stream scon.
def stream stit.
def stream spla.
def var vok as l.
def var vmes as int format "99".
def var vano as int format "9999".
def var vdata as date format "99/99/9999".
def buffer btitulo for titulo.
repeat:
    vmes = 12.
    vano = year(today) - 1.
    update vmes label "Mes"
           vano label "Ano" with frame f1 side-label width 80
                                color white/cyan title "Periodo".
    if vmes = 12
    then assign vmes = 1
                vano = vano + 1.
    else assign vmes = vmes + 1.
    vdata = date(vmes,1,vano) - 1.
    disp vdata label "Data Final" colon 60 with frame f1.
    output stream scon to ..\work9\contluc.d.
    output stream stit to ..\work9\titluc.d.
    output stream spla to ..\work9\contnf.d.
    for each clien no-lock.
        if clien.clicod = 1
        then next.
        pause 0.
        disp "Luc/Per...." clien.clicod
                           clien.clinom no-label
                                    with frame f-luc overlay color white/cyan
                                            side-label row 10.

        vok = yes.
        for each titulo use-index iclicod where
                              titulo.clifor = clien.clicod and
                              titulo.titnat = no    and
                              titulo.modcod = "cre" and
                              titulo.titsit = "LIB" no-lock:
            if titulo.titdtven > vdata
            then do:
                vok = yes.
                leave.
            end.
            else vok = no.
        end.
        if vok = no
        then do:
            for each btitulo where btitulo.clifor = clien.clicod and
                                   btitulo.titnat = no.
                find titluc where titluc.empcod = btitulo.empcod and
                                  titluc.titnat = btitulo.titnat and
                                  titluc.modcod = btitulo.modcod and
                                  titluc.etbcod = btitulo.etbcod and
                                  titluc.clifor = btitulo.clifor and
                                  titluc.titnum = btitulo.titnum and
                                  titluc.titpar = btitulo.titpar no-error.
                if not avail titluc
                then do transaction:
                    create titluc.
                    ASSIGN titluc.empcod    = btitulo.empcod
                           titluc.modcod    = btitulo.modcod
                           titluc.CliFor    = btitulo.CliFor
                           titluc.titnum    = btitulo.titnum
                           titluc.titpar    = btitulo.titpar
                           titluc.titnat    = btitulo.titnat
                           titluc.etbcod    = btitulo.etbcod
                           titluc.titdtemi  = btitulo.titdtemi
                           titluc.titdtven  = btitulo.titdtven
                           titluc.titvlcob  = btitulo.titvlcob
                           titluc.titdtdes  = btitulo.titdtdes
                           titluc.titvldes  = btitulo.titvldes
                           titluc.titvljur  = btitulo.titvljur
                           titluc.cobcod    = btitulo.cobcod
                           titluc.bancod    = btitulo.bancod
                           titluc.agecod    = btitulo.agecod
                           titluc.titdtpag  = btitulo.titdtpag
                           titluc.titdesc   = btitulo.titdesc
                           titluc.titjuro   = btitulo.titjuro
                           titluc.titvlpag  = btitulo.titvlpag
                           titluc.titbanpag = btitulo.titbanpag
                           titluc.titagepag = btitulo.titagepag
                           titluc.titchepag = btitulo.titchepag
                           titluc.titobs[1] = btitulo.titobs[1]
                           titluc.titobs[2] = btitulo.titobs[2]
                           titluc.titsit    = btitulo.titsit
                           titluc.titnumger = btitulo.titnumger
                           titluc.titparger = btitulo.titparger
                           titluc.cxacod    = btitulo.cxacod
                           titluc.evecod    = btitulo.evecod
                           titluc.cxmdata   = btitulo.cxmdata
                           titluc.cxmhora   = btitulo.cxmhora
                           titluc.vencod    = btitulo.vencod
                           titluc.etbCobra  = btitulo.etbCobra
                           titluc.datexp    = today
                           titluc.moecod    = btitulo.moecod.


                    export stream stit titluc.

                end.
                do transaction:
                    delete btitulo.
                end.
            end.
            for each contrato where contrato.clicod = clien.clicod:
                find contluc where contluc.contnum = contrato.contnum no-error.
                if not avail contluc
                then do transaction:
                    create contluc.
                    ASSIGN contluc.contnum   = contrato.contnum
                           contluc.clicod    = contrato.clicod
                           contluc.autoriza  = contrato.autoriza
                           contluc.dtinicial = contrato.dtinicial
                           contluc.etbcod    = contrato.etbcod
                           contluc.banco     = contrato.banco
                           contluc.vltotal   = contrato.vltotal
                           contluc.vlentra   = contrato.vlentra
                           contluc.situacao  = contrato.situacao
                           contluc.indimp    = contrato.indimp
                           contluc.lotcod    = contrato.lotcod
                           contluc.crecod    = contrato.crecod
                           contluc.vlfrete   = contrato.vlfrete
                           contluc.datexp    = today.

                   export stream scon contluc.
                   for each contnf where contnf.etbcod = contrato.etbcod and
                                         contnf.contnum = contrato.contnum
                                                            no-lock: 
                     export stream spla contnf.
                   end.
                end.
                do transaction:
                    delete contrato.
                end.
            end.
        end.
    end.
    output stream spla close.
    output stream scon close.
    output stream stit close.
    run lis-cli.p .
    message "Emitir Listagem" update sresp.
    if sresp 
    then run lis-lp.p.
end.
