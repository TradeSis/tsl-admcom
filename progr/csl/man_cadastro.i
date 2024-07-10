/* #1 25.07.19 - Tratamento numero do endereco */

assign   vestado_civil               = ""
         vchave_contrato             = ""
         vgrau_instrucao             = ""
         vplano_saude                = ""    
         vseguros                    = ""
         vtempo_residencia           = ""
         vcpfconj                    = ""
         vnatconj                    = ""
         vdat-spc                    = ?
         vlimite_credito             = 0
         vmedia_atraso               = 0
         vvalor_atraso               = 0
         vvalor_a_vencer             = 0
         vvalor_total_divida         = 0
         vdata_vencimento_contrato   = ""
         vdata_ultimo_pagamento      = ""
         vdata_ultimo_vencimento     = ""
         vvalor_ultimo_pagamento     = 0
         vvalor_vencido              = 0
         vRisco                      = "" 
         vvalor_multa                = 0
         vqtd_parcelas               = 0
         vqtd_parcelas_a_vencer      = 0
         vqtd_parcelas_vencidas      = 0
         vqtd_parcelas_pagas         = 0
         vverificar_se_teve_parcelamento = ""     
         vvalor_juros                = 0
         vcobranca                   = 0
         tipo_contrato               = "1"
         vcontrato_gerado_na_novacao = ""
         vvalor_entrada              = 0
         vSubset                     = 0.

assign 
    vtempo_residencia   = substring(string(clien.temres,"999999"),1,2) + "/" +
                          substring(string(clien.temres,"999999"),3,4)
    vestado_civil       = if clien.estciv = 1 
                          then "S"
                          else if clien.estciv = 2 
                          then "C"
                          else if clien.estciv = 3 
                          then "V"
                          else if clien.estciv = 4 
                          then "C"
                          else if clien.estciv = 5 
                          then "Z"
                          else "O" 
    vdat-spc            = date(clien.entrefcom[1]).

if clien.conjuge <> ?
then assign
        vcpfconj            = substr(clien.conjuge,51,20)
        vnatconj            = substr(clien.conjuge,71,20).

/**
if avail cpclien
then do.
    run grau-instrucao.  
    run plano-saude.
    run seguro.                   
end.
**/

vciccgc = trata-numero(clien.ciccgc).
if length(vciccgc) = 11
then do.
    vsubset = int(substr(vciccgc, 11, 1)).
    if vsubset = 0
    then vsubset = 10.
end.


vchave_contrato = string(cslog_controle.loja ,"999") +
                  string(cslog_controle.contnum,"99999999999"). 

run csl/dados_contrato.p (input recid(cslog_controle)).

assign 
    vvalor_entrada      = if avail contrato 
                          then contrato.vlentra
                          else 0.

/**
    vvalor_atraso           = cslog_controle.vlratrasado.
    vvalor_vencido          = cslog_controle.vlratrasado.
    vqtd_parcelas_vencidas  = cslog_controle.qtdatrasado.
    vvalor_a_vencer         = cslog_controle.vlravencer.
    vqtd_parcelas_a_vencer  = cslog_controle.qtdavencer. 
    vvalor_total_divida     = cslog_controle.vlraberto.
    vvalor_juros            = cslog_controle.vlrjuros.
    vdtprivcto              = cslog_controle.privenab.
    vdtultvcto              = cslog_controle.ultvenab.
    vqtd_parcelas_pagas     = cslog_controle.qtdpagas.
    vqtd_parcelas           = cslog_controle.qtdatrasado +
                                 cslog_controle.qtdavencer.
    vvalor_ultimo_pagamento = cslog_controle.ultvlrpag.
    vdtultpgto              = cslog_controle.ultdtpag.
**/

put unformatted
    ""     /* tipo registro */               format "x(3)"    /* Obrigatorio */
    "2"    /* grupo */                       format "x(1)"    /* Obrigatorio */
    vchave_contrato                          format "x(25)"   /* obrigatorio */
    vdata_geracao                            format "x(8)"    /* obrigatorio */
    vhora_geracao                            format "x(8)"    /* obrigatorio */
    vciccgc           /* cpf/cnpj */         format "x(25)"   /* Obrigatorio */
    formatatexto(clien.clinom)               format "x(80)"   /* 71 Obrig  */
    clien.clicod                      format "999999999999"   /* 151         */
    string(cslog_controle.contnum)           format "x(25)"   /* 163         */
    if clien.tippes then "F" else "J"        format "x(1)"    /* Obrigatorio */
    if clien.sexo   then "M" else "F"        format "x(1)"    /* Obrigatorio */
    vestado_civil                            format "x(1)"    /* Obrigatorio */
    vgrau_instrucao                          format "x(20)"   /* 191        */
    vplano_saude                             format "x(20)"   /* 211        */
    vseguros                                 format "x(40)"   /* 231        */
    formatatexto(clien.nacion)               format "x(10)"   /* 271        */
    formatatexto(clien.natur)                format "x(40)"   /* 281        */
    formatadata(clien.dtnasc)                format "x(8)"    /* Obrigatorio */
    formatatexto(clien.ciins)                format "x(25)"   /* 329        */
    formatatexto(clien.pai)                  format "x(40)"   /* 354        */
    formatatexto(clien.mae)                  format "x(40)"   /* 394        */
    formatatexto(clien.zona)  /* e-mail  */  format "x(60)"   /* 434        */
    formatatexto(clien.endereco[1])          format "x(80)"   /* 494 Obrig  */
    (if formatanumero(clien.numero[1]) <= 99999 /* #1 */
     then formatanumero(clien.numero[1])
     else 0)                                 format "99999"   /* 574 Obrig  */
    0                 /* qtd dependentes*/   format "99"      /*             */
    formatatexto(clien.compl[1])             format "x(80)"   /*             */
    formatatexto(clien.bairro[1])            format "x(80)"   /* Obrigatorio */
    formatatexto(clien.cidade[1])            format "x(40)"   /* Obrigatorio */
    formatatexto(clien.ufecod[1])            format "x(5)"    /* Obrigatorio */
    formatatexto(clien.cep[1])               format "x(10)"   /*             */
    (if avail cpclien 
     then formatatexto(cpclien.var-char9)
     else "" ) /* ponto de referencia */     format "x(80)"   /*             */
    (if tipres then "P" else "A")            format "x(1)"    /*             */
    vtempo_residencia                        format "x(7)"    /* Obrigatorio */
    "55"                                     format "x(3)"    /* Obrigatorio */
    formatatexto(clien.fone)                 format "x(13)"   /* Obrigatorio */
    ""             /* ramal da casa */       format "x(4)"    /*             */
    formatatexto(clien.fax)                  format "x(13)"  /* Obrig.Celular*/
    0       /* prestacao/aluguel*/ format "999999999999999"   /*             */
    formatatexto(clien.proemp[1])            format "x(80)"   /* empresa     */
    (if avail cpclien            
     then formatatexto(cpclien.var-char1)
     else "")       /* cnpj empresa */       format "x(25)"   /*             */
    formatatexto(clien.proprof[1])           format "x(40)"   /* profissao   */
    ""               /* cargo */             format "x(40)"   /*             */
    formatadata(clien.prodta[1])             format "x(8)"    /* admissao    */
    formatavalor(clien.prorenda[1]) format "999999999999999"  /*  renda      */
    formatatexto(clien.endereco[2])          format "x(80)"   /* 1140        */
    formatanumero(clien.numero[2])           format "99999"   /* 1220        */
    formatatexto(clien.compl[2])             format "x(80)"   /* 1225        */
    formatatexto(clien.bairro[2])            format "x(80)"   /* 1305        */
    formatatexto(clien.cidade[2])            format "x(40)"   /* 1385        */
    formatatexto(clien.ufecod[2])            format "x(5)"    /* 1425        */
    formatatexto(clien.cep[2])               format "x(10)"   /* 1430        */
    formatatexto(clien.protel[1])            format "x(13)"   /* 1440        */
    ""                                       format "x(4)"    /* ramal       */
    formatatexto(clien.refcom[1])            format "x(15)"   /*             */
    formatatexto(clien.refcom[2])            format "x(15)"   /*             */
    formatatexto(clien.refcom[3])            format "x(15)"   /*             */
    formatatexto(clien.refcom[4])            format "x(15)"   /*             */
    formatatexto(clien.refcom[5])            format "x(15)"   /*             */
    
    /* dados conjuge */
    formatatexto(clien.conjuge)              format "x(40)"   /*             */
    vcpfconj                                 format "x(25)"   /*             */
    vnatconj                                 format "x(40)"   /*             */
    formatatexto(clien.protel[2])            format "x(13)"   /* fone conj   */
    formatatexto(clien.proemp[2])            format "x(30)"   /* empresa conj*/
    formatatexto(clien.proprof[2])           format "x(30)"   /* profis.conj */
    formatadata(clien.prodta[2])             format "x(8)"    /*             */
    formatavalor(clien.prorenda[2])  format "999999999999999" /* renda conj  */
    formatatexto(clien.endereco[3])          format "x(40)"   /* ender.conj  */
    formatanumero(clien.numero[3])           format "99999"   /*             */
    formatatexto(clien.compl[3])             format "x(20)"   /*             */
    formatatexto(clien.bairro[3])            format "x(20)"   /*             */
    formatatexto(clien.cidade[3])            format "x(30)"   /*             */
    formatatexto(clien.ufecod[3])            format "x(2)"    /*             */
    formatatexto(clien.cep[3])               format "x(10)"   /*             */
    formatadata(clien.nascon)                format "x(8)"    /*             */
    formatatexto(clien.conjpai)              format "x(40)"   /*             */
    formatatexto(clien.conjmae)              format "x(40)"   /*             */
    
    ""    /* tel adicional */                format "x(13)"   /*             */
    ""    /* tel adicional */                format "x(13)"   /*             */
    ""    /* tel adicional */                format "x(13)"   /*             */
    ""    /* tel adicional */                format "x(13)"   /*             */

    /* Referencias Pessoais  1  */
    formatatexto(clien.entbairro[1])         format "x(40)"   /* nome     */
    formatatexto(clien.entcep[1])            format "x(13)"   /* fone     */
    formatatexto(clien.entcidade[1])         format "x(13)"   /* celular  */
    formatatexto(clien.entcompl[1])          format "x(50)"   /* parentesco */

    /* Referencias Pessoais  2  */
    formatatexto(clien.entbairro[2])         format "x(40)"   /* nome     */
    formatatexto(clien.entcep[2])            format "x(13)"   /* fone     */
    formatatexto(clien.entcidade[2])         format "x(13)"   /* celular  */
    formatatexto(clien.entcompl[2])          format "x(50)"   /* parentesco */

    /* Referencias Pessoais  3  */
    formatatexto(clien.entbairro[3])         format "x(40)"   /* nome     */
    formatatexto(clien.entcep[3])            format "x(13)"   /* fone     */
    formatatexto(clien.entcidade[3])         format "x(13)"   /* celular  */
    formatatexto(clien.entcompl[3])          format "x(50)"   /* parentesco */

    ""        /* classe */                   format "x(10)"   /*             */
    vlimite_credito   * 100        format "999999999999999"   /* ########### */
    vmedia_atraso     * 100                  format "999"     /* ########### */
    formatadata(clien.dtcad)                 format "x(8)"    /* dt cadastro */
    ""     /* situacao     */                format "x(1)"    /*             */
    formatadata(vdat-spc)                    format "x(8)"    /*             */
    formatatexto(clien.autoriza[1])          format "x(70)"   /* observacoes */
    formatatexto(clien.autoriza[2])          format "x(70)"   /* observacoes */
    formatatexto(clien.autoriza[3])          format "x(70)"   /* observacoes */
    formatatexto(clien.autoriza[4])          format "x(70)"   /* observacoes */
    formatatexto(clien.autoriza[5])          format "x(70)"   /* observacoes */
    ""           /* cartao credito */        format "x(80)"   /*             */
    ""           /* ref bancaria */          format "x(80)"   /*             */
    .

