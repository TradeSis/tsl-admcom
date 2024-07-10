def var vdtvenc     as date format "99/99/9999" label "Vencimento Boleto".
def var vdtini      as date.
def var vdtfim      as date format "99/99/9999" label "Limite Vencimento".

def var vtoday  as date.
def var vtime   as int.

def var varquivo as char format "x(60)".
def var vcpf        as dec format ">>>>>>>>>>>>>9".     

def var par-tabelaorigem as char.
def var par-chaveorigem as char.
def var par-dadosorigem as char.
def var par-valorOrigem  as dec.


update varquivo label "Arquivo" 
    with side-labels width 80 .

vdtfim =date(month(today),28,year(today)) + 28.
vdtfim = date(month(vdtfim),01,year(vdtfim)) - 1.

update vdtfim.

vtoday  = today.
vtime   = time.
pause 0 before-hide.
input from value(varquivo) no-echo.
repeat on error undo, next.
    import vcpf.
    if string(vcpf) = "" or vcpf = 0 or vcpf = ?
    then next.
    find neuclien where neuclien.cpf = vcpf no-lock no-error.
    disp vcpf neuclien.clicod vtoday vtime.
    
    create banmassacli.
    banmassacli.CpfCnpj         = vcpf.
    banmassacli.Clicod          = if avail neuclien and neuclien.clicod <> 0
                                  then neuclien.clicod
                                  else ?.
    banmassacli.observacao      = if avail neuclien
                                  then ""
                                  else "Nao Encontrado cpf em NeuClien".
    banmassacli.DtEnvio         = ?.
    banmassacli.DtImportacao    = vtoday.
    banmassacli.hrImportacao    = vtime.
    banmassacli.DtEnvioCSV      = ?.
    banmassacli.DtVencBoleto    = ?.
    banmassacli.dtini           = ?.
    banmassacli.dtfim           = ?.

END.
input close.

for each banmassacli where banmassacli.dtenvio = ? and
                           banmassacli.dtimportacao = vtoday and
                           banmassacli.hrimportacao = vtime
                           no-lock.
    if banmassacli.clicod = ?
    then next.

    vdtvenc = ?.
    
    find neuclien where neuclien.clicod = banmassacli.clicod no-lock.
    for each titulo where titulo.clifor = neuclien.clicod no-lock
        by titulo.titdtven.
        if titulo.titsit = "LIB"
        then.
        else next.
        if titulo.titdtven >= today - 62 and
           titulo.titdtven <= vdtfim
        then.
        else next.
        if titulo.titvlcob = 0 then next.
        
        if titulo.modcod = "CRE" or
           titulo.modcod begins "CP"
        then .   
        else next.
        
    
        if vdtini = ?
        then vdtini = titulo.titdtven.
        
        if vdtvenc = ?
        then if titulo.titdtven > today
             then vdtvenc = titulo.titdtven + 1.

        par-tabelaorigem = "titulo".
        par-chaveOrigem  = "contnum,titpar".
        par-dadosOrigem  = string(int(titulo.titnum)) + "," +
                           string(titulo.titpar).

        find last banbolOrigem 
            where banbolorigem.tabelaOrigem = par-tabelaOrigem and
                  banbolorigem.chaveOrigem  = par-chaveOrigem and
                  banbolorigem.dadosOrigem  = par-dadosOrigem
            no-lock no-error.
        if avail banBolOrigem
        then do:
            next.
        end.        
        create banmassatit.
        banmassatit.Clicod       = banmassacli.Clicod.
        banmassatit.DtImportacao = banmassacli.DtImportacao.
        banmassatit.hrImportacao = banmassacli.hrImportacao.
        banmassatit.titulo-recid = recid(titulo).
    end.
    if vdtvenc = ?
    then do:
        vdtvenc = today + 1.
    end.    
     
    run p .
end.


message "Aguarde...".
run mas/emiteboletoapi.p.
hide message no-pause.
return.



procedure p.

do on error undo.

    find current banmassacli exclusive.
    
        if weekday(vdtvenc) = 6 
        then vdtvenc = vdtvenc + 3.
        if weekday(vdtvenc) = 7
        then vdtvenc = vdtvenc + 2. 
        if weekday(vdtvenc) = 1 
        then vdtvenc = vdtvenc + 1.
    
    banmassacli.dtvenc = vdtvenc.
    banmassacli.dtini  = vdtini.
    banmassacli.dtfim  = vdtfim.
    find first banmassatit of banmassacli no-lock no-error.
    if not avail banmassatit
    then banmassacli.observacao = "Sem Titulos nos Criterios," +
                        "ou já com Boleto".
end.


end procedure.

