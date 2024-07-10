/* 10 - DESATIVO A ESCRITA NO DIRETORIO MONTADO DO AC DEVIDO A TRAVAMENTOS */ 
DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.

{/admcom/barramento/metodos/buscaRegrasMotor.i}



/* LE ENTRADA */
lokJSON = hRegrasMotorEntrada:READ-JSON("longchar", lcJsonEntrada, "EMPTY").

find first ttRegrasMotorEntrada no-error.


        def var cpoliticas as char format "x(40)"
            extent 8 init
            ["P1 - Pre Aprovacao",
             "P2 - Cliente Novo",
             "P3 - Atualizacao de Dados",
             "P4 - Atualizacao Limites",
             "P5 - Autoriza Venda Normal",
             "P6 - Autoriza Saque Facil",
             "P7 - Autoriza Credito Pessoal",
             "P8 - Autoriza Novacao"].
        def var vpoliticas as char 
            extent 8 init
            ["P1",
             "P2",
             "P3",
             "P4",
             "P5",
             "P6",
             "P7",
             "P8"].
        def var ipolitica as int.
        def var epolitica as char.


create ttstatus.
ttstatus.situacao = "".
    find first tab_ini where tab_ini.etbcod = 0 and
                             tab_ini.cxacod = 0 and
                         tab_ini.parametro = "MOTOR_NEUROTECH_ATIVO"
    no-lock no-error.
    if avail tab_ini
    then  ttstatus.motorativo = if tab_ini.valor = "NAO"
                                then "NAO"
                                else "SIM".
    else  ttstatus.motorativo = "NAO".
    
    for each agfilcre where
             agfilcre.tipo = "NEUROTECH" 
             no-lock.
        find first ttgrupos where
            ttgrupos.grupo = string(agfilcre.codigo)
            no-error.
        if not avail ttgrupos
        then do:
            create ttgrupos.
            ttgrupos.grupo = string(agfilcre.codigo).
            ttgrupos.grupoNome   = agfilcre.descri.
        end.
        find first ttfilial where
                ttfilial.codigoFilial = string(agfilcre.etbcod) 
                no-error.
        if not avail ttfilial 
        then do:
            create ttfilial.
            ttfilial.codigoFilial = string(agfilcre.etbcod).
            ttfilial.grupo  = string(agfilcre.codigo).
        end.
    end.         

for each ttgrupos:
    do ipolitica = 1 to 8:
        find first ttgruposregras where
            ttgruposregras.grupo = ttgrupos.grupo and
            ttgruposregras.politica    = vpoliticas[ipolitica]
            no-error.
        if not avail ttgruposregras
        then do:
            create ttgruposregras.
            ttgruposregras.grupo    = ttgrupos.grupo.
            ttgruposregras.politica       = vpoliticas[ipolitica].
            ttgruposregras.politicaNome   = cpoliticas[ipolitica].
        end.
        for each tabparam where
                tabparam.tipo       = "NEUROTECH" and
                tabparam.grupo      = int(ttgrupos.grupo) and
                tabparam.aplicacao  = ttgruposregras.politica
                no-lock:
            find first ttgrupospolitica where
                    ttgrupospolitica.grupo = ttgrupos.grupo and
                    ttgrupospolitica.politica    = ttgruposregras.politica and
                    ttgrupospolitica.parametro   = tabparam.parametro
                 no-error.   
            if not avail ttgrupospolitica
            then do:        
                create ttgrupospolitica.
                ttgrupospolitica.grupo    = ttgrupos.grupo. 
                ttgrupospolitica.politica       = ttgruposregras.politica.
                ttgrupospolitica.Parametro      = tabparam.parametro.
                ttgrupospolitica.condicao       = tabparam.condicao.
                ttgrupospolitica.valor          = string(tabparam.valor).
                ttgrupospolitica.submete        = string(tabparam.bloqueio,"SIM/NAO").
                if tabparam.parametro = "QUANTIDADE CONTRATOS EXISTENTES"
                then  ttgrupospolitica.atributo = "QTDECONT".
                if tabparam.parametro = "DIAS ULTIMA COMPRA"
                then  ttgrupospolitica.atributo = "DTULTCPA".
                if tabparam.parametro = "DIAS ULTIMO PAGAMENTO"
                then  ttgrupospolitica.atributo = "DTULTPAGTO".
                if tabparam.parametro = "DIAS ULTIMA ATUALIZACAO"
                then  ttgrupospolitica.atributo = "CLIEN.DATEXP".
                if tabparam.parametro = "PERCENTUAL PARCELAS PAGAS"
                then  ttgrupospolitica.atributo = "PARCPAG/QTDPARC".
                if tabparam.parametro = "QUANTIDADE PARCELAS PAGAS"
                then  ttgrupospolitica.atributo = "PARCPAG".
                if tabparam.parametro = "SALDO ABERTO"
                then  ttgrupospolitica.atributo = "LIMITETOM".
                if tabparam.parametro = "QUANTIDADE DE NOVACOES FEITAS"
                then  ttgrupospolitica.atributo = "QTDENOV".
                if tabparam.parametro = "VALOR DE NOVACOES EM ABERTO"
                then  ttgrupospolitica.atributo = "TOTALNOV".
                if tabparam.parametro = "DIAS DE ATRASO ATUAL"
                then  ttgrupospolitica.atributo = "ATRASOATUAL".
                if tabparam.parametro = "CHEQUE DEVOLVIDO ABERTO"
                then  ttgrupospolitica.atributo = "VALORCHDEVOLV".
            end.


        end.        

    end.
end.


/* 10
lokJson = hRegrasMotor:WRITE-JSON("FILE", "helios.json", true).
*/
lokJson = hRegrasMotor:WRITE-JSON("LONGCHAR",  lcJsonSaida, TRUE).

