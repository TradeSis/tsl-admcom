if {1} = 0 or vnumero = ?
then do:
     bell.
     message color red/with
            "Numero da Nota Fiscal nao pode ser" vnumero
            view-as alert-box title " Mensagem " .
    undo,retry.
end.
