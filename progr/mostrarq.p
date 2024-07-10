/******************************************************************************
* Programa  - confdev1.p                                                      *
*                                                                             *
* Funcao    - relatorio de conferencia das notas de devolucao de vendas       *
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
*******************************************************************************/
{admcab.i}
def var varquivo as char format "x(50)".

    update varquivo label "Nome do Arquivo"
            with frame f1 side-label width 80.
   
   
 message "Deseja imprimir arquivo?" update sresp.
    if not sresp
    then return.
    
    
        if opsys <> "UNIX"
            then do:
                    {mrod_l.i}
            end.
                 else run visurel.p (input varquivo, input "").
           
                            
    dos silent value("type " + varquivo + " > prn").

