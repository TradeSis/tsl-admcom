{admcab.i}

def temp-table tt-estab
       field etbcod as int
       index ind1 etbcod.

def buffer btitulo for titulo.

def var varquivo as char.
def var varqexp  as char.

def var vseq as int.
def var vqtoper  as int.
def var vetbcod like estab.etbcod.
def var vlote as int.

def buffer ctitulo for titulo.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var vclicod  like clien.clicod.
def var vclinom  like clien.clinom.


varqexp = "cn" + string(today,"999999") + ".rem".

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

def temp-table tc-titulo like titulo.

repeat:
    update vetbcod label "Filial" colon 16
                with frame f1 side-label width 70.

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
    

    output to value(varquivo) page-size 0.

    run p-registro-00.


    assign vqtoper = 0.

    for each titulo where 
             titulo.empcod = 19 and
             titulo.titnat = no and
             titulo.modcod = "CRE" and
             titulo.titdtpag >= vdti and
             titulo.titdtpag <= vdtf and
             titulo.etbcod = tt-estab.etbcod and
             titulo.moecod = "DEV"
             no-lock:
        if titulo.cobcod <> 10
        then next.        
        find first envfinan where envfinan.empcod = titulo.empcod
                        and envfinan.titnat = titulo.titnat
                        and envfinan.modcod = titulo.modcod
                        and envfinan.etbcod = titulo.etbcod
                        and envfinan.clifor = titulo.clifor
                        and envfinan.titnum = titulo.titnum
                        and envfinan.titpar = titulo.titpar
                        no-lock no-error.
        if not avail envfinan
        then next.  
        
        find clien where clien.clicod = titulo.clifor no-lock.
                
        if vclicod <> 0 and 
           clien.clicod <> vclicod 
        then next.
        
        run p-registro-20.    

        find first tc-titulo where 
                   tc-titulo.empcod = titulo.empcod and
                   tc-titulo.titnat = titulo.titnat and
                   tc-titulo.modcod = titulo.modcod and
                   tc-titulo.etbcod = titulo.etbcod and
                   tc-titulo.clifor = titulo.clifor and
                   tc-titulo.titnum = titulo.titnum
                    no-error.
        
        if not avail tc-titulo
        then do:
            create tc-titulo.
            buffer-copy titulo to tc-titulo.
        end.
                    
    end.
        
   run p-registro-99.

   output close.
/*
   run visurel.p(varquivo,"").
*/

  if opsys = "unix"
  then do.
       unix silent chmod 777 value(varquivo).
  end.

/***
def var vx as char.
input from value(varquivo).
repeat:
    import unformat vx.
    disp vx format "x(10)"
         substring(vx,20) format "x(50)"
         length(vx).
end.
*/

end.

/* header */
procedure p-registro-00.

     def buffer blotefin for lotefin.
     vseq = 1.
     put unformat skip
         "00"                      /* 001-002 */
         varqexp format "x(08)"    /* 003-010 */
          string(today,"99999999") /* 011-018 */
          " " format "x(776)"      /* 019-794  */
          vseq format "999999" /* NUMERICO  Sequencia  */
          .

   find last Blotefin use-index lote exclusive-lock no-error.

   create lotefin.
   assign lotefin.lotnum = (if avail Blotefin 
                             then Blotefin.lotnum + 1
                             else 1)
          lotefin.lottip = "CAN".
          
   assign vlote = lotefin.lotnum.                         
   
end procedure.

/* OPERACAO */
procedure p-registro-20.
  def buffer benvfinan for envfinan.

  vseq = vseq + 1.
  put unformat skip 
      "20"                          /* 001-002  TIPO  FIXO –1 */
      "0001"                        /* 003-006 AGÊNCIA        */
      titulo.titnum format "9999999999"       /* 007-016 Contrato */
      " " format "x(778)"
      vseq format    "999999"                    /* 795-800 */
     .
  
  assign vqtoper = vqtoper + 1.
  find benvfinan where rowid(benvfinan) = rowid(envfinan) 
                exclusive-lock no-error.
  if avail benvfinan
  then assign benvfinan.lotcan = vlote
              benvfinan.envsit = "CAN".  
  titulo.cobcod = 2.

end procedure.

/* Trailer */
procedure p-registro-99.
  vseq = vseq + 1.

  put unformat skip
     "99"                                 /* 01-02 fixo "99" */
     varqexp format "x(6)"                /* 03-08 Nome do arquivo */
     string(today,"99999999")             /* 09-16 data movimento */
     vqtoper format "9999999999"          /* 17-26 QTD DE OPERAÇÕES */
     " " format "x(768)"                  /* 27-794 FILLER */
     vseq format    "999999" skip.

   find lotefin where lotefin.lotnum = vlote exclusive-lock no-error.
   if not avail lotefin
   then do:
        create lotefin.
        assign lotefin.lotnum = vlote
               lotefin.lottip = "CAN".
   end.
   assign lotefin.datexp = today
          lotefin.hora = time
          lotefin.lotqtd = vqtoper.

end procedure.


/*
def var vx as char.
input from /admcom/relat/pg120109.rem.
repeat:
    import unformat vx.
    disp vx format "x(20)"
         substring(vx,790,20) format "x(20)"
         length(vx).
end.
*/



