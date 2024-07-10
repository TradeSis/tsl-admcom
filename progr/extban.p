/*
*
* importa extrato bancario (extban)
*
*/
 {admcab.i}
  
def var vatual as dec  format "->>>,>>>,>>9.99".
def var vanter as dec  format "->>>,>>>,>>9.99".
def var vcr as dec  format ">>>>>,>>9.99".
def var vdb as dec  format ">>>>>,>>9.99".
def var vrodape as char format "x(78)".

def var vreg as char format "x(250)".
def var vseq as int.
def var varq as char.
def var varquivo as char format "x(80)" label "Arquivo de extrato ".
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
      initial ["MARCAR","MARCA TUDO","ATUALIZAR","RELATORIO",""].

def var vdti           as date label "Data Inicial".
def var vdtf           as date label "Data Final".

def var esqcom2         as char format "x(12)" extent 5.

def temp-table tt-extrato
    field banco    as int Label "BANCO"
    field agencia  as char label "AG"
    field operacao as char label "OP"
    field conta    as char label "CONTA" format "x(10)"
    field dv       as char  label "DV"   format "x(01)"
    field data     as date  label "Data" format "99/99/9999"
    field hist     as char  label "Historico"
    field categ    as char
    field codlcto  as char
    field docum    as char  label "Documento"
    field valor    as dec   format "->>>,>>>,>>9.99" label "Valor"
    field tipo     as char  label "TP.L"
    field saldo    as dec  format "->>>,>>>,>>9.99" label "Saldo"
    field seq      as int
    index seq is primary unique
          seq
    index bco 
          banco
          agencia
          conta
          data
          seq.
           

form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
form tt-extrato.banco format ">>9"                       
     tt-extrato.agencia format "x(6)"
     tt-extrato.conta
     tt-extrato.dv
     vanter label "SALDO ANTERIOR"
     with frame fcab row 4 no-box side-labels centered.
     
 form 
     vrodape
     with  frame frod
            row screen-lines no-labels no-box centered width 80. 

form
    tt-extrato.data  format "99/99/9999"
    tt-extrato.hist  format "x(18)"
    tt-extrato.categ column-label "CATEG" FORMAT "X(3)"
    tt-extrato.codlcto  column-label "LCTO" format "x(4)"
    tt-extrato.docum format "x(15)"
    tt-extrato.valor
    tt-extrato.tipo column-label "D/C" format "x(1)"
    with frame frame-a 12 down row 5 centered width 80
                       .
                 
                 
                 
esqregua  = yes.
esqpos1  = 1.
esqpos2  = 1.

def var vi as int.
def var vb as char extent 3 format "x(10)"
        init[" B.BRASIL "," CAIXA "," BANRISUL "] 
    .
def var vrede as char.
def var vbanco as int.

vreg = "".
vseq = 0.
if opsys = "UNIX"
then varquivo = "../sispro/arquivo/".
else varquivo = "l:~\sispro~\arquivo~\".

do on error undo, retry:
    disp vb with frame f-b 1 down centered no-label.
    choose field vb with frame f-b.
    vrede = trim(vb[frame-index]).  

    update vdti colon 20
           help " [Sera limpado o periodo informado e importado novamente]"
           vdtf colon 20
           help " [Sera limpado o periodo informado e importado novamente]"
           with frame f-dt side-label .
    
    if opsys <> "UNIX"
    then do:
         varquivo = sel-arq01().
    end.
    update varquivo view-as fill-in size 64 by 1
           with frame f-abrir-arquivo 
                   no-underline title "Abrir Arquivo"
                   overlay view-as dialog-box.

    if search(varquivo) = ? 
    then do:
            message "Arquivo nao encontrado"
                    view-as alert-box error.
            undo.
    end.
end.

if vrede = "B.Brasil"
then do:
     vbanco = 1001.
     run p-bbrasil.
end.

if vrede = "CAIXA"
then do:
     vbanco = 1002. 
     run p-caixa.
end.     
if vrede = "BANRISUL"
then do:
     vbanco = 1003.
     run p-banrisul.
     end.
     
vrodape = 
      "    CREDITO:" + string(vcr,"->>>,>>>,>>9.99") + 
      "  DEBITO:" + string(vdb,"->>>,>>>,>>9.99") +
      "    SALDO:" + string(vatual,"->>>,>>>,>>9.99").
/*
disp tt-extrato.banco                        
     tt-extrato.agencia
     tt-extrato.conta
     tt-extrato.dv
     vanter
     with frame fcab.
disp  vrodape with frame frod.

*/

if not can-find(first tt-extrato)
then do:
     message "Nenhum lancamento encontrado" view-as alert-box.
     
     leave.     
  end.

run p-grava-arq.

/******

bl-princ:
repeat:
     /*
    disp esqcom1 with frame f-com1. 
    disp esqcom2 with frame f-com2.
    */
    pause 0.
    if recatu1 = ?
    then do:
        find first tt-extrato no-error.
        if not avail tt-extrato then leave.
       end.
    else
        find tt-extrato where recid(tt-extrato) = recatu1.
    vinicio = yes.
    if not available tt-extrato
    then do:
        message "NENHUMA extrato ENCONTRADA"    .
               undo, retry.
    end.
    clear frame frame-a all no-pause.

    run p-mostra.
    recatu1 = recid(tt-extrato).
    repeat:
        find next tt-extrato no-error.

        if not available tt-extrato
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
       
       run p-mostra. 
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-extrato where recid(tt-extrato) = recatu1.
        
        run p-mostra.
         choose field tt-extrato.data
                 go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        if keyfunction(lastkey) = "TAB"
        then do:
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-extrato no-error.

                if not avail tt-extrato
                then leave.
                recatu1 = recid(tt-extrato).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:      
            do reccont = 1 to frame-down(frame-a):
                find prev tt-extrato no-error.
                if not avail tt-extrato
                then leave.
                recatu1 = recid(tt-extrato).
            end.
            leave.
        end.

        if keyfunction(lastkey) = "cursor-left"
        then do:
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-extrato no-error.

            if not avail tt-extrato
            then next.
            color display normal
                tt-extrato.data.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-extrato no-error.
            if not avail tt-extrato
            then next.
            color display normal
                tt-extrato.data.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
  
        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.
          view frame frame-a .
        end.
               
        
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
          
          run p-mostra.
        recatu1 = recid(tt-extrato).
   end.
  
end.
******/
procedure p-mostra.
  
      disp 
           tt-extrato.data
           tt-extrato.hist
           tt-extrato.categ 
           tt-extrato.codlcto
           tt-extrato.docum
           tt-extrato.valor
           tt-extrato.tipo
           with frame frame-a. 
end procedure.

procedure p-caixa.
vseq = 0.
input from value(varquivo).
repeat:
    import unformat vreg. 
    vseq = vseq + 1.
    if substring(vreg,7,2) = "15"
    then do:
         assign vatual = dec(substring(vreg,151,18)) / 100.
         if substring(vreg,169,1) = "D" then vatual = vatual * -1.
    end.
    else if substring(vreg,7,2) = "11"
         then do:
              assign vanter = dec(substring(vreg,151,18)) / 100.
              if substring(vreg,169,1) = "D" then vanter = vanter * -1.
        end.

    if substring(vreg,7,2) = "13"
    then do:
        create tt-extrato.
        assign tt-extrato.seq     = vseq
               tt-extrato.banco   = int(substring(vreg,1,3))
               tt-extrato.agencia  = substring(vreg,53,5)
               tt-extrato.operacao = substring(vreg,59,3)
               tt-extrato.conta    = substring(vreg,62,9)
               tt-extrato.dv       = substring(vreg,71,1)
               tt-extrato.data     = date(substring(vreg,143,8))
               tt-extrato.hist     = substring(vreg,177,25)
               tt-extrato.categ    = substring(vreg,170,3)
               tt-extrato.codlcto  = substring(vreg,173,4)
               tt-extrato.docum    = substring(vreg,202,39)
               tt-extrato.valor    = dec(substring(vreg,151,18)) / 100
               tt-extrato.tipo     = substring(vreg,169,1)
               tt-extrato.saldo    = dec(substring(vreg,151,18)) / 100 .

        if tt-extrato.tipo = "c"
        then vcr = vcr + tt-extrato.valor.
        else vdb = vdb + tt-extrato.valor.       
           
  end.
end.
input close.
end procedure.

procedure p-bbrasil.
    def var auxvlr as char.
    vseq = 0.
    input from value(varquivo).
    repeat:
        import unformat vreg. 
        vseq = vseq + 1.
     
        if substring(vreg,35,3) <> "DEP"
        then next.

/*    disp vreg format "x(60)"
           substring(vreg,5,10) format "x(11)" label "data".
 */          
        
        if date(substring(vreg,5,10)) <> ? 
        then do:
             assign auxvlr = replace(substring(vreg,79,13),",","")
                    auxvlr = replace(auxvlr,".","").
                    
             create tt-extrato.
             assign tt-extrato.seq     = vseq
                    tt-extrato.banco   = 1
                    tt-extrato.agencia  = "0"
                    tt-extrato.operacao = ""
                    tt-extrato.conta    = ""
               tt-extrato.dv       = ""
               tt-extrato.data     = date(substring(vreg,5,10))
               tt-extrato.hist     = substring(vreg,35,20)
               tt-extrato.categ    = ""
               tt-extrato.codlcto  = "" 
               tt-extrato.docum    = substring(vreg,62,15)
               tt-extrato.valor    = dec(auxvlr) / 100
               tt-extrato.tipo     = substring(vreg,92,2)
            tt-extrato.saldo    = 0 /* dec(substring(vreg,151,18)) / 100 */
             no-error.

        if tt-extrato.tipo = "c"
        then vcr = vcr + tt-extrato.valor.
        else vdb = vdb + tt-extrato.valor.       
   
      end.
            
    end.

end procedure.

procedure p-banrisul.
    def var vdia as int.
    def var vmes as int.
    def var vano as int.
    def var vmeses as char extent 12 init
   ["JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"].
    
    def var auxvlr as char.
    vseq = 0.
    input from value(varquivo).
    repeat:
        import unformat vreg. 
        vseq = vseq + 1.
        
        if substring(vreg,2,14) = "++  MOVIMENTOS"
        then do:
             assign vano = int(substring(vreg,21,4))
                    vmes = 0.
             REPEAT VI = 1 TO 12:
                   if substring(vreg,17,3) = vmeses[vi]
                   then vmes = vi.
             end.
        end.
/*
        disp substring(vreg,1,30) format "x(30)" label "data".
 */

        if vmes = 0
        then next.
        if substring(vreg,6,3) <> "DEP"
        then next.

        if int(substring(vreg,2,2)) > 0
        then assign vdia = int(substring(vreg,2,2)).
        
        if vdia > 0 and vmes < 13 and vmes > 0
        then do:
             assign auxvlr = replace(substring(vreg,33,16),",","")
                    auxvlr = replace(auxvlr,".","").
                    
             create tt-extrato.
             assign tt-extrato.seq     = vseq
                    tt-extrato.banco   = 1
                    tt-extrato.agencia  = "0"
                    tt-extrato.operacao = ""
                    tt-extrato.conta    = ""
               tt-extrato.dv       = ""
               tt-extrato.data     = date(vmes,vdia,vano)
               tt-extrato.hist     = substring(vreg,6,16)
               tt-extrato.categ    = ""
               tt-extrato.codlcto  = "" 
               tt-extrato.docum    = substring(vreg,23,6)
               tt-extrato.valor    = dec(auxvlr) / 100
               tt-extrato.tipo     = substring(vreg,49,1)
            tt-extrato.saldo    = 0 /* dec(substring(vreg,151,18)) / 100 */
             no-error.
             
     disp tt-extrato.data tt-extrato.hist tt-extrato.docum
             tt-extrato.valor tt-extrato.tipo.

        if tt-extrato.tipo = "-"
        then vdb = vdb + tt-extrato.valor. 
        else vcr = vcr + tt-extrato.valor.
   
      end.
            
    end.

end procedure.

procedure p-grava-arq.

for each extban where extban.etbcod = vbanco
                  and extban.datmov >= vdti
                  and extban.datmov <= vdtf .
    delete extban.               
end.

for each tt-extrato no-lock:

   if tt-extrato.data < vdti
   or tt-extrato.data > vdtf then next.

   find extban where extban.etbcod = vbanco
                 and extban.dephora = tt-extrato.seq
                 and extban.datmov = tt-extrato.data no-error.
                 
   if not avail extban
   then  create extban.

   assign extban.etbcod = vbanco
          extban.bancod = vbanco
          extban.datexp  = today
          extban.datmov  = tt-extrato.data
          extban.dephora = tt-extrato.seq
          extban.campo1 = tt-extrato.docum
          extban.valdep = tt-extrato.valor
          extban.campo2  = tt-extrato.hist.
          
end.

end procedure.

