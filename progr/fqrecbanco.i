
procedure receb_banco.

    def input  parameter par_titnum as char.
    def input  parameter par_titpar as int.
    def output parameter par_possui_boleto as log init no.
    def output parameter par_possui_ted    as log init no.
    def output parameter par_recid         as recid init ?.

    def var vtabelaorigem as char.
    def var vchaveorigem  as char.
    def var vdadosorigem  as char.

    assign
        vtabelaorigem = "titulo"
        vchaveorigem  = "contnum,titpar"
        vdadosorigem  = string(int(par_titnum)) + "," + string(par_titpar).

    find last banbolOrigem 
            where banbolorigem.tabelaOrigem = vtabelaorigem and
                  banbolorigem.chaveOrigem  = vchaveorigem and
                  banbolorigem.dadosOrigem  = vdadosorigem
            no-lock no-error.
    if avail banBolOrigem
    then do:
        find banboleto of banbolOrigem no-lock no-error.
        if avail banboleto
        then 
            if banboleto.dtpagamento <> ? 
            then assign
                    par_possui_boleto = yes
                    par_recid = recid(banboleto).
    end.

    find first banAviOrigem 
            where banAviOrigem.tabelaOrigem = vtabelaorigem and
                  banAviOrigem.chaveOrigem  = vchaveorigem and
                  banAviOrigem.dadosOrigem  = vdadosorigem
            no-lock no-error.
    if avail banAviOrigem
    then do:
        find banavisopag of banAviOrigem no-lock no-error.
        if avail banavisopag
        then 
            if banavisopag.dtpagamento <> ? 
            then assign
                    par_possui_ted = yes
                    par_recid = recid(banavisopag).
    end.

end procedure.

