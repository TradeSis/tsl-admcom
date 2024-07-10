{admcab.i}

def var vtotal  like titulo.titvlcob.
def var vjuro   like titulo.titvlcob.
def var vacum   like titulo.titvlcob.
def var vdias   as   int.


def var i as int.
def var vtem as char format "x(20)".
def var vclicod     like clien.clicod.
def var vsit as log format "PAGO/ABERTO".
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


    {mdadmcab.i
            &Saida     = "i:\admcom\relat\cli" 
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""dreb024""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """INFORMACOES DO CLIENTE  : "" +
                                  string(clien.clicod,""99999999"") "
            &Width     = "160"
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
            clien.dtnasc
            clien.numdep
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
           clien.prodta[1]   label "Data Admissao"   at 10
           clien.proprof[1]  label "Profissao"      at 10
           clien.prorenda[1] label "Renda mensal"  at 10
           clien.endereco[2] label "Rua"           at 10
           clien.numero[2] label "Numero"
           clien.compl[2]  label "Complemento"      at 10
           clien.bairro[2] label "Bairro"
           clien.cidade[2] label "Cidade" at 10
           clien.ufecod[2] label "Estado"
                    with width 80 frame finfpro no-box side-label.

if clien.estciv = 2 and clien.tippes
then
    display clien.conjuge at 10
           clien.nascon at 10
           clien.proemp[2] label "Empresa"      at 10
           clien.protel[2] label "Telefone"
           clien.prodta[2] label "Data Admissao"  at 10
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
                title "              INFORMACOES DO CONJUGE" side-label.
put skip(1).
display clien.refcom[1] label "Ref.Comercial" colon 16
       clien.refcom[2] no-label  colon 18
       clien.refcom[3] no-label  colon 18
       clien.refcom[4] no-label  colon 18
       clien.refcom[5] no-label  colon 18
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
       i = 0.
       for each contrato where contrato.clicod = clien.clicod 
                                                    by contrato.dtinicial
                                                    by contrato.vltotal.
            vsit = yes.
            for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = no and
                                  titulo.modcod = "CRE" and
                                  titulo.etbcod = contrato.etbcod and
                                  titulo.clifor = clien.clicod    and
                                  titulo.titnum = string(contrato.contnum)
                                        no-lock.
                if titulo.titsit = "LIB"
                then vsit = no.
            end.
            
            i = i + 1.
            if i >= 6 and vsit
            then next.

            disp contrato.etbcod
                 contrato.contnum
                 contrato.dtinicial format "99/99/9999"
                 contrato.vltotal(total) 
                 contrato.vlentra(total) 
                 vsit no-label
                 with frame f-contrato down width 200.
       end.
       for each titulo use-index iclicod where titulo.clifor = clien.clicod and
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
                find tabjur where tabjur.nrdias = today - titulo.titdtven
                                 no-lock no-error.
                if  not avail tabjur
                then do:
                    message "Fator para" today - titulo.titdtven
                            "dias de atraso, nao cadastrado".
                    pause.
                    undo.
                end.
                assign vjuro  = (titulo.titvlcob * tabjur.fator) - 
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
                            with frame flin down width 200.
       end.       
       
       
    output close.
    dos silent type i:\admcom\relat\cli > prn.
end.
