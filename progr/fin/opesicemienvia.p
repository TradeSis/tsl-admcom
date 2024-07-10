/* helio 25052023 Demanda 308 - Layout Sicred - Campo valor financiado e valor liquido */
/* helio 24052023 Demanda 286 - trocado nome do arquivo de op para ep, so que apenas quando contratos EP */
/* helio 18052023 - Demanda 269 - ajustado dtven */
/* helio 18052023 - Demanda 286 - trocado nome do arquivo de op para ep */ 
/*** helio 12042023 - Qualitor 22363 - Erro no exportador / Data cônjuge. */
/* helio 23032023 - ajuste banco pagamento */
/* helio 07022023 - teste existe pdvmov, por causa problema da linx */
/* helio 18012023 - alterado para pegar dados do contrato do proprio contrato. */
/* helio 05122022 - ID 155437 - Caracteres Especiais no Exportador do ADMCOM - colocado funcao api/acentos.i RemoveAcento */
/* helio #16062022 - ID 148949 - Ajuste Data Admissão Cliente */
/* helio #02092022 - reativacao projeto cria produto adm */
/* helio 18082022 -  rollback produitos adm + ID 131236 - Ajuste Arquivo de Importação */
/* helio 19072022 - projeto Criar Produtos - ADM - tipoontratoSicred */
/* helio 13072022 - projeto Criar Produtos - ADM */

def var  vtitvltot as dec.

def var vvaloroperacao as dec.
def var vvalorseguro   as dec.

def input param poperacao   like sicred_contrato.operacao.
def input param pstatus     like sicred_contrato.sstatus.

def var vcobcoddes like cobra.cobcod init 10.

def var vtipocontratosicred as char.
{api/acentos.i}
{admbatch.i}
{acha.i}

def var vservicos as dec.
def var vvlf_principal as dec.
def var vtpcontrato     like contrato.tpcontrato.

     def buffer blotefin for lotefin.

def shared temp-table ttsicred no-undo
    field marca     as log format "*/ "
    field cobcod    like titulo.cobcod     
    field dtenvio   like lotefin.datexp
    field lotnum    like lotefin.lotnum
    field datamov   like pdvforma.datamov
    field ctmcod    like pdvforma.ctmcod        
    field modcod    like poscart.modcod
    field tpcontrato    like poscart.tpcontrato
    field qtd       as int 
    field vlf_principal  like contrato.vlf_principal
    field vlf_acrescimo  like contrato.vlf_acrescimo
    field vlentra  like contrato.vlentra 
    field vlseguro    like contrato.vlseguro
    field vltotal    like contrato.vltotal
    index idx is unique primary 
        cobcod asc
        datamov asc 
        dtenvio  asc
        lotnum
        ctmcod asc
        modcod asc
        tpcontrato asc            
     index idx2 marca asc datamov asc   .

def temp-table ttenviado no-undo
    field psicred as recid.
def new shared temp-table ttnovacao no-undo
    field tipo      as char
    field contnum   like contrato.contnum format ">>>>>>>>>>9"
    field valor     like contrato.vltotal
    field saldoabe  like titulo.titvlcob  

    index idx is unique primary tipo desc contnum asc.
def temp-table ttcob no-undo
    field cobcod as int
    index idx is unique primary cobcod asc.
    
def var varquivo as char.
def var varqexp  as char.
def var vseq as int.
def var vqtoper  as int.
def var vtotal   as dec.

def var vlote as int.

def buffer btitulo for titulo.

def temp-table cont_novacao like contrato.
def temp-table tt-tit_novacao like tit_novacao.

FUNCTION f-troca returns character
    (input cpo as char).
    def var v-i as int.
    def var v-lst as char extent 60
       init ["+","@",":",";",".",",","*","/","-",">","!","'",'"',"[","]"].
         
    if cpo = ?
    then cpo = "".
    else do v-i = 1 to 30:
         cpo = replace(cpo,v-lst[v-i],"").
    end.
    return cpo. 
end FUNCTION.

    
    for each ttenviado.
        delete ttenviado.
    end.        

    do on error undo.
        find last Blotefin no-lock no-error.
        create lotefin.
        assign lotefin.lotnum = (if avail Blotefin 
                                 then Blotefin.lotnum + 1
                             else 1)
            lotefin.lottip = "INC"
            lotefin.aux-ch = "FINANCEIRA - EXPORTA CONTRATOS".
          
    assign vlote = lotefin.lotnum.                         
    end.

    /* helio 24052023 */ 
    
    varqexp = "op" + string(today,"999999") + "f_" + string(vlote) + ".rem". /* normal */

    find first ttsicred where ttsicred.marca = yes no-lock no-error.
    if avail ttsicred and ttsicred.modcod begins "CP"
    then do: 
        varqexp = "ep" + string(today,"999999") + "f_" + string(vlote) + ".rem". /* helio 24052023 arquivo ep */
    end.
    /**/
    varquivo = "/admcom/import/financeira/" + varqexp.

    hide message no-pause.
    message color normal "gerando arquivo" varquivo "... aguarde...".
    
    output to value(varquivo) page-size 0.

    run p-registro-00.

    for each  ttsicred where ttsicred.marca = yes no-lock:
    for each sicred_contrato where
        sicred_contrato.operacao = poperacao and
        sicred_contrato.cobcod   = ttsicred.cobcod   and
        sicred_contrato.sstatus  = pstatus and
        sicred_contrato.datamov  = ttsicred.datamov and
        sicred_contrato.ctmcod   = ttsicred.ctmcod 
        no-lock.
    
        find contrato where contrato.contnum = sicred_contr.contnum
            no-lock no-error.
        if not avail contrato
        then next.   

        /*helio 51077 122020
        if contrato.dtinicial >= today
        then next.*/
        
        find contnf where contnf.etbcod  = contrato.etbcod and
                          contnf.contnum = contrato.contnum
                          no-lock no-error.
        if avail contnf
        then do:
            find plani where plani.etbcod = contnf.etbcod and
                             plani.placod = contnf.placod
                             no-lock no-error.
        end.                                          
        if contrato.dtinicial >= 06/01/2020
        then vtpcontrato = contrato.tpcontrato.
        else do:
            find first titulo where titulo.contnum = contrato.contnum and
                      titulo.titpar  >= 1
                      no-lock no-error.
                if not avail titulo
                then do:
                    find first titulo where
                    titulo.empcod     = 19 and
                    titulo.titnat     = no and
                    titulo.modcod     = contrato.modcod and
                    titulo.etbcod     = contrato.etbcod and
                    titulo.clifor     = contrato.clicod and
                    titulo.titnum     = string(contrato.contnum) and 
                    titulo.titpar     >= 1 and
                    titulo.titdtemi   = contrato.dtinicial
                    no-lock no-error.
                end.
            vtpcontrato = if avail titulo
                      then titulo.tpcontrato
                      else "".
        end.
 
        if  contrato.modcod   = ttsicred.modcod  and
            vtpcontrato = ttsicred.tpcontrato
        then. 
        else next.     

        find first clien where clien.clicod = contrato.clicod no-lock.
        find first cpclien where cpclien.clicod = clien.clicod  no-lock no-error.

        find finan where finan.fincod = contrato.crecod no-lock no-error.

        /**run calciof.p(input rowid(contrato),  output viof, output vjuro, output txjuro).
        **/
        
        create ttenviado.
        ttenviado.psicred = recid(sicred_contrato).
        
        run p-registro-01.
        run p-registro-02.
        run p-registro-03.
        run p-registro-04.   
        run p-registro-05.   
        
        run p-registro-07.            
        
        
        run p-registro-10.    

        for each btitulo where 
                           btitulo.empcod = 19  and 
                           btitulo.titnat = no   and
                           btitulo.modcod = contrato.modcod and      
                           btitulo.etbcod = contrato.etbcod and
                           btitulo.clifor = contrato.clicod and
                           btitulo.titnum = string(contrato.contnum) and
                           btitulo.titpar > 0  
                       no-lock.
             run p-registro-11.
        end.   

        find contCP where contCp.contnum = contrato.contnum no-lock no-error.
            
        if avail contCP
        then do:
            run p-registro-12.
        end.    

        if poperacao = "NOVACAO"
        then do:
            run p-registro-13.
            /*run p-registro-14.*/
        end.
        
        run p-registro-98.
    end.
    end.
    
    run p-registro-99.
    
    output close.
    
    
        output to ./unixdos.txt.
        unix silent unix2dos value(varquivo). 
        unix silent chmod 777 value(varquivo).
        output close.
        unix silent value("rm ./unixdos.txt -f").

    for each ttenviado.
        find sicred_contrato where recid(sicred_contrato) = ttenviado.psicred exclusive.
        sicred_contrato.sstatus = "ENVIADO".
        sicred_contrato.lotnum = vlote.        
        /** VERSAO NOVA sicred_contrato.dtenvio = today. **/
        
        if poperacao = "NOVACAO"
        then do:
            find first pdvmov where 
                    pdvmov.etbcod = sicred_contr.etbcod and
                    pdvmov.cmocod = sicred_contr.cmocod and
                    pdvmov.datamov = sicred_contr.datamov and
                    pdvmov.sequencia = sicred_contr.sequencia
                no-lock no-error.
            if avail pdvmov
            then    
            for each pdvdoc of pdvmov no-lock.
                for each sicred_pagam where sicred_pagam.etbcod = pdvdoc.etbcod and 
                                    sicred_pagam.cmocod = pdvdoc.cmocod and
                                    sicred_pagam.datamov = pdvdoc.datamov and
                                    sicred_pagam.sequencia = pdvdoc.sequencia and
                                    sicred_pagam.ctmcod = pdvdoc.ctmcod and
                                    sicred_pagam.seqreg = pdvdoc.seqreg
                                    exclusive.
                    sicred_pagam.sstatus = "ENVIADO".
                    sicred_pagam.lotnum = vlote.        
                    /** versao nova ** sicred_pagam.dtenvio = today. **/
                    
                end.
            end.
        end.                                                                      
        
    end.        
    hide message no-pause.
    message color normal "arquivo" varquivo "gerado!".
    pause 3 no-message.

/* header */
procedure p-registro-00.

     vseq = 1.
     put unformat skip
         "00" 
         varqexp format "x(08)"
         string(today,"99999999")
         "0001"    /* 19 - 22 NUMÉRICO        AGÊNCIA ??? */
         "LEBES" format "x(6)" /* 23 - 28 ALFANUMÉRICO    LOJISTA ??? */
         0000 /*vetbcod*/ format ">>>9"   /* 29-32 LOJA (UM ARQ. P/FILIAL??) */
         " " format "x(762)" 
         vseq format "999999" /* NUMERICO  Sequencia do arquvo???? */
          .
end procedure.

procedure p-registro-01.

def var vestciv as char init "SCVJD".
def var vciccgc like clien.ciccgc.
def var vciinsc like clien.ciinsc.
vseq = vseq + 1.

vciccgc = clien.ciccgc.
vciinsc = clien.ciins.

run Pi-cic-number(input-output vciccgc).
run Pi-cic-number(input-output vciinsc).

def var cid-natur as char format "x(20)".
def var uf-natur as char.

cid-natur = "".
uf-natur = "".

if num-entries(clien.natur,"-") > 1
then assign
         cid-natur = trim(entry(1,clien.natur,"-"))
         uf-natur  = trim(entry(2,clien.natur,"-")).

put unformat skip
     "01"
     (if clien.tippes then "F" else "J") format "x(1)" 
     dec(f-troca(vciccgc))    format "99999999999999"
     RemoveAcento(clien.clinom)  format "x(40)"
     RemoveAcento(clien.mae)    format "x(40)"
     RemoveAcento(clien.pai)    format "x(40)"
    (if clien.estciv > 0 and clien.estciv < 6
     then substring(vestciv,clien.estciv,1) else "S") 
     string(clien.sexo,"M/F")
     clien.numdep format "99"         /*  140 - 141 */
     string(clien.dtnasc,"99999999")  /* 142 - 149  */
     cid-natur format "x(20)"       /*  150 - 169 */
     uf-natur  format "x(2)"        /* 170 - 171  */
     (if clien.nacion begins "br" then "BR" else "ES") /* 172 - 173 */
     string(vciinsc) format "x(15)"    /* 174 - 188 */
     " " format "x(6)" /* 189 - 194   TIPO DOC IDENTIDADE  */
     "  "         /* 195 - 196  orgão emissor */
     "00000000"   /* 197 - 204   DATA    DATA EMISSÃO  */  
     "0"          /* 205 - 205    GRAU DE INSTRUÇÃO */
     "C"          /* 206 - 206 TP CLIENTE C-Cliente  A-Avalista O-Coobr */
     "  "         /* 207 - 208 UF DOC IDENTIDADE */
     "  "         /* 209 - 210 Código do Conceito do cliente */
     " " format "x(584)"
     vseq format "999999".
 
end procedure.

/* conjuge */
procedure p-registro-02.
def var vrenda as dec.
def var vprodta as date.
vseq = vseq + 1.

if clien.prorenda[2] > 0
then vrenda = clien.prorenda[2].
else vrenda = 0.

def var vnomconj as char.
def var vcpfconj as char.
def var vnatconj as char.
def var vnascon like clien.nascon.
assign
    vnomconj = substr(clien.conjuge,1,50)
    vcpfconj = substr(clien.conjuge,51,20)
    vnatconj = substr(clien.conjuge,71,20).

    /*#16092022 se a data estivar vazia ou invalida, incluir a data da operação realizada. */
    vprodta = if clien.prodta[2] = ? or clien.prodta[2] < today - (100 * 365)
              then contrato.dtinicial
              else clien.prodta[2].

    /*** helio 12042023 - Qualitor 22363 - Erro no exportador / Data cônjuge.*/

    vnascon = if clien.nascon = ?
              then 01/01/2000
              else clien.nascon.
              
    if clien.conjuge <> ? and clien.conjuge <> ""  and (clien.estciv = 2 or clien.estciv = 6) and clien.tippes
    then do: 
        if  (clien.nascon = ? or clien.nascon < today - (100 * 365))
        then do: 
            vnascon = 01/01/2000.
        end.
    end.    
        
put unformat skip 
   "02"  
    dec(f-troca(vcpfconj))    format "99999999999999"
    RemoveAcento(vnomconj) format "x(40)"    /* 17 - 56 NOME DO CÔNJUGE  */
    f-troca(string(vnascon)) format "99999999" /* 57-64 DATA NASCIMENTO */
    "   "                            /* 65 - 68  PROFISSÃO */
    RemoveAcento(clien.proprof[2])  format "x(15)"  /* 69 - 83  CARGO  */
    vrenda * 100 format "999999999999"  /* 84-95 RENDA */
    /*#16092022 f-troca(string(clien.prodta[2]))  format "99999999" /* 96-103 DT DE ADM */ */
                f-troca(string(vprodta))         format "99999999" /*#16092022*/
    
    fill(" ",691)                       /* 104 - 794 */
    vseq format    "999999".
end procedure.

/* referencias */
procedure p-registro-03.
  vseq = vseq + 1.
  put unformat skip "03" 
      "0000"     /* 03 - 06 BANCO1  */
      "0 "       /* 07 - 07 TIPO CONTA1 1-NENHUMA2-COMUM3-ESPECIAL */
      "000000"   /* 09 - 14 CONTA DESDE1 */
      " " format "x(20)" /* 15 - 34 AGENCIA */
      "0000"     /* 35 - 38 Banco */
      "0"        /* 39 - 39 TIPO CONTA2 1-NENHUMA2-COMUM3-ESPECIAL */
      "000000"   /* 40 - 45 cONTA DESDE2 */
      " " format "x(20)"  /* 46 - 65 ALFANUMÉRICO    AGÊNCIA BANCO2 */
      "000"     /* 66 - 68 NUMÉRICO    CARTAO CREDITO1 VER ANEXO */
      "00"      /* 69 - 70 NUMERICO    TIPO CARTAO1    */
      "000"     /* 71 - 73 NUMÉRICO    CARTAO CREDITO2   */
      "00"      /* 74 - 75 NUMÉRICO    TIPO CARTAO2      */
      clien.entbairro[1] format "x(40)" /* 76 - 115 REF PESSOAL */
      clien.entcompl[1]  format "x(10)" /* 116 - 125 RELACION */
      clien.entcidade[1] format "x(20)" /* 126 - 145  TELEFONE */
      clien.entbairro[2] format "x(40)" /* 146 - 185 REF PESSOAL */
      clien.entcompl[2] format "x(10)" /* 186 - 195 RELACION */
      clien.entcidade[2] format "x(20)" /* 196 - 215  TELEFONE */
      " " format "x(579)" /* 216 - 794   ALFANUMÉRICO    FILLER  */
      vseq format    "999999" /*795 - 800 */ .
end procedure.        

/* ENDERECO */
procedure p-registro-04.
  def var vaux as char. 
  vseq = vseq + 1.
  put unformat skip "04"  /* 01  - 02  TIPO  FIXO – 04*/
      clien.endereco[1]  format "x(50)" /* 03 - 52   ENDEREÇO */
      clien.bairro[1]    format "x(40)" /* 53  - 92  BAIRRO  */
      clien.cidade[1]    format "x(40)" /* 93  - 132 CIDADE  */
      clien.ufecod[1]    format "x(2)" /* 133 - 134 UF    */
      f-troca(clien.cep[1]) format "x(8)"  /* 135 - 142 CEP   */
      (if clien.tipres then "1" else "3")  /* 143  1- PROPRIA;  3- ALUGADA */
       trim(substring(string(clien.temres,"999999"),1,2) + "/" + 
            substring(string(clien.temres,"999999"),3,4)) format "x(7)"
                  /* 144 - 150   RESIDÊNCIA DESDE */
      "2". /* 151  DESTINO CORRESP.A 1- COMERCIAL;2- RESIDENCIAL */
      
  vaux = f-troca(clien.fone).
  put unformat
      vaux format "x(19)" /* 152 - 170 ddd/telefone/ramal */
      (if length(vaux) > 5 
      then "1"  /* 171 - 1 residencial, 3 nao possue */
      else "3")
      .
  vaux = f-troca(clien.fax).
  put unformat 
      vaux format "x(19)" /* 172 - 190 ddd/telefone/ramal */
      (if length(vaux) > 5 
      then "2"  /* 191 - 2 celular, 3 nao possue */
      else "3")
      clien.zona format "x(40)" /* 192 – 231 EMAIL */
      " " format "x(40)" /* 232 – 271 ENDEREÇO ALTERNATIVO  */
      " " format "x(40)" /* 272 – 311 BAIRRO ENDEREÇO ALTERNATIVO*/    
      " " format "x(40)" /* 312 – 351 CIDADE ENDEREÇO ALTERNATIV */   
      " " format "x(2)"  /* 352 – 353 UF ENDEREÇO ALTERNATIV */
      " " format "x(8)"  /* 354 – 361 CEP ENDEREÇO ALTERNATIVO*/
      fill("0",17)       /* 362 – 378 ALUGUEL MENSAL    Clien.*/
      fill("0",17)       /* 379 – 395 PRESTAÇÃO CASA PRÓPRIA*/
      fill(" ",399)      /* 396  794   ALFANUMÉRICO    FILLER  */
      vseq format    "999999" /*795 - 800 */ .
end procedure.

/* ATIVIDADES */
procedure p-registro-05.
def var vrenda as dec.
def var vprodta as date.

    vseq = vseq + 1.
    if clien.prorenda[1] > 0
    then vrenda = clien.prorenda[1].
    else vrenda = 0.
    def var vaux as char.
    vaux = "".
    
    vaux = f-troca(clien.protel[1]).
    
    def var var-int4 like cpclien.var-int4.
    if avail cpclien
    then var-int4 = cpclien.var-int4.
    else var-int4 = 0.

    /*#16092022 se a data estivar vazia ou invalida, incluir a data da operação realizada. */
    vprodta = if clien.prodta[1] = ? or clien.prodta[1] < today - (100 * 365)
              then contrato.dtinicial
              else clien.prodta[1].
        
    put unformat skip "05"  /* 01  - 02  TIPO  FIXO  05*/
        clien.proemp[1]     /* 03 - 42 */      format "x(40)"
        clien.endereco[2]  /* 43 - 82 */       format "x(40)"
        clien.bairro[2]     /* 83 - 122 */     format "x(40)"
        clien.cidade[2]    /* 123 - 162 */     format "x(40)"
        clien.ufecod[2]     /* 163 - 164 */    format "x(2)"
        f-troca(clien.cep[2])  /* 165 - 172 */    format "x(8)"
        vaux                /* 173 - 193 */    format "x(21)" 
        /*DDD
        clien.protel[1]    /* 177 - 188 */    format "x(12)"
        " "                  /* 189 - 193 */    format "x(5)"
        */
        var-int4    /* 194 - 197 */   format "9999"
        clien.proprof[1]         /* 198 - 227 CARGO*/ format "x(30)"
        /*#16092022 f-troca(string(clien.prodta[1])) /* 228 - 235 */ format "99999999" */
        f-troca(string(vprodta)) /* 228 - 235 */ format "99999999" /*#16092022*/
        
        vrenda * 100 format "99999999999999999" /* 236 - 252 */
        "00000000000000000"   /* 253 - 269 OUTROS RENDIM*/
        " "  format "x(29)"    /* 270 - 299 DESCRIÇÃO OUTROS RENDIMENTOS*/
        "N"                 /* 300 - 300 PROPRIETÁRIO*/
        " "  format "x(14)"  /* 301 - 314 */
        fill(" ",399)       /* 315 - 794 FILLER  */
        vseq format    "999999" /* 795 - 800 */ 
        .
end procedure.

/* observacao */
procedure p-registro-07.
    vseq = vseq + 1.
    def var vlimite as char.
    
    find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
    if AVAIL neuclien and neuclien.vctolimite >= today 
    then vlimite = replace(string(neuclien.vlrlimite,"->>>>>>>>9.99"),".",",").
    else vlimite = "0,00".
    
    put unformat skip 
        "07"  /* TIPO  FIXO  07*/
        "LIMITE DE CREDITO " + vlimite
        format "x(699)"
        fill(" ",93)
        vseq format    "999999"
        .
        
end procedure.


/* OPERACAO */
procedure p-registro-10.
  def var vcod-produto  as integer.
  def var vplano-fin like contrato.crecod.
  vseq = vseq + 1.
  vqtoper = vqtoper + 1.
  vservicos = 0. 
  vvlf_principal = 0. 
  find first titulo where titulo.contnum = contrato.contnum and
                    titulo.titpar  >= 1
                      no-lock no-error.

                if not avail titulo
                then do:
                    find first titulo where
                    titulo.empcod     = 19 and
                    titulo.titnat     = no and
                    titulo.modcod     = contrato.modcod and
                    titulo.etbcod     = contrato.etbcod and
                    titulo.clifor     = contrato.clicod and
                    titulo.titnum     = string(contrato.contnum) and 
                    titulo.titpar     >= 1 and
                    titulo.titdtemi   = contrato.dtinicial
                    no-lock no-error.
                end.
    if not avail titulo then next.                     /* helio 25042023 - ID 24709 - arquivo exportação com falha. */
    
    /* helio 13072022 - projeto Criar Produtos - ADM */
    vcod-produto = sicred_contr.codProduto. 
    if vcod-produto = 0 or vcod-produto = ? /* helio 13072022 - projeto Criar Produtos - ADM */
    then do:      
        find first profin where profin.modcod = contrato.modcod
                             no-lock no-error.
        if avail profin
        then assign vcod-produto = profin.Codigo_Sicred.
        else do:
            assign vcod-produto = 1.
            if poperacao = "NOVACAO"
            then do:
                run achacobcod(output vcod-produto).
                vservicos = contrato.vlseguro. 
            end.     
        end.  
        /***https://trello.com/c/YRnrxmXd/62-produto-nova%C3%A7ao-arquivo-importado-sicr ed ***/
        if (contrato.tpcontrato = "N" or (avail titulo and titulo.tpcontrato = "N")) and contrato.modcod = "CRE"
        then vcod-produto = 2.
        else if contrato.modcod = "CPN"
             then vcod-produto = 5.
        /*** ***/               

        if poperacao = "TRANSFERE"
        then do:
            if contrato.tpcontrato = "N"
            then vcod-produto = 12.
            else vcod-produto = 11.
        end. 
  
        find contrsite where contrsite.contnum = contrato.contnum no-lock no-error. 
        if avail contrsite 
        then do: 
            vcod-produto = 13. /* 06042021 helio - Crediário Digital . Int. Financeira - Codigo produto */
        end.
    end.
  
    vplano-fin = contrato.crecod.
    if vplano-fin = 0     /* 122020 helio 46030 */
    then do:
        if vcod-produto = 2 or vcod-produto = 12
        then vplano-fin = 500.
        else if vcod-produto = 5
             then vplano-fin = 501.
    end.
    
    /* 17.06 le a nota para pegar o valor dos servicos */
    find contnf where 
            contnf.etbcod = contrato.etbcod and
            contnf.contnum = contrato.contnum no-lock no-error.
    if avail contnf
    then do:
        find plani where plani.etbcod = contnf.etbcod and
                         plani.placod = contnf.placod
                         no-lock no-error.
        if avail plani
        then do:
            if contrato.modcod = "CP0" or contrato.modcod = "CP1"
            then vvlf_principal = plani.protot + plani.vlserv.
            
            vservicos = plani.vlserv. 

            if contrato.modcod = "CP0" or 
               contrato.modcod = "CP1" 
            then do:
                vservicos = if plani.seguro = ?
                            then 0
                            else plani.seguro. 
            end.
                
            find finan where finan.fincod = plani.pedcod no-lock no-error.
            if avail finan
            then vplano-fin = if vplano-fin = 0 or vplano-fin = ?
                                          then plani.pedcod
                                          else vplano-fin.
            
        end.
    end.            
  
    if contrato.modcod = "CP0" or
       contrato.modcod = "CP1" 
    then.
    else  vvlf_principal = if contrato.vlf_principal = 0
                     then contrato.vltotal - contrato.vlentra - contrato.vliof
                     else if poperacao = "NOVACAO"
                          then contrato.vlf_principal /*- contrato.vlentra helio 06042022*/
                          else contrato.vlf_principal.
    
    /* ID 139269 - ADMCOM - "PRINCIPAL" CONTENDO Valores/Exportação de arquivo PRINCIPAL=0 */
    if contrato.modcod = "CRE" /* ID 139269 acrescentei teste so para CRE */
    then do:
        if vvlf_principal <= vservicos        /* ID 139269 era < ficou <= */
        then do:
            vvlf_principal = vservicos /* ID 156040 29112022 */ - contrato.vlentra .
            vservicos = 0.
        end.
    end.
  
  /*** #02092022 */     /* helio 19072022 - projeto Criar Produtos - ADM - tipocontratosicred */
    vtipocontratosicred = if sicred_contr.tipocontratosicred <> "" and sicred_contr.tipocontratosicred <> ?
                          then (sicred_contr.tipocontratosicred + " ")
                          else "N ".

  /*  vtipocontratosicred =  "N ". #02092022 */
    
    def var v-data-comerc as log init yes.
    def var v-data-retorno as date.
    def var vdtinicial like contrato.dtinicial.
    def var vtitdtven like titulo.titdtven.
    vdtinicial = contrato.dtinicial.
    vtitdtven = titulo.titdtven.

    /* 14042021 card ID 67095 - Exportação Novação 
        voltando atras 
    if poperacao = "NOVACAO" /* 19/02/2021 */
    then do:
        run p-verif-data (input vdtinicial,
                          output v-data-retorno,
                          output v-data-comerc).
        if v-data-comerc = no and v-data-retorno <> ?
        then vdtinicial = v-data-retorno.
    end.
    14042021 card ID 67095 **/
    
    if titulo.titdtven = contrato.dtinicial 
    then vtitdtven = vdtinicial + 1.
    
    /* helio 18012023 - alterado para pegar dados do contrato */
      vvaloroperacao = contrato.vlf_principal /*+ contrato.vlf_acrescimo*/.
      if contrato.vlseguro > 0
      then do: 
        vvalorseguro   = contrato.vlseguro.
      end.
      else do:
        vvalorseguro = 0.
        /**
        vvalorseguro    = vservicos.
        vvaloroperacao  = vvaloroperacao - vservicos.
        */
      end.
    /**/
        /* helio 25052023 */
      if contrato.tpcontrato = "N" or contrato.modcod = "CPN" 
      then do:
          vvaloroperacao = 0. 
          for each titulo where
                    titulo.empcod     = 19 and
                    titulo.titnat     = no and
                    titulo.modcod     = contrato.modcod and
                    titulo.etbcod     = contrato.etbcod and
                    titulo.clifor     = contrato.clicod and
                    titulo.titnum     = string(contrato.contnum) and 
                    titulo.titpar     >= 1 and
                    titulo.titdtemi   = contrato.dtinicial
                    no-lock.
            vvaloroperacao = vvaloroperacao + titulo.titvlcob.
          end.        
          vvaloroperacao = vvaloroperacao - vvalorseguro.
    end.
    
  put unformat skip 
      "10"            /* 01  - 02  TIPO  FIXO –1  */
      contrato.contnum format "9999999999" /* 03 - 12 NÚMERO OPERAÇÃO  */
      "0001"           /* 13 - 16 AGÊNCIA          */
      "06"            /* 17 - 18 MIDIA            */
      "000001"        /* 19 - 24 LOJISTA          */
      contrato.etbcod format "9999"      /* 25-28 LOJA  */
      vcod-produto format "9999" 
      " " format "x(02)"                  /* 29-34 PRODUTO */
      vplano-fin /*contrato.crecod*/ format ">>>9"      /* 35-38 PLANO    */
      contrato.nro_parcelas format ">>9"   /* prazo */
      vdtinicial format "99999999"  /* 42-49 DATA EMISSÃO */
      vtitdtven format "99999999" /* 50-57 DATA 1° VENCIMENTO */ 
      
      /* helio 18/01/2023 - novo campo
        ((vvlf_principal /* Helio 29112022 ID 156242 retirado-> - vservicos*/) * 100) format "99999999999999999"
      */
      /* helio 18/01/2023 - novo campo */
      vvaloroperacao * 100 format "99999999999999999"
      /**/

      ((vtitvltot /*- titulo.titdesc*/) * 100) format "999999999999999999" /* 75-92 VALOR PRESTAÇÃO */
      " " format "x(20)"                 /* SOMENTE P/ CONVENIOS */
      vtipocontratosicred format "x(2)"    /* 113-114 TIPO CONTRATO */ /* helio 19072022 - projeto Criar Produtos - ADM - tipoontratoSicred */

     (contrato.VlIof * 100) format "99999999999999999" /* 115-131 VLR DO IOF */
     (contrato.TxJuros * 1000000) format "999999999"  /* 132-140 TAXA NOMINAL */
      if poperacao = "NOVACAO" then "S" else " "                  format "x(10)"       /* 141-150 CONTRATO RENEG */
      (contrato.Cet * 1000000)    format "999999999"         /* 151-159 CET */
      " "                 format "x(38)"             /* 160 - 197 FILLER */
      contrato.vltaxa * 100    format "99999999999999999" /* 198 - 214 VALOR TFC */

      /* helio 18/01/2023 - novo campo
      vservicos * 100   format "99999999999999999" /* 215 - 231 VAL SEGURO*/
      **/
      /* helio 18/01/2023 - novo campo */
      vvalorseguro * 100   format "99999999999999999"
      /**/
        
      " "                 format "x(563)"            /* 238 - 794 FILLER */
      vseq format    "999999".

end procedure.

/* parcelas do contrato */
procedure p-registro-11.

    vseq = vseq + 1.

    /* #18082022 */
    vtitvltot = if btitulo.titvltot <> 0 then btitulo.titvltot else btitulo.titvlcob.
    vtotal = vtotal + vtitvltot.

  /* Vencimento c/Data Especial ou Nao */

  /**
  assign v-data-comerc = yes.
  assign v-data-vecto = btitulo.titdtven.  
  *run p-verif-data
            (input v-data-vecto, output vdata-retorno, output v-data-comerc).
  if v-data-comerc = no and vdata-retorno <> ?
  then assign v-data-vecto = vdata-retorno.
  **/
    def buffer ctitulo for titulo.
    def var vparcela like titulo.titpar.
    vparcela = btitulo.titpar.
    if vparcela > 30
    then do:
        find first ctitulo where
                   ctitulo.empcod = btitulo.empcod and
                   ctitulo.titnat = btitulo.titnat and
                   ctitulo.modcod = btitulo.modcod and
                   ctitulo.etbcod = btitulo.etbcod and
                   ctitulo.clifor = btitulo.clifor and
                   ctitulo.titnum = btitulo.titnum and
                   ctitulo.titpar > 30 and
                   ctitulo.titpar < 51
                   no-lock no-error.
        if avail ctitulo
        then vparcela = vparcela - 30.
        else if vparcela < 51
            then vparcela = vparcela - 30.
            else vparcela = vparcela - 50.
            
        if vparcela = ? or vparcela <= 0
        then vparcela = btitulo.titpar.   
  end.

  put unformat skip
     "11"                   /* 01-02 fixo "11" */
     dec(btitulo.titnum) format "9999999999" /* 03 - 12 OPERAÇÃO */
     "0001"                            /* 13 - 16 AGÊNCIA */
     vparcela format "999"        /* 17 - 19 PARCELA */
     if btitulo.titdtven = btitulo.titdtemi then btitulo.titdtven + 1 else btitulo.titdtven  format "99999999" /* 20 - 27 dt VENCIMENTO */
     ((vtitvltot /*- btitulo.titdesc*/) * 100) 
                format "999999999999" /* 28-39 VLR PRESTAcaO */
     fill("0",30) format "x(30)"       /* 40-69 CMC7: nro do cheque pre */
     " " format "x(725)"               /* 70 - 794 FILLER */
     vseq format    "999999".

    /* arquivo de controle */
    
    find envfinan where envfinan.empcod = btitulo.empcod
                    and envfinan.titnat = btitulo.titnat
                    and envfinan.modcod = btitulo.modcod
                    and envfinan.etbcod = btitulo.etbcod
                    and envfinan.clifor = btitulo.clifor
                    and envfinan.titnum = btitulo.titnum
                    and envfinan.titpar = btitulo.titpar
                    exclusive-lock no-error.
    if not avail envfinan
    then do: 
         create envfinan.
         assign envfinan.empcod = btitulo.empcod
                envfinan.titnat = btitulo.titnat
                envfinan.modcod = btitulo.modcod
                envfinan.etbcod = btitulo.etbcod
                envfinan.clifor = btitulo.clifor
                envfinan.titnum = btitulo.titnum
                envfinan.titpar = btitulo.titpar.
    end.
    assign envfinan.envdtinc = today
           envfinan.envhora = time
           envfinan.datexp  = today
           envfinan.envsit  = "INC"
           /*
           envfinan.txjuro = txjuro
           envfinan.envcet = dvalorcetanual
           envfinan.enviof = viof
           */
           envfinan.lotinc = vlote
           envfinan.lotpag = 0
           envfinan.lotcan = 0 .

    find current envfinan no-lock.
    
    if btitulo.cobcod <> vcobcoddes
    then  run p-grava-cobcod (input string(rowid(btitulo))).
    

end.

/* LIBERAÇÃO PARA O CLIENTE (Obrigatório para empréstimo Pessoal) */
PROCEDURE p-registro-12.


    def var vbanco          as integer.
    def var vagencia        as integer.
    def var vconta          as character.
    def var vtipo_conta     as character.
    def var vcpf_cgc_desti  as character.
    def var vnome_desti     as char.
    
    assign vseq = vseq + 1.

    vbanco      = int(substring(string(int(contcp.banco),"99999"),3,3)). /* helio 23032023 */
    vagencia    = int(contcp.agencia).
    if length(string(vagencia)) = 5
    then do:
        vagencia = int(substring(string(vagencia,"99999"),1,4)).
    end.
    vconta      = contcp.numeroconta.
    vtipo_conta = contcp.tipoconta.
    
    /* helio 16122021 - Chamado 101510 - 75460 - Alteração CPF arquivo Financeira 
    *vcpf_cgc_desti = if contcp.cpfdesti = ?    or contcp.cpfdesti = 0
    *          then clien.ciccgc
    *          else string(contcp.cpfdesti).
    */
    /* helio 16122021 - Chamado 101510 - 75460 - Alteração CPF arquivo Financeira */
    vcpf_cgc_desti = clien.ciccgc.
    
    run Pi-cic-number(input-output vcpf_cgc_desti).
    vnome_desti = if contcp.nomedesti = ? or contcp.nomedesti = ""
                  then clien.clinom
                  else contcp.nomedesti.

 /* 17.06 le a nota para pegar o valor dos servicos */
    vservicos = 0.
    find contnf where 
            contnf.etbcod = contrato.etbcod and
            contnf.contnum = contrato.contnum no-lock no-error.
    if avail contnf
    then do:
        find plani where plani.etbcod = contnf.etbcod and
                         plani.placod = contnf.placod
                         no-lock no-error.
        if avail plani
        then do:
            /**** https://trello.com/c/CmK7IUZ1/17-valor-liberado-divergente
            vservicos = plani.vlserv - 
                        if contrato.modcod = "CP0" or
                           contrato.modcod = "CP1"
                        then (contrato.vlf_principal - plani.seguro)
                        else 0.
            ******/

            if contrato.modcod = "CP0" or contrato.modcod = "CP1"
            then vvlf_principal = plani.protot + plani.vlserv.
            
            vservicos = plani.vlserv. 

            if contrato.modcod = "CP0" or 
               contrato.modcod = "CP1" 
            then do:
                vservicos = if plani.seguro = ?
                            then 0
                            else plani.seguro. 
            end.

        end.
    end.            
    
    if contrato.modcod = "CP0" or
       contrato.modcod = "CP1"
    then.
    else    
    vvlf_principal = if contrato.vlf_principal = 0
                     then contrato.vltotal - contrato.vlentra - contrato.vliof
                     else if poperacao = "NOVACAO"
                          then contrato.vlf_principal - contrato.vlentra
                          else contrato.vlf_principal.
     
    if vvlf_principal < vservicos
    then do:
        vvlf_principal = vservicos.
        vservicos = 0.
    end.

   
    put unformat skip           
    "12"                                     /*01 - 02 Tipo de registro*/
    vbanco              format "999"         /*03 - 05 Banco*/
    vagencia            format "9999"        /*06 - 09 Agencia*/
    vconta              format "x(15)"       /*10 - 24 Conta*/
    vtipo_conta         format "x(1)"        /*25 - 25 Tipo de Conta*/
    ((vvlf_principal - vservicos ) * 100) format "99999999999999999"
    vcpf_cgc_desti     format "x(14)"       /*43 - 56 CPF ou CGC Destinatario*/
    vnome_desti        format "x(40)"       /*57 - 96 Nome Destinario*/ 
    "5"                 format "x(1)"        /*97 - 97 Tipo de Liberacao*/
    " "                 format "x(697)"      
    vseq format    "999999".
        .


end procedure.

/* CONTRATOS RENEGOCIADOS */
procedure p-registro-13:
    for each ttnovacao. delete ttnovacao. end.
    find first pdvmov where 
                    pdvmov.etbcod = sicred_contr.etbcod and
                    pdvmov.cmocod = sicred_contr.cmocod and
                    pdvmov.datamov = sicred_contr.datamov and
                    pdvmov.sequencia = sicred_contr.sequencia
                no-lock no-error.
    if avail pdvmov
    then     run fin/montattnov.p (recid(pdvmov),no).
    
    for each ttnovacao where ttnovacao.tipo = "ORIGINAL".
        vseq = vseq + 1.
        put unformat skip
        "13"                   /* 01-02 fixo "13" */
        dec(ttnovacao.contnum) format "9999999999" /* 03 - 12 OPERAÇÃO */
        "0001"                            /* 13 - 16 AGÊNCIA */
        (ttnovacao.valor * 100)
                    format "99999999999999999"  /* 17 - 33 PARCELA */
        " " format "x(20)"  /* 34 - 53*/
        " " format "x(740)"               /* 54 - 794 FILLER */
        vseq format    "999999".

        run p-registro-14.

    end.
    
end procedure.

/* PARCELAS RENEGOCIADAS */
procedure p-registro-14:
def buffer bcontrato for contrato.
    find first pdvmov where 
                    pdvmov.etbcod = sicred_contr.etbcod and
                    pdvmov.cmocod = sicred_contr.cmocod and
                    pdvmov.datamov = sicred_contr.datamov and
                    pdvmov.sequencia = sicred_contr.sequencia
                no-lock no-error.
    if avail pdvmov
    then for each pdvdoc of pdvmov where
             pdvdoc.contnum = string(ttnovacao.contnum) no-lock.
            find bcontrato where bcontrato.contnum = int(pdvdoc.contnum) no-lock. 
            find titulo where titulo.contnum = bcontrato.contnum and
                              titulo.titpar  = pdvdoc.titpar
                              no-lock no-error.
                if not avail titulo
                then do:
                    find first titulo where
                    titulo.empcod     = 19 and
                    titulo.titnat     = no and
                    titulo.modcod     = bcontrato.modcod and
                    titulo.etbcod     = bcontrato.etbcod and
                    titulo.clifor     = bcontrato.clicod and
                    titulo.titnum     = string(bcontrato.contnum) and 
                    titulo.titpar     = pdvdoc.titpar and
                    titulo.titdtemi   = bcontrato.dtinicial
                    no-lock no-error.
                end.
                              
            vseq = vseq + 1.
            put unformat skip
            "14"                   
            dec(pdvdoc.contnum) format "9999999999"
            "0001"                            /* 13 - 16 AGÊNCIA */
            /* helio 122020 44132*/
            if pdvdoc.titpar >= 31 then pdvdoc.titpar - 30 else pdvdoc.titpar format "999"
            /*44132*/
            if titulo.titdtven = titulo.titdtemi then titulo.titdtven + 1 else titulo.titdtven  format "99999999" /* helio 18052023 */
            (pdvdoc.titvlcob * 100) format "999999999999"
            string(pdvdoc.datamov,"99999999") format "99999999"
            " " format "x(20)"  /* 34 - 53*/
            "000"
            " " format "x(723)"               /* 71 - 794 FILLER */
            vseq format    "999999".

    end.

end procedure.


/* Trailer da Operação */
procedure p-registro-98.
  vseq = vseq + 1.
  put unformat skip
     "98"                   /* 01-02 fixo "98" */
     " " format "x(792)"    /* 03-794 FILLER   */
     vseq format    "999999".

end procedure.

/* Trailer */
procedure p-registro-99.
  vseq = vseq + 1.
  put unformat skip
     "99"                                 /* 01-02 fixo "99" */
     varqexp format "x(8)"                /* 03-10 Nome do arquivo */
     string(today,"99999999")             /* 11-18 data movimento */
     vqtoper format "9999999999"          /* 19-28 QTD DE OPERAÇÕES */
     vtotal  format "99999999999999999"   /* 29-45 VLR TOTAL das OPERAÇÕES */
     " " format "x(749)"                  /* 46-794 FILLER */
     vseq format    "999999" skip.
     
   find lotefin where lotefin.lotnum = vlote exclusive-lock no-error.
   
   if not avail lotefin
   then do:
        create lotefin.
        assign lotefin.lotnum = vlote
               lotefin.lottip = "Inc".
   end.
   assign lotefin.datexp = today
          lotefin.hora = time
          lotefin.lotqtd = vqtoper
          lotefin.lotvlr = vtotal.
   find current lotefin no-lock.
end procedure.


Procedure Pi-cic-number.

    def input-output  parameter p-ciccgc  like clien.ciccgc.
    def var v-ciccgc like clien.ciccgc.
    def var jj          as int.
    def var ii          as int.
    def var v-carac     as char format "x(1)".

    assign v-ciccgc = "".
    do ii = 1 to length(p-ciccgc):
        assign v-carac = string(substr(p-ciccgc,ii,1)).
        do jj = 1 to 10:
            if string(jj - 1) = v-carac then assign v-ciccgc = v-ciccgc +
                         v-carac.
        end.
    end.
    assign p-ciccgc = v-ciccgc.
end procedure.


procedure p-grava-cobcod:

    define input parameter vcha-rowid as character.
    define buffer bf1-titulo for titulo.

    find first bf1-titulo where rowid(bf1-titulo) = to-rowid(vcha-rowid) 
                                        exclusive-lock no-error.   
    
    if available bf1-titulo
    then do:
        create titulolog.
        assign
            titulolog.empcod = bf1-titulo.empcod
            titulolog.titnat = bf1-titulo.titnat
            titulolog.modcod = bf1-titulo.modcod
            titulolog.etbcod = bf1-titulo.etbcod
            titulolog.clifor = bf1-titulo.clifor
            titulolog.titnum = bf1-titulo.titnum
            titulolog.titpar = bf1-titulo.titpar
            titulolog.data    = today
            titulolog.hora    = time
            titulolog.funcod  = sfuncod
            titulolog.campo   = "CobOri,CobCod"
            titulolog.valor   = string(bf1-titulo.cobcod) + "," + string(vcobcoddes).
            titulolog.obs     = "Troca Carteira".
        assign bf1-titulo.cobcod = vcobcoddes.

    end.
    find current bf1-titulo no-lock.
    
    
end procedure.

 

procedure achacobcod.
def output param vcod-produto as int.
def var vlebes as log.
def var vsicred as log.
def buffer bcontrato for contrato.
    find first pdvmov where 
                    pdvmov.etbcod = sicred_contr.etbcod and
                    pdvmov.cmocod = sicred_contr.cmocod and
                    pdvmov.datamov = sicred_contr.datamov and
                    pdvmov.sequencia = sicred_contr.sequencia
                no-lock  no-error.

    for each ttcob.
        delete ttcob.
    end.    
    if avail pdvmov
    then for each pdvdoc of pdvmov no-lock.
        for each sicred_pagam where sicred_pagam.etbcod = pdvdoc.etbcod and 
                                    sicred_pagam.cmocod = pdvdoc.cmocod and
                                    sicred_pagam.datamov = pdvdoc.datamov and
                                    sicred_pagam.sequencia = pdvdoc.sequencia and
                                    sicred_pagam.ctmcod = pdvdoc.ctmcod and
                                    sicred_pagam.seqreg = pdvdoc.seqreg
                no-lock.
            find bcontrato where bcontrato.contnum = int(pdvdoc.contnum) no-lock. 
            find btitulo where btitulo.contnum = bcontrato.contnum and
                              btitulo.titpar  = pdvdoc.titpar
                              no-lock no-error.
                if not avail btitulo
                then do:
                    find first btitulo where
                    btitulo.empcod     = 19 and
                    btitulo.titnat     = no and
                    btitulo.modcod     = bcontrato.modcod and
                    btitulo.etbcod     = bcontrato.etbcod and
                    btitulo.clifor     = bcontrato.clicod and
                    btitulo.titnum     = string(bcontrato.contnum) and 
                    btitulo.titpar     = pdvdoc.titpar and
                    btitulo.titdtemi   = bcontrato.dtinicial
                    no-lock no-error.
                end.
                
                find first ttcob where ttcob.cobcod = btitulo.cobcod no-error.
                if not avail ttcob
                then do:
                    create ttcob.
                    ttcob.cobcod = btitulo.cobcod.
                end.
                
                
        end.
    end.      
            vlebes  = no.
            vsicred = no.
            for each ttcob.
                find cobra where cobra.cobcod = ttcob.cobcod no-lock.
                if cobra.sicred = no
                then vlebes = yes.
                else vsicred = yes.
                delete ttcob. 
            end.
            if vlebes
            then do:
                if vsicred 
                then vcod-produto = 9.
                else vcod-produto = 7.
            end.
            else vcod-produto = 8.
       

end procedure.

procedure p-verif-data. /* 19022021 */

def input  parameter p-data-verifica as date.
def output parameter p-data-retorno  as date.
def output parameter p-data-comerc as logical.
def var vdata-aux as date.
def var vdia as int.

assign  p-data-comerc = yes
        vdia = weekday(p-data-verifica)
        p-data-retorno = ?.

/* 1) Verifica especial */

if vdia = 1 or vdia = 7 /* Sabado ou Domingo */
then assign p-data-comerc = no.
else do:               /*  Feriado */
    find first dtextra where dtextra.exdata = p-data-verifica no-lock no-error.
    if avail dtextra then p-data-comerc = no.
end.

/* 2) Acha Proxima Data Comercial */
if p-data-comerc = no
then do vdata-aux = (p-data-verifica + 1) to (p-data-verifica + 30) :
         find first dtextra where dtextra.exdata = vdata-aux no-lock no-error.
         if avail dtextra then next.
         if weekday(vdata-aux) = 1 or weekday(vdata-aux) = 7 then next.
         assign p-data-retorno = vdata-aux.
         leave. 
     end.

end procedure.

