/* etiquetas com total de distribuição */ 

/* Recebe como Parametro estabelecimento e o total */


{admcab.i}

def shared var vlote as int.

def var recimp as recid.
def var fila as char format "x(20)".

def var vtime as int.
def var varquivo as char.
def var vlinha as int.
def var wetique as int.
def var vpos   as int. 
def var v-comando as char format "x(70)".   
def var varqsai as char.

def shared temp-table tt-estab
    field etbcod   like estab.etbcod
    field estatual like estoq.estatual
    field qtd-cal  as dec 
    field saldo    as dec
    field per-ori  as dec
    field qtd-dis  as int
    field per-cal  as dec
    field crijaime as dec
    field per-vir  as dec
    index iestab crijaime desc
                 per-ori  desc
                 saldo    desc
                 estatual.
                 
def temp-table tt-etiq
    field seq as int
    field linha  as int
    field comando as char format "x(70)"
    index i1 is primary unique 
               seq linha.

def temp-table tt-aux
    field qtde   as int format ">>>>9" extent 2
    field etbcod as int format ">>9"   extent 2
    field seq   as int
    index ind is primary unique
          seq.

def temp-table wfetq
    field linha as int
    field comando as char format "x(70)".

def var v-total like tt-estab.qtd-dis.
def var vseq as int.
def var aux-seq as int.
def var xi as int.

 for each wfetq.
        delete wfetq.
 end.

 if opsys = "UNIX"
 then do:
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do:
            run acha_imp.p (input recid(impress), 
                            output recimp).
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp). 
    end.
 end.    
 else fila = "".

 IF OPSYS = "UNIX"
 THEN varquivo = "/admcom/zebra/tot_estab.z".
 else varquivo = "l:\zebra\tot_estab.z".
/*
varquivo = "/admcom/desenv/tot_estab.z".
  */      
        
 input from value(varquivo) no-echo.

 vlinha = 0.
 repeat:
        import unformat v-comando.
        create wfetq.
        wfetq.comando = v-comando.
        vlinha = vlinha + 1.   
        wfetq.linha = vlinha.
 end.

 input close.

  wetique = 1.

for each tt-estab where tt-estab.etbcod > 0 and
                        tt-estab.qtd-dis > 0 no-lock
             break by tt-estab.etbcod:
    if first-of(tt-estab.etbcod)
    then v-total = 0.
     
    v-total = v-total + (tt-estab.qtd-dis * vlote).
             
    if last-of(tt-estab.etbcod)
    then do xi = 1 to tt-estab.qtd-dis:

         vseq = vseq + 1.
         if vseq modulo 2 = 1
         then do:
              aux-seq = aux-seq + 1. 
              create tt-aux.
              assign tt-aux.seq = aux-seq
                     tt-aux.etbcod[1] = tt-estab.etbcod
                     tt-aux.qtde[1] = vlote /* v-total */.
         end.
         else assign tt-aux.etbcod[2] = tt-estab.etbcod
                     tt-aux.qtde[2] = vlote /* v-total */.
    end.

end.

 for each tt-aux no-lock
             break by tt-aux.seq:
     
          for each wfetq break by linha:
    
              if wfetq.linha = 3 
              then vpos = 4.
              else vpos = 24.
        
              v-comando = wfetq.comando.
              assign substring( v-comando,vpos ) = 
                     if wfetq.linha = 3
                     then string(wetique,"999")
                     else
                     if wfetq.linha = 6
                     then "LOJA:" + string(tt-aux.etbcod[1],"999")
                     else 
                     if wfetq.linha = 7
                     then "LOJA:" + string(tt-aux.etbcod[2],"999")
                     else
                     if wfetq.linha = 9
                     then string(tt-aux.qtde[1])
                     else 
                     if wfetq.linha = 10
                     then string(tt-aux.qtde[2])
                     else substring(v-comando,vpos).
               
            find tt-etiq where tt-etiq.seq = tt-aux.seq
                           and tt-etiq.linha = wfetq.linha no-error.
            if not avail tt-etiq
            then create tt-etiq.
            assign tt-etiq.seq = tt-aux.seq 
                   tt-etiq.linha  = wfetq.linha
                   tt-etiq.comando = v-comando.               
         end.
   end.
  
  vtime = time.

  IF OPSYS = "UNIX" /* Criando bat para impressao */
  THEN DO: 
       varqsai = "/admcom/zebra-fila/etiq-distr" + string(day(today),"99")
                       +  "." + string(vtime).
       end.
  else do:
         varqsai = "c:\temp\etiq-distr" + string(day(today),"99")
                       +  "." + string(vtime).

          if search("c:\temp\etique.bat") <> ?
          then do:
                dos silent del c:\temp\impender.bat.
                dos silent del c:\temp\etiq-ditr*.* .
          end.

          output to "c:\temp\impender.bat".

          put "c:\windows\command\mode com1:9600,e,7,2,r" skip.
          put trim(" type c:\temp\etiq-distr" + string(day(today),"99")
                       +  "." + string(vtime) + " > com1")          
                          format "x(40)" skip.

          output close.
      
   end.
      
  output to value(varqsai).
    
  for each tt-etiq 
             break by tt-etiq.seq
                   by tt-etiq.linha.
       put unformatted tt-etiq.comando skip.
           if last-of(tt-etiq.seq)
           then put skip(1).           
       end.
  output close.

 IF OPSYS = "UNIX"
 THEN do:
        
        os-command silent /admcom/progr/cupszebra.sh  value(fila).

        os-command silent "lpr " value(fila) value(varqsai).
        
        pause 1 no-message.                          
      
    end.        
 else os-command silent c:\temp\impender.bat.

 hide frame f1 no-pause.

