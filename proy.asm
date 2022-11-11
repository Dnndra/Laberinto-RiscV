.global programa
  .data
input:   
  .string  "mapa.txt"
output:
  .string "solucion.txt"
error:
  .string  "No se ha podido abrir el archivo"
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
posicionX:
  .byte 0
posicionY:
  .byte 0
dir:
  .byte 0
dece:
  .byte 0
uni:
  .byte 0
matriz:
  .string "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
solu:
  .string "exito?"
nosolu:
  .string "Error en el mapa, no hay salida?"
kmino:
  .string ""
  .text
programa:
#Inicio del segmento de codigo
#INICIAN MACROS 
.macro limpiar() #este macro limpia los registros t mas utilizados para evitar la redundancia de codigo
add t0, zero, zero #vaciar registros
add t1, zero, zero 
add t2, zero, zero
add t3, zero, zero
add t4, zero, zero
.end_macro	
.macro limpiarA()
add a0, zero, zero #vaciar registros
add a1, zero, zero 
add a2, zero, zero
add a3, zero, zero
add a4, zero, zero
add a5, zero, zero
add a6, zero, zero
add a7, zero, zero
.end_macro	
.macro posicionEnArray()
li t1,10
addi t3,t3,1 #sumar 1 para pasar de posicion a numero de celda
div t4,t3,t1 
add t5,a1,a2 #cargar posicion del kmino
beq t4,t1,centena1 #validacion para matriz 10x10
mul t6,t4,t1 #
sub t0,t3,t6 #realizando reajuste para calcular unidades
addi t4,t4,48 #convierte el numero en caracter
sb t4,0(t5) #mete las decenas al kmino
addi a2,a2,1
addi t0,t0,48 #convierte el numero en caracter
sb t0,1(t5) #guardar las unidades al kmino
addi a2,a2,1
j salir1
centena1:
	li t1,'1' #carga el caracter 1
	sb t1,0(t5) #guarda el 1 de centenas
	li t1,'0' #carga el caracter 0
	addi a2,a2,1
	sb t1,1(t5) #inserta 0 en el kmino
	addi a2,a2,1
	sb t1,2(t5) #inserta 0 en el kmino
	addi a2,a2,1
salir1:
.end_macro 

.macro verificarPared()
limpiar()
#aplicando la forrrrmula
mul t6,a4,a6 #t6 = posicionY * rows
mv t3,t6 #suma a t3 el offset por posicionY
add t3,t3,a3 #suma a t3 el offset por pos x
posicionEnArray()
addi t3,t3,-1 #resta 1 para regresar a posicion despues de posicionEnArray
add t6,a0,t3 #obtiene la direccion de la pos exacta del robot
lb t6,0(t6) #guardar en t6 el valor de la pared
addi t6,t6,-48
limpiar()
hayDh:
li t5,8
blt t6,t5,hayCh
sub t6,t6,t5
li t1,1 #t1 pared D
hayCh:
li t5,4
blt t6,t5,hayBh
sub t6,t6,t5
li t2,1 #t2 pared C
hayBh:
li t5,2
blt t6,t5,hayAh
sub t6,t6,t5
li t3,1 #t3 pared B
hayAh:
li t5,1
blt t6,t5,comprobarh
li t4,1 #t4 pared A
comprobarh: #comprobar que direccion esta viendo el robot
li t6,'A'
beq t6,a5,esAh
li t6,'B'
beq t6,a5,esBh
li t6,'C'
beq t6,a5,esCh
li t6,'D'
beq t6,a5,esDh
j errorh 
esAh:
	mv t0,t4 #mover a t0 el valor de la pared
	j validh
esBh:
	mv t0,t3
	j validh
esCh:
	mv t0,t2
	j validh
esDh:
	mv t0,t1
	j validh
errorh:
	#direccion del robot no valida
	j salirh
validh:
	add t5,a1,a2
	addi a2,a2,1
	sb a5,0(t5)
	addi a2,a2,1
	addi t5,t5,1
	li t3,45
	sb t3,0(t5)
salirh:
.end_macro 

.macro leftShift()
limpiar()
la t1,dir #obtiene variable que guarda la direccion del robot
#comprobar que direccion esta viendo el robot
li t6,'A'
beq t6,a5,esAgi
li t6,'B'
beq t6,a5,esBgi
li t6,'C'
beq t6,a5,esCgi
li t6,'D'
beq t6,a5,esDgi
j errorgi
esAgi:
	li t6,'D' #si la direccion es A asigna la direccion D al girar
	sb t6,0(t1) #asigna nueva direccion
	mv a5,t6 #mueve a a5 la nueva direccion
	j salirgi
esBgi:
	li t6,'A' #si la direccion es B asigna la direccion A al girar
	sb t6,0(t1) #asigna nueva direccion
	mv a5,t6 #mueve a a5 la nueva direccion
	j salirgi
esCgi:
	li t6,'B' #si la direccion es C asigna la direccion B al girar
	sb t6,0(t1) #asigna nueva direccion
	mv a5,t6 #mueve a a5 la nueva direccion
	j salirgi
esDgi:
	li t6,'C' #si la direccion es D asigna la direccion C al girar
	sb t6,0(t1) #asigna nueva direccion
	mv a5,t6 #mueve a a5 la nueva direccion
	j salirgi
errorgi:
	#direccion del robot no valida
	j salirgi
salirgi:
.end_macro 

.macro rShift()
limpiar()
la t1,dir #obtiene variable que guarda la direccion del robot
#comprobar que direccion esta viendo el robot
li t6,'A'
beq t6,a5,esAgd
li t6,'B'
beq t6,a5,esBgd
li t6,'C'
beq t6,a5,esCgd
li t6,'D'
beq t6,a5,esDgd
j errorgd
esAgd:
	li t6,'B' #si la direccion es A asigna la direccion B al girar
	sb t6,0(t1) #asigna nueva direccion
	mv a5,t6 #mueve a a5 la nueva direccion
	j salirgd 
esBgd:
	li t6,'C' #si la direccion es B asigna la direccion C al girar
	sb t6,0(t1) #asigna nueva direccion
	mv a5,t6 #mueve a a5 la nueva direccion
	j salirgd
esCgd:
	li t6,'D' #si la direccion es C asigna la direccion D al girar
	sb t6,0(t1) #asigna nueva direccion
	mv a5,t6 #mueve a a5 la nueva direccion
	j salirgd
esDgd:
	li t6,'A' #si la direccion es D asigna la direccion A al girar
	sb t6,0(t1) #asigna nueva direccion
	mv a5,t6 #mueve a a5 la nueva direccion
	j salirgd
errorgd:
	#direccion del robot no valida
	j salirgd
salirgd:
.end_macro 

.macro avanzar()
limpiar()
add t5, zero, zero
add t6, zero, zero
#comprobar que direccion esta viendo el robot
li t0,'A'
beq t0,a5,esAa
li t0,'B'
beq t0,a5,esBa
li t0,'C'
beq t0,a5,esCa
li t0,'D'
beq t0,a5,esDa
j errorDa
esAa:
	beqz a3,bordea #Si la posicion es 0 es que esta saliendo del laberinto
	addi a3,a3,-1 #Restar 1 a pos x (mover izquierda)
	j valida
esBa:
	addi a4,a4,1 #Sumar 1 a pos y (mover arriba)
	beq a3,a7,bordeay #Si la posicion es igual a la cantidad de rows es que esta saliendo del laberinto
	j valida
esCa:
	addi a3,a3,1 #Sumar 1 a pos x (mover derecha)
	beq a3,a6,bordeax #Si la posicion es igual a la cantidad de columnas es que esta saliendo del laberinto
	j valida
esDa:
	beqz a4,bordea #Si la posicion es 0 es que esta saliendo del laberinto
	addi a4,a4,-1 #Restar 1 a pos y (mover abajo)
	j valida
errorDa:
	#direccion del robot no valida
	j salira
bordeay: #si es caso de desborde por avanzar hacia arriba revierte el movimiento
	addi a4,a4,-1
	j bordea
bordeax: #si es caso de desborde por avanzar a la derecha revierte el movimiento
	addi a3,a3,-1
	j bordea
bordea:
	addi t0, zero, 1
	la t5,posicionX #cargar la direccion del posicionX
	sb a3,0(t5) #inserta la nueva posicion x
	la t5,posicionY #cargar la direccion del posicionY
	sb a4,0(t5) #inserta la nueva posicion y
	mul t2,a4,a6 #t2 = posicionY*rows para offset por mov en y
	add t5,zero,t2 #suma a t4 el offset por mov en y
	add t5,t5,a3 #suma la posicion en x
	addi t5,t5,1 #suma 1 para pasar de pos a num de celda
	la t4,posicionSalida #carga la direccion de la posicion de la salida
	lb t3,0(t4) #obtiene el valor de la posicion de la salida
	beq t3,t5,ganara #si la salida coincide con la pos del robot gana
	la t4,posEntrada #carga la direccion de la posicion de la entrada
	lb t3,0(t4) #obtiene el valor de la posicion de la entrada
	beq t3,t5,perdera #si la entrada coincide con la pos del robot, no hay solucion
	j errorSa
	
errorSa:
	#Error al salirse del mapa sin ser la salida indicada
	j salira
ganara:
	limpiar()
	add t5, zero, zero
	add t6, zero, zero
	la t1,solu #prepara el puntero de la cadena de ganar
	j imprimira
perdera:
	limpiar()
	add t5, zero, zero
	add t6, zero, zero
	la t1,nosolu #prepara el puntero de la cadena de perder
imprimira:
	add t2,a1,a2 #cargar la direccion del kmino
	li t4,'?'
printSolua:
	lb t3,0(t1) #carga el caracter de la cadena de ganar
	beq t4,t3,salirimp #si en la cadena no aparece ? no ha terminado
	sb t3,0(t2) #guarda el caracter cargado en el kmino
	addi t1,t1,1 #aumenta en 1 el puntero de la cadena
	addi t2,t2,1 #aumenta en 1 el puntero del kmino
	addi a2,a2,1 #aumenta en 1 la posicion del kmino
	j printSolua #repite
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
.macro reconNumber() #Obtiene le valor numerico a partir de una posicion en el kmino
	getCharFromNumber(t0) #obtiene el caracter en la posicion del kmino
	mv a2,t4 #Guarda el valor del caracter en a4
	addi t0, t0, 1 #avanza la posicion del kmino
	getCharFromNumber(t0) #obtiene el caracter en la posicion del kmino
	mv a3,t4 #Guarda el valor del caracter en a5
	addi a2,a2,-48 #Obtiene el valor numerico del caracter
	addi a3,a3,-48 #Obtiene el valor numerico del caracter
	li a5,1 #a5 igual a 1 
	bne a2,a5,decenasrn #si el primer digito no es uno, entonces no hay posibilidad de valor 100
	bnez a3,decenasrn #si el segundo numero no es 0, entonces no hay posibilidad de valor 100
	addi t0, t0, 1 #avanza la posicion del kmino
	getCharFromNumber(t0) #obtiene el caracter en la posicion del kmino
	mv a5,t4 #Guarda el valor del caracter en a5
	addi a5,a5,-48 #Obtiene el valor numerico del caracter
	bnez a5,nocentrn #Si el 3 digito no es un 0, entonces hay posibilidad de valor 100
	addi a6,zero,100 #Si si es 0, entonces se trataba del numero 100
	j salirrn
nocentrn:
	addi t0,t0,-1 #revierte el cambio de posicion por posible valor 100
decenasrn: #Asignar el valor de 2 digitos a a6
	li a5,10
	mul a4,a5,a2 #se obtiene el valor de las centenas
	add a6,zero,a4 #se agregan las centenas al resultado
	add a6,a6,a3 #Se agregan las unidades al resultado
salirrn:
.end_macro
	
.macro getCharFromNumber(%pos) #obtiene el caracter en la posicion del kmino
	#Guarda en t2 el resultado del puntero del kmino mas la posicion que se consulta
	add t2, a0, %pos 
	lb t4,0(t2) #Obtiene el caracter de la direccion t2
.end_macro 

  la   s0, kmino   
  li   s1, 1      

  la   a0, input      # param nombre de archivo
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
reconNumber()
la a1, rows
sb a6, 0(a1)
#asignar columnas
addi t0, t0, 1
reconNumber()
la a1, cols
sb a6, 0(a1)
#asignar posicion de la entrada
addi t0, t0, 1
reconNumber()
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
la a2, dir
sb a6, 0(a2) #asignar como direccion inicial
#asignar posicion de la salida
addi t0, t0, 1
reconNumber()
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
reconNumber() #Reconocer el numero que esta 
	li t5,1
	sub a6,a6,t5 #Restar uno al valor para convertirlo en pos. de matriz
	addi t0,t0,1 #avanzar puntero del kmino
	getCharFromNumber(t0) #Obtener valor de la pared
	li a2,'A'
	li a3,'B'
	li a4,'C'
	li a5,'D'
	beq t4,a2,sumar1 #si encuentra una A, suma a la casilla el valor de 1
	beq t4,a3 sumar2 #si encuentra una B, suma a la casilla el valor de 2
	beq t4,a4 sumar4 #si encuentra una C, suma a la casilla el valor de 4
	beq t4,a5 sumar8 #si encuentra una D, suma a la casilla el valor de 8
	j errorpared
sumar1:
	li t5,1 #Asigna valor 1
	j sumar
sumar2:
	li t5,2 #Asigna valor 2
	j sumar
sumar4:
	li t5,4 #Asigna valor 4
	j sumar
sumar8:
	li t5,8 #Asigna valor 8
	j sumar
errorpared:

	j salir
sumar:
	add a2,zero,zero #vacia a2
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
la a0,matriz #carga el inicio de la matriz
la a1,kmino #carga la ubicacion del kmino para apuntar los pasos
li a2,0 #valor de la posicon donde se sobre escribe el kmino
la a7,posicionX #carga la ubicacion de la posicion en x del robot
lb a3,0(a7) #guarda su valor en a3 para su uso
la a7,posicionY #carga la ubicacion de la posicion en x del robot
lb a4,0(a7) #guarda su valor en a4 para su uso
la a7,dir #carga la ubicacion de la direccion del robot
lb a5,0(a7) #guarda su valor en a5 para su uso
la a7,cols #carga la ubicacion de la cant de columnas
lb a6,0(a7) #guarda su valor en a6 para su uso
la t0,rows #carga la ubicacion de la cant de rows
lb a7, 0(t0) #guarda su valor en a7 pasa su uso

buscar:
	leftShift() #gira a la derecha
	verificarPared() #verificar si hay muro
	li t1,1
	beq t1,t0,avan #si no hay muro avanza
	rShift() #si hay gira a la izquierda
	verificarPared() #verificar si hay muro
	li t1,1
	beq t1,t0,avan #si no hay muro avanza
	rShift() #si hay gira a la izquierda
	verificarPared() #verificar si hay muro
	li t1,1
	beq t1,t0,avan #si no hay muro avanza
	rShift() #si hay gira a la izquierda
	verificarPared() #verificar si hay muro
	li t1,1
	beq t1,t0,avan #si no hay muro avanza
	#si t0 es 1, no se puede avanzar
	limpiar()
	add t5, zero, zero
	add t6, zero, zero
	la t1,nosolu #prepara el puntero de la cadena de perder
	add t2,a1,a2 #cargar la direccion del kmino
	li t4,'?'
printSol:
	lb t3,0(t1) #carga el caracter de la cadena de ganar
	beq t4,t3,escribir #si en la cadena no aparece ? no ha terminado
	sb t3,0(t2) #guarda el caracter cargado en el kmino
	addi t1,t1,1 #aumenta en 1 el puntero de la cadena
	addi t2,t2,1 #aumenta en 1 el puntero del kmino
	addi a2,a2,1 #aumenta en 1 la posicion del kmino
	j printSol #repite
avan:
	avanzar()
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

