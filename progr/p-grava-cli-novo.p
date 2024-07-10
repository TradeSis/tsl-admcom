/*
#1 12.12.18 - Ricardo - Tratamento de lock
*/
/*#1 {admcab.i} */

def shared temp-table tt-clien like cliecom
    field tppes     as char
    field protocolo as char
    index idx01 is primary unique cpfcgc.

def var vcha-codcli-novo as char.

for each tt-clien no-lock.
            
    find first cliecom where cliecom.cpfcgc = tt-clien.cpfcgc 
                            exclusive-lock no-error.

    find first clien where clien.ciccgc = tt-clien.cpfcgc no-lock no-error.    
    if not avail cliecom 
    then do:
        if avail clien
        then do:
            create cliecom.
            assign cliecom.clicod = clien.clicod.
        end.
        else do:
            find last ecommerce.geranum where ecommerce.geranum.etbcod = 200
                                exclusive-lock no-error.
            if available ecommerce.geranum
            then do:
                assign vcha-codcli-novo = "1" + "200"
                            + string(ecommerce.geranum.clicod,"999999").

                assign ecommerce.geranum.clicod = ecommerce.geranum.clicod + 1.
            
                create cliecom.
                assign cliecom.clicod = integer(vcha-codcli-novo).
            end.
        end.
    end.
    else if not avail clien
        then find clien where clien.clicod = cliecom.clicod no-lock no-error.

    buffer-copy tt-clien except clicod to cliecom.

    if tt-clien.tppes = "tpeFisica"
    then cliecom.tippes = yes.
    else cliecom.tippes = no.
            
    if not avail clien 
    then do:    
        create clien.
        assign clien.clicod = cliecom.clicod
               clien.clinom = cliecom.clinom
               clien.ciccgc = cliecom.cpfcgc
               clien.zona = cliecom.email
               clien.dtnasc = cliecom.dtnasc
               clien.ciinsc = cliecom.ciinsc
               clien.sexo = cliecom.sexo
               clien.mae = cliecom.mae
               clien.estciv = cliecom.estciv
               clien.conjuge = cliecom.conjuge
               clien.datexp = today
               clien.cep[1] = cliecom.cep
               clien.endereco[1] = cliecom.endereco
               clien.numero[1] = cliecom.numero
               clien.compl[1] = cliecom.compl
               clien.bairro[1] = cliecom.bairro
               clien.cidade[1] = cliecom.cidade
               clien.ufeco[1] = cliecom.ufecod
               clien.tippes = cliecom.tippes.
    end.

    find /*#1 first*/ cpclien where cpclien.clicod = cliecom.clicod
                    exclusive-lock no-error.
    if not avail cpclien
    then do:
        create cpclien.
        assign cpclien.clicod = cliecom.clicod.
    end.
    
    assign cpclien.var-char12 = "ProtocoloCliFor=" + tt-clien.protocolo + "|".
    
    release clien no-error.
    release cpclien no-error.
    release cliecom no-error.              
end.
            
