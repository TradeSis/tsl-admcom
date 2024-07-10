{admcab.i}

def input parameter par-rec as recid.

def var varquivo as char.
def var v-cel-doa-aux   as logical format "Sim/Nao" no-undo.
def var v-proobs-aux    like asstec.proobs no-undo.
def var v-imei-cel-aux  as character no-undo.
def var vpdf as char no-undo.

find asstec where recid(asstec) = par-rec no-lock.
find estab where estab.etbcod = asstec.etbcod no-lock.

/*if estab.etbnom begins "DREBES-FIL"
then varquivo = "/usr/admcom/porta-relat/os." + string(asstec.oscod) + "." +
                 string(time).
else varquivo = "/admcom/relat/os." + string(asstec.oscod) + "." + string(time).*/

if estab.etbnom begins "DREBES-FIL" then do:
    if setbcod > 0 and setbcod < 10 
    then varquivo = "/admcom/relat-loja/filial00" + string(setbcod) + "/relat/OS-" + string(asstec.oscod) + ".txt".

    if setbcod > 9 and setbcod < 100 
    then varquivo = "/admcom/relat-loja/filial0" + string(setbcod) + "/relat/OS-" + string(asstec.oscod) + ".txt".

    if setbcod > 99 
    then varquivo = "/admcom/relat-loja/filial" + string(setbcod) + "/relat/OS-" + string(asstec.oscod) + ".txt".
end.
else varquivo = "/admcom/relat/os." + string(asstec.oscod) + "." + string(time).

                {mdadmcab.i 
                    &Saida     = "value(varquivo)"
                    &Page-Size = "64"
                    &Cond-Var  = "160"
                    &Page-Line = "66"
                    &Nom-Rel   = ""asstec""
                    &Nom-Sis   = """ASSISTENCIA TECNICA"""
                    &Tit-Rel   = """O.S :  "" + 
                                 string(asstec.oscod,""999999"") +
                                 "" Filial "" + string(estab.etbcod) + "" - "" +
                                               estab.etbnom"
                    &Width     = "160"
                    &Form      = "frame f-cabcab2"}

                disp asstec.etbcod colon 10 label "Filial"
                     asstec.oscod colon 40 label "O.S." 
                     asstec.procod colon 10
                        with frame f-lista side-labels.

                find first produ where produ.procod = asstec.procod 
                            no-lock no-error.
                display produ.pronom no-label format "x(30)" when avail produ
                                with frame f-lista.
                
                find forne where forne.forcod = asstec.forcod  
                                no-lock no-error.
                display asstec.forcod colon 10 label "Cod.Ass."
                        forne.fornom no-label when avail forne
                        forne.forfone         when avail forne.
                
                disp asstec.apaser format "x(15)" colon 10
                     with frame f-lista.
                
                disp asstec.clicod colon 10 label "cliente"
                     with frame f-lista.
               
                find first clien where clien.clicod = asstec.clicod 
                                    no-lock no-error.

                if not avail clien
                then undo,retry.
                else do:
                     if asstec.clicod <> 0
                     then 
                     display clien.clinom no-label 
                             clien.ciinsc colon 10 label "RG" 
                             clien.ciccgc colon 50 label "CPF"
                             clien.endereco[1] colon 10 label "Endereco"
                             clien.numero[1]   colon 60 label "Numero"
                             clien.bairro[1]   colon 10 label "Bairro"
                             clien.cidade[1]   colon 50 label "Cidade"
                             clien.cep[1]      colon 10 label "Cep"
                             " "               colon 10
                             with frame f-lista.
                end. 
                disp asstec.pladat colon 10 label "Data NF"
                     asstec.planum colon 50
                        with frame f-lista.
                        
                if acha("IMEI",asstec.proobs) <> ""
                then do:
                    assign  v-cel-doa-aux = (acha("DOA",asstec.proobs) = "yes").
                    assign v-proobs-aux = replace(asstec.proobs,"|DOA=" + 
                                      trim(string(v-cel-doa-aux,"yes/no")),"").
                    assign
                      v-imei-cel-aux = acha("IMEI",asstec.proobs)
                      v-proobs-aux =
                          replace(v-proobs-aux,"|IMEI=" + v-imei-cel-aux,"").

                      disp v-imei-cel-aux colon 10 label "IMEI Cel."
                                      format "x(20)"
                           v-cel-doa-aux  colon 50 label "DOA"
                                      format "Sim/Nao" with frame f-lista.
                end.
                else v-proobs-aux = asstec.proobs.

                disp v-proobs-aux colon 10 label "Obs.Prod."
                     asstec.defeito colon 10 
                     asstec.nftnum colon 10 label "NF Transf" 
                     asstec.reincid colon 50 
                     asstec.dtentdep colon 25 label "Dt.Entrada Deposito"
                     asstec.dtenvass colon 60 label "Dt.Envio Assistencia"
                     asstec.dtretass colon 25 label "Dt.Retirada Assistencia"
                     asstec.dtenvfil colon 60 label "Dt.Envio para Filial" 
                     asstec.osobs colon 10 label "Obs.OS"
                     with frame f-lista.
output close.

if estab.etbnom begins "DREBES-FIL" then do:
    run pdfout.p (input varquivo,
                      input "/admcom/kbase/pdfout/",
                      input "OS-" + string(asstec.oscod) + ".pdf",
                      input "Portrait",
                      input 8.2,
                      input 1,
                      output vpdf).
    message "Arquivo gerado com sucesso!" /*varquivo*/ view-as alert-box.
end.
else run visurel.p (input varquivo, input "").