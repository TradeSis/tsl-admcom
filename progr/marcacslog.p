
def var vcontnum as int format ">>>>>>>>>>>9".
pause 0 before-hide.                    
def var varquivo as char format "x(50)" init "/admcom/tmp/marcacslog.csv".         
update varquivo with no-labels centered.
input from value(varquivo).
repeat.
    import vcontnum.
    find cslog_controle where cslog_controle.contnum = vcontnum no-error.
    
    if avail cslog_controle
    then do:
        disp cslog_controle.contnum with 2 col.
        delete cslog_controle.
    end.
    find contrato where contrato.contnum = vcontnum.
    disp contrato.etbcod contrato.contnum format ">>>>>>>>>>>9" contrato.clicod contrato.modcod contrato.datexp.
    contrato.datexp = today - 1.
    /*
    for each titulo where
        titulo.empcod = 19 and 
        titulo.titnat = no and 
        titulo.modcod = contrato.modcod and 
        titulo.etbcod = contrato.etbcod and 
        titulo.clifor = contrato.clicod and 
        titulo.titnum = string(contrato.contnum) 
        no-lock.
        disp titulo.titvlcob titulo.titsit titulo.titdtpag titulo.titdtven today - titulo.titdtven titulo.datexp titulo.contnum.
    end.
    */
end.                    

