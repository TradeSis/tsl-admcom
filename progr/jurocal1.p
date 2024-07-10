{admcab.i}
def input parameter p-rec as recid.
def output parameter p-juro as dec.
find titulo where recid(titulo) = p-rec no-lock no-error.
if not avail titulo then return.

    def var ljuros as log.
    def var vnumdia as int.
    def var vtitdtpag as date.
    def var vtitdtven as date.
    def var vtitvlcob like titulo.titvlcob.
    def var vtitvlpag like titulo.titvlpag.
    def var vtitjuro  like titulo.titjuro.
    def var vv as int.
    assign
        ljuros = no
        vnumdia = 0
        vtitdtpag = titulo.titdtpag
        vtitdtven = titulo.titdtven
        vtitvlcob = titulo.titvlcob
        vtitvlpag = titulo.titvlpag    .
    if vtitdtpag > vtitdtven
    then do:
        ljuros = yes.
        if vtitdtpag - vtitdtven = 3
        then do:
            find dtextra where exdata = vtitdtpag - 3 no-error.
            if weekday(vtitdtpag - 3) = 1 or avail dtextra
            then do:
                find dtextra where exdata = vtitdtpag - 1 no-error.
                if weekday(vtitdtpag - 1) = 1 or avail dtextra
                then ljuros = no.
            end.
        end.
        if vtitdtpag - vtitdtven = 2
        then do:
            find dtextra where exdata = vtitdtpag - 2 no-error.
            if weekday(vtitdtpag - 2) = 1 or avail dtextra
            then do:
                find dtextra where exdata = vtitdtpag - 1 no-error.
                if weekday(vtitdtpag - 1) = 1 or avail dtextra
                then ljuros = no.
            end.
        end.
        else do:
            if vtitdtpag - vtitdtven = 1
            then do:
                find dtextra where exdata = vtitdtpag - 1 no-error.
                if weekday(vtitdtpag - 1) = 1 or avail dtextra
                then ljuros = no.
            end.
        end.
        vnumdia = if not ljuros
                  then 0
                  else vtitdtpag - vtitdtven.
        find tabjur where tabjur.nrdias = vnumdia no-lock no-error.
        if avail tabjur
        then
            assign 
                vtitvlpag = vtitvlcob * tabjur.fator
                vtitjuro  = vtitvlpag - vtitvlcob.
        if ljuros
        then do: 
            vv = ( (int(vtitvlpag) -  vtitvlpag) )  - 
                    round(( (int(vtitvlpag) -  (vtitvlpag)) ),1).
            if vv < 0  
            then vv = 0.10 - (vv * -1).
            vtitvlpag = vtitvlpag + vv.
            vtitjuro  =  vtitvlpag - vtitvlcob.
        end. 
    end.

p-juro = vtitjuro.
