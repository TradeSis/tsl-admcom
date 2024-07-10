/*  qbesegprest.p Nov/2015
#1 05.06.2017 Buscar numero da sorte quando em branco
*/
{admcab.i}
{loj/qbebilhete.i}
{dftempWG.i new}

def input parameter par-rec-vndseguro as recid.
def input parameter par-vias as int.

def var vpdf as char no-undo.

function Texto return character
    (input par-texto as char).

    if par-texto = ?
    then return "".
    else return(trim(par-texto)).

end function.


def var vparam as char.
def var vlayout as char.
def var vlocal  as char.
def var varqsai as char.
def var vct     as int.

find vndseguro where recid(vndseguro) = par-rec-vndseguro no-lock.
find clien of vndseguro no-lock.
find estab of vndseguro no-lock.

/* #1 */
if setbcod < 900 and
   vndseguro.procod <> 559910 and
   (vndseguro.numerosorte = "" or
    vndseguro.numerosorte = ?)
then run busca-numero-seguro.

vlocal = trim(estab.munic) + "/" + estab.ufecod + ", " +
         string(vndseguro.dtincl, "99/99/9999") + ".".

if vndseguro.dtcanc <> ?
then vlayout = "/admcom/progr/loj/qbe-prest-canc".
else if vndseguro.procod = 559910
then vlayout = "/admcom/progr/loj/qbe-prest-moveis".
else if vndseguro.procod = 559911
then vlayout = "/admcom/progr/loj/qbe-prest-moda".
else if vndseguro.procod = 578790
then vlayout = "/admcom/progr/loj/qbe-prest-moveis2".
else vlayout = "/admcom/progr/loj/qbe-prest-moveis3".

input from value(vlayout) no-echo.
repeat transaction.
    create tt-texto.
    import unformatted tt-texto.
end.
input close.

for each tt-texto.
    if index(tt-texto.linha, "&") = 0
    then next.

    troca("&Certificado", vndseguro.certifi, 0).
    troca("&DInclusao",string(vndseguro.dtincl, "99/99/9999"), 10).    
    troca("&Nome",  clien.clinom, 0).
    troca("&Cpf",   Texto(clien.ciccgc), 14).
    troca("&DNascimen",if clien.dtnasc <> ?
                    then string(clien.dtnasc, "99/99/9999") else "",10).
    troca("&Endereco",trim(clien.endereco[1]) + "," + string(clien.numero[1]) +
                           " " + Texto(clien.compl[1]), 0).
    troca("&Bairro",Texto(clien.bairro[1]), 0).
    troca("&Cep",   Texto(clien.cep[1]), 0).
    troca("&Cidade",Texto(clien.cidade[1]), 0).
    troca("&Uf",    Texto(clien.ufecod[1]), 3).
    troca("&Fone",  Texto(clien.fone), 0).
    troca("&Email", Texto(clien.zona), 0).
    troca("&DtInVig",string(vndseguro.dtivig, "99/99/99"), 8).
    troca("&DtFnVig",string(vndseguro.dtfvig, "99/99/99"), 8).
    troca("&NSorteio",string(vndseguro.numerosorte, "999/99999"), 0).
    troca("&Local", vlocal, 0).
    if vndseguro.dtcanc <> ?
    then troca("&DCancelam",string(vndseguro.dtcanc,"99/99/9999"), 10).

    tt-texto.linha = right-trim(tt-texto.linha).
end.

varqsai = "/admcom/relat/qbesegprest." + string(mtime).

output to value(varqsai).

put unformatted chr(27) "@".  /* reseta */
put chr(29) + "!" + chr(0)   skip  .      /* tamanho da fonte */
put unformatted chr(27) "!" chr(4).
put unformatted chr(27) "3" chr(45). /* espaco entre lin */
put unformatted chr(27) "M" chr(49). /* Fonte B */
put unformatted chr(27) "a" chr(48). /* justifica esquerda */
    
run imprime-texto.

if vndseguro.dtcanc = ?
then run termo("Prestamista LEBES", vlocal).

put unformatted
    chr(29) + "V" + chr(66)     /* corta */
    chr(27) + "@" skip.         /* reseta */

output close.

/***
do vct = 1 to par-vias.
    if scarne = "local"
    then unix silent /fiscal/lp value(varqsai).
    else unix silent /fiscal/lp value(varqsai) 1.
end.
***/
if sremoto
then do.
    run pdfout.p (input varqsai /***"/admcom/relat/cre02"***/,
                  input "/admcom/kbase/pdfout/",
                  input "qbesegprest" + string(time) + ".pdf",
                  input "Portrait",
                  input 8.2,
                  input 1,
                  output vpdf).
    message ("Arquivo " + vpdf + " gerado com sucesso!") view-as alert-box.
end.
else run visurel.p (input varqsai, input "").


procedure busca-numero-seguro:
    def var vparam as char init "".
    def buffer bvndseguro for vndseguro.

    find bvndseguro where recid(bvndseguro) = recid(vndseguro) no-lock.
    vparam = string(bvndseguro.etbcod,"999") + string(bvndseguro.certifi).
    run agil4_WG.p (input "segnumsorte", input vparam).
    find first tp-segnumsorte no-error.
    if avail tp-segnumsorte
    then do on error undo:
        find current bvndseguro no-error.
        assign
            bvndseguro.numerosorte = string(tp-segnumsorte.serie,"999") +
                                     string(tp-segnumsorte.nsorteio,"99999")
            bvndseguro.datexp = today
            bvndseguro.exportado = no.
    end.
end procedure.

