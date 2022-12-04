gen contractb=1 if contract==1|contract==3|contract==65|contract==100|contract==139|contract==189|contract==200|contract==239|contract==289
replace contractb=2 if contract==8|contract==9|contract==11|contract==12|contract==13|contract==20|contract==23|contract==28|contract==29|contract==30|contract==31|contract==32|contract==33|contract==35|contract==38|contract==40|contract==41|contract==42|contract==43|contract==44|contract==45|contract==46|contract==47|contract==48|contract==49|contract==50|contract==51|contract==52|contract==59|contract==60|contract==61|contract==62|contract==63|contract==69|contract==70|contract==71|contract==80|contract==81|contract==86|contract==88|contract==89|contract==90|contract==91|contract==98|contract==101|contract==102|contract==109|contract==130|contract==131|contract==141|contract==150|contract==151|contract==152|contract==153|contract==154|contract==155|contract==156|contract==157|contract==186|contract==209|contract==230|contract==231|contract==241|contract==250|contract==251|contract==252|contract==253|contract==254|contract==255|contract==256|contract==257
replace contractb=3 if contract==18|contract==181|contract==182|contract==183|contract==184|contract==185|contract==300|contract==309|contract==330|contract==331|contract==339|contract==350|contract==351|contract==352|contract==353|contract==354|contract==355|contract==356|contract==357|contract==389
replace contractb=4 if contract==0&(type1plant==901|type1plant==910)
replace contractb=4 if contract==0&(type1plant==902)
replace contractb=5 if contract==2|contract==4|contract==5|contract==16|contract==17|contract==22|contract==24|contract==64|contract==72|contract==73|contract==74|contract==75|contract==76|contract==82|contract==83|contract==84|contract==92|contract==93|contract==94|contract==95|contract==408|contract==410|contract==418|contract==500|contract==508|contract==510|contract==518
replace contractb=6 if contract==14|contract==401|contract==501
replace contractb=7 if contract==15|contract==402|contract==502
replace contractb=8 if contract==6|contract==7|contract==26|contract==27|contract==36|contract==37|contract==39|contract==53|contract==54|contract==55|contract==56|contract==57|contract==58|contract==66|contract==67|contract==68|contract==77|contract==78|contract==79|contract==85|contract==87|contract==96|contract==97|contract==420|contract==421|contract==430|contract==431|contract==403|contract==452|contract==503|contract==520|contract==530|contract==531
replace contractb=8 if contract==0&(type1plant==87)
replace contractb=9 if contract==10|contract==25|contract==34|contract==441|contract==540|contract==541
replace contractb=10 if contract==450|contract==451|contract==457|contract==550|contract==551|contract==552|contract==557|contract==990
replace contractb=10 if contract==0&(type1plant==932)

label define contractlabel 1"indefinido ordinario" 2"fomento empleo" 3"fijo discontinuo" 4"funcionarios (incluye interinos)" /*
*/ 5"duracion determinada" 6"obra o servicio" 7"circunstancia de produccion" 8"formacion" 9"relevo" 10"otros temporales"
label values contractb contractlabel
