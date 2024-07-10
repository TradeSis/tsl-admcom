{admcab.i}

def temp-table tt-plaent
    field numero like plani.numero
    field serie  like plani.serie
    field emite  like plani.emite
    field fornom like forne.fornom
    field ufecod like forne.ufecod
    field dtinclu like plani.dtinclu
    field pladat  like plani.pladat
    field dias-e  as int
    field dias-p  as int
    field sit     as char
    field titdtven like titulo.titdtven
    field dtvenori like titulo.titdtven
    field dias-v as int
    index i1 dtinclu
    index i2 titdtven
      .
     
update vetbcod like estab.etbcod label "Filial" with side-label width 80.
find estab where estab.etbcod = vetbcod no-lock.
disp estab.etbnom no-label.

def var vdti as date.
def var vdtf as date.
vdti = today - 1.
vdtf = vdti.

update vdti  at 1 format "99/99/9999" label "Periodo"
       vdtf  format "99/99/9999" no-label
       .

if vdti > vdtf then undo.

def var vdiaspad as int.
def var vsit as char.

for each plani where plani.etbcod = vetbcod and
                     plani.movtdc = 4 and
                     plani.dtinclu >= vdti and
                     plani.dtinclu <= vdtf
                     no-lock:
                     
    find first forne where forne.forcod = plani.emite no-lock.

    run dias-padrao.

    vsit = "OK".
    if (plani.dtinclu - plani.pladat) > vdiaspad
    then vsit = "PROBLEMA".

    create tt-plaent.
    assign
        tt-plaent.numero = plani.numero
        tt-plaent.serie  = plani.serie
        tt-plaent.emite  = plani.emite
        tt-plaent.fornom = forne.fornom
        tt-plaent.ufecod = forne.ufecod
        tt-plaent.dtinclu = plani.dtinclu
        tt-plaent.pladat  = plani.pladat
        tt-plaent.dias-e  = plani.dtinclu - plani.pladat
        tt-plaent.dias-p  = vdiaspad
        tt-plaent.sit     = vsit
        .
 
    find titulo where titulo.empcod = 19 and
                      titulo.titnat = yes and
                      titulo.modcod = "DUP" and
                      titulo.etbcod = plani.etbcod and
                      titulo.clifor = plani.emite and
                      titulo.titnum = string(plani.numero) and
                      titulo.titpar = 1 and
                      titulo.titdtemi = plani.dtinclu
                      no-lock no-error.
    if avail titulo
    then do:
        assign
            tt-plaent.titdtven = titulo.titdtven
            tt-plaent.dtvenori = titulo.titdtven
            tt-plaent.dias-v   = titulo.titdtven - plani.pladat
            .
 
        find first  hiscampotb where
                        hiscampotb.xtabela = "titulo" and
                        hiscampotb.xcampo  = "titdtven" and
                        hiscampotb.rowreg = string(rowid(titulo)) 
                        no-lock no-error.
        if avail hiscampotb
        then tt-plaent.dtvenori = date(hiscampotb.valor_campo). 
     
     end.     
end. 

def var varquivo as char.

if opsys = "UNIX"
then varquivo = "/admcom/relat/diasentreganf." + string(time).
else varquivo = "l:~\relat~\rmetdes." + string(time).

{mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "150"
            &Page-Line = "64"
            &Nom-Rel   = ""PAG4""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """ENTRADAS FILIAL "" + string(vetbcod) 
                        + "" - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" ATE "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "150"
            &Form      = "frame f-cabcab"}

for each tt-plaent where tt-plaent.numero > 0 no-lock
        use-index i2:

    disp tt-plaent.numero   column-label "Numero NF"  format ">>>>>>>>9"
         tt-plaent.serie    column-label "Ser"
         tt-plaent.emite    column-label "Emitente"   format ">>>>>>>>9"
         tt-plaent.fornom   column-label "Razao Social" format "x(40)"
         tt-plaent.ufecod   column-label "UF"
         tt-plaent.dtinclu  column-label "Entrada" format "99/99/99"
         tt-plaent.pladat   column-label "Emisso"  format "99/99/99"
         tt-plaent.dias-e   column-label "Dias!Entrega" format ">>9"
         tt-plaent.dias-p  when tt-plaent.dias-p > 0
            column-label "Dias!Padrao" format ">>9"
         tt-plaent.sit format "x(10)" column-label "Sit"
         tt-plaent.dtvenori column-label "Vencimento"
         tt-plaent.titdtven column-label "Vencimento!Atual"
         tt-plaent.dias-v  when tt-plaent.titdtven <> ?
         format ">>9" column-label "Dias!Vencimento"
         with width 150
         .
         
end.                          

output close.

def var varqexcel as char.
if opsys = "UNIX"
then varqexcel = "/admcom/relat/diasentreganf" + string(time) + ".csv".
else varqexcel = "l:~\relat~\rmetdes.csv" .


output to value(varqexcel).
put "NUMERO;SERIE;EMITENTE;RAZAOSOCIAL;UF;ENTRADA;EMISSAO;DIASENTREGA;DIASPADRAO;SIT
UACAO;VENCIMENTO;DIASVENCIMENTO"
SKIP.

for each tt-plaent where tt-plaent.numero > 0 no-lock:

    PUT  tt-plaent.numero   format ">>>>>>>>9"
         ";"
         tt-plaent.serie    
         ";"
         tt-plaent.emite     format ">>>>>>>>9"
         ";"
         tt-plaent.fornom    format "x(40)"
         ";"
         tt-plaent.ufecod   
         ";"
         tt-plaent.dtinclu   format "99/99/99"
         ";"
         tt-plaent.pladat     format "99/99/99"
         ";"
         tt-plaent.dias-e    format ">>9"
         ";"
         tt-plaent.dias-p   format ">>9"
         ";"
         tt-plaent.sit format "x(10)" 
         ";"
         tt-plaent.titdtven 
         ";"
         tt-plaent.dias-v   format ">>9" 
         SKIP
         .
         
end.  
output close.

message color red/with
    varqexcel
    view-as alert-box title "Arquivo EXCEL"
    .

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
   {mrod.i} .
end.

procedure dias-padrao:
    vdiaspad = 0.
    find first movim where movim.etbcod = plani.etbcod and
                           movim.placod = plani.placod and
                           movim.movtdc = plani.movtdc and
                           movim.movdat = plani.pladat
                           no-lock no-error.
    if avail movim
    then do:    
        find produ where produ.procod = movim.procod
                    no-lock no-error.
        if avail produ
        then do:            
            find first tabaux where
                tabaux.tabela = "DIAS-PADRAO-ENTRADA-NF" AND
                tabaux.nome_campo = string(produ.catcod) 
                no-lock no-error.
            if avail tabaux
            then vdiaspad = int(acha(forne.ufecod,tabaux.valor_campo)).
        end.
    end.    
    if vdiaspad = ? then vdiaspad = 0.        
end procedure.
