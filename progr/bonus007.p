{admcab.i}
{admcom_funcoes.i}

def var vpardias as int.
def var vcalclim as dec.
def var vdisponivel as dec.

def new shared temp-table tt-dados
    field parametro as char
    field valor     as dec
    field valoralt  as dec
    field percent   as dec
    field vcalclim  as dec
    field operacao  as char format "x(1)" column-label ""
    field numseq    as int
    index dado1 numseq.
def buffer btt-dados for tt-dados.

def var dsresp as log init yes.
def var lim-calculado as dec.
def var vnumero as char.
def var vbairro as char.
def var vcompl as char.
def var vcep as char.
def var vcidade as char.

def var v-ok-email as log.

def var vnumeros as char init "0,1,2,3,4,5,6,7,8,9".
def var valfabeto as char
    init "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z".
def var vnext as log.

def var vcontem as char.

def temp-table tt-acao
    field acaocod   like acao.acaocod
    field descricao like acao.descricao
    field dtini     like acao.dtini
    field dtfin     like acao.dtfin
    field marca     as char format "X"
    index i-p      is primary unique acaocod
    index iacaocod acaocod desc .

def temp-table tt-limite
    field clicod like clien.clicod
    field limite as dec
    field limdisp as dec.

for each acao no-lock:
    find tt-acao where tt-acao.acaocod = acao.acaocod no-error.
    if not avail tt-acao
    then do:
        create tt-acao.
        assign tt-acao.acaocod   = acao.acaocod
               tt-acao.descricao = acao.descricao
               tt-acao.dtini     = acao.dtini
               tt-acao.dtfin     = acao.dtfin.
    end.
end.
def var vultcmp as char.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(20)" extent 3
    initial [" Seleciona ",
             " Gera Arquivo ",
             " Gera Bonus "].
             
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].

def var esqhel1         as char format "x(80)" extent 5
    initial [" ",
             " ",
             " ",
             " ",
             " "].
             
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].


def buffer btt-acao       for tt-acao.
def var vtt-acao         like tt-acao.acaocod.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-acao where recid(tt-acao) = recatu1 no-lock.

    if not available tt-acao
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-acao).
    
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.

    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-acao
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tt-acao where recid(tt-acao) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-acao.acaocod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-acao.acaocod)
                                        else "".
            run color-message.
            choose field tt-acao.marca 
                         tt-acao.acaocod 
                         tt-acao.descricao
                         tt-acao.dtini
                         tt-acao.dtfin help "" go-on(cursor-down cursor-up
                                                     cursor-left cursor-right
                                                     page-down   page-up
                                                     tab PF4 F4 ESC return).
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 3 then 3 else esqpos1 + 1.
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
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-acao
                    then leave.
                    recatu1 = recid(tt-acao).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-acao
                    then leave.
                    recatu1 = recid(tt-acao).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-acao
                then next.
                color display white/red tt-acao.marca 
                                        tt-acao.acaocod  
                                        tt-acao.descricao 
                                        tt-acao.dtini 
                                        tt-acao.dtfin with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-acao
                then next.
                color display white/red tt-acao.marca
                                        tt-acao.acaocod  
                                        tt-acao.descricao 
                                        tt-acao.dtini 
                                        tt-acao.dtfin with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:

            if esqregua
            then do:
            
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Seleciona "
                then do with frame f-seleciona on error undo.

                    if tt-acao.marca = ""
                    then tt-acao.marca = "*".
                    else tt-acao.marca = "".
                    
                    recatu1 = recid(tt-acao).
                    leave.
                end.
                
                if esqcom1[esqpos1] = " Gera Arquivo " 
                then do with frame f-gera-arquivo on error undo:
                                
                    run p-gera-arquivo-grafica.
                                
                    recatu1 = ?. 
                    leave. 
                
                end.

                if esqcom1[esqpos1] = " Gera Bonus " 
                then do with frame f-gera-bonus on error undo:
                                
                    sresp = no.
                    message "Confirma a geracao dos Bonus para as Campanhas selecionadas?" update sresp.
                    
                    if sresp
                    then
                        run p-gera-bonus.
                    
                    recatu1 = ?. 
                    leave. 
                
                end.

            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-acao).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.
procedure credito-pre-aprovado:
def var sal-aberto as dec.
for each titulo where titulo.clifor = clien.clicod no-lock:
    if titulo.modcod = "DEV" or
       titulo.modcod = "BON" or
       titulo.modcod = "CHP"
    then next.

    if titulo.titsit = "LIB"
    then do:
        sal-aberto = sal-aberto + titulo.titvlcob.
    end.

end.
def var maior-credito-aberto as dec.
def var media-credito-aberto as dec.
def var v1 as dec.
def var v2 as dec.
run stcrecli.p(input clien.clicod,
                               input 24, 
                               output maior-credito-aberto,
                               output media-credito-aberto,
                               output v1,
                               output v2).
                               
/*lim-calculado = maior-credito-aberto - sal-aberto.*/
lim-calculado = limite-cred-scor(recid(clien)).             
  
end procedure.

procedure frame-a.
    display tt-acao.marca     column-label ""
            tt-acao.acaocod   column-label "Codigo"
            tt-acao.descricao column-label "Campanha"
            tt-acao.dtini     column-label "Dt.Inicio"
            tt-acao.dtfin     column-label "Dt.Final"
            with frame frame-a 11 down centered color white/red row 5
                    title " Aniversario do Conjuge ".
end procedure.
procedure color-message.
    color display message tt-acao.marca     column-label ""
                          tt-acao.acaocod   column-label "Codigo"
                          tt-acao.descricao column-label "Campanha"
                          tt-acao.dtini     column-label "Dt.Inicio"
                          tt-acao.dtfin     column-label "Dt.Final"
                          with frame frame-a.
end procedure.
procedure color-normal.
    color display normal tt-acao.marca     column-label ""
                         tt-acao.acaocod   column-label "Codigo"
                         tt-acao.descricao column-label "Campanha"
                         tt-acao.dtini     column-label "Dt.Inicio"
                         tt-acao.dtfin     column-label "Dt.Final"
                         with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-acao use-index iacaocod where true
                                                no-lock no-error.
    else  
        find last tt-acao use-index iacaocod where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-acao use-index iacaocod where true
                                                no-lock no-error.
    else  
        find prev tt-acao use-index iacaocod where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-acao use-index iacaocod where true  
                                        no-lock no-error.
    else   
        find next tt-acao use-index iacaocod where true 
                                        no-lock no-error.
        
end procedure.
         

procedure p-gera-arquivo-grafica:

    def var vprinome as char.
    def var vprinome-conj as char.
    def var cont as int.
    def var varq as char.
    def var varq1 as char.

    if opsys = "UNIX"
    then varq = "/admcom/relat-crm/Arquivo-Bonus-Conjuge-" 
         + string(time)
         + ".csv.".
    else varq = "l:\relat-crm\Arquivo-Bonus-Conjuge-"
         + string(time)
         + ".csv".

    hide message no-pause.
    message "Gerando arquivo ...".

    for each tt-limite.
    delete tt-limite.
    end.
    
    for each tt-acao where tt-acao.marca <> "" no-lock.
        for each acao-cli where
            acao-cli.acaocod = tt-acao.acaocod no-lock.
            find clien where clien.clicod = acao-cli.clicod no-lock.
                    lim-calculado = 0.
                    /*run credito-pre-aprovado.
                    if lim-calculado = ? or
                       lim-calculado < 0
                    then lim-calculado = 0.   
                    */
/*                    lim-calculado = limite-cred-scor(recid(clien)). */
            find first tt-limite where tt-limite.clicod = acao-cli.clicod
                no-error.
            if not avail tt-limite
            then do:
                create tt-limite.
                tt-limite.clicod = acao-cli.clicod.
            end.
    vcalclim = 0.
    vdisponivel = 0.
   connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao
                                            no-error.
   if connected("dragao")            
   then do:
        run calccredscore.p (input "Tela",
                                 input recid(clien),
                                 output vcalclim,
                                 output vpardias,
                                 output vdisponivel).
        disconnect dragao.                                 
    end.                                 
            lim-calculado = vcalclim.            
            tt-limite.limite = lim-calculado.
            tt-limite.limdisp = vdisponivel.
        end.            
    end.
        
    output to value(varq).

        for each tt-acao where tt-acao.marca <> " " no-lock:

            for each acao-cli where
                     acao-cli.acaocod = tt-acao.acaocod no-lock:
                        

                find clien where 
                     clien.clicod = acao-cli.clicod no-lock no-error.

                /* NUMERO */
                if clien.numero[1] = 0 or
                   clien.numero[1] = ? or
                   clien.numero[1] > 5000
                then next.
                vnumero = string(clien.numero[1],">>>>9").

                vcontem = "".
                vnext = no.
                do cont = 1 to num-entries(valfabeto).
                    vcontem = "*" + entry(cont,valfabeto) + "*".
                    if vnumero matches vcontem
                    then vnext = yes.
                end.    
    
                /* BAIRRO */
                if clien.bairro[1] = ? or clien.bairro[1] = "" or
                   clien.bairro[1] = "rural" or
                   clien.bairro[1] = "interior" or
                   clien.bairro[1] = "zona rural" or
                   clien.bairro[1] = "sitio"
                then next.
                vbairro = clien.bairro[1].
                
                vcontem = "".
                vnext = no.
                do cont = 1 to num-entries(vnumeros).
                    vcontem = "*" + entry(cont,vnumeros) + "*".
                    if vbairro matches vcontem
                    then vnext = yes.
                end.    
    
                /* COMPLEMENTO */
                if clien.compl[1] = "rural" or
                   clien.compl[1] = "interior" or
                   clien.compl[1] = "zona rural" or
                   clien.compl[1] = "sitio"
                then next.                
                vcompl = clien.compl[1].
    
                vcontem = "".
                vnext = no.
                do cont = 1 to num-entries(vnumeros).
                    vcontem = "*" + entry(cont,vnumeros) + "*".
                    if vcompl matches vcontem
                    then vnext = yes.
                end.
                if vnext = yes
                then next.    
    
                /* CEP */
                vcep = replace(clien.cep[1],"-","").
                if length(vcep) <> 8
                then next.
    
                /* CIDADE */
                if clien.cidade[1] = ? or clien.cidade[1] = ""
                then next.
                vcidade = clien.cidade[1].
    
                vcontem = "".
                vnext = no.
                do cont = 1 to num-entries(vnumeros).
                    vcontem = "*" + entry(cont,vnumeros) + "*".
                    if vcidade matches vcontem
                    then vnext = yes.
                end.
                if vnext = yes
                then next.    
    
                find rfvcli where rfvcli.setor  = 0 
                              and rfvcli.clicod = acao-cli.clicod 
                              no-lock no-error.

                vprinome = "".
    
                do cont = 1 to length(clien.clinom):
                    if substring(clien.clinom,cont,1) <> ""
                    then vprinome = vprinome + substring(clien.clinom,cont,1).
                    else leave.
                end.
    
                vprinome-conj = "".

                cont = 0.
                do cont = 1 to length(clien.conjuge):
                    if substring(clien.conjuge,cont,1) <> ""
                    then vprinome-conj = vprinome-conj 
                            + substring(clien.conjuge,cont,1).
                    else leave.
                end.
    
                put unformatted 
                    vprinome            format "x(20)" 
                    ";"
                    dec(acao-cli.aux)   format ">>9.99"
                    ";"
                    clien.clinom        format "x(40)"
                    " - "
                    clien.clicod        format ">>>>>>>>>9"
                    ";"
                    clien.clinom        format "x(40)"
                    ";"
                    clien.endereco[1]   format "x(40)"
                    ";"
                    clien.numero[1]     format ">>>>9"
                    ";"
                    clien.compl[1]      format "x(10)"
                    ";"
                    clien.bairro[1]     format "x(30)"
                    ";"
                    clien.cep[1]        format "x(10)"
                    ";"
                    clien.cidade[1]     format "x(30)"
                    ";"
                    clien.ufecod[1]     format "XX"
                    ";"
                    vprinome-conj       format "x(20)"
                    ";"
                    string(acao-cli.recencia) format "x(12)" ";".
                    
                    if not avail rfvcli
                    then put "0" format "X".
                    else put substring(rfvcli.nota,1,1) format "X".
                    /*
                    lim-calculado = 0.
                    /*
                    run credito-pre-aprovado.
                    if lim-calculado = ? or
                       lim-calculado < 0
                    then lim-calculado = 0.   
                    */
                    lim-calculado = limite-cred-scor(recid(clien)).            
                                         */
                    find tt-limite where tt-limite.clicod = clien.clicod.                                         
                    put ";" tt-limite.limite /*lim-calculado*/ format ">>>,>>9.99" .

                    vultcmp = "00/0000".
                    find last plani  where
                        plani.movtdc = 5 and
                        plani.desti = clien.clicod no-lock no-error.
                    if avail plani
                    then vultcmp = trim(string(month(plani.pladat),"99") 
                        + "/" + string(year(plani.pladat),"9999")).
                    put ";" vultcmp ";" tt-limite.limdisp.
                    
                    assign v-ok-email = no.
                    
                    run pfval_mail2.p (input clien.zona, output v-ok-email).

                    if v-ok-email
                    then do:
                                        
                        put ";" clien.zona.

                    end.
                    
                    put skip.
            end.    

        end.
    
    output close.    

    if opsys = "UNIX"
    then varq1 = "/admcom/relat-crm/Arquivo-Bonus-Conjuge-Criticas" 
         + string(time)
         + ".csv.".
    else varq1 = "l:\relat-crm\Arquivo-Bonus-Conjuge-Criticas"
         + string(time)
         + ".csv".

    hide message no-pause.
    message "Gerando arquivo ...".
    
    output to value(varq1).

        for each tt-acao where tt-acao.marca <> " " no-lock:

            for each acao-cli where
                     acao-cli.acaocod = tt-acao.acaocod no-lock:
                        

                find clien where 
                     clien.clicod = acao-cli.clicod no-lock no-error.

                vnext = yes.
                /* NUMERO */
                if clien.numero[1] = 0 or
                   clien.numero[1] = ? or
                   clien.numero[1] > 5000
                then vnext = no.
                vnumero = string(clien.numero[1],">>>>9").

                vcontem = "".
                do cont = 1 to num-entries(valfabeto).
                    vcontem = "*" + entry(cont,valfabeto) + "*".
                    if vnumero matches vcontem
                    then vnext = no.
                end.    
    
                /* BAIRRO */
                if clien.bairro[1] = ? or clien.bairro[1] = "" or
                   clien.bairro[1] = "rural" or
                   clien.bairro[1] = "interior" or
                   clien.bairro[1] = "zona rural" or
                   clien.bairro[1] = "sitio"
                then vnext = no.
                vbairro = clien.bairro[1].
                
                vcontem = "".
                do cont = 1 to num-entries(vnumeros).
                    vcontem = "*" + entry(cont,vnumeros) + "*".
                    if vbairro matches vcontem
                    then vnext = no.
                end.    
    
                /* COMPLEMENTO */
                if clien.compl[1] = "rural" or
                   clien.compl[1] = "interior" or
                   clien.compl[1] = "zona rural" or
                   clien.compl[1] = "sitio"
                then vnext = no.
                vcompl = clien.compl[1].
    
                vcontem = "".
                do cont = 1 to num-entries(vnumeros).
                    vcontem = "*" + entry(cont,vnumeros) + "*".
                    if vcompl matches vcontem
                    then vnext = no.
                end.
    
                /* CEP */
                vcep = replace(clien.cep[1],"-","").
                if length(vcep) <> 8
                then vnext = no.
    
                /* CIDADE */
                if clien.cidade[1] = ? or clien.cidade[1] = ""
                then vnext = no  .
                vcidade = clien.cidade[1].
    
                vcontem = "".
                do cont = 1 to num-entries(vnumeros).
                    vcontem = "*" + entry(cont,vnumeros) + "*".
                    if vcidade matches vcontem
                    then vnext = no.
                end.
    
                find rfvcli where rfvcli.setor  = 0 
                              and rfvcli.clicod = acao-cli.clicod 
                              no-lock no-error.

                vprinome = "".
    
                do cont = 1 to length(clien.clinom):
                    if substring(clien.clinom,cont,1) <> ""
                    then vprinome = vprinome + substring(clien.clinom,cont,1).
                    else leave.
                end.
    
                vprinome-conj = "".

                cont = 0.
                do cont = 1 to length(clien.conjuge):
                    if substring(clien.conjuge,cont,1) <> ""
                    then vprinome-conj = vprinome-conj 
                            + substring(clien.conjuge,cont,1).
                    else leave.
                end.
    
                if vnext = yes
                then next.
                
                find tt-limite where tt-limite.clicod = clien.clicod.
                
                put unformatted 
                    vprinome            format "x(20)" 
                    ";"
                    dec(acao-cli.aux)   format ">>9.99"
                    ";"
                    clien.clinom        format "x(40)"
                    " - "
                    clien.clicod        format ">>>>>>>9"
                    ";"
                    clien.clinom        format "x(40)"
                    ";"
                    clien.endereco[1]   format "x(40)"
                    ";"
                    clien.numero[1]     format ">>>>9"
                    ";"
                    clien.compl[1]      format "x(10)"
                    ";"
                    clien.bairro[1]     format "x(30)"
                    ";"
                    clien.cep[1]        format "x(10)"
                    ";"
                    clien.cidade[1]     format "x(30)"
                    ";"
                    clien.ufecod[1]     format "XX"
                    ";"
                    vprinome-conj       format "x(20)"
                    ";"
                    string(acao-cli.recencia) format "x(12)" ";".
                    
                    if not avail rfvcli
                    then put "0" format "X".
                    else put substring(rfvcli.nota,1,1) format "X".
                    vultcmp = "00/0000".
                    find last plani  where
                        plani.movtdc = 5 and
                        plani.desti = clien.clicod no-lock no-error.
                    if avail plani
                    then vultcmp = trim(string(month(plani.pladat),"99") 
                        + "/" + string(year(plani.pladat),"9999")).
                    put ";" vultcmp 
                        ";"
                        tt-limite.limite    format ">>>,>>9.99"
                        ";"
                        tt-limite.limdisp   format ">>>,>>9.99".

                    assign v-ok-email = no.
                    
                    run pfval_mail2.p (input clien.zona, output v-ok-email).

                    if v-ok-email
                    then do:
                                        
                        put ";" clien.zona.

                    end.

                    put skip.
            end.    

        end.
    
    output close.    

    run msg2.p (input-output dsresp, 
                input "     ARQUIVO GERADO COM SUCESSO EM:" 
                    + " !" 
                    + "!"
                    + "        " + VARQ
                    + "!        " + varq1
                    + "!"
                    + "!     PRESSIONE ENTER PARA CONTINUAR ..." , 
                input " *** ATENCAO *** ", 
                input "    OK").
   
end procedure.

procedure p-gera-bonus:

    for each tt-acao where tt-acao.marca <> " " no-lock: 
        
        find acao where acao.acaocod = tt-acao.acaocod no-lock no-error.
        if not avail acao
        then do:
            message "Problemas ao tentar gerar bonus para a acao " 
                    tt-acao.acaocod.
            pause.
            next.
        end.
        
        for each acao-cli where acao-cli.acaocod = acao.acaocod no-lock:
            
            find rfvcli where rfvcli.setor  = 0 
                          and rfvcli.clicod = acao-cli.clicod no-lock no-error.
        
            create titulo.
            assign titulo.empcod   = 19
                   titulo.modcod   = "BON"
                   titulo.clifor   = acao-cli.clicod
                   titulo.titnum   = string(acao-cli.clicod)
                                   + string(acao-cli.acaocod,"999999")
                   titulo.titpar   = 1
                   titulo.titnat   = yes
                   titulo.etbcod   = rfvcli.etbcod
                   titulo.titdtemi = acao.dtini
                   titulo.titdtven = acao.dtfin
                   titulo.titvlcob = dec(acao-cli.aux)
                   titulo.titsit   = "LIB"
                   titulo.moecod   = "BON"
                   titulo.titob[1] = string(acao-cli.acaocod).
        end.               
    end.               

end procedure.
