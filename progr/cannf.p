{admcab.i}
def var ser-u as i.
def var ser-d1 as i.
def var ser-d2 as i.
def var ser-d3 as i.
def var ser-d4 as i.
def var ser-a as i.
def var ser-b as i.
def var i as i.
def var vserie as i extent 99.
def var tot-s as i.
def var tot-e as i.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
repeat:

    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".

        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.

        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""NFCAN""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """LISTAGEM DE NOTAS ANULADAS - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}
put " FILIAL     D1         D2         D3         D4"
    "U           A         B       TOTAL"  at 58
            SKIP
      fill("-",130) format "x(130)" skip.

        for each nota where nota.notdat >= vdti        and
                            nota.notdat <= vdtf no-lock break by nota.etbcod:

            if nota.notser = "1" or nota.notser = "d1"
            then ser-d1 = ser-d1 + 1.
            if nota.notser = "2" or nota.notser = "d2"
            then ser-d2 = ser-d2 + 1.
            if nota.notser = "3" or nota.notser = "d3"
            then ser-d3 = ser-d3 + 1.
            if nota.notser = "4" or nota.notser = "d4"
            then ser-d4 = ser-d4 + 1.

            if nota.notser = "5" or nota.notser = "M1"
            then ser-u = ser-u + 1.

            if nota.notser = "A"
            then ser-a = ser-a + 1.
            if nota.notser = "B"
            then ser-b = ser-b + 1.

            if last-of(nota.etbcod)
            then do:
                disp nota.etbcod
                     ser-d1
                     ser-d2
                     ser-d3
                     ser-d4
                     ser-u
                     ser-a
                     ser-b
                     (ser-u + ser-d1 +
                      ser-d2 + ser-d3 + ser-d4 + ser-a + ser-b) with frame ff
                                no-box no-label width 150.
                assign ser-u  = 0
                       ser-d1 = 0
                       ser-d2 = 0
                       ser-d3 = 0
                       ser-d4 = 0
                       ser-a  = 0
                       ser-b  = 0.

            end.
        end.
    output close.
end.
