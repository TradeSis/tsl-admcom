{admcab.i}

def var vi as int.
def temp-table tt-clien
    field clicod like clien.clicod
    field etbcod like estab.etbcod
    field contnum like contrato.contnum
    field tipo as int     
    index i1 tipo etbcod
    .

def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vfil1 as int.
def var vfil2 as int.

update vfil1 label "Filial "
       vfil2 label " Ate " 
       with frame f1 width 80 side-label.
/*
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
end.
else disp "GERAL" @ estab.etbnom with frame f1.
*/
if vfil1 = 0 or vfil2 = 0
then undo.

assign
    vdti = today - 1
    vdtf = today - 1.
    
update vdti at 1 label "Perioso de"
       vdtf label "Ate"
       with frame f1.

def buffer bplani for plani.
def buffer bcontrato for contrato.
def var vqtd as int.

def var vtipo as char extent 5 format "x(15)".

assign
    vtipo[1] = "PRIMEIRA COMPRA SEM ENTRADA" 
    vtipo[2] = "COMPRA COM CPF INVALIDO"
    vtipo[3] = "PARCELA DA PRIMEIRA COMPRA MAIOR QUE  10% DA RENDA"
    vtipo[4] = "ATRASO 5 PRIMEIRAS PARCELAS DO PRIMEIRO CONTRATO"
     .

def var vok as log.
def var vrenda as dec.

def buffer btitulo for titulo.

for each estab where  estab.etbcod >= vfil1 and
                      estab.etbcod <= vfil2 and
             estab.etbnom begins "DREBES-FIL"
             NO-LOCK:
    disp "Processando.... Aguade! "
         estab.etbcod no-label
         with frame fd1 no-label row 10 centered.
    pause 0.     
    for each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = 5 and
                         plani.pladat >= vdti and
                         plani.pladat <= vdtf
                         no-lock: 
        if plani.crecod = 1
        then next.
        disp plani.numero format ">>>>>>>>9" plani.pladat with frame fd1.
        pause 0.
        find contnf where contnf.etbcod = plani.etbcod and
                          contnf.placod = plani.placod 
                          no-lock no-error.
        if not avail contnf then next.
        find contrato where contrato.contnum = contnf.contnum 
                            no-lock no-error.
        if not avail contrato then next.
                            
        find clien where clien.clicod = contrato.clicod no-lock.
        vok = yes.
        run cpf.p(input clien.ciccgc,
                              output vok).
        if vok = no
        then do:
            find first tt-clien where 
                       tt-clien.etbcod = estab.etbcod and
                       tt-clien.clicod = clien.clicod and
                       tt-clien.contnum = contrato.contnum and
                       tt-clien.tipo = 2
                       no-error.
            if not avail tt-clien
            then do:
                create tt-clien.
                assign
                    tt-clien.etbcod = estab.etbcod 
                    tt-clien.clicod = clien.clicod 
                    tt-clien.contnum = contrato.contnum
                    tt-clien.tipo = 2.
            end. 
        end. 
        
        vqtd = 0.
        for each bcontrato where
                 bcontrato.clicod = clien.clicod no-lock:                  
            vqtd = vqtd + 1.
        end.
        if vqtd > 1
        then next.
        disp contrato.clicod with frame fd1.
        if contrato.vlentra = 0
        then do:
            find first tt-clien where 
                       tt-clien.etbcod = estab.etbcod and
                       tt-clien.clicod = clien.clicod and
                       tt-clien.contnum = contrato.contnum and
                       tt-clien.tipo = 1
                       no-error.
            if not avail tt-clien
            then do:
                create tt-clien.
                assign
                    tt-clien.etbcod = estab.etbcod 
                    tt-clien.clicod = clien.clicod 
                    tt-clien.contnum = contrato.contnum
                    tt-clien.tipo = 1.
            end.                     
        end.
        vrenda = clien.prorenda[1] + clien.prorenda[2].
        vok = no.
        for each titulo where
                 titulo.empcod = 19 and
                 titulo.titnat = no and
                 titulo.modcod = "CRE" and
                 titulo.etbcod = contrato.etbcod and
                 titulo.clifor = clien.clicod and
                 titulo.titnum = string(contrato.contnum)
                 no-lock:
            if titulo.titsit = "PAG"
            then next.
            
            if (titulo.titvlcob / vrenda) * 100 > 10
            then do:
                vok = yes.
                leave.
            end.    
        end.
        if vok = yes
        then do:     
            find first tt-clien where 
                       tt-clien.etbcod = estab.etbcod and
                       tt-clien.clicod = clien.clicod and
                       tt-clien.contnum = contrato.contnum and
                       tt-clien.tipo = 3
                       no-error.
            if not avail tt-clien
            then do:
                create tt-clien.
                assign
                    tt-clien.etbcod = estab.etbcod 
                    tt-clien.clicod = clien.clicod 
                    tt-clien.contnum = contrato.contnum
                    tt-clien.tipo = 3.
            end. 
        end.                            
    end.
    vqtd = 0.
    for each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = "CRE" and
                          titulo.titsit = "LIB" and
                          titulo.etbcod = estab.etbcod and
                          titulo.titpar = 5 and
                          titulo.titdtven <= vdti 
                          no-lock.
        disp titulo.titnum with frame fd1.
        pause 0.
        find clien where clien.clicod = titulo.clifor
                    no-lock no-error.
        if not avail clien then next. 
        find contrato where 
             contrato.contnum = int(titulo.titnum)
                         no-lock no-error.
        if not avail contrato
        then next.
        find prev contrato where
                  contrato.clicod = clien.clicod
                  no-lock no-error.  
        if avail contrato then next.                  
        vqtd = 0.
        for each contrato where 
            contrato.clicod = titulo.clifor no-lock:
            vqtd = vqtd + 1.
        end.
        vok = no.
        do vi = 1 to 5:
            find btitulo where btitulo.empcod = 19 and
                          btitulo.titnat = no and
                          btitulo.modcod = "CRE" and
                          btitulo.etbcod = titulo.etbcod and
                          btitulo.clifor = titulo.clifor and
                          btitulo.titnum = titulo.titnum and
                          btitulo.titpar = vi
                          no-lock no-error.
            if not avail btitulo or
                btitulo.titsit = "PAG"
            then do:
                vok = no.
                leave.
            end.
            vok = yes.    
        end. 
        if vok = yes
        then do:
            find first tt-clien where 
                       tt-clien.etbcod = estab.etbcod and
                       tt-clien.clicod = clien.clicod and
                       tt-clien.contnum = int(titulo.titnum) and
                       tt-clien.tipo = 4
                       no-error.
            if not avail tt-clien
            then do:
                create tt-clien.
                assign
                    tt-clien.etbcod = estab.etbcod 
                    tt-clien.clicod = clien.clicod 
                    tt-clien.contnum = int(titulo.titnum)
                    tt-clien.tipo = 4.
            end.            
        end.
    end.
end.

def buffer bestab for estab.

def var varquivo as char.
if opsys = "UNIX"
then varquivo = "/admcom/relat/infocli0" + string(time).
else varquivo = "l:~\relat~\infocli0" + string(time).

{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""infocli0"" 
                &Nom-Sis   = """SISTEMA FINANCEIRO""" 
                &Tit-Rel   = """ INFORMATIVO DE CLIENTES ** Periodo: ""
                            + string(vdti,""99/99/9999"") + "" ate "" +
                              string(vdtf,""99/99/9999"") " 
                &Width     = "80"
                &Form      = "frame f-cabcab"}
 
for each tt-clien,
    first clien where clien.clicod = tt-clien.clicod no-lock 
                  break by tt-clien.tipo 
                        by tt-clien.etbcod
                        by clien.clinom :
    
    /*if first-of(tt-clien.tipo)
    then do:
        disp vtipo[tt-clien.tipo] with frame f-tipo
        no-label.
    end.*/    
    if first-of(tt-clien.etbcod)
    then do:
        find bestab where bestab.etbcod = tt-clien.etbcod no-lock.
        disp vtipo[tt-clien.tipo]  label  "Motivo" format "x(60)"
             bestab.etbcod at 1     label "Filial"
             bestab.etbnom no-label
             with frame f-tp side-label width 80 no-box.
    end. 
    disp tt-clien.clicod
         clien.clinom
         tt-clien.contnum
         with frame f-dispcl down.
    down with frame f-dispcl.     
    if last-of(tt-clien.etbcod)
    then down(1) with frame f-dispcl.
    if last-of(tt-clien.etbcod)
    then put fill("=",80) format "x(80)".    
end.
output close.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.    
