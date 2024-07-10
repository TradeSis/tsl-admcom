{admcab.i}

def var vpdf as char no-undo.

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

{mdadmcab.i
    &Saida     = "/admcom/relat/extra03"
    &Page-Size = "0"
    &Cond-Var  = "137"
    &Page-Line = "66"
    &Nom-Rel   = """extrato3"""
    &Nom-Sis   = """SISTEMA CREDIARIO"""
    &Tit-Rel   = """EXTRATO DE CLIENTE"""
    &Width     = "137"
    &Form      = "frame f-cab"}





for each tt-extrato use-index ind-1:
    find clien where recid(clien) = tt-extrato.rec no-lock no-error.
    if not avail clien
    then next.
    

    display clien.clicod at 10
             clien.clinom at 10
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
             clien.fax         label "Celular     "     at 10
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
            find fin.tabjur where fin.tabjur.nrdias = 
                                    today - titulo.titdtven
                                             no-lock no-error.
            if not avail fin.tabjur
            then do:
                message "Fator para" today - titulo.titdtven
                        "dias de atraso, nao cadastrado".
                pause.
                undo.
            end.
            assign vjuro  = 
                    (titulo.titvlcob * fin.tabjur.fator) - 
                     titulo.titvlcob
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
    
    display
      skip
      "<page>"
      with frame fsep down width 250 no-box.
    
    /* comentado a pedido do usuario
    page. */
     
end.
    
output close.

run pdfout.p (input "/admcom/relat/extra03",
              input "/admcom/kbase/pdfout/",
              input "extrato3-" + string(time) + ".pdf",
              input "Portrait",
              input 7.0,
              input 1,
              output vpdf).
    
message ("Arquivo " + vpdf + " gerado com sucesso!").
    

/* substituido pela geracao de PDF
os-command silent /fiscal/lp /admcom/relat/extra03. */



