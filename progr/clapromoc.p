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

def var vsel as char format "x(10)" extent 7    init[" Produto","  Classe","  S~etor","Fabricante","  Brinde"," Casadinha"," Vinculado"].

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
 
form bctpromoc.qtdvenda    at 1 label "Comprado"
     bctpromoc.campodec[1] at 1 label "Pago    "
            format ">>>"
           with frame f-inqt 1 down side-label
            row 8 title "Produtos"
            .

def var vindex as int.

form ctpromoc.clacod
     clase.clanom
     ctpromoc.situacao  validate(ctpromoc.situacao = "I" or
                                 ctpromoc.situacao = "A" or
                                 ctpromoc.situacao = "E"
                                 ,"Informe Corretamente")
     help "Informe :  A=Ativo  I=Inativo  E=Exceto "
     with frame f-linha1.
     
{setbrw.i}

run in-classe.

procedure in-classe:
    bl-princ2:
    repeat:
        assign
            a-seeid = -1
            a-recid = -1
            a-seerec = ?
            .
        {sklcls.i
            &help = "            Enter=Altera   "I" = Inclui   "E" = Exclui"
            &file = ctpromoc
            &cfield = ctpromoc.clacod
            &noncharacter = /*
            &ofield = " clase.clanom when avail clase
                        ctpromoc.situacao  no-label format ""!""
                      "  
            &where = " ctpromoc.sequencia = bctpromoc.sequencia  and
                        ctpromoc.clacod > 0 "
            &aftfnd1 = " find clase where clase.clacod = ctpromoc.clacod
                        no-lock no-error.
                  "
            &naoexiste = " clapromoc.in "
            &otherkeys = " clapromoc.i "
            &aftselect1 = " update ctpromoc.situacao with frame f-linha1. "
            &form   = " frame f-linha1 9 down centered row 8 
                    title "" Classe da promocao "" 
                    color with/cyan no-label "
        }  
        if keyfunction(lastkey) = "end-error"
        then do:
            hide frame f-linha1 no-pause.
            leave bl-princ2.
        end.                      
    end.        
end procedure.

