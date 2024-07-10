def input parameter vrow-produ as rowid.

def buffer     produ    for produ.
def buffer bf1-produ    for produ.
def buffer bf1-clasecom for clasecom.
def buffer bf2-clasecom for clasecom.

find produ where rowid(produ) = vrow-produ no-lock.

def var esqcom3  as character format "x(14)" extent 2.

def var vlog-resp as logical.
def var vindex    as integer no-undo.

def var esqpos3             as integer.

def temp-table tt-e-commerce no-undo
    field nome           as character extent 2 format "x(55)"
    field desccom        as character extent 7
    field exporta        as logical format "Sim/Nao"
    field peso           as decimal format ">>9.99"
    field altura         as integer format ">>>>>>9"
    field largura        as integer format ">>>>>>9"
    field profund        as integer format ">>>>>>9"
    field fretegratis    as logical
    field voltagem       as integer format ">>>>>9"
    field marca          as character format "x(35)"
    field estmin         as integer format ">>>>9"
    field clasecom       as integer format ">>>>9"  
    field informtec      as character extent 100
    field ofespec        as logical
    field procodcompl    as integer
    field codcatfiskpl   as integer.

form "                           "
     tt-e-commerce.desccom[1]    label "Desc. Comercial" at 4 format "x(58)"
     tt-e-commerce.desccom[2]    no-label at 1 format "x(78)"
     tt-e-commerce.desccom[3]    no-label at 1 format "x(78)"
     tt-e-commerce.desccom[4]    no-label at 1 format "x(78)"
     tt-e-commerce.desccom[5]    no-label at 1 format "x(78)"
     tt-e-commerce.desccom[6]    no-label at 1 format "x(78)"
     tt-e-commerce.desccom[7]    no-label at 1 format "x(78)"
     "                           "
     "                           "
     "                           "
     "                           "
     "                           "
     "                           "
     "                           "
                 with frame f-desccom width 80 centered row 5 1 down
                                  OVERLAY side-labels color black/cyan.


form "                           "
     tt-e-commerce.exporta       label "Exporta E-Commerce"
     tt-e-commerce.nome[1]       label "Descricao" at 10
     tt-e-commerce.nome[2]       no-label at 21
     tt-e-commerce.peso          label "Peso"
     tt-e-commerce.altura        label "Alt"
     tt-e-commerce.largura       label "Larg"
     tt-e-commerce.profund       label "Prof"
     tt-e-commerce.voltagem      label "Volt." format ">>>9"
     tt-e-commerce.marca         label "Marca" format "x(32)"
     tt-e-commerce.estmin        label "Est.Min." format ">>9"
     tt-e-commerce.clasecom      label "Classe" format ">>>9"
     tt-e-commerce.procodcompl   label "Cod.Prod.Complem." format ">>>>>9"
     tt-e-commerce.ofespec       label "Oferta Especial" format "Sim/Nao"
     tt-e-commerce.fretegratis   label "Pode ser Brinde?" format "Sim/Nao"
     tt-e-commerce.codcatfiskpl  label "Cod Cat Fis KPL"
     "                           "
     "                           "
     "                           "
     "                           "
     with frame f-E-commerce width 80 centered
                                      OVERLAY side-labels color black/cyan.

form "                "
     tt-e-commerce.informtec[1]    label "Inf. Tecnicas" at 4 format "x(58)"
     tt-e-commerce.informtec[2]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[3]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[4]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[5]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[6]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[7]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[8]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[9]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[10]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[11]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[12]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[13]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[14]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[15]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[16]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[17]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[18]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[19]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[20]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[21]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[22]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[23]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[24]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[25]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[26]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[27]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[28]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[29]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[30]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[31]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[32]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[33]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[34]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[35]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[36]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[37]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[38]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[39]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[40]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[41]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[42]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[43]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[44]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[45]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[46]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[47]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[48]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[49]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[50]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[51]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[52]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[53]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[54]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[55]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[56]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[57]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[58]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[59]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[60]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[61]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[62]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[63]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[64]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[65]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[66]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[67]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[68]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[69]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[70]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[71]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[72]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[73]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[74]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[75]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[76]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[77]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[78]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[79]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[80]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[81]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[82]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[83]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[84]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[85]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[86]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[87]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[88]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[89]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[90]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[91]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[92]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[93]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[94]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[95]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[96]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[97]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[98]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[99]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[100]   no-label at 1 format "x(78)"
                      with frame f-Ecom-inftec width 80 row 5 1 down
                      title " Informacoes Tecnicas "
                                OVERLAY side-labels color black/cyan.

form esqcom3 with frame f-E-commerce-aux
                    row screen-lines - 2 title " Inf. Adicionais E-Commerce "
                                   no-labels side-labels column 1 width 80.
     esqpos3   = 1.

empty temp-table tt-e-commerce.

create tt-e-commerce.

find first produaux where produaux.procod = produ.procod
                      and produaux.nome_campo = "exporta-e-com"
                    no-lock no-error.
if available produaux
then
    assign tt-e-commerce.exporta = (ProduAux.Valor_Campo = "yes").
else do:
    create produaux.
    assign produaux.procod      = produ.procod
           produaux.Nome_Campo  = "exporta-e-com"
           produaux.Valor_Campo = "no"
           produaux.Tipo_Campo  = "logical".
    assign tt-e-commerce.exporta = no.
end.

find first prodecom where prodecom.procod = produ.procod no-lock no-error.
if available prodecom
then do:
    assign tt-e-commerce.nome[1] = substring(prodecom.nome,1,55).
    assign tt-e-commerce.nome[2] = substring(prodecom.nome,56,55).
    assign tt-e-commerce.desccom[1] = substring(prodecom.desccom,1,58).  
    assign tt-e-commerce.desccom[2] = substring(prodecom.desccom,59,78).
    assign tt-e-commerce.desccom[3] = substring(prodecom.desccom,137,78).
    assign tt-e-commerce.desccom[4] = substring(prodecom.desccom,215,78).
    assign tt-e-commerce.desccom[5] = substring(prodecom.desccom,293,78).
    assign tt-e-commerce.desccom[6] = substring(prodecom.desccom,371,78).
    assign tt-e-commerce.desccom[7] = substring(prodecom.desccom,449,78).
    assign tt-e-commerce.peso        = prodecom.peso
           tt-e-commerce.altura      = prodecom.altura
           tt-e-commerce.largura     = prodecom.largura
           tt-e-commerce.profund     = prodecom.profund
           tt-e-commerce.fretegratis = prodecom.fretegratis
           tt-e-commerce.voltagem    = prodecom.voltagem
           tt-e-commerce.marca       = prodecom.marca
           tt-e-commerce.estmin      = prodecom.estmin
           tt-e-commerce.clasecom    = prodecom.clacod
           tt-e-commerce.ofespec     = prodecom.ofespec
           tt-e-commerce.procodcompl = prodecom.procodcompl
           tt-e-commerce.codcatfiskpl = prodecom.codcatfiskpl.

    assign tt-e-commerce.informtec[1] = substring(prodecom.especiftec,1,58).
    assign tt-e-commerce.informtec[2] = substring(prodecom.especiftec,59,78).
    assign tt-e-commerce.informtec[3] = substring(prodecom.especiftec,137,78).
    assign tt-e-commerce.informtec[4] = substring(prodecom.especiftec,215,78).
    assign tt-e-commerce.informtec[5] = substring(prodecom.especiftec,293,78).
    assign tt-e-commerce.informtec[6] = substring(prodecom.especiftec,371,78).
    assign tt-e-commerce.informtec[7] = substring(prodecom.especiftec,449,78).
    assign tt-e-commerce.informtec[8] = substring(prodecom.especiftec,527,78).
    assign tt-e-commerce.informtec[9] = substring(prodecom.especiftec,605,78).
    assign tt-e-commerce.informtec[10] = substring(prodecom.especiftec,683,78).
    assign tt-e-commerce.informtec[11] = substring(prodecom.especiftec,761,78).
    assign tt-e-commerce.informtec[12] = substring(prodecom.especiftec,839,78).
    assign tt-e-commerce.informtec[13] = substring(prodecom.especiftec,917,78).
    assign tt-e-commerce.informtec[14] = substring(prodecom.especiftec,995,78).
    assign tt-e-commerce.informtec[15] = substring(prodecom.especiftec,1073,78).
    assign tt-e-commerce.informtec[16] = substring(prodecom.especiftec,1151,78).
    assign tt-e-commerce.informtec[17] = substring(prodecom.especiftec,1229,78).
    assign tt-e-commerce.informtec[18] = substring(prodecom.especiftec,1307,78).

    assign tt-e-commerce.informtec[19] =
                          substring(prodecom.especiftec,1385,78).

    assign tt-e-commerce.informtec[20] =
                          substring(prodecom.especiftec,1463,78).

    assign tt-e-commerce.informtec[21] =
                          substring(prodecom.especiftec,1541,78).

    assign tt-e-commerce.informtec[22] =
                          substring(prodecom.especiftec,1619,78).

    assign tt-e-commerce.informtec[23] =
                          substring(prodecom.especiftec,1697,78).

    assign tt-e-commerce.informtec[24] =
                          substring(prodecom.especiftec,1775,78).

    assign tt-e-commerce.informtec[25] =
                          substring(prodecom.especiftec,1853,78).

    assign tt-e-commerce.informtec[26] =
                          substring(prodecom.especiftec,1931,78).

    assign tt-e-commerce.informtec[27] =
                          substring(prodecom.especiftec,2009,78).

    assign tt-e-commerce.informtec[28] =
                          substring(prodecom.especiftec,2087,78).

    assign tt-e-commerce.informtec[29] =
                          substring(prodecom.especiftec,2165,78).

    assign tt-e-commerce.informtec[30] =
                          substring(prodecom.especiftec,2243,78).

    assign tt-e-commerce.informtec[31] =
                          substring(prodecom.especiftec,2321,78).

    assign tt-e-commerce.informtec[32] =
                          substring(prodecom.especiftec,2399,78).

    assign tt-e-commerce.informtec[33] =
                          substring(prodecom.especiftec,2477,78).

    assign tt-e-commerce.informtec[34] =
                          substring(prodecom.especiftec,2555,78).

    assign tt-e-commerce.informtec[35] =
                          substring(prodecom.especiftec,2633,78).

    assign tt-e-commerce.informtec[36] =
                          substring(prodecom.especiftec,2711,78).

    assign tt-e-commerce.informtec[37] =
                          substring(prodecom.especiftec,2789,78).

    assign tt-e-commerce.informtec[38] =
                          substring(prodecom.especiftec,2867,78).

    assign tt-e-commerce.informtec[39] =
                          substring(prodecom.especiftec,2945,78).

    assign tt-e-commerce.informtec[40] =
                          substring(prodecom.especiftec,3023,78).

    assign tt-e-commerce.informtec[41] =
                          substring(prodecom.especiftec,3101,78).

    assign tt-e-commerce.informtec[42] =
                          substring(prodecom.especiftec,3179,78).

    assign tt-e-commerce.informtec[43] =
                          substring(prodecom.especiftec,3257,78).

    assign tt-e-commerce.informtec[44] =
                          substring(prodecom.especiftec,3335,78).

    assign tt-e-commerce.informtec[45] =
                          substring(prodecom.especiftec,3413,78).

    assign tt-e-commerce.informtec[46] =
                          substring(prodecom.especiftec,3491,78).

    assign tt-e-commerce.informtec[47] =
                          substring(prodecom.especiftec,3569,78).

    assign tt-e-commerce.informtec[48] =
                          substring(prodecom.especiftec,3647,78).

    assign tt-e-commerce.informtec[49] =
                          substring(prodecom.especiftec,3725,78).

    assign tt-e-commerce.informtec[50] =
                          substring(prodecom.especiftec,3803,78).

    assign tt-e-commerce.informtec[51] =
                          substring(prodecom.especiftec,3881,78).

    assign tt-e-commerce.informtec[52] =
                          substring(prodecom.especiftec,3959,78).

    assign tt-e-commerce.informtec[53] =
                          substring(prodecom.especiftec,4037,78).

    assign tt-e-commerce.informtec[54] =
                          substring(prodecom.especiftec,4115,78).

    assign tt-e-commerce.informtec[55] =
                          substring(prodecom.especiftec,4193,78).

    assign tt-e-commerce.informtec[56] =
                          substring(prodecom.especiftec,4271,78).

    assign tt-e-commerce.informtec[57] =
                          substring(prodecom.especiftec,4349,78).

    assign tt-e-commerce.informtec[58] =
                          substring(prodecom.especiftec,4427,78).

    assign tt-e-commerce.informtec[59] =
                          substring(prodecom.especiftec,4505,78).

    assign tt-e-commerce.informtec[60] =
                          substring(prodecom.especiftec,4583,78).

    assign tt-e-commerce.informtec[61] =
                          substring(prodecom.especiftec,4661,78).

    assign tt-e-commerce.informtec[62] =
                          substring(prodecom.especiftec,4739,78).

    assign tt-e-commerce.informtec[63] =
                          substring(prodecom.especiftec,4817,78).

    assign tt-e-commerce.informtec[64] =
                          substring(prodecom.especiftec,4895,78).

    assign tt-e-commerce.informtec[65] =
                          substring(prodecom.especiftec,4973,78).

    assign tt-e-commerce.informtec[66] =
                          substring(prodecom.especiftec,5051,78).

    assign tt-e-commerce.informtec[67] =
                          substring(prodecom.especiftec,5129,78).

    assign tt-e-commerce.informtec[68] =
                          substring(prodecom.especiftec,5207,78).

    assign tt-e-commerce.informtec[69] =
                          substring(prodecom.especiftec,5285,78).

    assign tt-e-commerce.informtec[70] =
                          substring(prodecom.especiftec,5363,78).

    assign tt-e-commerce.informtec[71] =
                          substring(prodecom.especiftec,5441,78).

    assign tt-e-commerce.informtec[72] =
                          substring(prodecom.especiftec,5519,78).

    assign tt-e-commerce.informtec[73] =
                          substring(prodecom.especiftec,5597,78).

    assign tt-e-commerce.informtec[74] =
                          substring(prodecom.especiftec,5675,78).

    assign tt-e-commerce.informtec[75] =
                          substring(prodecom.especiftec,5753,78).

    assign tt-e-commerce.informtec[76] =
                          substring(prodecom.especiftec,5831,78).

    assign tt-e-commerce.informtec[77] =
                          substring(prodecom.especiftec,5909,78).

    assign tt-e-commerce.informtec[78] =
                          substring(prodecom.especiftec,5987,78).

    assign tt-e-commerce.informtec[79] =
                          substring(prodecom.especiftec,6065,78).

    assign tt-e-commerce.informtec[80] =
                          substring(prodecom.especiftec,6143,78).

    assign tt-e-commerce.informtec[81] =
                          substring(prodecom.especiftec,6221,78).

    assign tt-e-commerce.informtec[82] =
                          substring(prodecom.especiftec,6299,78).

    assign tt-e-commerce.informtec[83] =
                          substring(prodecom.especiftec,6377,78).

    assign tt-e-commerce.informtec[84] =
                          substring(prodecom.especiftec,6455,78).

    assign tt-e-commerce.informtec[85] =
                          substring(prodecom.especiftec,6533,78).

    assign tt-e-commerce.informtec[86] =
                          substring(prodecom.especiftec,6611,78).

    assign tt-e-commerce.informtec[87] =
                          substring(prodecom.especiftec,6689,78).

    assign tt-e-commerce.informtec[88] =
                          substring(prodecom.especiftec,6767,78).

    assign tt-e-commerce.informtec[89] =
                          substring(prodecom.especiftec,6845,78).

    assign tt-e-commerce.informtec[90] =
                          substring(prodecom.especiftec,6923,78).

    assign tt-e-commerce.informtec[91] =
                          substring(prodecom.especiftec,7001,78).

    assign tt-e-commerce.informtec[92] =
                          substring(prodecom.especiftec,7079,78).

    assign tt-e-commerce.informtec[93] =
                          substring(prodecom.especiftec,7157,78).

    assign tt-e-commerce.informtec[94] =
                          substring(prodecom.especiftec,7235,78).

    assign tt-e-commerce.informtec[95] =
                          substring(prodecom.especiftec,7313,78).

    assign tt-e-commerce.informtec[96] =
                          substring(prodecom.especiftec,7391,78).

    assign tt-e-commerce.informtec[97] =
                          substring(prodecom.especiftec,7469,78).

    assign tt-e-commerce.informtec[98] =
                          substring(prodecom.especiftec,7547,78).

    assign tt-e-commerce.informtec[99] =
                          substring(prodecom.especiftec,7625,78).

    assign tt-e-commerce.informtec[100] =
                          substring(prodecom.especiftec,7781,78).
end.

if trim(tt-e-commerce.nome[1]) = ""
then
    assign tt-e-commerce.nome[1] = substring(produ.pronom,1,55).

if trim(tt-e-commerce.marca) = ""
then do:
    find first fabri where fabri.fabcod = produ.fabcod NO-LOCK no-error.
    if available fabri
    then
        assign tt-e-commerce.marca = fabri.fabfant.
end.

disp esqcom3 with frame f-E-commerce-aux.

bloco_principal:
do on error undo, retry:

    color display normal
    esqcom3[1]
    with frame f-E-commerce-aux.

    color display normal
    esqcom3[2]
    with frame f-E-commerce-aux.

    hide frame f-desccom.

    update tt-e-commerce.exporta colon 19 go-on("TAB" "end-error")
                            with frame f-E-commerce.

    if keyfunction(lastkey) = "TAB"
    then do:

        assign vindex = 0.

        choose field esqcom3 with frame
                                f-E-commerce-aux.
                                
        vindex = frame-index.
        
        do:
        
            if vindex = 1
            then do:
                                
                update text(tt-e-commerce.informtec) go-on("TAB")
                             with frame f-Ecom-inftec.
                        
            end.
        
            if vindex = 2
            then do:
                
                update text(tt-e-commerce.desccom) go-on("TAB")
                               with frame f-desccom.            
                               
            end.                    
                                
        end.
        
    end.

    view frame f-E-commerce-aux.
    
    hide frame f-Ecom-inftec.

    pause 0.

    if keyfunction(lastkey) = "end-error"
    then do:
         
        if tt-e-commerce.exporta
        then do:

            if tt-e-commerce.nome[1]          = ""
                or tt-e-commerce.desccom[1]   = ""
                or tt-e-commerce.peso         = 0
                or tt-e-commerce.altura       = 0
                or tt-e-commerce.largura      = 0
                or tt-e-commerce.profund      = 0
             /* or tt-e-commerce.voltagem     = 0 */
                or tt-e-commerce.marca        = ""
                or tt-e-commerce.estmin       = 0
                or tt-e-commerce.informtec[1] = ""
                or tt-e-commerce.clasecom     = 0
                or tt-e-commerce.codcatfiskpl = 0
            then do:

                run mensagem.p (input-output vlog-resp,
                                input " Existem campos obrigatós que nã" +
                                      "  foram preenchidos.  " +
                                      "                     " +
                                      " Deseja Sair sem salvar? ",
                                input "",
                                input " Sim ",
                                input " Nao ").
                                     
                if vlog-resp then do:
                                             
                    return "end-error".

                end.

            end.
            else do:
            
                leave bloco_principal.

            end.
            
        end.
        else leave bloco_principal.

    end.

    color display normal
    esqcom3[1]
    with frame f-E-commerce-aux.

    update text(tt-e-commerce.nome)
           tt-e-commerce.peso        colon 19
           tt-e-commerce.altura      colon 45
           tt-e-commerce.largura     colon 19
           tt-e-commerce.profund     colon 45
           tt-e-commerce.voltagem    colon 19
           tt-e-commerce.marca       colon 45
           tt-e-commerce.estmin      colon 19
                 with frame f-E-commerce.
    
    do on error undo, retry:       
        update tt-e-commerce.clasecom    colon 45
                     with frame f-E-commerce.

        if tt-e-commerce.clasecom > 0
        then do:
    
            if not can-find(first bf1-clasecom
                        where bf1-clasecom.clacod = tt-e-commerce.clasecom)
            then do:
            
                message "Classe informada invalida.".
                undo, retry.
                        
                        
            end.                
    
            if can-find (first bf1-clasecom
                         where bf1-clasecom.clacod = tt-e-commerce.clasecom
                           and bf1-clasecom.clatipo2 = "Superior")
            then do:
                           
        message "Classe superior selecionada. Por favor selecione outra Classe".
                undo, retry.
                              
                
            end.
          
            if can-find(first bf2-clasecom
                        where bf2-clasecom.clasup = tt-e-commerce.clasecom)
            then do:
                        
                message "Esta Classe possui outras Classes abaixo dela"
                        " e n�o pode ser selecionada.".        
                        
                undo, retry.
                        
            end.                
            
        end.
    
    end.

    update tt-e-commerce.procodcompl colon 19
           tt-e-commerce.ofespec     colon 45
           tt-e-commerce.fretegratis colon 19
           tt-e-commerce.codcatfiskpl colon 45
                            with frame f-E-commerce.
                                                  

    if tt-e-commerce.exporta
    then do:
                
        if tt-e-commerce.nome[1]          = ""
            or tt-e-commerce.desccom[1]   = ""
            or tt-e-commerce.peso         = 0
            or tt-e-commerce.altura       = 0
            or tt-e-commerce.largura      = 0
            or tt-e-commerce.profund      = 0
         /* or tt-e-commerce.voltagem     = 0 */
            or tt-e-commerce.marca        = ""
            or tt-e-commerce.estmin       = 0
            or tt-e-commerce.informtec[1] = ""
            or tt-e-commerce.clasecom     = 0
            or tt-e-commerce.codcatfiskpl = 0
        then do:
            
            message "Todos os campos tem preenchimento obrigatorio.".
            undo, retry.

        end.

    end.

end.

release produaux.
find first produaux where produaux.procod = produ.procod
                      and produaux.nome_campo = "exporta-e-com" exclusive-lock no-error.

if available produaux
then do:

    if tt-e-commerce.exporta
    then assign produaux.Valor_Campo = "yes".
    else assign produaux.Valor_Campo = "no".

end.

if tt-e-commerce.nome[1]          <> ""
    or tt-e-commerce.desccom[1]   <> ""
    or tt-e-commerce.peso          > 0
    or tt-e-commerce.altura        > 0
    or tt-e-commerce.largura       > 0
    or tt-e-commerce.profund       > 0
    or tt-e-commerce.fretegratis   = yes
    or tt-e-commerce.voltagem      > 0
    or tt-e-commerce.marca        <> ""
    or tt-e-commerce.estmin        > 0
    or tt-e-commerce.informtec[1] <> ""
    or tt-e-commerce.clasecom      > 0
    or tt-e-commerce.ofespec       = yes
    or tt-e-commerce.procodcompl   > 0
    or tt-e-commerce.codcatfiskpl  > 0
then do:

    release prodecom.
    find first prodecom where prodecom.procod = produ.procod
                                  exclusive-lock no-error.

    if not available prodecom
    then do:
        create prodecom.
        assign prodecom.procod = produ.procod.
    end.

    if available prodecom
    then do:

        assign prodecom.nome     =
                    string(tt-e-commerce.nome[1],"x(55)")
                  + string(tt-e-commerce.nome[2],"x(55)")

               prodecom.desccom  =
                    string(tt-e-commerce.desccom[1],"x(58)")
                  + string(tt-e-commerce.desccom[2],"x(78)")
                  + string(tt-e-commerce.desccom[3],"x(78)")
                  + string(tt-e-commerce.desccom[4],"x(78)")
                  + string(tt-e-commerce.desccom[5],"x(78)")
                  + string(tt-e-commerce.desccom[6],"x(78)")
                  + string(tt-e-commerce.desccom[7],"x(78)")

               prodecom.peso        = tt-e-commerce.peso
               prodecom.altura      = tt-e-commerce.altura
               prodecom.largura     = tt-e-commerce.largura
               prodecom.profund     = tt-e-commerce.profund
               prodecom.fretegratis = tt-e-commerce.fretegratis
               prodecom.voltagem    = tt-e-commerce.voltagem
               prodecom.marca       = tt-e-commerce.marca
               prodecom.estmin      = tt-e-commerce.estmin
               prodecom.clacod      = tt-e-commerce.clasecom
               prodecom.ofespec     = tt-e-commerce.ofespec    
               prodecom.codcatfiskpl = tt-e-commerce.codcatfiskpl
               prodecom.procodcompl = tt-e-commerce.procodcompl.

        assign prodecom.especiftec = string(tt-e-commerce.informtec[1],"x(58)")
                                   + string(tt-e-commerce.informtec[2],"x(78)")
                                   + string(tt-e-commerce.informtec[3],"x(78)")
                                   + string(tt-e-commerce.informtec[4],"x(78)")
                                   + string(tt-e-commerce.informtec[5],"x(78)")
                                   + string(tt-e-commerce.informtec[6],"x(78)")
                                   + string(tt-e-commerce.informtec[7],"x(78)")
                                   + string(tt-e-commerce.informtec[8],"x(78)")
                                   + string(tt-e-commerce.informtec[9],"x(78)")
                                   + string(tt-e-commerce.informtec[10],"x(78)")
                                   + string(tt-e-commerce.informtec[11],"x(78)")
                                   + string(tt-e-commerce.informtec[12],"x(78)")
                                   + string(tt-e-commerce.informtec[13],"x(78)")
                                   + string(tt-e-commerce.informtec[14],"x(78)")
                                   + string(tt-e-commerce.informtec[15],"x(78)")
                                   + string(tt-e-commerce.informtec[16],"x(78)")
                                   + string(tt-e-commerce.informtec[17],"x(78)")
                                   + string(tt-e-commerce.informtec[18],"x(78)")
                                   + string(tt-e-commerce.informtec[19],"x(78)")
                                   + string(tt-e-commerce.informtec[20],"x(78)")
                                   + string(tt-e-commerce.informtec[21],"x(78)")
                                   + string(tt-e-commerce.informtec[22],"x(78)")
                                   + string(tt-e-commerce.informtec[23],"x(78)")
                                   + string(tt-e-commerce.informtec[24],"x(78)")
                                   + string(tt-e-commerce.informtec[25],"x(78)")
                                   + string(tt-e-commerce.informtec[26],"x(78)")
                                   + string(tt-e-commerce.informtec[27],"x(78)")
                                   + string(tt-e-commerce.informtec[28],"x(78)")
                                   + string(tt-e-commerce.informtec[29],"x(78)")
                                   + string(tt-e-commerce.informtec[30],"x(78)")
                                   + string(tt-e-commerce.informtec[31],"x(78)")
                                   + string(tt-e-commerce.informtec[32],"x(78)")
                                   + string(tt-e-commerce.informtec[33],"x(78)")
                                   + string(tt-e-commerce.informtec[34],"x(78)")
                                   + string(tt-e-commerce.informtec[35],"x(78)")
                                   + string(tt-e-commerce.informtec[36],"x(78)")
                                   + string(tt-e-commerce.informtec[37],"x(78)")
                                   + string(tt-e-commerce.informtec[38],"x(78)")
                                   + string(tt-e-commerce.informtec[39],"x(78)")
                                   + string(tt-e-commerce.informtec[40],"x(78)")
                                   + string(tt-e-commerce.informtec[41],"x(78)")
                                   + string(tt-e-commerce.informtec[42],"x(78)")
                                   + string(tt-e-commerce.informtec[43],"x(78)")
                                   + string(tt-e-commerce.informtec[44],"x(78)")
                                   + string(tt-e-commerce.informtec[45],"x(78)")
                                   + string(tt-e-commerce.informtec[46],"x(78)")
                                   + string(tt-e-commerce.informtec[47],"x(78)")
                                   + string(tt-e-commerce.informtec[48],"x(78)")
                                   + string(tt-e-commerce.informtec[49],"x(78)")
                                   + string(tt-e-commerce.informtec[50],"x(78)")
                                   + string(tt-e-commerce.informtec[51],"x(78)")
                                   + string(tt-e-commerce.informtec[52],"x(78)")
                                   + string(tt-e-commerce.informtec[53],"x(78)")
                                   + string(tt-e-commerce.informtec[54],"x(78)")
                                   + string(tt-e-commerce.informtec[55],"x(78)")
                                   + string(tt-e-commerce.informtec[56],"x(78)")
                                   + string(tt-e-commerce.informtec[57],"x(78)")
                                   + string(tt-e-commerce.informtec[58],"x(78)")
                                   + string(tt-e-commerce.informtec[59],"x(78)")
                                   + string(tt-e-commerce.informtec[60],"x(78)")
                                   + string(tt-e-commerce.informtec[61],"x(78)")
                                   + string(tt-e-commerce.informtec[62],"x(78)")
                                   + string(tt-e-commerce.informtec[63],"x(78)")
                                   + string(tt-e-commerce.informtec[64],"x(78)")
                                   + string(tt-e-commerce.informtec[65],"x(78)")
                                   + string(tt-e-commerce.informtec[66],"x(78)")
                                   + string(tt-e-commerce.informtec[67],"x(78)")
                                   + string(tt-e-commerce.informtec[68],"x(78)")
                                   + string(tt-e-commerce.informtec[69],"x(78)")
                                   + string(tt-e-commerce.informtec[70],"x(78)")
                                   + string(tt-e-commerce.informtec[71],"x(78)")
                                   + string(tt-e-commerce.informtec[72],"x(78)")
                                   + string(tt-e-commerce.informtec[73],"x(78)")
                                   + string(tt-e-commerce.informtec[74],"x(78)")
                                   + string(tt-e-commerce.informtec[75],"x(78)")
                                   + string(tt-e-commerce.informtec[76],"x(78)")
                                   + string(tt-e-commerce.informtec[77],"x(78)")
                                   + string(tt-e-commerce.informtec[78],"x(78)")
                                   + string(tt-e-commerce.informtec[79],"x(78)")
                                   + string(tt-e-commerce.informtec[80],"x(78)")
                                   + string(tt-e-commerce.informtec[81],"x(78)")
                                   + string(tt-e-commerce.informtec[82],"x(78)")
                                   + string(tt-e-commerce.informtec[83],"x(78)")
                                   + string(tt-e-commerce.informtec[84],"x(78)")
                                   + string(tt-e-commerce.informtec[85],"x(78)")
                                   + string(tt-e-commerce.informtec[86],"x(78)")
                                   + string(tt-e-commerce.informtec[87],"x(78)")
                                   + string(tt-e-commerce.informtec[88],"x(78)")
                                   + string(tt-e-commerce.informtec[89],"x(78)")
                                   + string(tt-e-commerce.informtec[90],"x(78)")
                                   + string(tt-e-commerce.informtec[91],"x(78)")
                                   + string(tt-e-commerce.informtec[92],"x(78)")
                                   + string(tt-e-commerce.informtec[93],"x(78)")
                                   + string(tt-e-commerce.informtec[94],"x(78)")
                                   + string(tt-e-commerce.informtec[95],"x(78)")
                                   + string(tt-e-commerce.informtec[96],"x(78)")
                                   + string(tt-e-commerce.informtec[97],"x(78)")
                                   + string(tt-e-commerce.informtec[98],"x(78)")
                                   + string(tt-e-commerce.informtec[99],"x(78)")
                                + string(tt-e-commerce.informtec[100],"x(78)").
                                
        find first bf1-produ where bf1-produ.procod = prodecom.procod                                                 exclusive-lock.
                                                    
        assign bf1-produ.datexp = today.

    end.

end.



