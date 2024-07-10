def temp-table tt-texto
    field linha as char format "x(96)".

def var vtamlin as int.

vtamlin = 56.

function centraliza returns character
    (input par-texto as char,
     input par-tamln as int).
         
    def var vtam as int.

    par-texto = trim(par-texto).
    vtam = (par-tamln - length(par-texto)) / 2.
    if vtam > 0
    then return fill(" ", vtam) + par-texto.

end function.


function troca returns character
    (input par-de   as char,
     input par-para as char,
     input par-tam  as int).

    def var vformat as char.

    if par-para = ?
    then par-para = "".

    if par-tam = 0
    then tt-texto.linha = replace(tt-texto.linha, par-de, par-para).
    else do.
        vformat = "x(" + string(par-tam) + ")".
        tt-texto.linha = replace(tt-texto.linha,
                                 string(par-de, vformat),
                                 string(par-para, vformat)).
    end.

end function.


procedure imprime-texto.

def var vct       as int.
def var vPos      as int.
def var vPalavra  as char.
def var vPosUlt   as int.
def var vLetra    as char.
def var mTexto    as char extent 70.
def var vLin      as int.
def var vTextoIni as char.
def var vnegrito  as log.
def var vnegritooff as char.

input from /admcom/progr/loj/EpsonNegritoOff.
repeat.
    import vnegritooff.
end.
input close.

for each tt-texto.

    if tt-texto.linha begins "<C>"
    then do.
        put unformatted Centraliza(substr(tt-texto.linha, 4), vtamlin) skip.
        next.
    end.

    else if tt-texto.linha begins "<L>"
    then do.
        put unformatted fill("_", vtamlin) skip.
        next.
    end.

    else if tt-texto.linha begins "<G>"
    then do.
        put unformatted chr(29) + "V" + chr(66)     /* corta */.
        next.
    end.

    else if tt-texto.linha = "<N>" and
            length(tt-texto.linha) = 3
    then do.
        vnegrito = not vnegrito.
        if vnegrito
        then put unformatted chr(27) + "E" + chr(1).
        else put unformatted vnegritooff + " ".
        next.
    end.

    else if tt-texto.linha begins "<P>"
    then do.
        put " " skip.
        next.
    end.

    assign
        vtextoini = tt-texto.linha + " "
        vLin      = 1
        vPalavra  = ""
        mTexto    = ""
        vPos      = 1
        vPosUlt   = 1.
    repeat.
        if vPos > Length(vTextoIni)
        then leave.

        vLetra = substr(vTextoIni, vPos, 1).
        vPalavra = vPalavra + vLetra.
        vPos = vPos + 1.

        if vLetra = " " or
           vletra = ">"
        then do.
            if vPalavra = "<N>"
            then do.
                vnegrito = not vnegrito.
                if vnegrito
                then vpalavra = chr(27) + "E" + chr(1).
                else vpalavra = vnegritooff + " ".
            end.

            else if length(mTexto[vLin]) + length(trim(vpalavra)) > vtamlin
            then do.
                if length(vpalavra) > vtamlin
                then do. /* palavra maior que a linha */
                    vpalavra = substr(vpalavra, 1,
                                      vtamLin - length(mTexto[vLin])).
                    vPos = vPosUlt + length(vpalavra).
                    mTexto[vLin] = mTexto[vLin] + vPalavra.
                    vPalavra = "".
                end.
                vLin = vLin + 1.
            end.

            mTexto[vLin] = mTexto[vLin] + vPalavra.
            vPalavra = "".
            vPosUlt  = vPos.
        end.
    end.

    /* Fazer o alinhento "justificado" */
    do vPos = 1 to vLin - 1.
        mTexto[vPos] = trim(mTexto[vPos]).

        /* faz leitura do fim p/o inicio da linha*/
        vPosUlt = length(mTexto[vPos]).
        vct = 0.
        repeat.
            vct = vct + 1.
            if length(mTexto[vPos]) >= vtamlin or
               vct > 3 /* seguranca para nao ficar preso no repeat */
            then leave.

            if substr(mTexto[vPos], vPosUlt, 1) = " " /* acrescenta um espaco */
            then mTexto[vPos] = substr(mTexto[vPos], 1, vPosUlt) + 
                               substr(mTexto[vPos], vPosUlt).
       
            vPosUlt = vPosUlt - 1.
            if vPosUlt = 0
            then vPosUlt = length(mTexto[vPos]).
        end.
    end.

    do vPos = 1 to vLin.
       put unformatted right-trim(mTexto[vPos]) skip.
    end.
end.

end procedure.


procedure termo.

    def input parameter par-seguro as char.
    def input parameter par-local  as char.

    empty temp-table tt-texto.
    input from /admcom/progr/loj/qbe-termo no-echo.
    repeat transaction.
        create tt-texto.
        import unformatted tt-texto.

        troca("&nome", clien.clinom, 0).
        troca("&cpf",  clien.ciccgc, 0).
        troca("&Seguro", par-seguro, 0).
        troca("&certificado", vndseguro.certifi, 0).
        troca("&local",par-local, 0).
    end.
    input close.

    run imprime-texto.

end procedure.

