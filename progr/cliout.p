def input  parameter vrecid  as recid.
def var vcarro like carro.carsit.
def var vclicod like clien.clicod.
def buffer bclien for clien.

find clien where recid(clien) = vrecid .

if clien.tippes
then do:
    assign
        clien.nacion = "BRASILEIRA"
        clien.natur  = "RS".
    update clien.sexo
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
end.
else
    update clien.nacion
           clien.ciins label "Insc.Estadual" format "x(11)"
           clien.ciccgc
           with 1 column frame f3 width 80 .
update clien.endereco[1] label "Rua"
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
       clien.temres format "999999"
       with 1 column width 80 frame fres
            title " Informacoes Residenciais ".

if clien.tippes
then
    update clien.proemp[1] label "Empresa"
           clien.protel[1] label "Telefone"
           clien.prodta[1] label "Data Admissao"
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
    update clien.conjuge
           clien.nascon
           clien.conjpai
           clien.conjmae
           clien.proemp[2] label "Empresa"
           clien.protel[2] label "Telefone"
           clien.prodta[2] label "Data Admissao"
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

update clien.refcom[1] label "Ref.Comercial" colon 16
       clien.refcom[2] no-label  colon 18
       clien.refcom[3] no-label  colon 18
       clien.refcom[4] no-label  colon 18
       clien.refcom[5] no-label  colon 18
       with width 80 side-label
            frame f4 title " Referencias Comerciais ".
            
find carro where carro.clicod = clien.clicod no-lock no-error.            
if avail carro and carro.carsit = yes
then vcarro = yes.
else vcarro = no.

update vcarro label "Possui Carro" 
        with frame fcarro side-label title "C A R R O" 1 column centered.
        
if vcarro = yes
then do:
    find carro where carro.clicod = clien.clicod no-error.
    if not avail carro
    then do:
        create carro.
        assign carro.clicod = clien.clicod
               carro.carsit = yes
               carro.datexp = today.
    end.

    update carro.marca  label "Marca"
           carro.modelo label "Modelo"
           carro.ano    label "Ano" 
                with frame fcarro.
end.
else do:
    find carro where carro.clicod = clien.clicod no-error.
    if avail carro
    then assign carro.carsit = yes
                carro.datexp = today
                carro.modelo = ""
                carro.marca  = ""
                carro.ano    = 0.
end.                
        
    
    
        


update clien.autoriza[1]   colon 5 no-label format "x(70)"
       clien.autoriza[2]   colon 5 no-label format "x(70)"
       clien.autoriza[3]   colon 5 no-label format "x(70)"
       clien.autoriza[4]   colon 5 no-label format "x(70)"
       clien.autoriza[5]   colon 5 no-label format "x(70)"
       with width 80 side-label frame f5 title " Observacoes ".
update clien.refnome
       clien.endereco[4] label "Rua"
       clien.numero[4] label "Numero"
       clien.compl[4] label "Complemento"
       clien.bairro[4] label "Bairro"
       clien.cidade[4] label "Cidade"
       clien.ufecod[4] label "Estado"
       clien.cep[4] label "CEP"
       clien.reftel
       with 1 column width 80 frame fpess
            title " Referencia Pessoal " .
