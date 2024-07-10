{admcab.i}
{setbrw.i}
                                                                      
def shared temp-table tt-cli
    field clicod like clien.clicod
    field clinom like clien.clinom
    index iclicod is primary unique clicod.

def temp-table tt-tbcartao like tbcartao
    field marca as char
    index idx99 is primary ct-forenv.

def buffer b-tt-tbcartao for tt-tbcartao.
def var    vm-todos as log no-undo init "no".

def var vdti as date.
def var vdtf as date.

update vdti label "Data inicial" format "99/99/9999"
       vdtf label "Data final" format "99/99/9999"
       with frame ff1 1 down side-label width 80 .
 
hide frame ff1 no-pause.
        
disp "         SOLICITAÇÃO DE NOVOS CARTÕES - " + string(vdti) + " a " +
                string(vdtf) format "x(70)" 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
pause 0. 

for each estab no-lock:
    for each tbcartao where 
             tbcartao.codoper = estab.etbcod and
             tbcartao.dtinclu >= vdti and
             tbcartao.dtinclu <= vdtf and
             tbcartao.situacao = ""
             no-lock:
        create tt-tbcartao.
        buffer-copy tbcartao to tt-tbcartao.
    end.
end.
            
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  RELATORIO","  GERAR ACAO","  MARCAR","  MARCAR TODOS"].
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

def buffer btbcntgen for tbcntgen.                            
def var i as int.
def var vvia as char.
def var vmotivo as char.

form tt-tbcartao.codoper   column-label "Fil"    format ">>9"
     tt-tbcartao.dtinclu   column-label "Data"   format "99/99/99"
     tt-tbcartao.clicod    column-label "Conta"  format ">>>>>>>>>9"
     clien.clinom          column-label "Nome"   format "x(14)"
     vvia                  column-label "Via"    format "x(12)"
     vmotivo               column-label "Motivo" format "x(14)"
     tt-tbcartao.ct-forenv column-label "F. Env" format "x(8)"
     tt-tbcartao.marca     column-label "*"       format "x"
     with frame f-linha5 down width 80 overlay. 

l1: repeat:
    /*
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ? */.
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    disp with frame f1.
    
    PAUSE 0.
 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-tbcartao  
        &cfield = tt-tbcartao.codoper
        &noncharacter = /* 
        &ofield = " tt-tbcartao.dtinclu
                    tt-tbcartao.clicod
                    clien.clinom when avail clien
                    vvia 
                    vmotivo
                    tt-tbcartao.ct-forenv
                    tt-tbcartao.marca
                    "  
        &aftfnd1 = " 
                find clien where 
                        clien.clicod = tt-tbcartao.clicod 
                        no-lock no-error.
                vvia = acha(""Solicita"",tt-tbcartao.campochar[1]).
                vmotivo = acha(""Motivo"",tt-tbcartao.campochar[1]).
                if vvia = ? then vvia = """".
                if vmotivo = ? then vmotivo = """".
                "
        &where  = " "
        &aftselect1 = " 
                        run aftselect.
                        a-seeid = -1.
                       
                        if esqcom1[esqpos1] = ""  gerar acao""
                        then do:
                            leave l1.
                        end.
                        else next l1. "
        &go-on = TAB 
        &naoexiste1 = " bell.
                        message color red/with
                        ""Nenhum registro encontrato""
                         view-as alert-box.
                        leave l1. 
                         " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha5 "
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
    if esqcom1[esqpos1] = "  relatorio"
    THEN DO on error undo:
        run relatorio.
    END.
    if esqcom1[esqpos1] = "  gerar acao"
    THEN DO:
        run gerar-acao.
    END.
    if esqcom1[esqpos1] = "  marcar"
    THEN DO:
        if avail tt-tbcartao then do:
            if tt-tbcartao.marca = "" then do:
                tt-tbcartao.marca = "*".
            end.
            else do on error undo.
                tt-tbcartao.marca = "".
            end.
            
            a-recid = recid(tt-tbcartao).
        end.
        else
            a-recid = -1.
    END.
    if esqcom1[esqpos1] = "  marcar todos"
    THEN DO:
        
        vm-todos = can-find(first b-tt-tbcartao where b-tt-tbcartao.marca = "").
        
        for each b-tt-tbcartao no-lock:
            if vm-todos then do:
                b-tt-tbcartao.marca = "*".
            end.
            else do:
                b-tt-tbcartao.marca = "".
            end.
        end.
                
        a-recid = -1.
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
    def var voutros as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/pedcartaolebes." + string(time).
    else varquivo = "..~\relat~\pedcartaolebes." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """         SOLICITAÇÃO DE NOVOS CARTÕES - "" +
                    string(vdti) + "" a "" + string(vdtf) " 
                &Width     = "80"
                &Form      = "frame f-cabcab"}


    for each tt-tbcartao:
        find clien where clien.clicod = tt-tbcartao.clicod
                        no-lock no-error.
             
        vvia = acha("Solicita",tt-tbcartao.campochar[1]).
        vmotivo = acha("Motivo",tt-tbcartao.campochar[1]).
        voutros = acha("Outros",tt-tbcartao.campochar[1]).

        if vvia = ? then vvia = "".
        if vmotivo = ? then vmotivo = "".
        if voutros = ? then voutros = "".
                         
        disp tt-tbcartao.codoper column-label "Fil"  format ">>9"
             tt-tbcartao.dtinclu column-label "Data" format "99/99/99"
             tt-tbcartao.clicod  column-label "Conta" format ">>>>>>>>>9"
             clien.clinom        column-label "Nome" format "x(20)"
             vvia                column-label "Via"  format "x(15)"
             vmotivo             column-label "Motivo" format "x(20)"
             voutros             no-label format "x(60)"
	     tt-tbcartao.ct-forenv column-label "F. Env." format "x(8)"
             with frame f-linha6 down width 200 overlay. 

    end .

    output close.
        
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

procedure gerar-acao:
    for each tt-tbcartao where tt-tbcartao.marca = "*" no-lock:
        find clien where clien.clicod = tt-tbcartao.clicod
            no-lock no-error.
            
        create tt-cli.
        assign
            tt-cli.clicod = tt-tbcartao.clicod
            tt-cli.clinom = clien.clinom.
    end.
end procedure.
