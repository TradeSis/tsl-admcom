{admcab.i}
{setbrw.i}                                                                      

def input  parameter par-chave     as char.
def output parameter par-ok        as log init yes.

def var vok as log.
def var vi as int.
def var cgc-admcom as char.
def var vserie as char.
def var vnumero as int.

assign cgc-admcom = substring(par-chave,7,14)
       vserie     = string(int(substring(par-chave,23,3)))
       vnumero    = int(substring(par-chave,26,9)).
 
find first forne where forne.forcgc = cgc-admcom no-lock.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["  PRODUTO","","","",""].
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


form    I01_prod.procod format ">>>>>>>>>"  column-label "Cod.Lebes"
        help "<ENTER>Cod.Lebes   <F4>Retorna"
        /*I01_prod.cprod  format "x(17)"      column-label "Cod.Fornecedor"
        */
        I01_prod.Nitem format ">>9" column-Label "Num"
        I01_prod.xprod  format "x(64)" column-label "Descricao"
        with frame f-linha down width 80 row 8 overlay
        title " Itens XML recebimento ".
                                                                         
def buffer btbcntgen for tbcntgen.                            
def var i as int.

def temp-table tt-i01
    field procod like produ.procod
    field profor as char
    index i1 profor.

def buffer bi01_prod for i01_prod.
for each plani where plani.etbcod = setbcod and
                     plani.emite  = forne.forcod and
                     plani.pladat >= today - 360
                     no-lock:
    for each bi01_prod where
             bi01_prod.chave = plani.ufdes no-lock:
        find first tt-i01 where
                   tt-i01.profor = bi01_prod.cprod
                   no-error.
        if not avail tt-i01
        then create tt-i01.
        assign
            tt-i01.procod = bi01_prod.procod 
            tt-i01.profor = bi01_prod.cprod
            .        
    end.         
end.   
for each i01_prod where I01_prod.chave = par-chave :
    if i01_prod.procod = 0
    then do:
        find first tt-i01 where
                   tt-i01.profor = i01_prod.cprod no-error.
        if avail tt-i01
        then i01_prod.procod = tt-i01.procod.           
    end.
end.                
form I01_prod.xprod[1] no-label
    with frame f-desc color message 1 down no-box
    row 21.
l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    color disp  message esqcom1[esqpos1] with frame f-com1.
    pause 0.
    {sklclstb.i  
        &color = with/cyan
        &file = I01_prod  
        &cfield = I01_prod.procod
        &noncharacter = /* 
        &ofield = " I01_prod.NItem
                    I01_prod.xprod 
                   "  
        &aftfnd1 = " "
        &where  = " I01_prod.chave = par-chave "
        &aftselect1 = " 
                        run aftselect.
                        next keys-loop. 
                        
                        "
        &go-on = TAB 
        &naoexiste1 = " message ""Nenhum registo encontrado"".
                        leave l1. " 
        &otherkeys1 = " 
                        run controle. 
                        
                        "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    
    if keyfunction(lastkey) = "end-error"
    then DO:
        vok = yes.
        for each I01_prod where I01_prod.chave = par-chave no-lock:
            if I01_prod.procod = 0
            then do:
                vok = no.
                leave.
            end.
        end.
        if vok = no
        then do:
            sresp = no.
            message "Produto(s) sem codigo Lebes. Deseja sair ? "
            update sresp.
            if not sresp then next l1.
                     else par-ok = no.
        end.

        leave l1.      
         
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.
hide frame f-com1 no-pause.
hide frame f-com2 no-pause.

procedure aftselect:
    def var vant as char.
    def var vi as int.
    def var vok as log.
    if esqcom1[esqpos1] = "  PRODUTO"
    THEN do on error undo with frame f-linha:
         update I01_prod.procod.
         find produ where produ.procod = I01_prod.procod 
                        no-lock no-error.
         if not avail produ
         then do:
             bell.
             message color red/with
             "Produto " input I01_prod.procod "nao cadastrado"
             view-as alert-box.
             undo, retry.
         end. 
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



