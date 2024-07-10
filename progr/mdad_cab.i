/*******************************************************************************
*  Area Comercial  -  Administracao Comercial          Programa: MdAdmCab.i    *
*  Programador(a)...: Mesquita                         Data....: 24/07/1992    *
*  Descricao Sumaria:                                                          *
*       - Cabecalho Padrao do Sistema Comercial                                *
*------------------------------------------------------------------------------*
* Parametros   | Usual          | Opcoes           | Comentario                *
*--------------|----------------|----------------------------------------------*
* &Saida     = | Printer        | Terminal/Arquivo | Meio de Saida             *
* &Page-Size = | 60             | Numero           | Linhas por Pagina         *
* &Append    = | Nao Usar       | Append           | Extender Arquivo          *
* &Cond-Var  = |  "80""         |  "80"  ate "160" | No. de Caracteres no Frame*
* &Page-Line = | 0              | Numero           | Formata Imp p/ n Linhas   *
* &Nom-Rel   = | """XXXXXXXX""" | Texto Livre      | Nome do Relatorio (8 Pos) *
* &Nom-Sis   = | """XXXXXXXX""" | Texto Livre      | Nome do Sistema           *
* &Tit-Rel   = | """XXXXXXXX""" | Texto Livre      | Titulo Relatorio Centrado *
* &Width     = | 80             | Numero           | Tamanho da linha          *
* &Form      = | frame xxxxxxx  | Texto            | Nome do Frame do cabe‡alho*
*******************************************************************************/

scabrel = {&tit-rel}.

if opsys = "UNIX"
then do:
    form header
    wempre.emprazsoc                                            +
        fill(" ",({&width} - length(wempre.emprazsoc) - 21))    +
    {&Nom-Rel}                                                  +
        fill(" ",(21 - length({&Nom-Rel}) - 10))                +
    "PAG.: "                                                    +
    string(page-number,">>>9") format "x(248)"
    skip
    {&Nom-Sis}                                                  +
        fill(" ",({&width} - length({&Nom-Sis}) - 21))          +
    string(day(today),"99")                                     +
        " "                                                     +
    caps(vmesabr[month(today)])                                 +
        " "                                                     +
    string(year(today),"9999")                                  +
        " "                                                     +
        "  "                                                    +
        " "                                                    +
    string(time,"hh:mm")
            format "x(248)"
    skip

    {&Centered}
    fill(" ",integer(string(truncate((({&width} -
        length({&Tit-Rel})) / 2),0),"999")))                    +
    caps({&Tit-Rel})
            format "x(248)" at 1
    skip
    /{&Centered}**/

    {&Tit-Rel1}

    fill ("-",{&width})
            format "x(248)"
    with {&Form}
        page-top
        no-box
        width 250.

end.
output to {&Saida} page-size {&Page-Size} {&Append}.

if {&Page-Line} <> 0
then
    put unformatted chr(27) + "C" + chr({&Page-Line}).

if {&Cond-Var} >  137
then
    put unformatted chr(27) + "M" + chr(15).

if {&Cond-Var} >  96  and {&Cond-Var} <=  137
then
    put unformatted chr(27) + "P" + chr(15).

if {&Cond-Var} >  80  and {&Cond-Var} <=  96
then
    put unformatted chr(27) + "M" + chr(18).

if {&Cond-Var} <=  80
then
    put unformatted chr(27) + "P" + chr(18).

display with {&form}.
