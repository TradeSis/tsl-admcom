{admcab.i  }

def var c-arquivo as char format "x(55)" no-undo.
def var d-dtini as date format "99/99/9999" no-undo.
def var d-dtfim as date format "99/99/9999" no-undo.

assign c-arquivo = "/admcom/import/ajustes/ajustes-control.csv".

assign d-dtini = date(month(today),1,year(today)).
assign d-dtfim = today.

update c-arquivo label "Paste e arquivo"
           d-dtini label "Data inicial"
           d-dtfim label "Data final"
with frame f1 side-label width 80 centered title " Informe os dados ".

def var vmovtnom as char.

message "Gerando arquivo...".

output to value(c-arquivo).                                   

        put "Emitente ; Destinatario ; Produto ; NomeProduto ; Qtd ; valorUnt ; DataEmissaoNota ; TipoMovim ; Depto; TipoAjuste ; Nota ; Serie ;" skip.                             
        for each plani where (movtdc = 7 or movtdc = 8) and 
                                                  pladat >= d-dtini and    
                                                  pladat <= d-dtfim no-lock.                                                  
                vmovtnom = plani.notobs[2].
                if vmovtnom = ""
                then do:
                    if plani.movtdc = 7
                    then vmovtnom = "BAL.AJUS.ACR".
                    else if plani.movtdc = 8
                        then vmovtnom = "BAL.AJUS.DEC".
                end.

                for each movim where plani.etbcod = movim.etbcod and                            
                                                         plani.movtdc = movim.movtdc and                            
                                                         plani.placod = movim.placod no-lock.  

                        find first produ where produ.procod = movim.procod no-lock no-error.            

                        put 
                                plani.Emite format ">>>>>>>>>>>>>>>>>>9" ";" 
                                plani.Desti format ">>>>>>>>>>>>9" ";" 
                                movim.procod format ">>>>>>>>>>9" ";" 
                                produ.pronom ";" 
                                movim.movqtm ";"     
                                movim.movpc ";" 
                                plani.pladat ";" 
                                movim.movtdc ";" 
                                produ.catcod ";"
                                vmovtnom
                                /*plani.notobs[2]*/ format "x(100)" ";"
                                plani.Numero format ">>>>>>>>9" ";"
                                plani.Serie ";" 
                                 
                                 skip.                                                          
                end.                                                                            
        end.  

output close.          

message c-arquivo view-as alert-box title " ARQUIVO GERADO! ".
