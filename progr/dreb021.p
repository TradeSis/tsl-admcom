{admcab.i}
def var vtem as char format "x(20)".
def var vclicod     like clien.clicod.
repeat:
    update vclicod colon 20
           with frame f1 side-label width 80.
    find clien where clien.clicod = vclicod no-lock no-error.
        if not avail clien
        then do:
            message "Cliente nao Cadastrado".
            undo, retry.
        end.
        display clien.clinom with frame f1.

def var v-arquivo as char.

v-arquivo = "/admcom/relat/cliente" + string(clien.clicod) + "." +
        string(time).

{mdadmcab.i
        &Saida     = "value(v-arquivo)"
        &Page-Size = "0"
        &Cond-Var  = "150"
        &Page-Line = "66"
        &Nom-Rel   = ""acr_fin""
        &Nom-Sis   = """SISTEMA DE CREDIARIO"""
        &Tit-Rel   = """ CLIENTE "" + 
                        string(clien.clicod) + "" - "" +
                        clien.clinom "
        &Width     = "110"
        &Form      = "frame f-cabcab"}


vtem = substring(string(clien.temres,"999999"),1,2) + "/" +
        substring(string(clien.temres,"999999"),3,4) + "(Mes/Ano)".




if clien.tippes
then do:
    display "                                  DADOS PESSOAIS    "
            clien.clicod at 10
            clien.clinom
            clien.ciinsc label "Identidade" at 10
            clien.ciccgc
            clien.pai     at 10
            clien.mae     at 10
            clien.sexo    at 10
            clien.estciv   
            clien.dtnasc  format "99/99/9999"
            clien.numdep  at 10
            clien.dtcad   at 10 format "99/99/9999"
                    with frame f2 width 80 no-box side-label.
    put skip(02).
    display "                      DADOS RESIDENCIAIS    "
            clien.endereco[1] label "Rua"  AT 10
            clien.numero[1] label "Numero"
            clien.compl[1] label "Complemento" at 10
            clien.bairro[1] label "Bairro"      at 10
            clien.cidade[1] label "Cidade"
            clien.ufecod[1] label "Estado"   at 10
            clien.cep[1] label "CEP"
            clien.fone       at 10
            clien.tipres
            clien.vlalug     at 10
            vtem label "tempo Res."
                    with frame f02 width 80 no-box side-label.
end.
else
    display
           clien.nacion at 10
           clien.ciins label "Insc.Estadual" format "x(11)"
           clien.ciccgc
            with frame f3 width 80 no-box side-label.
            put skip(1).
if clien.tippes
then
    disp  "                 INFORMACOES PROFISSIONAIS"
           clien.proemp[1]   label "Empresa"         at 10
           clien.protel[1]   label "Telefone"        at 10
           clien.prodta[1]   label "Data Admissao"   at 10  format "99/99/9999"
           clien.proprof[1]  label "Profissao"      at 10
           clien.prorenda[1] label "Renda mensal"  at 10
           clien.endereco[2] label "Rua"           at 10
           clien.numero[2] label "Numero"
           clien.compl[2]  label "Complemento"      at 10
           clien.bairro[2] label "Bairro"
           clien.cidade[2] label "Cidade" at 10
           clien.ufecod[2] label "Estado"
                    with width 80 frame finfpro no-box side-label.

if /*clien.estciv = 2 and*/ clien.tippes
then
    display clien.conjuge at 10
           clien.nascon at 10 format "99/99/9999"
           clien.proemp[2] label "Empresa"      at 10
           clien.protel[2] label "Telefone"
           clien.prodta[2] label "Data Admissao"  at 10 format "99/99/9999"
           clien.proprof[2] label "Profissao"
           clien.prorenda[2] label "Renda mensal"  at 10
           clien.endereco[3] label "Rua"           at 10
           clien.numero[3] label "Numero"
           clien.compl[3] label "Complemento"    at 10
           clien.bairro[3] label "Bairro"           at 10
           clien.cidade[3] label "Cidade"           at 10
           clien.ufecod[3] label "Estado"
           clien.cep[3] label "CEP"
           with width 80 frame fconj
                title "       INFORMACOES DO CONJUGE" side-label.
put skip(1).
display clien.refcom[1] label "Ref.Comercial" colon 25
       clien.refcom[2] no-label  colon 27
       clien.refcom[3] no-label  colon 27
       clien.refcom[4] no-label  colon 27
       clien.refcom[5] no-label  colon 27
       with width 80 side-label
            frame f4  no-box.


disp   clien.autoriza[1]   no-label format "x(70)"
       clien.autoriza[2]   no-label format "x(70)"
       clien.autoriza[3]   no-label format "x(70)"
       clien.autoriza[4]   no-label format "x(70)"
       clien.autoriza[5]   no-label format "x(70)"
       with width 80 side-label frame f5 title " Observacoes ".
display clien.refnome
       clien.endereco[4] label "Rua"
       clien.numero[4] label "Numero"
       clien.compl[4] label "Complemento"
       clien.bairro[4] label "Bairro"
       clien.cidade[4] label "Cidade"
       clien.ufecod[4] label "Estado"
       clien.cep[4] label "CEP"
       clien.reftel
       with 1 column width 80 frame fpess no-box.



    output close.

    run visurel.p(v-arquivo, "").
    
end.
