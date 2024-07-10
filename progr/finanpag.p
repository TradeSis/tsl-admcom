/**
#1-TP31171289
**/

{admcab.i}

def temp-table tt-estab
       field etbcod as int
       index ind1 etbcod.

def buffer btitulo for titulo.

def var varquivo as char.
def var varqexp  as char.

def var vseq as int.
def var vqtoper  as int.
def var vtotal   as dec.
def var vetbcod like estab.etbcod.
def var vlote as int.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var vclicod  like clien.clicod.
def var vclinom  like clien.clinom.

varqexp = "pg" + string(today,"999999") + ".rem".

if opsys = "unix"
then varquivo = "/admcom/import/financeira/" + varqexp.
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

def var vindex as int.
def var v-sit as char extent 3 format "x(15)".
def var v-it as char extent 3.
def var v-i as int.
v-sit[1] = "NÃO EXPORTADOS".
v-sit[2] = "JA EXPORTADOS".
v-sit[3] = "TODOS".

form "(" at 1  space(0)
     v-it[1] format "x" no-label
     space(0) ")"
     v-sit[1] no-label
     "(" at 1  space(0)
     v-it[2] format "x" no-label
     space(0) ")"
     v-sit[2]  no-label
     "("  at 1 space(0)
     v-it[3] format "x" no-label
     space(0) ")"
     v-sit[3] no-label
     with frame f-it 1 down centered row 10
     title " processar ".

def buffer ctitulo for titulo.

def var vetbcod1 like estab.etbcod.
repeat:
    clear frame f-it all.
    hide frame f-it no-pause.
    update vetbcod label "Filial de" colon 16
           vetbcod1 label "Ate"
                with frame f1 side-label width 70.

    if vetbcod = 0 or
       vetbcod1 = 0
    then next.
   
    update vclicod label "Cliente" colon 16 with frame f1.
    if vclicod > 0
    then do:                 
        find first clien where clien.clicod = vclicod no-lock no-error.
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
                 vdtf label "Data Final" colon 16 with frame f1.
          if  vdti > vdtf
          then do:
                message "Data inválida".
                undo.
          end.
     end. 

    disp varquivo    label "Arquivo"   colon 16 format "x(50)"
    with frame f1 side-label.

    update varquivo with frame f1.

    for each tt-estab: delete tt-estab. end.
   
    for each estab no-lock:
        if estab.etbcod < vetbcod then next.
        if estab.etbcod > vetbcod1 then next.
        
        if estab.etbcod = 22 or 
                estab.etbcod > 995 then next.
                       
        create tt-estab.
        assign tt-estab.etbcod = estab.etbcod.             
    end.

    disp v-it v-sit with frame f-it.

    choose field v-it with frame f-it.
    vindex = frame-index.
    v-it[vindex] = "*".
    disp v-it with frame f-it.
 
    sresp = no.
    message "Confirma processamento?" update sresp. 
    if sresp = no
    then next.
    
    output to value(varquivo) page-size 0.

    run p-registro-00.

    assign vqtoper = 0
           vtotal = 0.
    for each tt-estab no-lock:

        for each titulo where 
             titulo.empcod = 19 and
             titulo.titnat = no and
             titulo.modcod = "CRE" and
             titulo.titdtpag >= vdti and
             titulo.titdtpag <= vdtf and
             titulo.etbcod = tt-estab.etbcod and
             titulo.titpar > 0
             no-lock:

            if titulo.cobcod = 14 then next.
            if titulo.titdtpag = ? then next.

            find first clien where clien.clicod = titulo.clifor 
                    no-lock no-error.
            if not avail clien then next.
                
            if vclicod <> 0 and 
                clien.clicod <> vclicod 
            then next.

            def var vparcela like titulo.titpar.
            vparcela = titulo.titpar.
            def var vparcial as log.
            vparcial = no.
            /*
            run retorna-titpar-financeira.p(input recid(titulo),
                                        input-output vparcela,
                                        output vparcial).
            */
            def var par-ori like titulo.titpar.
            def var pag-tipo as log.
            def var p-retorno as char.
            p-retorno = "".
            par-ori = titulo.titpar.
            pag-tipo = yes. 
            if  acha("PARCIAL",titulo.titobs[1]) <> ? or
                acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
            then do:
                vparcial = yes.
                run protituloparcial.p (input recid(titulo),
                                    output p-retorno).
                par-ori = int(acha("PARCELA-ORIGEM",p-retorno)).
                if dec(acha("VALOR-ABERTO",p-retorno)) > 0
                then pag-tipo = no.
            end.

            vparcela = par-ori.
            /*
            if titulo.titpar > 30 and vparcela < 30
            then vparcela = par-ori. /*#1titulo.titpar.*/
            */    
            find first envfinan where envfinan.empcod = titulo.empcod
                        and envfinan.titnat = titulo.titnat
                        and envfinan.modcod = titulo.modcod
                        and envfinan.etbcod = titulo.etbcod
                        and envfinan.clifor = titulo.clifor
                        and envfinan.titnum = titulo.titnum
                        and envfinan.titpar = vparcela /*titulo.titpar*/
                        no-lock no-error.
            if not avail envfinan or 
               (envfinan.envsit <> "INC" and
                envfinan.envsit <> "PAG")
            then next.
          
            if vindex = 1 /*Nao exportados*/
            then do:
                if envfinan.envsit = "PAG"
                then next.
                else if acha("PAGAMENTO" +
                             string(titulo.titpar,"999"),envfinan.c-1) <> ?
                then next.             
            end.
            else if vindex = 2 /*ja exportados*/
            then do:
                if envfinan.envsit = "INC" and
                   acha("PAGAMENTO" +  
                        string(titulo.titpar,"999"),envfinan.c-1) = ?
                then next.         
            end.    
        
            if vparcela > 30
            then do:
                find first ctitulo where
                   ctitulo.empcod = titulo.empcod and
                   ctitulo.titnat = titulo.titnat and
                   ctitulo.modcod = titulo.modcod and
                   ctitulo.etbcod = titulo.etbcod and
                   ctitulo.clifor = titulo.clifor and
                   ctitulo.titnum = titulo.titnum and
                   ctitulo.titpar = 31
                   no-lock no-error.
                if avail ctitulo
                then vparcela = vparcela - 30.
                else do:
                    find first ctitulo where
                        ctitulo.empcod = titulo.empcod and
                        ctitulo.titnat = titulo.titnat and
                        ctitulo.modcod = titulo.modcod and
                        ctitulo.etbcod = titulo.etbcod and
                        ctitulo.clifor = titulo.clifor and
                        ctitulo.titnum = titulo.titnum and
                        ctitulo.titpar = 51
                        no-lock no-error.
                    if avail ctitulo
                    then vparcela = vparcela - 50.
                end.
            end. 
            
            run p-registro-10.    

        end.
    end.    
    run p-registro-99.

    output close.

    if opsys = "unix"
    then do.
        output to ./unixdos.txt.
        unix silent unix2dos value(varquivo). 
        unix silent chmod 777 value(varquivo).
        output close.
        unix silent value("rm ./unixdos.txt -f").
    end.
end.

/* header */
procedure p-registro-00.

     def buffer blotefin for lotefin.
     vseq = 1.
     put unformat skip
         "00"                      /* 001-002 */
         varqexp format "x(08)"    /* 003-010 */
          string(today,"99999999") /* 011-018 */
          " " format "x(776)"      /* 019-079  */
          vseq format "999999" /* NUMERICO  Sequencia  */.

   find last Blotefin use-index lote exclusive-lock no-error.

   create lotefin.
   assign lotefin.lotnum = (if avail Blotefin 
                             then Blotefin.lotnum + 1
                             else 1)
          lotefin.lottip = "PAG".
          
   assign vlote = lotefin.lotnum.                         
   
end procedure.

/* OPERACAO */
procedure p-registro-10.
  def buffer benvfinan for envfinan.
  def var tp-baixa as char.
  /*
  find btitulo where btitulo.empcod = titulo.empcod
                 and btitulo.titnat = titulo.titnat
                 and btitulo.modcod = titulo.modcod
                 and btitulo.etbcod = titulo.etbcod
                 and btitulo.clifor = titulo.clifor
                 and btitulo.titnum = titulo.titnum 
                 and btitulo.titpar > titulo.titpar
                 no-lock no-error.
  */
  def var v-data-comerc as log.
  def var v-data-vecto as date.
  def var vdata-retorno as date.
  assign v-data-comerc = yes.
  v-data-vecto = titulo.titdtpag. 
  run p-verif-data (input v-data-vecto, 
                    output vdata-retorno, 
                    output v-data-comerc).
  if v-data-comerc = no and vdata-retorno <> ?
  then assign v-data-vecto = vdata-retorno.

  /*
  def var vparcela like titulo.titpar.
  vparcela = titulo.titpar.
  def var vparcial as log.
  vparcial = no.
  run retorna-titpar-financeira.p(input recid(titulo),
                                  input-output vparcela,
                                  output vparcial)
                                  .
  */
  vseq = vseq + 1.

  tp-baixa = "10".
  if vparcial and titulo.titvlcob > titulo.titvlpag
  then tp-baixa = "12".
  
  put unformat skip 
      "10"                          /* 001-002  TIPO  FIXO –1 */
      "0001"                        /* 003-006 AGÊNCIA        */
      dec(titulo.titnum) format "9999999999"       /* 007-016 Contrato */
      vparcela format "999"                 /* 017-019 Parcela  */
      /********************************
      titulo.titvlcob * 100 format "99999999999999999" /* 020-036 Vlr Par */
      titulo.titvljur * 100 format "99999999999999999" /* 037-053 Encargos */
      titulo.titvldes * 100 format "99999999999999999" /* 054-070 Desc */
      titulo.titvlpag * 100 format "99999999999999999" /* 071-087 valor pago */
      *********************************/
      0                     format "99999999999999999" /* 020-036 Vlr Par */
      0                     format "99999999999999999" /* 037-053 Encargos */
      0                     format "99999999999999999" /* 054-070 Desc */
      titulo.titvlpag * 100 format "99999999999999999" /* 071-087 valor pago */
      "00000000000000000"                        /* 088-104 CPMF */
      "00000000000000000"                        /* 105-121 Taxas */
      "000000000000000"                          /* 122-136 Comissão */
      /***************
      "00000000000000000"                        /* 137-153 Vlr repassado */
      ***************/
      titulo.titvlpag * 100 format "99999999999999999" /* 137-153 Vl repass. */
      "01"                                       /* 154-155 tipo pagto */
      /*29481 v-data-vecto */
      /*30477 titulo.titdtpag */
      v-data-vecto format "99999999"          /* 156-163 dat pag */
      /*(if avail btitulo then "12" else "10")*/
      /*"10"*/ /* 164-165 total/parcial */
      tp-baixa format "x(2)"
      "00000000"                                 /* 166-173 */
      "00000"                                    /* 174-178 */
      " "                                        /* 179-179 */ 
      "N"                                        /* 180-180 */
      "   "                                      /* 181-183 */
      " " format "x(6)"                          /* 184-189 */
      " " format "x(30)"                         /* 190-219 */
      " " format "x(575)"                        /* 220-794 */
      vseq format    "999999"                    /* 795-800 */.

  assign vqtoper = vqtoper + 1
         vtotal = vtotal + titulo.titvlcob.
  find benvfinan where rowid(benvfinan) = rowid(envfinan) 
                exclusive-lock no-error.
  if avail benvfinan
  then do:
        assign benvfinan.lotpag = vlote.
        if tp-baixa = "10"
        then benvfinan.envsit = "PAG".
        if vparcial
        then benvfinan.c-1 = benvfinan.c-1 +
                "PAGAMENTO" + string(titulo.titpar,"999") + "=" +
                              string(titulo.titvlcob) + ";" +
                              string(titulo.titvlpag) + ";" +
                              string(titulo.titdtpag) + ";" +
                              string(today) + ";" +
                              string(time,"hh:mm:ss") + "|".
  end.
  
end procedure.

/* Trailer */
procedure p-registro-99.
  vseq = vseq + 1.

  put unformat skip
     "99"                                 /* 01-02 fixo "99" */
     varqexp format "x(6)"                /* 03-08 Nome do arquivo */
     string(today,"99999999")             /* 09-16 data movimento */
     vqtoper format "9999999999"          /* 17-26 QTD DE OPERAÇÕES */
     vtotal  format "99999999999999999"   /* 27-43 VLR TOTAL das OPERAÇÕES */
     " " format "x(751)"                  /* 44-794 FILLER */
     vseq format    "999999" skip.

   find lotefin where lotefin.lotnum = vlote exclusive-lock no-error.
   if not avail lotefin
   then do:
        create lotefin.
        assign lotefin.lotnum = vlote
               lotefin.lottip = "PAG".
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

