{admcab.i}
def var xx as int.
def var yy as int.
def var vtotal  like titulo.titvlcob.
def var vjuro   like titulo.titvlcob.
def var vacum   like titulo.titvlcob.
def var vdias   as   int.
def var varquivo as char.


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
        
    find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
    

   varquivo = "..\relat\cli" + string(time).

    {mdad.i
        &Saida     = "value(varquivo)" 
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""dreb025""
        &Nom-Sis   = """SISTEMA DE CREDIARIO"""
        &Tit-Rel   = """INFORMACOES DO CLIENTE  : "" +
                        string(clien.clicod,""99999999"") "
        &Width     = "130"
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
                clien.dtnasc format "99/99/9999"
                clien.numdep at 10
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
    else display clien.nacion at 10 
                 clien.ciins label "Insc.Estadual" format "x(11)" 
                 clien.ciccgc 
                    with frame f3 width 80 no-box side-label.
    put skip(1).
    if clien.tippes 
    then disp  "                 INFORMACOES PROFISSIONAIS"
           clien.proemp[1]   label "Empresa"         at 10
           clien.protel[1]   label "Telefone"        at 10
           clien.prodta[1]   label "Data Admissao"   at 10 format "99/99/9999" 
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
    then display clien.conjuge at 10
                 clien.nascon at 10 
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
                        title "              INFORMACOES DO CONJUGE" side-label.

    put skip(1).
    run grau-instrucao.
    
    put skip(1).
    run plano-saude.
    
    put skip(1).
    run seguro.
    
    put skip(1).
    run cartao-credito.
    
    put skip(1).
    run ref-bancaria.
    
    put skip(1).
    run ref-comerciais.
    
    put skip(1).
    run poutros.
    
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
    
                   
    xx = 0. 
    for each contrato where contrato.clicod = clien.clicod no-lock:
        vsit = yes. 
        for each titulo where titulo.empcod = 19 and
                              titulo.titnat = no and 
                              titulo.modcod = "CRE" and 
                              titulo.etbcod = contrato.etbcod and 
                              titulo.clifor = clien.clicod    and 
                              titulo.titnum = string(contrato.contnum) no-lock.
            if titulo.titsit = "LIB" 
            then vsit = no.
        end. 
        if vsit  
        then xx = xx + 1.
    end.
       
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
                              titulo.titnum = string(contrato.contnum) no-lock.
            if titulo.titsit = "LIB" 
            then vsit = no.
        end. 
        
        if vsit  
        then yy = yy + 1.
                      
        if vsit and (yy <= 5 or (xx - yy) <= 5) 
        then. 
        else if vsit  
             then next.
                      

        disp contrato.etbcod 
             contrato.contnum 
             contrato.dtinicial format "99/99/9999" 
             contrato.vltotal(total)  
             contrato.vlentra(total) 
             vsit no-label with frame f-contrato down width 200.
        if vsit = no 
        then do: 
            for each contnf where contnf.etbcod  = contrato.etbcod and
                                  contnf.contnum = contrato.contnum no-lock,
                each plani where plani.etbcod = contrato.etbcod and 
                                 plani.placod = contnf.placod no-lock.
                                 
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and 
                                     movim.movtdc = plani.movtdc and 
                                     movim.movdat = plani.pladat no-lock:
                                     
                    find produ where produ.procod = movim.procod no-lock no-error.
                    display movim.procod 
                            produ.pronom when avail produ format "x(21)" 
                            movim.movqtm column-label "Qtd" format ">>>>9" 
                            movim.movpc format ">>,>>9.99" column-label "Preco"   
                           (movim.movqtm * movim.movpc) column-label "Total"
                                        with frame fmov down centered width 200.
                        
                end.                     
            end.      
        end.
    end. 
    for each titulo use-index iclicod 
                    where titulo.clifor = clien.clicod and
                          titulo.titnat = no no-lock by titulo.titdtven
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
            if not avail tabjur 
            then do:
                message "Fator para" today - titulo.titdtven
                            "dias de atraso, nao cadastrado".
                pause.
                undo.
            end. 
            assign vjuro = (titulo.titvlcob * tabjur.fator) - titulo.titvlcob
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
                            with frame flin down width 140.
    end.       
       
    output close.
    
    if opsys = "UNIX" then do :
        run visurel.p (varquivo,"").
    end.
    else do:
        {mrod.i} 
    end.

end.

procedure grau-instrucao:
    def var vinstrucao as char format "X(30)".
    def var vaux as int.
    DEF VAR AUX-instrucao AS CHAR EXTENT 5 FORMAT "X(20)".
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
        
        if avail(cpclien) then do:
        if cpclien.var-log8 = yes then do:
            assign vcompleto   = yes
                   vincompleto = no.
        end.
        else do:
             assign vcompleto = no
                    vincompleto = yes.   
        end.
        
        do vaux = 1 to 5:
           if aux-instrucao[vaux] = acha("INSTRUCAO",cpclien.var-char8) then do:
              assign vinstrucao = aux-instrucao[vaux].
           end.
        end.
        if vinstrucao = "" then do:
            assign vinstrucao = "Não possui cadastrado.".
        end.
        display "                            GRAU DE INSTRUÇÃO"
                 skip(1)
                 vinstrucao  label "Instrucao " at 10
                 vcompleto   label "Completo  " at 10
                 with frame fgi width 80 no-box side-label.
    end.
end procedure.

procedure plano-saude:
    DEF VAR AUX-psaude AS CHAR EXTENT 4 FORMAT "X(20)".
    def var vplano     as char format "x(20)".
    assign
        aux-psaude[1] = "Nao Possui"
        aux-psaude[2] = "IPE"
        aux-psaude[3] = "UNIMED"
        aux-psaude[4] = "Outros" .
    
    if avail(cpclien) and cpclien.var-log7 = yes
    then do:
        if acha("IPE",var-char7) <> ?
        then assign vplano = if vplano = "" then "Ipe" else vplano + ", Ipe".
        if acha("UNIMED",var-char7) <> ?
        then assign vplano = if vplano = "" then "Unimed" else vplano + ", Unimed".
        if acha("Outros",var-char7) <> ?
        then assign vplano = if vplano = "" then  "Outros" else vplano + ", Outros".
    end.
    else do:
        assign vplano = "Não possui".
    end.       

    display "                            PLANO DE SAUDE"
         skip(1)
         vplano label "Plano de Saude" at 10
         with frame fps width 80 no-box side-label.
         
end procedure.


procedure seguro:

    def var vseguro as char format "x(20)".
    DEF VAR AUX-seguro AS CHAR EXTENT 5 FORMAT "X(20)".
    assign
        aux-seguro[1] = "Nao Possui"
        aux-seguro[2] = "De Saude"
        aux-seguro[3] = "De Vida"
        aux-seguro[4] = "Residencial" 
        aux-seguro[5] = "Automovel".
    
    if avail(cpclien) and cpclien.var-log6 = yes
    then do:
        if acha("De Saude",var-char6) <> ?
        then assign vseguro = if vseguro = "" then "De Saude" else vseguro + ", De saude".
        if acha("De Vida",var-char6) <> ?
        then assign vseguro = if vseguro = "" then "De vida" else vseguro + ", De vida ".
        if acha("Residencial",var-char6) <> ?
        then assign vseguro = if vseguro = "" then "Residencial" else vseguro + ", Residencial".
        if acha("Automovel",var-char6) <> ?
        then assign vseguro = if vseguro = "" then "Automovel" else vseguro + ", Automovel".         
    end.
    else assign vseguro = "Não possui".       

    display "                            SEGURO"
         skip(1)
         vseguro label "Seguro" at 10
         with frame fs width 80 no-box side-label.

end procedure.

procedure cartao-credito:


def var auxcartao as char extent 7 format "x(20)" 
      init [" Visa"," Master"," Banricompras"," Hipercard",
        " Cartoes de Lojas"," American Express"," Dinners"].
def var vcartao as char format "x(30)".        
def var vaux as int.        
                                                  
    repeat vaux = 1 to 7:         
        if avail(cpclien) and int(cpclien.var-int[vaux]) > 0 then do:
            assign vcartao = if vcartao = "" then auxcartao[vaux] else vcartao + "," + auxcartao[vaux].
        end.
    end.
    if vcartao = "" then do:
        assign vcartao = "Não possui".
    end.
    display "                            CARTAO DE CREDITO"
         skip(1)
         vcartao label "Cartao de Credito" at 10
         with frame fc width 80 no-box side-label.
end.

procedure ref-bancaria:

DEF VAR AUX-BANCO AS CHAR EXTENT 4 FORMAT "X(30)".
DEF VAR MARCA-BANCO AS CHAR EXTENT 4 FORMAT "(X)" .
def var log-refban as log format "Sim/Nao" extent 5.
def var vbanco as char extent 4 format "x(80)".
def var vtipo  as char extent 4 format "x(30)".
def var vano   as char extent 4 format "x(30)".

    if avail(cpclien) and cpclien.var-ext5[1] = "SIM" then do:
        assign log-refban[1] = yes
               vtipo[1]      = cpclien.var-ext3[1]
               vano[1]       = cpclien.var-ext4[1].
    end.    
    else do:
        log-refban[1] = no.
    end.    
    if avail(cpclien) and  cpclien.var-ext5[2] = "SIM" then do:
        assign log-refban[2] = yes
               vtipo[2]      = cpclien.var-ext3[2]
               vano[2]       = cpclien.var-ext4[2].
    end.
    else do: 
        log-refban[2] = no.
    end.    
    if avail(cpclien) and cpclien.var-ext5[3] = "SIM" then do:
        assign log-refban[3] = yes
               vtipo[3]      = cpclien.var-ext3[3]
               vano[3]       = cpclien.var-ext4[3].
    end.
    else do: 
        log-refban[3] = no.
    end.    
    if avail(cpclien) and cpclien.var-ext5[4] = "SIM" then do:
        assign log-refban[4] = yes
               vtipo[4]      = cpclien.var-ext3[4]
               vano[4]       = cpclien.var-ext4[4].
    end.
    else do:
        log-refban[4] = no.
    end.
        
    if log-refban[1] = no and     
       log-refban[2] = no and
       log-refban[3] = no and
       log-refban[4] = no then do:
       assign vbanco[1] = ""
              vtipo[1]  = ""
              vano[1]   = "".
    end.
    else do:
        assign
            aux-banco[1] = "BANRISUL"
            aux-banco[2] = "CAIXA ECONOMICA FEDERAL"
            aux-banco[3] = "BANCO DO BRASIL"
            aux-banco[4] = "OUTROS".
        
        if avail(cpclien) and 
          (cpclien.var-ext2[1] = "BANRISUL" or
           cpclien.var-ext2[2] = "BANRISUL" or
           cpclien.var-ext2[3] = "BANRISUL" or
           cpclien.var-ext2[4] = "BANRISUL")
        THEN assign vbanco[1] = "Banrisul".
        if avail(cpclien) and
          (cpclien.var-ext2[1] = "CAIXA ECONOMICA FEDERAL" or
           cpclien.var-ext2[2] = "CAIXA ECONOMICA FEDERAL" or
           cpclien.var-ext2[3] = "CAIXA ECONOMICA FEDERAL" or
           cpclien.var-ext2[4] = "CAIXA ECONOMICA FEDERAL")
         THEN assign vbanco[2] = "Caixa Economica Federal".
        if avail(cpclien) and
          (cpclien.var-ext2[1] = "BANCO DO BRASIL" or
           cpclien.var-ext2[2] = "BANCO DO BRASIL" or
           cpclien.var-ext2[3] = "BANCO DO BRASIL" or
           cpclien.var-ext2[4] = "BANCO DO BRASIL")
         THEN assign vbanco[3] = "Banco do Brasil". 
        if avail(cpclien) and 
          (cpclien.var-ext2[1] = "OUTROS" or
           cpclien.var-ext2[2] = "OUTROS" or
           cpclien.var-ext2[3] = "OUTROS" or
           cpclien.var-ext2[4] = "OUTROS")
        THEN assign vbanco[4]  = "Outros".    
         
    end.    
    if vbanco[1] <> "" or
       vbanco[2] <> "" or
       vbanco[3] <> "" or
       vbanco[4] <> "" then do:           
        display "                            REFERENCIA BANCARIA"
             skip(1).
        if vbanco[1] <> "" then do:
            display      
                 vbanco[1] label "Banco" at 10
                 vtipo[1]  label "Tipo"  at 10
                 vano[1]   label "Ano"   at 10
                 with frame frb2 width 150  no-box side-label.
        end.     
        if vbanco[2] <> "" then do:
           display 
                skip(1)
                vbanco[2] label "Banco" at 10
                vtipo[2]  label "Tipo"  at 10
                vano[2]   label "Ano"   at 10
                with frame frb3 width 150  no-box side-label.
        end.       
        if vbanco[3] <> "" then do:
           display            
                skip(1)
                vbanco[3] label "Banco" at 10
                vtipo[3]  label "Tipo"  at 10
                vano[3]   label "Ano"   at 10
                with frame frb4 width 150  no-box side-label.
        end.
        if vbanco[4] <> "" then do:
            display
                skip(1)
                vbanco[4] label "Banco" at 10
                vtipo[4]  label "Tipo"  at 10
                vano[4]   label "Ano"   at 10
                with frame frb5 width 150  no-box side-label.
        end.        
    end.
    else do:
        display "                            REFERENCIA BANCARIA"
             skip(1)
             "Não possui." at  10
             with frame frb2 width 150  no-box side-label.
    end.
end procedure.

procedure ref-comerciais:

def var log-refcom as log format "Sim/Nao" extent 5.

    if avail(cpclien) and cpclien.var-ext6[1] = "SIM" then do:
        assign log-refcom[1] = yes.
    end.
    else do:    
        assign log-refcom[1] = no.
    end.    
    if avail(cpclien) and cpclien.var-ext6[2] = "SIM" then do:
        assign log-refcom[2] = yes.
    end.
    else do:    
        assign log-refcom[2] = no.
    end.    
    if avail(cpclien) and cpclien.var-ext6[3] = "SIM" then do:
        assign log-refcom[3] = yes.
    end.
    else do:
        assign log-refcom[3] = no.
    end.    
    if avail(cpclien) and cpclien.var-ext6[4] = "SIM" then do:
        assign log-refcom[4] = yes.
    end.
    else do:
        assign log-refcom[4] = no.
    end.
    if avail(cpclien) and cpclien.var-ext6[5] = "SIM" then do:
       assign log-refcom[5] = yes.
    end.    
    else do:
       assign log-refcom[5] = no.
    end.   
    if log-refcom[1] = no or
       log-refcom[2] = no or
       log-refcom[3] = no or
       log-refcom[4] = no or
       log-refcom[5] = no then do:

    
        display "                       REFERENCIAS COMERCIAIS"
                 clien.refcom[1] label "Ref.Comercial" colon 16
                 clien.refcom[2] no-label  colon 18
                 clien.refcom[3] no-label  colon 18
                 clien.refcom[4] no-label  colon 18
                 clien.refcom[5] no-label  colon 18
                 with width 80 side-label
                 frame frc  color white/cyan.
    
    end.
    else do:
    display "                       REFERENCIAS COMERCIAIS"
                 "Não possui"  colon 16
                 with width 80 side-label
                 frame frc1  color white/cyan.

    end.

        find carro where carro.clicod = clien.clicod no-lock no-error.
        if avail carro and carro.carsit = yes
        then do:
         display "                 CARRO"
                     carro.marca  label "Marca" at 10
                     carro.modelo label "Modelo" at 10
                     carro.ano    label "Ano"    at 10
                     with width 80 side-label 
                     frame fcarro. 
        end.
        else do:
        display "                 CARRO"
                     "Nao possui" at 10
                     with width 80 side-label 
                     frame fcarro1. 

        end.             
                         
end procedure.

procedure poutros:

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

display cpclien.var-int3 label "Nota" format ">9"
                    with frame fpess5 side-labels width 20 centered
                    color white/cyan title "    NOTA    ".

end procedure.