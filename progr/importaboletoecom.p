{admcab.i}

define variable vcha-titulo        as character format "x(53)".
define variable vcha-titulo2       as character format "x(24)".
define variable vcha-arquivo-aux   as character.
define variable vcha-arquivo-aux2  as character.
define variable vcha-val-aux       as character.


define variable vcha-linha         as character format "x(100)".

define temp-table tt-arquivo
        field nome as character format "x(14)".

form vcha-titulo
     with frame f-01 centered.

form vcha-titulo2
     with frame f-02 centered.
     
form vcha-arquivo-aux label "Nome do Arquivo" format "x(14)"
     with frame f-03 centered side-labels.

assign vcha-titulo  = "Conciliacao Bancaria do E-Commerce - Banco do Brasil"
       vcha-titulo2 = "Importacao dos arquivos".


display vcha-titulo skip(2)
           with fram f-01 no-label no-box centered row 5 .
pause 0.

display vcha-titulo2 skip(2)
           with fram f-02 no-label no-box centered row 8 .
pause 0.
           
/* Igual a executar um LS no diretorio e importar o resultado */
input through value("ls /admcom/web/retornobb") no-echo.

repeat:

  import vcha-arquivo-aux.
  
  if vcha-arquivo-aux = "importados" or vcha-arquivo-aux = ""
      or vcha-arquivo-aux = "outros"  
  then next.
  
  create tt-arquivo.
  assign tt-arquivo.nome = vcha-arquivo-aux.

end.  

output close. 

for each tt-arquivo:

    disp tt-arquivo.nome column-label "Arquivos Importados"
                    with  frame f-down row 08 down color blue/cyan.
                    
    pause 0.                
    
    /*Coloca aspas no inicio e fim de cada linha*/
    assign vcha-arquivo-aux2 = "/usr/dlc/bin/quoter /admcom/web/retornobb/" + tt-arquivo.nome + " > /admcom/web/retornobb/ok-" + tt-arquivo.nome.

    unix silent value(vcha-arquivo-aux2).
    
    input from value("/admcom/web/retornobb/ok-" + tt-arquivo.nome).
    
    repeat:
    
        import vcha-linha.
          
        if substring(vcha-linha,1,1) = "1"
        then do:

            assign vcha-val-aux = substring(vcha-linha,254,11) + "." + 
            substring(vcha-linha,265,2).
        
            if not can-find(first boletopag
                            where boletopag.bolcod =                                     integer(substring(vcha-linha,46,15)))
            then do:                        
                                    
               create boletopag.
               assign boletopag.bolcod    = integer(substring(vcha-linha,46,15))
                      boletopag.bolvalpag = decimal(vcha-val-aux).
            
            end.
            
        end.                    

    end.
    
    unix silent value("rm -f /admcom/web/retornobb/ok-" + tt-arquivo.nome).
                    
    unix silent value("mv -f /admcom/web/retornobb/" + tt-arquivo.nome
         + " /admcom/web/retornobb/importados/" + tt-arquivo.nome).
         
                    
end.

