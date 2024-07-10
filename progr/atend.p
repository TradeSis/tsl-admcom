{ADMcab.i}
repeat with 1 column frame f1 width 80 title " Informacoes Pessoais ":
 prompt-for clien.clicod.
 find clien using clien.clicod.
 display clinom
	 tippes.
 if tippes then do:
  display estciv nacion natur dtnasc ciins label "Identidade"
	  ciccgc mae numdep with 1 column frame f2 width 80.
 end.
 else do:
  display nacion ciins label "Insc.Estadual" format "x(11)"
	  ciccgc with 1 column frame f3 width 80.
 end.
 pause.
 hide frame f1.
 hide frame f2.
 hide frame f3.
 repeat with 1 column width 80 frame f4 title " Informacoes Residenciais ":
  display endereco[1] label "Rua" numero[1] label "Numero"
	  compl[1] label "Complemento" bairro[1] label "Bairro"
	  cidade[1] label "Cidade" ufecod[1] label "Estado"
	  tipres vlalug temres.
  if tippes then pause.
  hide frame f4.
  repeat with 1 column width 80 frame f5 title " Informacoes Profissionais ":
   if tippes then do:
    display proemp[1] label "Empresa" protel[1] label "Telefone"
	    prodta[1] label "Data Admissao" proprof[1] label "Profissao"
	    prorenda[1] label "Renda mensal".
   end.
   repeat with 1 column width 80 frame f6 title " Informacoes do Conjuge ":
    if estciv = 2 and tippes then do:
     display conjuge conjpai conjmae proemp[2] label "Empresa"
	     protel[2] label "Telefone"
	     prodta[2] label "Data Admissao" proprof[2] label "Profissao"
	     prorenda[2] label "Renda mensal".
    end.
    pause.
    hide frame f5.
    hide frame f6.
    repeat with 1 column width 80 frame f7 title " Referencias Comerciais ":
     display refcom label "Ref.Comercial".
     repeat with 1 column width 80 frame f8 title " Autorizados ":
      display autoriza.
      pause.
      hide frame f7.
      hide frame f8.
      repeat with 1 column width 80 frame f9 title " Referencia Pessoal ":
       display refnome
	       endereco[4] label "Rua" numero[4] label "Numero"
	       compl[4] label "Complemento" bairro[4] label "Bairro"
	       cidade[4] label "Cidade" ufecod[4] label "Estado"
	       cep[4] label "CEP" reftel.
       pause.
       hide frame f9.
       repeat with 1 column 1 down width 80 frame f10
	      title " Informacoes de Controle ":
	display classe limite medatr dtcad situacao dtspc.
	pause.
	hide frame f10.
	leave.
       end.
       leave.
      end.
      leave.
     end.
     leave.
    end.
    leave.
   end.
   leave.
  end.
  leave.
 end.
 define variable w01 like contrato.vltotal.
 define variable w02 like contrato.vltotal.
 define variable w03 like contrato.vltotal.
 define variable w001 like contrato.vltotal.
 define variable w002 like contrato.vltotal.
 define variable w003 like contrato.vltotal.
 repeat:
  display clinom with 1 column width 80 title " Posicao Analitica ".
  assign w001 = 0
	 w002 = 0
	 w003 = 0.
  for each contrato of clien where situacao <> 9:
   assign w01 = 0
	  w02 = 0
	  w03 = 0.
   for each titulo where titulo.titnum = string(contrato.contnum) and
			 titulo.titnat = no and
			 titulo.modcod = "CRE" and
			 titulo.empcod = wempre.empcod
    with width 80 7 down frame f11 no-box:
    if titulo.titpar = 1
    then display space(1) contnum label "Cont." dtinicial label "Dt.Inic.".
    display titulo.titpar label "Pc"
	    titulo.titdtven label "Dt.Venc."
	    titulo.titvlcob label "Valor Parc."
	    titulo.titvlpag label "Valor Pago".
    if titulo.titsit <> "PAG"
     then do:
     assign w02 = w02 + titulo.titvlcob
	    w03 = titulo.titvlcob.
     display w03 format ">>>,>>>,>>9.99" label "Saldo Deve.".
     end.
    w01 = w01 + titulo.titvlpag.
   end.
   assign w001 = w001 + vltotal - vlentra
	  w002 = w002 + w01
	  w003 = w003 + w02.
   display space(11) "Total Parcial =" contrato.vltotal - contrato.vlentra
	   format ">>>,>>>,>>9.99" w01 w02
	   with width 80 1 down no-labels frame f12.
  end.
  display space(13)  "Total Geral =" w001 format ">>>,>>>,>>9.99"
	  w002 w003 with width 80 1 down no-labels frame f13.
  pause.
  leave.
 end.
end.
