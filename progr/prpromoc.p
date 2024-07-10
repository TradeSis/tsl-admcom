/*

*    Esqueletao de Programacao
*
*/

{admcab.i}
{difregtab.i new}
def input parameter p-rec as recid.

def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var vmes as int.
def var vano as int.
def var vdesmes as char format "x(10)" extent 12
    init["Janeiro","Fevereiro","Marco","Abril","Maio","Junho",
         "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].
def var esqcom1         as char format "x(12)" extent 6
  initial ["  Inclui","  Exclui","","","",""]
            .
def var esqcom2         as char format "x(12)" extent 5
  initial ["","","","",""].

def var vsel as char format "x(10)" extent 7    init[" Produto","  Classe","  Setor","Fabricante","  Brinde"," Casadinha"," Vinculado"].


form
        esqcom1
            with frame f-com1                                   
                 row 7 no-box no-labels side-labels centered.
form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
esqregua  = yes.
esqpos1  = 1.
esqpos2  = 1.

def var vdti as date.
def var vdtf as date.
def var vdtauxi as date.
def var vdtauxf as date.
def buffer bctpromoc for ctpromoc.
def buffer dctpromoc for ctpromoc.
 
find bctpromoc where recid(bctpromoc) = p-rec .
if bctpromoc.promocod = 54
then assign
        vsel[3] = ""
        vsel[4] = ""
        vsel[5] = ""
        vsel[6] = ""
        vsel[7] = "" .
 
form bctpromoc.qtdvenda    at 1 label "Comprado"
     bctpromoc.campodec[1] at 1 label "Pago    "
            format ">>>"
           with frame f-inqt 1 down side-label
            row 8 title "Produtos"
            .

def var vindex as int.

{setbrw.i}

repeat:
    disp  vsel with frame f-sel 1 down no-box no-label
          centered row 6.
    choose field vsel with frame f-sel.
    vindex = frame-index. 
    if vsel[vindex] = ""
    then next.
    if bctpromoc.situacao = "M"  and
        vindex < 5
    then do:
    
        if bctpromoc.qtdvenda = 0
        then bctpromoc.qtdvenda = 1.                
        update bctpromoc.qtdvenda   bctpromoc.campodec[1]
           with frame f-inqt.
    
        run selct-estac.

    end.
    if vindex = 1
    then do:
        run in-produto.
        hide frame f-inqt no-pause.
    end.
    else if vindex = 2
        then do:
            run in-classe.
            hide frame f-inqt no-pause.
        end.
        else if vindex = 3    
            then do:
                run in-setor.
                hide frame f-inqt no-pause.
            end.
            else if vindex = 4
                 then do:
                    run in-fabricante.
                    hide frame f-inqt no-pause.
                 end.
                 else if vindex = 5
                 then do:
                    if bctpromoc.campodec[1] > 0
                    then do:
                        message color red/with
                        "Opcao nao permitida." view-as alert-box .
                    end.
                    else run brpromoc.p(recid(bctpromoc)).
                 end.
                 else if vindex = 6
                    then do:
                        if bctpromoc.campodec[1] > 0
                        then do:
                            message color red/with
                            "Opcao nao permitida." view-as alert-box .
                        end.
                        else  run capromoc.p(recid(bctpromoc)).
                    end.
                    else if vindex = 7
                        then do:
                            run vipromoc.p(recid(bctpromoc)).
                        end.
                      
end.        

form ctpromoc.procod format ">>>>>>>>9"
     produ.pronom   format "x(35)"
     ctpromoc.precosugerido
     ctpromoc.situacao  validate(ctpromoc.situacao = "I" or
                                 ctpromoc.situacao = "A" or
                                 ctpromoc.situacao = "E"
                                 ,"Informe Corretamente")
     help "Informe :  A=Ativo  I=Inativo  E=Exceto "
     with frame f-linha.
                       
procedure in-produto:
    
    bl-princ1:
    repeat:
        
        assign
            a-seeid = -1
            a-recid = -1
            a-seerec = ?
            .
        {sklcls.i
            &help = "                        I  = Inclui     E  = Exclui"
            &file = ctpromoc
            &cfield = ctpromoc.procod
            &noncharacter = /*
            &ofield = "produ.pronom  
                       ctpromoc.precosugerido label ""Pr.Sugerido"" 
                       ctpromoc.situacao no-label format ""!""
                       " 
            &where = " ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.procod > 0 "
            &aftfnd1 = " find produ where produ.procod = ctpromoc.procod
                        no-lock no-error. "
            &naoexiste = " prpromoc.in "
            &otherkeys = " prpromoc.i "
            &aftselect = " prpromoc.as "
            &form   = " frame f-linha 9 down column 16 row 8 overlay 
           title "" Produtos da promocao ""  color with/cyan no-label width 65"
        } 
        if keyfunction(lastkey) = "end-error"
        then do:
            hide frame f-linha no-pause.
            leave bl-princ1.
        end.                      
    end.        
end procedure.

procedure inclui-pro.
    
    repeat on endkey undo, leave:
        find last dctpromoc where
                    dctpromoc.sequencia = bctpromoc.sequencia 
                    no-lock no-error.

        scroll from-current down with frame f-linha.
        create ctpromoc.
        assign
            ctpromoc.promocod = bctpromoc.promocod  
            ctpromoc.situacao = "A"
            ctpromoc.sequencia = bctpromoc.sequencia
            ctpromoc.linha     = dctpromoc.linha + 1
            ctpromoc.fincod = ?
            .
        do on error undo:
            update  ctpromoc.procod  with frame f-linha.
            find produ where produ.procod = ctpromoc.procod
                no-lock no-error.
            if not avail produ
            then do:
                message color red/with
                    "Produto " ctpromoc.procod " nao cadastrado." 
                    view-as alert-box.
                undo.
            end.
        
            disp produ.pronom with frame f-linha.
            update ctpromoc.situacao with frame f-linha.
        end.
   end.
            
end procedure.

procedure in-classe:

    run clapromoc.p( input recid(bctpromoc)).
    
end procedure.

procedure in-setor:
    bl-princ3:
    repeat:
        assign
            a-seeid = -1
            a-recid = -1
            a-seerec = ?
            .
        {sklcls.i
            &help = "          Enter=Altera  I = Inclui   E = Exclui"
            &file = ctpromoc
            &cfield = ctpromoc.setcod
            &noncharacter = /*
            &ofield = " categoria.catnom
                        ctpromoc.situacao format ""!"" "
            &where = " ctpromoc.sequencia = bctpromoc.sequencia and
                            ctpromoc.setcod > 0 "
            &aftfnd1 = " find categoria where categoria.catcod = ctpromoc.setcod
                        no-lock no-error. "
            &naoexiste = " setpromoc.in "
            &otherkeys = " setpromoc.i "
            &form   = " frame f-linha2 9 down centered row 8 
                    title "" Setores da promocao "" 
                    color with/cyan no-label "
        }  
        if keyfunction(lastkey) = "end-error"
        then do:
            hide frame f-linha2 no-pause.
            leave bl-princ3.
        end.                      
    end.        
end procedure.

procedure in-fabricante:
    bl-princ4:
    repeat:
        assign
            a-seeid = -1
            a-recid = -1
            a-seerec = ?
            .
        hide frame f-linha3 no-pause.

        {sklcls.i
            &help = "                        I = Inclui     E = Exclui"
            &file = ctpromoc
            &cfield = ctpromoc.fabcod
            &noncharacter = /*
            &ofield = fabri.fabnom
            &where = " ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.fabcod > 0 "
            &aftfnd1 = " find fabri where fabri.fabcod = ctpromoc.fabcod
                        no-lock no-error. "
            &naoexiste = " fabpromoc.in "
            &otherkeys = " fabpromoc.i "
            &form   = " frame f-linha3 9 down centered row 8 
                    title "" Fabricantes da promocao "" 
                    color with/cyan no-label "
        }  

        if keyfunction(lastkey) = "end-error"
        then do:
            hide frame f-linha3 no-pause.
            leave bl-princ4.
        end.
    end.        
end procedure.

procedure selct-estac:
    def var vsel-estac as char.
    if acha("PESTACAO",bctpromoc.campochar2[1]) <> ?
    then vsel-estac = acha("PESTACAO",bctpromoc.campochar2[1]).
    {marcaestac.i}
    bctpromoc.campochar2[1] = "PESTACAO=" + vsel-estac + "|"
            + bctpromoc.campochar2[1].
end.
