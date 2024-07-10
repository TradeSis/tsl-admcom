/*************************************************************************
* PROGRAMA...: Funcoes.p
* FINALIDADE.: Funcoes diversas para programas
* PROGRAMADOR: Marcio Brener
* CHAMADA....: 1. definir o handle (def var h as handle)
*              2. inicializar a procedure
*                 run .../funcoes.p persistent handle h.
*              3. uso da funcao da procedure
*                 run funcao[procedure] in handle.
* ULT. ALTERA: 30/01/1999
**************************************************************************/
define shared var graf-valor  as decimal    format ">>9"   extent 12.
define shared var graf-cores  as integer    format ">>9"   extent 12.
define shared var graf-texto  as character  format "x(15)" extent 12.
define shared var graf-titulo as character.

pause 0 before-hide.
define stream s-temp.

define temp-table arquivo
       field linha as integer
       field texto as character.


function login-windows returns character.
    define variable cUserID as character no-undo.
    define variable iResult as integer   no-undo.
    define variable iSize   as integer   no-undo.

    assign cUserID = fill(' ', 256)
             iSize = 255.

    run GetUserNameA(output cUserID, input-output iSize, output iResult).

    return cUserID.
end function.

procedure GetUserNameA external "advapi32.dll":
    define output       parameter cUserID as character no-undo.
    define input-output parameter iBuffer as long      no-undo.
    define return       parameter iResult as short     no-undo.
end procedure.


function subtexto returns character
   (input texto  as character,
    input inicio as integer,
    input fim    as integer):

    return substring(texto, inicio, fim - inicio + 1).

end function.


function horas returns character
   (input p-datini as date,
    input p-horini as character,
    input p-datfim as date,
    input p-horfim as character).

    define variable i-totdia as integer.
    define variable i-qtdseg as integer.
    define variable i-qtdhor as integer.

    do:
        /*** 86.400 = 24 horas *** 21.600 = 6 horas *** 3.600 = 1 hora ***/

        assign i-totdia = 86400 * (p-datfim - p-datini)
               i-qtdseg = (((integer( substring(p-horfim,1,2) ) * 3600)  +
                            (integer( substring(p-horfim,3,2) ) *   60)) -
                           ((integer( substring(p-horini,1,2) ) * 3600)  +
                            (integer( substring(p-horini,3,2) ) *   60))).

        assign i-qtdhor = truncate(
                          integer((truncate((if i-qtdseg >= 0 then (i-totdia / 86400) else
                                                                  ((i-totdia - 86400) / 86400)),0) * 86400) +
                                  (if i-qtdseg < 0 then 86400 + i-qtdseg else i-qtdseg)) / 3600, 0).

        return string(i-qtdhor,'9999') + substring(string((if i-qtdseg > 0 then 86400 + i-qtdseg else i-qtdseg) - (i-qtdhor * 3600),"hh:mm"), 4, 2).
    end.
end function.

/* Verificar se o texto e todo numerico */
procedure numero:
    define input  parameter c-numero  as character.
    define output parameter l-retorno as logical format "Sim/Nao" initial false.

    define variable i as integer no-undo.

    assign c-numero = trim(c-numero).
    if c-numero = "" then return.
    repeat i = 1 to length(c-numero):
        if lookup(substring(c-numero, i, 1), "1,2,3,4,5,6,7,8,9,0,.,~,") = 0 then return.
    end.
    assign l-retorno = yes.
end procedure.

procedure dia:
    define input  parameter data as date format "99/99/9999".
    define output parameter dia  as character.
    define variable c as character extent 7 initial ["Segunda", "Terca", "Quarta", "Quinta", "Sexta", "Sabado", "Domingo"].
    assign dia = c[day(data)].
end.

procedure troca-decimal:
    define input  parameter c-numero  as character.
    define input  parameter c-milhar  as character.
    define input  parameter c-decimal as character.
    define output parameter c-saida   as character.

    define variable i as integer no-undo.

    repeat i = 1 to length(c-numero):
        if substring(c-numero, i, 1) = c-decimal then
            assign c-saida = c-saida + ",".
        else if substring(c-numero, i, 1) <> c-milhar then
            assign c-saida = c-saida + substring(c-numero, i, 1).
    end.
end procedure.

procedure retira-caracter:
    define input  parameter c-texto as character.
    define input  parameter c-chars as character.
    define output parameter c-saida as character.
    define variable    i       as integer.

    repeat i = 1 to length(c-texto):
        if lookup(substring(c-texto, i, 1), c-chars) = 0 then
            assign c-saida = c-saida + substring(c-texto, i, 1).
    end.
end procedure.

function retira-acento returns character(input texto as character):
    define variable c-retorno as character no-undo.
    define variable c         as character no-undo case-sensitive.
    define variable i         as integer   no-undo.

    repeat i = 1 to length(texto):
        assign c = substring(texto, i , 1).
        if      can-do("‹,Š,,Œ,Ž,ã,", c)  then assign c-retorno = c-retorno + "A".
        else if can-do("ß,Ó,Ò,Ô,õ,Õ",   c)  then assign c-retorno = c-retorno + "a".
        else if can-do("‘,,’,“,ú",     c)  then assign c-retorno = c-retorno + "E".
        else if can-do("Ú,Þ,Û,Ù,&",     c)  then assign c-retorno = c-retorno + "e".
        else if can-do("•,”,–,¤",       c)  then assign c-retorno = c-retorno + "I".
        else if can-do("Ý,ý,¯,´",       c)  then assign c-retorno = c-retorno + "i".
        else if can-do("Ë,Ê,È,Í,—",     c)  then assign c-retorno = c-retorno + "O".
        else if can-do("¾,,¶,÷,§",     c)  then assign c-retorno = c-retorno + "o".
        else if can-do("™,˜,›,š",       c)  then assign c-retorno = c-retorno + "U".
        else if can-do("·,¨,³,¹",       c)  then assign c-retorno = c-retorno + "u".
        else if can-do("Ã",             c)  then assign c-retorno = c-retorno + "C".
        else if can-do("þ",             c)  then assign c-retorno = c-retorno + "c".
        else if can-do("Ÿ,¦",           c)  then assign c-retorno = c-retorno + "Y".
        else if can-do(" ,²",           c)  then assign c-retorno = c-retorno + "y".
        else if can-do("Ð",             c)  then assign c-retorno = c-retorno + "N".
        else if can-do("±",             c)  then assign c-retorno = c-retorno + "n".
        else                                     assign c-retorno = c-retorno + c.
    end.

    return c-retorno.
end function.

procedure compila:
    define input  parameter lista   as character.
    define input  parameter arquivo as character.

    define variable i    as integer   no-undo.
    define variable prog as character no-undo.
    os-delete value(arquivo).

    do i = 1 to num-entries(lista):
        assign prog = ENTRY(i, lista).
        if search(prog) = ? then do:
            output to value(arquivo) append.
            put "ERRO: ARQUIVO NAO CONTRATADO -" prog format "x(30)" skip.
            output close.
            bell.
            message "ERRO: ARQUIVO NAO ENCONTRATADO -" prog
                    view-as alert-box warning title "Erro".
            next.
        end.

        message "Compilando arquivo" entry(i, lista) i "de" num-entries(lista).
        compile value(entry(i, lista)) save no-error.
        if compiler:error then do:
            output to value(arquivo) append.
            put "ERRO: (COMPILACAO) " compiler:filename format "x(30)"
                " LINHA "  compiler:error-row format ">>>>>9" 
                " COLUNA " compiler:error-col format ">>>>>9" skip.
            output close.
            bell.
            message "ERRO: (COMPILACAO) - ARQUIVO " compiler:filename
                    "LINHA" compiler:error-row "COLUNA" compiler:error-col
                    view-as alert-box warning title "Erro".
        end.
    end.
end procedure.

procedure extenso:
    define input  parameter valor as decimal format "-999,999,999,999.99".
    define output parameter retorno as character.

    define variable i as integer no-undo.
    define variable j as integer no-undo.
    define variable u as integer no-undo.
    define variable d as integer no-undo.
    define variable c as integer no-undo.

    define variable texto as character extent 5.

    define variable unidade as character extent 19.
    assign unidade[01] = " um"
           unidade[02] = " dois"
           unidade[03] = " tres"
           unidade[04] = " quatro"
           unidade[05] = " cinco"
           unidade[06] = " seis"
           unidade[07] = " sete"
           unidade[08] = " oito"
           unidade[09] = " nove"
           unidade[11] = " onze"
           unidade[12] = " doze"
           unidade[13] = " treze"
           unidade[14] = " quartoze"
           unidade[15] = " quinze"
           unidade[16] = " dezesseis"
           unidade[17] = " dezessete"
           unidade[18] = " dezeoito"
           unidade[19] = " dezenove".

    define variable dezena as character extent 9.
    assign dezena[01] = " dez"
           dezena[02] = " vinte"
           dezena[03] = " trinta"
           dezena[04] = " quarenta"
           dezena[05] = " cinquenta"
           dezena[06] = " sessenta"
           dezena[07] = " setenta"
           dezena[08] = " oitenta"
           dezena[09] = " noventa".

    define variable centena as character extent 9.
    assign centena[01] = " cem"
           centena[02] = " duzentos"
           centena[03] = " trezentos"
           centena[04] = " quatrocentos"
           centena[05] = " quinhentos"
           centena[06] = " seiscentos"
           centena[07] = " setecentos"
           centena[08] = " oitocentos"
           centena[09] = " novecentos".

    do i = 1 to 5:
        /* Centavos */
        if i = 1 then do:
            assign j = integer(substring(string(valor, "-999,999,999,999.99"), 18, 2)).
            if j = 0 then next.

            else if j < 20 and j <> 10 then assign texto[5] = unidade[j].
            else if j = 10 or j >= 20 then do:
                assign u = integer(substring(string(valor, "-999,999,999,999.99"), 19, 1)).
                assign d = integer(substring(string(valor, "-999,999,999,999.99"), 18, 1)).
                if u = 0 then assign texto[5] = dezena[d].
                else assign texto[5] = dezena[d] + " e" + unidade[u].
            end.
            if j = 1 then assign texto[5] = texto[5] + " centavo".
            else assign texto[5] = texto[5] + " centavos".
        end.

        /* Centenas */
        if i = 2 then do:
            assign j = integer(substring(string(valor, "-999,999,999,999.99"), 14, 3)).
            if j = 0 then next.

            assign u = integer(substring(string(valor, "-999,999,999,999.99"), 15, 2)).
            if u = 0 or u = 10 or u >= 20 then
                assign u = integer(substring(string(valor, "-999,999,999,999.99"), 16, 1)).

            assign d = integer(substring(string(valor, "-999,999,999,999.99"), 15, 1)).
            assign c = integer(substring(string(valor, "-999,999,999,999.99"), 14, 1)).
            
            assign texto[4] = if c = 1 and d = 0 and u = 0 then
                              centena[c]
                              else if c = 1 and (d <> 0 or u <> 0) then
                              " cento e"
                              else if c <> 0 and (d = 0 and u = 0) then
                              centena[c]
                              else if c <> 0 and (d <> 0 or u <> 0) then
                              centena[c] + " e"
                              else "".
            assign texto[4] = texto[4] +
                              if d = 0 then ""
                              else if d <> 0 and u <> 0 then
                              dezena[d] + " e"
                              else dezena[d].
            assign texto[4] = texto[4] +
                              if u = 0 then ""
                              else unidade[u].
        end.
                    
        /* Milhares */
        if i = 3 then do:
            assign j = integer(substring(string(valor, "-999,999,999,999.99"), 10, 3)).
            if j = 0 then next.

            assign u = integer(substring(string(valor, "-999,999,999,999.99"), 11, 2)).
            if u = 0 or u = 10 or u >= 20 then
                assign u = integer(substring(string(valor, "-999,999,999,999.99"), 12, 1)).

            assign d = integer(substring(string(valor, "-999,999,999,999.99"), 11, 1)).
            assign c = integer(substring(string(valor, "-999,999,999,999.99"), 10, 1)).

            assign texto[3] = if c = 1 and d = 0 and u = 0 then
                              centena[c]
                              else if c = 1 and (d <> 0 or u <> 0) then
                              " cento e"
                              else if c <> 0 and (d = 0 and u = 0) then
                              centena[c]
                              else if c <> 0 and (d <> 0 or u <> 0) then
                              centena[c] + " e"
                              else "".
            assign texto[3] = texto[3] +
                              if d = 0 then ""
                              else if d <> 0 and u <> 0 then
                              dezena[d] + " e"
                              else dezena[d].
            assign texto[3] = texto[3] +
                              if u = 0 then ""
                              else unidade[u].
            assign texto[3] = texto[3] + " mil".
        end.

        /* Milhoes */
        if i = 4 then do:
            assign j = integer(substring(string(valor, "-999,999,999,999.99"), 6, 3)).
            if j = 0 then next.

            assign u = integer(substring(string(valor, "-999,999,999,999.99"), 7, 2)).
            if u = 0 or u = 10 or u >= 20 then
                assign u = integer(substring(string(valor, "-999,999,999,999.99"), 8, 1)).
                
            assign d = integer(substring(string(valor, "-999,999,999,999.99"), 7, 1)).
            assign c = integer(substring(string(valor, "-999,999,999,999.99"), 6, 1)).

            assign texto[2] = if c = 1 and d = 0 and u = 0 then
                              centena[c]
                              else if c = 1 and (d <> 0 or u <> 0) then
                              " cento e"
                              else if c <> 0 and (d = 0 and u = 0) then
                              centena[c]
                              else if c <> 0 and (d <> 0 or u <> 0) then
                              centena[c] + " e"
                              else "".
            assign texto[2] = texto[2] +
                              if d = 0 then ""
                              else if d <> 0 and u <> 0 then
                              dezena[d] + " e"
                              else dezena[d].
            assign texto[2] = texto[2] +
                              if u = 0 then ""
                              else unidade[u].
            if j = 1 then assign texto[2] = texto[2] + " milhao".
            else if j > 1 then assign texto[2] = texto[2] + " milhoes".
        end.

        /* Bilhoes */
        if i = 5 then do:
            assign j = integer(substring(string(valor, "-999,999,999,999.99"), 2, 3)).
            if j = 0 then next.
        
            assign u = integer(substring(string(valor, "-999,999,999,999.99"), 3, 2)).
            if u = 0 or u = 10 or u >= 20 then
                assign u = integer(substring(string(valor, "-999,999,999,999.99"), 4, 1)).

            assign d = integer(substring(string(valor, "-999,999,999,999.99"), 3, 1)).
            assign c = integer(substring(string(valor, "-999,999,999,999.99"), 2, 1)).

            assign texto[1] = if c = 1 and d = 0 and u = 0 then
                              centena[c]
                              else if c = 1 and (d <> 0 or u <> 0) then
                              " cento e"
                              else if c <> 0 and (d = 0 and u = 0) then
                              centena[c]
                              else if c <> 0 and (d <> 0 or u <> 0) then
                              centena[c] + " e"
                              else "".
            assign texto[1] = texto[1] +
                              if d = 0 then ""
                              else if d <> 0 and u <> 0 then
                              dezena[d] + " e"
                              else dezena[d].
            assign texto[1] = texto[1] +
                              if u = 0 then ""
                              else unidade[u].
            if j = 1 then assign texto[1] = texto[1] + " bilhao".
            else if j > 1 then assign texto[1] = texto[1] + " bilhoes".
        end.
    end.

    /* Virgulas de separacao dos milhares */
    if texto[1] <> "" and (texto[2] <> "" or texto[3] <> "" or
       texto[4] <> "") then assign texto[1] = texto[1] + ",".

    if texto[2] <> "" and (texto[3] <> "" or texto[4] <> "") then
        assign texto[2] = texto[2] + ",".

    if texto[3] <> "" and texto[4] <> "" then
        assign texto[3] = texto[3] + " e".

    assign i = decimal(substring(string(valor, "-999999999999.99"), 2, 12)).
    assign j = integer(substring(string(valor, "-999999999999.99"), 15, 2)).
    if      i = 1 and j <> 0 then assign texto[4] = texto[4] + " real e".
    else if i > 1 and j <> 0 then assign texto[4] = texto[4] + " reais e".

    if      i = 1 and j = 0 then assign texto[4] = texto[4] + " real".
    else if i > 1 and j = 0 then assign texto[4] = texto[4] + " reais".

    assign retorno = texto[1] +
                     texto[2] +
                     texto[3] +
                     texto[4] +
                     texto[5].
end procedure.


procedure grava-ini:
    define input parameter arquivo as character.
    define input parameter secao   as character.
    define input parameter chave   as character.
    define input parameter valor   as character.

    define variable i as integer no-undo.


    &if "~{&window-system~}" = "ms-windows" or
        "~{&window-system~}" = "ms-win32"   or
        "~{&window-system~}" = "ms-win95"   &then
        unload search(arquivo) no-error.
        if search(arquivo) <> ? then
            load search(arquivo) no-error.
        else
            load search(arquivo) new no-error.

        use search(arquivo) no-error.
        put-key-value section secao key chave value valor.
        leave.
    &endif

    assign secao = trim(secao)
           chave = trim(chave).

    define variable c       as character.
    define variable l-secao as logical initial no.
    define variable l-chave as logical initial no.
    define variable i-linha as integer.

    if search(arquivo) = ? then do:
        output to value(arquivo) append.
        put "[" secao format "x(" + string(length(secao), "999") + ")" "]" skip
                chave format "x(" + string(length(chave), "999") + ")" "="
                valor format "x(" + string(length(valor), "999") + ")".
        output close.
        return.
    end.

    input from value(arquivo).
    repeat:
        assign i = i + 1.
        create arquivo.
        import unformatted arquivo.texto no-error.
        assign arquivo.linha = i.
    end.
    input close.

    /* Procurar a Secao */
    for each arquivo:
        assign c = substring(trim(arquivo.texto), 2)
               c = substring(c, 1, length(c) - 1).
        if c = secao then do:
             assign l-secao = true
                    i-linha = arquivo.linha.
             leave.
        end.
    end.

    if l-secao = no then do:
        assign i = i + 1.
        create arquivo.
        assign arquivo.linha = i
               arquivo.texto = "[" + trim(secao) + "]".
        assign i = i + 1.
        create arquivo.
        assign arquivo.linha = i
               arquivo.texto = trim(chave) + "=" + valor.
    end.
    else do:
        for each arquivo where
                arquivo.linha > i-linha:

             if substring(trim(arquivo.texto), 1, length(trim(chave))) = chave then do:
                  assign arquivo.texto = chave + "=" + valor
                               l-chave = yes.
                  leave.
             end.
             else if substring(trim(arquivo.texto), 1, 1) = "[" then do:
                  assign i-linha = arquivo.linha.
                  leave.
             end.
        end.

        if l-chave = no then do:
             create arquivo.
             assign arquivo.linha = i-linha
                    arquivo.texto = chave + "=" + valor.
             for each arquivo where
                      arquivo.linha >= i-linha:
                  assign arquivo.linha = arquivo.linha + 1.
             end.
        end.
    end.

    output to value(arquivo).
    for each arquivo by arquivo.linha:
        if arquivo.linha = 0 then next.
        put arquivo.texto format "x(256)" skip.
    end.
    output close.
end procedure.

procedure le-ini:
    define input  parameter arquivo as character.
    define input  parameter secao   as character.
    define input  parameter chave   as character.
    define output parameter valor   as character.
    define variable l-secao as logical.
    define variable c       as character.


    &if "~{&window-system~}" = "ms-windows" &then
        unload search(arquivo) no-error.
        load search(arquivo) no-error.
        use search(arquivo) no-error.
        get-key-value section secao key chave value valor.
        leave.
    &endif



    input from value(arquivo).
    repeat:
        import unformatted c no-error.
        if substring(trim(c), 1, 1) = "[" and
           substring(trim(c), 2, length(trim(c)) - 1) = secao then
            assign l-secao = yes.

        if substring(trim(c), 1, 1) = "[" and
            l-secao = yes then do:
            input close.
            return.
        end.

        if substring(trim(c), 1, length(chave) + 1) = (chave + "=") then do:
            assign valor = substring(trim(c), length(trim(chave)) + 2).
            input close.
            return.
        end.
    end.
    input close.
end procedure.

/*
procedure mes:
    define input  parameter i-mes as integer.
    define output parameter c-mes as character.
    define variable meses as character extent 12
        initial ["Janeiro", "Fevereiro", "Marco", "Abril", "Maio", "Junho",
              "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"].
    if i-mes < 1 or i-mes > 12 then return.
    assign c-mes = meses[i-mes].
end procedure.
*/

function mes returns character (input i-mes as integer).
    define variable meses as character extent 12
        initial ["Janeiro", "Fevereiro", "Marco", "Abril", "Maio", "Junho",
                 "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"].

    if i-mes < 1 or i-mes > 12 then return "".

    return meses[i-mes].
end function.

procedure cpf:
    define input parameter v-cpf as character format "999999999-99".

    define var digito  as logical format "Correto/Incorreto".
    define variable y as character format "99999999999".
    define variable z as integer.

    assign y = substring(v-cpf,1,9).

    assign z = (integer(substring(y,9,1)) * 2 + integer(substring(y,8,1)) * 3 +
                integer(substring(y,7,1)) * 4 + integer(substring(y,6,1)) * 5 +
                integer(substring(y,5,1)) * 6 + integer(substring(y,4,1)) * 7 +
                integer(substring(y,3,1)) * 8 + integer(substring(y,2,1)) * 9 +
                integer(substring(y,1,1)) * 10 )     
                modulo 11. 

    assign z = 11 - z.
    if  z = 11 or z = 10 then assign z = 0.

    assign y = substring(y,1,9) + string(z, "9").

    assign z = (integer(substring(y,10,1)) * 2 + integer(substring(y,9,1)) * 3 +
                integer(substring(y,8,1))  * 4 + integer(substring(y,7,1)) * 5 +
                integer(substring(y,6,1))  * 6 + integer(substring(y,5,1)) * 7 +
                integer(substring(y,4,1))  * 8 + integer(substring(y,3,1)) * 9 +   
                integer(substring(y,2,1)) * 10 + integer(substring(y,1,1)) * 11)     
                modulo 11. 

    assign z = 11 - z.
    if z = 11 or z = 10 then assign z = 0.
    
    assign y = substring(y,1,10) + string(z).

    if v-cpf = y then
        assign digito = true.
    else
        if v-cpf = "00000000000" then
            assign digito = true.
        else do:
            bell.
            message v-cpf "CPF invalido!"
                    view-as alert-box error title "Erro"
                    in window current-window.
            assign digito = false.
            return error.
        end.
end procedure.

procedure codigo-de-barras:
    define input  parameter posicao-y as integer   no-undo.
    define input  parameter posicao-x as integer   no-undo.
    define input  parameter numero    as decimal   no-undo.
    define output parameter barra     as character no-undo.

    define variable i      as integer   no-undo.
    define variable i-temp as integer   no-undo.
    define variable c-temp as character no-undo.
    define variable cBarra as character no-undo extent 100.

    assign c-temp = string(numero, "99999999999999999999999999999999999999999999").


    assign cBarra[01] = "nnWWn"
           cBarra[02] = "NnwwN"
           cBarra[03] = "nNwwN"
           cBarra[04] = "NNwwn"
           cBarra[05] = "nnWwN"
           cBarra[06] = "NnWwn"
           cBarra[07] = "nNWwn"
           cBarra[08] = "nnwWN"
           cBarra[09] = "NnwWn"
           cBarra[10] = "nNwWn"

           cBarra[11] = "wnNNw"
           cBarra[12] = "WnnnW"
           cBarra[13] = "wNnnW"
           cBarra[14] = "WNnnW"
           cBarra[15] = "wnNnW"
           cBarra[16] = "WnNnw"
           cBarra[17] = "wNNnw"
           cBarra[18] = "wnnNW"
           cBarra[19] = "WnnNw"
           cBarra[20] = "wNnNw"

           cBarra[21] = "nwNNw"
           cBarra[22] = "NwnnW"
           cBarra[23] = "nWnnW"
           cBarra[24] = "NWnnw"
           cBarra[25] = "nwNnW"
           cBarra[26] = "NwNnw"
           cBarra[27] = "nWNnw"
           cBarra[28] = "nwnNW"
           cBarra[29] = "NwnNw"
           cBarra[30] = "nWnNw"

           cBarra[31] = "wwNNn"
           cBarra[32] = "WwnnN"
           cBarra[33] = "wWnnN"
           cBarra[34] = "WWnnn"
           cBarra[35] = "wwNnN"
           cBarra[36] = "WwNnn"
           cBarra[37] = "wWNnn"
           cBarra[38] = "wwnNN"
           cBarra[39] = "WwnNn"
           cBarra[40] = "wWnNn"

           cBarra[41] = "nnWNw"
           cBarra[42] = "NnwnW"
           cBarra[43] = "nNwnW"
           cBarra[44] = "NNwnw"
           cBarra[45] = "nnWnW"
           cBarra[46] = "NnWnw"
           cBarra[47] = "nNWnw"
           cBarra[48] = "nnwNW"
           cBarra[49] = "NnwNw"
           cBarra[50] = "nNwNw"

           cBarra[51] = "wnWNn"
           cBarra[52] = "WnwnN"
           cBarra[53] = "wNwnN"
           cBarra[54] = "WNwnn"
           cBarra[55] = "wnWnN"
           cBarra[56] = "WnWnn"
           cBarra[57] = "wNWnn"
           cBarra[58] = "wnwNN"
           cBarra[59] = "WnwNn"
           cBarra[60] = "wnwNn"

           cBarra[61] = "nwWNn"
           cBarra[62] = "NwwnN"
           cBarra[63] = "nWwnN"
           cBarra[64] = "NWwnn"
           cBarra[65] = "nwWnN"
           cBarra[66] = "NwWnn"
           cBarra[67] = "nWWnn"
           cBarra[68] = "nwwNN"
           cBarra[69] = "NwwNn"
           cBarra[70] = "NWwNn"

           cBarra[71] = "nnNWw"
           cBarra[72] = "NnnwW"
           cBarra[73] = "nNnwW"
           cBarra[74] = "NNnww"
           cBarra[75] = "nnNwW"
           cBarra[76] = "NnNww"
           cBarra[77] = "nNNww"
           cBarra[78] = "nnnWW"
           cBarra[79] = "NnnWw"
           cBarra[80] = "nNnWw"

           cBarra[81] = "wnNWn"
           cBarra[82] = "WnnwN"
           cBarra[83] = "wNnwN"
           cBarra[84] = "WNnwn"
           cBarra[85] = "wnNwN"
           cBarra[86] = "WnNwn"
           cBarra[87] = "wNNwn"
           cBarra[88] = "wnnWN"
           cBarra[89] = "WnnWn"
           cBarra[90] = "wNnWn"

           cBarra[91] = "nwNWn"
           cBarra[92] = "NwnwN"
           cBarra[93] = "nWnwN"
           cBarra[94] = "NWnwn"
           cBarra[95] = "nwNwN"
           cBarra[96] = "NwNwn"
           cBarra[97] = "nWNwn"
           cBarra[98] = "nwnWN"
           cBarra[99] = "NwnWn"
           cBarra[100]= "nWnWn".

    do i = 1 To 44 by 2:
        assign i-temp = integer(substring(c-temp, i, 2)) + 1
               barra  = barra + cBarra[i-temp].
    end.

    assign barra = "~033" + "(1111X" + "~033" + "*p" + 
                   string(posicao-x, "9999999999") + "x" +
                   string(posicao-y, "9999999999") + "Y" +
                   "<" + barra + ">".
end procedure.

procedure verifica-cgc:
    define input parameter cgc as character no-undo format "999.999.999/9999-99".

    define variable i      as integer no-undo.
    define variable d-temp as integer no-undo.

    assign d-temp = (integer(substring(cgc, 01, 1)) * 00) +
                    (integer(substring(cgc, 02, 1)) * 05) +
                    (integer(substring(cgc, 03, 1)) * 04) +
                    (integer(substring(cgc, 04, 1)) * 03) +
                    (integer(substring(cgc, 05, 1)) * 02) +
                    (integer(substring(cgc, 06, 1)) * 09) +
                    (integer(substring(cgc, 07, 1)) * 08) +
                    (integer(substring(cgc, 08, 1)) * 07) +
                    (integer(substring(cgc, 09, 1)) * 06) +
                    (integer(substring(cgc, 10, 1)) * 05) +
                    (integer(substring(cgc, 11, 1)) * 04) +
                    (integer(substring(cgc, 12, 1)) * 03) +
                    (integer(substring(cgc, 13, 1)) * 02).

    assign i = if (d-temp modulo 11) = 1 or
                  (d-temp modulo 11) = 0 then 0
               else
                  11 - (d-temp modulo 11).

    if integer(substring(cgc, 14, 1)) <> i then do:
        bell.
        message "CGC invalido. 1§ Digito incorreto!" view-as alert-box error title "Aviso".
        return error.
    end.

    assign d-temp = (integer(substring(cgc, 01, 1)) * 00) +
                    (integer(substring(cgc, 02, 1)) * 06) +
                    (integer(substring(cgc, 03, 1)) * 05) +
                    (integer(substring(cgc, 04, 1)) * 04) +
                    (integer(substring(cgc, 05, 1)) * 03) +
                    (integer(substring(cgc, 06, 1)) * 02) +
                    (integer(substring(cgc, 07, 1)) * 09) +
                    (integer(substring(cgc, 08, 1)) * 08) +
                    (integer(substring(cgc, 09, 1)) * 07) +
                    (integer(substring(cgc, 10, 1)) * 06) +
                    (integer(substring(cgc, 11, 1)) * 05) +
                    (integer(substring(cgc, 12, 1)) * 04) +
                    (integer(substring(cgc, 13, 1)) * 03) +
                                                  i * 02.

    assign i = if (d-temp modulo 11) = 1 or
                  (d-temp modulo 11) = 0 then 0
               else
                  11 - (d-temp modulo 11).

    if integer(substring(cgc, 15, 1)) <> i then do:
        bell.
        message "CGC invalido. 2§ Digito incorreto!" view-as alert-box error title "Aviso".
        return error.
    end.
end procedure.

procedure estado:
    define input-output parameter estado as character.
    
         if estado = "AC" then assign estado = "Acre".
    else if estado = "AM" then assign estado = "Amazonas".
    else if estado = "RO" then assign estado = "Rondonia".
    else if estado = "RR" then assign estado = "Roraima".
    else if estado = "PA" then assign estado = "Para".
    else if estado = "BA" then assign estado = "Bahia".
    else if estado = "PI" then assign estado = "Piaui".
    else if estado = "CE" then assign estado = "Ceara".
    else if estado = "PB" then assign estado = "Paraiba".
    else if estado = "PE" then assign estado = "Pernambuco".
    else if estado = "AL" then assign estado = "Alagoas".
    else if estado = "RN" then assign estado = "Rio Grando do Norte".
    else if estado = "MA" then assign estado = "Maranhao".
    else if estado = "SE" then assign estado = "Sergipe".
    else if estado = "ES" then assign estado = "Espirito Santo".
    else if estado = "SP" then assign estado = "Sao Paulo".
    else if estado = "RJ" then assign estado = "Rio de Janeiro".
    else if estado = "BH" then assign estado = "Bahia".
    else if estado = "MT" then assign estado = "Mato Grosso".
    else if estado = "MS" then assign estado = "Mato Grosso Sul".
    else if estado = "GO" then assign estado = "Goias".
    else if estado = "DF" then assign estado = "Distrito Federal".
    else if estado = "PR" then assign estado = "Parana".
    else if estado = "RS" then assign estado = "Rio Grande do Sul".
    else if estado = "SC" then assign estado = "Santa Catarina".
    else                       assign estado = "".
end procedure.    

/*
Funcao para calculo de DV modulo 11
Exemplo: Agencias Bancarias
*/
function digito1 returns character(input numero as integer):
    define variable i     as integer no-undo.
    define variable total as integer no-undo.
    define variable mult  as integer no-undo initial 9.

    do i = length(trim(string(numero))) to 1 by -1:
        assign total = total +
                      (integer(substring(string(numero), i, 1)) * mult).

        if   mult = 2 then assign mult = 9.
        else mult = mult - 1.
    end.
    assign i = total modulo 11.
    if i = 10 then return "X".
    else           return string(i, "9").
end function.

procedure codifica:
    define input-output parameter texto as character.

    define variable j as integer   no-undo.
    define variable c as character no-undo.
    define variable i as integer   no-undo.

    do i = 1 to length(texto).
         assign j = asc(substring(texto, i, 1)).
        if      j <= 10               then assign c = c + chr(j + 03)  + "+"         + chr(j + 07)  + "z".
        else if j >= 11  and j <=  20 then assign c = c + chr(j + 07)  + chr(j + 05) + chr(j + 03)  + "%".
        else if j >= 21  and j <=  30 then assign c = c + chr(j + 05)  + chr(j + 03) + "!"          + "#".
        else if j >= 31  and j <=  40 then assign c = c + "*"          + chr(j + 06) + chr(j + 02)  + chr(j + 12).
        else if j >= 51  and j <=  70 then assign c = c + chr(j + 09)  + "/"         + chr(j + 04)  + chr(j + 11).
        else if j >= 71  and j <=  90 then assign c = c + chr(j + 11)  + "^"         + chr(j + 07)  + chr(j - 01).
        else if j >= 91  and j <= 110 then assign c = c + chr(j - 11)  + chr(j - 04) + chr(j - 07)  + "-".
        else if j >= 111 and j <= 130 then assign c = c + chr(j + 03)  + chr(j + 09) + "$"          + chr(j).
        else if j >= 131 and j <= 150 then assign c = c + chr(j + 09)  + chr(j + 21) + chr(j + 01)  + "]".
        else if j >= 151 and j <= 170 then assign c = c + chr(j - 10)  + "#"         + chr(j - 10)  + "?".
        else if j >= 171 and j <= 190 then assign c = c + chr(j - 11)  + chr(j - 12) + chr(j - 12)  + chr(j - 12).
        else if j >= 191 and j <= 200 then assign c = c + "@"          + chr(j + 09) + chr(j - 08)  + chr(j - 30).
        else if j >= 201 and j <= 210 then assign c = c + chr(j - 11)  + "w"         + "b"          + chr(j - 25).
        else if j >= 211 and j <= 230 then assign c = c + chr(j - 24)  + chr(j + 21) + "y"          + chr(j - 25).
        else if j >= 230 and j <= 250 then assign c = c + chr(j - 101) + "k"         + "a"          + chr(j - 34).
        else if j >= 251 and j <= 255 then assign c = c + chr(j)       + "o"         + "t"          + chr(j + 01).
        else if j >= 256 and j <= 270 then assign c = c + chr(j - 103) + chr(j)      + "1"          + chr(j - 01).
        else if j >= 270 and j <= 300 then assign c = c + chr(j)       + "@"         + "&"          + chr(j).
        else                               assign c = c + chr(j - 121) + chr(j - 34) + chr(j)       + "(".
    end.
    assign texto = c.
end procedure.


procedure decodifica:
    define input  parameter texto as character.
    define output parameter senha as character.

    define variable i  as integer   no-undo.
    define variable w  as character no-undo.

    define variable c  as character.
    define variable c1 as character format "x".
    define variable c2 as character format "x".
    define variable c3 as character format "x".
    define variable c4 as character format "x".

    do i = 1 to length(texto) by 4:
         assign w  = substring(texto, i, 4).
         assign c1 = substring(w, 1, 1)
                c2 = substring(w, 2, 1)
                c3 = substring(w, 3, 1)
                c4 = substring(w, 4, 1).


    end.
    assign senha = c.
end procedure.

procedure porcentagem:
    define input parameter d-porcent as decimal format "zz9.9".

    if d-porcent >= 100 then do:
        hide frame f-porcentagem no-pause.
        leave.
    end.

    define button b-porcentagem label "" size 1 by 1.
    form b-porcentagem
         with bgcolor 8 no-labels
         three-d no-attr-space row 8
         centered width 50.5 overlay
         frame f-porcentagem.

    assign b-porcentagem:width in frame f-porcentagem = d-porcent / 2
           b-porcentagem:label = string(d-porcent, "zz9.9") + "%".
    display b-porcentagem with frame f-porcentagem.
    if d-porcent >= 100 then do:
        pause 0.5 no-message.
        hide frame f-porcentagem no-pause.
    end.
end procedure.

procedure tabela-asc:
    define variable c     as character    no-undo.
    define variable lista as character    view-as selection-list inner-chars 8 inner-lines 10
                             scrollbar-vertical no-undo.

    define variable i as integer no-undo.

    form lista
         with frame f-lista
         view-as dialog-box no-labels
         no-underline title "ASC" overlay.

    do i = 33 to 255:
        assign c = c + string(i, "zz9") + " " + chr(i) + ",".
    end.

    assign input frame f-lista lista:list-items = c.
    update lista with frame f-lista.
end.

procedure configuracao:
    define input parameter arquivo as character.

    define variable i     as integer.
    define variable l     as logical.
    define variable c     as character.
    define variable texto as character.



    if arquivo = "" then assign arquivo = session:temp-directory + "info.pro".

    output to value(arquivo) paged page-size 64.

    form header
         skip fill("-", 132) format "x(132)" at 01 skip(1)
         "CASSI - CAIXA DE ASSITENCIA DOS FUNCIONARIOS DO BANCO DO BRASIL" at 01
         "FOLHA:" to 125 page-number format "zz9" skip
         "RELATORIO DE CONFIGURACOES DO SISTEMA" at 01 skip
         fill("-", 132) format "x(132)" at 01 skip
         with frame f-cabecalho page-top width 135 overlay.
    view frame f-cabecalho.

    form header
         skip fill("-", 107) format "x(107)"
         today format "99/99/9999"
         string(time, "hh:mm:ss") format "x(8)"
         with frame f-rodape page-bottom width 155 overlay.
    view frame f-rodape.

    put unformatted
        "CONFIGURACOES GLOBAIS"   at 10
        "---------------------"   at 10
        "OPSYS: "                 to 25 opsys
        "PLATAFORMA: "            to 25 "{&window-system}"
        "INTERFACE: "             to 25 session:display-type
        "LINGUAGEM ATUAL: "       to 25 if   current-language = ? then "NAO DISPONIVEL"
                                        else current-language
        "PROGRESS: "              to 25 progress
        "VERSAO DO PROGRESS: "    to 25 proversion
        "TIPO DE TERMINAL: "      to 25 terminal
        "PROPATH: "               to 25 substring(propath, 01, 30) "..."
        "PROMSGS: "               to 25 promsgs
        "FORMATO DATA: "          to 25 session:date-format
        "FORMATO NUMERO: "        to 25 session:numeric-format
        "DISPLAY IMEDIATO: "      to 25 session:immediate-display format "Sim/Nao"
        "INTERVALO MULTITAREFA: " to 25 session:multitasking-interval
        "DIRETORIO TEMPORARIO: "  to 25 session:temp-directory
        "DISPLAY VERSAO 6: "      to 25 session:v6display
        "GATEWAYS: "              to 25 gateways
        "SERVIDORES: "            to 25 dataservers
        "PIXELS POR LINHA: "      to 25 session:pixels-per-row    format "zz9"
        "PIXELS POR COLUNA: "     to 25 session:pixels-per-column format "zz9"
        "PATH: "                  to 25 os-getenv("path")
        "COMSPEC: "               to 25 os-getenv("comspec")
        "ESTACAO: "               to 25 os-getenv("estacao").

    if num-dbs > 0 then do:
        page.
        put unformatted
            "BANCOS DE DADOS" at 10
            "---------------" at 10
            "DATABASES CONECTADAS:" to 25 num-dbs format ">>9".

        do i = 1 to num-dbs:
            put unformatted
                fill("-", 50)        at 01
                "NOME FISICO: "      to 25 pdbname(i)
                "NOME LOGICO: "      to 25 ldbname(i)
                "SQUEMA NAME: "      to 25 sdbname(i)
                "ALIAS: "            to 25 alias(i)
                "DATABASE VERSAO: "  to 25 dbversion(i)
                "RESTRICOES: "       to 25 dbrestrictions(i)
                "DATABASE TIPO: "    to 25 dbtype(i) skip(1).
        end.
    end.

    if opsys = "msdos" or
       opsys = "unix" then do:
    
        /* Configuracoes do SET */
        page.
        assign c = session:temp-directory + "set.tmp".
        if opsys = "msdos" then dos  silent set > value(c).
        else                    unix silent set > value(c).
    
        input stream s-temp from value(c) unbuffered.
        repeat:
            import stream s-temp unformatted c no-error.
            assign texto = texto + c +(chr(13) + chr(10)).
        end.
        input stream s-temp close.
        put unformatted
            "CONFIGURACOES DO SET" at 10
            "--------------------" at 10
            texto at 01.

        if opsys = "msdos" or opsys = "unix" then do:
            if search("c:\autoexec.bat") <> ? then do:
                page.
                assign texto = "".
                input stream s-temp from "c:\autoexec.bat" unbuffered.
                repeat:
                    import stream s-temp unformatted c no-error.
                    assign texto = texto + c + (chr(13) + chr(10)).
                end.
                input stream s-temp close.
                put unformatted
                    "CONFIGURACOES DO AUTOEXEC.BAT" at 10
                    "-----------------------------" at 10
                    texto at 01.
            end.
        
            if search("c:\config.sys") <> ? then do:
                page.
                assign texto = "".
                input stream s-temp from "c:\config.sys" unbuffered.
                repeat:
                    import stream s-temp unformatted c no-error.
                    assign texto = texto + c + (chr(13) + chr(10)).
                end.
                input stream s-temp close.
                put unformatted
                    "CONFIGURACOES DO CONFIG.SYS" at 10
                    "---------------------------" at 10
                    texto at 01.
            end.

            /* Obter HOSTS, SERVICES, NETWORKS */
            if opsys = "msdos" or
               opsys = "unix"  then do:

                /* Procura do SERVICES */
                assign c = "".
                if search("c:\windows\services") <> ? then
                    assign c = "c:\windows\services".
                else if search("c:\winnt\system32\drivers\etc\services") <> ? then
                    assign c = "c:\winnt\system32\drivers\etc\services".
                else if search("c:\win95\services") <> ? then
                    assign c = "c:\win95\services".
                else if search("c:\windows.000\services") <> ? then
                    assign c = "c:\windows.000\services".
                else if search("/etc/services") <> ? then
                    assign c = "/etc/services".

                if search(c) <> ? then do:
                    page.
                    assign texto = "".
                    input stream s-temp from value(c) unbuffered.
                    repeat:
                        import stream s-temp unformatted c no-error.
                        assign texto = texto + c + (chr(13) + chr(10)).
                    end.
                    input stream s-temp close.
                    put unformatted
                        "CONFIGURACOES DO SERVICOS" at 10
                        "-------------------------" at 10
                        texto at 01.
                end.


                /* Procura do HOSTS */
                assign c = "".
                if search("c:\windows\hosts") <> ? then
                    assign c = "c:\windows\hosts".
                else if search("c:\winnt\system32\drivers\etc\hosts") <> ? then
                    assign c = "c:\winnt\system32\drivers\etc\hosts".
                else if search("c:\win95\hosts") <> ? then
                    assign c = "c:\win95\hosts".
                else if search("c:\windows.000\hosts") <> ? then
                    assign c = "c:\windows.000\hosts".
                else if search("/etc/hosts") <> ? then
                    assign c = "/etc/hosts".

                if search(c) <> ? then do:
                    page.
                    assign texto = "".
                    input stream s-temp from value(c) unbuffered.
                    repeat:
                        import stream s-temp unformatted c no-error.
                        assign texto = texto + c + (chr(13) + chr(10)).
                    end.
                    input stream s-temp close.
                    put unformatted
                        "CONFIGURACOES DO HOSTS" at 10
                        "----------------------" at 10
                        texto at 01.
                end.


                /* Procura do NETWORKS */
                assign c = "".
                if search("c:\windows\networks") <> ? then
                    assign c = "c:\windows\networks".
                else if search("c:\winnt\system32\drivers\etc\networks") <> ? then
                    assign c = "c:\winnt\system32\drivers\etc\networks".
                else if search("c:\win95\networks") <> ? then
                    assign c = "c:\win95\networks".
                else if search("c:\windows.000\networks") <> ? then
                    assign c = "c:\windows.000\networks".
                else if search("/etc/networks") <> ? then
                    assign c = "/etc/networks".

                if search(c) <> ? then do:
                    page.
                    assign texto = "".
                    input stream s-temp from value(c) unbuffered.
                    repeat:
                        import stream s-temp unformatted c no-error.
                        assign texto = texto + c + (chr(13) + chr(10)).
                    end.
                    input stream s-temp close.
                    put unformatted
                        "CONFIGURACOES DO NETWORKS" at 10
                        "-------------------------" at 10
                        texto at 01.
                end.
            end.
        end.
    end.
    page.
    output close.

end procedure.

/* Resulucao: 800x600, fontes pequenas */
procedure grafico-horizontal1:
    def rectangle r01 size 0.01 by 1 graphic-edge.
    def rectangle r02 size 0.01 by 1 graphic-edge.
    def rectangle r03 size 0.01 by 1 graphic-edge.
    def rectangle r04 size 0.01 by 1 graphic-edge.
    def rectangle r05 size 0.01 by 1 graphic-edge.
    def rectangle r06 size 0.01 by 1 graphic-edge.
    def rectangle r07 size 0.01 by 1 graphic-edge.
    def rectangle r08 size 0.01 by 1 graphic-edge.
    def rectangle r09 size 0.01 by 1 graphic-edge.
    def rectangle r10 size 0.01 by 1 graphic-edge.
    def rectangle r11 size 0.01 by 1 graphic-edge.
    def rectangle r12 size 0.01 by 1 graphic-edge.

    define variable i as integer no-undo.


    do i = 1 to extent(graf-texto):
        assign graf-texto[i] = fill(" ", 10 - length(trim(graf-texto[i]))) +
                               trim(graf-texto[i]).
    end.

    if graf-cores[01] = 0 and
       graf-cores[02] = 0 and
       graf-cores[03] = 0 and
       graf-cores[04] = 0 and
       graf-cores[05] = 0 and
       graf-cores[06] = 0 and
       graf-cores[07] = 0 and
       graf-cores[08] = 0 and
       graf-cores[09] = 0 and
       graf-cores[10] = 0 and
       graf-cores[11] = 0 and
       graf-cores[12] = 0 then
    assign graf-cores[01] = 01
           graf-cores[02] = 02
           graf-cores[03] = 03
           graf-cores[04] = 04
           graf-cores[05] = 05
           graf-cores[06] = 06
           graf-cores[07] = 07
           graf-cores[08] = 08
           graf-cores[09] = 09
           graf-cores[10] = 10
           graf-cores[11] = 11
           graf-cores[12] = 12.

    do i = 1 to extent(graf-valor):
        if graf-valor[i] <= 0 then assign graf-cores[i] = 15.
    end.

    form
         r01 at row 14 column 17 bgcolor graf-cores[01] fgcolor graf-cores[01]
         r02 at row 13 column 17 bgcolor graf-cores[02] fgcolor graf-cores[02]
         r03 at row 12 column 17 bgcolor graf-cores[03] fgcolor graf-cores[03]
         r04 at row 11 column 17 bgcolor graf-cores[04] fgcolor graf-cores[04]
         r05 at row 10 column 17 bgcolor graf-cores[05] fgcolor graf-cores[05]
         r06 at row 09 column 17 bgcolor graf-cores[06] fgcolor graf-cores[06]
         r07 at row 08 column 17 bgcolor graf-cores[07] fgcolor graf-cores[07]
         r08 at row 07 column 17 bgcolor graf-cores[08] fgcolor graf-cores[08]
         r09 at row 06 column 17 bgcolor graf-cores[09] fgcolor graf-cores[09]
         r10 at row 05 column 17 bgcolor graf-cores[10] fgcolor graf-cores[10]
         r11 at row 04 column 17 bgcolor graf-cores[11] fgcolor graf-cores[11]
         r12 at row 03 column 17 bgcolor graf-cores[12] fgcolor graf-cores[12]
         graf-texto[12] view-as text at row 03 column 16 right-aligned fgcolor graf-cores[12]
         graf-texto[11] view-as text at row 04 column 16 right-aligned fgcolor graf-cores[11]
         graf-texto[10] view-as text at row 05 column 16 right-aligned fgcolor graf-cores[10]
         graf-texto[09] view-as text at row 06 column 16 right-aligned fgcolor graf-cores[09]
         graf-texto[08] view-as text at row 07 column 16 right-aligned fgcolor graf-cores[08]
         graf-texto[07] view-as text at row 08 column 16 right-aligned fgcolor graf-cores[07]
         graf-texto[06] view-as text at row 09 column 16 right-aligned fgcolor graf-cores[06]
         graf-texto[05] view-as text at row 10 column 16 right-aligned fgcolor graf-cores[05]
         graf-texto[04] view-as text at row 11 column 16 right-aligned fgcolor graf-cores[04]
         graf-texto[03] view-as text at row 12 column 16 right-aligned fgcolor graf-cores[03]
         graf-texto[02] view-as text at row 13 column 16 right-aligned fgcolor graf-cores[02]
         graf-texto[01] view-as text at row 14 column 16 right-aligned fgcolor graf-cores[01]
         "'" at row 15 column 17.0 "0%"   at row 15.4 column 17.0 right-aligned
         "'" at row 15 column 21.6
         "'" at row 15 column 26.5
         "'" at row 15 column 31.6
         "'" at row 15 column 36.5
         "'" at row 15 column 41.6 "50%"  at row 15.4 column 41.6 right-aligned
         "'" at row 15 column 46.5
         "'" at row 15 column 51.5
         "'" at row 15 column 56.5
         "'" at row 15 column 61.6
         "'" at row 15 column 66.5 "100%" at row 15.4 column 66.5 right-aligned
         skip(1)
         with frame f-grafico view-as dialog-box
         use-text no-underline side-labels
         no-labels width 80 keep-tab-order centered title graf-titulo.

    assign r01:width in frame f-grafico = if graf-valor[01] > 0 then graf-valor[01] / 2 else 1.00
           r02:width in frame f-grafico = if graf-valor[02] > 0 then graf-valor[02] / 2 else 1.00
           r03:width in frame f-grafico = if graf-valor[03] > 0 then graf-valor[03] / 2 else 1.00
           r04:width in frame f-grafico = if graf-valor[04] > 0 then graf-valor[04] / 2 else 1.00
           r05:width in frame f-grafico = if graf-valor[05] > 0 then graf-valor[05] / 2 else 1.00
           r06:width in frame f-grafico = if graf-valor[06] > 0 then graf-valor[06] / 2 else 1.00
           r07:width in frame f-grafico = if graf-valor[07] > 0 then graf-valor[07] / 2 else 1.00
           r08:width in frame f-grafico = if graf-valor[08] > 0 then graf-valor[08] / 2 else 1.00
           r09:width in frame f-grafico = if graf-valor[09] > 0 then graf-valor[09] / 2 else 1.00
           r10:width in frame f-grafico = if graf-valor[10] > 0 then graf-valor[10] / 2 else 1.00
           r11:width in frame f-grafico = if graf-valor[11] > 0 then graf-valor[11] / 2 else 1.00
           r12:width in frame f-grafico = if graf-valor[12] > 0 then graf-valor[12] / 2 else 1.00.

    display r01
            r02
            r03
            r04
            r05
            r06
            r07
            r08
            r09
            r10
            r11
            r12
            graf-texto with frame f-grafico.
    pause message "Pressione ESPACO para fechar".
end procedure.

/* Resulucao: 800x600, fontes pequenas */
procedure grafico-vertical1:
    def rectangle r01 size 5 by 1 graphic-edge.
    def rectangle r02 size 5 by 1 graphic-edge.
    def rectangle r03 size 5 by 1 graphic-edge.
    def rectangle r04 size 5 by 1 graphic-edge.
    def rectangle r05 size 5 by 1 graphic-edge.
    def rectangle r06 size 5 by 1 graphic-edge.
    def rectangle r07 size 5 by 1 graphic-edge.
    def rectangle r08 size 5 by 1 graphic-edge.
    def rectangle r09 size 5 by 1 graphic-edge.
    def rectangle r10 size 5 by 1 graphic-edge.
    def rectangle r11 size 5 by 1 graphic-edge.
    def rectangle r12 size 5 by 1 graphic-edge.

    def rectangle rl01 size-pixel 10 by 10 graphic-edge.
    def rectangle rl02 size-pixel 10 by 10 graphic-edge.
    def rectangle rl03 size-pixel 10 by 10 graphic-edge.
    def rectangle rl04 size-pixel 10 by 10 graphic-edge.
    def rectangle rl05 size-pixel 10 by 10 graphic-edge.
    def rectangle rl06 size-pixel 10 by 10 graphic-edge.
    def rectangle rl07 size-pixel 10 by 10 graphic-edge.
    def rectangle rl08 size-pixel 10 by 10 graphic-edge.
    def rectangle rl09 size-pixel 10 by 10 graphic-edge.
    def rectangle rl10 size-pixel 10 by 10 graphic-edge.
    def rectangle rl11 size-pixel 10 by 10 graphic-edge.
    def rectangle rl12 size-pixel 10 by 10 graphic-edge.

    define variable i as integer no-undo.

    do i = 1 to extent(graf-texto):
        assign graf-texto[i] = fill(" ", 10 - length(trim(graf-texto[i]))) +
                               trim(graf-texto[i]).
    end.

    if graf-cores[01] = 0 and
       graf-cores[02] = 0 and
       graf-cores[03] = 0 and
       graf-cores[04] = 0 and
       graf-cores[05] = 0 and
       graf-cores[06] = 0 and
       graf-cores[07] = 0 and
       graf-cores[08] = 0 and
       graf-cores[09] = 0 and
       graf-cores[10] = 0 and
       graf-cores[11] = 0 and
       graf-cores[12] = 0 then
    assign graf-cores[01] = 01
           graf-cores[02] = 02
           graf-cores[03] = 03
           graf-cores[04] = 04
           graf-cores[05] = 05
           graf-cores[06] = 06
           graf-cores[07] = 07
           graf-cores[08] = 08
           graf-cores[09] = 09
           graf-cores[10] = 10
           graf-cores[11] = 11
           graf-cores[12] = 12.

    do i = 1 to extent(graf-valor):
        if graf-valor[i] <= 0 then assign graf-cores[i] = 15.
    end.


    /* Resolucao 800x600, fontes pequenas */
    if session:pixels-per-row    = 15 and
       session:pixels-per-column = 08 then do:
        form
             r01 at row 20 column 06.0 bgcolor graf-cores[01] fgcolor graf-cores[01]
             r02 at row 20 column 11.1 bgcolor graf-cores[02] fgcolor graf-cores[02]
             r03 at row 20 column 16.3 bgcolor graf-cores[03] fgcolor graf-cores[03]
             r04 at row 20 column 21.4 bgcolor graf-cores[04] fgcolor graf-cores[04]
             r05 at row 20 column 26.5 bgcolor graf-cores[05] fgcolor graf-cores[05]
             r06 at row 20 column 31.6 bgcolor graf-cores[06] fgcolor graf-cores[06]
             r07 at row 20 column 36.8 bgcolor graf-cores[07] fgcolor graf-cores[07]
             r08 at row 20 column 41.9 bgcolor graf-cores[08] fgcolor graf-cores[08]
             r09 at row 20 column 47.0 bgcolor graf-cores[09] fgcolor graf-cores[09]
             r10 at row 20 column 52.1 bgcolor graf-cores[10] fgcolor graf-cores[10]
             r11 at row 20 column 57.2 bgcolor graf-cores[11] fgcolor graf-cores[11]
             r12 at row 20 column 62.5 bgcolor graf-cores[12] fgcolor graf-cores[12]
             graf-valor[01] at row 20 column 06.0 left-aligned font 2 fgcolor graf-cores[01]
             graf-valor[02] at row 20 column 11.2 left-aligned font 2 fgcolor graf-cores[02]
             graf-valor[03] at row 20 column 16.3 left-aligned font 2 fgcolor graf-cores[03]
             graf-valor[04] at row 20 column 21.4 left-aligned font 2 fgcolor graf-cores[04]
             graf-valor[05] at row 20 column 26.6 left-aligned font 2 fgcolor graf-cores[05]
             graf-valor[06] at row 20 column 31.7 left-aligned font 2 fgcolor graf-cores[06]
             graf-valor[07] at row 20 column 36.9 left-aligned font 2 fgcolor graf-cores[07]
             graf-valor[08] at row 20 column 42.0 left-aligned font 2 fgcolor graf-cores[08]
             graf-valor[09] at row 20 column 47.2 left-aligned font 2 fgcolor graf-cores[09]
             graf-valor[10] at row 20 column 52.3 left-aligned font 2 fgcolor graf-cores[10]
             graf-valor[11] at row 20 column 57.4 left-aligned font 2 fgcolor graf-cores[11]
             graf-valor[12] at row 20 column 62.5 left-aligned font 2 fgcolor graf-cores[12]
             "-" at row 19.4 column 05.0
             "%" at row 20.0 column 04.7
             "-" at row 11.1 column 05.0
             "-" at row 02.9 column 05.0
             with frame f-grafico1 view-as dialog-box
             use-text no-underline side-labels
             no-labels width 80 keep-tab-order centered title graf-titulo.

        form
             rl01 at row 21.0 column 06.0 bgcolor graf-cores[01] fgcolor graf-cores[01]
             rl02 at row 21.8 column 06.0 bgcolor graf-cores[02] fgcolor graf-cores[02]
             rl03 at row 22.6 column 06.0 bgcolor graf-cores[03] fgcolor graf-cores[03]
             rl04 at row 23.4 column 06.0 bgcolor graf-cores[04] fgcolor graf-cores[04]
             rl05 at row 21.0 column 24.0 bgcolor graf-cores[05] fgcolor graf-cores[05]
             rl06 at row 21.8 column 24.0 bgcolor graf-cores[06] fgcolor graf-cores[06]
             rl07 at row 22.6 column 24.0 bgcolor graf-cores[07] fgcolor graf-cores[07]
             rl08 at row 23.4 column 24.0 bgcolor graf-cores[08] fgcolor graf-cores[08]
             rl09 at row 21.0 column 42.0 bgcolor graf-cores[09] fgcolor graf-cores[09]
             rl10 at row 21.8 column 42.0 bgcolor graf-cores[10] fgcolor graf-cores[10]
             rl11 at row 22.6 column 42.0 bgcolor graf-cores[11] fgcolor graf-cores[11]
             rl12 at row 23.4 column 42.0 bgcolor graf-cores[12] fgcolor graf-cores[12]
             graf-texto[01] view-as text at row 20.8 column 07.5 left-aligned font 2 fgcolor graf-cores[01]
             graf-texto[02] view-as text at row 21.6 column 07.5 left-aligned font 2 fgcolor graf-cores[02]
             graf-texto[03] view-as text at row 22.4 column 07.5 left-aligned font 2 fgcolor graf-cores[03]
             graf-texto[04] view-as text at row 23.2 column 07.5 left-aligned font 2 fgcolor graf-cores[04]
             graf-texto[05] view-as text at row 20.8 column 25.5 left-aligned font 2 fgcolor graf-cores[05]
             graf-texto[06] view-as text at row 21.6 column 25.5 left-aligned font 2 fgcolor graf-cores[06]
             graf-texto[07] view-as text at row 22.4 column 25.5 left-aligned font 2 fgcolor graf-cores[07]
             graf-texto[08] view-as text at row 23.2 column 25.5 left-aligned font 2 fgcolor graf-cores[08]
             graf-texto[09] view-as text at row 20.8 column 43.5 left-aligned font 2 fgcolor graf-cores[09]
             graf-texto[10] view-as text at row 21.6 column 43.5 left-aligned font 2 fgcolor graf-cores[10]
             graf-texto[11] view-as text at row 22.4 column 43.5 left-aligned font 2 fgcolor graf-cores[11]
             graf-texto[12] view-as text at row 23.2 column 43.5 left-aligned font 2 fgcolor graf-cores[12]
             skip(1)
             with frame f-grafico1 view-as dialog-box
             use-text no-underline side-labels
             no-labels width 80 keep-tab-order centered title graf-titulo.

        if graf-valor[01] > 0 then assign r01:row = r01:row - ((if graf-valor[01] > 100 then 250 else graf-valor[01] * 2.5) / session:pixels-per-row).
        if graf-valor[02] > 0 then assign r02:row = r02:row - ((if graf-valor[02] > 100 then 250 else graf-valor[02] * 2.5) / session:pixels-per-row).
        if graf-valor[03] > 0 then assign r03:row = r03:row - ((if graf-valor[03] > 100 then 250 else graf-valor[03] * 2.5) / session:pixels-per-row).
        if graf-valor[04] > 0 then assign r04:row = r04:row - ((if graf-valor[04] > 100 then 250 else graf-valor[04] * 2.5) / session:pixels-per-row).
        if graf-valor[05] > 0 then assign r05:row = r05:row - ((if graf-valor[05] > 100 then 250 else graf-valor[05] * 2.5) / session:pixels-per-row).
        if graf-valor[06] > 0 then assign r06:row = r06:row - ((if graf-valor[06] > 100 then 250 else graf-valor[06] * 2.5) / session:pixels-per-row).
        if graf-valor[07] > 0 then assign r07:row = r07:row - ((if graf-valor[07] > 100 then 250 else graf-valor[07] * 2.5) / session:pixels-per-row).
        if graf-valor[08] > 0 then assign r08:row = r08:row - ((if graf-valor[08] > 100 then 250 else graf-valor[08] * 2.5) / session:pixels-per-row).
        if graf-valor[09] > 0 then assign r09:row = r09:row - ((if graf-valor[09] > 100 then 250 else graf-valor[09] * 2.5) / session:pixels-per-row).
        if graf-valor[10] > 0 then assign r10:row = r10:row - ((if graf-valor[10] > 100 then 250 else graf-valor[10] * 2.5) / session:pixels-per-row).
        if graf-valor[11] > 0 then assign r11:row = r11:row - ((if graf-valor[11] > 100 then 250 else graf-valor[11] * 2.5) / session:pixels-per-row).
        if graf-valor[12] > 0 then assign r12:row = r12:row - ((if graf-valor[12] > 100 then 250 else graf-valor[12] * 2.5) / session:pixels-per-row).

        if graf-valor[01] > 0 then assign r01:height-pixels in frame f-grafico1 = if graf-valor[01] > 100 then 250 else graf-valor[01] * 2.5.
        if graf-valor[02] > 0 then assign r02:height-pixels in frame f-grafico1 = if graf-valor[02] > 100 then 250 else graf-valor[02] * 2.5.
        if graf-valor[03] > 0 then assign r03:height-pixels in frame f-grafico1 = if graf-valor[03] > 100 then 250 else graf-valor[03] * 2.5.
        if graf-valor[04] > 0 then assign r04:height-pixels in frame f-grafico1 = if graf-valor[04] > 100 then 250 else graf-valor[04] * 2.5.
        if graf-valor[05] > 0 then assign r05:height-pixels in frame f-grafico1 = if graf-valor[05] > 100 then 250 else graf-valor[05] * 2.5.
        if graf-valor[06] > 0 then assign r06:height-pixels in frame f-grafico1 = if graf-valor[06] > 100 then 250 else graf-valor[06] * 2.5.
        if graf-valor[07] > 0 then assign r07:height-pixels in frame f-grafico1 = if graf-valor[07] > 100 then 250 else graf-valor[07] * 2.5.
        if graf-valor[08] > 0 then assign r08:height-pixels in frame f-grafico1 = if graf-valor[08] > 100 then 250 else graf-valor[08] * 2.5.
        if graf-valor[09] > 0 then assign r09:height-pixels in frame f-grafico1 = if graf-valor[09] > 100 then 250 else graf-valor[09] * 2.5.
        if graf-valor[10] > 0 then assign r10:height-pixels in frame f-grafico1 = if graf-valor[10] > 100 then 250 else graf-valor[10] * 2.5.
        if graf-valor[11] > 0 then assign r11:height-pixels in frame f-grafico1 = if graf-valor[11] > 100 then 250 else graf-valor[11] * 2.5.
        if graf-valor[12] > 0 then assign r12:height-pixels in frame f-grafico1 = if graf-valor[12] > 100 then 250 else graf-valor[12] * 2.5.

        if graf-valor[01] <= 0 then assign r01:height-pixels in frame f-grafico1 = 0.5
                                           r01:row           in frame f-grafico1 = 20.
        if graf-valor[02] <= 0 then assign r02:height-pixels in frame f-grafico1 = 0.5
                                           r02:row           in frame f-grafico1 = 20.
        if graf-valor[03] <= 0 then assign r03:height-pixels in frame f-grafico1 = 0.5
                                           r03:row           in frame f-grafico1 = 20.
        if graf-valor[04] <= 0 then assign r04:height-pixels in frame f-grafico1 = 0.5
                                           r04:row           in frame f-grafico1 = 20.
        if graf-valor[05] <= 0 then assign r05:height-pixels in frame f-grafico1 = 0.5
                                           r05:row           in frame f-grafico1 = 20.
        if graf-valor[06] <= 0 then assign r06:height-pixels in frame f-grafico1 = 0.5
                                           r06:row           in frame f-grafico1 = 20.
        if graf-valor[07] <= 0 then assign r07:height-pixels in frame f-grafico1 = 0.5
                                           r07:row           in frame f-grafico1 = 20.
        if graf-valor[08] <= 0 then assign r08:height-pixels in frame f-grafico1 = 0.5
                                           r08:row           in frame f-grafico1 = 20.
        if graf-valor[09] <= 0 then assign r09:height-pixels in frame f-grafico1 = 0.5
                                           r09:row           in frame f-grafico1 = 20.
        if graf-valor[10] <= 0 then assign r10:height-pixels in frame f-grafico1 = 0.5
                                           r10:row           in frame f-grafico1 = 20.
        if graf-valor[11] <= 0 then assign r11:height-pixels in frame f-grafico1 = 0.5
                                           r11:row           in frame f-grafico1 = 20.
        if graf-valor[12] <= 0 then assign r12:height-pixels in frame f-grafico1 = 0.5
                                           r12:row           in frame f-grafico1 = 20.

        display r01
                r02
                r03
                r04
                r05
                r06
                r07
                r08
                r09
                r10
                r11
                r12
                rl01
                rl02
                rl03
                rl04
                rl05
                rl06
                rl07
                rl08
                rl09
                rl10
                rl11
                rl12
                graf-valor
                graf-texto
                with frame f-grafico1.
    end.
    else do:
        bell.
        message "A visualizacao do grafico necessita de Resolucao 800x600, fontes pequenas!"
                view-as alert-box information title "Aviso".
        leave.
    end.

    message "Pressione" kblabel("end-error") "para fechar".
    wait-for "endkey", "error" of frame f-grafico1.
end procedure.


procedure grafico-vertical2:
    def rectangle r01 size 5 by 1 graphic-edge.
    def rectangle r02 size 5 by 1 graphic-edge.
    def rectangle r03 size 5 by 1 graphic-edge.
    def rectangle r04 size 5 by 1 graphic-edge.
    def rectangle r05 size 5 by 1 graphic-edge.
    def rectangle r06 size 5 by 1 graphic-edge.
    def rectangle r07 size 5 by 1 graphic-edge.
    def rectangle r08 size 5 by 1 graphic-edge.
    def rectangle r09 size 5 by 1 graphic-edge.
    def rectangle r10 size 5 by 1 graphic-edge.
    def rectangle r11 size 5 by 1 graphic-edge.
    def rectangle r12 size 5 by 1 graphic-edge.


    def rectangle rl01 size-pixel 10 by 10 graphic-edge.
    def rectangle rl02 size-pixel 10 by 10 graphic-edge.
    def rectangle rl03 size-pixel 10 by 10 graphic-edge.
    def rectangle rl04 size-pixel 10 by 10 graphic-edge.
    def rectangle rl05 size-pixel 10 by 10 graphic-edge.
    def rectangle rl06 size-pixel 10 by 10 graphic-edge.
    def rectangle rl07 size-pixel 10 by 10 graphic-edge.
    def rectangle rl08 size-pixel 10 by 10 graphic-edge.
    def rectangle rl09 size-pixel 10 by 10 graphic-edge.
    def rectangle rl10 size-pixel 10 by 10 graphic-edge.
    def rectangle rl11 size-pixel 10 by 10 graphic-edge.
    def rectangle rl12 size-pixel 10 by 10 graphic-edge.

    define variable i as integer no-undo.

    do i = 1 to extent(graf-texto):
        assign graf-texto[i] = fill(" ", 10 - length(trim(graf-texto[i]))) +
                               trim(graf-texto[i]).
    end.

    if graf-cores[01] = 0 and
       graf-cores[02] = 0 and
       graf-cores[03] = 0 and
       graf-cores[04] = 0 and
       graf-cores[05] = 0 and
       graf-cores[06] = 0 and
       graf-cores[07] = 0 and
       graf-cores[08] = 0 and
       graf-cores[09] = 0 and
       graf-cores[10] = 0 and
       graf-cores[11] = 0 and
       graf-cores[12] = 0 then
    assign graf-cores[01] = 01
           graf-cores[02] = 02
           graf-cores[03] = 03
           graf-cores[04] = 04
           graf-cores[05] = 05
           graf-cores[06] = 06
           graf-cores[07] = 07
           graf-cores[08] = 08
           graf-cores[09] = 09
           graf-cores[10] = 10
           graf-cores[11] = 11
           graf-cores[12] = 12.

    do i = 1 to extent(graf-valor):
        if graf-valor[i] <= 0 then assign graf-cores[i] = 15.
    end.

    display
            r01 at row 13 column 06.0 bgcolor graf-cores[01] fgcolor graf-cores[01]
            r02 at row 13 column 11.2 bgcolor graf-cores[02] fgcolor graf-cores[02]
            r03 at row 13 column 16.3 bgcolor graf-cores[03] fgcolor graf-cores[03]
            r04 at row 13 column 21.4 bgcolor graf-cores[04] fgcolor graf-cores[04]
            r05 at row 13 column 26.6 bgcolor graf-cores[05] fgcolor graf-cores[05]
            r06 at row 13 column 31.7 bgcolor graf-cores[06] fgcolor graf-cores[06]
            r07 at row 13 column 36.9 bgcolor graf-cores[07] fgcolor graf-cores[07]
            r08 at row 13 column 42.0 bgcolor graf-cores[08] fgcolor graf-cores[08]
            r09 at row 13 column 47.2 bgcolor graf-cores[09] fgcolor graf-cores[09]
            r10 at row 13 column 52.3 bgcolor graf-cores[10] fgcolor graf-cores[10]
            r11 at row 13 column 57.4 bgcolor graf-cores[11] fgcolor graf-cores[11]
            r12 at row 13 column 62.5 bgcolor graf-cores[12] fgcolor graf-cores[12]
            graf-valor[01] at row 13 column 06.0 left-aligned font 2 fgcolor graf-cores[01]
            graf-valor[02] at row 13 column 11.2 left-aligned font 2 fgcolor graf-cores[02]
            graf-valor[03] at row 13 column 16.3 left-aligned font 2 fgcolor graf-cores[03]
            graf-valor[04] at row 13 column 21.4 left-aligned font 2 fgcolor graf-cores[04]
            graf-valor[05] at row 13 column 26.6 left-aligned font 2 fgcolor graf-cores[05]
            graf-valor[06] at row 13 column 31.7 left-aligned font 2 fgcolor graf-cores[06]
            graf-valor[07] at row 13 column 36.9 left-aligned font 2 fgcolor graf-cores[07]
            graf-valor[08] at row 13 column 42.0 left-aligned font 2 fgcolor graf-cores[08]
            graf-valor[09] at row 13 column 47.2 left-aligned font 2 fgcolor graf-cores[09]
            graf-valor[10] at row 13 column 52.3 left-aligned font 2 fgcolor graf-cores[10]
            graf-valor[11] at row 13 column 57.4 left-aligned font 2 fgcolor graf-cores[11]
            graf-valor[12] at row 13 column 62.5 left-aligned font 2 fgcolor graf-cores[12]
            "-" at row 12.6 column 05.3
            "-" at row 06.9 column 05.3
            "-" at row 01.2 column 05.3
            with frame f-grafico view-as dialog-box
            use-text no-underline side-labels
            no-labels width 80 keep-tab-order centered title graf-titulo.

    display
            rl01 at row 14.0 column 06.0 bgcolor graf-cores[01] fgcolor graf-cores[01]
            rl02 at row 14.5 column 06.0 bgcolor graf-cores[02] fgcolor graf-cores[02]
            rl03 at row 15.0 column 06.0 bgcolor graf-cores[03] fgcolor graf-cores[03]
            rl04 at row 15.5 column 06.0 bgcolor graf-cores[04] fgcolor graf-cores[04]
            rl05 at row 14.0 column 24.0 bgcolor graf-cores[05] fgcolor graf-cores[05]
            rl06 at row 14.5 column 24.0 bgcolor graf-cores[06] fgcolor graf-cores[06]
            rl07 at row 15.0 column 24.0 bgcolor graf-cores[07] fgcolor graf-cores[07]
            rl08 at row 15.5 column 24.0 bgcolor graf-cores[08] fgcolor graf-cores[08]
            rl09 at row 14.0 column 42.0 bgcolor graf-cores[09] fgcolor graf-cores[09]
            rl10 at row 14.5 column 42.0 bgcolor graf-cores[10] fgcolor graf-cores[10]
            rl11 at row 15.0 column 42.0 bgcolor graf-cores[11] fgcolor graf-cores[11]
            rl12 at row 15.5 column 42.0 bgcolor graf-cores[12] fgcolor graf-cores[12]
            graf-texto[01] view-as text at row 13.9 column 07.5 left-aligned font 2
            graf-texto[02] view-as text at row 14.4 column 07.5 left-aligned font 2
            graf-texto[03] view-as text at row 14.9 column 07.5 left-aligned font 2
            graf-texto[04] view-as text at row 15.4 column 07.5 left-aligned font 2
            graf-texto[05] view-as text at row 13.9 column 25.5 left-aligned font 2
            graf-texto[06] view-as text at row 14.4 column 25.5 left-aligned font 2 
            graf-texto[07] view-as text at row 14.9 column 25.5 left-aligned font 2
            graf-texto[08] view-as text at row 15.4 column 25.5 left-aligned font 2
            graf-texto[09] view-as text at row 13.9 column 43.5 left-aligned font 2
            graf-texto[10] view-as text at row 14.4 column 43.5 left-aligned font 2
            graf-texto[11] view-as text at row 14.9 column 43.5 left-aligned font 2
            graf-texto[12] view-as text at row 15.4 column 43.5 left-aligned font 2
            skip(0.5)
            with frame f-grafico view-as dialog-box
            use-text no-underline side-labels
            no-labels width 80 keep-tab-order centered title graf-titulo.

    if graf-valor[01] > 0 then assign r01:row = r01:row - ((graf-valor[01] * 3) / session:pixels-per-row).
    if graf-valor[02] > 0 then assign r02:row = r02:row - ((graf-valor[02] * 3) / session:pixels-per-row).
    if graf-valor[03] > 0 then assign r03:row = r03:row - ((graf-valor[03] * 3) / session:pixels-per-row).
    if graf-valor[04] > 0 then assign r04:row = r04:row - ((graf-valor[04] * 3) / session:pixels-per-row).
    if graf-valor[05] > 0 then assign r05:row = r05:row - ((graf-valor[05] * 3) / session:pixels-per-row).
    if graf-valor[06] > 0 then assign r06:row = r06:row - ((graf-valor[06] * 3) / session:pixels-per-row).
    if graf-valor[07] > 0 then assign r07:row = r07:row - ((graf-valor[07] * 3) / session:pixels-per-row).
    if graf-valor[08] > 0 then assign r08:row = r08:row - ((graf-valor[08] * 3) / session:pixels-per-row).
    if graf-valor[09] > 0 then assign r09:row = r09:row - ((graf-valor[09] * 3) / session:pixels-per-row).
    if graf-valor[10] > 0 then assign r10:row = r10:row - ((graf-valor[10] * 3) / session:pixels-per-row).
    if graf-valor[11] > 0 then assign r11:row = r11:row - ((graf-valor[11] * 3) / session:pixels-per-row).
    if graf-valor[12] > 0 then assign r12:row = r12:row - ((graf-valor[12] * 3) / session:pixels-per-row).

    if graf-valor[01] > 0 then assign r01:height-pixels in frame f-grafico = graf-valor[01] * 3.
    if graf-valor[02] > 0 then assign r02:height-pixels in frame f-grafico = graf-valor[02] * 3.
    if graf-valor[03] > 0 then assign r03:height-pixels in frame f-grafico = graf-valor[03] * 3.
    if graf-valor[04] > 0 then assign r04:height-pixels in frame f-grafico = graf-valor[04] * 3.
    if graf-valor[05] > 0 then assign r05:height-pixels in frame f-grafico = graf-valor[05] * 3.
    if graf-valor[06] > 0 then assign r06:height-pixels in frame f-grafico = graf-valor[06] * 3.
    if graf-valor[07] > 0 then assign r07:height-pixels in frame f-grafico = graf-valor[07] * 3.
    if graf-valor[08] > 0 then assign r08:height-pixels in frame f-grafico = graf-valor[08] * 3.
    if graf-valor[09] > 0 then assign r09:height-pixels in frame f-grafico = graf-valor[09] * 3.
    if graf-valor[10] > 0 then assign r10:height-pixels in frame f-grafico = graf-valor[10] * 3.
    if graf-valor[11] > 0 then assign r11:height-pixels in frame f-grafico = graf-valor[11] * 3.
    if graf-valor[12] > 0 then assign r12:height-pixels in frame f-grafico = graf-valor[12] * 3.


    if graf-valor[01] <= 0 then assign r01:height-pixels in frame f-grafico = 0.5
                                       r01:row           in frame f-grafico = 13.
    if graf-valor[02] <= 0 then assign r02:height-pixels in frame f-grafico = 0.5
                                       r02:row           in frame f-grafico = 13.
    if graf-valor[03] <= 0 then assign r03:height-pixels in frame f-grafico = 0.5
                                       r03:row           in frame f-grafico = 13.
    if graf-valor[04] <= 0 then assign r04:height-pixels in frame f-grafico = 0.5
                                       r04:row           in frame f-grafico = 13.
    if graf-valor[05] <= 0 then assign r05:height-pixels in frame f-grafico = 0.5
                                       r05:row           in frame f-grafico = 13.
    if graf-valor[06] <= 0 then assign r06:height-pixels in frame f-grafico = 0.5
                                       r06:row           in frame f-grafico = 13.
    if graf-valor[07] <= 0 then assign r07:height-pixels in frame f-grafico = 0.5
                                       r07:row           in frame f-grafico = 13.
    if graf-valor[08] <= 0 then assign r08:height-pixels in frame f-grafico = 0.5
                                       r08:row           in frame f-grafico = 13.
    if graf-valor[09] <= 0 then assign r09:height-pixels in frame f-grafico = 0.5
                                       r09:row           in frame f-grafico = 13.
    if graf-valor[10] <= 0 then assign r10:height-pixels in frame f-grafico = 0.5
                                       r10:row           in frame f-grafico = 13.
    if graf-valor[11] <= 0 then assign r11:height-pixels in frame f-grafico = 0.5
                                       r11:row           in frame f-grafico = 13.
    if graf-valor[12] <= 0 then assign r12:height-pixels in frame f-grafico = 0.5
                                       r12:row           in frame f-grafico = 13.


    display r01
            r02
            r03
            r04
            r05
            r06
            r07
            r08
            r09
            r10
            r11
            r12
            rl01
            rl02
            rl03
            rl04
            rl05
            rl06
            rl07
            rl08
            rl09
            rl10
            rl11
            rl12
            graf-valor
            graf-texto
            with frame f-grafico.

    message "Pressione" kblabel("end-error") "para fechar".
    wait-for "endkey", "error" of frame f-grafico.
end procedure.

/* Grafico Horizontal Caracter */
procedure grafico-horizontal:
    define variable b01 as character format "x(50)".
    define variable b02 as character format "x(50)".
    define variable b03 as character format "x(50)".
    define variable b04 as character format "x(50)".
    define variable b05 as character format "x(50)".
    define variable b06 as character format "x(50)".
    define variable b07 as character format "x(50)".
    define variable b08 as character format "x(50)".
    define variable b09 as character format "x(50)".
    define variable b10 as character format "x(50)".
    define variable b11 as character format "x(50)".
    define variable b12 as character format "x(50)".

    define variable i as integer no-undo.

    assign b01 = if graf-valor[01] > 0 then fill("#", 50) else ""
           b02 = if graf-valor[02] > 0 then fill("@", 50) else ""
           b03 = if graf-valor[03] > 0 then fill("#", 50) else ""
           b04 = if graf-valor[04] > 0 then fill("@", 50) else ""
           b05 = if graf-valor[05] > 0 then fill("#", 50) else ""
           b06 = if graf-valor[06] > 0 then fill("@", 50) else ""
           b07 = if graf-valor[07] > 0 then fill("#", 50) else ""
           b08 = if graf-valor[08] > 0 then fill("@", 50) else ""
           b09 = if graf-valor[09] > 0 then fill("#", 50) else ""
           b10 = if graf-valor[10] > 0 then fill("@", 50) else ""
           b11 = if graf-valor[11] > 0 then fill("#", 50) else ""
           b12 = if graf-valor[12] > 0 then fill("@", 50) else "".

    do i = 1 to extent(graf-texto):
        assign graf-texto[i] = fill(" ", 15 - length(trim(graf-texto[i]))) +
                               trim(graf-texto[i]).
    end.

    display graf-titulo view-as text format "x(50)" at row 2 column 17
            b01 view-as text size 50 by 1 at row 15 column 17
            b02 view-as text size 50 by 1 at row 14 column 17
            b03 view-as text size 50 by 1 at row 13 column 17
            b04 view-as text size 50 by 1 at row 12 column 17
            b05 view-as text size 50 by 1 at row 11 column 17
            b06 view-as text size 50 by 1 at row 10 column 17
            b07 view-as text size 50 by 1 at row 09 column 17
            b08 view-as text size 50 by 1 at row 08 column 17
            b09 view-as text size 50 by 1 at row 07 column 17
            b10 view-as text size 50 by 1 at row 06 column 17
            b11 view-as text size 50 by 1 at row 05 column 17
            b12 view-as text size 50 by 1 at row 04 column 17
            graf-texto[12] view-as text at row 04 column 01
            graf-texto[11] view-as text at row 05 column 01
            graf-texto[10] view-as text at row 06 column 01
            graf-texto[09] view-as text at row 07 column 01
            graf-texto[08] view-as text at row 08 column 01
            graf-texto[07] view-as text at row 09 column 01
            graf-texto[06] view-as text at row 10 column 01
            graf-texto[05] view-as text at row 11 column 01
            graf-texto[04] view-as text at row 12 column 01
            graf-texto[03] view-as text at row 13 column 01
            graf-texto[02] view-as text at row 14 column 01
            graf-texto[01] view-as text at row 15 column 01
            "'" at row 16 column 17 "0%"   at row 17 column 17 right-aligned
            "'" at row 16 column 21
            "'" at row 16 column 26
            "'" at row 16 column 31
            "'" at row 16 column 36
            "'" at row 16 column 41 "50%"  at row 17 column 41 right-aligned
            "'" at row 16 column 46
            "'" at row 16 column 51
            "'" at row 16 column 56
            "'" at row 16 column 61
            "'" at row 16 column 66 "100%" at row 17 column 66 right-aligned
            skip(1)
            with frame f-grafico view-as dialog-box
            use-text no-underline side-labels three-d color white/red
            no-labels width 80 keep-tab-order centered title "Grafico Horizontal - Caracter/FUNCOES.P".

    assign b01:width in frame f-grafico = if graf-valor[01] > 0 then graf-valor[01] / 2 else 1.00
           b02:width in frame f-grafico = if graf-valor[02] > 0 then graf-valor[02] / 2 else 1.00
           b03:width in frame f-grafico = if graf-valor[03] > 0 then graf-valor[03] / 2 else 1.00
           b04:width in frame f-grafico = if graf-valor[04] > 0 then graf-valor[04] / 2 else 1.00
           b05:width in frame f-grafico = if graf-valor[05] > 0 then graf-valor[05] / 2 else 1.00
           b06:width in frame f-grafico = if graf-valor[06] > 0 then graf-valor[06] / 2 else 1.00
           b07:width in frame f-grafico = if graf-valor[07] > 0 then graf-valor[07] / 2 else 1.00
           b08:width in frame f-grafico = if graf-valor[08] > 0 then graf-valor[08] / 2 else 1.00
           b09:width in frame f-grafico = if graf-valor[09] > 0 then graf-valor[09] / 2 else 1.00
           b10:width in frame f-grafico = if graf-valor[10] > 0 then graf-valor[10] / 2 else 1.00
           b11:width in frame f-grafico = if graf-valor[11] > 0 then graf-valor[11] / 2 else 1.00
           b12:width in frame f-grafico = if graf-valor[12] > 0 then graf-valor[12] / 2 else 1.00.

    display graf-titulo
            b01
            b02
            b03
            b04
            b05
            b06
            b07
            b08
            b09
            b10
            b11
            b12
            graf-texto[01]
            with frame f-grafico.
    pause message "Pressione ESPACO para fechar".
end procedure.

/* Editor para visualizacao de impressao em tela */
procedure editor:
    define input parameter arquivo as character format "x(256)" label "Caminho".

    define variable i as integer no-undo.

    define variable editor as character view-as editor no-word-wrap size 78 by 19
        scrollbar-vertical scrollbar-horizontal large label "Editor" no-undo.


    define button b-abrir  label "&Abrir"       size 12 by 1 auto-go.
    define button b-salvar label "&Salvar"      size 12 by 1 auto-go.
    define button b-sair   label "Sai&r"        size 12 by 1 auto-go.
    define button b-fonte  label "&Fonte"       size 12 by 1 auto-go.
    define button b-trava  label "Des&protege"  size 12 by 1 auto-go.
    define button b-print  label "&Imprimir"    size 12 by 1 auto-go.

    define var l-saida as logical   format "Sim/Nao" initial no.
    define var c       as character.
    define var texto   as character.
    define var l       as logical.
    define var d       as decimal.

    define var linha   as integer   format "zzzz9" label "&Linha".
    define var coluna  as integer   format "zzzz9" label "&Coluna".

    define var procura as character format "x(256)" label "&Procura".
    define var troca   as character format "x(256)" label "&Troca".

    define var lado    as character format "x(8)" label "Lado" initial "Ambos".

    display editor   at row 2.2 column 1    font 2
            help "Edicao do texto"
            b-abrir  at row 1.1 column 1.1  font 0
            help "Abrir arquivo"
            b-salvar at row 1.1 column 13.3 font 0
            help "Salvar arquivo"
            b-fonte  at row 1.1 column 25.4 font 0
            help "Trocar a fonte do editor"
            b-print  at row 1.1 column 37.6 font 0
            help "Imprimir o texto atual"
            b-trava  at row 1.1 column 49.7 font 0
            help "Trava/Destrava o texto atual"
            b-sair   at row 1.1 column 66.0 font 0
            help "Finaliza edicao"
            with view-as dialog-box
            width 80 no-labels no-attr-space
            no-underline font 0 centered three-d
            top-only keep-tab-order use-text no-hide
            frame f-editor title "EDITOR".

    assign editor:modified     in frame f-editor = no
           editor:read-only    in frame f-editor = yes.

    /* Abertura do Arquivo */
    if search(arquivo) <> ? and
         trim(arquivo) <> "" then
        assign l = editor:read-file(search(arquivo))
               l = editor:move-to-top()
               current-window:title = search(arquivo).
    else
        assign current-window:title = "Sem titulo".

    /* Triggers */
    on choose of b-sair in frame f-editor or
       window-close of current-window     or
       "alt-f4" of editor in frame f-editor do:

        if editor:modified = yes then do:
            bell.
            message "Salva" search(arquivo)
                    view-as alert-box information
                    buttons yes-no-cancel update l.
            if l = ? then leave.
            else if l = yes then do:
                assign frame f-editor editor.
                assign l = editor:save-file(search(arquivo)).
            end.
        end.
        assign l-saida = yes.
    end.

    on choose of b-trava in frame f-editor do:
        if editor:read-only = yes then
            assign editor:read-only = no
                   b-trava:label = "&Protege".
        else
            assign editor:read-only = yes
                   b-trava:label = "Des&protege".
    end.

    on choose of b-abrir in frame f-editor do:
        if editor:modified = yes then do:
            bell.
            message "Salva" search(arquivo)
                    view-as alert-box information
                    buttons yes-no-cancel update l.
            if l = ? then leave.
            else if l = yes then do:
                assign frame f-editor editor.
                assign l = editor:save-file(search(arquivo)).
            end.
        end.

        &if "{&window-system}" = "ms-windows" &then
            system-dialog get-file arquivo
            update l title "Abrir Arquivo"
            filters "Listagem (*.lst)" "*.lst",
                    "Texto (*.txt)"    "*.txt",
                    "Todos (*.*)"      "*.*".
        &else
            update arquivo view-as fill-in size 40 by 1
                   with frame f-abrir-arquivo 
                   no-underline title "Abrir Arquivo"
                   overlay view-as dialog-box.
            if keyfunction(lastkey) = "end-error" then
                 assign l = no.
            else assign l = yes.
        &endif

        if l = no then leave.
        if search(arquivo) = ? then do:
            bell.
            message "Arquivo nao encontrado"
                    view-as alert-box error.
            leave.
        end.
        
        assign l = editor:read-file(search(arquivo)).
        assign editor:modified = no
               l = editor:move-to-top().
    end.

    on choose of b-salvar in frame f-editor do:
        &if "{&window-system}" = "ms-windows" &then
            system-dialog get-file arquivo
            update l title "Salvar Arquivo"
            filters "Listagem(*.lst)" "*.lst",
                    "Texto(*.txt)"    "*.txt",
                    "Todos(*.*)  "    "*.*"
            must-exist.
        &else
            update arquivo view-as fill-in size 40 by 1
                   with frame f-salvar-arquivo 
                   no-underline title "Salvar Arquivo"
                   overlay view-as dialog-box.
            if keyfunction(lastkey) = "end-error" then
                 assign l = no.
            else assign l = yes.
        &endif
    
        if l = no then leave.

        assign frame f-editor editor.
        assign l = editor:save-file(search(arquivo))
               editor:modified = no.
    end.

    on choose of b-fonte in frame f-editor do:
        if session:display-type <> "gui":u then do:
            message "Esta opcao so e valida para ambientes graficos"
                    view-as alert-box information.
            leave.
        end.
        system-dialog font i
        fixed-only update l.

        if l = yes then assign editor:font = i.
    end.

    on choose of b-print in frame f-editor do:
        &if "{&window-system}" = "ms-windows" &then
            system-dialog printer-setup
            num-copies 1 update l.

            if l = no then leave.
            assign frame f-editor editor.
            output to printer.
            put unformatted editor.
            output close.
        &else
            bell.
            message "Opcao nao disponivel somente para ambiente MS-Windows"
                    view-as alert-box information title "Aviso".
        &endif
    end.

    on "ctrl-l" of editor in frame f-editor do:
        assign frame f-editor editor.
        display "Linha:"  to 20 string(editor:cursor-line in frame f-editor, ">>>,>>9")
                "Coluna:" to 20 string(editor:cursor-char in frame f-editor, ">>>,>>9")
                "Total de Linhas:"     to 20 string(editor:num-lines in frame f-editor, ">>>,>>9")
                "Total de Caracteres:" to 20 string(length(editor), ">>>,>>9")
                with frame f-posicoes view-as dialog-box
                title "Posicao" no-labels no-underline
                use-text 
                overlay.
        pause message "Pressione ESPACO para fechar".
    end.

    on "ctrl-j" of editor in frame f-editor do:
        update linha
               coluna
               with frame f-procura no-underline
               title "Procura" overlay 
               view-as dialog-box centered.
        if keyfunction(lastkey) = "end-error" then leave.
        if linha  > 0 then assign editor:cursor-line = linha.
        if coluna > 0 then assign editor:cursor-char = coluna.
    end.


    on "ctrl-r" of editor in frame f-editor do:
        update procura view-as fill-in size 40 by 1 colon 8
               validate(input frame f-procura procura <> "", "Texto de procura invalido")
               troca   view-as fill-in size 40 by 1 colon 8
               l       label "Diferencia Maiuscula/Minuscula"
                       format "Sim/Nao" colon 45
               with frame f-procura no-underline
               title "Procura" overlay 
               view-as dialog-box side-labels centered.
        if keyfunction(lastkey) = "end-error" then leave.

        if procura = "" then leave.
        assign frame f-editor editor.
        assign editor = replace(input frame f-editor editor, procura, troca).
        display editor with frame f-editor.
    end.

    on "ctrl-f3" of editor in frame f-editor do:
        assign frame f-editor editor
               linha  = editor:cursor-line
               coluna = editor:cursor-char
               editor = caps(editor).

        display editor with frame f-editor.
        assign editor:cursor-line = linha
               editor:cursor-char = coluna.
    end.

    on "alt-f3" of editor in frame f-editor do:
        assign frame f-editor editor
               linha  = editor:cursor-line
               coluna = editor:cursor-char
               editor = lc(editor).

        display editor with frame f-editor.
        assign editor:cursor-line = linha
               editor:cursor-char = coluna.
    end.

    on "ctrl-s" of editor in frame f-editor do:
        update lado
               validate(lookup(lado, "Direita,Esquerda,Ambos") > 0, "Parametro invalido")
               help "Pressione a letra inicial da posicao (Direita, Esquerda, Ambos)"
               with frame f-lado view-as dialog-box side-labels
               no-underline centered overlay title "Remover espacos" editing:
               readkey.
               if      keyfunction(lastkey) = "d" then display "Direita"  @ lado with frame f-lado.
               else if keyfunction(lastkey) = "e" then display "Esquerda" @ lado with frame f-lado.
               else if keyfunction(lastkey) = "a" then display "Ambos"    @ lado with frame f-lado.
               else if lookup(keyfunction(lastkey), "return,end-error") > 0 then apply lastkey.
               end.

        if keyfunction(lastkey) = "end-error" or keyfunction(lastkey) = "endkey" then leave.

        assign linha  = editor:cursor-line
               coluna = editor:cursor-char.
        assign frame f-editor editor.

        if      lado = "Direita"  then assign editor = right-trim(input frame f-editor editor).
        else if lado = "Esquerda" then assign editor = left-trim(input frame f-editor editor).
        else if lado = "Ambos"    then assign editor = trim(input frame f-editor editor).

        display editor with frame f-editor.
        assign editor:cursor-line = linha
               editor:cursor-char = coluna.
    end.

    on "ctrl-f" of editor in frame f-editor do:
        assign i = 255.
        assign color-table:num-entries = 255.
        if not color-table:get-dynamic(i) and
           not color-table:set-dynamic(i, true) then
           message "mal" view-as alert-box.
        system-dialog color i update l.
    end.

    on "ctrl-t" of editor in frame f-editor do:
        assign frame f-editor editor.
    end.

    on "help" anywhere do:
        &if "{&window-system}" = "ms-windows" &then
            display kblabel("ctrl-r")   to 15 "substitui texto"
                    kblabel("ctrl-f3")  to 15 "texto em maiusculo"
                    kblabel("ctrl-f3")  to 15 "texto em minusculo"
                    kblabel("ctrl-f")   to 15 "troca a cor do texto"
                    kblabel("ctrl-j")   to 15 "posiciona na linha/coluna do texto"
                    kblabel("ctrl-l")   to 15 "mostra linha, coluna e caracteres"
                    kblabel("ctrl-c")   to 15 "copia o texto selecionado"
                    kblabel("ctrl-v")   to 15 "cola o texto copiado"
                    kblabel("ctrl-x")   to 15 "recorta o texto selecionado"
                    kblabel("alt-f4")   to 15 "finaliza o editor"
                    kblabel("ctrl-tab") to 15 "aplica tabulacao na posicao"
                    kblabel("ctrl-s")   to 15 "remove espacos a direita e/ou esquerda"
                    with frame f-ajuda-gui view-as dialog-box
                    title "Teclas de Funcao do Editor" no-hide
                    no-underline use-text overlay.
        &else
            display kblabel("ctrl-r")   to 15 "substitui texto"
                    kblabel("ctrl-f3")  to 15 "texto em maiusculo"
                    kblabel("ctrl-f3")  to 15 "texto em minusculo"
                    kblabel("ctrl-f")   to 15 "troca a cor do texto"
                    kblabel("ctrl-j")   to 15 "posiciona na linha/coluna do texto"
                    kblabel("ctrl-l")   to 15 "mostra linha, coluna e caracteres"
                    kblabel("ctrl-c")   to 15 "copia o texto selecionado"
                    kblabel("ctrl-v")   to 15 "cola o texto copiado"
                    kblabel("ctrl-x")   to 15 "recorta o texto selecionado"
                    kblabel("alt-f4")   to 15 "finaliza o editor"
                    kblabel("delete-line") to 15 "apaga linha atual"
                    kblabel("ctrl-s")   to 15 "remove espacos a direita e/ou esquerda"                
                    with frame f-ajuda-tty view-as dialog-box
                    title "Teclas de Funcao do Editor" no-hide
                    no-underline use-text overlay.
        &endif
        pause message "Pressione ESPACO para fechar".
    end.

    bloco:
    repeat on error  undo, retry bloco
           on endkey undo, retry bloco:

        prompt-for
               editor
               b-abrir
               b-salvar
               b-fonte
               b-print
               b-trava
               b-sair with frame f-editor.
        if l-saida = yes then leave bloco.
    end.
    hide frame f-editor no-pause.
end procedure.

procedure direita-pcl:
    define input parameter pY     as integer.
    define input parameter pX     as integer.
    define input parameter texto  as character.
    define input parameter espaco as integer.
    define variable i-contador         as integer.

    bloco_contador:
    do i-contador = length(texto) to 1 by -1:
        if trim(substring(texto, i-contador, 1)) = "" then leave bloco_contador.

        if lookup(trim(substring(texto, i-contador, 1)), "~,,.") = 0 then do:
            put unformatted "~033*p" pY "y" pX "X" substring(texto, i-contador, 1) skip.
            assign pX = pX - espaco.
        end.
        else do:
            put unformatted "~033*p" pY "y" (pX + 6) "X" substring(texto, i-contador, 1) skip.
            assign pX = pX - espaco + 6.
        end.
    end.
end procedure.

procedure uf-estabelecimento:
    define input  parameter cod-estabel as character format "xxx".
    define output parameter estado      as character format "!!".

    if      cod-estabel = "001" then assign estado = "AL".
    else if cod-estabel = "002" then assign estado = "AM".
    else if cod-estabel = "003" then assign estado = "BA".
    else if cod-estabel = "004" then assign estado = "CE".
    else if cod-estabel = "005" then assign estado = "DF".
    else if cod-estabel = "006" then assign estado = "ES".
    else if cod-estabel = "007" then assign estado = "GO".
    else if cod-estabel = "008" then assign estado = "MA".
    else if cod-estabel = "009" then assign estado = "MG".
    else if cod-estabel = "010" then assign estado = "MS".
    else if cod-estabel = "011" then assign estado = "MT".
    else if cod-estabel = "012" then assign estado = "PA".
    else if cod-estabel = "013" then assign estado = "PB".
    else if cod-estabel = "014" then assign estado = "PE".
    else if cod-estabel = "015" then assign estado = "PI".
    else if cod-estabel = "016" then assign estado = "PR".
    else if cod-estabel = "017" then assign estado = "RJ".
    else if cod-estabel = "018" then assign estado = "RN".
    else if cod-estabel = "019" then assign estado = "RO".
    else if cod-estabel = "020" then assign estado = "RS".
    else if cod-estabel = "021" then assign estado = "SC".
    else if cod-estabel = "022" then assign estado = "SE".
    else if cod-estabel = "023" then assign estado = "SP".
end procedure.

procedure cod-estabelecimento:
    define input  parameter estado      as character format "!!".
    define output parameter cod-estabel as character format "xxx".

    if      estado = "AL" then assign cod-estabel = "001".
    else if estado = "AM" then assign cod-estabel = "002".
    else if estado = "BA" then assign cod-estabel = "003".
    else if estado = "CE" then assign cod-estabel = "004".
    else if estado = "DF" then assign cod-estabel = "005".
    else if estado = "ES" then assign cod-estabel = "006".
    else if estado = "GO" then assign cod-estabel = "007".
    else if estado = "MA" then assign cod-estabel = "008".
    else if estado = "MG" then assign cod-estabel = "009".
    else if estado = "MS" then assign cod-estabel = "010".
    else if estado = "MT" then assign cod-estabel = "011".
    else if estado = "PA" then assign cod-estabel = "012".
    else if estado = "PB" then assign cod-estabel = "013".
    else if estado = "PE" then assign cod-estabel = "014".
    else if estado = "PI" then assign cod-estabel = "015".
    else if estado = "PR" then assign cod-estabel = "016".
    else if estado = "RJ" then assign cod-estabel = "017".
    else if estado = "RN" then assign cod-estabel = "018".
    else if estado = "RO" then assign cod-estabel = "019".
    else if estado = "RS" then assign cod-estabel = "020".
    else if estado = "SC" then assign cod-estabel = "021".
    else if estado = "SE" then assign cod-estabel = "022".
    else if estado = "SP" then assign cod-estabel = "023".
end procedure.

/*
    define variable tabela as character no-undo initial "or-conta-contab".
    define variable i      as integer   no-undo.

    output to "clipboard" unbuffered.
    for each _file where
             _file._file-name = tabela:

        put unformatted "assign".
        for each _field of _file:
            if _field._extent = 0 then
                put unformatted
                    "b-" + _file._file-name + "." + _field._field-name at 8
                    "= " to 42
                    _file._file-name + "." + _field._field-name
                    skip.
            else do:
                do i = 1 to _field._extent:
                    put unformatted
                        "b-" + _file._file-name + "." + _field._field-name + "[" + string(i, "99") + "]" at 8
                        "= " to 42
                        _file._file-name + "." + _field._field-name + "[" + string(i, "99") + "]"
                        skip.
                end.
            end.
        end.
        put unformatted "." to 8.
    end.
    output close.
*/

/* HELP */
/*

form header
     fill("-", 132) format "x(132)" skip
     empresa.nome
     "Arquivo para Credito de Funcionarios"
     "Folha:" at 122 page-number format ">>>9" to 132
     fill("-", 110) format "x(110)"
     today format "99/99/9999" at 112 "-" format "x" to 123
     string(time, "hh:mm:ss") to 132
     with frame f-cabecalho page-top overlay width 135.

form header
     fill("-", 74) format "x(74)" at 01
     "Desenvolvimento CASSI - Programa: CSP018 Versao: I.00.000" to 132
     with frame f-rodape page-bottom overlay width 135.


RUN aderb/_printrb.p
              ("m:\ste\magnus\temporca.prl",
               "exec-orca",
               "cassi.db",
               "O",
               "",
               "",
               "P", (P-Impressora, D-Display)
               "",
               "" ,
               "",
               numcopias,
               1,
               9999,
               no,
               "",
               yes,
               yes,
               no,
               /* Parametros */
               "mes = " + w-mes[v-mes] + "~nano = " + substring(v-periodo,3,4) + 
               "~nunidade = " + v-nome-unidade + "~nmes-ant = " + w-mes[v-mes-ant].

define variable i as integer.
output to printer.

put unformatted
    "~033E"
    "~033(s0p19h0s0b4099T".

repeat i = 0 to 3300 by 20:
    put unformatted
        "~033*p" i format "9999" "y" "0X" i format "9999".
end.
*/

/* fim do programa */
