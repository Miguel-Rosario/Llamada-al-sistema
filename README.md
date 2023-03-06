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
```asm
/*Calculo de las posiciones del arreglo de enteros*/
add	r2, r7, #20		@ Se carga base(arreglo de enteros)
ldr	r3, [r7, #4]		@ Se carga el iterador i
add	r3, r3, r2		@ Una vez obtenido lo anterior, realizamos la operacion: base(arreglo de enteros) + i y se almacena en r3 la posicion
ldrb	r3, [r3]		@ Se carga arreglo de enteros[i]

/*Invocacion de i2a*/
mov	r0, r3			@ Se pasa como parametro arreglo de enteros[i]
bl	i2a			@ Se manda a llamar i2a y se pasa el argumento: i2a(arreglo de enteros[i])
mov	r3, r0			@ Se mueve el resultado retornado por la funcion al registro r3

mov	r1, r3			@ Resultado de la invocacion de i2a
ldr r2, =cout			@ Se carga la direccion base del buffer de salida: base(buffer de salida)
ldr	r3, [r7, #4]		@ Se carga el iterdor i
add	r3, r3, r2		@ Una vez obtenido lo anterior, realizamos la operacion: base(buffer de salida) + i

mov	r2, r1			@ Se asigna el resultado retornado por i2a en el registro r2
strb	r2, [r3] 		@ Se hace la asignacion: buffer de salida[i] = i2a(arreglo de enteros[i])

```
Despues de pasar de los bucles que procesan la lectura, es tiempo de pasar a la llamada al sistema que dara lugar a la escritura del mensaje introducido:
```asm
/*Se invoca al buffer de salida*/
bl 	display	@ Se invoca a la funcion la cual realiza la escritura
mov 	r0,#0x0	
mov 	r7,#0x1
svc 	0x0
```
Finalmente se llega a la parte del epilogo, donde se restauran los valores originales del sp y la pila vuelve a su estado inicial:
```asm
/*Comienza el epilogo*/
movs	r3, #0
mov	r0, r3
adds	r7, r7, #40 @ Se regresa el valor original del sp
mov	sp, r7	@ Se restaura el sp
pop	{r7, pc}	@ Se regresa a su estado original la pila
```

### Main frame:


![image](https://user-images.githubusercontent.com/79227555/223010046-e4ed01ad-7825-4237-8a10-b86423d59d56.png)

  

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


### read_user_input_frame

![Marco_read_user_input](https://user-images.githubusercontent.com/126648916/223009153-546b27b8-3cd6-4d09-ad46-8edf4fbc4c58.jpeg)



## Funcion para mostrar la Salida (display).

La salida llega a ser muy similar a lo que es la entrada, como toda funcion vamos a empezar con el prologo para que compoo ya se sabe es para reservar la memoria de las variables que se usaran en esta funcion. 

```asm
	push {r7}        @guarda el valor de r7 en pila 
	sub sp, sp, #12   @asignamos el valor de sp para reservar espacio para las variables 
	add r7, sp, #0     @inicializa r7 para apuntar al inicio del espacio reservado 
```
Vuelve a guardar los argumentos en la pila, en una pocision diferente,tomando como base la direccion de la pila r7
  
  ```asm
	str r1, [r7, #4]    @ Bufer de entrada arg1
	str r0, [r7, #8]    @ Numero de bytes a almacenar arg2
	mov r4, r7           @respalda el valor de la pila 
```	
el #0x4 es una interrupción del sistema que se utiliza para mostrar el mensaje en pantalla utilizando la función "cout".
  ```asm
	mov r7, #0x4
```	
el #0x1 una interrupción del sistema que se utiliza para realizar la acción de salida del programa.
  ```asm
	mov r0, #0x1
```
La primera instruccion,carga en R1 la dirección de memoria de la función "cout", la siguiente instruccion hace la llamada al sistema con el número 0x10 esta se utiliza para realizar operaciones de E/S en el sistema, en particular para mostrar texto en la consola o en otro dispositivo de salida utilizando la función "cout".

```asm
	ldr r1, =cout    @carga el registro R1 
	mov r2, #0x10
```
Comienza con el epilogo para darle fin a la funcion y devolver todo como estaba
```asm
	mov r7, r4      @respalda el valor de la pila 
	mov r0, r3       @carga en el registro R0 el valor del registro R3
	adds r7, r7, #12   @libera el espacio reservado para las variables 
	mov sp, r7        @restaurar el valor original de sp 
	pop {r7}       @guarda el valor de r7 en pila 
	bx lr           @ regresar a la funcion llamante 
	
```	
El .global permite que sea llamada desde otras partes del programa
 
  ```asm
.global	main   @define la función "main" como global

```
## Marcos de funciones.
Display_frame

![image](https://user-images.githubusercontent.com/126711639/223006659-5e315868-8741-45aa-88dc-edf49a5e0010.png)





