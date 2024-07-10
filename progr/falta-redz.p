{admcab.i new}

def input parameter vetbi like estab.etbcod.
def input parameter vetbf like estab.etbcod.
def input parameter vdti as date.
def input parameter vdtf as date.

def var vetbcod like estab.etbcod.
/*def var vdti as date.
def var vdtf as date.    */
def var vnrored as int.
def temp-table tt-redz
    field marca as char format "x"
    field etbcod like estab.etbcod 
    field cxacod like mapctb.cxacod
    field nroser as char
    field datmov like mapctb.datmov
    field nrored like mapctb.nrored
    field indinc as log init no format "Sim/Nao"
    field indpla as log init no format "Sim/Nao"
    index i1 etbcod nroser nrored
    index i2 etbcod datmov cxacod indinc
    .

def var vdata as date.
/*
def var vgerar as log format "Sim/Nao".
update vetbcod label "Filial"
        with frame f-1 1 down width 80
        side-label.
if vetbcod <> 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f-1.
end.
else disp "GERAL" @ estab.etbnom with frame f-1.    
update vdti at 1 label "Periodo" format "99/99/9999"
       vdtf no-label format "99/99/9999"
        with frame f-1.

if vdti > vdtf then undo.
*/
vnrored = 0.

do vetbcod = vetbi to vetbf:
for each estab where if vetbcod > 0 then estab.etbcod = vetbcod else true
                no-lock:
    disp "Processando... " estab.etbcod column-label "Filial"
        with frame f-bp 1 down no-box row 10 centered.
        pause 0.
        
    do vdata = vdti to vdtf:
        disp vdata column-label "Data" with frame f-bp.
        pause 0.
        for each mapctb where mapctb.etbcod = estab.etbcod and
                              mapctb.datmov = vdata
                              no-lock.
            create tt-redz.
            assign
                tt-redz.etbcod = estab.etbcod
                tt-redz.cxacod = mapctb.cxacod
                tt-redz.nroser = mapctb.ch1
                tt-redz.datmov = mapctb.datmov 
                tt-redz.nrored = mapctb.nrored
                .

        end.                      
    end.
end.                    
end.
def var vi as int.
def buffer btt-redz for tt-redz.

for each tt-redz break by tt-redz.etbcod
                       by tt-redz.nroser
                       by tt-redz.nrored.
                       
    if first-of(tt-redz.nroser)
    then vnrored = tt-redz.nrored.
    else vnrored = vnrored + 1.
     
    if vnrored < tt-redz.nrored
    then do:
        do vi = vnrored to (tt-redz.nrored - 1):
            create btt-redz.
            assign
                btt-redz.etbcod = tt-redz.etbcod
                btt-redz.cxacod = tt-redz.cxacod
                btt-redz.nroser = tt-redz.nroser
                btt-redz.datmov = tt-redz.datmov - 1
                btt-redz.nrored = vi
                btt-redz.indinc = yes
                .
        end.
        vnrored = tt-redz.nrored .
    end.
    if last-of(tt-redz.nroser)
    then vnrored = 0.
            
end.

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
    initial [""," Marca/Desm","Marca/Desm tudo","  Gera Red Z",""].
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


form " " 
     tt-redz.marca no-label
     " "
     with frame f-linha 11 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
disp "                         " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

for each tt-redz where tt-redz.indinc = yes no-lock:
    find first plani where
               plani.etbcod = tt-redz.etbcod and
               plani.movtdc = 5 and
               plani.pladat = tt-redz.datmov and
               plani.cxacod = tt-redz.cxacod and
               plani.ufemi  = tt-redz.nroser
               no-lock no-error.
    if not avail plani
    then find first plani where
                    plani.etbcod = tt-redz.etbcod and
                    plani.movtdc = 45 and
                    plani.pladat = tt-redz.datmov and
                    plani.cxacod = tt-redz.cxacod and
                    plani.ufemi  = tt-redz.nroser
                    no-lock no-error.
        
    if avail plani 
    then do:
        tt-redz.indpla = yes. 
    end.    
end. 


l1: repeat:
    clear frame f-com1 all.
    clear frame f-com2 all.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-redz  
        &cfield = tt-redz.etbcod
        &noncharacter = /* 
        &ofield = " tt-redz.marca no-label
                    tt-redz.etbcod column-label ""Filial""
                    tt-redz.datmov
                    tt-redz.cxacod
                    tt-redz.nroser format ""x(20)"" column-label ""Serie""
                    tt-redz.nrored
                    tt-redz.indinc column-label ""Falta""
                    tt-redz.indpla column-label ""Venda"" 
                    "  
        &where  = " 
                    tt-redz.indinc = yes use-index i2 "
        &aftselect1 = " run aftselect.
                        if esqcom1[esqpos1] = ""Marca/Desm tudo"" or
                           esqcom2[esqpos2] = """"
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  " 
        &otherkeys1 = " run controle. "
        &locktype = " "
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
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        
    END.
    if esqcom1[esqpos1] = " Marca/Desm"
    THEN DO:
        if tt-redz.marca = "*"
        then tt-redz.marca = "".
        else tt-redz.marca = "*".
        disp tt-redz.marca with frame f-linha.
        pause 0.
    END.
    if esqcom1[esqpos1] = "Marca/Desm tudo"
    THEN DO:
        find first tt-redz where tt-redz.marca = "*" no-error.
        if avail tt-redz
        then
        for each tt-redz:
            tt-redz.marca = "".
        end.    
        else
        for each tt-redz:
            tt-redz.marca = "*".
        end. 
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
                &Tit-Rel   = """TITULO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.


