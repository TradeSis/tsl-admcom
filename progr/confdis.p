/*   confdis.p coleta produtos e compara com a nota */


/**  VER AS POSIÇÕES CORRETAS DO COLETOR   ***/


{admcab.i}
def var varquivo       as char.

def var vpath as char format "x(30)".
def var vcol as i.
def var vpedrec         as recid.
def var reccont         as int.
def var vpronom         like produ.pronom.
def var vlei            as char format "x(26)".
def var vetb            as i    format ">>9".
def var vcod            as i    format "9999999".
def var vqtenv          as i    format "999999".
def var vqtrec          as i    format "999999".
def var vnf             like plani.numero.
def var vnumero         like plani.numero.
def var vserie          like plani.serie.
def var vetbcod         as int format ">>9".
def var vplacod         like plani.placod.
def var vseq            as int .
def var vdiverg         as char.
def var vresp           as log.
def var recimp          as recid.
def var fila            as char.

def temp-table tt-movcol
    field etbcod like estab.etbcod
    field placod like plani.placod
    field numero like plani.numero
    field procod like produ.procod
    field qtrec  like movim.movqt
    field qtenv  like movim.movqt
    index movim is primary unique
         etbcod
         numero
         procod.

def buffer btt-movcol for tt-movcol.         

def temp-table tt-diverg
    field etbcod like estab.etbcod
    field numero like plani.numero
    field procod like produ.procod
    field seq    as int
    field descr  as char format "x(50)"
    index movim is primary unique
         etbcod
         numero
         procod
         seq.
vcol = 1.
vnumero = 0.

repeat:

    do on error undo, retry:
        update vetbcod  colon 15 label "Filial" with frame f-col.
        find estab where estab.etbcod = vetbcod no-lock no-error.
         if not avail estab
        then do:
             message "Estabelecimento nao Cadastrado".
             undo, retry.
        end.
        disp estab.etbnom no-label with frame f-col.
     end.

     do on error undo, retry:
        vserie = "U".
        update vnumero  colon 15 label "Nota Fiscal" 
               "(0 = Todas as notas do coletor)"  
               vserie   colon 15 label "Serie" with frame f-col.
        if vnumero > 0
        then do:
             find plani where plani.etbcod = estab.etbcod  and
                              plani.movtdc = 6 and  /* 06=NF TRANSFERENCIA */
                              plani.serie  = vserie        and
                              plani.numero = vnumero no-lock no-error.
             if not avail plani
             then do:
                  message "Nota de transferencia nao encontrada".
                  undo, retry.
             end. 
        end.     
     end.

     do on error undo, retry:
        update vcol colon 15 label "Coletor" format "9"
               with frame f-col side-label
                                centered overlay color white/cyan.

        if opsys = "UNIX"
        then vpath = "/admcom/coletor/col" + string(vcol,"9") 
                           + "/LEITURA.TXT".
        else vpath = "m:\coletor\col" + string(vcol,"9") 
                        + "\LEITURA.TXT".
        if search(vpath) = ?
        then do:
              message "Nao encontrou arquivo do coletor " vpath .
              undo, retry.
        end.
        update vpath label "Arquivo" colon 15 format "x(40)"
             with frame f-col.
        if search(vpath) = ?
        then do:
              message "Nao encontrou arquivo do coletor " vpath .
              undo, retry.
        end.
     
     end.      
     
     for each tt-diverg where tt-diverg.etbcod = estab.etbcod
                             and tt-diverg.numero = plani.numero:
            delete tt-diverg.
     end.  

     input from value(vpath).
     repeat:
             import unformat vlei.
             assign vetb = int(substring(vlei,1,3))
                    vcod = int(substring(vlei,5,7)) 
                  vqtenv = int(substring(vlei,18,6)) /* ver posições corretas */
                    vqtrec = int(substring(vlei,18,6))
                    vnf  = int(substring(vlei,25,10)).


            if vetb <> estab.etbcod or vcod = 0 or vcod = ? or
               vcod = 1 or vcod = 2 or vcod = 3 or vcod = 4 or vcod = 5
            then next.
            
            if vnumero > 0 and vnumero <> vnf then next.
            
            find tt-movcol where tt-movcol.etbcod = estab.etbcod
                             and tt-movcol.numero = vnf
                             and tt-movcol.procod = vcod 
                             no-error.
            if not avail tt-movcol
            then do:
                 create tt-movcol.
                 assign tt-movcol.etbcod = estab.etbcod
                        tt-movcol.numero = vnf
                        tt-movcol.procod = vcod. 
            end.                           
            assign tt-movcol.qtenv = tt-movcol.qtenv + vqtenv.
                   tt-movcol.qtrec = tt-movcol.qtrec + vqtrec.
     end.

     vseq = 0.

     for each tt-movcol where tt-movcol.etbcod = estab.etbcod
                      no-lock
                      break by tt-movcol.etbcod
                            by tt-movcol.numero:
                            
         find first plani where plani.movtdc = 6
                            and plani.etbcod = tt-movcol.etbcod
                            and plani.serie = "U"
                            and plani.numero = tt-movcol.numero
                            no-lock no-error.
         if not avail plani 
         then do:
              vdiverg = "Nota não encontrada: " + string(tt-movcol.numero).
              run p-create-diverg(tt-movcol.numero, tt-movcol.procod).

              next.
         end.
                      
         if not can-find(first movim 
                         where movim.etbcod = estab.etbcod
                           and movim.placod = plani.placod
                           and movim.procod = tt-movcol.procod)
         then do:
              vdiverg = "Produto nao encotrado na Nota Fiscal".

              run p-create-diverg(tt-movcol.numero, tt-movcol.procod).
              next.
         end.
         if tt-movcol.qtenv <> tt-movcol.qtrec
         then do:
              vdiverg = "Divergencia entre enviadas e recebidas"
                         + " Enviada: " + string(tt-movcol.qtenv) 
                         + " Recebida: " + string(tt-movcol.qtrec).

              run p-create-diverg(tt-movcol.numero, tt-movcol.procod).
              next.

         end.

         if last-of(tt-movcol.numero)
         then do:

              for each movim where movim.etbcod = plani.etbcod
                               and movim.placod = plani.placod 
                               and movim.movtdc = plani.movtdc
                      no-lock: 
                      
                  assign vdiverg = "".
                  find btt-movcol where btt-movcol.etbcod = estab.etbcod
                                    and btt-movcol.placod = plani.placod
                                    and btt-movcol.procod = movim.procod 
                                no-lock no-error.
                  if not avail btt-movcol
                  then vdiverg = "Produto nao encotrado no coletor".
                  else if btt-movcol.qtenv <> movim.movqt
                       then vdiverg = " Qtde Enviada: " + 
                                      string(btt-movcol.qtenv) +
                                      " Qtde Recebida: " +
                                      string(btt-movcol.qtrec) +
                                       "  Qtde NF: "  + string(movim.movqt).
                  if vdiverg <> ""
                  then do:
                       run p-create-diverg(plani.numero, movim.procod). 
                  end.                   
              end.
         end.
                       
      end.
      
   if can-find(first tt-diverg 
                         where tt-diverg.etbcod = estab.etbcod
                         /*  and tt-diverg.numero = plani.numero */)
   then do:
        message "Existem divergencias. Listar divergencias? "  
        update vresp format "Sim/Nao".
        if vresp 
        then run p-lista.
        else do:         
             for each tt-diverg where tt-diverg.etbcod = estab.etbcod
                       /*      and tt-diverg.numero = plani.numero */
                        no-lock:
                 disp tt-diverg except tt-diverg.seq.
             end.
        end.     
   end.
   else message "Nota fiscal em conformidade com o coletor".     
     
 end.
procedure p-create-diverg.
   def input parameter p-numero as int.
   def input parameter p-procod as int.

   create tt-diverg.
   assign tt-diverg.etbcod = estab.etbcod
          tt-diverg.numero = p-numero
          tt-diverg.procod = p-procod 
          vseq = vseq + 1
          tt-diverg.seq = vseq 
          tt-diverg.descr = vdiverg.
          
   vdiverg = "".

end procedure.

procedure p-lista.
  if opsys = "unix"
  then do:
       find first impress where impress.codimp = setbcod 
                    no-lock no-error. 
       if avail impress
       then do:
                  run acha_imp.p (input recid(impress), 
                                  output recimp).
                  find impress where recid(impress) = recimp 
                            no-lock no-error.
                  if avail impress
                  then assign fila = string(impress.dfimp). 
                  else assign fila = "".
       end.
       else do:
                 fila = "".
                 message "Impressora nao cadastrada".
       end.
   
       varquivo = "../relat/confdis" + string(time).
        
       {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "63"
            &Cond-Var  = "80" 
            &Page-Line = "66" 
            &Nom-Rel   = ""confdis"" 
            &Nom-Sis   = """SISTEMA DEPOSITO""" 
            &Tit-Rel   = """CONFERENCIA DE DESCARGA"""
            &Width     = "80"
            &Form      = "frame f-cabcab"}
    end.                    
   else do:
        assign fila = "" 
               varquivo = "l:\relat\confdis" + string(time).
    
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "76"
            &Page-Line = "66"
            &Nom-Rel   = ""confdis"" 
            &Nom-Sis   = """SISTEMA DEPOSITO""" 
            &Tit-Rel   = """CONFERENCIA DE DESCARGA"""
            &Width     = "80"
            &Form      = "frame f-cabcab1"}

     end.
   
    if can-find(first tt-diverg) 
    then for each tt-diverg where tt-diverg.etbcod = estab.etbcod
                           /*  and tt-diverg.numero = plani.numero */
                           no-lock :
            disp tt-diverg except tt-diverg.seq.
    end.     
    ELSE message skip (2) "Descarca em conformidade".      
    put skip(2).

    output close.
    
   if opsys = "unix"
   then do:
        if fila = ""
        then run visurel.p (input varquivo, input ""). 
        else os-command silent lpr value(fila + " " + varquivo).

    end.
    else do:
        {mrod.i}
    end.
  
end procedure.
