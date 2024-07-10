{admcab.i}

def var v-opera as char format "x(30)" extent 16.
def var vindex as int.
if setbcod > 990 and setbcod <> 999
then v-opera[2] = "VENDA POSSOA JURIDICA".
else
assign
    v-opera[1] = "VENDA POSSOA FISICA"
    v-opera[2] = "VENDA POSSOA JURIDICA"
    v-opera[3] = "VENDA ATIVO IMOBILIZADO"
    v-opera[4] = "DEVOLUCAO DE VENDA "
    v-opera[5] = "DEVOLUCAO DE COMPRA"  
    v-opera[6] = "TRANSFERENCIA PARA REVENDA"
    v-opera[7] = "TRANSFERENCIA IMOBILIZADO"
    v-opera[8] = "TRANSFERENCIA USO/CONSUMO"
    v-opera[9] = "REMESSA BENEFICIAMENTO"
    v-opera[10] = "REMESSA CONSERTO   "
    v-opera[11] = "RETORNO CONSERTO   "
    v-opera[12] = "OUTRAS SAIDAS      "
    v-opera[13] = "TRANSFERENCIA CREDITO ICMS"
    v-opera[14] = "RETORNO LOCACAO"
    v-opera[15] = "OUTRAS ENTRADAS"
    v-opera[16] = "REMESSA PARA EXPORTACAO".
    disp v-opera with frame f-opera 1 down
                no-label centered row 6 1 column
                title " Emissao ".
choose field v-opera with frame f-opera.  
vindex = frame-index.

sresp = yes.
if setbcod = 22 or
   setbcod = 999 or
   sremoto
then.
else run blok-NFe.p (input setbcod,
                input "emis_nfe.p",
                output sresp).
if not sresp
then return.

sresp = no.
                                  
if vindex = 1
then run nfvenda.p. /*5102*/
if vindex = 2
then run nfvenda_j.p. /*5102*/
else if vindex = 3
then run nfvenda_ativo_j.p. /*5551*/
else if vindex = 4
    then run nfdevven.p. /*1202*/
    else if vindex = 5
        then run nfdevcom.p. /*5202*/
        else if vindex = 6
            then run nftransf.p. /*5152*/
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
                                then run nftracre.p. /*5602*/
                                else if vindex = 14
                                then run nftraRem_Loc.p. /*5602*/
                                else if vindex = 15
                                then run nfoutent.p.
                                else if vindex = 16 /*5502*/
                                then run remessa_exportacao.p.
return.                    
                    
                    
