/* helio 26072023 Otimização de Cadastro de Crédito V6 - restricoes admcom e ie */
{admcab.i}

def input  parameter vrecid  as recid.
def var vtem as char format "x(20)".

find clien where recid(clien) = vrecid NO-LOCK.
find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
if not avail cpclien
then do ON ERROR UNDO:
    create cpclien.
    cpclien.clicod = clien.clicod.
end.
find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
if clien.tippes
then do:
    display 
           clien.genero  /*clien.sexo */
           clien.estciv
           clien.nacion    clien.falecido
           clien.natur format "x(40)"
           clien.dtnasc format "99/99/9999"
           clien.ciins label "Identidade"
           clien.ciccgc
           clien.pai  format "x(50)"
           clien.mae  format "x(50)"
           clien.numdep
           clien.zona label "E-mail" format "x(40)"
           with 2 column frame f2 width 80 row 9 color white/cyan overlay.
        pause.
    run grau-instrucao.
    run plano-saude.
    run seguro.
    pause.
end.
else
    display clien.nacion
           clien.ciins label "Insc.Estadual" format "x(11)"
           clien.ciccgc
           with 1 column frame f3 width 80 color white/cyan.

 vtem = substring(string(clien.temres,"999999"),1,2) + "/" +
        substring(string(clien.temres,"999999"),3,4) + "(Mes/Ano)".

display clien.endereco[1] label "Rua" format "x(40)"
        clien.numero[1] label "Numero"
        clien.compl[1] label "Complemento"
        cpclien.var-char9 label "Ponto Ref." format "x(20)"
        clien.bairro[1] label "Bairro"  format "x(20)"
        clien.cidade[1] label "Cidade"
        clien.ufecod[1] label "Estado"
        clien.cep[1] label "CEP"
       with frame fres.

disp cpclien.correspondencia at 5 label "Enviar correspondencia?"
           with frame fres.
disp cpclien.var-log2 at 5 
                label "Corrigir endereco? "
                with frame fres.

disp   clien.fone
       clien.fax label "Celular" 
       clien.tipres
       /* clien.vlalug */
       vtem label "Tempo.Res."
       clien.dtcad label "Data Cadastro" format "99/99/9999"
           with 1 column width 80 frame fres
            title " Informacoes Residenciais " color white/cyan.
pause .

def var aux-endereco as char extent 7 format "X(30)".
def var marca-endereco as char extent 7 format "(X)".
def var vaux as int.
    assign
        aux-endereco[1] = "Corrigir endereco"
        aux-endereco[2] = "Nao procurado pelo correio"
        aux-endereco[3] = "Mudou-se"
        aux-endereco[4] = "Desconhecido"
        aux-endereco[5] = "Recusado"
        aux-endereco[6] = "Insuficiente"
        aux-endereco[7] = "Numero nao existe"
        .
    
    do vaux = 1 to 7:
        if cpclien.var-int2 = vaux
        then marca-endereco[vaux] = "X"  .
        else marca-endereco[vaux] = ""   .
    end.
    
    if cpclien.var-log2 = yes
    then  do:
        disp marca-endereco[1] at 1
             aux-endereco[1]
             marca-endereco[2] at 1
             aux-endereco[2]
             marca-endereco[3] at 1
             aux-endereco[3]
             marca-endereco[4] at 1
             aux-endereco[4]
             marca-endereco[5] at 1
             aux-endereco[5]
             marca-endereco[6] at 1
             aux-endereco[6]
             marca-endereco[7] at 1
             aux-endereco[7]
             with frame f-sitender 1 down row 8 column 40
                overlay no-label title " Atualizar endereco ".
             
pause.
   end.
if clien.tippes
then  do:
    display 
        clien.pessoaexposta
        clien.proemp[1] label "Empresa"
           clien.protel[1] label "Telefone"
           clien.prodta[1] label "Data Admissao" format "99/99/9999"
           clien.proprof[1] label "Profissao"
           cpclien.var-char1 label "Cnpj" when avail cpclien  clien.empresa_inscricaoEstadual
           clien.patrimonio
           clien.prorenda[1] label "Soma das rendas"
           clien.endereco[2] label "Rua"
           clien.numero[2] label "Numero"
           clien.compl[2] label "Complemento"
           clien.bairro[2] label "Bairro"
           clien.cidade[2] label "Cidade"
           clien.ufecod[2] label "Estado"
           clien.cep[2] label "CEP"
           with 1 column width 80 frame finfpro
                title " Informacoes Profissionais " color white/cyan.
pause.
end.
def var  vcpfconj like clien.ciccgc.
def var  vnomconj like clien.clinom.
def var  vnatconj as char.
def var vok as log.


if (clien.estciv = 2 or clien.estciv = 6) and clien.tippes
then do:
    vcpfconj = substr(clien.conjuge,51,20).
    vnatconj = substr(clien.conjuge,71,20).
    display clien.conjuge
           vcpfconj          label "CIC/CGC"
           vnatconj          label "Natural de" format "x(40)"
           
           clien.nascon format "99/99/9999"
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
                title " Informacoes do Conjuge " color white/cyan.
pause.
end.
else do:
    disp with frame fconj.
    pause.
end.    
    
def var aux1cartao as char extent 7 format "x(20)" 
      init ["( )","( )","( )","( )","( )","( )","( )"].

def var log-refban as log format "Sim/Nao" extent 5.
def var log-refcom as log format "Sim/Nao" extent 5.

def var auxcartao as char extent 7 format "x(20)" 
      init [" 1-Visa"," 2-Master"," 3-Banricompras"," 4-Hipercard",
        " 5-Cartoes de Lojas"," 6-American Express"," 7-Dinners"].

          /*
def var auxcfcar as log extent 9 format "Sim/Nao".
*/
    repeat vaux = 1 to 7:         
          if int(cpclien.var-int[vaux]) > 0
        then aux1cartao[vaux] = "(X)".
        else aux1cartao[vaux] = "( )".
        /*
        if acha(string(vaux),cpclien.var-char2) = "Sim"
        then auxcfcar[vaux] = yes.
        else auxcfcar[vaux] = no.
        */
    end.    

    repeat:
      display aux1cartao[1] no-label format "x(3)"
          auxcartao[1] no-label 
          "     " no-label
          /*auxcfcar[1] no-label*/ skip
          aux1cartao[2] no-label format "x(3)"
          auxcartao[2] no-label 
          "                 " no-label
          /*auxcfcar[2] no-label*/ skip
          aux1cartao[3] no-label format "x(3)"
          auxcartao[3] no-label 
          "                 " no-label
          /*auxcfcar[3] no-label*/ skip
          aux1cartao[4] no-label format "x(3)"
          auxcartao[4] no-label 
          "                 " no-label
          /*auxcfcar[4] no-label*/ skip
          aux1cartao[5] no-label format "x(3)"
          auxcartao[5] no-label 
          "                 " no-label
          /*auxcfcar[5] no-label*/ skip
          aux1cartao[6] no-label format "x(3)"
          auxcartao[6] no-label 
          "                 " no-label
          /*auxcfcar[6] no-label*/ skip
          aux1cartao[7] no-label format "x(3)"
          auxcartao[7] no-label 
          "                 " no-label
          /*auxcfcar[7] no-label skip
          aux1cartao[8] no-label format "x(3)"
          auxcartao[8] no-label 
          "                 " no-label
          auxcfcar[8] no-label skip
          aux1cartao[9] no-label format "x(3)"
          auxcartao[9] no-label 
          "                 " no-label
          auxcfcar[2] no-label*/ skip
         with frame f-cartao  title "Cartao de Credito". 
        leave.
    end.
    
    /*****************  REFERENCIAS BANCARIAS  **************************/

    DEF VAR AUX-BANCO AS CHAR EXTENT 4 FORMAT "X(30)".
    DEF VAR MARCA-BANCO AS CHAR EXTENT 4 FORMAT "(X)" .

    disp  "Banco"  no-label colon 5
          "Tipo Conta" no-label colon 37
          "Ano Conta" no-label colon 50
          /*"Confirmado" colon 65 */
          /*"---" */
          "-----"  no-label colon 5
          "----------" no-label colon 37
          "-----------" no-label colon 50
          /*"----------" colon 65  */          
          with frame f-banco overlay row 14
          title " REFERENCIAS BANCARIAS ". 

        if cpclien.var-ext5[1] = "SIM"
            then log-refban[1] = yes.
                else log-refban[1] = no.
                    if cpclien.var-ext5[2] = "SIM"
                        then log-refban[2] = yes.
                            else log-refban[2] = no.
                                if cpclien.var-ext5[3] = "SIM"
                                    then log-refban[3] = yes.
                                        else log-refban[3] = no.
                                            if cpclien.var-ext5[4] = "SIM"
                                                then log-refban[4] = yes.
                                                    else log-refban[4] = no.
                  
    assign
        aux-banco[1] = "BANRISUL"
        aux-banco[2] = "CAIXA ECONOMICA FEDERAL"
        aux-banco[3] = "BANCO DO BRASIL"
        aux-banco[4] = "OUTROS"
        .
        
    if cpclien.var-ext2[1] = "BANRISUL" or
       cpclien.var-ext2[2] = "BANRISUL" or
       cpclien.var-ext2[3] = "BANRISUL" or
       cpclien.var-ext2[4] = "BANRISUL"
    THEN marca-banco[1] = "X".
    if cpclien.var-ext2[1] = "CAIXA ECONOMICA FEDERAL" or
       cpclien.var-ext2[2] = "CAIXA ECONOMICA FEDERAL" or
       cpclien.var-ext2[3] = "CAIXA ECONOMICA FEDERAL" or
       cpclien.var-ext2[4] = "CAIXA ECONOMICA FEDERAL"
    THEN marca-banco[2] = "X".
    if cpclien.var-ext2[1] = "BANCO DO BRASIL" or
       cpclien.var-ext2[2] = "BANCO DO BRASIL" or
       cpclien.var-ext2[3] = "BANCO DO BRASIL" or
       cpclien.var-ext2[4] = "BANCO DO BRASIL"
    THEN marca-banco[3] = "X".
    if cpclien.var-ext2[1] = "OUTROS" or
       cpclien.var-ext2[2] = "OUTROS" or
       cpclien.var-ext2[3] = "OUTROS" or
       cpclien.var-ext2[4] = "OUTROS"
    THEN marca-banco[4] = "X".
    vaux = 1.
    do:    
        disp marca-banco[1]    no-label   at 1
         aux-banco[1]  no-label colon 5  format "x(25)"
         cpclien.var-ext3[1]  no-label colon 40 format "x(1)"
         cpclien.var-ext4[1]  no-label format "x(4)" colon 55
         /*log-refban[1] no-label   colon 70      */ 
         marca-banco[2] no-label    at 1
         aux-banco[2] no-label colon 5  format "x(25)"
         cpclien.var-ext3[2]  no-label colon 40 format "x(1)"
         cpclien.var-ext4[2]  no-label colon 55 format "x(4)"   
         /*log-refban[2] no-label   colon 70      */
         marca-banco[3]    no-label  at 1
         aux-banco[3]      no-label colon 5  format "x(25)"
         cpclien.var-ext3[3]  no-label colon 40 format "x(1)"
         cpclien.var-ext4[3]  no-label colon 55 format "x(4)"   
         /*log-refban[3] no-label   colon 70        */
         marca-banco[4]   no-label    at 1
         aux-banco[4]    no-label colon 5  format "x(25)"
         cpclien.var-ext3[4]  no-label colon 40 format "x(1)"
         cpclien.var-ext4[4] no-label colon 55 format "x(4)"   
         /*log-refban[4] no-label   colon 70          */
         with frame f-banco 
         .

    end.  
    pause.
    hide frame f-banco no-pause.
    
    /*****************  FIM REFERENCIAS BANCARIAS ****************/


        if cpclien.var-ext6[1] = "SIM"
        then log-refcom[1] = yes.
        else log-refcom[1] = no.
        if cpclien.var-ext6[2] = "SIM"
        then log-refcom[2] = yes.
        else log-refcom[2] = no.
        if cpclien.var-ext6[3] = "SIM"
        then log-refcom[3] = yes.
        else log-refcom[3] = no.
        if cpclien.var-ext6[4] = "SIM"
        then log-refcom[4] = yes.
        else log-refcom[4] = no.
        if cpclien.var-ext6[5] = "SIM"
        then log-refcom[5] = yes.
        else log-refcom[5] = no.


     disp clien.refcom[1] label "Ref.Comercial" colon 16  format "x(30)"
           cpclien.var-ext1[1] 
                   label "Cartao" colon 55 format "x(1)"   
         help "[1] Apresentado, [2] Não apresentado, [3] Não possui cartão" 
       /*log-refcom[1] label "Confirmado" */
       clien.refcom[2] no-label  colon 16  format "x(30)"
       cpclien.var-ext1[2] 
                   no-label colon 55 format "x(1)"   
         help "[1] Apresentado, [2] Não apresentado, [3] Não possui cartão" 
       /*log-refcom[2] label "          "     */
       clien.refcom[3] no-label  colon 16  format "x(30)"
       cpclien.var-ext1[3] 
                   no-label colon 55 format "x(1)"   
         help "[1] Apresentado, [2] Não apresentado, [3] Não possui cartão"
       /*log-refcom[3] label "          "  */
       clien.refcom[4] no-label  colon 16  format "x(30)"
       cpclien.var-ext1[4] 
                   no-label colon 55 format "x(1)"   
         help "[1] Apresentado, [2] Não apresentado, [3] Não possui cartão"
                  /*log-refcom[4] label "          "    */
       clien.refcom[5] no-label  colon 16  format "x(30)"
       cpclien.var-ext1[5] 
                   no-label colon 55 format "x(1)"   
         help "[1] Apresentado, [2] Não apresentado, [3] Não possui cartão" 
       /*log-refcom[5] label "          "*/
       with width 80 side-label
            frame f4 title " Referencias Comerciais " color white/cyan.

display clien.refcom[1] label "Ref.Comercial" colon 16
        clien.refcom[2] no-label  colon 18
        clien.refcom[3] no-label  colon 18
        clien.refcom[4] no-label  colon 18
        clien.refcom[5] no-label  colon 18
        with width 80 side-label
            frame f4 title " Referencias Comerciais " color white/cyan.
pause.  

def var vconfirmado as log.
    
    find carro where carro.clicod = clien.clicod no-lock no-error.
    if avail carro and carro.carsit = yes
    then do:
        display carro.marca  label "Marca"
                 carro.modelo label "Modelo"
                 carro.ano    label "Ano" 
                     with frame fcarro 
                        side-label title "C a r r o" 1 column centered.

        /*
        if acha("CONFIRMADO",cpclien.var-char3) = "SIM"
        then vconfirmado = yes.
        else vconfirmado = no.
        disp vconfirmado label "Confirmado?" with frame fcarro.
        */
        pause.
        
    end.
    else do:
        disp with frame fcarro.
        pause 0.
    end.    
    display clien.autoriza[1] no-label
       clien.autoriza[2]  no-label
       clien.autoriza[3]  no-label
       clien.autoriza[4]  no-label
       clien.autoriza[5]  no-label
       with width 80 side-label frame f5 title " Observacoes "
       color white/cyan.
    pause.
            
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
pause.
display clien.entendereco[1] format "x(78)" skip
        clien.entendereco[2] format "x(78)" skip
        clien.entendereco[3] format "x(78)" skip
        clien.entendereco[4] format "x(78)" skip
        with frame fpess3 no-labels width 80
                          color white/cyan title " Documentos Apresentados ".

run registros-spc.

display cpclien.var-int3 label "Nota" format ">9"
                    with frame fpess5 side-labels width 20 centered
                    color white/cyan title "    NOTA    ".

      pause.                                  

procedure seguro:
    DEF VAR AUX-seguro AS CHAR EXTENT 5 FORMAT "X(20)".
    DEF VAR MARCA-seguro AS CHAR EXTENT 5 FORMAT "(X)" .
    assign
        aux-seguro[1] = "Nao Possui"
        aux-seguro[2] = "De Saude"
        aux-seguro[3] = "De Vida"
        aux-seguro[4] = "Residencial" 
        aux-seguro[5] = "Automovel".
    
    if cpclien.var-log6 = yes
    then do:
        if acha("De Saude",var-char6) <> ?
        then marca-seguro[2] = "X".
        if acha("De Vida",var-char6) <> ?
        then marca-seguro[3] = "X".
        if acha("Residencial",var-char6) <> ?
        then marca-seguro[4] = "X".
        if acha("Automovel",var-char6) <> ?
        then marca-seguro[5] = "X".
        
    end.
    else marca-seguro[1] = "X".       

    vaux = 1.
    repeat:    
         disp skip(1)
         marca-seguro[1]    no-label   at 1
         aux-seguro[1]  no-label   at 5
         marca-seguro[2] no-label    at 1
         aux-seguro[2] no-label        at 5
         marca-seguro[3]    no-label  at 1
         aux-seguro[3]      no-label     at 5
         marca-seguro[4]   no-label    at 1
         aux-seguro[4]    no-label       at 5
         marca-seguro[5]   no-label    at 1
         aux-seguro[5]    no-label       at 5
          with frame f-seguro  title "  Seguros  "   
         ROW 10 COLUMN 55
         .
         pause 0.
        leave.
    end.  

end procedure.

procedure plano-saude:
    DEF VAR AUX-psaude AS CHAR EXTENT 4 FORMAT "X(20)".
    DEF VAR MARCA-psaude AS CHAR EXTENT 4 FORMAT "(X)" .
    assign
        aux-psaude[1] = "Nao Possui"
        aux-psaude[2] = "IPE"
        aux-psaude[3] = "UNIMED"
        aux-psaude[4] = "Outros" .
    
    if cpclien.var-log7 = yes
    then do:
        if acha("IPE",var-char7) <> ?
        then marca-psaude[2] = "X".
        if acha("UNIMED",var-char7) <> ?
        then marca-psaude[3] = "X".
        if acha("Outros",var-char7) <> ?
        then marca-psaude[4] = "X".
    end.
    else marca-psaude[1] = "X".       

    vaux = 1.
    repeat:    
         disp skip(1)
            marca-psaude[1]    no-label   at 1
         aux-psaude[1]  no-label   at 5
         marca-psaude[2] no-label    at 1
         aux-psaude[2] no-label        at 5
         marca-psaude[3]    no-label  at 1
         aux-psaude[3]      no-label     at 5
         marca-psaude[4]   no-label    at 1
         aux-psaude[4]    no-label       at 5
         with frame f-psaude  title "  Planos de saude  "   
         ROW 10   COLUMN 28
         .
         leave.
    end.  

end procedure.

procedure grau-instrucao:
    DEF VAR AUX-instrucao AS CHAR EXTENT 5 FORMAT "X(20)".
    DEF VAR MARCA-instrucao AS CHAR EXTENT 5 FORMAT "(X)".
    def var v1 as int.
    def var vcompleto as log format "Sim/Nao".
    def var vincompleto as log format "Sim/Nao".
    assign
        aux-instrucao[1] = "Fundamental"
        aux-instrucao[2] = "Primeiro grau"
        aux-instrucao[3] = "Segundo grau"
        aux-instrucao[4] = "Curso superior"
        aux-instrucao[5] = "Pos/Mestrado"    
        .
    if cpclien.var-log8 = yes
    then assign
             vcompleto = yes
             vincompleto = no.
    else assign
             vcompleto = no
             vincompleto = yes.   
    
    do vaux = 1 to 5:
        if aux-instrucao[vaux] = acha("INSTRUCAO",cpclien.var-char8)
        then marca-instrucao[vaux] = "X".
    end.

    vaux = 1.
    repeat:    
         disp  skip(1)
         marca-instrucao[1]    no-label   at 1
         aux-instrucao[1]  no-label   at 5
         marca-instrucao[2] no-label    at 1
         aux-instrucao[2] no-label        at 5
         marca-instrucao[3]    no-label  at 1
         aux-instrucao[3]      no-label     at 5
         marca-instrucao[4]   no-label    at 1
         aux-instrucao[4]    no-label       at 5
         marca-instrucao[5]   no-label    at 1
         aux-instrucao[5]    no-label       at 5
         skip(1)
         "Completo?:" at 1 no-label vcompleto no-label 
         /*"   Incompleto:" no-label vincompleto no-label */
         with frame f-instrucao  title "  Grau de Instrucao  "   
         row 10 
         .
        leave.
    end.  

end procedure.

procedure registros-spc:

    def var vcont    as int.
    def var vmen-spc as char. 
    def var vdat-spc as date label "Data   consulta".
    def var vcpf-spc as char label "CPF    consulta".
    def var vnom-spc as char label "NOME   consulta".
    def var vreg-spc as log  label "CPF   Restricao" format "Sim/Nao".
    def var vcre-spc as char label "Reg. de credito".
    def var vche-spc as char label "Reg. de cheque ".
    def var vnac-spc as char label "Reg. nacional  ".
    def var vale-spc as char label "Reg. de alertas".
    def var vfil-spc as char label "Filial consulta".
    def var vcon-spc as char label "Quant. consulta".
    def var vhor-spc as char.
    def var vloc-spc as char label "Local  consulta".

    vdat-spc = date(clien.entrefcom[1])     .
    vcpf-spc = acha("CPF",clien.entrefcom[2]).
    vnom-spc = clien.clinom.
    
    if acha("ConsultaCpfConjuge",clien.entrefcom[2]) <> ?  and
       date(acha("ConsultaCpfConjuge",clien.entrefcom[2])) > vdat-spc
    then vdat-spc = date(acha("ConsultaCpfConjuge",clien.entrefcom[2])).
    
    if acha("OK",clien.entrefcom[2]) <> ?  and
       acha("OK",clien.entrefcom[2]) = "NAO"
    then vreg-spc = yes.
    else vreg-spc = no.   
    
    assign
        vcre-spc = acha("credito",clien.entrefcom[2])
        vche-spc = acha("cheques",clien.entrefcom[2])
        vnac-spc = acha("nacional",clien.entrefcom[2])
        vale-spc = acha("alertas",clien.entrefcom[2])
        vfil-spc = acha("filial",clien.entrefcom[2])
        vcon-spc = acha("consultas",clien.entrefcom[2])
        vhor-spc = acha("Hora",clien.entrefcom[2])
        vloc-spc = acha("Local",clien.entrefcom[2]).

    if vreg-spc
    then vmen-spc = "CLIENTE COM REGISTRO ".
    ELSE vmen-spc = "CLIENTE SEM REGISTRO ".

    if vhor-spc <> ?
    then vhor-spc = string(int(vhor-spc), "hh:mm:ss").
    else vhor-spc = "".

    disp vmen-spc format "x(50)"  no-label
        skip(1) 
        vcpf-spc  at 1     format "x(15)"
        vnom-spc  at 1     format "x(20)"
        vfil-spc  at 1
        vloc-spc  at 40
        vdat-spc  at 1     format "99/99/9999"
        vhor-spc           no-label
        vcon-spc  at 1
        vale-spc  at 1     when vreg-spc
        vcre-spc  at 40    when vreg-spc
        vche-spc  at 1     when vreg-spc                      
        vnac-spc  at 40    when vreg-spc
        with frame fpess4 side-labels width 80
            color white/cyan title "  S P C  "
             down.
        
    pause.
            
    hide frame fpess4.
    hide frame fpess3.
                    
    do vcont = 1 to num-entries(cpclien.var-char11,"|"):        
        display entry(vcont,cpclien.var-char11,"|") format "x(78)"
                  with frame f-log-spc down
                      title "LOG DA ULTIMA PRE CONSULTA AO SPC" row 5.
        pause 0.
        down with frame f-log-spc.
    end.
                    
    pause.
        
end procedure.
  
