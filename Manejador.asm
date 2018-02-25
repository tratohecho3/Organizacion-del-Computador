# TAD_Manejador

# Esta estructura tendr� como funci�n el administrar un espacio fijo de
# memoria para ofrecer a las aplicaciones el servicio de reserva y liberaci�n 
# de espacios en forma din�mica. En esta implementaci�n esta estructura se
# manejar� con dos listas enlazadas, una que me indique el espacio que est�
# ocupado dentro del espacio que se reserva y la otra indica el espacio libre 
# para ser ocupado.

# Autores: David Segura 13-11341
#	   Jesus Kauze  12-10273

.data
   ocupado: 		.word 16  # Nodo de la lista de espacios ocupados (Direcci�n,Tama�o,Elemento,Siguiente)
   cabezaocupado: 	.space 4  # Direccion de la cabeza de la lista ocupados 
   elementosOcupados: 	.space 4  # Cantidad de elementos ocupados
   libre: 		.word 12  # Nodo de la lista de espacios libres (Direcci�n,Tama�o,Siguiente)
   cabezalibre: 	.space 4  # Direccion de la cabeza de la lista libres 
   elementosLibres: 	.space 4  # Cantidad de elementos libres
   reservatotal: 	.word
   initerror: 		.asciiz   "Cantidad solicitada inv�lida"
   mallocerror: 	.asciiz   "Cantidad solicitada no disponible"
   reallococerror:	.asciiz   "Tamano no disponible"
   freeerror: 		.asciiz   "Direcci�n a liberar no encontrada"
.globl ocupado
.globl cabezaocupado
.globl elementosOcupados
.globl libre
.globl cabezalibre
.globl elementosLibres
.globl reservatotal
.globl initerror
.globl mallocerror
.globl reallococerror
.globl freeerror
   
.text
################################################## INIT ##################################################
   init:
   # Esta funci�n debe solicitar un bloque de memoria de size bytes y de este bloque es que �l 
   # posteriormente podr� seleccionar segmentos para asignarlos a los programas que lo soliciten
   	# Entrada: $a0 -> Cantidad de espacio a reservar
   	
	li   $s0, -1		# Carga en $s0 el c�digo de error
        blez $a0, Error		# Si la cantidad especificada es un valor negativo -> Error
        sw   $a0, reservatotal  # Guardamos la cantidad de reservada total
        move $s0, $a0		# Carga en $s0 la cantidad especificada para reservar
        
        li   $v0, 9		# Asigna en $v0 la cantidad pedida
        syscall
        
        move $s1, $v0		# Mueve a $s1 la direcci�n del espacio reservado
        
        lw   $a0, libre		# Carga en $a0 el tama�o del nodo libre
        li   $v0, 9		# Asigna en $v0 la direcci�n del nodo libre
        syscall
        
        la   $t0, cabezalibre   # Carga en $t0 la direcci�n de la cabeza libre
        sw   $v0, ($t0)		# Guardamos el primer nodo de la lista libre
        move $s2, $v0		# Guardamos en $s2 la direcci�n del nodo libre
        
        sw   $s1, ($s2)		# Guarda la direcci�n del espacio reservado en el nodo libre
        sw   $s0, 4($s2)	# Guarda el tama�o del espacio reservado en el nodo libre
        li   $t1, 0
        sw   $t1, 8($s2)	# Guarda el apuntador al siguiente nodo
        
        sw   $zero, elementosOcupados # Inicializa la cantidad de elementos ocupados en 0
        li   $t2, 1
        sw   $t2, elementosLibres # Inicializa la cantidad de elementos libres en 1
        
        li   $a0, 0
        j    retorno   
################################################## MALLOC ##################################################        
   malloc:
   # Funci�n que reserva una cantidad de memoria solicitada dentro del espacio reservado
   	# Entrada: $a0 -> Cantidad de memoria
   	move $s0, $a0
   	lw   $s1, cabezalibre	    # Se carga el primer nodo de la lista libre para buscar espacio disponible
   	lw   $t0, elementosOcupados # Se carga la cantidad de elementos ocupados
   	buscar:
   		lw    $s4, 4($s1)        # 4($s1) ser� el tama�o del nodo del espacio libre
   		ble   $s0, $s4, reservar # Si hay la cantidad de memoria solicitada
   		
   		lw    $s2, 8($s1)	 # Si no hay, sigue revisando los siguientes
   		move  $s1, $s2		 # Mueve a $s1 el siguiente nodo
   		bne   $s1, 0, buscar	 # Si el siguiente no es nulo, vuelve a buscar
   		
   		li    $s0, -2
   		j     Error		
   	reservar:
   		sw    $fp, 0($sp) 	  # Se almacena al inicio del stack el valor que trae $fp
        	move  $fp, $sp  	  # Se coloca el $fp de reservar al inicio de su stack frame

        	addi  $sp, $sp, -8  	  # Se abre espacio en el stack frame para el $fp (que ya esta guardado), para $s0 y $ra
        	sw    $ra, 4($sp)    	  # Se guarda $s0 
        	
        	bnez  $t0, agregarOcupado # Si ya hay un elemento ocupado, agrega uno a la lista
   	
   		beqz  $t0, crearOcupado   # Si no hay ning�n elemento ocupado, crea uno nuevo
   		
   		lw  $t6, ($s1)          # Guardamos la direcci�n del espacio libre que se solicit�
   		# Aqui se elimina o disminuye el espacio libre restante
   		beq   $s0, $s4, eliminarlibre # Si el espacio a reservar es el mismo, elimina el nodo en la lista libre
   		
   		bne   $s0, $s4, redimension
   		
   		move  $v0, $t6
   		
   		jr $ra
   		
   		redimension:
   			lw    $s3, ($s1)	# Se carga en $s3 la direccion libre que se esta ocupando
   			add   $s3, $s3, $s0	# Se le suma la cantidad de espacio que reserva
   			sw    $s3, ($s1)	# Ahora el nodo libre tiene como direcci�n la nueva direcci�n sumada
   			lw    $s3, 4($s1)       # Se carga en $s3 el tama�o a reducir
   			sub   $s3, $s4, $s0
   			sw    $s3, 4($s1)	# Ahora el nodo libre tiene como tama�o el nuevo tama�o reducido
   			jr $ra
   			
################################################## REALLOCOC ##################################################
   			
   Reallococ:
   # Funci�n que crea el nodo de la lista de ocupados cuando esta es vacia
   	# Entradas: $a0 -> Tama�o a reservar
   	#	    $a1 -> Direcci�n a reservar
   	
   move $s0, $a0	#$S0 contiene el size de reducir o aumentar (valor pasado por $a0)
   move $s1, $a1	#$S1 contiene la direccion de la memoria a modificar (valor pasado por $a1)
   lw $s3, cabezaocupado #Cargamos el inicio de cabezaocupado (contiene la direccion del primer nodo de la lista ocupado)
   
   #Buscamos en la lista ocupados la direccion  alterar
   buscarR:
   		lw    $s4, 0($s3)        # 0($s3) sera la direccion del nodo del ocupado a modificar
   		lw    $s5, 4($s3)	 # 4($s3) es el tamano de ese nodo ocupado a modificar
   		beq   $s1, $s4, CondicionRoA # Si hay la cantidad de memoria solicitada
   		
   		lw    $s2, 8($s3)	 # Si no hay, sigue revisando los siguientes
   		move  $s3, $s2		 # Mueve a $s1 el siguiente nodo
   		beqz  $s3, error_no_space
   		bne   $s3, 0, buscarR	 # Si el siguiente no es nulo, vuelve a buscar
   		
   		li    $s0, -2
   		j     Error
   		CondicionRoA:
   		blt $s0, $s5, redimensionR 	#s0: size  $s5:tamano del nodo a modificar
   		move $t7, $a0
   		move $a0, $a1
   		beq $s0, $s5, free
   		move $a0, $t7
   		bgt $s0, $s5, redimensionA
   		j error_no_space 
   		
   		redimensionA:
   			lw $t1, elementosLibres			#cargo elementos libres
   			beqz $t1, error_no_space		#si no hay elementos libres, error
   			move $t7, $a0
   			move $a0, $a1
   			b free
   			move $a0, $t7
   			b malloc
   			
   		
   		redimensionR: #Si se Reduce
   			lw    $s3, ($s4)	# Se carga en $s3 la direccion libre que se esta ocupando
   			lw $t0, 4($s4)		#cargo el valor del nodo ocupado en $t0
   			move $t0, $s3		#Guardo la direccion inicial del nodo ocupado
   			sub $t0, $t0, $s0	#Guardo la resta del tamanoOcupado - tamano solicitado
   			add   $s3, $s3, $t0	# Se desplaza la direccion para reducir su tamano
   			sw    $s3, ($s4)	# le asigno la nueva direccion desplazada al nodo ocupado
   			lw $a0, ($s4)		#inicializo en a0 el valor de $s4 (direccion desplazada del nodo ocupado)
   			#direccion $a0 porque lo necesita free
   			jal free		#Libera la memoria
   			
   			move $s0, $t0
   			lw $t1, elementosLibres
   			#$s1 direccion $s0 tamano
   			beqz $t1, crearLibre
   			#$s1 direccion $s0 tamano
   			bge $t1, 1 agregarLibre
   		
   			#como ya se libero el nodo ocupado en el FREE, ahora REcreamos el nodo ocupado con su nuevo tamano 
   			
   			lw $t1, elementosOcupados
   			#$s1 Direccion $s0 tamano del nodo
   			beqz $t1, crearOcupado
   			#$s1 Direccion $s0 tamano del nodo
   			bgtz $t1, agregarOcupado
   			
   			
   			
   			lw    $s3, 4($s4)       # Se carga en $s3 el tama�o a reducir
   			sub   $s3, $s3, $s0	# Le resto $s3 (tamano del nodo ocupado) $s0 (tamano input a modificar)
   			sw    $s3, 4($s4)	# le asigno el nuevo tamano al nodo que se modifica
   			lw $t1, elementosLibres
   			#$s1 direccion $s0 tamano
   			beqz $1, crearLibre
   			#$s1 direccion $s0 tamano
   			bge $1, 1 agregarLibre
   			
   			move $v0, $zero
   			jr $ra
   			#MOSTRAR 0 Ya que se realizo con exito
   
    error_no_space:
    
    	li $a0, -2
    	j perror
   			
################################################## FREE ##################################################
   free:
   # El segmento de memoria referido por address vuelve a estar disponible para una pr�xima reserva.
   	# Entrada: $a0 -> Direccion de memoria a eliminar
   	move $s3, $a0
   	la   $s1, cabezaocupado	    # Se carga el primer nodo de la lista ocupado para buscar el espacio a liberar
   	lw   $t0, elementosLibres
   	li   $k1, 0

   	buscar4:
   		lw    $s4, ($s1)         # ($s1) ser� la direcci�n de cada nodo a iterar
   		lw    $s0, 4($s1)        # 4($s1) ser� el tama�o del nodo a iterar
   		ble   $s3, $s4, liberar  # Si es la direccion que se busca se libera
   		
   		lw    $s2, 8($s1)	 # Si no hay, sigue revisando los siguientes
   		move  $s1, $s2		 # Mueve a $s1 el siguiente nodo
   		bne   $s1, 0, buscar4	 # Si el siguiente no es nulo, vuelve a buscar
   		
   		li    $s0, -4
   		j     Error
   	liberar:
   		jal   eliminarocupado
   		lw    $s1, ($s1)         # Guarda en $s1 la direcci�n que se va a liberar
   		lw    $s0, 4($s1)	 # Guarda en $s0 el tama�o a liberar
   		beqz  $t0, crearLibre
   		bnez  $t0, agregarLibre
   		move  $k0, $v0
	   		
   		menor:
   			bgt  $t0, $k1, exit
   			la   $s5, cabezalibre
   			buscarme:
   				lw    $s6, ($s5)             # ($s5) ser� la direcci�n de cada nodo a iterar
   				lw    $s7, ($k0)             # ($k0) ser� la direccion en el espacio total
   				lw    $t8, 4($k0)	     # 4($k0) ser� el tama�o del espacio
   				add   $s7, $s7, $t8          # $s7 ser� la direccion a comparar	
   				beq   $s7, $s6, concatenar1
   		
   				lw    $s2, 12($s6)	 # Si no hay, sigue revisando los siguientes
   				move  $s6, $s2		 # Mueve a $s1 el siguiente nodo
   				bne   $s6, 0, buscarme	 # Si el siguiente no es nulo, vuelve a buscar
   				
   				addi  $k1, $k1, 1
   				b     mayor
   			
   			concatenar1:
   				lw    $t2, ($k0)
   				sw    $t2, ($s6)
   				lw    $t2, 4($k0)
   				lw    $t3, 4($s6)
   				add   $t2, $t2, $t3
   				sw    $t2, 4($s6)
   				
   				move  $s1, $k0
   				jal   eliminarlibre
   				
   				move  $k0, $s6
   				
   				b     mayor
   				
   		mayor:
   			bgt  $t0, $k1, exit
   			la $s5, cabezalibre
   			buscarma:
   				lw    $s6, ($s5)             # ($s5) ser� la direcci�n de cada nodo a iterar
   				lw    $s7, ($s6)             # ($s6) ser� la direccion en el espacio total en el nodo a iterar
   				lw    $t8, 4($s6)	     # 4($s6) ser� el tama�o del espacio en el nodo a iterar
   				add   $s7, $s7, $t8          # $s7 ser� la direccion a comparar	
   				lw    $t9, ($k0)	     # Direccion en el espacio total del nodo a verificar
   				beq   $s7, $t9, concatenar2
   		
   				lw    $s2, 12($s6)	 # Si no hay, sigue revisando los siguientes
   				move  $s6, $s2		 # Mueve a $s1 el siguiente nodo
   				bne   $s6, 0, buscarma	 # Si el siguiente no es nulo, vuelve a buscar
   				
   				addi  $k1, $k1, 1
   				b     menor
   			
   			concatenar2:
   				lw    $t2, 4($k0)
   				lw    $t3, 4($s6)
   				add   $t2, $t2, $t3
   				sw    $t2, 4($s6)
   				
   				move  $s1, $k0
   				jal   eliminarlibre
   				
   				move  $k0, $s6
   				
   				b     menor
   		exit:
   			jr $ra
################################################## PERROR ##################################################
   perror:
   # Entrada: $a0 -> C�digo error
   	lw  $s0, initerror
   	beq $a0, -1, imprime
   	lw  $s0, mallocerror
   	beq $a0, -2, imprime
   	lw  $s0, reallococerror
   	beq $a0, -3, imprime
   	lw  $s0, freeerror
   	beq $a0, -4, imprime
   	 
   	imprime:
   		jal print_string
   		jr  $ra
############################################### FUNCIONES AUXILIARES ###############################################      
   agregarLibre:
   # Funci�n que agrega un nodo a la lista de espacios libres
   	# Entradas: $s0 -> Tama�o a liberar
   	#	    $s1 -> Direcci�n a liberar
   
   	sw   $fp, 0($sp) 	# Se almacena al inicio del stack el valor que trae $fp
        move $fp, $sp  		# Se coloca el $fp de agregarLibre al inicio de su stack frame

        addi $sp, $sp, -20  	# Se abre espacio en el stack frame para el $fp, $s0, $s1, $t0 y $ra
        sw   $s0, 4($sp)    	# Se guarda $s0 
        sw   $s1, 8($sp)    	# Se guarda $s1
        sw   $t0, 12($sp)	# Se guarda $t0
        sw   $ra, 16($sp)	# Se guarda $ra
        
   	lw   $a0, libre 	# Carga en $a0 el tama�o del nodo libre
        li   $v0, 9		# Asigna en $v0 la direcci�n del nodo libre
        syscall
        
        la   $t0, cabezalibre   # Carga en $t0 la direcci�n de la cabeza libre
        buscar6:
        	lw     $s4, 8($t0)
   		beqz   $s4, continuar2   # Si el �ltimo es nulo, salta a continuar
   		
   		lw     $t3, 8($t0)	# Si no es el �ltimo, pasa al siguiente
   		move   $t0, $t3
   		b      buscar6
        
        continuar2:
        	sw   $v0, 8($t0)	# Guardamos el nodo en la lista libre
       		move $s2, $v0		# Guardamos en $s2 la direcci�n del nodo libre
        	sw   $s1, ($s2)		# Guarda la direcci�n del espacio a liberar en el nodo libre
       		sw   $s0, 4($s2)	# Guarda el tama�o del espacio a liberar en el nodo libre
        	li   $t1, 0
        	sw   $t1, 8($s2)	# Guarda el apuntador al siguiente nodo
        
        	lw   $fp, 0($sp)                 
        	lw   $s0, 4($sp)
        	lw   $s1, 8($sp)
        	lw   $t0, 12($sp)
        	lw   $ra, 16($sp)
        	addi $sp, $sp, 20	# Restauramos los stacks
        
        	addi $t0, $t0, 1
        	sw   $t0, elementosLibres # Suma una cantidad de libres
 
        	jr $ra
   
   
   crearLibre:
   # Funci�n que crea el nodo de la lista de libres cuando esta es vacia
   	# Entradas: $s0 -> Tama�o a reservar
   	#	    $s1 -> Direcci�n a reservar
   
   	sw   $fp, 0($sp) 	# Se almacena al inicio del stack el valor que trae $fp
        move $fp, $sp  		# Se coloca el $fp de crearLibre al inicio de su stack frame

        addi $sp, $sp, -20  	# Se abre espacio en el stack frame para el $fp, $s0, $s1, $t0 y $ra
        sw   $s0, 4($sp)    	# Se guarda $s0 
        sw   $s1, 8($sp)    	# Se guarda $s1
        sw   $t0, 12($sp)	# Se guarda $t0
        sw   $ra, 16($sp)	# Se guarda $ra
        
   	lw   $a0, libre		# Carga en $a0 el tama�o del nodo ocupado
        li   $v0, 9		# Asigna en $v0 la direcci�n del nodo ocupado
        syscall
        
        la   $t0, cabezalibre   # Carga en $t0 la direcci�n de la cabeza libre
        sw   $v0, ($t0)		# Guardamos el primer nodo de la lista libre
        move $s2, $v0		# Guardamos en $s2 la direcci�n del nodo libre
        
        lw   $t4, ($s1)
        sw   $t4, ($s2)		# Guarda la direcci�n del espacio a liberar en el nodo libre
        sw   $s0, 4($s2)	# Guarda el tama�o del espacio a liberar en el nodo libre
        li   $t1, 0
        sw   $t1, 12($s2)	# Guarda el apuntador al siguiente nodo
        
        lw   $fp, 0($sp)                 
        lw   $s0, 4($sp)
        lw   $s1, 8($sp)
        lw   $t0, 12($sp)
        lw   $ra, 16($sp)
        addi $sp, $sp, 20	# Restauramos los stacks
        
        addi $t0, $t0, 1
        sw   $t0, elementosLibres # Suma una cantidad de ocupados
 
        jr $ra
   
   eliminarocupado:
   # Funci�n que elimina un nodo de la lista de espacios ocupados
   	# Entrada: $s1 -> Nodo a eliminar
        sw   $fp, 0($sp) 	# Se almacena al inicio del stack el valor que trae $fp
        move $fp, $sp  		# Se coloca el $fp de eliminarOcupado al inicio de su stack frame

        addi $sp, $sp, -20  	# Se abre espacio en el stack frame
        sw   $s0, 4($sp)    	
        sw   $s1, 8($sp)    	
        sw   $s4, 12($sp)
        sw   $ra, 16($sp)	# Se guarda $ra
   	
   	lw   $s0, cabezaocupado

   	beq  $s0, $s1, eliminarcabecera2
   	bne  $s0, $s1, eliminarnodo2
   	
   	eliminarcabecera2:
   		lw   $s2, 12($s0)	 # Carga el siguiente nodo en $s2
   		sw   $s2, cabezaocupado # Convierte la cabeza en el siguiente y elimina la cabeza
   		
   		lw   $fp, ($sp)
   		lw   $s0, 4($sp)    	
        	lw   $s1, 8($sp)    	
        	lw   $s4, 12($sp)
        	lw   $ra, 16($sp)
        	addi $sp, $sp, 20
        	
        	lw   $t7, elementosOcupados
        	subi $t7, $t7, 1
        	sw   $t7, elementosOcupados
        				
        	jr $ra
   		
   	eliminarnodo2:
   		lw   $s2, 12($s1)	# Guardamos la direcci�n del siguiente nodo
   		buscar5:
   			lw    $s4, 12($s0)       # 12($s0) ser� la direcci�n del nodo
   			beq   $s1, $s4, cambiar2 # Si las direcciones son iguales, se cambia el siguiente del anterior
   						 # por el siguiente actual.
   			lw    $s3, 12($s0)	 # Si no hay, sigue revisando los siguientes
   			move  $s0, $s3		 # Mueve a $s0 el siguiente nodo
   			bne   $s0, 0, buscar5	 # Si el siguiente no es nulo, vuelve a buscar
   		cambiar2:
   			lw    $s4, 12($s1)	 # Guarda la direcci�n del siguiente del nodo actual
   			sw    $s4, 12($s0)	 # Cambia el siguiente del nodo anterior al nodo siguiente del actual
   			
   			lw   $fp, ($sp)
   			lw   $s0, 4($sp)    	
        		lw   $s1, 8($sp)    
        		lw   $s4, 12($sp)
        		lw   $ra, 16($sp)
        		addi $sp, $sp, 20
        		
        		lw   $t7, elementosOcupados
        		subi $t7, $t7, 1
        		sw   $t7, elementosOcupados
        		
        		jr $ra
   				
   eliminarlibre:
   # Funci�n que elimina un nodo de la lista de espacios libres 
   	# Entrada: $s1 -> Nodo a eliminar
   	sw   $fp, 0($sp) 	# Se almacena al inicio del stack el valor que trae $fp
        move $fp, $sp  		# Se coloca el $fp de eliminarlibre al inicio de su stack frame

        addi $sp, $sp, -28  	# Se abre espacio en el stack frame
        sw   $s0, 4($sp)    	
        sw   $s1, 8($sp)    	
        sw   $s2, 12($sp)	
        sw   $s3, 16($sp)
        sw   $s4, 20($sp)
        sw   $ra, 24($sp)	# Se guarda $ra
   	
   	lw   $s0, cabezalibre
   	beq  $s0, $s1, eliminarcabecera
   	bne  $s0, $s1, eliminarnodo
   	
   	eliminarcabecera:
   		lw   $s2, 8($s0)	# Carga el siguiente nodo en $s2
   		sw   $s2, cabezalibre   # Convierte la cabeza en el siguiente y elimina la cabeza
   		
   		lw   $fp, ($sp)
   		lw   $s0, 4($sp)    	
        	lw   $s1, 8($sp)    	
        	lw   $s2, 12($sp)	
        	lw   $s3, 16($sp)
        	lw   $s4, 20($sp)
        	lw   $ra, 24($sp)
        	addi $sp, $sp, 28
        	
        	subi $t0, $t0, 1
        	sw   $t0, elementosLibres
        				
        	jr $ra
   		
   	eliminarnodo:
   		lw   $s2, 8($s1)	# Guardamos la direcci�n del siguiente nodo
   		buscar3:
   			lw    $s4, 8($s0)        # 8($s0) ser� la direcci�n del nodo
   			beq   $s1, $s4, cambiar  # Si las direcciones son iguales, se cambia el siguiente del anterior
   						 # por el siguiente actual.
   			lw    $s3, 8($s0)	 # Si no hay, sigue revisando los siguientes
   			move  $s0, $s3		 # Mueve a $s0 el siguiente nodo
   			bne   $s0, 0, buscar3	 # Si el siguiente no es nulo, vuelve a buscar
   		cambiar:
   			lw    $s4, 8($s1)	 # Guarda la direcci�n del siguiente del nodo actual
   			sw    $s4, 8($s0)	 # Cambia el siguiente del nodo anterior al nodo siguiente del actual
   			
   			lw   $fp, ($sp)
   			lw   $s0, 4($sp)    	
        		lw   $s1, 8($sp)    	
        		lw   $s2, 12($sp)	
        		lw   $s3, 16($sp)
        		lw   $s4, 20($sp)
        		lw   $ra, 24($sp)
        		addi $sp, $sp, 28
        		
        		subi $t0, $t0, 1
        		sw   $t0, elementosLibres
        		
        		jr $ra
   
   agregarOcupado:
   # Funci�n que agrega un nodo a la lista de ocupados
   	# Entradas: $s0 -> Tama�o a reservar
   	#	    $s1 -> Direcci�n a reservar
   
   	sw   $fp, 0($sp) 	# Se almacena al inicio del stack el valor que trae $fp
        move $fp, $sp  		# Se coloca el $fp de agregarOcupado al inicio de su stack frame

        addi $sp, $sp, -20  	# Se abre espacio en el stack frame para el $fp, $s0, $s1, $t0 y $ra
        sw   $s0, 4($sp)    	# Se guarda $s0 
        sw   $s1, 8($sp)    	# Se guarda $s1
        sw   $t0, 12($sp)	# Se guarda $t0
        sw   $ra, 16($sp)	# Se guarda $ra
        
   	lw   $a0, ocupado	# Carga en $a0 el tama�o del nodo ocupado
        li   $v0, 9		# Asigna en $v0 la direcci�n del nodo ocupado
        syscall
        
        la   $t0, cabezaocupado # Carga en $t0 la direcci�n de la cabeza ocupado
        buscar2:
        	lw     $s4, 12($t0)
   		beqz   $s4, continuar   # Si el �ltimo es nulo, salta a continuar
   		
   		lw     $t3, 12($t0)	# Si no es el �ltimo, pasa al siguiente
   		move   $t0, $t3
   		b      buscar2
        
        continuar:
        	sw   $v0, 12($t0)	# Guardamos el nodo en la lista ocupado
       		move $s2, $v0		# Guardamos en $s2 la direcci�n del nodo ocupado
        	sw   $s1, ($s2)		# Guarda la direcci�n del espacio reservado en el nodo ocupado
       		sw   $s0, 4($s2)	# Guarda el tama�o del espacio reservado en el nodo ocupado
        	li   $t1, 0
        	sw   $t1, 12($s2)	# Guarda el apuntador al siguiente nodo
        
        	lw   $fp, 0($sp)                 
        	lw   $s0, 4($sp)
        	lw   $s1, 8($sp)
        	lw   $t0, 12($sp)
        	lw   $ra, 16($sp)
        	addi $sp, $sp, 20	# Restauramos los stacks
        
        	addi $t0, $t0, 1
        	sw   $t0, elementosOcupados # Suma una cantidad de ocupados
 
        	jr $ra
   
   
   crearOcupado:
   # Funci�n que crea el nodo de la lista de ocupados cuando esta es vacia
   	# Entradas: $s0 -> Tama�o a reservar
   	#	    $s1 -> Direcci�n a reservar
   
   	sw   $fp, 0($sp) 	# Se almacena al inicio del stack el valor que trae $fp
        move $fp, $sp  		# Se coloca el $fp de crearOcupado al inicio de su stack frame

        addi $sp, $sp, -20  	# Se abre espacio en el stack frame para el $fp, $s0, $s1, $t0 y $ra
        sw   $s0, 4($sp)    	# Se guarda $s0 
        sw   $s1, 8($sp)    	# Se guarda $s1
        sw   $t0, 12($sp)	# Se guarda $t0
        sw   $ra, 16($sp)	# Se guarda $ra
        
   	lw   $a0, ocupado	# Carga en $a0 el tama�o del nodo ocupado
        li   $v0, 9		# Asigna en $v0 la direcci�n del nodo ocupado
        syscall
        
        la   $t0, cabezaocupado # Carga en $t0 la direcci�n de la cabeza ocupado
        sw   $v0, ($t0)		# Guardamos el primer nodo de la lista ocupado
        move $s2, $v0		# Guardamos en $s2 la direcci�n del nodo ocupado
        
        lw   $t4, ($s1)
        sw   $t4, ($s2)		# Guarda la direcci�n del espacio reservado en el nodo ocupado
        sw   $s0, 4($s2)	# Guarda el tama�o del espacio reservado en el nodo ocupado
        li   $t1, 0
        sw   $t1, 12($s2)	# Guarda el apuntador al siguiente nodo
        
        lw   $fp, 0($sp)                 
        lw   $s0, 4($sp)
        lw   $s1, 8($sp)
        lw   $t0, 12($sp)
        lw   $ra, 16($sp)
        addi $sp, $sp, 20	# Restauramos los stacks
        
        addi $t0, $t0, 1
        sw   $t0, elementosOcupados # Suma una cantidad de ocupados
 
        jr $ra
             
   Error:
   # Subrutina que indica el error de init al perror.
        # Entrada: $s0 -> Codigo de Error
        move $a0, $s0
        jal  perror
        j    retorno
        
   retorno:
   # Subrutina que retorna
   	# Entrada: $a0 -> Valor a devolver   	
        move   $v0, $a0		# Retorna 0 al efectuarse correctamenta
        jr     $ra
   
   print_string:
    	move    $a0,$s0
    	li      $v0,4
    	syscall
    	jr      $ra
