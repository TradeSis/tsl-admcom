/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : valtribu.i
***** Diretorio                    : estoq
***** Autor                        : Claudir Santolin
***** Descri‡ao Abreviada da Funcao: Valida tributacao da mercadoria
***** Data de Criacao              : 25/09/2000

                                ALTERACOES
***** 1) Autor     :
***** 1) Descricao : 
***** 1) Data      :

***** 2) Autor     :
***** 2) Descricao : 
***** 2) Data      :

***** 3) Autor     :
***** 3) Descricao : 
***** 3) Data      :
*****************************************************************************/

/* busca tributacao do produto */

find first tribicms where tribicms.pais-sigla   = {&pais-ori}
                      and tribicms.ufecod       = {&unfed-ori}
                      and tribicms.pais-dest    = {&pais-dest}
                      and tribicms.unfed-dest   = {&unfed-dest}
                      and tribicms.procod       = {&procod}
                      and tribicms.cfop         = {&opfcod}
                      and tribicms.agfis-cod    = {&ncm}
                      and tribicms.agfis-dest   = {&agfis-dest}
                      and tribicms.dativig     <= {&dativig}
                      and ( tribicms.datfvig    = ? or
                            tribicms.datfvig   >= {&dativig} )
                            use-index tribicms no-lock no-error.

if not available tribicms and
   {&procod} > 0 and
   {&opfcod} > 0 /* Procod + cfop */
then
    find first tribicms where tribicms.pais-sigla   = {&pais-ori}
                      and tribicms.ufecod       = {&unfed-ori}
                      and tribicms.pais-dest    = {&pais-dest}
                      and tribicms.unfed-dest   = {&unfed-dest}
                      and tribicms.procod       = {&procod}
                      and tribicms.cfop         = {&opfcod}
                      and tribicms.agfis-cod    = 0
                      and tribicms.agfis-dest   = 0
                      and tribicms.dativig     <= {&dativig}
                      and ( tribicms.datfvig    = ? or
                            tribicms.datfvig   >= {&dativig} )
                            use-index tribicms no-lock no-error.

if not available tribicms and
   {&procod} > 0 and
   {&ncm} > 0 /* Procod + NCM */
then
    find first tribicms where tribicms.pais-sigla   = {&pais-ori}
                      and tribicms.ufecod       = {&unfed-ori}
                      and tribicms.pais-dest    = {&pais-dest}
                      and tribicms.unfed-dest   = {&unfed-dest}
                      and tribicms.procod       = {&procod}
                      and tribicms.cfop         = 0
                      and tribicms.agfis-cod    = {&ncm}
                      and tribicms.agfis-dest   = 0
                      and tribicms.dativig     <= {&dativig}
                      and ( tribicms.datfvig    = ? or
                            tribicms.datfvig   >= {&dativig} )
                            use-index tribicms no-lock no-error.

if not available tribicms and {&procod} > 0 /* Procod */
then
    find first tribicms where tribicms.pais-sigla   = {&pais-ori}
                      and tribicms.ufecod       = {&unfed-ori}
                      and tribicms.pais-dest    = {&pais-dest} 
                      and tribicms.unfed-dest   = {&unfed-dest}
                      and tribicms.procod       = {&procod}
                      and tribicms.cfop         = 0
                      and tribicms.agfis-cod    = 0
                      and tribicms.agfis-dest   = 0
                      and tribicms.dativig     <= {&dativig}
                      and ( tribicms.datfvig    = ? or
                            tribicms.datfvig   >= {&dativig} )
                            use-index tribicms no-lock no-error.

if not available tribicms and {&opfcod} > 0 /* CFOP */
then
    find first tribicms where tribicms.pais-sigla   = {&pais-ori}
                      and tribicms.ufecod       = {&unfed-ori}
                      and tribicms.pais-dest    = {&pais-dest}
                      and tribicms.unfed-dest   = {&unfed-dest}
                      and tribicms.procod       = 0
                      and tribicms.cfop         = {&opfcod}
                      and tribicms.agfis-cod    = 0
                      and tribicms.agfis-dest   = 0
                      and tribicms.dativig     <= {&dativig}
                      and ( tribicms.datfvig    = ? or
                            tribicms.datfvig   >= {&dativig} )
                            use-index tribicms no-lock no-error.

if not available tribicms and {&ncm} > 0 /* NCM */
then
    find first tribicms where tribicms.pais-sigla   = {&pais-ori}
                      and tribicms.ufecod       = {&unfed-ori}
                      and tribicms.pais-dest    = {&pais-dest}
                      and tribicms.unfed-dest   = {&unfed-dest}
                      and tribicms.procod       = 0
                      and tribicms.cfop         = 0
                      and tribicms.agfis-cod    = {&ncm}
                      and tribicms.agfis-dest   = 0
                      and tribicms.dativig     <= {&dativig}
                      and ( tribicms.datfvig    = ? or
                            tribicms.datfvig   >= {&dativig} )
                            use-index tribicms no-lock no-error.

if not available tribicms /* Regra Geral da UF */
then
    find first tribicms where tribicms.pais-sigla   = {&pais-ori}
                      and tribicms.ufecod       = {&unfed-ori}
                      and tribicms.pais-dest    = {&pais-dest}  
                      and tribicms.unfed-dest   = {&unfed-dest}
                      and tribicms.procod       = 0
                      and tribicms.cfop         = 0
                      and tribicms.agfis-cod    = 0
                      and tribicms.agfis-dest   = 0
                      and tribicms.dativig     <= {&dativig}
                      and ( tribicms.datfvig    = ? or
                            tribicms.datfvig   >= {&dativig} )
                            use-index tribicms no-lock no-error.

if not avail tribicms
then do : 
/***
    message color red/withe " Produto " {&procod} 
                " - " {&pais-ori} " - " {&unfed-ori} "--" 
                      {&pais-dest} " - " {&unfed-dest} " nao esta tributado"
                            view-as alert-box 
                            title " Erro Tributacao ".
***/
    {&nextlabel}
end.

if keyfunction(lastkey) = "end-error"
then next.

