{admcab.i}

def shared temp-table tt-extrato 
    field rec as recid
    field ord as int
        index ind-1 ord.

def var xx as int.
def var yy as int.
def var vtotal  like titulo.titvlcob.
def var vjuro   like titulo.titvlcob.
def var vacum   like titulo.titvlcob.
def var vdias   as   int.


def var i as int.
def var vclicod     like clien.clicod.
def var vsit as log format "PAGO/ABERTO".

def var varquivo as char.

disp "Gerando extrato... Aguarde!"
    with frame f-av 1 down no-label centered row 12.
pause 0.    
if opsys = "UNIX"
then varquivo = "/admcom/relat/extrato" + string(time) + ".txt".
else varquivo = "l:\relat\extrato" + string(time) + ".txt" .

{mdadmcab.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""extrato2""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """EXTRATO DO CLIENTE""" 
            &Width     = "160"
            &Form      = "frame f-cabcab"}




for each tt-extrato use-index ind-1:
    find clien where recid(clien) = tt-extrato.rec no-lock no-error.
    if not avail clien
    then do:
        message "Cliente nao Cadastrado".
        undo, retry.
    end.
    

    display clien.clicod at 10
             clien.clinom at 10
             clien.ciccgc at 10
             clien.proemp[1]   label "Empresa     "     at 80
             clien.endereco[1] label "Rua         "     at 10 
             clien.protel[1]   label "Telefone    "     at 80
             clien.numero[1]   label "Numero      "     at 10
             clien.proprof[1]  label "Profissao   "     at 80
             clien.compl[1]    label "Compl.      "     at 10 
             clien.prorenda[1] label "Renda mensal"     at 80
             clien.bairro[1]   label "Bairro      "     at 10 
             clien.endereco[2] label "Rua         "     at 80
             clien.cidade[1]   label "Cidade      "     at 10
             clien.numero[2]   label "Numero      "     at 80
             clien.fone        label "Fone        "     at 10
             clien.compl[2]    label "Compl.      "     at 80
             clien.bairro[2]   label "Bairro      "     at 80
             clien.cidade[2]   label "Cidade      "     at 80
                with frame f02 width 200 no-box side-label.
     
                              
    display clien.refnome                            at 10
            clien.conjuge  when clien.estciv = 2 at 80
            clien.endereco[4] label "Rua"        at 10
            clien.proemp[2] label "Empresa"  when clien.estciv = 2 at 80
            clien.numero[4]   label "Numero"         at 10
            clien.protel[2] label "Telefone"  when clien.estciv = 2 at 80

            clien.compl[4]    label "Complemento"    at 10
            clien.proprof[2] label "Profissao" when clien.estciv = 2 at 80

            clien.bairro[4]   label "Bairro"         at 10
            clien.endereco[3] label "Rua" when clien.estciv = 2  at 80

            clien.cidade[4]   label "Cidade"         at 10
            clien.numero[3] label "Numero" when clien.estciv = 2  at 80
            clien.reftel   at 10
            clien.compl[3] label "Complemento" when clien.estciv = 2  at 80
            clien.bairro[3] label "Bairro" when clien.estciv = 2     at 80 
            clien.cidade[3] label "Cidade" when clien.estciv = 2      at 80
                with  width 200 frame fpess side-label. 
    
    
    
    for each titulo use-index iclicod where
                        titulo.clifor     = clien.clicod and
                        titulo.titnat     = no           
                                            no-lock by titulo.titdtven
                                                    by titulo.titnum
                                                    by titulo.titpar.
        if titulo.titsit = "PAG"
        then next.
        vtotal = 0.
        vjuro = 0.
        vdias = 0.

        if titulo.titdtven < today
        then do:
            find tabjur where tabjur.nrdias = today - titulo.titdtven and
                              tabjur.etbcod = 0
                             no-lock no-error.
            if not avail tabjur
            then do:
                message "Fator para" today - titulo.titdtven
                        "dias de atraso, nao cadastrado".
                pause.
                undo.
            end.
            assign vjuro  = (titulo.titvlcob * tabjur.fator) - titulo.titvlcob
                   vtotal = titulo.titvlcob + vjuro
                   vdias  = today - titulo.titdtven.
        end.
        else vtotal = titulo.titvlcob.
        vacum = vacum + vtotal.
        display titulo.etbcod
                titulo.titnum
                titulo.titpar
                titulo.titdtven format "99/99/9999"
                vdias           when vdias > 0 column-label "Atraso"
                titulo.titvlcob column-label "Principal "   (total)
                vjuro           column-label "Juro"         (total)
                vtotal          column-label "Total"        (total)
                space(3)
                vacum           column-label "Acumulador"
                    with frame flin down width 130 no-box.
    end.        
    page.
     
end.
    
output close.

message color red/with
    "Arquivo de extrato gerado: " varquivo
    view-as alert-box.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
{mrod.i}
end.
