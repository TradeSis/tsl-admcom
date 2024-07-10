{admcab.i}
{setbrw.i}                                                                      

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [""," Procura ","","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var vdata as date.
def var vprocod like produ.procod.
def var vpronom like produ.pronom.

form vdata label   "Data Alteracao"
     vprocod label "Produto       "
     vpronom label "Descricao     "
     with frame f-pc centered overlay 1 down side-label
     1 column row 12 color message.

def temp-table tt-hispre like hispre
    index i1 dtalt descending aux ascending
    index i2 aux
    index i3 procod
    .

def var vcat like produ.catcod init 31.
def var vdias as int init 10.
disp vdias label "Alteracao de preco nos ultimos "
        "dias"
        with frame f-dias.
find categoria where categ.catcod = vcat no-lock.

disp vcat at 1 label "Setor" 
     catnom no-label 
        with frame f-dias 1 down
        side-label width 80.
pause 0. 
if setbcod = 999
then do:
    update vdias 
        with frame f-dias.
    update  vcat 
        with frame f-dias.
end.
disp vdias  with frame f-dias.
find categoria where categ.catcod = vcat no-lock.

disp vcat 
     catnom no-label 
        with frame f-dias.
pause 0. 
for each hispre where
         hispre.dtalt >= 12/01/2008 and
         hispre.dtalt >= today - vdias no-lock:
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
       estoq.estprodat < today
    then next.   
                     
                     
        find first tt-hispre use-index i3
                where tt-hispre.procod = produ.procod 
                    no-lock no-error.
        if avail tt-hispre
        then delete tt-hispre.
        create tt-hispre.
        assign
            tt-hispre.procod = produ.procod
            tt-hispre.aux    = produ.pronom
            tt-hispre.estvenda-ant = estoq.estvenda
            tt-hispre.estvenda-nov = estoq.estproper
            tt-hispre.funcod = - 1
            tt-hispre.dtalt = estoq.estprodat.
end.                     
def var vtp as char.
form tt-hispre.procod column-label "Codigo"
     tt-hispre.aux    column-label "Descricao"  format "x(33)"
     tt-hispre.dtalt  column-label "Data"
     tt-hispre.estvenda-ant  column-label "Preco!Ates"
     tt-hispre.estvenda-nov  column-label "Preco!Atual"
     vtp  format "x" column-label "St"
     /*tt-hispre.estpromo-nov  column-label "Preco!Promocao"*/
     with frame f-linha 10 down color with/cyan 
     .
                                                                                
disp "        PRODUTOS COM PRECO ALTERADO NOS ULTIMOS "
        +  STRING(VDIAS) + " DIAS DO SETOR "  + string(vcat)  FORMAT "X(80)"
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " Coluna ST : P = Preco promocao " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-hispre  
        &cfield = tt-hispre.aux
        &noncharacter = /* */
        &ofield = " tt-hispre.dtalt
                    tt-hispre.procod
                    tt-hispre.aux
                    tt-hispre.estvenda-ant
                    tt-hispre.estvenda-nov 
                    vtp
                    /*tt-hispre.estpromo-nov
                        when tt-hispre.estpromo-nov > 0*/
                    "  
        &aftfnd1 = "
            vtp = "" "".
            if tt-hispre.funcod = - 1
            then vtp = ""P"".
            "
        &where  = " 
              (if vdata <> ?
               then tt-hispre.dtalt = vdata else true) and
              (if vprocod > 0
               then tt-hispre.procod = vprocod else true) and
              (if vpronom <> "" ""
               then tt-hispre.aux begins vpronom else true) 
        use-index i2 "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  bell.
                    message color red/with
                    ""Nenhum registro encontrado.""
                    view-as alert-box.
                    vdata = ? . vprocod = 0. vpronom = "" "".
                    next keys-loop.
                    " 
        &otherkeys1 = " run controle. "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = " Procura"
    THEN DO on error undo:
        vdata = ?.
        vprocod = 0.
        vpronom = "".
        update vdata
               vprocod
               with frame f-pc.
        if vprocod = 0
        then update vpronom with frame f-pc.
        hide frame f-pc.
        
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
    
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
    END.
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:
    
    END.

end procedure.

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
end procedure.

