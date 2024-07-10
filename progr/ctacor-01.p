{admcab.i} 

form vetbcod like estab.etbcod label "Filial  "
     estab.etbnom no-label
     vfuncod like func.funcod  at 1 label "Vendedor"
     func.funnom no-label
       with frame f1 1 down side-label width 80.
     
{selestab.i vetbcod f1}     

if vetbcod > 0
then do on error undo:
    update vfuncod label "Vendedor" with frame f1.
    if vfuncod > 0
    then do:
        find func where func.etbcod = vetbcod and
                        func.funcod = vfuncod
                        no-lock.
        disp func.funnom with frame f1.
    end.                    
end.

def var vtipo as char format "x(15)".

update vtipo label "Tipo"
         help "Tipo: Est = Estoque / Compl =  Complemento Salarial"
                     with frame f1.
vtipo = caps(vtipo).
disp vtipo with frame f1.

def temp-table tt-conta
    field etbcod like estab.etbcod
    field funcod like func.funcod
    field credito as dec
    field debito as dec
    field licred as dec
    field saldo as dec
    field sitcor as char
    index i1 etbcod funcod
    .

def temp-table etb-conta
    field etbcod like estab.etbcod
    field credito as dec
    field debito as dec
    field licred as dec
    field saldo as dec
    field sitcor as char
    index i1 etbcod
    .
    

for each tt-lj no-lock:
    for each func where func.etbcod = tt-lj.etbcod no-lock:
        if vfuncod > 0 and func.funcod <> vfuncod
        then next.
        
        for each contacor where
                 contacor.natcor = no and
                 contacor.etbcod = tt-lj.etbcod and
                 contacor.clifor = ? and
                 contacor.funcod = func.funcod /*and
                 contacor.sitcor = "LIB"         */
                 and contacor.campo3[1] = vtipo
                 no-lock.

            if contacor.sitcor = "EXC"
            then next.

            find first tt-conta where tt-conta.etbcod = contacor.etbcod and
                                      tt-conta.funcod = contacor.funcod
                                      no-error.
            if not avail tt-conta
            then do:
                create tt-conta.
                assign tt-conta.etbcod = contacor.etbcod 
                       tt-conta.funcod = contacor.funcod
                       .
            end.
            assign
                tt-conta.debito = tt-conta.debito + contacor.valcob
                tt-conta.credito = tt-conta.credito + contacor.valpag
                .
        end.
    end.
end.
            
for each tt-conta:
    tt-conta.saldo = tt-conta.debito - tt-conta.credito - tt-conta.licred.

    find first etb-conta where
               etb-conta.etbcod = tt-conta.etbcod
               no-error.
    if not avail etb-conta
    then do:
        create etb-conta.
        etb-conta.etbcod = tt-conta.etbcod.
    end.
    assign          
        etb-conta.credito = etb-conta.credito + tt-conta.credito 
        etb-conta.debito  = etb-conta.debito + tt-conta.debito 
        etb-conta.licred  = etb-conta.licred + tt-conta.licred
        etb-conta.saldo   = etb-conta.saldo + tt-conta.saldo 
        .
end.            


def var tdebito as dec.
def var tcredito as dec.
def var tsaldo as dec.

form with frame ff.

def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "164"  
                &Cond-Var  = "120" 
                &Page-Line = "166" 
                &Nom-Rel   = ""ctacor01"" 
                &Nom-Sis   = """ RH """ 
                &Tit-Rel   = """ CONTA CORRENTE CONSULTORES """ 
                &Width     = "120"
                &Form      = "frame f-cabcab"}

disp with frame f1.

for each etb-conta:
    find estab where estab.etbcod = etb-conta.etbcod no-lock.
    disp etb-conta.etbcod  column-label "Fil"
         estab.etbnom no-label
         etb-conta.debito  column-label "Valor Devido"   format "->,>>>,>>9.99" 
         etb-conta.credito column-label "Valor Descontado" 
          format "->,>>>,>>9.99"
         etb-conta.saldo   column-label "Saldo"    format "->,>>>,>>9.99"
        with frame ff down width 120
          .

    down with frame ff.
    for each tt-conta where
             tt-conta.etbcod = etb-conta.etbcod:
        find func where func.etbcod = tt-conta.etbcod and
                        func.funcod = tt-conta.funcod no-lock.         
        disp 
        etb-conta.etbcod  column-label "Fil"   
        estab.etbnom no-label
                          func.UserCod no-label
        string(func.funcod) + "-" + func.funnom @ estab.etbnom
             tt-conta.debito @ etb-conta.debito
             tt-conta.credito @ etb-conta.credito
             tt-conta.saldo @ etb-conta.saldo
             with frame ff.
       down with frame ff.
    end.       
    put fill("-",80) format "x(80)".
    tdebito = tdebito + etb-conta.debito.
    tcredito = tcredito + etb-conta.credito.
    tsaldo = tsaldo + etb-conta.saldo.
end.          
         
disp "Total Geral" @ estab.etbnom
     tdebito @ etb-conta.debito
     tcredito @ etb-conta.credito
     tsaldo @ etb-conta.saldo
     with frame ff.

output close.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.

     
