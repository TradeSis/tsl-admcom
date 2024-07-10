/*  emis_nfe.p  */
{admcab.i}

def temp-table tt-opera
    field campo1 as int
    field campo2 as char format "x(25)"
    field campo3 as int
    index i1 campo1.

/*********************************************************
Libera emergencialmente a emissao de Transferencia de credito nas filiais, essa
procedure poderá ser removida após janeiro de 2013 quando o código 14 estiver
inserido corretamente em todas as filiais
***************** ****************************************/
run p-libera-transf-credito.

    
run gera-temp.

def var v-opera as char format "x(30)" extent 15.
def var p-valor as char.
p-valor = "".
run le_tabini.p (setbcod, 0,
            "NFE - MOVIMENTACOES", OUTPUT p-valor) .

def var vi as int.
def var va as int.
def var vb as int.
va = num-entries(p-valor," ").
do vi = 1 to va:
    vb = int(entry(vi,p-valor,"")).
    find first tt-opera where
               tt-opera.campo1 = vb no-error.
    if avail tt-opera
    then tt-opera.campo3 = vi.            
end.

for each tt-opera where tt-opera.campo3 > 0:
    v-opera[tt-opera.campo3] = tt-opera.campo2.
end.    
def var vindex as int.

vindex = frame-index.
find first tt-opera where
           tt-opera.campo3 = vindex no-error. 
sresp = yes.
run blok-NFe.p (input setbcod,
                input "emis_nfe.p",
                output sresp).
if not sresp
then return.

sresp = no.
                            
vindex = tt-opera.campo1.

if vindex = 1
then run nftra_NFe.p. /*5152*/
else if vindex = 2 or vindex = 3
then run nfveneco.p /*nfdevven.p*/  . /*1202*/
else if vindex = 4
then run nfvenda.p. /*5102*/
if vindex = 5
then run nfvenda_j.p. /*5102*/
else if vindex = 6
then run nfdevcom.p. /*5202*/
else if vindex = 7
then run nftraimb.p. /*5901*/
else if vindex = 8
then run nftrauco.p. 
else if vindex = 9
then run nfremben.p. /*5901*/
else if vindex = 10
then run nfremcon.p. /*5915*/
else if vindex = 11
then run nfretcon.p. /*1915*/
else if vindex = 12
then run nfoutsai.p. /*5949*/
else if vindex = 13
then run nfoutent.p. /*1949*/ 
else if vindex = 14
then run nftracre.p. /*5602*/
else if vindex = 15
then run nftraU_NFe.p. /*5152*/
else if vindex = 16
then run nftraRem_Loc.p. /*5555*/

return.                    
                    
procedure gera-temp:
    create tt-opera.
    assign
        campo1 = 1
        campo2 = "TRANSFERENCIA PARA REVENDA"
        .
    create tt-opera.
    assign
        campo1 = 2
        campo2 = "DEVOLUCAO DE VENDA "
        .
    create tt-opera.
    assign
        campo1 = 3
        campo2 = "NOTA FISCAL ACOBERTADA"
        .
    create tt-opera.
    assign
        campo1 = 4
        campo2 = "VENDA POSSOA FISICA"
            .
    create tt-opera.
    assign
        campo1 = 5
        campo2 = "VENDA POSSOA JURIDICA"
          .
    create tt-opera.
    assign
        campo1 = 6
        campo2 = "DEVOLUCAO DE COMPRA"
           .
    create tt-opera.
    assign
        campo1 = 7
        campo2 = "TRANSFERENCIA IMOBILIZADO"
            .
    create tt-opera.
    assign
        campo1 = 8
        campo2 = "TRANSFERENCIA USO/CONSUMO"
           .
    create tt-opera.
    assign
        campo1 = 9
        campo2 = "REMESSA BENEFICIAMENTO"
            .
    create tt-opera.
    assign
        campo1 = 10
        campo2 = "REMESSA CONSERTO   "
        .
    create tt-opera.
    assign
        campo1 = 11
        campo2 = "RETORNO CONSERTO   "
          .
    create tt-opera.
    assign
        campo1 = 12
        campo2 = "OUTRAS SAIDAS      "
          .
    create tt-opera.
    assign
        campo1 = 13
        campo2 = "OUTRAS ENTRADAS    "
          .
    create tt-opera.
    assign
        campo1 = 14
        campo2 = "TRANSFERENCIA CREDITO ICMS"
          .   
    create tt-opera.
    assign
        campo1 = 15
        campo2 = "TRANSFERENCIA PRODUTO USADO"
          .                  
    create tt-opera.
    assign
        campo1 = 16
        campo2 = "RETORNO LOCACAO"
          .                  
end procedure.                
                        
                        
procedure p-libera-transf-credito.
                        
    /*
    def buffer btab_ini for tab_ini.
                            
    find first btab_ini where   btab_ini.etbcod = stebcod and
                                parametro = "NFE - MOVIMENTACOES".

    if lookup("14",btab_ini.valor," ") = 0
    then assign btab_ini.valor = btab_ini.valor + " 14".
    */    
end.
        
