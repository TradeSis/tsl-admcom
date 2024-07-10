/*   devdep1.p coleta produtos e compara com a nota */

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
def var vcod2           as i    format "999999".
def var vqtd            as i    format "999999".
def var vnumero         like plani.numero.
def var vserie          like plani.serie.
def var vetbcod         as int format ">>9".
def var vplacod         like plani.placod.
def var vseq            as int .
def var vdiverg         as char.
def var vresp           as log.
def var recimp          as recid.
def var fila           as char.

def temp-table tt-movcol
    field etbcod like estab.etbcod
    field placod like plani.placod
    field procod like produ.procod
    field movqt  like movim.movqt
    index movim is primary unique
         etbcod
         placod
         procod.
         
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

repeat:
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
               vserie   colon 15 label "Serie" with frame f-col.

        find plani where plani.etbcod = estab.etbcod  and
                         plani.movtdc = 6             and
                         plani.serie  = vserie        and
                         plani.numero = vnumero no-lock no-error.
        if not avail plani
        then do:
             message "Nota de transferencia nao encontrada".
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
             assign vetb = int(substring(string(vlei),1,3))
                    vcod = int(substring(string(vlei),5,7)) 
                    vcod2 = int(substring(string(vlei),5,7)) 
                    vqtd = int(substring(string(vlei),18,6)).

            if vetb <> estab.etbcod or vcod = 0 or vcod = ? or
               vcod = 1 or vcod = 2 or vcod = 3 or vcod = 4 or vcod = 5
            then next.
            find produ where produ.procod = vcod no-lock no-error.
            if not avail produ
            then find produ where produ.procod = vcod2 no-lock no-error.
            
            find tt-movcol where tt-movcol.etbcod = estab.etbcod
                             and tt-movcol.placod = plani.placod
                             and tt-movcol.procod = produ.procod 
                             no-error.
            if not avail tt-movcol
            then do:
                 create tt-movcol.
                 assign tt-movcol.etbcod = estab.etbcod
                        tt-movcol.placod = plani.placod
                        tt-movcol.procod = produ.procod. 
            end.                           
            assign tt-movcol.movqt = tt-movcol.movqt + vqtd.
     end.

     vseq = 0.
     for each movim where movim.etbcod = plani.etbcod
                      and movim.placod = plani.placod 
                      no-lock:
                      
         assign vdiverg = "".
         find tt-movcol where tt-movcol.etbcod = estab.etbcod
                          and tt-movcol.placod = plani.placod
                          and tt-movcol.procod = movim.procod 
                             no-error.
         if not avail tt-movcol
         then vdiverg = "Produto nao encotrado no coletor".
         else if tt-movcol.movqt <> movim.movqt
              then vdiverg = " Qtde Coletor: " + string(tt-movcol.movqt) +
                              "  Qtde NF: "  + string(movim.movqt).
         if vdiverg <> ""
         then do:
              create tt-diverg.
              assign tt-diverg.etbcod = estab.etbcod
                     tt-diverg.numero = plani.numero
                     tt-diverg.procod = movim.procod 
                     vseq = vseq + 1
                     tt-diverg.seq = vseq 
                     tt-diverg.descr = vdiverg.
         end.                       
     end.
     
     for each tt-movcol where tt-movcol.etbcod = plani.etbcod
                           and tt-movcol.placod = plani.placod 
                      no-lock:
                      
         assign vdiverg = "".
         if not can-find(first movim 
                         where movim.etbcod = estab.etbcod
                           and movim.placod = plani.placod
                           and movim.procod = tt-movcol.procod)
         then do:
              create tt-diverg.
              assign tt-diverg.etbcod = estab.etbcod
                     tt-diverg.numero = plani.numero
                     tt-diverg.procod = tt-movcol.procod 
                     tt-diverg.descr = "Produto nao encotrado na Nota Fiscal"
                     vseq = vseq + 1
                     tt-diverg.seq = vseq . 
         end.                       
      end.
   if can-find(first tt-diverg 
                         where tt-diverg.etbcod = estab.etbcod
                           and tt-diverg.numero = plani.numero)
   then do:
        message "Existem divergencias. Listar divergencias?"  
        update vresp format "Sim/Nao".
        if vresp 
        then run p-lista.
        else do:         
             for each tt-diverg where tt-diverg.etbcod = estab.etbcod
                             and tt-diverg.numero = plani.numero:
                 disp tt-diverg except tt-diverg.seq.
             end.
        end.     
   end.
   else message "Nota fiscal em conformidade com o coletor".     
     
 end.
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
   
       varquivo = "../relat/devdep" + string(time).
        
       {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "63"
            &Cond-Var  = "80" 
            &Page-Line = "66" 
            &Nom-Rel   = ""devdep"" 
            &Nom-Sis   = """SISTEMA DEPOSITO""" 
            &Tit-Rel   = """DEVOLUCAO DE PRODUTOS"""
            &Width     = "80"
            &Form      = "frame f-cabcab"}
    end.                    
   else do:
        assign fila = "" 
               varquivo = "l:\relat\devdep" + string(time).
    
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "76"
            &Page-Line = "66"
            &Nom-Rel   = ""devdep"" 
            &Nom-Sis   = """SISTEMA DEPOSITO""" 
            &Tit-Rel   = """DEVOLUCAO DE PRODUTOS"""
            &Width     = "80"
            &Form      = "frame f-cabcab1"}

     end.
   
    if can-find(first tt-diverg) 
    then for each tt-diverg where tt-diverg.etbcod = estab.etbcod
                             and tt-diverg.numero = plani.numero:
            disp tt-diverg except tt-diverg.seq.
    end.     
    else message skip(2) "Nota fiscal em conformidade com o coletor.".     
    
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
