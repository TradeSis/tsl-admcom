/* 30.09.19 - tem que vir PONTO DECIMAL */
def var vlinha as char.

def var varquivo  as char format "x(60)".
varquivo = "/admcom/tmp/tabelaprecos.csv".

message "O arquivo deve ter formatacao de PONTO na casa DECIMAL".
update
    varquivo label "Arquivo CSV"
        with frame f1
            width 80 row 3 side-labels title "COM PONTO DECIMAL".

if search(varquivo) = ?
then do:
    message "Arquivo Nao Localizado no Servidor Admcom".
    pause.
    undo.
end.    
def temp-table tt-csv no-undo like abascusto.

pause 1 before-hide.

input from value(varquivo). 
repeat transaction.
    create tt-csv.
    import delimiter ";"
        tt-csv.
    
    disp tt-csv.


    find abascusto where abascusto.procod = tt-csv.procod exclusive no-error.
    if not avail abascusto
    then do:
        create abascusto.
        abascusto.procod = tt-csv.procod.
    end.    
    abascusto.custocompra   = tt-csv.custocompra   . /* planilha Original TEM que vir com PONTO na casa decimal */
    abascusto.ipiperccompra = tt-csv.ipiperccompra  .
    
    delete tt-csv.
    
end.
input close.
do on endkey undo, retry.
    message "Arquivo " varquivo "processado.".
    pause.
end.    


