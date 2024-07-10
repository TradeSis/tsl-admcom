DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
def output param vok as char.
vok = "".

DEFINE var lcJsonsaida      AS LONGCHAR.


{/admcom/barramento/async/mercadologico_01.i}

/* LE ENTRADA */
lokJSON = hmercadologicoEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY") no-error.
if not lokJSON then return.


    
    for each ttarvore of ttmercadologico.

       /*
       field nivel as char 
       field descricaoNivel as char
       field codigo as char
       field descricao as char
       field ativo as char
       field dataCadastro as char
       field codigoSuperior as char
       */
       
            find clase where clase.clacod = int(codigo) exclusive no-error.
            if not avail clase
            then do:
                create clase.
                clase.clacod = int(codigo).
                clase.clanom = descricao.
                clase.clasup = if int(nivel) = 1
                               then 0
                               else int(codigoSuperior).
                clase.clagrau = int(nivel).
            end.
            else do:
                clase.clanom = descricao.
                clase.clasup = if int(nivel) = 1 
                               then 0 
                               else int(codigoSuperior).
            end.
        
    end.
    




