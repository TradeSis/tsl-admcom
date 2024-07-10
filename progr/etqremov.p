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
    initial [""," Produtos"," Etiquetas","",""].
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
     " "
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         
                                    
/**
disp "                     PROMOCOES DE REMARCACAO       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
**/
def buffer btbcntgen for tbcntgen.                            
def var i as int.

def temp-table tt-promo
    field etbcod like estab.etbcod
    field vencod as int
    field nome   as char
    field val-venda  as dec
    field val-promo  as dec
    field pct-promo  as dec
    field premiov as dec
    field premiog as dec
    field premiot as dec
    field numero like plani.numero
    field linha as int
    field depto as integer
    index i1 etbcod vencod
    .

def temp-table tt-movim like movim.

def var vdata-teste-promo as date.
def var funcao as char format "x(20)".
def var parametro as char format "x(20)".
input from ./admcom.ini no-echo.
repeat:
    set funcao parametro.
    if funcao = "DATA-TESTE-PROMOCAO"
    then vdata-teste-promo = date(parametro).
end.
input close.

def temp-table tt-promoc like ctpromoc.

def buffer bctpromoc for ctpromoc.
def buffer fctpromoc for ctpromoc.
def buffer ectpromoc for ctpromoc.

def buffer bmovim for movim. 
def buffer bprodu for produ.
 
 
form    skip(1)
        tt-promoc.sequencia   format ">>>>9"
     tt-promoc.descricao[1]      format "x(70)"
     tt-promoc.descricao[2] at 7 format "x(70)"
     with frame esc-promo down no-label
     TITLE " Promocoes de remarcacao ".
     
for each ctpromoc where  
        ctpromoc.promocod = 22 AND
        (if vdata-teste-promo <> ?
                              then ctpromoc.dtinicio <= vdata-teste-promo
                              else ctpromoc.dtinicio <= today) and
         ctpromoc.dtfim  >= today and
         ctpromoc.linha = 0
         no-lock:

    create tt-promoc.
    buffer-copy ctpromoc to tt-promoc.
end. 


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
        &file = tt-promoc  
        &cfield = tt-promoc.descricao[1]
        &ofield = " tt-promoc.sequencia
                    tt-promoc.descricao[2] "  
        &aftfnd1 = " "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " bell.
                        message color red/with
                          ""Nenhum registro encontrado.""
                          view-as alert-box.
                        leave l1.  
                            
                            " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame esc-promo "
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
    if esqcom1[esqpos1] = " Produtos"
    THEN DO on error undo:
        run relatorio.
    END.
    if esqcom1[esqpos1] = " Etiquetas "
    THEN DO:
        run /admcom/progr/etqremov01.p(tt-promoc.sequencia).
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
                &Tit-Rel   = """ PROMOCAO DE REMARCACAO ""  +
                            STRING(tt-promoc.sequencia) " 
                &Width     = "80"
                &Form      = "frame f-cabcab"}


    for each ctpromoc where 
             ctpromoc.sequencia = tt-promoc.sequencia and
             ctpromoc.linha > 0 and
             ctpromoc.procod <> 0
             no-lock:
        
        find first produ where produ.procod = ctpromoc.procod
                    no-lock no-error.
        if not avail produ
        then next.
                
        disp produ.procod
             produ.pronom
             ctpromoc.precosugerido
             with frame f-disp down.
                    
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

