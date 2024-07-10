{admcab.i}. 

def var vdataini as date label "Dt.Inicial".
def var vdatafim as date label "Dt.Final".
def var varqsai as char.
def var vetbcod like estab.etbcod.

def stream stela.
def var i as date.

form
    vetbcod
    estab.etbnom no-label
    vdataini     label "Periodo"
    vdatafim     no-label 
    with frame f-data 
        centered 1 down side-labels title "Datas".

update
    vetbcod 
    vdataini
    vdatafim
    with frame f-data.

find first estab where estab.etbcod = vetbcod no-lock no-error.
disp estab.etbnom with frame f-data.

varqsai = "l:\work\clientes." + string(estab.etbcod).

output stream stela to terminal.

output to value(varqsai).

do i = vdataini to vdatafim : 

for each titulo where titulo.titnat = no
                  and titulo.titdtpag = i
                  and titulo.etbcod = estab.etbcod
                  and titulo.modcod = "CRE"
                  and titulo.empcod = 19
                  use-index titdtpag
                no-lock  :

    find first contrato where contrato.contnum = int(titulo.titnum)
                        no-lock no-error.
    if not avail contrato then next.

    find first contnf where contnf.etbcod = contrato.etbcod
                        and contnf.contnum = contrato.contnum
                        use-index codigo
                      no-lock no-error.
    if not avail contnf then next.
               
    find first plani where plani.etbcod = contrato.etbcod
                  and plani.placod = contnf.placod
                  use-index plani
                no-lock no-error.

    if avail plani
    then do :
        if plani.notped <> "C" 
        then next.
    end.
    else next.
    
    disp stream stela "Titulo" titulo.clifor    titulo.titdtemi
        with 1 down  centered row 10 no-labels overlay.
         pause 0.
    
    put "102" format "x(28)"
        string(titulo.clifor) format "x(14)" 
        day(titulo.titdtpag) format "99"
        month(titulo.titdtpag) format  "99"
        year(titulo.titdtpag) format "9999"
        " " format "x(50)"  
        (titulo.titvlpag * 100) format "99999999999999999"
        "RCRE"
        titulo.titnum format "x(12)"
        (titulo.titvlcob * 100) format "99999999999999999"
        day(titulo.titdtemi) format "99"
        month(titulo.titdtemi) format  "99"
        year(titulo.titdtemi) format "9999"
        day(titulo.titdtven) format "99"
        month(titulo.titdtven) format  "99"
        year(titulo.titdtven) format "9999"
        "000000000000"
        skip.
end.
end.

    for each estab where estab.etbcod = vetbcod
                   no-lock :
        for each plani where plani.pladat >= vdataini
                         and plani.pladat <= vdatafim
                         and plani.notped = "C"
                         and plani.desti = 1
                         and plani.movtdc = 5 
                         and plani.etbcod = estab.etbcod
                         use-index plasai
                    no-lock :

            disp stream stela "V.Vista " plani.desti   plani.pladat
                    with 1 down  centered row 10 no-labels overlay.
                pause 0.

            put "102" format "x(28)"
                string(plani.desti) format "x(14)" 
                day(plani.pladat) format "99"
                month(plani.pladat) format  "99"
                year(plani.pladat) format "9999"
                " " format "x(50)"  
                (plani.platot * 100) format "99999999999999999"
                "RCRE"
                string(plani.numero) format "x(12)"
                (plani.platot * 100) format "99999999999999999"
                day(plani.pladat) format "99"
                month(plani.pladat) format  "99"
                year(plani.pladat) format "9999"
                day(plani.pladat) format "99"
                month(plani.pladat) format  "99"
                year(plani.pladat) format "9999"
                "000000000000"
            skip.
        end.    
    end.               
output close.
    