/*

* Manutencao em Tipos de Operacao Comercial
* Programa original: tipmov01.p
* Campos nao usados: TipMov.movtaut, movttitu, movtcre, movtnat
* Campos com uso duvidoso: tipmov.movtdeb
  
*/

{admcab.i}

def var v as int.
def var modelo-documento  as char label "Modelo Documento".
def var tipo-documento    as char label "Tipo Documento".
def var natureza-operacao as char label "Natureza da Operacao" format "x(60)".

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 6
    init["", " Pesquisa "," Alteracao "," Consulta "," Listagem ", ""].
/***
         initial ["Operacoes Comerciais"," Pesquisa "," Consulta "," Filtro ",
                  " Copia ", " Alteracao "].
***/

def buffer btipmov       for tipmov.

/***
if sfuncod <> 100
then assign
    esqcom1[5] = ""
    esqcom1[6] = "".
***/

form
    esqcom1
        with frame f-com1 row 4 no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        find first tipmov no-lock no-error.
    else
        find tipmov where recid(tipmov) = recatu1 no-lock.
    if not available tipmov
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    recatu1 = recid(tipmov).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        find next tipmov no-lock no-error.
        if not available tipmov
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
            find tipmov where recid(tipmov) = recatu1 no-lock.
            disp tipmov.movtnom no-label format "x(60)"
                 with frame f-sub no-box row screen-lines.

            choose field tipmov.movtdc pause 50
                go-on(cursor-down cursor-up
                  page-down   page-up
                  cursor-left cursor-right
                  PF4 F4 ESC return).
        end.
        hide message no-pause.
        if keyfunction(lastkey) = "cursor-right"
        then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
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
                find next tipmov no-lock no-error.
                if not avail tipmov
                then leave.
                recatu2 = recid(tipmov).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tipmov no-lock no-error.
                if not avail tipmov
                then leave.
                recatu1 = recid(tipmov).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tipmov no-lock no-error.
            if not avail tipmov
            then next.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tipmov no-lock no-error.
            if not avail tipmov
            then next.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Operacoes Comerciais"
            then do:
                hide frame f-com1 no-pause.
                run cad/opcom.p (input recid(tipmov)).
                pause 0.
                view frame f-com1.
                leave.
            end.
            if esqcom1[esqpos1] = " Pesquisa "
            then do with frame f-pesq side-label row 5 overlay.
                prompt-for tipmov.movtdc format ">>9".
                if input tipmov.movtdc > 0
                then do.
                    find first btipmov
                                   where btipmov.movtdc >= input tipmov.movtdc
                                   no-lock no-error.
                    if avail btipmov
                    then recatu1 = recid(btipmov).
                end.
                else do.
                    prompt-for opcom.opccod.
                    if input opcom.opccod <> ""
                    then do.
                        find first opcom
                                    where opcom.opccod = input opcom.opccod
                                    no-lock no-error.
                        if avail opcom
                        then do.
                            find btipmov of opcom no-lock.
                            recatu1 = recid(btipmov).
                        end.
                    end.
                end.
                hide frame f-pesq.
                leave.
            end.
            if esqcom1[esqpos1] = " Consulta " or
               esqcom1[esqpos1] = " Alteracao "
            then do.
                disp
                    tipmov.movtdc   format ">>9"
                    tipmov.movtsig
                    tipmov.movtnom  format "x(50)"
                    tipmov.tipemite label "Estoque" format "Saida/Entrada"
                    tipmov.movtcusto
                    skip(1)
                    tipmov.movtest
                    /*tipmov.movtesp*/
                    skip
                    /*tipmov.etecod-entra
                    tipmov.etecod-saida*/
                    skip(1)
                    tipmov.movttra
                    /*tipmov.movttrcre*/
                    tipmov.movtvenda
                    tipmov.movtcompra
                    tipmov.movtdev
                    /*tipmov.xx-pncod label "Tip.Mov.Associado"*/
                    tipmov.movtnota format "Emite/Digita"
                    tipmov.notass                    
                    tipmov.movtlin
                    /*tipmov.movtreq
                    tipmov.situacao*/
                    tipmov.emitecusto
                    /*
                    tipmov.movtentrada label "Tributacao" format "Entrada/Saida"
                    */
                    tipmov.piscofins
                    tipmov.contapiscof
                    with frame f-consulta 2 col row 5 centered.
                if esqcom1[esqpos1] = " Consulta "
                then pause.
            end.
            if esqcom1[esqpos1] = " Copia "
            then do on error undo with frame f-copia side-label.
                message "Confirma copiar tipmov" tipmov.movtdc "?"
                update sresp.
                if sresp = no
                then leave.

                do v = 1 to 200.
                    find tipmov where tipmov.movtdc = v no-lock no-error.
                    if avail tipmov then next.
                    leave.
                end.

                disp v @ tipmov.movtdc.
                prompt-for tipmov.movtdc format ">>9".
                
                find tipmov where recid(tipmov) = recatu1 no-lock.
                create btipmov.
                ASSIGN btipmov.movtdc  = input tipmov.movtdc
                       btipmov.MovtNom = "Copia de " + tipmov.MovtNom.
                buffer-copy tipmov except movtdc movtnom to btipmov.
                message btipmov.movtdc btipmov.movtnom "Criado "
                        VIEW-AS ALERT-BOX.
                recatu1 = recid(tipmov).
                leave.
            end.
            if esqcom1[esqpos1] = " Alteracao "
            then do on error undo with frame f-consulta.
                find tipmov where recid(tipmov) = recatu1.
                update
                    /*tipmov.movtnom*/
                    tipmov.tipemite   when sfuncod = 100
                    tipmov.movtcusto  when sfuncod = 100
                    tipmov.movtest    when sfuncod = 100
                    /*tipmov.movtesp*/
                    tipmov.movtcompra when sfuncod = 100
                    tipmov.movtdev    when sfuncod = 100
                    /*tipmov.xx-pncod*/
                    tipmov.movtnota   when sfuncod = 100
                    /*tipmov.situacao*/
                    tipmov.piscofins.
            end.
            if esqcom1[esqpos1] = " Filtro "
            then do on error undo with frame f-filtro side-label row 5 3 col.
                disp
                    ? @ tipmov.movtest
                    ? @ tipmov.movtcusto
                    ? @ tipmov.movtnota
                    ? @ tipmov.tipemite
                    ? @ tipmov.movtvenda
                    ? @ tipmov.movtdev
                    ? @ tipmov.movttra.
                prompt-for
                    tipmov.movtest
                    tipmov.movtcusto
                    tipmov.movtnota format "Emite/Digita"  help "Emite/Digita"
                    tipmov.tipemite format "Saida/Entrada" help "Saida/Entrada"
                    tipmov.movtvenda
                    tipmov.movtdev
                    tipmov.movttra.
                for each btipmov where
                               (if input tipmov.movtest <> ?
                                then btipmov.movtest   = input tipmov.movtest
                                else true)

                           and (if input tipmov.movtcusto <> ?
                                then btipmov.movtcusto = input tipmov.movtcusto
                                else true)

                           and (if input tipmov.movtnota <> ?
                                then btipmov.movtnota  = input tipmov.movtnota
                                else true)

                           and (if input tipmov.movtvenda <> ?
                                then btipmov.movtvenda = input tipmov.movtvenda
                                else true)

                           and (if input tipmov.movtdev <> ?
                                then btipmov.movtdev   = input tipmov.movtdev
                                else true)

                           and (if input tipmov.movttra <> ?
                                then btipmov.movttra   = input tipmov.movttra
                                else true)

                           and (if input tipmov.tipemite <> ?
                                then btipmov.tipemite  = input tipmov.tipemite
                                else true)

                                no-lock.
                    disp btipmov.movtdc  format ">>9"
                         btipmov.movtnom format "x(40)"
                         /*btipmov.xx-pncod*/
                         btipmov.movtlin
                         /*btipmov.movtreq
                         btipmov.situacao format "Ati/Ina"*/
                         with frame f-list 12 down.
                end.
                pause.
            end.

            if esqcom1[esqpos1] = " Listagem "
            then do.
                message "Confirma Impressao?" update sresp.
                if not sresp
                then next bl-princ.

                recatu2 = recatu1.

                run relatorio.

                recatu1 = recatu2.
                leave.
            end.
        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tipmov).
   end.
end.
hide frame frame-a no-pause.
hide frame f-com1  no-pause.

procedure frame-a.

    display
        tipmov.movtdc     format ">>9" column-label "Cod"
        tipmov.movtnom
        tipmov.movtsig
        tipmov.movtnota   column-label "" format "Emi/Dig"
        tipmov.movtest    column-label "Est!oq"
        tipmov.tipemite label "Estoque" format "Sai/Ent"
        tipmov.movtcusto  column-label "Cus!to"
        tipmov.movtvenda  column-label "Ven!da"
        tipmov.movtcompra column-label "Com!pra"
        tipmov.movtdev    column-label "Dev!ol"
        tipmov.movttra    column-label "Tra!nsf"
        /*tipmov.situacao   format "Ati/Ina"*/
        tipmov.modcod
        with frame frame-a 11 down centered row 5 
            title " Tipos de Movimentacoes ".

end procedure.


procedure relatorio:

    def var varquivo as char.
    
    varquivo = "/admcom/relat/tipmov." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "100" 
                &Page-Line = "66" 
                &Nom-Rel   = ""tipmov01"" 
                &Nom-Sis   = """MODULO CONTABIL/FISCAL""" 
                &Tit-Rel   = """ TIPOS DE DOCUMENTOS """ 
                &Width     = "100"
                &Form      = "frame f-cabcab"}

    for each tipmov no-lock:
        assign
                    modelo-documento = ""
                    tipo-documento = "".
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "Modelo-Documento"
                           no-lock no-error.
                if avail tipmovaux
                then modelo-documento = tipmovaux.valor_campo.
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "Tipo-Documento"
                           no-lock no-error.
                if avail tipmovaux
                then tipo-documento = tipmovaux.valor_campo.
 
        disp  tipmov.movtdc
                        movtnom movtnat movtsig
                        movtnota movttitu
                        movtaut
                        movtdeb
                        movtcre 
                        modcod
                        modelo-documento column-label "Modelo!Documento"
                        tipo-documento   column-label "Tipo!Documento"
                        with frame f-relat down width 100.
        down with frame f-relat.
 
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
