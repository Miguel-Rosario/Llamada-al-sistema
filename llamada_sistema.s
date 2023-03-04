	.arch armv7-m
	.fpu softvfp
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 6
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"llamada_sistema.c"

.text

	.align	1
	.global	len
	.syntax unified
	.thumb
	.thumb_func
	.type	len, %function
len:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	sub	sp, sp, #20
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r3, [r7, #4]
	str	r3, [r7, #12]
	b	.L2
.L3:
	ldr	r3, [r7, #12]
	adds	r3, r3, #1
	str	r3, [r7, #12]
.L2:
	ldr	r3, [r7, #12]
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	bne	.L3
	ldr	r2, [r7, #12]
	ldr	r3, [r7, #4]
	subs	r3, r2, r3
	mov	r0, r3
	adds	r7, r7, #20
	mov	sp, r7
	@ sp needed
	pop	{r7}
	bx	lr
	.size	len, .-len

	.align	1
	.global	a2i
	.syntax unified
	.thumb
	.thumb_func
	.type	a2i, %function
a2i:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	sub	sp, sp, #12
	add	r7, sp, #0
	mov	r3, r0
	strb	r3, [r7, #7]
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	subs	r3, r3, #48
	mov	r0, r3
	adds	r7, r7, #12
	mov	sp, r7
	@ sp needed
	pop	{r7}
	bx	lr
	.size	a2i, .-a2i
	.align	1
	.global	i2a
	.syntax unified
	.thumb
	.thumb_func
	.type	i2a, %function
i2a:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	sub	sp, sp, #12
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r3, [r7, #4]
	uxtb	r3, r3
	adds	r3, r3, #48
	uxtb	r3, r3
	mov	r0, r3
	adds	r7, r7, #12
	mov	sp, r7
	@ sp needed
	pop	{r7}
	bx	lr
	.size	i2a, .-i2a


read_user_input:
	push {r7}
	sub sp, sp, #12
	add r7, sp, #0

	str r1, [r7, #4] @ Bufer de entrada arg1
	str r0, [r7, #8] @ NUmero de bytes a almacenar arg2

	mov r4, r7
	mov r7, #0x3
	mov r0, #0x0
	ldr r1, [r4, #8]
	ldr r2, [r4, #4]
	svc 0x0

	mov r7, r4
	mov r0, r3
	adds r7, r7, #12
	mov sp, r7
	pop {r7}
	bx  lr

display:
	push {r7}
	sub sp, sp, #12
	add r7, sp, #0

	str r1, [r7, #4]
	str r0, [r7, #8]

	mov r4, r7
	mov r7, #0x4
	mov r0, #0x1
	ldr r1, =cout
	mov r2, #0x10
	svc 0x0

	mov r7, r4
	mov r0, r3
	adds r7, r7, #12
	mov sp, r7
	pop {r7}
	bx lr



	.align	1
	.global	main
	.syntax unified
	.thumb
	.thumb_func
	.type	main, %function
main:	/*int main()*/
	@ args = 0, pretend = 0, frame = 40
	@ frame_needed = 1, uses_anonymous_args = 0
	/*Comienzo del prologo*/
	push	{r7, lr}	@ Se reserva el marco
	sub	sp, sp, #40	@ Reservamos espacio
	add	r7, sp, #0	@ Actualizamos el apuntador de marco

	/*Buffer de entrada*/
	ldr r0, =cin	@ Direccion base del buffer
	mov r1, #0x10	@ Numero de bytes a usar
   	bl read_user_input	@ Se hace la invocacion de la llamada al sistema

	/*Invocacion de la funcion len*/
	mov	r3, #0
	ldr	r3, =cin 	@ Se obtiene la direccion base del bufer de entrada
	mov	r0, r3		@ Se pasa como parametro la direccion
	bl	len		@ Se manda a llamar a la funcion len
	str	r0, [r7, #8]  	@ size = len(bufer de entrada)

	/*Bucle for 1*/
	movs	r3, #0		@ int i = 0
	str	r3, [r7]	@ se respalda i
	b	.L10 		@ #Brinca a i < size
.L11:
	ldr r2, =cin			@ Se carga base(buffer de entrada)
	ldr	r3, [r7]		@ se carga el iterador i
	add	r3, r3, r2		@ base(buffer_entrada) + i y se almacena en r3 el elemento
	ldrb	r3, [r3]		@ se carga el elemento buffer de entrada[i]

	/*Invocacion de a2i*/
	mov	r0, r3			@ Se pasa el argumento base(buffer de entrada)
	bl	a2i
	mov	r3, r0			@ Se respalda el resultado

	uxtb	r1, r3
	add	r2, r7, #20		@ Se carga base(arreglo de enteros)
	ldr	r3, [r7]		@ se carga el iterador i
	add	r3, r3, r2		@ base(arreglo de enteros) + i y se almacena en r3 el elemento
	mov	r2, r1			@ Se asigna el valor retornado por a2i
	strb	r2, [r3]		@ array de enteros[i] = a2i(buffer de entrada[i] se almacena el resultado obtenido en la base obtenida del array
	ldr	r3, [r7]		@ se carga i
	adds	r3, r3, #1		@ se incrementa i++
	str	r3, [r7]		@ Se vuelve a respaldar
.L10:					@ condicion:
	ldr	r2, [r7]		@ Se carga i
	ldr	r3, [r7, #8]		@ Se carga size
	cmp	r2, r3			@ i < size?
	blt	.L11			@ Se vuelve a ejecutar for, si la condicion se cumple, si no se termina el bucle

	/*bucle for 2*/
	movs	r3, #0			@ i = 0
	str	r3, [r7, #4]		@ Se carga i
	b	.L12			@ Se brinca a i < size
.L13:
	add	r2, r7, #20		@ Se carga base(arreglo de enteros)
	ldr	r3, [r7, #4]		@ Se carga el iterador i
	add	r3, r3, r2		@ Base(arreglo de enteros) + i y se almacena en r3 el elemento
	ldrb	r3, [r3]		@ Se carga arreglo de enteros[i]

	/*Invocacion de i2a*/
	mov	r0, r3			@ Se pasa como parametro arreglo de enteros[i]
	bl	i2a			@ Se manda a llamar y se pasa el argumento i2a(array_enteros[i])
	mov	r3, r0

	mov	r1, r3			@ Resultado de la invocacion de i2a
	ldr r2, =cout			@ Se carg base(buffer de salida)
	ldr	r3, [r7, #4]		@ Se carga el iterdor i
	add	r3, r3, r2		@ Se calcula base(buffer de salida) + i

	mov	r2, r1			@ Se asigna el resultado retornado por i2a
	strb	r2, [r3] 		@ buffer_salida[i] = i2a(array_enteros[i]);
	ldr	r3, [r7, #4] 		@ Se carga el iterador i
	adds	r3, r3, #1		@ Se incrementa i++
	str	r3, [r7, #4]		@ se vuelve a respaldar
.L12:
	ldr	r2, [r7, #4]		@ Se carga i
	ldr	r3, [r7, #8]		@ Se carga size
	cmp	r2, r3			@ i < size?
	blt	.L13			@ Se vuelve a ejecutar for, si la condicion se cumple, sino  se termina el bucle

	/*Se invoca al buffer de salida*/
	bl display	@ Se invoca a la funcion la cual realiza la escritura
	mov r0,#0x0
	mov r7,#0x1
   	svc 0x0

	/*Comienza el epilogo*/
	movs	r3, #0
	mov	r0, r3
	adds	r7, r7, #40 @ Se regresa el valor original del sp
	mov	sp, r7	@ Se restaura el sp
	@ sp needed
	pop	{r7, pc}	@ Se regresa a su estado original la pila
.L16:
	.align	2
	.word	__stack_chk_guard
	.size	main, .-main

.section .data
cin:
	.skip 8
cout:
	.skip 8
end:
	.skip 8

	.ident	"GCC: (Ubuntu 11.3.0-1ubuntu1~22.04) 11.3.0"
	.section	.note.GNU-stack,"",%progbits



