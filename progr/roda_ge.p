def var par-parametro as char.

propath = propath + "/admcom/progr/".

par-parametro = SESSION:PARAMETER.

def var par-dtini as date.
def var par-dtfim as date.

def var temp-arquivo as char.


par-dtini = date(entry(1,par-parametro,",")).
par-dtfim = date(entry(2,par-parametro,",")).

if par-dtini = ?
then par-dtini = today.
if par-dtfim = ?
then par-dtfim = today.

temp-arquivo = "../tmp/GE/GE_" + string(year (today),"9999") +
                                 string(month(today),"99"  ) +
                                 string(day  (today),"99"  ) + "_" +
                                 string(par-dtini,"99999999") + "_" +
                                 string(par-dtfim,"99999999") .
output to /admcom/lebesintel/GE.log append.
export par-parametro par-dtini par-dtfim temp-arquivo .
output close.

def var par-arquivo as char.
par-arquivo = "/admcom/lebesintel/bi_ocorrenciasdiarias.csv".


message par-dtini par-dtfim.


pause 0.


def var v as int.
do v = 9001 to 9020.    
    if search("/admcom/progr/ge" + string(v) + ".p") <> ?
    then do.
        message "Run no" search("/admcom/progr/ge" + string(v) + ".p")
                    par-dtini par-dtfim temp-arquivo
                    .
        pause 3 no-message.
        run value(("/admcom/progr/ge" + string(v) + ".p"))
                        (input temp-arquivo,
                         input par-dtini,
                         input par-dtfim ) 
                            .
    end.
end.

unix silent value("cp " + temp-arquivo + " " + par-arquivo).

