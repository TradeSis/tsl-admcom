{admcab.i}

def temp-table tt-plani like plani.
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".

find first  rfvparam  no-lock no-error.
vdtf = rfvparam.recencia-i[1] - 1.

update vdti label "Data Inicial"
       vdtf label "Data Final"
            with frame f-1 1 down side-label width 80.
            
disp vdtf label "Data Final" with frame f-1.

def buffer bplani for plani.

def var vspc as log format "Sim/Nao".

vspc = no.
update vspc label "Descartar clientes com registro no SPC?" with frame f-1.

sresp = no.
Message "Confirma processamento?" update sresp.
if not sresp then return.

form "Processando.... " 
        with frame f-p 1 down width 80 no-box color message side-label.

def var vdata as date.
do vdata = vdti to vdtf:
    disp vdata no-label with frame f-p. 
    pause 0.
    for each estab no-lock:
        disp estab.etbcod label "Filial" with frame f-p.
        pause 0.
        for each plani where plani.movtdc = 5 and
                         plani.etbcod = estab.etbcod and
                         plani.pladat = vdata
                         no-lock:
            find first bplani where
                       bplani.movtdc = plani.movtdc and
                       bplani.desti  = plani.desti and
                       bplani.pladat >= vdata  and
                       bplani.numero <> plani.numero
                       no-lock no-error.
            if not avail bplani            
            then do:
                find first tt-plani where
                           tt-plani.movtdc = plani.movtdc and
                           tt-plani.desti  = plani.desti
                           no-error.
                if avail tt-plani
                then delete tt-plani.
                else do:            
                    create tt-plani.
                    buffer-copy plani to tt-plani.
                end.
            end.
        end.
    end.
end.     
def var log-clispc as log.
def var varquivo as char.
varquivo = "/admcom/relat/rcliultcmp." + string(time).

{mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "120"
            &Page-Line = "64"
            &Nom-Rel   = ""rcliultcmp""
            &Nom-Sis   = """SISTEMA COMERCIAL"""
            &Tit-Rel   = """ CLIENTE ULTIMA COMPRA """ 
            &Width     = "120"
            &Form      = "frame f-cabcab"}

disp with frame f-1.

for each tt-plani by tt-plani.desti:
    find clien where clien.clicod = tt-plani.desti no-lock no-error.
    if not avail clien then next.
    log-clispc = no.
    find first fin.clispc where clispc.clicod = clien.clicod
                        and clispc.dtcanc = ? no-lock no-error.
    if avail fin.clispc and vspc
    then next.
    if avail fin.clispc then log-clispc = yes.
    find first d.clispc where d.clispc.clicod = clien.clicod
                        and d.clispc.dtcanc = ? no-lock no-error.
    if avail d.clispc and vspc
    then next.
    if avail d.clispc then log-clispc = yes.
        
    disp tt-plani.desti column-label "Codigo"  format ">>>>>>>>>9"
         clien.clinom   column-label "Nome"
         tt-plani.numero column-label "Numero!Ultima!Venda" format ">>>>>>>>9"
         tt-plani.etbcod column-label "Filial!Ultima!Venda"
         clien.fone format "x(15)" column-label "Telefone!Convencional"
         clien.fax  format "x(15)" column-label "Telefone!Celular"
         log-clispc format "Sim/Nao"       column-label "SPC"
         with frame f-disp down width 120.
end.

output close.

run visurel.p(varquivo,"").
