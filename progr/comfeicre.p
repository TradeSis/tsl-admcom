{admcab.i}
def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vanalitico as log format "Sim/Nao".

def var vtipo-feirao as char format "x(20)"
    extent 3 init ["TODOS","ANTIGO (Fora Carteira)","NOVO (Carteira)"] .
def var vindex-feirao      as int.
def var vfeirao-antigo as log.
def var vfeirao-novo   as log.


update vetbcod label "Filial" colon 11 with frame f1 1 down width 80
        side-label.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        bell.
        message color red/with
        "Filial não cadastrada."
        view-as alert-box.
        undo.
    end.
    disp estab.etbnom no-label with frame f1.
end.
else disp "Todas as filiais" @ estab.etbnom with frame f1.
 
update vdti colon 11 label "De"
       vdtf label "Ate"
       with frame f1.

       
if vdti = ? or vdtf = ? or vdti > vdtf
then do:
    bell.
    message color red/with
    "Favor verificar periodo informado."
    view-as alert-box.
    undo, retry.
end.

disp skip "   FEIRAO?:" vtipo-feirao no-label
    with frame f1.
choose field vtipo-feirao 
    with frame f1.

vindex-feirao = frame-index.

update vanalitico colon 11 label "Analitico?"
        with frame f1.

def var vdata as date.
def temp-table tt-dd no-undo
    field etbcod like estab.etbcod
    field cpf as char
    field titnum like titulo.titnum 
    field valor as dec
    index i1 etbcod cpf
    .

for each estab where (if vetbcod > 0
                      then estab.etbcod = vetbcod else true)
                      no-lock:
    disp "Aguarde processamento...  "
         estab.etbcod no-label
         with frame f-r 1 down no-box color message row 10.
    pause 0. 
    do vdata = vdti to vdtf:
        disp vdata no-label with frame f-r.
        pause 0.
        if not vanalitico
        then
        for each titulo where
             titulo.empcod   = 19 and
             titulo.titnat   = no and
             titulo.modcod   = "CRE" and
             titulo.etbcod   = estab.etbcod and
             titulo.titdtemi = vdata and
             (titulo.titpar = 0 or
              (titulo.titpar = 1 and
               titulo.titdtpag = titulo.titdtemi)) and
             titulo.titsit = "PAG"
             no-lock:
            vfeirao-antigo = acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM".
            vfeirao-novo   = acha("FEIRAO-NOVO",titulo.titobs[1])       = "SIM". 

            if  vfeirao-antigo or
                vfeirao-novo 
            then do:
                if  vindex-feirao = 1 or
                   (vindex-feirao = 2 and vfeirao-antigo) or
                   (vindex-feirao = 3 and vfeirao-novo)
                then do:
                    find first tt-dd where
                           tt-dd.etbcod = titulo.etbcod and
                           tt-dd.cpf = acha("CPF-AUTORIZA",titulo.titobs[1])
                           no-error.
                    if not avail tt-dd
                    then do:
                        create tt-dd.
                        assign
                            tt-dd.etbcod = titulo.etbcod
                            tt-dd.cpf = acha("CPF-AUTORIZA",titulo.titobs[1]) .
                    end.
                    tt-dd.valor = tt-dd.valor + titulo.titvlcob.
                end.       
            end.
        end.
        else
        for each titulo where
             titulo.empcod   = 19 and
             titulo.titnat   = no and
             titulo.modcod   = "CRE" and
             titulo.etbcod   = estab.etbcod and
             titulo.titdtemi = vdata and
             (titulo.titpar = 0 or
              (titulo.titpar = 1 and
               titulo.titdtpag = titulo.titdtemi)) and
             titulo.titsit = "PAG"
             no-lock:
            vfeirao-antigo = acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM".
            vfeirao-novo   = acha("FEIRAO-NOVO",titulo.titobs[1])       = "SIM". 

            if  vfeirao-antigo or
                vfeirao-novo 
            then do:
                if  vindex-feirao = 1 or
                   (vindex-feirao = 2 and vfeirao-antigo) or
                   (vindex-feirao = 3 and vfeirao-novo)
                then do:
                    find first tt-dd where
                           tt-dd.etbcod = titulo.etbcod and
                           tt-dd.cpf = acha("CPF-AUTORIZA",titulo.titobs[1]) and
                           tt-dd.titnum = titulo.titnum
                           no-error.
                    if not avail tt-dd
                    then do:
                        create tt-dd.
                        assign
                            tt-dd.etbcod = titulo.etbcod
                            tt-dd.cpf = acha("CPF-AUTORIZA",titulo.titobs[1])
                            tt-dd.titnum = titulo.titnum .
                    end.
                    tt-dd.valor = tt-dd.valor + titulo.titvlcob.
                end.           
            end.
        end.
    end.
end.
            
def var varquivo as char.
    
varquivo = "/admcom/relat/confcre" + string(setbcod) + "."
                    + string(time).
    
{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""confeicre"" 
                &Nom-Sis   = """CREDIARIO""" 
                &Tit-Rel   = """VALORES PAGOS NOVACAO FEIRAO "" + vtipo-feirao[vindex-feirao] " 
                &Width     = "80"
                &Form      = "frame f-cabcab"}


if not vanalitico
then
for each tt-dd.
    find clien where clien.ciccgc = tt-dd.cpf no-lock no-error.
    find estab where estab.etbcod = tt-dd.etbcod no-lock no-error.
    disp tt-dd.etbcod column-label "Filial" 
         /*estab.etbnom when avail estab  no-label*/
         tt-dd.cpf    column-label "C.P.F"    format "x(16)"
         clien.clinom when avail clien  no-label format "x(25)"
         tt-dd.valor(total)    column-label "Valor"
         with down.
                
end.
else
for each tt-dd.
    find clien where clien.ciccgc = tt-dd.cpf no-lock no-error.
    find estab where estab.etbcod = tt-dd.etbcod no-lock no-error.
    disp tt-dd.etbcod column-label "Filial" 
         /*estab.etbnom when avail estab  no-label*/
         tt-dd.cpf    column-label "C.P.F"  format "x(16)"
         clien.clinom when avail clien  no-label format "x(25)"
         tt-dd.titnum column-label "Contrato"
         tt-dd.valor(total)    column-label "Valor"
         with down width 100.
                
end.
    
output close.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.

                
