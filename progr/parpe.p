{admcab.i}
define variable dtini as date format "99/99/99" initial today
       label "Data Inicial".
define variable dtfim as date format "99/99/99" label "Data Final".
do with 2 column width 80 frame f1:
 update dtini.
 assign dtfim = dtini.
 update dtfim validate(dtfim>=dtini,"Dt.Final deve ser maior que Dt.Inicial").
end.
message "Processando Relatorio, aguarde.".
output to printer page-size 63.
define variable w01 like contrato.vltotal.
define variable w001 like contrato.vltotal.
form header
 wempre.emprazsoc "C R E D I A R I O" at 40 today at 73
 skip "Crediario - Parcelas no Periodo" "Pag." at 73 page-number format ">>9"
 skip fill("-",80) format "x(80)" skip
 with frame fcab page-top no-box.
form header
 skip "Dt.Venc. Cliente" space (41) "Cont. Pc    Valor Parc."
 with frame fdet page-top no-box.
view frame fcab.
view frame fdet.
assign w01 = 0.
assign w001 = 0.
 for each titulo  where
    titulo.empcod = wempre.empcod and
    titulo.titnat = no and
    titulo.modcod = "CRE" and
    titdtven >= dtini and
    titdtven <= dtfim
    break by titdtven
    with width 80 down:
 if first-of(titulo.titdtven)
  then put titulo.titdtven " ".
  else put space(9).
 find contrato where contrato.contnum = int(titulo.titnum).
 find clien of contrato.
 put clien.clinom "-" clien.clicod " "
     contrato.contnum " "
     titulo.titpar " "
     titulo.titvlcob skip.
 assign w001 = w001 + titulo.titvlcob.
 if last-of(titulo.titdtven)
 then do:
 put space(46) "Total de " titdtven " = " w001 format ">>>,>>>,>>9.99"
     skip fill("-",80) format "x(80)" skip.
 assign w01 = w01 + w001
	w001 = 0.
 end.
end.
put skip(2) space(52) "Total Geral = " w01 format ">>>,>>>,>>9.99".
