{admcab.i}
def var vlog as log.
def var vnov as log init no.
define variable wcon like contrato.contnum format ">>>>>>>>>9".
l0:
repeat with frame f1:
 assign wcon = 0.
 do with /*1 column*/ width 80 frame f1 title " Contrato " side-label:
  update wcon colon 15.
  find contrato where contrato.contnum = wcon
       use-index iconcon no-lock no-error.
  if not available contrato
   then do:
   message "Contrato nao cadastrado".
   undo,retry.
   end.
  display contrato.clicod colon 15.
  find clien of contrato no-lock no-error.
  display clien.clinom no-label when avail clien.
  display contrato.dtinicial format "99/99/9999" colon 15
          contrato.etbcod colon 45
          contrato.banco  colon 15
          contrato.modcod colon 45.
 end.
do with side-label width 31 frame f2 title " Valores ":
    display
        vltotal label "Vlr Total" skip(1)
        contrato.vlentra label "Vlr Entrada" skip(1)
        contrato.vltotal - contrato.vlentra
         label "Vlr liquido" format ">>>,>>>,>>9.99" skip(1)
        contrato.vlseguro  skip(1)
        contrato.vliof
        contrato.cet skip(1)
        contrato.txjuros.
end.
 vnov = no.
 for each titulo where titulo.empcod = 19 and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titnat = no and
                       titulo.clifor = contrato.clicod and
                       titulo.modcod = contrato.modcod and
                       titulo.etbcod = contrato.etbcod no-lock
     with column 32 width 48 frame f3 /*5*/ 9 down title " Parcelas ":

  display titulo.etbcod     column-label "Etb"
          titulo.etbcobra   column-label "Cob"
          titulo.titpar
          titulo.titsit
          if titulo.titdtpag <> ?
          then titulo.titdtpag
          else titulo.titdtven  @ titulo.titdtpag column-label "Vecto/Pagto"
          if titulo.titdtpag <> ?
          then titulo.titvlpag
          else titulo.titvlcob @ titulo.titvlcob column-label "Valor"
                            format ">,>>>,>>9.99"
          titulo.tpcontrato.
    if titulo.tpcontrato <> "" /*titpar > 30*/
    then vnov = yes.
 end.
 sresp = no.
 vlog = no.

 if vlog = no
then do:
    message "Consultar Notas Fiscais Associadas ?" update sresp.
    if sresp
    then
        for each contnf where contnf.contnum = contrato.contnum AND
                              contnf.etbcod  = contrato.etbcod no-lock
                                                with frame fnota overlay
                                                    centered row 15 3 down
                                                    color white/cyan.
            find first plani where plani.placod = contnf.placod and
                                   plani.etbcod = contnf.etbcod
                                        no-lock no-error.
            if avail plani
            then display plani.numero
                         plani.serie.
        end.
end.
if vnov  /*novação*/
then do:
    find first tit_novacao where
               tit_novacao.ger_contnum = contrato.contnum and
               tit_novacao.etbnova = contrato.etbcod
                                      no-lock no-error.
    if avail tit_novacao 
    then do:
        sresp = no.
        message "Consultar parcelas renegociadas?" update sresp.
        if sresp
        then do:
            for each tit_novacao where
                     tit_novacao.ger_contnum = contrato.contnum and
                     tit_novacao.etbnova = contrato.etbcod
                     no-lock:
                disp tit_novacao.ori_etbcod  column-label "Fil"
                     tit_novacao.ori_titnum   column-label "Titulo"
                     tit_novacao.ori_titpar   column-label "Par"
                     tit_novacao.ori_titdtemi column-label "Emissao"
                     tit_novacao.ori_titdtven column-label "Vencimento"
                     tit_novacao.ori_titvlcob column-label "Val.Orig"
                     with frame f-titn down centered
                     title " parcelas renegociadas ".
            end.         
        end.
    end.
end.
message "Consulta de Contrato encerrada.".
end.

