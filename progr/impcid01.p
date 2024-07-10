/* ********************************************************************************************
*  Programa....: impcid01.p
*  Funcao......: Importar arquivo de cidades
*  Data........: Abril de 2006
*  Autor ......: Gerson Mathias
******************************************************************************************** */

def var cLinha_1a   as char form "x(200)"               init ""                 no-undo.
def var cArquivo    as char form "x(60)"                init ""                 no-undo.
def var iContar      as inte form ">>>9"                 init 0                  no-undo.
def var iConta      as inte                             init 0                  no-undo.
def var icont       as inte                             init 0                  no-undo.
def var ctexto      as char form "x(60)"                init ""                 no-undo.


def temp-table tt-cidades                   no-undo
    field cidadeAnt     as  char    form "x(60)"
    field cidadeNov     as  char    form "x(60)".

for each tt-cidades:
    delete tt-cidades.
end.

assign cArquivo = "C:\Clientes\Drebes\CIDADES1.txt".

/* ---------------------------------------------------------------------------------------- */

input from value(cArquivo).

repeat:

    import unformatted cLinha_1a.

            create tt-cidades.
            assign tt-cidades.cidadeAnt = substring(cLinha_1a,01,50)
                   tt-cidades.cidadeNov = substring(cLinha_1a,56,50).
            
end.

input close.

for each tt-cidades no-lock:

    assign cTexto = "".
        
    assign iConta = length(trim(tt-cidades.cidadeNov)) + 2.
    repeat:

           assign iCont = iCont + 1.

           if substring(tt-cidades.cidadeNov,iCont,1) <> chr(9) 
           then do:
                   assign cTexto = cTexto + substring(tt-cidades.cidadeNov,iCont,1).
           end.


           if iCont >= iConta
           then do: 
                   assign iCont = 0. 
                   leave.
           end.

    end.


    assign tt-cidades.cidadeNov = trim(cTexto).


    disp tt-cidades.cidadeAnt   form "x(30)"
         tt-cidades.cidadeNov   form "x(30)"
         with frame f-1 down width 80.


end.
