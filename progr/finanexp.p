{admcab.i}
{setbrw.i}              
    
def temp-table tt-estab
       field etbcod as int
       index ind1 etbcod.
       
def temp-table tt-envfinan
    field empcod like envfinan.empcod 
    field titnat like envfinan.titnat
    field modcod like envfinan.modcod
    field etbcod like envfinan.etbcod 
    field clifor like envfinan.clifor 
    field titnum like envfinan.titnum 
    field titpar like envfinan.titpar
    field envdtinc like envfinan.envdtinc 
    field envhora like envfinan.envhora 
    field datexp  like envfinan.datexp 
    field envsit  like envfinan.envsit 
    field txjuro  like envfinan.txjuro
    field envcet  like envfinan.envcet
    field enviof  like envfinan.enviof 
    field lotinc  like envfinan.lotinc
    field lotpag  like envfinan.lotpag 
    field lotcan  like envfinan.lotcan
    index idx empcod titnat modcod etbcod clifor titnum titpar.

def temp-table tt-contrato 
    field etbcod  like estab.etbcod
    field contnum like contrato.contnum
    field marca   as char format "x"
    field clicod  like contrato.clicod 
    field valorav like plani.platot
    field valorto like contrato.vltotal
    field numparc like finan.finnpc
    index idx etbcod contnum.

    
def buffer btitulo for titulo.

def var varquivo as char.
def var varqexp  as char.

def var vseq as int.
def var vqtoper  as int.
def var vtotal   as dec.
def var vlote as int.
def var vtotalav as dec.
def var vtotalto as dec.
def var vetbcod  like estab.etbcod.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var vclicod  like clien.clicod.
def var vclinom  like clien.clinom.
def var vdata-retorno as date.
def var v-data-vecto   as date. 
def var v-data-comerc as logical format "Comercial/Especial".
def var vresp as log format "Sim/Nao".

def var dvalorcet as dec decimals 6 format "->,>>9.999999". 
def var dvalorcetanual as dec decimals 6 format "->,>>9.999999".  
def var viof as dec.
def var vjuro as dec.
def var txjuro as dec.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [""," Marca"," Marca tudo"," Envia arquivo "," "].
def var esqcom2         as char format "x(15)" extent 5
            initial [""," "," ","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 10 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def new shared temp-table tttitulo
      field titdtven  as date
      field titvlcob  like titulo.titvlcob.

form " " 
     tt-contrato.marca   no-label format "x"
     tt-contrato.etbcod  column-label "Fil"
     tt-contrato.contnum column-label "Contrato" format ">>>>>>>>>9"
     tt-contrato.clicod  column-label "Cod.Cliente"
     tt-contrato.valorav column-label "Valor sem Juros" 
     tt-contrato.valorto column-label "Valor com Juros" 
     tt-contrato.numparc column-label "N.Parc."
     " "
     with frame f-linha 6 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
varqexp = "op" + string(today,"999999") + ".rem".

if opsys = "unix"
then varquivo = "/admcom/relat/" + varqexp.
else varquivo = "f:~\relat~\" + varqexp.

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

def var vetbcod1 like estab.etbcod. 
def var qtd-cont as int.
def var tot-cont as int.
def var val-cont as dec.
repeat:
    
    for each tt-contrato:
        delete tt-contrato.
    end.    
    update vetbcod label "Filial de" colon 25
           vetbcod1 label "Ate" 
                with frame f1 side-label width 80.

    if vetbcod = 0 or
       vetbcod1 = 0
    then undo. /*display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.
    */
    update qtd-cont at 2 label "Quantidade de contratos"
           help "Informe a quntidade de contratos por filial" 
           val-cont  label "Valor minimo do contrato"
           help "Informe o valor minimo do contrato"
           with frame f1.
           
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
          update vdti label "Data Inicial" colon 16
                 vdtf label "Data Final" with frame f1.
          if  vdti > vdtf
          then do:
                message "Data inválida".
                undo.
          end.
    end. 
    disp varquivo    label "Arquivo"   colon 16 format "x(50)"
      with frame f1.

    update varquivo with frame f1.
    
    for each tt-estab: delete tt-estab. end.
   
    for each estab  where estab.etbnom BEGINS "DREBES-FIL"
                     no-lock:

        if estab.etbcod < vetbcod or
           estab.etbcod > vetbcod1
        then next.
        if estab.etbcod = 22 or
           estab.etbcod = 995
        then next.   
        /*   
        if vetbcod =  0
        then if estab.etbcod = 22 or 
                estab.etbcod > 995 then next.
        */               
        create tt-estab.
        assign tt-estab.etbcod = estab.etbcod.             
    end.
    
    /*
    output to value(varquivo) page-size 0.

    run p-registro-00.
    */
    
    def var TESTEIG AS INT.

    assign vqtoper = 0
           vtotal = 0.

    for each tt-estab no-lock:
        
        tot-cont = 0.
        
        for each contrato where contrato.etbcod = tt-estab.etbcod 
                        and contrato.dtinicial >= vdti
                        and contrato.dtinicial <= vdtf no-lock,
            first clien where clien.clicod = contrato.clicod no-lock:

            if vclicod <> 0 and 
                clien.clicod <> vclicod 
            then next.

            find first contnf where contnf.etbcod = contrato.etbcod and
                               contnf.contnum = contrato.contnum
                             no-lock no-error.
            find first plani where plani.pladat = contrato.dtinicial and
                             plani.etbcod = contrato.etbcod
                 and plani.placod = contnf.placod
                 and plani.dest = contrato.clicod
                 and plani.movtdc = 5 
                 and plani.serie = "V" no-lock no-error.
       
            if not avail plani then next.
            if plani.crecod <> 2
            then next.
            if (plani.biss - plani.platot) < 2 then next.
        
            find finan where finan.fincod = contrato.crecod
                    no-lock no-error.
        
            if not avail finan then next.            
        
            if plani.biss <= (plani.platot - plani.vlserv) then
            next.
            
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

            find first envfinan where envfinan.empcod = titulo.empcod
                        and envfinan.titnat = titulo.titnat
                        and envfinan.modcod = titulo.modcod
                        and envfinan.etbcod = titulo.etbcod
                        and envfinan.clifor = titulo.clifor
                        and envfinan.titnum = titulo.titnum
                        no-lock no-error.
            if avail envfinan then next.

            if contrato.vltotal < val-cont
            then next.
            
            /*
            run calciof.p(input rowid(contrato), 
                      output viof, output vjuro, output txjuro).
            run bscalccet.p (input (contrato.vltotal - (viof + vjuro)) , 
                         input  contrato.dtinicial,
                         output dvalorcet,
                         output dvalorcetanual
                            ).
 
            /*****
            ATENCAO: GRAVAR ENVIADO PARA FINANCEIRA VER CODIGO NA DREBES
            *****/

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
            */
            
            find first tt-contrato where
                tt-contrato.contnum = contrato.contnum  no-error.
        
            if not avail tt-contrato 
            then do:
                create tt-contrato.
                assign 
                   tt-contrato.etbcod  = contrato.etbcod
                   tt-contrato.contnum = contrato.contnum
                   tt-contrato.marca   = "" 
                   tt-contrato.clicod  = contrato.clicod 
                   tt-contrato.valorav = (plani.platot - plani.vlserv)
                   tt-contrato.valorto = contrato.vltotal
                   tt-contrato.numparc = finan.finnpc.
                   
                tot-cont = tot-cont + 1.      
            end. 
            if qtd-cont > 0 and
               tot-cont >= qtd-cont
            then leave.
        end.         
    end.        
        
    run p-registro-99.
    
    /***
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
           with frame fx width 130 4 down.
end.
*/
    ***/
def var t-pgeral as dec.
def var t-pmarcado as dec.
l1: repeat:
    hide frame f-com1 no-pause.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    disp esqcom1 with frame f-com1.
    pause 0.
    hide frame f-linha no-pause.
    clear frame f-linha all.
    t-pgeral = 0. t-pmarcado = 0.
    tot-cont = 0.
    for each tt-contrato:
        tot-cont = tot-cont + 1.
        t-pgeral = t-pgeral + tt-contrato.valorto.
        if tt-contrato.marca = "*"
        then t-pmarcado = t-pmarcado + tt-contrato.valorto.
    end. 
    disp tot-cont label " Quantidade" format ">>>>>>9" 
         t-pgeral label " Valor Total"  format ">>,>>>,>>9.99"
         t-pmarcado label " Valor marcado"   format ">>,>>>,>>9.99"
         with frame ftt 1 down no-box row 21 side-label.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-contrato  
        &cfield = tt-contrato.contnum
        &noncharacter = /* 
        &ofield = " tt-contrato.marca 
                    tt-contrato.etbcod
                    tt-contrato.clicod 
                    tt-contrato.valorav 
                    tt-contrato.valorto  
                    tt-contrato.numparc "   
        &aftfnd1 = " "
        &where  = " true no-lock  "
        &aftselect1 = " run aftselect.
                        disp with frame f1.
                        disp with frame f2.
                        disp with frame f-com1.
                        if esqcom1[esqpos1] = "" envia arquivo"" or
                           esqcom1[esqpos1] = "" marca tudo"" 
                        then next l1.
                        else next keys-loop.
                        "
        &go-on = TAB 
        &naoexiste1 = " bell.
                    leave l1. " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.
hide frame f-com1 no-pause.
hide frame f-com2 no-pause.
hide frame f-linha no-pause.
hide frame f1 no-pause.
hide frame f-tot no-pause.
hide frame f6 no-pause. 

              
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
   find last Blotefin no-lock no-error.
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
      /* titulo.titdtven format "99999999"  /* 50-57 DATA 1° VENCIMENTO */ */
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
  /*
  run p-verif-data
            (input v-data-vecto, output vdata-retorno, output v-data-comerc).
  if v-data-comerc = no and vdata-retorno <> ?
  then assign v-data-vecto = vdata-retorno.
  */
  
  put unformat skip
     "11"                   /* 01-02 fixo "11" */
     dec(btitulo.titnum) format "9999999999" /* 03 - 12 OPERAÇÃO */
     "0001"                            /* 13 - 16 AGÊNCIA */
     btitulo.titpar format "999"        /* 17 - 19 PARCELA */
     v-data-vecto        format "99999999" /* 20 - 27 dt VENCIMENTO */
     (btitulo.titvlcob * 100) format "999999999999" /* 28-39 VLR PRESTAcaO */
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
           envfinan.txjuro = txjuro
           envfinan.envcet = dvalorcetanual
           envfinan.enviof = viof
           envfinan.lotinc = vlote
           envfinan.lotpag = 0
           envfinan.lotcan = 0 .
    /*  Cham. 30807 Estava causando estouro na tabela lock, a alteracao desse         campo sera feita dentro da procedure abaixo: 
        btitulo.cobcod = 10.
    */

    find current envfinan no-lock.
    run p-grava-cobcod (input string(rowid(btitulo))).


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
   find current lotefin no-lock.
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


procedure criaenvfinan:

    output to value(varquivo) page-size 0.

    run p-registro-00.

    for each tt-contrato where
             tt-contrato.marca = "*" no-lock:
        find contrato where contrato.contnum = tt-contrato.contnum
            no-lock no-error.
        if not avail contrato
        then next.   
        
        find first clien where clien.clicod = contrato.clicod no-lock.

        find first contnf where contnf.etbcod = contrato.etbcod and
                               contnf.contnum = contrato.contnum
                             no-lock no-error.
        find first plani where plani.pladat = contrato.dtinicial and
                             plani.etbcod = contrato.etbcod
                 and plani.placod = contnf.placod
                 and plani.dest = contrato.clicod
                 and plani.movtdc = 5 
                 and plani.serie = "V" no-lock no-error.
       
        find finan where finan.fincod = contrato.crecod
                    no-lock no-error.
        /* */
        run calciof.p(input rowid(contrato), 
                      output viof, output vjuro, output txjuro).
        run bscalccet.p (input (contrato.vltotal - (viof + vjuro)) , 
                         input  contrato.dtinicial,
                         output dvalorcet,
                         output dvalorcetanual
                            ).
        /* */
        if txjuro  = ? then txjuro = 0.      
        
        if txjuro = 0 then next.
        
        if viof = ? then viof = 0.
        if dvalorcet = ? then dvalorcet = 0.
        if dvalorcetanual = ? then dvalorcetanual = 0.                    
        
        find first titulo where 
                       titulo.empcod = 19    and 
                       titulo.titnat = no    and
                       titulo.modcod = "CRE" and      
                       titulo.etbcod = contrato.etbcod and
                       titulo.clifor = contrato.clicod and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titpar = 1 and
                       titulo.titsit = "lib"
                       no-lock .

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
                           btitulo.titsit = "LIB"
                       no-lock.
             if btitulo.cobcod = 10
             then next.
             run p-registro-11.
        end.   
        run p-registro-98.
        /*
        delete tt-contrato.
        */
    end.
    output close.
    if opsys = "unix"
    then do.
        output to ./unixdos.txt.
        unix silent unix2dos value(varquivo). 
        unix silent chmod 777 value(varquivo).
        output close.
        unix silent value("rm ./unixdos.txt -f").
    end.

end procedure.

procedure aftselect:
    def buffer btabmix for tabmix.
    def buffer btt-contrato for tt-contrato.
    if esqcom1[esqpos1] = " MARCA"
    THEN DO:
        if tt-contrato.marca = " " 
        then do:
            assign tt-contrato.marca = "*"
                   vtotalav = tt-contrato.valorav + vtotalav
                   vtotalto = tt-contrato.valorto + vtotalto.
            t-pmarcado = t-pmarcado + tt-contrato.valorto.
        end.
        else do:
            assign 
                tt-contrato.marca = " "
                vtotalav  = 0
                vtotalto = 0
                t-pmarcado = 0.
            for each btt-contrato where btt-contrato.marca = "*" no-lock:
                assign 
                   vtotalav = btt-contrato.valorav + vtotalav
                   vtotalto = btt-contrato.valorto + vtotalto.
                t-pmarcado = t-pmarcado + btt-contrato.valorto.
            end.       
        end.           
        disp tt-contrato.marca with frame f-linha.
        disp t-pgeral 
             t-pmarcado 
             with frame ftt 1 down no-box row 21 side-label.
    END.
    if esqcom1[esqpos1] = " MARCA tudo"
    THEN DO:
        assign vtotalav = 0
               vtotalto = 0
               t-pmarcado = 0.
        find first tt-contrato where tt-contrato.marca = "*" no-lock  no-error.
        if avail tt-contrato
        then do transaction:     
            for each tt-contrato exclusive-lock:
        
                assign tt-contrato.marca = " "
                   vtotalav = 0
                   vtotalto = 0
                   t-pmarcado = 0.
            end.
        end.
        else do:
            for each tt-contrato exclusive-lock:
        
                assign tt-contrato.marca = "*"
                   vtotalav = tt-contrato.valorav + vtotal
                   vtotalto = tt-contrato.valorto + vtotalto.
                t-pmarcado = t-pmarcado + tt-contrato.valorto.
            end.

        end.
        disp t-pgeral 
             t-pmarcado 
             with frame ftt 1 down no-box row 21 side-label.
    END.
    if esqcom1[esqpos1] = " ENVIA ARQUIVO"
    THEN DO:
        /*
        disp vtotalav label "Valor Total"
             vtotalto label "Valor Total com Juros" with frame f-tot centered.
        */
        message  "Confirma o envio do arquivo? " update vresp .
        if vresp = yes 
        then do :     
            run  criaenvfinan.
        end.    
    END.
end procedure.

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
end procedure.

procedure p-grava-cobcod:

    define input parameter vcha-rowid as character.
    define buffer bf1-titulo for titulo.

    find first bf1-titulo where rowid(bf1-titulo) = to-rowid(vcha-rowid) 
                                        exclusive-lock no-error.   
    
    if available bf1-titulo then do:
    
        assign bf1-titulo.cobcod = 10.
        
    end.
    find current bf1-titulo no-lock.

end procedure.
