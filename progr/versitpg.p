{admcab.i}

/*versitpg.p*/

def var fl1 as int label "Filial:".
def var matr as int label "Matricula:".
def var tp as char label "Situacao:".
def var titdtini as date format "99/99/9999" label "Dt.Inicial".
def var titdtfin as date format "99/99/9999" label "Dt.Final".
def var total like titluc.titvlcob label "Total".

tp = "PAG".
total = 0.

update fl1 matr tp titdtini titdtfin.

if fl1 = 0
then do:
    message "Informe a filial." view-as alert-box.
    return.
end.                                                                  
                                                          
for each titluc where etbcod = fl1
                and vencod = matr
                and titdtven >= titdtini
                and titdtven <= titdtfin 
                and titsit = tp no-lock.

total = total + titvlcob.

disp clifor titsit titvlcob titdtven titdtpag total.

end.
pause.
            
