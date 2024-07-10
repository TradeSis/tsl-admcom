/* helio 26072023 NOVAÇÃO COM ENTRADA (BOLETO) + SEGURO PRESTAMISTA . SOLUÇÃO 3 */

def new global shared var sremoto       as log.
def new global shared var setbcod       as int.


def var varquivo as char.
def var vpdf as char.

def input param prec as recid.
def input param pcopias as int.
def input param par-dir as char. /* helio 16012023 */

def var vcatnom  as char.

{/admcom/progr/api/jsontermos.i NEW}

    find vndseguro where recid(vndseguro)= prec no-lock.

    create ttpedidoCartaoLebes.
    vdataTransacao = vndseguro.pladat.
    vdatainivigencia12 = vndseguro.DtIVig.  
    vdatafimvigencia13 = vndseguro.DtfVig.
      
    create ttcartaolebes.
    ttcartaoLebes.numeroBilheteSeguroPrestamista = string(CodSegur,"9999") + vndseguro.certifi.
    ttcartaoLebes.numeroSorteSeguroPrestamista   = string(vndseguro.numeroSorte,"999999999").

    vvalorSeguroPrestamista     = vndseguro.PrSeguro.
    vvalorSeguroPrestamistaIof  = round(vndseguro.PrSeguro * 0.38 / 100,2).
    vvalorSeguroPrestamistaLiquido = vvalorSeguroPrestamista - vvalorSeguroPrestamistaIof.
    vvalorSeguroPrestamista29 = 0.
    vvalorSeguroPrestamista30 = 0.
    



    find clien where clien.clicod = vndseguro.clicod no-lock.
    create ttcliente.

    ttcliente.tipoPessoa    = string(clien.tippes,"FISICA/JURIDICA").
    ttcliente.rg            = clien.ciinsc.
    ttcliente.cpf           = clien.ciccgc.
    ttcliente.nome          = clien.clinom.
    ttcliente.dataNascimento = string(year(clien.dtnasc)) + "-" + string(month(clien.dtnasc),"99") + "-" + string(day(clien.dtnasc),"99").
    ttcliente.codigoCliente = string(clien.clicod).
    ttcliente.cep           = string(clien.cep[1]).
    ttcliente.logradouro    = clien.endereco[1].
    ttcliente.numero        = string(clien.numero[1]).
    ttcliente.complemento   = clien.compl[1].
    ttcliente.bairro        = clien.bairro[1].
    ttcliente.cidade        = clien.cidade[1].
    ttcliente.uf            = clien.ufecod[1].
    ttcliente.pais          = "BRA".
    ttcliente.email         = clien.zona.
    ttcliente.telefone      = clien.fone.
    vprodutos-Lista = "".
    
    vcatnom = "".    
    run pprodutos.

       if vcatnom = "MODA"
       then find termos where termos.idtermo = "ADESAO-SEGURO-PRESTAMISTA-MODA" no-lock.
       else find termos where termos.idtermo = "ADESAO-SEGURO-PRESTAMISTA-MOVEIS" no-lock.


        COPY-LOB termos.termo TO textFile.

        do vcopias = 1 to termos.termoCopias:
            vid = vid + 1.

            create tttermos.
            tttermos.id = string(vid).
            tttermos.data = string(year(today)) + "-" + string(month(today),"99") + "-" + string(day(today),"99").
            tttermos.codigo = termos.idtermo. 
            tttermos.conteudo = string(textFile).
            tttermos.extensao = "TXT".
            tttermos.nome = termos.termoNome.
            tttermos.tipo = termos.idtermo.

            run trocamnemos.
        end. 


    find first tttermos.

    
def var vnome as char.
vnome = trim(clien.ciccgc) + "_" + string(vndseguro.etbcod,"999") + "_" + 
        string(vndseguro.pladat,"99999999") + "_" + trim(vndseguro.certifi) .

/*  helio 16012023 - recebera o diretorio de par-dir
    varquivo = "/admcom/relat-prestamista/" +  vnome.*/
/* helio 16012023 */

    par-dir  = "/admcom/relat-loja/filial" + string(vndseguro.etbcod,"999") + "/seguro/". /* helio 28/02/2024 - pedido Erica */

    if par-dir = "" or par-dir = ? then par-dir = "/admcom/relat/".
    varquivo = par-dir +  vnome.


    output to value(varquivo).
    put unformatted tttermos.conteudo.
    output close.

    
 run /admcom/progr/pdfout.p (input varquivo,
                  input par-dir,
                  input vnome + ".pdf",
                  input "Portrait",
                  input 8.2,
                  input 1,
                  output vpdf).
    
 unix silent value("rm -f       " + varquivo).
 unix silent value("chmod 777   " + par-dir + vpdf).

/*if pcopias > 0 and sremoto = no
then message "arquivo" skip par-dir + vpdf skip "gerado" view-as alert-box.*/

if program-name(2) = "fin/cdvndseguro.p"
then message "arquivo gerado em " par-dir + vpdf view-as alert-box.



procedure pprodutos.
def var vvalortotal as dec.

            find first plani where plani.etbcod = vndseguro.etbcod and
                                   plani.placod = vndseguro.placod
                                     no-lock no-error.
            if avail plani
            then do:
                for each movim where movim.etbcod = plani.etbcod and
                                    movim.placod  = plani.placod
                                    no-lock .
                    find produ of movim no-lock no-error.
                    if avail produ
                    then do:
                        /*
                        if produ.proipiper = 98
                        then next.
                        if contrato.contnum = 308483513
                        then disp produ.proseq produ.catcod produ.pronom proipiper produ.procod vcatnom vvalortotal (movim.movqtm * movim.movpc).
                */                        
                        find categoria of produ no-lock no-error.
                        if avail categoria
                        then do:
                            if produ.catcod = 31 or produ.catcod = 41
                            then do:
                                if vcatnom = ""
                                then vcatnom = trim(categoria.catnom).
                                vvalortotal = vvalortotal + (movim.movqtm * movim.movpc) - movim.movdes.
                               vprodutos-Lista = vprodutos-lista + 
                                    string(produ.procod) + 
                                    " - " + (if avail produ
                                             then produ.pronom
                                             else "")
                                            +
                                        chr(10).
                                
                            end.    
                            if produ.procod = 8011 or produ.procod = 8015 or produ.procod = 8012
                            then do:
                                vvalortotal = vvalortotal + (movim.movqtm * movim.movpc) - movim.movdes.
                            end.
                        end.
                    end.         
                end.                                    
            end.



end procedure.