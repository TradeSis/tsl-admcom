{admcab.i}
{setbrw.i}                                                                      

def var vdata as date.
def var v-data-salva as date.
def var v-datain as date format "99/99/9999".
def var v-datafi as date format "99/99/9999".
def var vprocod like produ.procod.
def var vpronom like produ.pronom.

form vdata label   "Data Alteracao"
     vprocod label "Produto       "
     vpronom label "Descricao     "
     with frame f-pc centered overlay 1 down side-label
     1 column row 12 color message.

def temp-table tt-hispre like hispre
    field data-inclu as date format "99/99/9999"
    index i1 dtalt descending aux ascending
    index i2 aux
    index i3 procod
    .

def var vcat like produ.catcod init 31.
def var vdias as int init 15 format "zz9".

assign  v-datafi = today - 1
        v-datain = v-datafi 
        vdias = int(v-datafi - v-datain).

disp v-datain label "Data Inicial  " at 3
     v-datafi label "Data Final    " at 3 skip
     /* vdias label "Alteracao de preco nos ultimos "  */
     /*   "dias"  */
        with frame f-dias.
find categoria where categ.catcod = vcat no-lock.

vdias = int(v-datafi - v-datain).

disp vcat at 1 label "Setor" 
     catnom no-label 
        with frame f-dias 1 down
        side-label width 80.
pause 0.

/*if setbcod = 999
then*/ do:
         update 
            v-datain 
            v-datafi  
            with frame f-dias.
          if v-datain > v-datafi
          then do:
             message "Periodo Invalido" view-as alert-box.
             undo, retry .
          end. 
          if v-datafi >= today 
          then do:
              message "Data Final deve ser inferior a Data do Dia" 
              view-as alert-box.
              undo, retry .
          end. 
          vdias = int(v-datafi - v-datain).
          /* disp vdias  with frame f-dias. */
          update  vcat 
              with frame f-dias.
end.
if vdias > 15 and setbcod <> 999
then do:
            message "Periodo superior a 15 dias" view-as alert-box.
            undo, retry .
end.

find categoria where categ.catcod = vcat no-lock.

disp    /* vdias */
        vcat 
        catnom no-label 
        with frame f-dias.
        pause 0.

for each hispre where
         hispre.dtalt >= 12/01/2008 and
         hispre.dtalt >= (v-datafi - vdias) no-lock:
    if hispre.estvenda-ant = hispre.estvenda-nov and
       hispre.estpromo-ant = hispre.estpromo-nov 
    then next.
    find produ where produ.procod = hispre.procod 
        no-lock no-error.
    if vcat > 0 and produ.catcod <> vcat
    then next.
    if avail produ
    then do:    
        create tt-hispre.
        buffer-copy hispre to tt-hispre.
        tt-hispre.aux = produ.pronom.
        tt-hispre.data-inclu = hispre.dtalt.
    end.
end.            

for each produ where produ.catcod = vcat no-lock:
    find first estoq where estoq.etbcod = setbcod and
                     estoq.procod = produ.procod 
                     no-lock no-error.
    if not avail estoq or
       estoq.estproper <= 0
    then next.
    
    if estoq.estprodat = ? or
       estoq.estprodat < v-datafi
    then next.   
                     
                     
        find first tt-hispre use-index i3
                where tt-hispre.procod = produ.procod 
                    no-lock no-error.
        
        /* antonio */
        if not avail tt-hispre then next.
        /**/
        
        /******* 
        assign v-data-salva = ?. 
        if avail tt-hispre
        then do: 
            assign v-data-salva = tt-hispre.data-inclu.
            delete tt-hispre.    
        end.
        create tt-hispre. 
        assign
            tt-hispre.procod = produ.procod
            tt-hispre.aux    = produ.pronom
            tt-hispre.estvenda-ant = estoq.estvenda
            tt-hispre.estvenda-nov = estoq.estproper
            tt-hispre.funcod = - 1
            tt-hispre.data-inclu = v-data-salva.
        ********/    
            tt-hispre.dtalt = estoq.estprodat.
end.                     
def var vtp as char.
form tt-hispre.procod column-label "Codigo"
     tt-hispre.aux    column-label "Descricao"  format "x(33)"
     tt-hispre.data-inclu column-label "Dt.Inicio"
     tt-hispre.dtalt      column-label "Dt.Promocao"
     tt-hispre.estvenda-ant  column-label "Preco!Ates"
     tt-hispre.estvenda-nov  column-label "Preco!Atual"
     vtp  format "x(10)" no-label 
     /*tt-hispre.estpromo-nov  column-label "Preco!Promocao"*/
     with frame f-linha down color with/cyan 
     width 100
     .


def var vtitrel as char.
                                                                               
vtitrel = " PRODUTOS COM PRECO ALTERADO ".

run relatorio.

procedure relatorio:

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = "vtitrel" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    disp with frame f-dias.
    
    for each tt-hispre where
              (if vdata <> ?
               then tt-hispre.dtalt = vdata else true) and
              (if vprocod > 0
               then tt-hispre.procod = vprocod else true) and
              (if vpronom <> ""
               then tt-hispre.aux begins vpronom else true) 
            use-index i2 no-lock:
        vtp = "".
        if tt-hispre.funcod = - 1
        then vtp = "Promocao".
     
        disp tt-hispre.aux
             tt-hispre.data-inclu
             tt-hispre.dtalt when tt-hispre.dtalt >  tt-hispre.data-inclu
             tt-hispre.procod
             tt-hispre.aux
             tt-hispre.estvenda-ant
             tt-hispre.estvenda-nov 
             vtp
             with frame f-linha.
        down with frame f-linha.
    end.
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.
