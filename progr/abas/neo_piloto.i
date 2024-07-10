/** {abas/neo_piloto.i} **/
/*
PILOTO
18/06: Lojas piloto 1 (25, 28, 41, 42, 46, 55, 61, 98, 115 e 134)
24/06: Lojas maiores (8, 13, 20, 38, 52, 57, 60, 101, 108, 113 e 164)
01/07: Demais lojas
*/
def var wfilvirada  as date .
wfilvirada  = 08/15/2019.

def temp-table ttpiloto no-undo
    field etbcod as int
    field dtini  as date
    index idx is unique primary etbcod asc.
    
    for each ttpiloto. delete ttpiloto. end.
    
    create ttpiloto. ttpiloto.etbcod = 189. ttpiloto.dtini = 06/14/2019.

    create ttpiloto. ttpiloto.etbcod =  25. ttpiloto.dtini = 06/18/2019.
    create ttpiloto. ttpiloto.etbcod =  28. ttpiloto.dtini = 06/18/2019.
    create ttpiloto. ttpiloto.etbcod =  41. ttpiloto.dtini = 06/18/2019.
    create ttpiloto. ttpiloto.etbcod =  42. ttpiloto.dtini = 06/18/2019.
    create ttpiloto. ttpiloto.etbcod =  46. ttpiloto.dtini = 06/18/2019.
    create ttpiloto. ttpiloto.etbcod =  55. ttpiloto.dtini = 06/18/2019.
    create ttpiloto. ttpiloto.etbcod =  61. ttpiloto.dtini = 06/18/2019.
    create ttpiloto. ttpiloto.etbcod =  98. ttpiloto.dtini = 06/18/2019.
    create ttpiloto. ttpiloto.etbcod = 115. ttpiloto.dtini = 06/18/2019.
    create ttpiloto. ttpiloto.etbcod = 134. ttpiloto.dtini = 06/18/2019.
    
    create ttpiloto. ttpiloto.etbcod = 116. ttpiloto.dtini = 06/26/2019.
    create ttpiloto. ttpiloto.etbcod =  11. ttpiloto.dtini = 06/26/2019.
    create ttpiloto. ttpiloto.etbcod = 131. ttpiloto.dtini = 06/26/2019.
    create ttpiloto. ttpiloto.etbcod = 126. ttpiloto.dtini = 06/26/2019.
    create ttpiloto. ttpiloto.etbcod = 105. ttpiloto.dtini = 06/26/2019.
    create ttpiloto. ttpiloto.etbcod =  83. ttpiloto.dtini = 06/26/2019.
    create ttpiloto. ttpiloto.etbcod =  59. ttpiloto.dtini = 06/26/2019.
    create ttpiloto. ttpiloto.etbcod =  65. ttpiloto.dtini = 06/26/2019.
    create ttpiloto. ttpiloto.etbcod =  48. ttpiloto.dtini = 06/26/2019.
    create ttpiloto. ttpiloto.etbcod =  45. ttpiloto.dtini = 06/26/2019.
    create ttpiloto. ttpiloto.etbcod =  40. ttpiloto.dtini = 06/26/2019.
    create ttpiloto. ttpiloto.etbcod =   1. ttpiloto.dtini = 06/26/2019.
    create ttpiloto. ttpiloto.etbcod =   7. ttpiloto.dtini = 06/26/2019.
    create ttpiloto. ttpiloto.etbcod =  82. ttpiloto.dtini = 06/26/2019.


    create ttpiloto. ttpiloto.etbcod = 150. ttpiloto.dtini = 07/02/2019.
    create ttpiloto. ttpiloto.etbcod = 139. ttpiloto.dtini = 07/02/2019.
    create ttpiloto. ttpiloto.etbcod = 141. ttpiloto.dtini = 07/02/2019.
    create ttpiloto. ttpiloto.etbcod =  10. ttpiloto.dtini = 07/02/2019.
    create ttpiloto. ttpiloto.etbcod = 306. ttpiloto.dtini = 07/02/2019.
    create ttpiloto. ttpiloto.etbcod =  39. ttpiloto.dtini = 07/02/2019.
    create ttpiloto. ttpiloto.etbcod =  72. ttpiloto.dtini = 07/02/2019.
    create ttpiloto. ttpiloto.etbcod =   5. ttpiloto.dtini = 07/02/2019.
    create ttpiloto. ttpiloto.etbcod =  37. ttpiloto.dtini = 07/02/2019.

    create ttpiloto. ttpiloto.etbcod =  97. ttpiloto.dtini = 07/03/2019.
    create ttpiloto. ttpiloto.etbcod = 100. ttpiloto.dtini = 07/03/2019.
    create ttpiloto. ttpiloto.etbcod =  66. ttpiloto.dtini = 07/03/2019.
    create ttpiloto. ttpiloto.etbcod =  89. ttpiloto.dtini = 07/03/2019.
    create ttpiloto. ttpiloto.etbcod =  68. ttpiloto.dtini = 07/03/2019.
    create ttpiloto. ttpiloto.etbcod =  64. ttpiloto.dtini = 07/03/2019.
    
    create ttpiloto. ttpiloto.etbcod =  80. ttpiloto.dtini = 07/08/2019.
    create ttpiloto. ttpiloto.etbcod = 103. ttpiloto.dtini = 07/08/2019.
    create ttpiloto. ttpiloto.etbcod = 143. ttpiloto.dtini = 07/08/2019.
    create ttpiloto. ttpiloto.etbcod = 104. ttpiloto.dtini = 07/08/2019.
    create ttpiloto. ttpiloto.etbcod = 138. ttpiloto.dtini = 07/08/2019.
   
    create ttpiloto. ttpiloto.etbcod =   6. ttpiloto.dtini = 07/09/2019.
    create ttpiloto. ttpiloto.etbcod =  27. ttpiloto.dtini = 07/09/2019.
    create ttpiloto. ttpiloto.etbcod = 137. ttpiloto.dtini = 07/09/2019.
    create ttpiloto. ttpiloto.etbcod = 110. ttpiloto.dtini = 07/09/2019.
    create ttpiloto. ttpiloto.etbcod =  81. ttpiloto.dtini = 07/09/2019.
    create ttpiloto. ttpiloto.etbcod = 309. ttpiloto.dtini = 07/09/2019.

    create ttpiloto. ttpiloto.etbcod = 164. ttpiloto.dtini = 07/10/2019.
    create ttpiloto. ttpiloto.etbcod =  38. ttpiloto.dtini = 07/10/2019.
    create ttpiloto. ttpiloto.etbcod =  70. ttpiloto.dtini = 07/10/2019.
    create ttpiloto. ttpiloto.etbcod =  44. ttpiloto.dtini = 07/10/2019.
    create ttpiloto. ttpiloto.etbcod =  47. ttpiloto.dtini = 07/10/2019.
    
    create ttpiloto. ttpiloto.etbcod = 112. ttpiloto.dtini = 07/15/2019.
    create ttpiloto. ttpiloto.etbcod = 111. ttpiloto.dtini = 07/15/2019.
    create ttpiloto. ttpiloto.etbcod =  93. ttpiloto.dtini = 07/15/2019.
    create ttpiloto. ttpiloto.etbcod = 117. ttpiloto.dtini = 07/15/2019.
    create ttpiloto. ttpiloto.etbcod =  43. ttpiloto.dtini = 07/15/2019.
    create ttpiloto. ttpiloto.etbcod = 124. ttpiloto.dtini = 07/15/2019.
    create ttpiloto. ttpiloto.etbcod =  12. ttpiloto.dtini = 07/15/2019.
    create ttpiloto. ttpiloto.etbcod =  74. ttpiloto.dtini = 07/15/2019.
    create ttpiloto. ttpiloto.etbcod =  56. ttpiloto.dtini = 07/15/2019.

    create ttpiloto. ttpiloto.etbcod =  13. ttpiloto.dtini = 07/16/2019.
    create ttpiloto. ttpiloto.etbcod =   8. ttpiloto.dtini = 07/16/2019.
    create ttpiloto. ttpiloto.etbcod =  20. ttpiloto.dtini = 07/16/2019.
    create ttpiloto. ttpiloto.etbcod =  60. ttpiloto.dtini = 07/16/2019.
    create ttpiloto. ttpiloto.etbcod =  57. ttpiloto.dtini = 07/16/2019.
    create ttpiloto. ttpiloto.etbcod =  33. ttpiloto.dtini = 07/16/2019.
    create ttpiloto. ttpiloto.etbcod =  85. ttpiloto.dtini = 07/16/2019.
    create ttpiloto. ttpiloto.etbcod =  91. ttpiloto.dtini = 07/16/2019.
    create ttpiloto. ttpiloto.etbcod =  34. ttpiloto.dtini = 07/16/2019.
    create ttpiloto. ttpiloto.etbcod =  15. ttpiloto.dtini = 07/16/2019.

    create ttpiloto. ttpiloto.etbcod = 113. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod = 108. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod =  52. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod = 119. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod =  54. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod = 129. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod =  35. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod =   9. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod =  14. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod =   2. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod =   4. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod =  67. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod =  32. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod =  26. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod = 136. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod =  76. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod =  92. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod =  96. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod = 162. ttpiloto.dtini = 07/17/2019.
    create ttpiloto. ttpiloto.etbcod = 140. ttpiloto.dtini = 07/17/2019.

    create ttpiloto. ttpiloto.etbcod =  69. ttpiloto.dtini = 07/18/2019.
    create ttpiloto. ttpiloto.etbcod =  73. ttpiloto.dtini = 07/18/2019.
    create ttpiloto. ttpiloto.etbcod =  17. ttpiloto.dtini = 07/18/2019.
    create ttpiloto. ttpiloto.etbcod =  63. ttpiloto.dtini = 07/18/2019.
    create ttpiloto. ttpiloto.etbcod =  79. ttpiloto.dtini = 07/18/2019.
    create ttpiloto. ttpiloto.etbcod = 121. ttpiloto.dtini = 07/18/2019.
    create ttpiloto. ttpiloto.etbcod =  99. ttpiloto.dtini = 07/18/2019.
    create ttpiloto. ttpiloto.etbcod =  21. ttpiloto.dtini = 07/18/2019.
    create ttpiloto. ttpiloto.etbcod =  50. ttpiloto.dtini = 07/18/2019.

    create ttpiloto. ttpiloto.etbcod =  87. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod =  49. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod = 106. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod =  51. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod =  29. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod = 127. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod =  75. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod =  53. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod =  62. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod = 163. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod =  71. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod = 135. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod =  24. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod = 125. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod = 142. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod = 160. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod = 161. ttpiloto.dtini = 07/22/2019.
    create ttpiloto. ttpiloto.etbcod =  78. ttpiloto.dtini = 07/22/2019.


    create ttpiloto. ttpiloto.etbcod = 101. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod = 301. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod = 303. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod = 304. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod = 305. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod = 122. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod = 133. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod =  86. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod =  94. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod =  84. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod =  77. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod = 114. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod = 144. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod = 102. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod = 130. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod = 120. ttpiloto.dtini = 07/23/2019.
    create ttpiloto. ttpiloto.etbcod = 109. ttpiloto.dtini = 07/23/2019.


    create ttpiloto. ttpiloto.etbcod =  88. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod = 132. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod = 123. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod =  36. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod =  58. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod = 165. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod =  30. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod =  31. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod = 118. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod =  95. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod =  90. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod =  18. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod =   3. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod =  19. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod =  23. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod =  16. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod = 200. ttpiloto.dtini = 07/25/2019.
    create ttpiloto. ttpiloto.etbcod = 145. ttpiloto.dtini = 07/25/2019.


/** teste *
def var vj as date.

for each estab where estab.etbcod = 8 no-lock.
    do vj = today to 07/30/2019.
        find first ttpiloto where ttpiloto.etbcod = estab.etbcod and
                                  ttpiloto.dtini  <= vj
            no-error.
        hide message no-pause.
        message "Lj" estab.etbcod "Hoje" vj string(avail ttpiloto,"Piloto/Nao eh Piloto").
        pause.
        
    end.
end.                                                          
    
* */

    
    
    
