def input  parameter vrecid  as recid.
def input  parameter vdtcad-aux as date format "99/99/9999".


def var vclicod like clien.clicod.
def buffer bclien for clien.

find clien where recid(clien) = vrecid .

if clien.tippes
then
    display clien.sexo
           clien.estciv
           clien.nacion
           clien.natur
           clien.dtnasc format "99/99/9999"
           clien.ciins label "Identidade"
           clien.ciccgc
           clien.pai
           clien.mae
           clien.numdep
           clien.zona label "E-mail" format "x(40)" 
           with 2 column frame f2 width 80 row 9.
else
    display clien.nacion
           clien.ciins label "Insc.Estadual" format "x(11)"
           clien.ciccgc
           with 1 column frame f3 width 80 .

display clien.endereco[1] label "Rua"
       clien.numero[1] label "Numero"
       clien.compl[1] label "Complemento"
       clien.bairro[1] label "Bairro"
       clien.cidade[1] label "Cidade"
       clien.ufecod[1] label "Estado"
       clien.cep[1] label "CEP"
       clien.fone
       clien.fax label "Celular" 
       clien.tipres
       /* clien.vlalug */ 
       trim(substring(string(clien.temres,"999999"),1,2) + "/" + 
            substring(string(clien.temres,"999999"),3,4)) format "x(15)"
                        label "Temp.Res."
       vdtcad-aux label "Data Cadastro" format "99/99/9999"
       with 1 column width 80 frame fres
            title " Informacoes Residenciais ".


if clien.tippes
then
    display clien.proemp[1] label "Empresa"
           clien.protel[1] label "Telefone"
           clien.prodta[1] label "Data Admissao" format "99/99/9999"
           clien.proprof[1] label "Profissao"
           clien.prorenda[1] label "Renda mensal"
           clien.endereco[2] label "Rua"
           clien.numero[2] label "Numero"
           clien.compl[2] label "Complemento"
           clien.bairro[2] label "Bairro"
           clien.cidade[2] label "Cidade"
           clien.ufecod[2] label "Estado"
           clien.cep[2] label "CEP"
           with 1 column width 80 frame finfpro
                title " Informacoes Profissionais ".

if clien.estciv = 2 and clien.tippes
then
    display clien.conjuge
           clien.nascon
           clien.conjpai
           clien.conjmae
           clien.proemp[2] label "Empresa"
           clien.protel[2] label "Telefone"
           clien.prodta[2] label "Data Admissao" format "99/99/9999"
           clien.proprof[2] label "Profissao"
           clien.prorenda[2] label "Renda mensal"
           clien.endereco[3] label "Rua"
           clien.numero[3] label "Numero"
           clien.compl[3] label "Complemento"
           clien.bairro[3] label "Bairro"
           clien.cidade[3] label "Cidade"
           clien.ufecod[3] label "Estado"
           clien.cep[3] label "CEP"
           with 2 column width 80 frame fconj
                title " Informacoes do Conjuge ".

display clien.refcom[1] label "Ref.Comercial" colon 16
       clien.refcom[2] no-label  colon 18
       clien.refcom[3] no-label  colon 18
       clien.refcom[4] no-label  colon 18
       clien.refcom[5] no-label  colon 18
       with width 80 side-label
            frame f4 title " Referencias Comerciais ".

find carro where carro.clicod = clien.clicod no-lock no-error.
if avail carro
then display carro.marca
             carro.modelo
             carro.ano with frame fcarro side-label 1 column centered
                            title "C A R R O".
    


disp   clien.autoriza[1]   colon 5 no-label format "x(70)"
       clien.autoriza[2]   colon 5 no-label format "x(70)"
       clien.autoriza[3]   colon 5 no-label format "x(70)"
       clien.autoriza[4]   colon 5 no-label format "x(70)"
       clien.autoriza[5]   colon 5 no-label format "x(70)"
       with width 80 side-label frame f5 title " Observacoes ".

/*****/
display clien.refnome
       clien.endereco[4] label "Rua"
       clien.numero[4] label "Numero"
       clien.compl[4] label "Complemento"
       clien.bairro[4] label "Bairro"
       clien.cidade[4] label "Cidade"
       clien.ufecod[4] label "Estado"
       clien.cep[4] label "CEP"
       clien.reftel
       with 1 column width 80 frame fpess
            title " *** Referencia Pessoal - Antigo *** " .
/******/


/********/

    display skip(1)
           clien.entbairro[1] label "1) Nome..........." format "x(50)" skip
           clien.entcep[1]    label "1) Fone Comercial." format "x(50)" skip
           clien.entcidade[1] label "1) Celular........" format "x(50)" skip
           clien.entcompl[1]  label "1) Parentesco....." format "x(50)" skip(1)
           clien.entbairro[2] label "2) Nome..........." format "x(50)" skip
           clien.entcep[2]    label "2) Fone Comercial." format "x(50)" skip
           clien.entcidade[2] label "2) Celular........" format "x(50)" skip
           clien.entcompl[2]  label "2) Parentesco....." format "x(50)" skip(1)
           clien.entbairro[3] label "3) Nome..........." format "x(50)" skip
           clien.entcep[3]    label "3) Fone Comercial." format "x(50)" skip
           clien.entcidade[3] label "3) Celular........" format "x(50)" skip
           clien.entcompl[3]  label "3) Parentesco....." format "x(50)" skip(1)
           with width 80 frame fpess2 side-labels
            title " Referencias Pessoais "  color white/cyan.

    display clien.entendereco[1] format "x(78)" skip
           clien.entendereco[2] format "x(78)" skip
           clien.entendereco[3] format "x(78)" skip
           clien.entendereco[4] format "x(78)" skip
           with frame fpess3 no-labels width 80
                color white/cyan title " Documentos Apresentados ".

    display clien.entrefcom[1] label "Data" format "99/99/9999" skip
           clien.entrefcom[2] label " OBS" format "x(72)" skip space(6)
           clien.entrefcom[3] no-label format "x(72)" skip space(6)
           clien.entrefcom[4] no-label format "x(72)" skip space(6)
           clien.entrefcom[5] no-label format "x(72)"
           with frame fpess4 side-labels width 80
                       color white/cyan title "  S P C  ".

/********/

            
