
{admcab.i new}
    
def temp-table tt-estab
       field etbcod as int
       index ind1 etbcod.

def var varquivo as char.
def var varqexp  as char.

def var vetbcod  like estab.etbcod.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var vclicod  like clien.clicod.
def var vclinom  like clien.clinom.

def var dvalorcet as dec decimals 6 format "->,>>9.999999". 
def var dvalorcetanual as dec decimals 6 format "->,>>9.999999".  
def var viof as dec.
def var vjuro as dec.
def var txjuro as dec.
def var vhist  as char.
  
def temp-table tt-titulo
      field data      as date
      field etbcod like estab.etbcod
      field tipo      as char format "X(15)"  Label "Tipo"
      field titvlcob  like titulo.titvlcob
      field titvlpag  like titulo.titvlpag
      index ix is primary unique
                  etbcod   
                  data
                  tipo
      index xx tipo.

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
                with frame f1 side-label width 80.

    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.
   
    do on error undo, retry:
          update vdti label "Data Inicial" colon 16
                 vdtf label "Data Final" colon 16 with frame f1.
          if  vdti > vdtf
          then do:
                message "Data inválida".
                undo.
            end.
     end. 
def var vndx as dec.
if opsys = "unix"
then varqexp = "/admcom/audit/tit_" + trim(string(vetbcod,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
else varqexp = "l:\audit\tit_" + trim(string(vetbcod,"999")) + "_" + 
                string(day(vdti),"99") +   
                string(month(vdti),"99") +   
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +   
                string(month(vdtf),"99") +   
                string(year(vdtf),"9999") + ".txt".
                

    disp varqexp    label "Arquivo"   colon 16 format "x(50)"
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
    
 
    output to value(varqexp) page-size 0.

    output close. /**** */

    for each tt-estab no-lock:

       disp tt-estab.etbcod with frame fxy.  pause 0.
    
        for each plani where plani.movtdc = 5
                         and plani.etbcod = tt-estab.etbcod
                         and plani.pladat >= vdti
                         and plani.pladat <= vdtF 
                      /*   and plani.notped = "C" */ no-lock,
            first contnf where contnf.etbcod = plani.etbcod
                           and contnf.placod = plani.placod no-lock,
            each titulo where 
                           titulo.empcod = 19  and 
                           titulo.titnat = no   and
                           titulo.modcod = "CRE" and      
                           titulo.etbcod = plani.etbcod and
                           titulo.clifor = plani.dest and
                           titulo.titnum = string(contnf.contnum) and
                           titulo.titsit <> "PAG"
                       no-lock.
             
             vndx = 1.
             if plani.platot < plani.biss and
                plani.pladat >= 01/01/09
             then do:
                vndx = plani.platot / plani.biss.
             end.

             if plani.notped = "C"
             then do:
                  vhist = "CADASTRAMENTO".
                  run p-registro ("C",titulo.titdtemi,
                                  titulo.titvlcob * vndx,
                                  titulo.titvlcob * vndx,
                                  "+").
            end.
            else do:
                  vhist = "CANCELAMENTO".
                  run p-registro ("B",titulo.titdtemi,
                                  titulo.titvlcob * vndx,
                                  titulo.titvlcob * vndx,
                                  "+").

            end.
        end. 

        for each titulo  where 
                           titulo.empcod = 19  and 
                           titulo.titnat = no   and
                           titulo.modcod = "CRE" and      
                           titulo.titsit = "pag" and
                           titulo.etbcod = tt-estab.etbcod and
                           titulo.titdtpag >= vdti and
                           titulo.titdtpag <= vdtf  no-lock.

             if titulo.titdtemi < 01/01/2009          
             then do:
                 /**
                  vhist = "CADASTRAMENTO".
                  run p-registro ("C",titulo.titdtpag,
                                   titulo.titvlpag,titulo.titvlpag,"+").
                 **/ 
                  vhist = "BAIXA".
                  run p-registro ("R",titulo.titdtpag,
                                   titulo.titvlpag,titulo.titvlpag,"-").
                  if titulo.titvlpag > titulo.titvlcob
                then do:
                  vhist = "JURO".
                  run p-registro ("J",titulo.titdtpag,
                                  (titulo.titvlpag - titulo.titvlcob),
                                   titulo.titvlcob,"+").
                end.
             end.   
             else do:
                find first contnf where 
                           contnf.etbcod = titulo.etbcod and
                           contnf.contnum = int(titulo.titnum)
                           no-lock no-error.
                if avail contnf
                then do:
                    find plani where plani.etbcod = contnf.etbcod and
                                     plani.placod = contnf.placod and
                                     plani.movtdc = 5
                                     no-lock no-error.
                    if avail plani 
                    then do:
                        vndx = 1.
                        if plani.platot < plani.biss and
                            plani.pladat >= 01/01/09
                        then do:
                            vndx = plani.platot / plani.biss.
                        end.
             
                        vhist = "BAIXA".
                        run p-registro ("R",titulo.titdtpag,
                                   titulo.titvlpag * vndx,
                                   titulo.titvlcob * vndx,
                                   "-").
                                   
                        if titulo.titvlpag > titulo.titvlcob
                        then do:
                            vhist = "JURO".
                            run p-registro ("J",titulo.titdtpag,
                             ((titulo.titvlpag * vndx) - 
                             (titulo.titvlcob * vndx)),
                                   titulo.titvlcob * vndx,
                                   "+").
                        end.
                    end.
                end.       
             end.                     
        end.
    end.        
    
    put unformat skip.

    output close.

   if opsys = "UNIX"
   then varquivo = "../relat/tit_aud" + string(time).
   else varquivo = "l:\relat\tit_aud" + string(time).

    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "90"
            &Page-Line = "66"
            &Nom-Rel   = ""TIT_AUD""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """ CARTEIRA DE CLIENTES - AUDIT  "" 
                            + ""   -  "" 
                            + string(vdti,""99/99/9999"") + "" a ""
                            + string(vdtf,""99/99/9999"")
                            "
            &Width     = "90"
            &Form      = "frame f-cabcab"}


 view frame f-cabcab.
 if vetbcod = 0
 then put unformat skip "Estabelecimento: - 0 GERAL" SKIP.
 else do:
      find estab where estab.etbcod = vetbcod no-lock no-error.
      put unformat skip "Estabelecimento: " estab.etbcod " - " estab.etbnom
            skip.
 end.       

 
 for each tt-titulo where tt-titulo.etbcod = 0  no-lock:
    disp tt-titulo except tt-titulo.data.
 end.
 put skip (2).
     
 output close.     

 if opsys = "UNIX"
 then do:
     run visurel.p(input varquivo, input "").
 end.
 else do:
     {mrod.i} 
 end. 
     
 def var vx as char.
input from value(varqexp).
repeat:
    import unformat vx.
    disp  length(vx) 
         vx format "x(5)"
         substring(vx,24) format "x(10)"
         substring(vx,44) format "x(10)"
         substring(vx,71) format "x(10)"
         substring(vx,104) format "x(5)"
         substring(vx,144) format "x(5)"
         .
end.


 if opsys = "unix"
    then do.
        unix silent chmod 777 value(varqexp).
    end.
end.

/* parcelas do contrato */
procedure p-registro.
 def input parameter voper as char.
 def input parameter vdtoper as date.
 def input parameter vtitvlpag as dec.
 def input parameter vtitvlcob as dec.
 def input parameter vsinal   as char.

/*** teste relatório 

 put unformat skip
     titulo.etbcod format ">>9"           /* 01-03 */
     string(titulo.clifor) format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     titulo.titnum format "999999999999"  /* 32-43 */
     year(vdtoper) format "9999"          /* 44-51 */
     month(vdtoper) format "99"          
     day(vdtoper)   format "99"
     voper     format "x(3)"             /* 52-54 */
     vtitvlpag              format "9999999999999.99" /* 55-70 */
     vsinal                 format "x(1)"             /* 71 */
     year(titulo.titdtemi)  format "9999" /* 72-79 */
     month(titulo.titdtemi) format "99"  
     day(titulo.titdtemi)   format "99"
     Vtitvlcob format "9999999999999.99"  /* 80-95 */
     year(titulo.titdtven) format "9999"  /* 96-103 */
     month(titulo.titdtven) format "99"  
     day(titulo.titdtven) format "99"
     titulo.titnum        format "x(12)" /* 104-115 nro arquivamento */   
     " " format "x(28)"                  /* 116-143 cod.contabil */
     vhist format "x(250)"               /* 144-393  Histórico */ .
     
***/

  find first
       tt-titulo where /* tt-titulo.data = vdtoper 
                   and */ 
                       tt-titulo.tipo = vhist 
                   and tt-titulo.etbcod = titulo.etbcod no-lock no-error.
  if not avail tt-titulo
  then do:
       create tt-titulo.
       assign tt-titulo.data = vdtoper
              tt-titulo.etbcod = titulo.etbcod
              tt-titulo.tipo = vhist.
  end.
  assign tt-titulo.titvlpag = tt-titulo.titvlpag + vtitvlpag
         tt-titulo.titvlcob = tt-titulo.titvlcob + 
                              (if voper = "j" then vtitvlpag else vtitvlcob).

  find first
       tt-titulo where /* tt-titulo.data = vdtoper 
                   and */ 
                       tt-titulo.tipo = vhist 
                   and tt-titulo.etbcod = 0 no-error.
  if not avail tt-titulo
  then do:
       create tt-titulo.
       assign tt-titulo.data = vdtoper
              tt-titulo.etbcod = 0
              tt-titulo.tipo = vhist.
  end.
  assign tt-titulo.titvlpag = tt-titulo.titvlpag + vtitvlpag
         tt-titulo.titvlcob = tt-titulo.titvlcob + 
                              (if voper = "j" then vtitvlpag else vtitvlcob).

    
end.




