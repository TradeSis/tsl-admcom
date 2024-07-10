/*26022021 helio*/

def var vmes as int.
def var vano as int.
def var vdata as date.
def var vmesext         as char format "x(10)"  extent 12
                        initial ["Janeiro" ,"Fevereiro","Marco"   ,"Abril",
                                 "Maio"    ,"Junho"    ,"Julho"   ,"Agosto",
                                 "Setembro","Outubro"  ,"Novembro","Dezembro"] .


                  pause 0.
    assign 
           vmes   = 0
           vano   = 0
           vdtini = ?
           vdtfin = ?
           vdata  = ?.
    form
        space(5) vmesext[01] space(5) skip
        space(5) vmesext[02] space(5) skip
        space(5) vmesext[03] space(5) skip
        space(5) vmesext[04] space(5) skip
        space(5) vmesext[05] space(5) skip
        space(5) vmesext[06] space(5) skip
        space(5) vmesext[07] space(5) skip
        space(5) vmesext[08] space(5) skip
        space(5) vmesext[09] space(5) skip
        space(5) vmesext[10] space(5) skip
        space(5) vmesext[11] space(5) skip
        space(5) vmesext[12] space(5) skip
         with frame fmes
         title string("   Referencia   ").
        display "Informe o Mes e Ano / Estabelecimento " at 23
            with frame fdad row 4 no-box width 81 color message.

    pause 0.
    display vmesext
            with frame fmes no-label /*column 14*/ row 5.


    choose field vmesext
            help "Selecione o Mes"
           with frame fmes.
    vmes = frame-index.
    vano = year(today).
    update vano label "Ano" format "9999" colon 16
            help "Informe o Ano"
            validate (vano > 0,"Ano Invalido")
            with frame fano 
            side-label column 23 width 55 .
    assign
        vdtini   = date(vmes,01,vano)
        vano     = year(vdtini) + if month(vdtini) = 12 then 1 else 0
        vmes     = if month(vdtini) = 12 then 1 else month(vdtini) + 1
        vdata    = date(vmes,01,vano) - 1
        vdtfin   = vdata.
 
disp
    vdtfin no-labels
        with frame fano.
 
    update vetbcod  colon 16 
    with frame fano.
    if vetbcod = 0 
    then do:  
        disp "Geral" @ estab.etbnom no-labels
            with frame fano.
         
    end.
    else do:
        find estab where  estab.etbcod = vetbcod no-lock.
        disp estab.etbnom
            with frame fano.
    end.   
    
update vmodal label "Selec. Modal?" colon 16
help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
 with frame fano.

    if vmodal
    then do:
        run selec-modal.p ("REC"). /* #4 */
    end.    
    else do:
        run le_tabini.p (0, 0, "Filtro-Modal-REC", OUTPUT vmodais).
        do v-cont = 1 to num-entries(vmodais).
            vmodcod = entry(v-cont, vmodais).
            create tt-modalidade-selec.
            assign tt-modalidade-selec.modcod = vmodcod.
        end.
    end.

assign vmod-sel = "".
for each tt-modalidade-selec.
    assign vmod-sel = vmod-sel  + 
        (if vmod-sel = ""
         then ""
         else "/") + trim(tt-modalidade-selec.modcod).
end.
display vmod-sel format "x(24)" no-label
    with frame fano.

    hide frame fmes no-pause.
    hide frame fdad  no-pause.
    hide frame fano no-pause.
