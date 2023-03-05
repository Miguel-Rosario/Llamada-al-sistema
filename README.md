# Manejo de perifericos mediante llamadas al sistema.


En esta seccion se describe el proceso de la llamada al sistema de lectura y escritura que se realizo mediante el uso del lenguaje ensamblador armv7.

## Funcion principal (main).

La funcion main invoca a las funciones read_user_input, display, a2i, i2a y len. Las cuales se usan para poder manipular los arreglos y procesar la lectura y la escritura. A continuacion se presenta el marco de frame:

```asm
/*Comienzo del prologo*/
push	{r7, lr}	@ Se respalda el apuntador de marco, el registro de enlace y se incrementa la direccion.
sub	sp, sp, #40	@ Reservamos espacio en el apuntador de la pila.
add	r7, sp, #0	@ Actualizamos el apuntador de marco. 

```
Seguido del prologo, se invoca al buffer de entrada, en el cual se define con una etiqueta en donde almacenara la entrada del usuario, esta funcion recibe como parametros la direccion base del buffer de entrada y el numero de bytes que se usaran para procesar la lectura.

```asm
/*Buffer de entrada*/
ldr r0, =cin	@ Etiqueta con la direccion base del buffer de entrada.
mov r1, #0x10	@ Numero de bytes a usar.
bl read_user_input	@ Se hace la invocacion de la llamada al sistema
  
```
Pasamos a invocar a la funcion "len()" la cual recibe como parametro la base del buffer de entrada, esta funcion realiza un conteo del numero de caracteres que contiene la entrada del usuario, por lo tanto, retorna la longitud de la cadena introducida:

```asm
/*Invocacion de la funcion len*/
mov	r3, #0
ldr	r3, =cin 	@ Se obtiene la direccion base del bufer de entrada
mov	r0, r3		@ Se pasa como parametro la direccion
bl	len		@ Se manda a llamar a la funcion len
str	r0, [r7, #8]  	@ size = len(bufer de entrada) En esta parte se respalda la longitud de la cadena
  
```
El siguiente paso es convertir la cadena introducida por el usuario a numeros enteros, para esto se define un bucle tipo for el cual se ejecutara con la condicion i < size, donde size es la longitud de la cadena introducida previamente, para esto realizamos las operaciones necesarias para obtener byte a byte cada uno de los caracteres y pasarlos como parametro a la funcion a2i (ascii to integer):
  
```asm
/*Calculo de los elementos del buffer de entrada*/
ldr r2, =cin			@ Se carga base(buffer de entrada)
ldr	r3, [r7]		  @ se carga el iterador i (este iterador se inicializa y respalda antes de entrar al bucle for)
add	r3, r3, r2		@ Una vez obtenido lo anterior, realizamos la operacion: buffer de entrada [i] = base(buffer de entrada) + i  
ldrb	r3, [r3]		@ se carga el elemento buffer de entrada[i], el cual se pasara como parametro a la funcion a2i()
/*Invocacion de a2i*/
mov	r0, r3			  @ Se pasa el argumento buffer de entrada[i] calculado previamente
bl	a2i
mov	r3, r0			  @ Se mueve el resultado retornado al registro r3
/*Calculo de las posiciones del arreglo a insertar los elementos procesados por a2i*/
add	r2, r7, #20		@ Se carga base(arreglo de enteros) desde la pila
ldr	r3, [r7]		  @ se carga el iterador i
add	r3, r3, r2		@ base(arreglo de enteros) + i y se almacena en r3 la posicion
mov	r2, r1			  @ Se mueve el valor retornado por a2i a r2
strb	r2, [r3]		@ array de enteros[i] = a2i(buffer de entrada[i]) se almacena el resultado obtenido en la posicion calculada del arreglo
```
Este proceso se repite hasta que se termine de recorrer y procesar las direcciones de los elementos del buffer de entrada.
Una vez que se hayan almacenado los elementos procesados del buffer de entrada en un arreglo auxiliar, podemos pasar al siguiente bucle el cual procesara los numeros enteros asignados al arreglo previo, los cuales se convertiran a caracteres para posteriormente realizar la escritura de dicha cadena introducida. La funcion encargada de convertir a numeros enteros a caracteres es i2a (integer to ascii):
  

## Funcion lee entrada de datos (read_user_imput).

Empieza la funcion con el prologo, para reservar la memoria de las variables que se usaran.
```asm
/* Prologo de la funcion read_user_input*/
	push {r7} 		@guarda el valor de r7 en pila 
	sub sp, sp, #12		@asignamos el valor de sp para reservar espacio para las variables 
	add r7, sp, #0		@inicializa r7 para apuntar al inicio del espacio reservado 
```
Guarda  los argumentos (buffer de entrada) en la pila, en una pocision diferente cada una, estas van de 4 en 4 bytes tomando como base la direccion de la pila r7

```asm
	str r1, [r7, #4] 	@ Bufer de entrada arg1
	str r0, [r7, #8] 	@ Numero de bytes a almacenar arg2
```
Esta instruccion es importante para no perder la direccion de la pila, ya que el registro r7 se usa para llamada al sistema, evitando perder la direccion de la pila 
```asm
	mov r4, r7		@respalda el valor de la pila 
```
Hace una llamada al sistema y se carga el valor en los registros 
```asm
	mov r7, #0x3		@llamada al sistema para leer la entrada del usuario 
	mov r0, #0x0		@
	ldr r1, [r4, #8]	@cargar el primer argumento (buffer de entrada) en r1
	ldr r2, [r4, #4]	@carga el segundo argumento bytes a almacenar 
	svc 0x0			@lee la entrada del usuario
```
Aqui regrsamos el valor del puntero del marco de la pila a r7
```asm
mov r7, r4		@regresa el valor original de r7
```
Termina la funcion con el epiligo, para liberar la memoria que se reservo y regresar los valores a la funcion desde donde se invoco

```asm
	
	/*empieza el epilogo*/
	mov r0, r3		@
	adds r7, r7, #12	@libera el espacio reservado para las variables 
	mov sp, r7		@restaurar el valor original de sp 
	pop {r7}		@recuperar e vaor de r7 de la pila 
	bx  lr			@ regresar a la funcion llamante 

```
En resumen esta funcion hace una llamada al sistema para leer la entrada del ususario y almacenar los datos en un buffer 
  
