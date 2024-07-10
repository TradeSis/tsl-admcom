{admcab.i new}

def var vdtini as date format "99/99/9999" init today.
def var vdtfim as date format "99/99/9999" init today.
def var vetbcod like estab.etbcod format ">>9".
def var vope as char.
def var varquivo as char.
def var vpdf as char.
def var vfilial as char.

vetbcod = setbcod.
vetbcod = 13.

find estab where estab.etbcod = vetbcod no-lock no-error.
if not avail estab
then do:
  message "Estabelecimento nao Cadastrado".
  undo.
end.
else disp vetbcod no-label estab.etbnom no-label with frame f02 centered title "Filial".

update vdtini label "Periodo"
       vdtfim no-label
with frame f01 centered side-label.

if vetbcod < 10 then vfilial = "00" + string(vetbcod).
if vetbcod > 10 and vetbcod < 100 then vfilial = "0" + string(vetbcod).

if opsys = "UNIX"
then varquivo = "/admcom/relat-loja/filial" + vfilial + "/relat/relhabil-ret-" + replace(string(today),'/','').
else varquivo = "l:\relat-loja\filial" + vfilial + "/relat/relhabil-ret-" + replace(string(today),'/','').

output to value(varquivo).

/*message "HABILITACOES DA FILIAL " + string(vetbcod) +  " DE " + string(vdtini) + " A " + string(vdtfim).*/
disp "HABILITACOES DA FILIAL" vetbcod no-label "DE" vdtini no-label "A" vdtfim no-label.

for each habil use-index ihabdat where habil.etbcod = vetbcod and habil.habdat >= vdtini and habil.habdat <= vdtfim no-lock:
  find func where func.funcod = habil.vencod and func.etbcod = vetbcod no-lock no-error.

  if habil.gercod = 1 then vope = "Habilitacao".
  if habil.gercod = 2 then vope = "Migracao".
  if habil.gercod = 3 then vope = "Cancelada".

  disp 
    habil.vencod column-label "Vendedor"
    func.funnom when avail func column-label "Vendedor"
    vope column-label "Operacao"
    habil.celular column-label "Celular"
    habil.ciccgc  column-label "CPF"
    habil.habdat column-label "Data"
    habil.codviv format ">>>9" column-label "Plano"
  with width 200.
end. /* habil */

output close.

run pdfout.p (input varquivo,
input "/admcom/kbase/pdfout/",
input "relhabil-ret-" + string(time) + ".pdf",
input "Portrait",
input 8.0,
input 1,
output vpdf).

message ("Arquivo " + vpdf + " gerado com sucesso!") 
view-as alert-box.