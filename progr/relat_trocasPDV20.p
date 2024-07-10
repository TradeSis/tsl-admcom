{admcab.i new}

def var data_ini as date.
def var data_fim as date.

def var totPlani as dec.

def var vetbcod like estab.etbcod.
def var operacao like pdvmov.ctmcod.
def var totDevol as dec.
assign operacao = "81".  /* 27 troca - 81 devolucao */
       .

def new shared frame f-cmon.
form cmon.etbcod    label "Etb" format ">>9"
     CMon.cxacod    label "PDV" format ">>9"
     data_ini       colon 50 format "99/99/9999" label "Dt Ini"
     data_fim       format "99/99/9999" label "Data"
     with frame f-CMon row 3 width 81
                     side-labels no-box.


disp  setbcod @ cmon.etbcod
           20 @ cmon.cxacod
        today @ data_ini
        today @ data_fim
        with frame f-cmon.

prompt-for cmon.etbcod /*when estab.etbcat <> "LOJA"*/
           data_ini
           data_fim
    with frame f-cmon.


data_ini = input frame f-cmon data_ini.
data_fim = input frame f-cmon data_fim.

find first cmon where
            cmon.etbcod = input frame f-cmon cmon.etbcod and
            cmon.cmtcod = "PDV" and
            cmon.cxacod = input frame f-cmon cmon.cxacod
                            no-lock no-error.
if not avail cmon and
    input frame f-cmon cmon.cxacod <> 0
then do:
    message "Loja nao Possui Devolucao".
    undo.
end.


find first pdvmov where pdvmov.etbcod = cmon.etbcod and
                      pdvmov.cmocod = cmon.cmocod and
                      pdvmov.datamov >= data_ini and
                      pdvmov.datamov <= data_fim and
                      pdvmov.ctmcod = operacao
                      no-lock no-error.
if not avail pdvmov and
    input frame f-cmon cmon.cxacod <> 0
then do:
    message "Loja nao Possui Devolucao para este periodo".
    undo.
end.
/*disp pdvmov.*/

def var varquivo as char.


vetbcod = setbcod.
if opsys = "UNIX"
then varquivo = "../relat/devolpdv20" + string(vetbcod,"999") +
                "." + string(time).
else varquivo = "l:~\relat~\devolpdv20" + string(vetbcod,"999").

output to varquivo.

{mdadmcab.i
  &Saida     = "value(varquivo)"
  &Page-Size = "64"
  &Cond-Var  = "100"
  &Page-Line = "66"
  &Nom-Rel   = ""devolpdv20""
  &Nom-Sis   = """CONTROLE DE DEVOLUCOES"""
  &Tit-Rel   = """ DEVOLUCOES DO CAIXA ADMCOM REALIZADAS PELA RETAGUARDA """
  &Width     = "100"
  &Form      = "frame f-cabcab"}

for each pdvmov where pdvmov.etbcod = cmon.etbcod and
                      pdvmov.cmocod = cmon.cmocod and
                      pdvmov.datamov >= data_ini and
                      pdvmov.datamov <= data_fim and
                      pdvmov.ctmcod = operacao
                      no-lock:


      find first pdvdoc of pdvmov where pdvdoc.seqreg = 1 no-lock no-error.
      if avail pdvdoc then do:
        /*disp pdvdoc with 3 columns.*/

        find first plani where plani.etbcod = pdvdoc.orig_loja and
                               plani.pladat = pdvdoc.orig_data and
                               plani.numero = pdvdoc.numero_nfe and
                               plani.serie = pdvdoc.serie_nfe no-lock no-error.
        if avail plani then do:
          totPlani = plani.platot.

          find first contnf where contnf.placod = plani.placod and
                                  contnf.etbcod = plani.etbcod no-lock no-error.
          if avail contnf then do:
              for each titulo where titnat = no and titnum = string(contnf.contnum) and
                                    titsit = "PAG" and clifor = plani.desti and
                                    titulo.titdtpag <> pdvdoc.datamov no-lock:

                  totDevol = totDevol + titvlpag.

              end.
          end.
          else do:

            find first titulo where titnat = no and
                                    titnum = plani.serie + string(plani.numero) and
                                    titulo.etbcod = plani.etbcod and
                                    titdtpag = plani.pladat and
                                    titsit = "PAG" no-lock no-error.
            if avail titulo then do:
              totDevol = titvlpag.
            end.
            /*
            else do:
              totDevol = plani.platot.
            end.
            */
          end.

          disp
            pdvdoc.datamov label "Dt Devol "
            pdvdoc.etbcod label "Lj Devol" format ">>>>9"
            /*plani.desti label "Cliente" format ">>>>>>>>>>>>>9"*/
            pdvdoc.orig_loja label "Lj Orig" format ">>>>9"
            pdvdoc.numero_nfe label "NF Venda" format ">>>>>>>>9"
            plani.serie label "Ser"
            totPlani label "Vl Venda"
            pdvdoc.valor label "Vl Devol"
            totDevol label "Dinheiro Devol".
        end.

      end.

      totPlani = 0.
      totDevol = 0.
end.


disp "". pause 0.
output close.
if opsys = "UNIX"
then run visurel.p (input varquivo, input "").
else do:
    {mrod.i}
end.


undo.
