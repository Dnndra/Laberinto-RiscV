.global programa
.data
input:   
  .string "mapa.txt"
output:
  .string "solucion.txt"
error:
  .string "error al cargar archivo"
cols:
  .byte 0
rows:
  .byte 0
posEntrada:
  .byte 0
direccionEntrada:
  .byte 0
posicionSalida:
  .byte 0
direccionSalida:
  .byte 0
direccion1:
  .byte 0
posicionX:
  .byte 0
posicionY:
  .byte 0
matriz:
  .string "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
msgExito:
  .string "exito?"
msgError:
  .string "error en el mapa, no hay salida?"
kmino:
  .string ""
  .text
programa:
#Inicio del segmento de codigo
#INICIAN MACROS 
.macro limpiar() #este macro limpia los registros t mas utilizados
add t0, zero, zero 
add t1, zero, zero 
add t2, zero, zero
add t3, zero, zero
add t4, zero, zero
.end_macro	
.macro limpiarA() #este macro limpia los registros a mas utilizados
add a0, zero, zero
add a1, zero, zero 
add a2, zero, zero
add a3, zero, zero
add a4, zero, zero
add a5, zero, zero
add a6, zero, zero
add a7, zero, zero
.end_macro	
.macro posicionEnArray() #este macro obtiene la posicion en el array del mapeo lexico-grafico
li t1,10
addi t3,t3,1 
div t4,t3,t1 
add t5,a1,a2 
beq t4,t1,centena1 #validacion para matriz 10x10
mul t6,t4,t1
sub t0,t3,t6 #realizando reajuste para calcular unidades
addi t4,t4,48 
sb t4,0(t5)
addi a2,a2,1
addi t0,t0,48 #ajuste para pasar de numero a char
sb t0,1(t5) 
addi a2,a2,1
j salir1
centena1:
li t1,'1' 
sb t1,0(t5) 
li t1,'0' 
addi a2,a2,1
sb t1,1(t5) 
addi a2,a2,1
sb t1,2(t5) 
addi a2,a2,1
salir1:
.end_macro 

.macro verificarPared() #este macro verifica la pared 
limpiar()
#aplicando la forrrrmula
mul t6,a4,a6 #t6 = posicionY * rows
mv t3,t6 #suma a t3 el offset por posicionY
add t3,t3,a3 #suma a t3 el offset por pos x
posicionEnArray()
addi t3,t3,-1 #resta 1 para regresar a posicion despues de posicionEnArray
add t6,a0,t3 #obtiene la direccion de la pos exacta
lb t6,0(t6) #guardar en t6 el valor de la pared
addi t6,t6,-48
limpiar()
#existeD:
li t5,8
blt t6,t5,existeC
sub t6,t6,t5
li t1,1 #t1 pared D
existeC:
li t5,4
blt t6,t5,existeB
sub t6,t6,t5
li t2,1 #t2 pared C
existeB:
li t5,2
blt t6,t5,existeA
sub t6,t6,t5
li t3,1 #t3 pared B
existeA:
li t5,1
blt t6,t5,compM
li t4,1 #t4 pared A
compM: #comprobar que direccion se esta viendo
li t6,'A'
beq t6,a5,muroA
li t6,'B'
beq t6,a5,muroB
li t6,'C'
beq t6,a5,muroC
li t6,'D'
beq t6,a5,muroD
j muroE 
muroA:
	mv t0,t4 #mover a t0 el valor de la pared
	j muroV
muroB:
	mv t0,t3
	j muroV
muroC:
	mv t0,t2
	j muroV
muroD:
	mv t0,t1
	j muroV
muroE:
	#direccion no valida
	j salirVerificarPared
muroV:
	add t5,a1,a2
	addi a2,a2,1
	sb a5,0(t5)
	addi a2,a2,1
	addi t5,t5,1
	li t3,45
	sb t3,0(t5)
salirVerificarPared:
.end_macro 

.macro leftShift()
limpiar()
la t1,direccion1 #obtiene variable que guarda la direccion
#comprobar que direccion esta viendo
li t6,'A'
beq t6,a5,paredA1
li t6,'B'
beq t6,a5,paredB1
li t6,'C'
beq t6,a5,paredC1
li t6,'D'
beq t6,a5,paredD1
j errorLeftShift
#valida las direcciones y asigna la direccion correspondiente al giro
#A->D->C->B->A loop XD
paredA1:
	li t6,'D'
	sb t6,0(t1)
	mv a5,t6
	j salirLeftShift
paredB1:
	li t6,'A'
	sb t6,0(t1)
	mv a5,t6
	j salirLeftShift
paredC1:
	li t6,'B'
	sb t6,0(t1)
	mv a5,t6
	j salirLeftShift
paredD1:
	li t6,'C'
	sb t6,0(t1)
	mv a5,t6
	j salirLeftShift
errorLeftShift:
	#direccion no valida
	j salirLeftShift
salirLeftShift:
.end_macro 

.macro rShift()
limpiar()
la t1,direccion1 #obtiene variable que guarda la direccion
#comprobar que direccion se esta viendo
li t6,'A'
beq t6,a5,paredA2
li t6,'B'
beq t6,a5,paredB2
li t6,'C'
beq t6,a5,paredC2
li t6,'D'
beq t6,a5,paredD2
j errorRightShift
paredA2:
	li t6,'B'
	sb t6,0(t1) 
	mv a5,t6 
	j salirRightShift 
paredB2:
	li t6,'C' 
	sb t6,0(t1) 
	mv a5,t6 
	j salirRightShift
paredC2:
	li t6,'D' 
	sb t6,0(t1) 
	mv a5,t6 
	j salirRightShift
paredD2:
	li t6,'A' 
	sb t6,0(t1) 
	mv a5,t6 
	j salirRightShift
errorRightShift:
	#direccion no valida
	j salirRightShift
salirRightShift:
.end_macro 
.macro getASCII() #Obtiene el valor ascii de un elemento en el string del output lo guarda y avanza la posicion
	getCharFromNumber(t0) #obtiene el caracter en la posicion del kmino
	mv a2,t4
	addi t0, t0, 1
	getCharFromNumber(t0)
	mv a3,t4
	addi a2,a2,-48
	addi a3,a3,-48
	li a5,1
	bne a2,a5,yesDec #validar las posibilidades de que valga 100
	bnez a3,yesDec
	addi t0, t0, 1
	getCharFromNumber(t0)
	mv a5,t4
	addi a5,a5,-48
	bnez a5,notCent #Si el 3 digito no es un 0, entonces hay posibilidad de valor 100
	addi a6,zero,100 #Si si es 0, entonces se trataba del numero 100
	j salirrn
notCent:
	addi t0,t0,-1 #revierte el cambio de posicion por posible valor 100
yesDec: #Asignar el valor de 2 digitos a a6
	li a5,10
	mul a4,a5,a2 #se obtienen los valores y se agregan al resultaod
	add a6,zero,a4
	add a6,a6,a3
salirrn:
.end_macro
.macro movimientos()
limpiar()
add t5, zero, zero
add t6, zero, zero
#comprobar que direccion esta viendo
li t0,'A'
beq t0,a5,avanzarA
li t0,'B'
beq t0,a5,avanzarB
li t0,'C'
beq t0,a5,avanzarC
li t0,'D'
beq t0,a5,avanzarD
j avanzarE
avanzarA:
	beqz a3,avanzarB #Si la posicion es 0 es que esta saliendo del laberinto
	addi a3,a3,-1 #(mover izquierda)
	j valida
avanzarB:
	addi a4,a4,1 #(mover arriba)
	beq a3,a7,avanzarBY #Si la posicion es igual a la cantidad de rows es que esta saliendo del laberinto
	j valida
avanzarC:
	addi a3,a3,1 #(mover derecha)
	beq a3,a6,avanzarBX #Si la posicion es igual a la cantidad de columnas es que esta saliendo del laberinto
	j valida
avanzarD:
	beqz a4,avanzarB #Si la posicion es 0 es que esta saliendo del laberinto
	addi a4,a4,-1 #(mover abajo)
	j valida
avanzarE:
	#direccion no valida
	j salira
avanzarBY: #revierte si se desborda hacia arriba
	addi a4,a4,-1
	j avanzarB
avanzarBX: #revierte si se desborda hacia la derecha
	addi a3,a3,-1
	j avanzarB
avanzarB:
	#cargar posiciones X, Y e insertarlas
	addi t0, zero, 1
	la t5,posicionX
	sb a3,0(t5)
	la t5,posicionY
	sb a4,0(t5)
	mul t2,a4,a6 #t2 = posicionY*rows para offset por mov en y
	add t5,zero,t2 #suma a t4 el offset por mov en y
	add t5,t5,a3 #suma la posicion en x
	addi t5,t5,1 #suma 1 para pasar de pos a num de celda
	la t4,posicionSalida #carga la direccion de la posicion de la salida
	lb t3,0(t4) #obtiene el valor de la posicion de la salida
	beq t3,t5,avanzarG #si la salida coincide con la pos gana
	la t4,posEntrada #carga la direccion de la posicion de la entrada
	lb t3,0(t4) #obtiene el valor de la posicion de la entrada
	beq t3,t5,avanzarP #si la entrada coincide con la pos, no hay solucion
	j avanzarES
	
avanzarES:
	#error al salirse del mapa sin ser la salida indicada
	j salira
avanzarG:
	limpiar()
	add t5, zero, zero
	add t6, zero, zero
	la t1,msgExito #prepara el puntero de la cadena de ganar
	j avanzarI
avanzarP:
	limpiar()
	add t5, zero, zero
	add t6, zero, zero
	la t1,msgError #prepara el puntero de la cadena de perder
avanzarI:
	add t2,a1,a2 #cargar la direccion del kmino
	li t4,'?'
avanzarPS:

	lb t3,0(t1) #carga el caracter de la cadena de ganar
	beq t4,t3,salirimp #si en la cadena no aparece ? no ha terminado
	sb t3,0(t2) #guarda el caracter cargado en el kmino
	#+= 1 puntero cadena += 1 puntero kmino += 1 posicion kmino
	addi t1,t1,1
	addi t2,t2,1
	addi a2,a2,1
	j avanzarPS
valida:
	la t5,posicionX #cargar la direccion del posicionX
	sb a3,0(t5) #inserta la nueva posicion x
	la t5,posicionY #cargar la direccion del posicionY
	sb a4,0(t5) #inserta la nueva posicion y
	mul t2,a4,a6 #t2 = posicionY * rows
	add t3,zero,t2 #suma a t3 el offset por posicionY
	add t3,t3,a3 #suma a t3 el offset por pos x
	posicionEnArray() #carga el avance al kmino
	add t4,a1,a2
	sb a5,0(t4)
	addi a2,a2,1
	addi t4, t4,1
	li t5, 45
	sb t5,0(t4)
	addi a2,a2,1
	add t0, zero, zero
	j salira
salirimp:
	
	li t0,1
	
salira:
.end_macro 
	
.macro getCharFromNumber(%pos) #obtiene el caracter en la posicion del kmino
	#Guarda en t2 el resultado del puntero del kmino mas la posicion que se consulta
	add t2, a0, %pos 
	lb t4,0(t2) #Obtiene el caracter de la direccion t2
.end_macro 

  la   s0, kmino   
  li   s1, 1      

  la   a0, input    # param nombre de archivo
  li   a1, 0        # param 0 leer, param 1 escribir
  li   a7, 1024     # abrir archivo
  ecall

  bltz a0, finalizar # Salto si a0 es menor a 0, es decir si no existe
  mv   s6, a0        # sguardar info del archivo

ciclolectura:
  mv   a0, s6       # descripcion del archivo 
  mv   a1, s0       # direccion de kmino
  mv   a2, s1       # cantidad de caracteres a leer
  li   a7, 63       # parametro para leer archivo
  ecall             

  bltz a0, cerrararchivo # en caso de error, cerrar el archivo es importante
  mv   t0, a0       
  add  t1, s0, a0   
  sb   zero, 0(t1) 
  addi s0,s0,1
  beq  t0, s1, ciclolectura
cerrararchivo: 
  mv   a0, s6       # informacion del archivo / descriptor
  li   a7, 57       # parametro para cerrar archivo
  ecall             # Cerrar el archivo
#TERMINAN MACROS 

#Inicio de codigo del proyecto 
#Reconocer los primeros parametros desde el archivo
limpiar()
limpiarA()
#asignar rows
la a0, kmino
getASCII()
la a1, rows
sb a6, 0(a1)
#asignar columnas
addi t0, t0, 1
getASCII()
la a1, cols
sb a6, 0(a1)
#asignar posicion de la entrada
addi t0, t0, 1
getASCII()
la a1, posEntrada
sb a6, 0(a1)
la a1,rows
lb a2,0(a1)
div a3,a6,a2 #obtiene valor de pos y
la a1, posicionY
sb a3,0(a1) #guarda el valor de pos y
mul a4,a3,a2 #obtiene el offset por posicion y
sub a6,a6,a4 #obtiene el valor de pos x
addi a6,a6,-1 #convierte a posicion de matriz
la a1, posicionX
sb a6, 0(a1) #asignar valor de pos x
#asignar direccion de la entrada
addi t0, t0, 1
getCharFromNumber(t0)
mv a6,t4
la a1, direccionEntrada
sb a6, 0(a1)
la a2, direccion1
sb a6, 0(a2) #asignar como direccion inicial
#asignar posicion de la salida
addi t0, t0, 1
getASCII()
la a1, posicionSalida
sb a6, 0(a1)
#asignar direccion de la salida
addi t0, t0, 1
getCharFromNumber(t0)
mv a6,t4
la a1, direccionSalida
sb a6, 0(a1)
#Inicializar matriz
add t4, zero, zero#limpiar registros
limpiarA()
la a0,kmino #asignar puntero de kmino
la a1,matriz #asignar puntero de matriz
recon:
addi t0,t0,1 #avanzar puntero
li a2,'?'
add a4,a0,t0
lb a5,0(a4)
beq a5,a2,finrecon #si encuentra ? finaliza el reconocimiento de paredes
#si no ha llegado al final reconoce una pared
getASCII() #Reconocer el numero que esta 
	li t5,1
	sub a6,a6,t5 #Restar uno al valor para convertirlo en pos. de matriz
	addi t0,t0,1 #avanzar puntero del kmino
	getCharFromNumber(t0) #Obtener valor de la pared
	li a2,'A'
	li a3,'B'
	li a4,'C'
	li a5,'D'
	#sumar dependiendo de donde se encuentra
	#A->1 B->2 C->4 D->8
	beq t4,a2,sumar1
	beq t4,a3 sumar2
	beq t4,a4 sumar4
	beq t4,a5 sumar8
	j errorpared
sumar1:
	li t5,1
	j sumar
sumar2:
	li t5,2
	j sumar
sumar4:
	li t5,4
	j sumar
sumar8:
	li t5,8
	j sumar
errorpared:

	j salir
sumar:
	add a2,zero,zero
	add a6,a6,a1 #obtiene la direccion de la casilla exacta
	lb a2,0(a6) #se carga el valor de la casilla en a2
	add a2,a2,t5 #suma a la casilla el valor de la pared
	sb a2,0(a6) #inserta el nuevo valor a la casilla
salir:
j recon #regresa al ciclo
finrecon:
#Comenzar Recorrido
limpiar()
add t5, zero, zero
add t6, zero, zero
limpiarA()
la a0,matriz #inicio de la matriz
la a1,kmino 
li a2,0 #empieza a escribir desde la posicion 0 
la a7,posicionX 
lb a3,0(a7) #guarda su valor en a3 para su uso
la a7,posicionY 
lb a4,0(a7) 
la a7,direccion1 #cargar la direccion a la que se esta viendo
lb a5,0(a7) 
la a7,cols 
lb a6,0(a7) 
la t0,rows 
lb a7, 0(t0) 
buscar:
	#aplicar el algoritmo para encontrar salida
	leftShift() 
	verificarPared() 
	li t1,1
	beq t1,t0,avan #comprobando si una pared existe, de lo contrario gira
	rShift() 
	verificarPared() 
	li t1,1
	beq t1,t0,avan #comprobando si una pared existe, de lo contrario gira
	rShift() 
	verificarPared() 
	li t1,1
	beq t1,t0,avan #comprobando si una pared existe, de lo contrario gira
	rShift() 
	verificarPared() 
	li t1,1
	beq t1,t0,avan #comprobando si una pared existe, de lo contrario gira
	limpiar()
	add t5, zero, zero
	add t6, zero, zero
	la t1,msgError #prepara el puntero de la cadena de perder
	add t2,a1,a2 #cargar la direccion del kmino
	li t4,'?'
printSol:
	lb t3,0(t1) #carga el caracter de la cadena de ganar
	beq t4,t3,escribir #si en la cadena no aparece ? no ha terminado
	sb t3,0(t2) #guarda el caracter cargado en el kmino
	#+= 1 puntero cadena += 1 puntero kmino += 1 posicion kmino
	addi t1,t1,1
	addi t2,t2,1
	addi a2,a2,1
	j printSol
avan:
	movimientos()
	beqz t0,buscar #si t0 es 0 es porque no ha terminado y debe seguir
	#si t0 es 1, se termino la busqueda
escribir:
mv s1,a2
limpiar() #limpiar registros t
add t5, zero, zero
add t6, zero, zero
limpiarA()
  la   s0, kmino
  la   a0, output      # param nombre de archivo
  li   a1, 1        # param 0 leer, param 1 escribir
  li   a7, 1024     # abrir archivo
  ecall
  bltz a0, finalizar # Salto si a0 es menor a 0, es decir si no existe
  mv   s6, a0       # sguardar info del archivo
  mv   a0, s6       # descripcion del archivo 
  mv   a1, s0       # direccion de kmino
  mv   a2, s1       # cantidad de caracteres a leer
  li   a7, 64       # parametro para escritura archivo
  ecall          
  mv   a0, s6       # informacion del archivo / descriptor
  li   a7, 57       # parametro para cerrar archivo
  ecall             # Cerrar el archivo   
finalizar:
  li   a7, 10
  ecall
