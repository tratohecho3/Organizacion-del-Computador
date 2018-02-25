# TAD_Lista

# Implementaci�n de una Lista enlazada simple.

# Autores: David Segura 13-11341
#	   Jesus Kauze  12-10273

.data
	CabezaLista:	.word 12 	# Direccion de la cabeza de la lista donde se apunta al next, al �ltimo y tama�o de la lista.
	nodo:		.word  8	# Nodo de la lista (Elemento,Siguiente)
	size:		.word		# Tama�o de la lista

.text
################################################## CREATE ##################################################
	create:
		sw $fp, 0($sp)
		addi $sp, $sp, -4
		sw $ra, 4($sp) 		#Guarda el ra del main
		li $a0, 12 		#Guardamos una estructura de 12 (3 elementos: direccion, elemento, next)
		jal malloc	   	 #Llama a malloc para asignarle la direccion
		lw $fp, 0($sp)
		lw $ra, 4($sp)
		addi $sp, $sp, 4
		move $t1, $v0 		# Direccion donde comienza la cabeza de la lista (en el init)
		
		jr $ra
	insert:
		#Convenciones (Para guardar nuestros datos sobre los anteriores)
		sw $fp, 0($sp)
		sw $ra, -4($sp)
		sw $a0, -8($sp) 	#Direccion de la list
		sw $a1, -12($sp)
		move $s2, $a1
		move $fp, $sp

		move $s0, $a0 		#$s0 guardo la cabeza de la lsita
		sw $s0, -16($sp)
		sw $s2, -20($sp) 
		addi $sp, $sp, -24
		add $a0, $zero, 8

		jal malloc		#Arroja el $v0 como la direccion
		bltz $v0, salir
		lw $s0, 8($sp)
		lw $s1, 4($s0)		#s1 guarda la cantidad de elementos (size)
 		lw $s2, 4($sp)

		li $k1, -1
		sw $k1, 0($v0) 		# Asigno el .next como -1 para decir que es el final
		sw $s2, 4($v0) 		# almaceno el elem_ptr
	
		beqz $s1, insertPrimero
		lw $t2, 8($s0)		#ultimo
		sw $v0, 0($t2)		# el penultimo nodo apunta al ultimo
		sw $v0, 8($s0)		# cabeza.last apunta al ultimo
		addi $s1, $s1, 1
		sw $s1, 4($s0)
	
	salir:
		jr $ra
		
	insertPrimero:
		sw $v0, 0($s0) 		#la cabeza del primer elemento apuntara al nuevo nodo
		sw $v0, 8($s0) 		# aplica igual para la cabeza del ultimo
		lw $t3, 4($s0)
		addi $t3, $t3, 1 	#AQUI ES DONDE ESTA EL PEO
		sw $t3, 4($s0) 		#Cabeza.size se le suma 1
		b salir
		
	
.include "Manejador.asm"