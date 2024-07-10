DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.

def var out-rec as recid.
def buffer btitulo for titulo.

pause 0 before-hide.
    
def var vdec as dec.    
{/admcom/barramento/metodos/bonusCrm.i}

/* LE ENTRADA */
lokJSON = hBonusCrmEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").


create ttbonus.
ttbonus.numero  = "".


find first ttBonusCrmEntrada no-error.
if not avail ttBonusCrmEntrada
then do:
    ttbonus.numero = "SEM INFORMACAO DE ENTRADA".
end.
else do:
    
        find neuclien where neuclien.clicod = int(ttBonusCrmEntrada.codigoCliente) no-lock no-error.
        if not avail neuclien
        then 
            find neuclien where neuclien.cpf = dec(ttBonusCrmEntrada.cpf) no-lock no-error.

        if not avail neuclien
        then return.
        
        run criatitulo (output out-rec). 
        
        find btitulo where recid(btitulo) = out-rec no-lock no-error.
        if avail btitulo
        then do:       
            ttbonus.numero          = btitulo.titnum. 
            ttbonus.codigoCliente   = string(btitulo.clifor).
            ttbonus.CPF             = if avail neuclien
                                      then string(neuclien.cpf,"zzz99999999999") 
                                      else ttBonusCrmEntrada.CPF.
            
            ttbonus.codigoLoja      = ttBonusCrmEntrada.codigoLoja.
            ttbonus.dataEmisao      = ttBonusCrmEntrada.dataEmisao.
            ttbonus.descricao       = ttBonusCrmEntrada.descricao.
            ttbonus.valor           = ttBonusCrmEntrada.valor.
            ttbonus.vencimento      = string(btitulo.titdtven,"99/99/9999").
            ttbonus.pstatus         = "LIB".
        end.        
end.    


lokJson = hBonusCrmSaida:WRITE-JSON("LONGCHAR", lcJsonSaida, TRUE).

hBonusCrmSaida:WRITE-JSON("FILE","helio_BonusCrm.json", true).



procedure criatitulo.

    def output parameter out-rec as recid.

    def var dt-validade as date.
    def var vi as int.

    dt-validade =  
                date(if month(today) = 12 then 1 else month(today) + 1,
                     1,
                     if month(today) = 12
                     then int(string(year(today),"9999")) + 1
                     else int(string(year(today),"9999"))).
    repeat.
        if weekday(dt-validade) <> 1 and
           weekday(dt-validade) <> 7
        then do.
            find dtextra where dtextra.exdata = dt-validade no-lock no-error.
            if not avail dtextra
            then do.
                vi = vi + 1.
                if vi >= 5 /* 5o. dia util */
                then leave.
            end.
        end.
        dt-validade = dt-validade + 1.
    end.

    run gera-bonus-fique-aqui (input dt-validade,
                               output out-rec).

end procedure.


procedure gera-bonus-fique-aqui:
    def input parameter dt-validade as date.
    def output parameter out-rec as recid.

    def var vtitnum like titulo.titnum.


    vtitnum = string(day(today),"99") + string(month(today),"99") +
              string(year(today),"9999") + 
              replace(string(time,"HH:MM:SS"),":","").

    find first btitulo use-index titnum where
                      btitulo.empcod = 19 and
                      btitulo.titnat = yes and
                      btitulo.modcod = "BON" and
                      btitulo.etbcod = int(ttBonusCrmEntrada.codigoLoja) and
                      btitulo.clifor = neuclien.clicod and
                      btitulo.titnum = vtitnum and
                      btitulo.titpar = 0
                     NO-LOCK no-error.
    if avail btitulo
    then do:
        pause 1 no-message.
        vtitnum = string(day(today),"99") + string(month(today),"99") +
                  string(year(today),"9999") + 
                  replace(string(time,"HH:MM:SS"),":","").
    
        find first btitulo use-index titnum where
                      btitulo.empcod = 19 and
                      btitulo.titnat = yes and
                      btitulo.modcod = "BON" and
                      btitulo.etbcod = int(ttBonusCrmEntrada.codigoLoja) and
                      btitulo.clifor = neuclien.clicod and
                      btitulo.titnum = vtitnum and
                      btitulo.titpar = 0
                     NO-LOCK no-error.
    end.
    if not avail btitulo
    then do ON ERROR UNDO:
        create btitulo.
        assign
           btitulo.empcod    = 19
           btitulo.modcod    = "BON"
           btitulo.clifor    = neuclien.clicod
           btitulo.titnum    = vtitnum
           btitulo.titpar    = 0
           btitulo.titnat    = yes
           btitulo.etbcod    =  int(ttBonusCrmEntrada.codigoLoja)
           btitulo.titdtemi  = today
           btitulo.titdtven  = dt-validade
           btitulo.datexp    = today
           btitulo.titvlcob  = dec(ttBonusCrmEntrada.valor)
           btitulo.exportado = no
           btitulo.titsit    = "LIB"
           btitulo.moecod    = "BON"
           btitulo.titobs[2] = ttBonusCrmEntrada.descricao.
        out-rec = recid(btitulo).
    end.
           
end procedure.


