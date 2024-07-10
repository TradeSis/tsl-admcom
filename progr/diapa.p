{cab.i}
define variable mes as integer format "99" label "Mes Processo".
define variable ano as integer format "9999" label "Ano Processo".
define variable livnum as integer format ">>>9" label "Numero Livro".
define variable pagini as integer format ">>>>9" label "Pagina Inicial"
       initial 2.
do with 1 column width 80 frame f1:
 update ano mes livnum pagini.
end.
message "Processando Diario Auxiliar, aguarde.".
output to printer page-size 60.
put unformatted chr(30) "5".
page.
define temp-table wdiapa
       field wdatapg like parcela.dtpaga
       field wcontnum like contrato.contnum
       field wparcela like parcela.parcela
       field wclicod like clien.clicod
       field wvltotal like contrato.vltotal
       field wvljuros like parcela.vljuros
       field wvldesc like parcela.vldesc
       field wvldevol like parcela.vldevol
       field wvlpaga like parcela.vlpaga.
define variable w01 like contrato.vltotal.
define variable w02 like contrato.vltotal.
define variable w03 like contrato.vltotal.
define variable w04 like contrato.vltotal.
define variable w05 like contrato.vltotal.
define variable w001 like contrato.vltotal.
define variable w002 like contrato.vltotal.
define variable w003 like contrato.vltotal.
define variable w004 like contrato.vltotal.
define variable w005 like contrato.vltotal.
define variable clinommes as character format "x(9)" extent 12
       initial ["Janeiro","Fevereiro","Marco","Abril","Maio","Junho",
                "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].
form header
 wempre.emprazsoc
 "Diario Auxiliar  -  Pagamentos  -  " at 55
 clinommes[mes] "  de  " ano
 "Livro - " at 133 livnum format ">>>9"
 ", Folha - " page-number + pagini - 2 format ">>>>9"
 skip fill("-",162) format "x(162)"
 skip(2)
 with frame fcab page-top no-box width 165.
form header
 skip "Data     Parcela   Cliente Nome do Cliente"
 "Valor Parcela     " at 69
 "Juros             "
 "Descontos         "
 "Devolucoes        "
 "Valor Pago"
 skip "-------- --------  -------" fill("-",40) format "x(40)" space(1)
 fill("-",18) format "x(18)" space
 fill("-",18) format "x(18)" space
 fill("-",18) format "x(18)" space
 fill("-",18) format "x(18)" space
 fill("-",18) format "x(18)" space
 with frame fdet page-top no-box width 165.
view frame fcab.
view frame fdet.
assign w01 = 0
       w02 = 0
       w03 = 0
       w04 = 0
       w05 = 0
       w001 = 0
       w002 = 0
       w003 = 0
       w004 = 0
       w005 = 0.
for each contrato where year(dtinicial) = ano and
                        month(dtinicial) = mes and
                        contrato.situacao <> 9 and
                        vlentra <> 0:
 create wdiapa.
 assign wdatapg = contrato.dtinicial
        wcontnum = contrato.contnum
        wclicod = contrato.clicod
        wvltotal = contrato.vlentra
        wvlpaga = contrato.vlentra.
end.
for each parcela where year(dtpaga) = ano and
                       month(dtpaga) = mes and
                       parcela.situacao <> 9:
 find contrato of parcela.
 create wdiapa.
 assign wdatapg = parcela.dtpaga
        wcontnum = parcela.contnum
        wparcela = parcela.parcela
        wclicod = contrato.clicod
        wvltotal = parcela.vlparc
        wvljuros = parcela.vljuros
        wvldesc = parcela.vldesc
        wvldevol = parcela.vldevol
        wvlpaga = parcela.vlpaga.
end.
for each wdiapa break by wdatapg:
 if first-of(wdatapg)
  then put wdatapg " ".
  else put space(9).
 find clien where clien.clicod = wdiapa.wclicod.
 put wcontnum "-" wparcela "  " wclicod "  " clien.clinom " "
     wvltotal format ">>>,>>>,>>>,>>9.99" " "
     wvljuros format ">>>,>>>,>>>,>>9.99" " "
     wvldesc format ">>>,>>>,>>>,>>9.99" " "
     wvldevol format ">>>,>>>,>>>,>>9.99" " "
     wvlpaga format ">>>,>>>,>>>,>>9.99" skip.
 assign w01 = w01 + wvltotal
        w02 = w02 + wvljuros
        w03 = w03 + wvldesc
        w04 = w04 + wvldevol
        w05 = w05 + wvlpaga.
 if last-of(wdatapg)
 then do:
 put space(48) "Total de " wdatapg " = " w01 format ">>>,>>>,>>>,>>9.99" " "
                                 w02 format ">>>,>>>,>>>,>>9.99" " "
                                 w03 format ">>>,>>>,>>>,>>9.99" " "
                                 w04 format ">>>,>>>,>>>,>>9.99" " "
                                 w05 format ">>>,>>>,>>>,>>9.99"
     skip fill("-",162) format "x(162)" skip.
 assign w001 = w001 + w01
        w01 = 0
        w002 = w002 + w02
        w02 = 0
        w003 = w003 + w03
        w03 = 0
        w004 = w004 + w04
        w04 = 0
        w005 = w005 + w05
        w05 = 0.
 end.
end.
put skip(2) space(56) "Total Mes = " w001 format ">>>,>>>,>>>,>>9.99" " "
                           w002 format ">>>,>>>,>>>,>>9.99" " "
                           w003 format ">>>,>>>,>>>,>>9.99" " "
                           w004 format ">>>,>>>,>>>,>>9.99" " "
                           w005 format ">>>,>>>,>>>,>>9.99".
put unformatted chr(30) "0".
