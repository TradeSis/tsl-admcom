{admcab.i}


def input parameter vetbcod like estab.etbcod.

def shared temp-table tt-dados
    field clicod like plani.desti
    field freq as int
    field vltot as dec
    field etique as log
        index iclicod clicod.

 
def stream sarq.
def var vcaminho as char format "x(59)" label "Diretorio/Caminho".



output stream sarq to l:\relat\cli.cdl.

update vcaminho with frame f1 side-label width 80.

    
    output to value(vcaminho).
    
    for each tt-dados where tt-dados.etique = yes by tt-dados.clicod:
    
        find clien where clien.clicod = tt-dados.clicod no-lock no-error.
        if not avail clien
        then next.
     
        
        if clien.clinom      = "" or
           clien.endereco[1] = "" or
           clien.endereco[1] = ?  or
           clien.cidade[1]   = "" or
           clien.cidade[1]   = ?  or
           clien.cep[1]      = ?  
        then do:
            
            display stream sarq
                    clien.clicod
                    clien.clinom with frame f-cli down.
                    
            next.
            
        end.
        
        
        put "|" clien.clinom    "|"
                 "Rua "  
                  clien.endereco[1] " "  
                  clien.numero[1] " "
                  clien.compl[1]  "|"
                  clien.bairro[1] "|" 
                  clien.cidade[1] "|"
                  clien.ufecod[1] "|"
                  clien.cep[1]    "|" 
                  vetbcod   format ">>9" "|" skip.
        
    end.
    
    output close.
    output stream sarq close.
    
    
    

 
