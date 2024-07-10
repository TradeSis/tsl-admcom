{admcab.i}
def input parameter p-setcod like setor.setcod.
def input parameter p-etbcod like estab.etbcod.
def input parameter p-forcod like forne.forcod.

do on error undo:
    update p-setcod label "Setor"
       p-etbcod label "Filial"
       p-forcod label "Fornecedor"
       with frame fff side-label width 80.
    find estab where estab.etbcod = p-etbcod no-lock.
    find forne where forne.forcod = p-forcod no-lock.
end.
       
def temp-table tt-funrat
    field funcod like func.funcod
    field valor as dec
    field alt as log.

def var valor-rat as dec.
def var total-rat as dec.
def var falta-rat as dec.
def var vindex as int.
def var v-quem as char format "x(15)" extent 1.
v-quem[1] = "CREDIARISTA"
.
DISP v-quem with frame f1 no-label 1 column.
choose field v-quem with frame f1.
vindex = frame-index.

hide frame f1.
disp v-quem[vindex] with frame f-quem 1 down no-label.

update valor-rat label "Valor" format "->>>,>>9.99" with frame f2 column 20 
        side-label.

disp total-rat label "Rateio" format "->>>,>>9.99" 
     falta-rat label "Dif." format "->>>,>>9.99"
     with frame f2. 

for each func where func.etbcod = p-etbcod and
                    func.funfunc = v-quem[vindex]
                    NO-LOCK.
    create tt-funrat.
    tt-funrat.funcod = func.funcod.
end.

find first tt-funrat where tt-funrat.funcod > 0 no-lock no-error.
if not avail tt-funrat
then do:
    bell.
    message color red/with
    "Nenhum registro encontrado para rateio."
    view-as alert-box.
    return.
end.

form tt-funrat.funcod
     func.funnom no-label
     tt-funrat.valor
     with frame f-linha down
     .

{setbrw.i}
     
l1: repeat:
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        .

    run rateio.
    
    {sklcls.i
        &file = tt-funrat
        &help = "Enter = Altera Valor  F4 = Retorna  F1 = Grava Premio"
        &cfield = tt-funrat.funcod
        &noncharacter = /*
        &ofield = " tt-funrat.valor
                    func.funnom
                  "
        &aftfnd1 = " find func where func.etbcod = p-etbcod and
                                     func.funcod = tt-funrat.funcod
                            no-lock no-error.
                  "
        &where = true
        &aftselect1 = "
                do:
                update tt-funrat.valor.
                tt-funrat.alt = yes.
                leave keys-loop.
                end.

                "
        &otherkeys1 = " If keyfunction(lastkey) = ""GO""
                        then leave keys-loop.
                      "  
        &form = " frame f-linha "
     }
     if keyfunction(lastkey) = "END-ERROR"
     THEN DO:
        leave l1.
     end.   
     if keyfunction(lastkey) = "GO"
     then do:
        sresp = no.
        message "Confirma gerar Premios" update sresp.
        if sresp = no
        then next l1.
        else do:
            run gera-premio.
            leave l1.
        end.
     end.
end.


procedure rateio:
    def var qtd-rat as int init 0.
    total-rat = valor-rat.
    for each tt-funrat :
        if tt-funrat.alt = yes
        then total-rat = total-rat - tt-funrat.valor.
        else qtd-rat = qtd-rat + 1.
    end.    
    for each tt-funrat where tt-funrat.alt = no:
        tt-funrat.valor = total-rat / qtd-rat.
    end.    
    total-rat = 0.
    for each tt-funrat :
        total-rat = total-rat + tt-funrat.valor.
    end.
    falta-rat = valor-rat - total-rat.
    disp valor-rat total-rat falta-rat with frame f2.    
end procedure.        
                                
procedure gera-premio:
    
    def var vint-titnum as int.
    
    find foraut where foraut.forcod = p-forcod no-lock.
    find estab where estab.etbcod = p-etbcod no-lock.
    
    for each tt-funrat where 
             tt-funrat.funcod > 0 and
             tt-funrat.valor > 0:
        do transaction:
            create titluc.
            assign titluc.empcod = 19
                   titluc.modcod = foraut.modcod
                   titluc.clifor = foraut.forcod
                   titluc.titpar = 1
                   titluc.etbcod = estab.etbcod
                   titluc.titnat = yes
                   titluc.titsit = "BLO"
                   titluc.titdtemi = today
                   titluc.titdtven = today
                   titluc.titvlcob = tt-funrat.valor
                   titluc.cxacod   = 1
                   titluc.cobcod   = 1
                   titluc.evecod   = 4
                   titluc.datexp   = today
                   titluc.titobs[1] = ""
                   titluc.titobs[2] = ""
                   titluc.vencod = tt-funrat.funcod.
                
            titluc.titobs[2] = titluc.titobs[2] +
                        "|PREMIO=" + v-quem[1].
                    
            run p-gera-numaut (output vint-titnum). 

            titluc.titnum = string(vint-titnum).

            assign
                titluc.titsit = "BLO"
                titluc.cxacod = 0
                titluc.cobcod = 2
                titluc.evecod = 5 .

        end.
    
    end.

end procedure.

procedure p-gera-numaut.                    

   def buffer bf-numaut for numaut.

   def output parameter opint-titnum  as integer.

       
   find last bf-numaut where bf-numaut.etbcod = 999 exclusive-lock.
       
   if not avail bf-numaut
   then create bf-numaut.
               bf-numaut.titnum = bf-numaut.titnum + 1.
                                
   opint-titnum = bf-numaut.titnum.
       
   release bf-numaut.
       
end procedure.
