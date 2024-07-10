/*


*/

{admcab.i}

{setbrw.i}
def var primeiro as log.
def var vprocod as char format "x(12)" label "Codigo Produto".
def buffer xprodu for produ.
pause 0.
disp 
string("") format "x(80)"
skip(19)

    with frame capa
    row 2
    color messages
    overlay
    no-box.
    
def var vpesquisa as char format "x(58)".
def var oldpesquisa as char.
def var vletra as char.
def var par-ultimofiltro    as char.
def var par-catcod  like produ.catcod.
def var par-mix     like estab.etbcod init 0.    
def var par-situacao    as char.
def var par-pe          as char.
def var par-vex         as char.

def var fil-campo as char.
def var fil-mensagem as char.

def var fil-contador as int.

def var vprosit as log format "SIM/NAO". 
def var vpe     as log format "SIM/NAO".
def var vvex    as log format "SIM/NAO".
def var vmix    as log format "SIM/NAO".
def var vloop   as int.
def var par-fabcod  like fabri.fabcod.
def var vpreco      like precohrg.prvenda.
def var vestoq      like estoq.estatual.

def temp-table ttprodu no-undo
    field procod    like produ.procod
    field pronom    like produ.pronom
    field indicegenerico    like produ.indicegenerico
    index procod is unique primary pronom asc procod asc.


def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    initial ["<Seleciona>","<Opcoes>","", "",""].

    pause 0.
    disp fil-campo format "x(77)"
            with frame fcab row 18 no-box no-labels centered 
            width 78 overlay.
    disp fil-mensagem format "x(77)"
            with frame fcabmensagem row 19 no-box no-labels centered 
            width 78 overlay.
            
form
    esqcom1
    with frame f-com1 row 20 no-box no-labels column 1 centered
    overlay.

assign
    esqpos1  = 1.

    form 
            produ.procod format ">>>>>>>9"
            produ.pronom column-label "Descricao"  format "x(49)"
            vpreco          format ">>>>9.99" column-label "Preco"
            vestoq          format "->>>>9" column-label "Estoq"
        with frame frame-a 9 down centered  row 5 no-box no-underline
        overlay.

    pause 0.
    disp esqcom1 with frame f-com1.
    
    form with frame f-linha.

run seleciona-categoria (input 31, output par-catcod ).
run seleciona-situacao  (input "ATIVO",output par-situacao).
run seleciona-pe        (input "",output par-pe).
run seleciona-vex       (input "",output par-vex).

par-mix = if setbcod = 999
          then 0
          else setbcod.
/*
run seleciona-mix       (input "NAO",output par-mix).
*/


run gera-filtro.
recatu1 = ?.
form 
vpesquisa format "x(68)" label "Pesquisa"
                            with frame fcampo
                row 3 side-labels no-box overlay centered.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.

    if recatu1 = ?
    then run leitura (input "pri").
    else find ttprodu where recid(ttprodu) = recatu1 no-lock.
    if not available ttprodu
    then do.

        hide message no-pause.
        message "Nenhum registro Encontrado neste Filtro " 
        replace(replace(fil-campo,"&"," "),"#","=")
 view-as alert-box.
        pause 2 no-message.
        fil-campo = par-ultimofiltro.
        run montatt (par-ultimofiltro).

        recatu1 = ?.
        next.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttprodu).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttprodu
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttprodu where recid(ttprodu) = recatu1 no-lock.
        find produ where produ.procod = ttprodu.procod no-lock.
        
        disp replace(replace(fil-campo,"&"," "),"#","=")
            @ fil-campo
            with frame fcab. 

        
        vprosit = produ.proseq = 0.
        vvex    = produ.ind_vex.
        vpe     = produ.proipival = 1.
        vmix    = no.
        do vloop = 1 to num-entries(produ.indicegenerico,"|"):
            if entry(vloop,produ.indicegenerico,"|") = "MIX#" + string(setbcod)
            then vmix = yes.
        end.
        find categoria of produ no-lock.
        disp
           categoria.catnom format "x(20)" label "CATEGORIA" colon 10 
           vprosit colon 38 label "ATIVO" 
                       vmix colon 58 label "MIX"    

            vpe colon 10 label "PE"
           vvex colon 38 label "VEX"
                with frame 
                    fdet
                    row 16
                    no-box
                    centered 
                    color messages
                    width 78
                    side-labels 
                    overlay.
        if esqcom1[3] = ""
        then status default 
            "Digite o nome do produto".
        else status default 
            "Digite o nome do produto, use * para partes do nome e <Filtrar>".
            

        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        
            pause 0.
            disp vpesquisa 
                            with frame fcampo.

            color disp input vpesquisa with frame fcampo.

        choose field produ.pronom
                help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right F7 PF7
                       1 2 3 4 5 6 7 8 9 0 " " "*"
                      page-down   page-up 
                      PF4 F4 ESC return   del-char backspace DELETE-CHARACTER
                      CUT F10 PF10
                      a b c d e f g h i j k l m n o p q r s t u v x z w y 
                      A B C D E F G H I J K L M N O P Q R S T U V X Z W Y
                      "." "/").
                      
        run color-normal.
        pause 0. 

            vletra = keyfunction(lastkey).
            if length(vletra) = 1 or
               keyfunction(lastkey) = "BACKSPACE" or
               keyfunction(lastkey) = "DELETE-CHARACTER" 
            then do:
                if keyfunction(lastkey) = "backspace" or 
                   keyfunction(lastkey) = "DELETE-CHARACTER"
                then do:
                    vpesquisa = substring(vpesquisa,1,length(vpesquisa) - 1).
                    if vpesquisa = ""
                    then do:
                        esqcom1[3] = "". 
                    end.
                    run campo.
                    leave.
                end.
                if vpesquisa = "" and
                   (vletra >= "0" and vletra <= "9") 
                then do
                    with frame fbusca
                        
                        row 4
                        color messages
                        overlay
                        side-labels 
                        width 40
                        title "Digite todo o Codigo do produto":
                    vprocod = (vletra).
                    primeiro = yes.
                    update vprocod  
                    editing: 
                        if  primeiro 
                        then do: 
                            apply  keycode("cursor-right"). 
                            primeiro = no. 
                        end. 
                        readkey. 
                        apply lastkey. 
                    end.
                    find xprodu where xprodu.procod = int(vprocod) no-lock no-error.
                    if not avail xprodu
                    then do:
                        message "Produto" vprocod "Nao cadastrado"
                            view-as alert-box.
                    end.
                    else do:
                        find first ttprodu where 
                            ttprodu.procod = xprodu.procod
                            no-lock no-error.
                        if not avail ttprodu
                        then do:
                            message "Produto" vprocod xprodu.pronom
                             "Nao Disponivel na Atual Selecao"
                             view-as alert-box.
                        end.    
                        else do:
                            recatu1 = recid(ttprodu).
                        end.
                    end.
                    hide frame fbusca no-pause.
                    leave.
                end.
                else   
                if (vletra >= "a" and vletra <= "z") or
                   (vletra >= "0" and vletra <= "9") or
                    vletra = " "   or
                    vletra = "."   or
                    vletra = "/"  or
                    vletra = "*"
                then do:         
                    
                    vpesquisa = vpesquisa + vletra.
                    
                    if vletra = " "
                    then do:
                        esqcom1[3] = "< Filtrar >". 
                    end.
                    
                    run campo.
                    leave.
                end.
                /**
                else do:
                    vpesquisa = "".
                end.
                **/
            end.
            /*
            else vpesquisa = "".
            */
            pause 0.
            disp vpesquisa with frame fcampo.
                                                         
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttprodu
                    then leave.
                    recatu1 = recid(ttprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttprodu
                    then leave.
                    recatu1 = recid(ttprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttprodu
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttprodu
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        
        
        if keyfunction(lastkey) = "return"
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = "<seleciona>"
            then do:
                frame-value = string(ttprodu.procod).
                leave bl-princ.
            end.
            if esqcom1[esqpos1] = "<Opcoes>"
            then do:
                vpesquisa = "".
                disp vpesquisa with frame fcampo.
                esqcom1[3] = "".
                color disp normal esqcom1[2] esqcom1[3] with frame f-com1.
                esqpos1 = 1.                   
                run busca.
                run gera-filtro.
                recatu1=?.
                leave.
            end. 
            
            if esqcom1[esqpos1] = "< Filtrar >"  
            then do:
                    
                        run gera-filtro.
                        esqcom1[4] = "<Desfiltrar>" .
                        recatu1 = ?.
                        leave.
            end.
            if esqcom1[esqpos1] = "<Desfiltrar>"  
            then do:
                        oldpesquisa = entry(1,vpesquisa," ") + " ".
                        vpesquisa = "".
                        run gera-filtro.
                        vpesquisa = oldpesquisa.
                        run leitura ("busca").
                        esqcom1[4] = "" .
/*                        color disp normal esqcom1[3] with frame f-com1.*/
                        recatu1 = recid(ttprodu).
                        leave.
            end.
            
            if esqcom1[esqpos1] = "Exclui Cliente"
            then do:
                recatu1 = ?.
                leave.
            end.
        end.
        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttprodu).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame ftipobusca no-pause.
 hide frame fmessage no-pause.
 hide frame fbusca no-pause.
 hide frame fdet no-pause.
 hide frame fcampo no-pause.
 hide frame f-linha no-pause.
 hide frame fcab no-pause.
 hide frame fcabmensagem no-pause.
 hide frame capa no-pause.

procedure frame-a.
    find produ where produ.procod = ttprodu.procod no-lock.
    find estoq where estoq.etbcod = setbcod and
                     estoq.procod = produ.procod
                     no-lock no-error.
    vpreco = if avail estoq
             then estoq.estvenda
             else 0.
    vestoq = if avail estoq
             then estoq.estatual
             else 0.

    disp 
            produ.procod
            produ.pronom
            vpreco    
            vestoq      
        with frame frame-a.
end procedure.

procedure color-message.
    color display message
            produ.procod
            produ.pronom
            vpreco    
            vestoq      

        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
            produ.procod
            produ.pronom
            vpreco    
            vestoq      

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

if par-tipo = "busca"
then do: 
    find first ttprodu where
            ttprodu.pronom begins vpesquisa
            no-lock no-error.

end.        
if par-tipo = "pri" 
then do:
    /*
    if par-loja
    then do:
        find first ttprodu  where ttprodu.etbcod = setbcod
                no-lock no-error.
    end.
    else do:
    */
        find first ttprodu where
            true
            no-lock no-error.
            
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    do:
        find next ttprodu where
            true
            no-lock no-error.
    end.        
end.    
             
if par-tipo = "up" 
then do:

    do:
        find prev ttprodu where
            true
            no-lock no-error.
    end.        

end.    
        
end procedure.

procedure seleciona-situacao.
    def input param par-opcao as char.
    def output param par-situacao as char.

    def var csituacao as char extent 3 init [ "  Todos",
                                              "  Ativo ",
                                              " Inativo "  ].
    
    if par-opcao = ?
    then do:
        disp csituacao
            with frame fsituacao
            row 10 centered
            overlay no-labels.
        choose field csituacao
                with frame fsituacao.
        par-situacao = trim(csituacao[frame-index]).        
        if par-situacao = "todos"
        then par-situacao = "".
    end.            
    else par-situacao = par-opcao.

end procedure.

procedure seleciona-pe.
    def input param par-opcao as char.
    def output param par-pe as char.

    def var cpe as char extent 3 init [ " Todos",
                                        "  Sim ", 
                                         " Nao "  ].
    
    if par-opcao = ?
    then do:
        disp cpe
            with frame fpe
            row 12 centered
            overlay no-labels.
        choose field cpe
                with frame fpe.
        par-pe = trim(cpe[frame-index]).        
        if par-pe = "todos"
        then par-pe = "".
    end.
    else par-pe = par-opcao.

end procedure.

procedure seleciona-vex.
    def input param par-opcao as char.
    def output param par-vex as char.
    def var cvex as char extent 3 init [ " Todos",
                                        "  Sim ", 
                                         " Nao "  ].
    
    if par-opcao = ?
    then do:
        disp cvex
            with frame fvex
            row 11 centered
            overlay no-labels.
        choose field cvex
                with frame fvex.
        par-vex = trim(cvex[frame-index]).        
        if par-vex = "todos"
        then par-vex = "".
    end.
    else par-vex = par-opcao.

end procedure.


procedure seleciona-mix.
    def input param par-opcao as char.
    def output param par-mix as int.
    
    if par-opcao = ?
    then message "Qual FILIAL de MIX?" update par-mix.
    else par-mix = 0.

end procedure.



procedure seleciona-categoria.

    {setbrw.i}

    def input  parameter par-catdefault as int. 
    def output parameter par-categoria like categoria.catcod.

    if par-catdefault <> 0
    then do:
        par-categoria = par-catdefault.
        return.
    end.


    hide frame f-linha no-pause.    
    clear frame f-linha all.
    assign a-seerec = ?.
    assign a-seeid  = -1  
           a-recid  = -1 .

    {sklcls.i
        &color  = withe
        &color1 = brown
        &file   = categoria 
        &noncharacter = /* 
        &cfield = categoria.catnom
        &ofield = categoria.catcod
        &where  = " true "
        &form = " frame f-linha 10 down centered no-label overlay
                     title "" CATEGORIA DE PRODUTO "" 
                        row 9
                        " }.
                    
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame f-linha no-pause.
        leave.
    end.                    
       
    find categoria where recid(categoria) = a-seerec[frame-line(f-linha)] no-lock                                                         no-error.
    
    par-categoria = if avail categoria
                 then categoria.catcod
                 else 0.
       hide frame f-linha no-pause.
end procedure. 


procedure gera-filtro.
    
    fil-campo = "".
    if vpesquisa <> ""
    then do:
        fil-campo = "PRONOM#" + (if substring(vpesquisa,1,1) = " " 
                                 then "*"
                                 else "")
                                    + vpesquisa.
    end.
    if par-situacao <> ""
    then do:
        fil-campo = fil-campo +
                    (if fil-campo <> "" then "&" else "") +
                    ("SITUACAO#" + par-situacao).
    end.
    if par-catcod <> 0
    then do:
        fil-campo = fil-campo +
                    (if fil-campo <> "" then "&" else "") +
                    (
                     "CATEGORIA#" + string(par-catcod)
                    ).
    end.    
    if par-pe <> ""
    then do:
        fil-campo = fil-campo +
                    (if fil-campo <> "" then "&" else "") +
                    (
                    "PE#" + par-pe
                    ).
    end.
    if par-vex <> ""
    then do:
        fil-campo = fil-campo +
                    (if fil-campo <> "" then "&" else "") +
                    (
                    "VEX#" + par-vex
                    ).
    end.
    
    if par-mix <> 0
    then do:
        fil-campo = fil-campo +
                    (if fil-campo <> "" then "&" else "") +
                    (
                    "MIX#" + string(par-mix)
                    ).
                    
    end.     
    pause 0.
    disp fil-campo 
            with frame fcab .

    run montatt (fil-campo).
    
    if fil-contador <> 0
    then do:
        par-ultimofiltro = fil-campo.
    end.
    /*
    else do:
        if par-catcod <> 0
        then do:
            if vpesquisa <> ""
            then do:
                fil-campo = par-ultimofiltro.
                run montatt (fil-campo).         
            end.
            else do:
                fil-campo = 
                         "CATEGORIA#" + string(par-catcod).
                run montatt (fil-campo).         
                         
            end.
        end.    
    end.
    */
    
end procedure.

procedure montatt.
    def input parameter par-campo as char.
    
    def var fil-time as int.

    for each ttprodu.
        delete ttprodu.
    end.
    fil-contador = 0.
    fil-time     = time.
    for each produ where produ.indicegenerico contains par-campo
            no-lock.
        create ttprodu.
        ttprodu.procod = produ.procod.
        ttprodu.indicegenerico = produ.indicegenerico.
        ttprodu.pronom = produ.pronom.
        fil-contador = fil-contador + 1.
        if fil-contador = 10 or fil-contador mod 500 =0
        then do:
            hide message no-pause.
            fil-mensagem = "Filtrados " 
                           + string(fil-contador) +  
            " Produtos em " + string(time - fil-time,"HH:MM:SS").
            pause 0.
            disp fil-mensagem with frame fcabmensagem.
        end.
    end.    
    hide message no-pause.
    fil-mensagem = 
    "Filtrados " + string(fil-contador ) + 
    " Produtos em " + string(time - fil-time,"HH:MM:SS").
    disp fil-mensagem with frame fcabmensagem.
end procedure.


procedure campo.
                    
                    pause 0.
                    disp vpesquisa with frame fcampo.
                    run leitura ("BUSCA").
                    if avail ttprodu
                    then recatu1 = recid(ttprodu).

end procedure.


procedure busca.  

        def var vtipobusca as char format "x(55)" extent  8
            init    [ "1-Categoria",
                      /*"2-Por Fabricante" ,
                      "3-Referencia ",
                      "4-Setor/Grupo/Classe/Sub-Classe",  
                      */
                      "2-Situacao", 
                      "3-Vex",
                      "4-Pedido Especial",
                      "5-Mix",
                      "" ].

        def var vfiltro as char.
        def var rectit as recid.
        def var recag as recid.
        pause 0.
        display " O P C O E S " at 16
                skip(10)
                with frame fmessage color message row 7 column 11 
                    width 64 no-box overlay.
        pause 0.
        display vtipobusca at 4
                with frame ftipobusca  column 13
                row 8  no-label overlay  1 column.
        choose field vtipobusca auto-return
                     with frame ftipobusca.
        vfiltro = entry(2,vtipobusca[frame-index],"-").

        
        if vfiltro = "Categoria"
        then run seleciona-categoria (0,output par-catcod).
        if vfiltro = "mix"
        then run seleciona-mix (?,output par-mix).
        if vfiltro = "Situacao"
        then run seleciona-situacao (?,output par-situacao).
        if vfiltro = "Pedido especial"
        then run seleciona-pe (?,output par-pe).
        if vfiltro = "VEX"
        then run seleciona-vex (?,output par-vex).
        
        hide frame ftipobusca no-pause.
        hide frame fmessage no-pause.
         
        

        /**
        recag = ?.
        rectit = ?.
        
        if vescolha = "carac"
        then do:
            sretorno = "".
            run producar.p.
            find first produpai where produpai.itecod = int(sretorno)
                                no-error.
            if avail produpai
            then do:
                find first produ where produ.itecod = produpai.itecod no-error.
                if avail produ
                then do:
                    recatu1 = recid(produ).
                    vgeral = yes. 
                    leave.
                end.
            end.
            else do:
                find first produ where produ.procod = int(sretorno) no-error.
                if avail produ
                then do:
                    recatu1 = recid(produ).
                    vgeral = yes. 
                    leave.
                end.
            end.
        end.        
        if vescolha = "clase"
        then do:
            def var vclacod like clase.clacod.
            def buffer bclase for clase.
            run busclase.p (output vclacod).
            clear frame frame-a all no-pause.
            i = 0.
            for each bprodu where bprodu.clacod = vclacod no-lock.
                i = i + 1.
            end.
            if i = 0
            then do:
                message "Nenhum Produto desta Classe".
                pause 3 no-message.
                vgeral = yes.
            end.    
            else do:
                for each wfprodu.
                    delete wfprodu.
                end.    
                for each bprodu where bprodu.clacod = vclacod no-lock.
                    create wfprodu.
                    assign wfprodu.recag = recid(bprodu)
                           wfprodu.pronom  = bprodu.pronom.
                end.
                find bclase where bclase.clacod = vclacod no-lock.
                vtitle = bcategoria.catnom + " " +   "Busca Classe - " + caps(bclase.clanom).
                hide frame frame-a no-pause.
                recatu1 = ?.
                vgeral = no.
                leave.
            end.
        end.
        if vescolha = "fonetica"
        then do:
            ffabcod =  par-fabcod.
            update "Fabricante" ffabcod    
         help "Digite o Fabricante , ZERO para geral"
                    with frame fbusca.
            if ffabcod <> 0
            then do:
                find ffabri where ffabri.fabcod = ffabcod no-lock
                                    no-error.
                if not avail ffabri 
                then ffabcod = 0.
                else
                    display ffabri.fabnom
                            with frame fbusca.
            end.
            vpalavra = "".
            update "Digite uma Palara para filtrar " skip
            vpalavra format "x(77)"
                   with frame fbusca
                    title " USE * quando nao souber nome completo "
                            centered row 10 overlay 
                                     no-label   
                                            width 80.
            vpalavra = "PRONOM#" + vpalavra.
            message vpalavra.

            i = 0.
            for each bprodu where bprodu.indicegenerico CONTAINS vpalavra no-lock.
                if ffabcod <> 0 and bprodu.fabcod <> ffabcod
                then next.
                i = i + 1.
            end.
            if i = 0
            then do:
                message "Nenhum Produto contendo este Nome".
                pause 3 no-message.
                vgeral = yes.
            end.    
            else do:
                for each wfprodu.                                   
                    delete wfprodu.
                end.    
                for each bprodu where bprodu.indicegenerico CONTAINS vpalavra no-lock.
                    if ffabcod <> 0 and bprodu.fabcod <> ffabcod
                    then next.
                    create wfprodu.
                    assign wfprodu.recag = recid(bprodu)
                           wfprodu.pronom  = bprodu.pronom.
                end.
                vtitle = "Busca Fonetica - " + caps(vpalavra) + 
                            "  -  Fab.: " +
                            (if ffabcod <> 0
                             then ffabri.fabnom
                             else "") .
                hide frame frame-a no-pause.
                recatu1 = ?.
                vgeral = no.
                leave.
            end.
        end.
        
        if vescolha = "fabri"
        then do:
        /*
            def buffer bfabri for fabri.
        {setbrw.i}
        */

            assign a-seeid  = -1 a-recid  = -1  a-seerec = ?.

            {sklcls.i
                &file         = fabri
                &help         =  "ENTER=Produtos do Fabricante   F4=Retorna"
                &cfield       = fabri.fabnom
                &ofield       = " 
                             fabri.fabcod
                             fabri.fabfant
                             fabri.fabdtcad
                            " 
                &where        = "true"
                &color        = withe
                &color1       = red
                &locktype     = " use-index ifabnom " 
                &aftselect1   = "  
                                  par-fabcod = fabri.fabcod.
                                  leave keys-loop. " 
                &naoexiste1   = " bell. bell.
                                message color red/withe
                                ""Nenhum Fabricante Cadastrado""
                                view-as alert-box title """" .
                                leave. "
                &form         = " frame f-linha1 row 4 down centered
                                  title "" FABRICANTES "" overlay
                                  color with/cyan " } 
            i = 0.
            for each bprodu where bprodu.fabcod = par-fabcod no-lock.
                i = i + 1.
            end.
            if i = 0
            then do:
                message "Nenhum Produto deste Fabricante ".
                pause 3 no-message.
                vgeral = yes.
            end.    
            else do:
                for each wfprodu.
                    delete wfprodu.
                end.    
                for each bprodu where bprodu.fabcod = par-fabcod no-lock.
                    create wfprodu.
                    assign wfprodu.recag = recid(bprodu)
                           wfprodu.pronom  = bprodu.pronom.
                end.
                find bfabri where bfabri.fabcod = par-fabcod no-lock.
                vtitle = bcategoria.catnom + " " +   "Busca Fabricante - " + caps(bfabri.fabnom).
                hide frame frame-a no-pause.
                recatu1 = ?.
                vgeral = no.
                leave.
            end.
 
        
        end.
        
        if vescolha = "refer"
        then do:

            hide frame f-linha1 no-pause. 
            def var par-refer   like produ.prorefter.
            update par-refer
                    with frame fzoorefer
                            row 10 overlay color message
                                        side-label.
            i = 0.
            for each bprodu where 
                               bprodu.prorefter   = par-refer
                                        no-lock.
                i = i + 1.                  
            end.
            if i = 0
            then do:
                message "Nenhum Produto nesta Referencia".
                pause 3 no-message.
                vgeral = yes.
            end.    
            else do:
                for each wfprodu.
                    delete wfprodu.
                end.    
                for each bprodu where 
                                      bprodu.prorefter  = par-refer
                                        no-lock.
                    create wfprodu.
                    assign wfprodu.recag = recid(bprodu)
                           wfprodu.pronom  = bprodu.pronom.
                end.
                vtitle = bcategoria.catnom + " " +
                                    " Referencia " + par-refer + "".
                hide frame frame-a no-pause.
                recatu1 = ?.
                vgeral = no.
                leave.
            end.
 
        
        end.
        
        if vescolha = "estoq"
        then do:
            /***
            hide frame f-linha1 no-pause. 
            do:
                for each wfprodu.
                    delete wfprodu.
                end.    
                hide message no-pause.
                message "Filtrando Estoque.....Aguarde....".
                vcont = 0.
                for each estoq where estoq.tipo = "+" and
                                estoq.etbcod = setbcod
                                        no-lock.
                    find bprodu of estoq no-lock.
                    find wfprodu where wfprodu.recag = recid(bprodu)
                                            no-error.
                    if avail wfprodu then next.  
                    if bprodu.catcod <> bcategoria.catcod
                    then next.
                    find wfprodu where wfprodu.recag = recid(bprodu)
                                            no-error.
                    if not avail wfprodu
                    then create wfprodu.
                    assign wfprodu.recag = recid(bprodu)
                           wfprodu.pronom  = bprodu.pronom. 
                    vcont = vcont + 1.
                    if vcont mod 10 = 0
                    then do.
                        display "Selecionando" vcont
                                with frame fffff row 22
                                        no-box no-label
                                                    color message.
                        pause 0.
                    end.                    
                end.
                vtitle = bcategoria.catnom + " " +
                                    " Referencia " + par-refer + "".
                hide frame frame-a no-pause.
                recatu1 = ?.
                vgeral = no.
                esqascend = yes.
                leave.
            end.
            **/
        
        end.

/***/
        if vescolha = "fabriestoq"
        then do:
            assign a-seeid  = -1 a-recid  = -1  a-seerec = ?.

            {sklcls.i
                &file         = fabri
                &help         =  "ENTER=Produtos do Fabricante   F4=Retorna"
                &cfield       = fabri.fabnom
                &ofield       = " 
                             fabri.fabcod
                             fabri.fabfant
                             fabri.fabdtcad
                            " 
                &where        = "true"
                &color        = withe
                &color1       = red
                &locktype     = " use-index ifabnom " 
                &aftselect1   = "  
                                  par-fabcod = fabri.fabcod.
                                  leave keys-loop. " 
                &naoexiste1   = " bell. bell.
                                message color red/withe
                                ""Nenhum Fabricante Cadastrado""
                                view-as alert-box title """" .
                                leave. "
                &form         = " frame f-linha1 row 4 down centered
                                  title "" FABRICANTES "" overlay
                                  color with/cyan " } 
            
            /**
            hide message no-pause.
            message "Filtrando Estoque por Fabricante.....Aguarde....".
            i = 0.
            for each bprodu where bprodu.fabcod = par-fabcod no-lock.
                i = i + 1.
            end.
            if i = 0
            then do:
                message "Nenhum Produto deste Fabricante ".
                pause 3 no-message.
                vgeral = yes.
            end.    
            else do:
                for each wfprodu.
                    delete wfprodu.
                end.    

                hide message no-pause.
                message "Filtrando Estoque por Fabricante.....Aguarde....".
                vcont = 0.
                
                for each bprodu where bprodu.fabcod = par-fabcod no-lock.
                    if bprodu.catcod <> bcategoria.catcod
                    then next.
                    for each estoq where estoq.tipo = "+"
                                     and estoq.procod = bprodu.procod
                                     and estoq.etbcod = setbcod
                                        no-lock.
                        find first wfprodu where wfprodu.recag = recid(bprodu)
                            no-error.
                        if not avail wfprodu
                        then do:
                            create wfprodu.
                            assign wfprodu.recag = recid(bprodu)
                                   wfprodu.pronom  = bprodu.pronom.
                        end.
                        vcont = vcont + 1.
                        if vcont mod 10 = 0
                        then do.
                            display "Selecionando" vcont
                                    with frame fffff1 row 22
                                            no-box no-label
                                                        color message.
                            pause 0.
                        end.                    
                    end. /* for each estoq ... */                        
                end.
                find bfabri where bfabri.fabcod = par-fabcod no-lock.
                vtitle = bcategoria.catnom + " " +   "Busca Fabricante - " + caps~(bfabri.fabnom).
                /***
                hide frame frame-a no-pause.
                recatu1 = ?.
                vgeral = no.
                leave.
                ***/
                
/*****/
                vtitle = bcategoria.catnom + " " +
                                    " Referencia " + par-refer + "".
                hide frame frame-a no-pause.
                recatu1 = ?.
                vgeral = no.
                esqascend = yes.
                leave.

/*****/
                
                
            end.





            **/
        end.
        
/***/        

        if vescolha = "x"
        then do:
            vgeral = yes.
        end.
        
        if vescolha = "fonet"
        then do:
            vpalavra = "".
            update "Digite uma Palara para filtrar " skip
            vpalavra format "x(77)"
                   with frame fbusca
                            centered row 10 overlay color message
                                     no-label.
            i = 0.
            vpalavra = "PRONOM#" + vpalavra.
            message 1 vpalavra.
            for each bprodu where bprodu.indicegenerico  contains vpalavra no-lock.
                i = i + 1.
            end.
            if i = 0
            then do:
                message "Nenhum Agente Comercial contendo este Nome".
                pause 3 no-message.
                vgeral = yes.
            end.    
            else do:
                for each wfprodu.
                    delete wfprodu.
                end.    
                for each bprodu where bprodu.indicegenerico CONTAINS vpalavra no-lock.
                    create wfprodu.
                    assign wfprodu.recag = recid(bprodu)
                           wfprodu.pronom  = bprodu.pronom.
                end.
                vtitle = bcategoria.catnom + " " +   "Busca Fonetica - " + caps(vpalavra).
                hide frame frame-a no-pause.
                recatu1 = ?.
                vgeral = no.
                leave.
            end.
        end.
        
        if vescolha = "nome"
        then do:
                run zoopron.p. 
                find first produ where 
                                    produ.procod = int(sretorno)
                            no-lock no-error.
                if avail produ
                then do:
                    vgeral = yes.
                    recatu1 = recid(produ).
                end.
                else .
                leave.
        end.
        if vescolha = "codigo"
        then do:
            def var vprocod like produ.procod.
            vprocod = 0.
            update "Digite o Codigo" vprocod 
                   with frame fbuscacodigo
                            centered row 10 overlay color message
                                        no-label.
            find first bprodu where 
                               bprodu.procod  >= int(vprocod                               )
                       no-lock no-error.
            vgeral = yes.
            if avail bprodu
            then do:
                    vgeral = yes.
                    recatu1 = recid(bprodu).
            end.
            else recatu1 = ?.
            leave.
        end.
        if vescolha = "geral"
        then do:
                     vgeral = yes.
                     vtitle = bcategoria.catnom + " " +   "GERAL" .
                     vprosit = ?. 
                     hide frame frame-a no-pause.
                     recatu1 = ?.
                     leave.
        end.
        if vescolha = "ATI"
        then do:
                     vgeral = yes.
                     vprosit = yes.
                     vtitle = bcategoria.catnom + " " +   "Geral Ativos ".
                     hide frame frame-a no-pause.
                     recatu1 = ?.
                     leave.
        end.
        if vescolha = "INA"
        then do:
                     vgeral = yes.
                     vtitle = bcategoria.catnom + " " +  "Geral Inativos ".
                     vprosit = no.
                     hide frame frame-a no-pause.
                     recatu1 = ?.
                     leave.
        end.
        */
    
    end procedure.



