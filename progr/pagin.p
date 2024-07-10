{admcab.i }
 define variable wtitvlcob like titulo.titvlcob.
define variable wtitdtven like titulo.titdtven.
define variable wpar like titulo.titpar.
define variable wpar1 like titulo.titpar.
define variable wcon like contrato.contnum.
define variable rsp as logical format "Sim/Nao" initial yes.
define variable wenc as logical.
repeat:
 do with 1 column width 80 frame f1 title " Cliente ":
 prompt-for clien.clicod.
 find clien using clien.clicod.
 display clien.clinom.
 end.
 do with 1 column width 39 frame f2 title " titulo ":
  prompt-for contrato.contnum.
  find contrato where contnum = input contrato.contnum no-error.
  if not available contrato
   then do:
   message "Contrato inexistente, tente novamente.".
   undo,retry.
   end.
  if contrato.clicod <> clien.clicod
   then do:
   message "Este Contrato nao pertence a este Cliente.".
   undo,retry.
   end.
  if contrato.situacao = 0
   then do:
   message "Contrato ja encerrado, pagamento impossivel.".
   undo,retry.
   end.
   else do:
   if contrato.situacao = 9
    then assign wpar = 0.
    else do:
        find first titulo where
            titulo.etbcod = contrato.etbcod and
            titulo.titnum = string(contrato.contnum) and
            titulo.empcod = wempre.empcod and
            titulo.clifor = contrato.clicod and
            titulo.titnat = no and
            titulo.modcod = "CRE" no-error.
        if not avail titulo
        then do:
            message "Titulo nao Achado".
            undo.
        end.
        assign wpar = titulo.titpar.
    end.
   end.
  if wpar = 0
   then display skip(1) wpar.
   else do:
   update skip(1) wpar.
   if wpar <> titulo.titpar
   then do:
    find titulo  where
    titulo.titnum = string(contrato.contnum) and
    titulo.empcod = wempre.empcod and
    titulo.titnat = no and
    titulo.modcod = "CRE" and
    titulo.titpar = wpar no-error.
    if not available titulo
     then do:
     message "titulo nao encontrada neste Contrato, tente novamente.".
     undo,retry.
     end.
    end.
   end.
  if wpar <> 0
   then do with 1 column width 39 frame f3:
   display titdtven.
   assign titdtpag = today.
   update titdtpag.
   end.
   else do with 1 column width 39 frame f4:
   assign wtitdtven = contrato.dtinicial.
   display contrato.dtinicial label "Dt.Vencim." skip (1) wtitdtven
           label "Dt.Pagamento".
   end.
 end.
 if wpar <> 0
  then do with 1 column width 40 column 41 frame f5 title " Pagamento ":
  display titvlcob skip(1).
  if titdtpag > titdtven
   then do:
   update titvljur
          titdesc.
   end.
   else update titvljur
               titdesc.
  end.
  else do with 1 column width 40 column 41 frame f6 title " Pagamento ":
  display skip(1) space(10) "ENTRADA" skip(1) contrato.vlentra
          label "Valor Entrada" skip(1).
  end.
 if wpar <> 0
  then do with 1 column width 40 column 41 frame f7:
  assign titvlpag = titvlcob + titvljur - titdesc.
  update titvlpag.
  end.
  else display contrato.vlentra label "Valor Pago" with 1 column width 40
               column 41 frame f8.
 assign rsp = yes.
 message "Confirme o pagamento ? " update rsp.
 if not rsp
  then do:
  message "Pagamento nao efetuado.".
  undo,retry.
  end.
 if wpar <> 0 and titvlpag < titvlcob + titvljur - titdesc
  then do:
  assign rsp = no.
  message "Confirma pagamento  P A R C I A L  ? " update rsp.
  if rsp
   then do:
   assign wtitvlcob = titvlcob
          wtitdtven = titdtven
          wcon = int(titulo.titnum)
          titvlcob = titvlpag - titvljur + titdesc
          wtitvlcob = wtitvlcob - titvlcob.
   find last titulo where titulo.titnum = string(wcon).
   assign wpar1 = titulo.titpar + 1.
   create titulo.
   assign titulo.titpar = wpar1
          titulo.titnum = string(wcon)
          titulo.titvlcob = wtitvlcob
          titulo.titdtven = wtitdtven.
   end.
   else do:
   message "Pagamento nao efetuado.".
   undo,retry.
   end.
  end.
 if wpar = 0
  then do:
  assign contrato.situacao = 1.
 for each titulo  where
    titulo.titnum = string(contrato.contnum) and
    titulo.empcod = wempre.empcod and
    titulo.titnat = no and
    titulo.modcod = "CRE":
   assign titulo.titsit = "PAG".
  end.
  end.
 assign wenc = no.
 for each titulo  where
    titulo.titnum = string(contrato.contnum) and
    titulo.empcod = wempre.empcod and
    titulo.titnat = no and
    titulo.modcod = "CRE":
  assign wenc = yes.
 end.
 if not wenc
  then assign contrato.situacao = 0.
 message "Pagamento efetuado.".
end.
