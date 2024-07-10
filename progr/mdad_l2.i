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

/*scabrel = {&tit-rel}.*/

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

/*display with {&form}.*/
