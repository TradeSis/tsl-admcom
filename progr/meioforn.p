{admcab.i}.

def var vdataini as date label "Dt.Inicial".
def var vdatafim as date label "Dt.Final".
def var varqsai as char.

update
    vdataini
    vdatafim
    with frame f-data
        centered 1 down side-labels title "Datas".

varqsai = "l:\work\fornecedores." + string(time).

output to value(varqsai).

for each lancxa where lancxa.datlan >= vdataini
                  and lancxa.datlan <= vdatafim
                  and lancxa.lancod = 100
                no-lock :
    put 
        string(lancxa.lancod) format "x(28)" 
        string(lancxa.forcod) format "x(14)" 
        day(lancxa.datlan) format "99"
        month(lancxa.datlan) format  "99"
        year(lancxa.datlan) format "9999"
        lancxa.comhis format "x(50)"  
        (lancxa.vallan * 100) format "99999999999999999"
        lancxa.lantip format "x"
        "DUP"
        lancxa.titnum format "x(12)"
        (lancxa.vallan * 100) format "99999999999999999"
        day(lancxa.datlan) format "99"
        month(lancxa.datlan) format  "99"
        year(lancxa.datlan) format "9999"
        day(lancxa.datlan) format "99"
        month(lancxa.datlan) format  "99"
        year(lancxa.datlan) format "9999"
        "000000000000"
        skip.
end.        
output close.
    