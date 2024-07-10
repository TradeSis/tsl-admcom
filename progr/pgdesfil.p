/*
*
* Relatório para conferencia das despesas financeiras  (confdes1.p)  
*
*/

{/admcom/progr/admcab-batch.i new}

def var varq as char.
def var varquivo as char.

def temp-table tt-ip
    field ip as char
    field etbcod like estab.etbcod.

def var difpre like plani.platot.
def var difpra like plani.platot.
def var vok as char format "x(01)".
def var vdti            like plani.pladat initial today.
def var vdtf            like plani.pladat initial today.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
      initial ["MARCAR","MARCA TUDO","ATUALIZAR","RELATORIO",""].


def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].
            
def new shared temp-table tt-saldo 
    field etbcod like estab.etbcod
    field data   like plani.pladat
    field pra    like plani.platot
    field pre    like plani.platot
    field ent    like plani.platot.

def new shared temp-table tt-diverg
    field empcod like fin.titluc.empcod
    field titnat like fin.titluc.titnat
    field modcod like fin.titluc.modcod
    field etbcod like fin.titluc.etbcod
    field clifor like fin.titluc.clifor
    field titnum like fin.titluc.titnum
    field titpar like fin.titluc.titpar
    field titsit like fin.titluc.titsit
    field titdtpag like fin.titluc.titdtpag 
    field titvlcob like fin.titluc.titvlcob    
    field obs    as char format "x(40)"
    field marca as char
    index etbcod is primary
           etbcod
           titnum     
    index titnum is unique
           empcod
           titnat
           modcod
           etbcod
           CliFor
           titnum
           titpar
    index mar marca.


def var vetbcod         like estab.etbcod.
def var vetbcod1        like estab.etbcod.
form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
esqregua  = yes.
esqpos1  = 1.
esqpos2  = 1.
vdti     = today - 1.
vdtf     = today - 1.
    
for each tt-saldo:
        delete tt-saldo.
end.
    
def temp-table tt-estab
    field etbcod like estab.etbcod
    field conect as log.
vdtf = today - 1.
vdti = vdtf - 7. 
for each tt-estab.
    delete tt-estab.
end.
def var vi as int.

for each estab where 
         estab.etbcod < 200 and
         estab.etbnom begins "DREBES-FIL"
         no-lock:
    if estab.etbcod = 22 then next.
    create tt-estab.
    tt-estab.etbcod = estab.etbcod.
end.
def var varquivo1 as char.

varquivo1 = "/admcom/logs/pgdesfil.log".
output to value(varquivo1).
put today space(5) string(time,"hh:mm:ss") skip.
output close.

for each estab no-lock.
    
    if estab.etbcod > 99 then next.
    
      create tt-ip.
      assign tt-ip.etbcod = estab.etbcod
             tt-ip.ip   = "filial" + string(estab.etbcod,"999").

end.
/*** Contas a pagar ***/

if connected ("banfin")
then disconnect banfin.
connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin no-error.

def buffer bestab for estab.
def var v-ok as char.
for each tt-diverg:
    delete tt-diverg .
end.
for each tt-estab,    
    first bestab where bestab.etbcod = tt-estab.etbcod
                    no-lock:
    tt-estab.conect = no.
    if connected ("finloja")
    then disconnect finloja.
    
    find first  tt-ip where 
                tt-ip.etbcod = bestab.etbcod  no-error.
    output to value(varquivo1) append.            
    put "Conectando......  Filial: "  bestab.etbcod format ">>9"
                "    Verificando... " .
    output close.        
    connect fin -H value(tt-ip.ip) -S sdrebfin -N tcp -ld finloja 
                                            no-error.
    
    if not connected ("finloja")
    then do:
        output to value(varquivo1) append.
        put "    NAO CONECTADO"  skip.
        output close.
        next.
    end.                
    tt-estab.conect = yes.              
    run confdes2.p(input bestab.etbcod,
                   input vdti,
                   input vdtf).
                
    if connected ("finloja")
    then  disconnect finloja.
    
    if can-find(first tt-diverg where tt-diverg.etbcod = bestab.etbcod)
    then v-ok = "DIVERG.".
    else v-ok = "OK".

    output to value(varquivo1) append.
    put v-ok  skip.
    output close.

    run p-grava-registro.
end.
if connected ("banfin") 
then disconnect banfin.
if connected ("finloja")
then  disconnect finloja.


procedure p-grava-registro.
   def var vconf as log init no format "Sim/Nao".
   def buffer btt-diverg for tt-diverg.
   do:     
        for each btt-diverg where btt-diverg.clifor > 0:
            find fin.titluc where 
                             fin.titluc.empcod = btt-diverg.empcod and
                             fin.titluc.titnat = btt-diverg.titnat and
                             fin.titluc.modcod = btt-diverg.modcod and
                             fin.titluc.etbcod = btt-diverg.etbcod and
                             fin.titluc.clifor = btt-diverg.clifor and
                             fin.titluc.titnum = btt-diverg.titnum and
                             fin.titluc.titpar = btt-diverg.titpar
                             no-lock no-error.
            if avail fin.titluc
            then do:
                run paga-titluc.p (recid(fin.titluc)). 
            end.

            delete btt-diverg.
            
        end.
        
    end.

end procedure.
