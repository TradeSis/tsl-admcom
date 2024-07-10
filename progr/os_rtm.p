{admcab.i}

def var vetbcod like estab.etbcod.
def var vforne  like forne.forcod.
def var vdti as date.
def var vdtf as date.


update vetbcod label "Filial"
        with frame f-1 1 down width 80 side-label.

if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f-1.
end.
else disp "GERAL" @ estab.etbnom with frame f-1.

update vforne label "Fornecedor"
        with frame f-1 1 down width 80 side-label.
        
if vforne > 0
then do:
    find forne where forne.forcod = vforne no-lock.
    disp forne.fornom no-label with frame f-1.
end.
else disp "GERAL" @ forne.fornom with frame f-1.    

update vdti at 1 label "Data Inicial"
       vdtf label "Data final"
       with frame f-1.

if  vdti = ? or 
    vdtf = ? or  
    vdti > vdtf
then undo.

def var vpronom like produ.pronom.
def var vclinom like clien.clinom.

def var vindex as int.

def var vsel as char format "x(20)" extent 3
        init["30 DIAS","REINCIDENCIA","GARANTIA PLANO BI$"].

disp vsel with frame f-sel 1 down no-label.
choose field vsel with frame f-sel. 

vindex = frame-index.

def var varquivo as char.

if opsys = "UNIX"
then varquivo = "/admcom/relat/os_rtm." + string(time).
else varquivo = "..\relat\os_rtm." + string(time).

{mdad.i &Saida     = "value(varquivo)" 
        &Page-Size = "0" 
        &Cond-Var  = "120" 
        &Page-Line = "66"
        &Nom-Rel   = ""asstec""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
        &Tit-Rel   = """LISTAGEM DE OS - TROCAS "" +
                        VSEL[VINDEX] "
        &Width     = "120"
        &Form      = "frame f-cabcab"}

 disp with frame f-1.
 
if vindex <> 4
then
for each asstec_aux where
         asstec_aux.data_campo >= vdti and
         asstec_aux.data_campo <= vdtf and
         asstec_aux.nome_campo = "REGISTRO-TROCA" and
         asstec_aux.valor_campo = vsel[vindex]
         no-lock,
    first asstec where
               asstec.oscod = asstec_aux.oscod  and
               (if vforne > 0 then asstec.forcod = vforne else true)
               no-lock :
         
    find produ where produ.procod = asstec.procod no-lock no-error.
    if avail produ
    then vpronom = produ.pronom.
    else vpronom = "".
    find clien where clien.clicod = asstec.clicod no-lock no-error.
    if avail clien and clien.clicod <> 0
    then vclinom = clien.clinom.
    else vclinom = "ESTOQUE".

    disp  
                asstec.etbcod column-label "Fil"
                asstec.oscod  format ">>>>>>9"
                asstec.datexp column-label "Data!Inclusao"
                asstec.procod
                vpronom format "x(20)"
                asstec.clicod 
                vclinom format "x(14)"   
                with frame f-disp down
                width 120.
 
end.
else do:
    for each asstec where 
             (if vetbcod > 0 then asstec.etbcod = vetbcod else true) and
             asstec.dtentdep >= vdti and
             asstec.dtentdep <= vdtf
              no-lock.
         if vforne > 0 and
            asstec.forcod <> vforne
         then next.   

    if asstec.planum > 0
    then do:
            find first plani where plani.etbcod = asstec.etbcod and
                                  plani.movtdc = 5 and
                                   plani.emite  =  asstec.etbcod and
                                   plani.serie = "V" and
                                   plani.numero = asstec.planum and
                                   plani.pladat = asstec.pladat and
                                   plani.pladat >= 11/01/2011
                                   no-lock no-error.
            if not avail plani
            then next.

            find first tabaux where tabaux.tabela = "PLANOBIZ" and
                           tabaux.valor_campo = string(plani.pedcod)
                           no-lock no-error.
            if avail tabaux
            then next.
            
        end.
        
         find produ where produ.procod = asstec.procod no-lock no-error.
        if avail produ
        then vpronom = produ.pronom.
    else vpronom = "".
    find clien where clien.clicod = asstec.clicod no-lock no-error.
    if avail clien and clien.clicod <> 0
    then vclinom = clien.clinom.
    else vclinom = "ESTOQUE".

    disp  
                asstec.etbcod column-label "Fil"
                asstec.oscod  format ">>>>>>9"
                asstec.datexp column-label "Data!Inclusao"
                asstec.procod
                vpronom format "x(20)"
                asstec.clicod 
                vclinom format "x(14)"   
                with frame f-disp1 down
                width 120.
 
    end.
end.
output close.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.
