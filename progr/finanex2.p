{admcab.i}
    
def temp-table tt-estab
       field etbcod as int
       index ind1 etbcod.

def temp-table tt-contrato
    field clicod like contrato.clicod
    field contnum like contrato.contnum
index k1 clicod    
         contnum.

def buffer btitulo for titulo.

def var varquivo   as char.
def var varqexp    as char.
def var vparval    as dec format ">>>,>>9.99".
def var vparmeta   as dec format ">>,>>>,>>9.99".
def var vlmontante as dec format ">>,>>>,>>9.99".  /* Apurado */
def var vlmaiorproc as dec format ">>,>>>,>>9.99". /* Apurado */
def var vlmenorproc as dec format ">>,>>>,>>>,>>9.99". /* Apurado */
def var vqmontante  as int.                        /* Apurado */
def var v-flg-ok    as logical format "sim/nao".
 
def var vseq as int.
def var vqtoper  as int.
def var vtotal   as dec.
def var vlote as int.

def var vetbcod  like estab.etbcod.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var vclicod  like clien.clicod.
def var vclinom  like clien.clinom.
def var vdata-retorno as date.
def var v-data-vecto   as date. 
def var v-data-comerc as logical format "Comercial/Especial".


def var dvalorcet as dec decimals 6 format "->,>>9.999999". 
def var dvalorcetanual as dec decimals 6 format "->,>>9.999999".  
def var viof as dec.
def var vjuro as dec.
def var txjuro as dec.
  
def new shared temp-table tttitulo
      field titdtven  as date
      field titvlcob  like titulo.titvlcob.

varqexp = "op" + string(today,"999999") + ".rem".

if opsys = "unix"
then varquivo = "/admcom/relat/" + varqexp.
else varquivo = "l:~\relat~\" + varqexp.

FUNCTION f-troca returns character
    (input cpo as char).
    def var v-i as int.
    def var v-lst as char extent 60
       init ["@",":",";",".",",","*","/","-",">","!","'",'"',"[","]"].
         
    if cpo = ?
    then cpo = "".
    else do v-i = 1 to 30:
         cpo = replace(cpo,v-lst[v-i],"").
    end.
    return cpo. 
end FUNCTION.

       
repeat:
    
    update vetbcod label "Filial" colon 16
                with frame f1 side-label width 70 centered 
                title "Parametros de Processamento".

    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.
   
    update vclicod label "Cliente" colon 16 with frame f1.

    if vclicod > 0
    then do:                 
        find first clien where clien.clicod = vclicod 
                    no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = "Cliente nao encontrado".   
    end.
    else do: 
         vclinom = "GERAL".
    end.
    
    disp vclinom no-label with frame f1.
    
    do on error undo, retry:
          update vdti label "Data  Inicial" colon 16
                 vdtf label "Data  Final  " colon 16 with frame f1.
          if  vdti > vdtf
          then do:
                message "Data inválida".
                undo.
            end.
          update vparval  label "Contratos Acima de R$" colon 24
                 vparmeta label "Val.Desejado p/Remessa R$"  colon 28                    with frame f1.
     
     
     end. 
  disp varquivo    label "Arquivo"   colon 16 format "x(50)"
      with frame f1.

    for each tt-estab: delete tt-estab. end.
   
    for each estab  where if vetbcod = 0 
                         then true
                     else (estab.etbcod = vetbcod) 
                     no-lock:
        if vetbcod =  0
        then if estab.etbcod = 22 or 
                estab.etbcod > 995 then next.
                       
        create tt-estab.
        assign tt-estab.etbcod = estab.etbcod.             
    end.
    
    /* Controle de Lote Ideal */
    assign vlmontante  = 0
           vqmontante  = 0
           vlmaiorproc = 0 
           vlmenorproc = 99999999999.99.
    for each tt-contrato:
            delete tt-contrato.
    end.
    run Pi-Processa-Teto (output v-flg-ok).
    if v-flg-ok = yes then next.
    /**/
     
    output to value(varquivo) page-size 0.

    run p-registro-00.

    def var TESTEIG AS INT.

    assign vqtoper = 0
           vtotal = 0.

    for each tt-estab no-lock,
        each contrato where contrato.etbcod = tt-estab.etbcod 
                        and contrato.dtinicial >= vdti
                        and contrato.dtinicial <= vdtf
               no-lock,
        first clien where clien.clicod = contrato.clicod no-lock:
        
          /* Antonio */
        find first tt-contrato where tt-contrato.clicod  = contrato.clicod and
                                     tt-contrato.contnum = contrato.contnum 
                                     use-index k1 no-error.
        if not avail tt-contrato then next.                             
        /**/
        
 
       find first contnf where contnf.etbcod = contrato.etbcod and
                               contnf.contnum = contrato.contnum
                             no-lock no-error.
       find first plani where plani.pladat = contrato.dtinicial and
                             plani.etbcod = contrato.etbcod
                 and plani.placod = contnf.placod
                 and plani.dest = contrato.clicod
                 and plani.movtdc = 5 no-lock no-error.
       
        if not avail plani then next.

        if (plani.biss - plani.platot) < 2 then next.
        
        find finan where finan.fincod = contrato.crecod
                    no-lock no-error.
        
        if not avail finan then next.            

        find first titulo where 
                       titulo.empcod = 19    and 
                       titulo.titnat = no    and
                       titulo.modcod = "CRE" and      
                       titulo.etbcod = contrato.etbcod and
                       titulo.clifor = contrato.clicod and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titpar = 1 and
                       titulo.titsit = "lib"
                       no-lock no-error.
                       
        if not avail titulo
        then next.

        run calciof.p(input rowid(contrato), 
                      output viof, output vjuro, output txjuro).
        run bscalccet.p (input (contrato.vltotal - (viof + vjuro)) , 
                         input  contrato.dtinicial,
                         output dvalorcet,
                         output dvalorcetanual
                            ).
 
        if txjuro  = ? then txjuro = 0.      
        
        if txjuro = 0 then next.
        
        if viof = ? then viof = 0.
        if dvalorcet = ? then dvalorcet = 0.
        if dvalorcetanual = ? then dvalorcetanual = 0.                    
        
        run p-registro-01.
        run p-registro-02.
        run p-registro-03.
        run p-registro-04.    
        run p-registro-10.    

        for each btitulo where 
                           btitulo.empcod = 19  and 
                           btitulo.titnat = no   and
                           btitulo.modcod = "CRE" and      
                           btitulo.etbcod = contrato.etbcod and
                           btitulo.clifor = contrato.clicod and
                           btitulo.titnum = string(contrato.contnum) and
                           btitulo.titpar > 0  and
                           btitulo.titsit = "lib"
                       no-lock.

             run p-registro-11.
        end.   
        run p-registro-98. 

    end.        
        
    run p-registro-99.

    output close.
/*
    run visurel.p(varquivo,"").

def var vx as char.
input from value(varquivo).
repeat:
    import unformat vx.
    disp  length(vx) 
         vx format "x(110)"
         substring(vx,790,20) format "x(20)" 
           with frame fx width 130 5 down.
end.
*/

    if opsys = "unix"
    then do.
        unix silent unix2dos value(varquivo). 
        unix silent chmod 777 value(varquivo).
    end.
end.

/* header */
procedure p-registro-00.
     def buffer blotefin for lotefin.

     vseq = 1.
     put unformat skip
         "00" 
         varqexp format "x(08)"
          string(today,"99999999")
          "0001"    /* 19 - 22 NUMÉRICO        AGÊNCIA ??? */
          "LEBES" format "x(6)" /* 23 - 28 ALFANUMÉRICO    LOJISTA ??? */
          vetbcod format ">>>9"   /* 29-32 LOJA (UM ARQ. P/FILIAL??) */
          " " format "x(762)" 
          vseq format "999999" /* NUMERICO  Sequencia do arquvo???? */
          .
   find last Blotefin exclusive-lock no-error.
   create lotefin.
   assign lotefin.lotnum = (if avail Blotefin 
                             then Blotefin.lotnum + 1
                             else 1)
          lotefin.lottip = "INC".
          
   assign vlote = lotefin.lotnum.                         

end procedure.

/* indentificação */
procedure p-registro-01.
def var vestciv as char init "SCVJD".

vseq = vseq + 1.

put unformat skip
     "01"
     (if clien.tippes then "F" else "J") format "x(1)" 
     dec(f-troca(clien.ciccgc))    format "99999999999999"
     f-troca(clien.clinom)  format "x(40)"
     f-troca(clien.mae)    format "x(40)"
     f-troca(clien.pai)    format "x(40)"
    (if clien.estciv > 0 and clien.estciv < 6
     then substring(vestciv,clien.estciv,1) else "S") 
     string(clien.sexo,"M/F")
     clien.numdep format "99"         /*  140 - 141 */
     string(clien.dtnasc,"99999999")  /* 142 - 149  */
     clien.natur format "x(20)"       /*  150 - 169 */
     clien.natur format "x(2)"        /* 170 - 171  */
      (if clien.nacion begins "br" then "BR" else "ES") /* 172 - 173 */
     string(clien.ciins) format "x(15)"    /* 174 - 188 */
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

vseq = vseq + 1.

  
put unformat skip 
   "02"  
    "0" format "x(14)"                /*  03 - 16 CPF DO CÔNJUGE  */
    f-troca(clien.conjuge) format "x(40)"    /* 17 - 56 NOME DO CÔNJUGE  */
    f-troca(string(clien.nascon)) format "99999999" /* 57-64 DATA NASCIMENTO */
    "    "                            /* 65 - 68  PROFISSÃO */
    f-troca(clien.proprof[1])  format "x(15)"  /* 69 - 83  CARGO  */
    f-troca(string(clien.prorenda[1])) format "999999999999"  /* 84-95 RENDA */
    f-troca(string(clien.prodta[1]))  format "99999999" /* 96-103 DT DE ADM */
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
end procedure.

/* patrimonio */
procedure p-registro-06.
end procedure.

 /* observacao */
procedure p-registro-07.
end procedure.

/* OPERACAO */
procedure p-registro-10.

  vseq = vseq + 1.
  vqtoper = vqtoper + 1.

  /* Vencimento c/Data Especial ou Nao */
  assign v-data-comerc = yes.
  assign v-data-vecto = titulo.titdtven.  
  run p-verif-data
            (input v-data-vecto, output vdata-retorno, output v-data-comerc).
  if v-data-comerc = no and vdata-retorno <> ?
  then assign v-data-vecto = vdata-retorno.
  /**/
  
  put unformat skip 
      "10"            /* 01  - 02  TIPO  FIXO –1  */
      contrato.contnum format "9999999999" /* 03 - 12 NÚMERO OPERAÇÃO  */
      "0001"           /* 13 - 16 AGÊNCIA          */
      "06"            /* 17 - 18 MIDIA            */
      "000001"        /* 19 - 24 LOJISTA          */
      "0001" /* contrato.etbcod format "9999" */     /* 25-28 LOJA  */
      "0001" format "x(6)"                  /* 29-34 PRODUTO ???  */
      contrato.crecod format ">>>9"      /* 35-38 PLANO    */
      finan.finnpc    format ">>9"       /* 39-41 PRAZO ???   */
      titulo.titdtemi format "99999999"  /* 42-49 DATA EMISSÃO */
      v-data-vecto    format "99999999"  /* 50-57 DATA 1° VENCIMENTO */
      ((plani.platot - contrato.vlentr) * 100) /* (plani.platot * 100) */
                      format "99999999999999999"   /* 58-74 VALOR DA OPERAÇÃO */
      (titulo.titvlcob * 100) format "999999999999999999"
                                         /* 75-92 VALOR PRESTAÇÃO */
      " " format "x(20)"                 /* SOMENTE P/ CONVENIOS */
      "N "                               /* 113-114 TIPO CONTRATO */
      /*******************************
      (viof * 100) format "99999999999999999"  /* 115-131 VLR DO IOF */
      *******************************/
      0            format "99999999999999999"  /* 115-131 VLR DO IOF */
      /******************************
      (txjuro * 1000000)  format "999999999"   /* 132-140 TAXA NOMINAL  */
      *******************************/
      0                   format "999999999"   /* 132-140 TAXA NOMINAL  */
      " "                 format "x(10)"       /* 141-150 CONTRATO RENEG */
      /******************************
      (dvalorcetanual * 1000000) format "999999999"  /* 151-159 CET */
      ******************************/
      0                          format "999999999"  /* 151-159 CET */
      " " format "x(635)" /* 160 - 794 FILLER */
      vseq format    "999999".

end procedure.

/* parcelas do contrato */
procedure p-registro-11.

 vseq = vseq + 1.
 vtotal = vtotal + btitulo.titvlcob.

  /* Vencimento c/Data Especial ou Nao */
  assign v-data-comerc = yes.
  assign v-data-vecto = btitulo.titdtven.  
  run p-verif-data
            (input v-data-vecto, output vdata-retorno, output v-data-comerc).
  if v-data-comerc = no and vdata-retorno <> ?
  then assign v-data-vecto = vdata-retorno.
  /**/

 put unformat skip
     "11"                   /* 01-02 fixo "11" */
     dec(btitulo.titnum) format "9999999999" /* 03 - 12 OPERAÇÃO */
     "0001"                            /* 13 - 16 AGÊNCIA */
     btitulo.titpar format "999"        /* 17 - 19 PARCELA */
     /* btitulo.titdtven format "99999999" /* 20 - 27 dt VENCIMENTO */ */
     v-data-vecto        format "99999999" /* 20 - 27 dt VENCIMENTO */
     (btitulo.titvlcob * 100) format "999999999999" /* 28-39 VLR PRESTAcaO */
     fill("0",30) format "x(30)"       /* 40-69 CMC7: nro do cheque pre */
     " " format "x(725)"               /* 70 - 794 FILLER */
     vseq format    "999999".
     
 /* arquivo de controle */
    
    find envfinan where envfinan.empcod = titulo.empcod
                    and envfinan.titnat = titulo.titnat
                    and envfinan.modcod = titulo.modcod
                    and envfinan.etbcod = titulo.etbcod
                    and envfinan.clifor = titulo.clifor
                    and envfinan.titnum = titulo.titnum
                    and envfinan.titpar = titulo.titpar
                    exclusive-lock no-error.
    if not avail envfinan
    then do: 
         create envfinan.
         assign envfinan.empcod = titulo.empcod
                envfinan.titnat = titulo.titnat
                envfinan.modcod = titulo.modcod
                envfinan.etbcod = titulo.etbcod
                envfinan.clifor = titulo.clifor
                envfinan.titnum = titulo.titnum
                envfinan.titpar = titulo.titpar.
    end.
                   
    assign envfinan.envdtinc = today
           envfinan.envhora = time
           envfinan.datexp   = today
           envfinan.envsit  = "INC"
           envfinan.txjuro = txjuro
           envfinan.envcet = dvalorcetanual
           envfinan.enviof = viof
           envfinan.lotinc = vlote
           envfinan.lotpag = 0
           envfinan.lotcan = 0.

end.

/* LIBERAÇÃO PARA O CLIENTE (Obrigatório para empréstimo Pessoal) */
PROCEDURE p-registro-12.
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

end procedure.

procedure p-verif-data.

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




/*******
 
 def var vx as char.
 input from /admcom/relat/op040309.rem.
repeat:
    import unformat vx.              
    if substring(vx,1,2) <> "10" and substring(vx,1,2) <> "11" then next.

    disp vx format "x(2)" column-label "Tp".
    if substring(vx,1,2) = "10"
    then do:
        find contrato where contrato.contnum = 
                      int(substring(vx,3,10)) no-lock no-error.
        disp contrato.contnum                .
                      
        disp 
         /*    dec (substring(vx,75,18)) / 100 format ">>>,>>9.99"
                column-label "r10-75" */
          contrato.vltotal column-label "CTotal" format ">>>9.99"
           contrato.vlentra column-label "Entr" format ">>>9.99"
    dec(substring(vx,58,17)) / 100 format ">>>>9.99" 
                    column-label "r10-58"
    dec(substring(vx,115,17)) / 100 format ">>>9.99" 
                    column-label "r10-115"
    dec(substring(vx,132,17)) / 1000000 format ">>>9.99" 
                    column-label "r10-132"
    dec(substring(vx,151,17)) / 1000000 format ">9.9999" 
                    column-label "r10-151"
                .
    end.            
    if substring(vx,1,2) = "11"
    then disp dec(substring(vx,28,12)) / 100 format ">>>,>>9.99" 
                column-label "r11-28(par)"
                .
                 
/*         substring(vx,29) format "x(6)"  column-label "29" */
end.         

*****/

/* Antonio */
Procedure Pi-Processa-Teto.

def output parameter p-ok as logical.
def var v-ok as logical format "Sim/Nao".
p-ok = no.
disp "Aguarde Selecao...." with frame f-proc centered no-box.
pause 0 before-hide.
for each tt-estab no-lock,
        each contrato where contrato.etbcod = tt-estab.etbcod 
                        and contrato.dtinicial >= vdti
                        and contrato.dtinicial <= vdtf
               no-lock,
        first clien where clien.clicod = contrato.clicod no-lock:
        
        if vclicod <> 0 and 
        clien.clicod <> vclicod 
        then next.
 
        find first contnf where contnf.etbcod = contrato.etbcod and
                               contnf.contnum = contrato.contnum
                             no-lock no-error.
        find first plani where plani.pladat = contrato.dtinicial
                         and plani.etbcod = contrato.etbcod
                         and plani.placod = contnf.placod
                         and plani.dest = contrato.clicod
                         and plani.movtdc = 5 no-lock no-error.
       
        if not avail plani then next.

        if (plani.biss - plani.platot) < 2 then next.
 
        find finan where finan.fincod = contrato.crecod
                    no-lock no-error.
        
        if not avail finan then next.            

        find first titulo where 
                       titulo.empcod = 19    and 
                       titulo.titnat = no    and
                       titulo.modcod = "CRE" and      
                       titulo.etbcod = contrato.etbcod and
                       titulo.clifor = contrato.clicod and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titpar = 1 and
                       titulo.titsit = "lib"
                       no-lock no-error.
                       
        if not avail titulo
        then next.

        run calciof.p(input rowid(contrato), 
                      output viof, output vjuro, output txjuro).
        run bscalccet.p (input (contrato.vltotal - (viof + vjuro)) , 
                         input  contrato.dtinicial,
                         output dvalorcet,
                         output dvalorcetanual
                            ).
 
        if txjuro  = ? then txjuro = 0.      
        
        if txjuro = 0 then next.
        
        if viof = ? then viof = 0.
        if dvalorcet = ? then dvalorcet = 0.
        if dvalorcetanual = ? then dvalorcetanual = 0.                    
 
        /* Contratos com Valor superior ao parametro de Tela*/
        if plani.platot <= vparval 
        then next.
        /* Controle de Val. Teto de Remessa informado em Tela */
        if plani.platot + vlmontante > vparmeta
        then next.  
        assign vlmontante = vlmontante + plani.platot
               vqmontante = vqmontante + 1.
        if plani.platot > vlmaiorproc then vlmaiorproc = plani.platot.
        if plani.platot < vlmenorproc then vlmenorproc = plani.platot.      
 
        create tt-contrato.
        assign tt-contrato.clicod = contrato.clicod
               tt-contrato.contnum = contrato.contnum.

end.        
hide frame f-proc.     
disp vlmontante  label "Valor Total da  Remessa" skip
     vqmontante  label "Quantidade de Contratos" skip 
     vlmaiorproc label "Maior Valor de Contrato" skip
     vlmenorproc label "Menor Valor de Contrato" skip
     with frame f-pos-proc row 16 side-labels centered overlay
     Title "Valores Processado".

message "Deseja Buscar novamente Remessa Ideal ? " update v-ok .
if v-ok = yes then p-ok = yes.

end procedure.    
