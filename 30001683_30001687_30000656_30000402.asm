.data
	result: .asciiz "O resultado: "
	text5: .asciiz "Peça rodada 180 graus, "
	text4: .asciiz "Peça em posicao normal,  "
	text3: .asciiz "Nao foi encontrada a peca. "
	text2: .asciiz "Posicao : Linha "
 	text1: .asciiz ", Coluna "

 	Largura: .half 32			
	Altura: .half 32		
	Bits_branco:	.word 0x00ffffff	
	Fundo_preto:.word 0x00000000
	
#GENERATOR.asm
#Alterar o seguinte mapa consoante a vossa forma (4x4), em que cada entrada (x,y) deve ser a localizacao de "1". 
#Considera-se um mapa e forma (4x4). Caso a sua forma 2D seja maior que 4x4, o codigo tera de ser modificado de forma concordante.
#Neste exemplo especifico, considerou-se a forma 2D identificada no trabalho como a forma "1".

#Definicao das entradas (x,y) que compoe a forma 2D
figure_x: .byte 0,1,2,1
figure_y: .byte 0,0,0,1

#Definicao das entradas (x,y) que compoe a forma 2D rodada em 180 graus
Inverted_figure_x: .byte 1,0,1,2
Inverted_figure_y: .byte 0,1,1,1

#Numero de celulas a 1 da forma escolhida. Neste caso, para a forma 1, temos 4 valores (1,0), (0,1), (1,1), (2,1) 
fig_cells: .byte 4

#Dimensao do bitmap e' dada por l^2, onde l representa a dimensao do lado, que deve ser sempre impar.
#Para este caso, l=11. 
d: .word 31

#espaco pre-alocado para o guardar bitmap na memoria [!]
map: .space 10000

.text

#Gerar um mapa aleatorio com 0's e 1's
jal GetRandomMap

#Faz print do resultado do mapa random (descomentar a linha seguinte)
#jal PrintMap

#Coloca a forma 2D no mapa gerado, numa posicao aleatoria
jal GetMapwPiece

#Faz print do resultado no mapa com a peca
jal PrintMap

j exit


GetRandomMap:
#Gera um mapa aleatorio com 0's e 1's
	
	#protege as variaveis usadas
	addi $sp,$sp,-8	
	sw $s1,0($sp)
	sw $s2,4($sp)
	sw $s0,8($sp)
	

	#$t1 - area do mapa
	lw $t1, d
	
	multu $t1,$t1
	
	#$t2 - Numero total de entradas no mapa 
	mflo $t2

	#Guarda em $s0 o endereco do mapa a preencher 
	la $s0, map

	#inicia o contador iterador no array com todas as entradas do mapa 
	li $t4,0
	
	#Prepara a execucao de randoms para 
	li $v0, 42 # Codigo associado a' geracao de numeros inteiros aleatorios
	li $a0, 1	
	addi $a1, $t2, 1 #fin [!]

	#Percorre todos as entradas, determinando se sao preenchidas a "0" ou a "1". 
	#(Este codigo pode ser modificado para se tornar o preenchimento mais ou menos denso de 1's, 
	# correndo-se o risco, no caso mais denso, de existirem varias formas 2D iguais as que procuramos)
	#Neste momento, guarda 4 zeros, e depois, de forma aleatoria, coloca um "1" ou um "0".
        LOOP0:	

		beq $t4,$t2,return01     		
		addi $s0, $s0, 1		
		sb $zero, ($s0) 	#Guarda 0 nesta posicao
		addi $t4,$t4,1
		
		beq $t4,$t2,return01
		addi $s0, $s0, 1		
		sb $zero, ($s0) 	#Guarda 0 nesta posicao
		addi $t4,$t4,1
		
		beq $t4,$t2,return01
		addi $s0, $s0, 1		
		sb $zero, ($s0) 	#Guarda 0 nesta posicao		
		addi $t4,$t4,1
		
		beq $t4,$t2,return01
		addi $s0, $s0, 1		
		sb $zero, ($s0) 	#Guarda 0 nesta posicao		
		addi $t4,$t4,1		
		
		beq $t4,$t2,return01    
		addi $s0, $s0, 1 
		li $a1, 2		
		syscall
		
		#guarda random 1 ou 0 - comentar esta linha para ter um mapa sem ruido	
		sb $a0, ($s0) 		
						
		addi $t4,$t4,1
		j LOOP0

	return01:
	

	lw $s1,0($sp)
	lw $s2,4($sp)
	lw $s0,8($sp)	
	addi $sp,$sp,8
	 	
	jr $ra

GetMapwPiece:

	#proteje variaveis usadas
	addi $sp,$sp,-16
	sw $s7,0($sp)
	sw $s4,4($sp)
	sw $s0,8($sp)
	sw $s5,12($sp)
	sw $s6,16($sp)
	

	#lado do mapa - $s0
	lw $s0, d
	multu $s0,$s0
	
	# area do mapa
	mflo $t2
	
	#encontra aletoriamente uma posicao para a peca ($s4)
	li $v0, 42
	li $a0, 1
	addi $a1, $t2, 1
	syscall
	move $s4, $a0 # em $s4 fica a posicao da peca	
	
	#descomentar a proxima linha para colocar a peca numa posicao conhecida (15) - para debuging 
	#Atencao que a posicaoo da peca conta a partir de 0. 
	#li $s4, 15
	
	li $a0, 1
	li $a1, 2
	syscall

	move $v0, $a0 #guarda em $vo a rotaco da peca (parametro para jal rotate
	
	#verifica se a peca deve ser rodada de 180 graus consoante o random anterior
	bne $v0, $zero, nrotate
		
		#prepara a chamada da funcao rotate, guardando $ra
		addi $sp, $sp, -4
		sw $ra, ($sp) 
		#Roda a peca 180 graus
		jal rotate
	
	#recupera o $ra do $sp
	lw $ra, ($sp) 
	addi $sp, $sp, 4
	
	
	nrotate:
	
	#vai buscar o inicio do mapa (endereï¿½o) e guarda em $t7
	la $t7, map
	
	#carrega os enderecos das posicoes x,y da peca 	
	la $s5, figure_x
	la $s6, figure_y	
	
	#carrega o numero de entradas da peca
	lb $s7, fig_cells
	
	#faz um loop que precorre todas as entradas da peca ($s7) e devolve um mapa com a peca inserida.
	LOOP2:	
		beq $s1, $s7, return02
				
		#vai buscar os valores da primeira entrada para x e para y		
		lb $t5, ($s5) #x
		lb $t6, ($s6) #y relativos de cada ponto da peca
		
		
		divu $s4, $s0 		
		#posicao x da peca no mapa dada a posicao absoluta da peca encontrada anteriormente
		mfhi $t3
		
		#posicao y da peca no mapa dada a posicao absoluta da peca encontrada anteriormente
		mflo $t8
		
				
		#Posicao x,y final do elemento (posicao do elemento na peca + posicao da peca no mapa): 
		add $t5, $t5, $t3 #x
		add $t6, $t8, $t6 #y
	
		li $t9, 1
		
		multu $t6, $s0
		mflo $t3
		#$s2 - Posicao final no array da entrada da peca de cada iteracao do loop
		add $t0, $t3, $t5
		#$t6 - endereco dessa entrada						
		add $t6, $t7, $t0
		
		#escrita do valor 1 nesse endereco
		sb $t9, ($t6)
		
		addi $s1, $s1, 1 #iteracao no loop		
		addi $s5, $s5, 1 #iteracao do endereco x
		addi $s6, $s6, 1 #iteracao do endereco y	
			
		j LOOP2	
	
	return02:
	

	sw $s7,0($sp)
	sw $s4,4($sp)
	sw $s0,8($sp)
	sw $s5,12($sp)
	sw $s6,16($sp)
	
	addi $sp,$sp,16	
		
	jr $ra		

PrintMap:
#imprime o map com 0's e 1's no ecran.
	

	#lado do mapa - $s0
	lw $t1, d
	multu $t1,$t1
	# area do mapa
	mflo $t2
	
	
	#inicializa a iteracao
	li $t4,0
	
	
	la $t7, map
	
	#Faz Print do mapa, iterando por todas as celulas
	LOOP1:	
		beq $t4,$t2,return2
		lb $a0, ($t7)
		addi $t7, $t7, 1 
		li  $v0, 1          		
		#imprime o valor que estao no mapa ($t7)
		syscall
		
		li $v0, 0xB
		addi $a0, $zero, 0x20
		#imprime um zero de separacao horizontal
		syscall		

		li $v0, 1
		addi $t4, $t4,1
		divu $t4, $t1	#procura o resto para saber se tem que introduzir uma quebra de linha            
		mfhi $t3				
		#se chegou ao fim da linha imprime um carrier - return - nova linha
		bne $zero, $t3, next
			li $v0, 0xB
			addi $a0, $zero, 0xA
			syscall
			li $v0, 1				
		
		next:
		
		j LOOP1

	return2:	

	jr $ra


rotate:
#roda uma peca de 180 graus - igual a simetria em x e simetria em y
	
	#carrega entradas em x e dimensao da peca
	la $t1, figure_x
	lb $t3, fig_cells 
	
	move $t4, $zero
	#itera em cada entrada em x para fazer simetria em x
	LOOP3:
		beq, $t3, $t4, exit2		
		
		#faz simetria em x, usando $t5 para guardar o valor		
		lb $t5, ($t1)
		#partindo do principio que a peca tem 4 entradas de lado, a simetria deve ser 4-x, 
		#sendo x a posicao actual deste "1" 
		li $t6, 4
		#subtrai a 4 a posicao actual
		sub $t5, $t6, $t5
		
		#guarda a entrada de novo no map.
		sb $t5, ($t1)
		
		#itera
		addi $t4, $t4, 1
		addi $t1, $t1, 1
		j LOOP3
	exit2:
	
	#carrega entradas em y e dimensao da peca
	la $t1, figure_y
	
	move $t4, $zero
	#itera em cada entrada em y para fazer simetria em y (igual ao codigo para x)
	LOOP4:
		beq, $t3, $t4, exit3				
		lb $t5, ($t1)
		li $t6, 4
		sub $t5, $t6, $t5
		sb $t5, ($t1)
		
		addi $t4, $t4, 1
		addi $t1, $t1, 1
		j LOOP4
	exit3:


	jr $ra



exit:

#prepara a chamada da funcao, guardando $ra
addi $sp, $sp, -4
sw $ra, ($sp) 

jal Algoritmo

lw $ra, ($sp)
addi $sp, $sp, 4

beq $t9, $zero, NaoEncontrou

j Fim




Algoritmo:
#Pesquisa Peca para baixo
	
	#lado do mapa - $t1
	lw $t1, d
	multu $t1,$t1
	
	# area do mapa
	mflo $t2
							
	#inicializa a iteracao do ciclo do map
	li $t4,0		
	
	la $t7, map
	
	#posicao x e y da peca
	li $s4, 0 
	li $s2, 0
	
	#Flag se encontrou Peca
	li $s0, 0

	lw $s7, Fundo_preto		# Cor de Fundo

	# Area a Preto
	move $a0, $s7 		# Coloca a cor de fundo 
	
	addi $sp, $sp, -8
	sw $ra, ($sp) 
	
	jal CarregaMemoria

	lw $ra, ($sp)
	addi $sp, $sp, 8
			
	#Itera por todas as celulas
	Ciclo:	
		beq $t4,$t2,return9
		lb $a0, ($t7)
		addi $t7, $t7, 1 
		
		li $t3, 0
		
		#prepara a chamada da funcao, guardando $ra
		addi $sp, $sp, -12
		sw $ra, ($sp) 
		
		jal verificavalores

		#recupera o $ra do $sp
		lw $ra, ($sp) 
		addi $sp, $sp, 12

		#li $v0, 1
		addi $t4, $t4, 1   #incrementa iteracao
		
		proximo:		
		j Ciclo

		verificavalores:
				#$s5 valor na posicao atual
				li $s1, 0
				lb $s5, map($t4)
				
				#prepara a chamada da funcao, guardando $ra
				addi $sp, $sp, -16
				sw $ra, ($sp) 
				
				jal BitmapDisplay
				
				lw $ra, ($sp)
				addi $sp, $sp, 16
		 
		 		#limpa variaveis usadas em BitmapDisplay
		 		li $s1, 0
		 		li $s3, 0
		 		li $s6, 0
				
				beq $s5, 1, CicloPeca
				#se nao tiver encontrado a peca antes, pesquisa peca invertida
				beq $t3, 0, CicloPecaInvertida
				jr $ra		
							
				CicloPeca:
					beq $t3, 5, posicaonormal
										
					lb $t6, figure_y($t3)
					lb $t8, figure_x($t3) 

					#calcular e verificar na nova posicao do map
					#(linha * 31) + coluna
					mul $t5, $t1, $t6
					add $t5, $t5, $t8
			
					#somar valor calculado na posicao atual
					add $t5, $t4, $t5
							
					# se valor calculado for maior que d*d
					# continua ciclo map
					blt $t2, $t5, sai 
																																							
					# Verifica o valor
					# na posicao calculada
					lb $s5, map($t5)
					
					beq $s5, $zero, sai
		
					#iteracao interior
					addi $t3, $t3, 1 
																																								
					j CicloPeca  					

				CicloPecaInvertida:
					beq $t3, 5, posicaoinvertida
					
					lb $t6, Inverted_figure_y($t3)
					lb $t8, Inverted_figure_x($t3) 

					#calcular e verificar na nova posicao do map
					#(linha * 31) + coluna
					#MULTiplicacao
					mul $t5, $t1, $t6
					add $t5, $t5, $t8
			
					add $t5, $t4, $t5
							
					# se valor calculado for maior que d*d
					# continua ciclo map
					blt $t2, $t5, sai 
																																							
					# Verifica o valor
					# na posicao calculada
					lb $s5, map($t5)
					
					beq $s5, $zero, sai
		
					#iteracao interior
					addi $t3, $t3, 1 
																																								
					j CicloPecaInvertida  
			
				#PRINTS das posicoes
				posicaoinvertida:
					addi $t4, $t4, 1
					li $v0,4        
					la $a0,text5    # "virado para cima"
					syscall
				
					j posicoes
				
				posicaonormal:
					li $v0,4        
					la $a0,text4    # "virado para baixo"
					syscall
				
					j posicoes
				
				posicoes:
					# Encontrou a peï¿½a
					li $t9, 1
					
					# Devolve a linha
					divu $s3, $t4, $t1	#Resto da divisao             
					mflo $s3 
				
					#linha   
					addi $s6, $s3, 1
				
					# DEVOLVE A COLUNA          
					mfhi $s3
				
					#coluna
					add $s7, $zero, $s3	
					
					li $v0,4        
					la $a0,text2    # "Posicao onde foi encontrada:"
					syscall	
					
					add $a0, $s6, $zero				   
					li $v0,1        
					syscall	

					li $v0,4        
					la $a0,text1   
					syscall		

					# DEVOLVE A COLUNA          
					add $a0, $s7, 1 
					li $v0,1        
					syscall
				
				sai:	
					li $t3, 0
					jr $ra
					
				BitmapDisplay:
					#$s5 = 1 desenha a branco no Bitmap Display
					beq $s5, 1, Desenha					
					jr $ra
	
				Desenha:
					# DEVOLVE A LINHA
					divu $s3, $t4, $t1	#Resto da divisao             
					mflo $s3 
				
					#linha   
					add $s6, $zero, $s3
				
					# DEVOLVE A COLUNA          
					mfhi $s3
				
					#coluna
					add $s7, $zero, $s3
				
					move $a1, $s6        #linha
					move $a0, $s7        #coluna
					
					#prepara a chamada da funcao, guardando $ra
					addi $sp, $sp, -20
					sw $ra, ($sp) 
					
					jal CoordenadasEmMemoria		# Posicao da peca

					lw $ra, ($sp)			
					addi $sp, $sp, 20

					move $s0, $v0		# Guarda o em memï¿½ria

					lw $s6, Bits_branco		# Guarda a cor
			
					# Desenha a cor
					move $a0, $s6 			
					move $a1, $s0 		# Guarda a posicao em a1

					#prepara a chamada da funcao, guardando $ra
					addi $sp, $sp, -24
					sw $ra, ($sp) 

					jal Putcolor		# coloca a branco na coordenada corrente

					lw $ra, ($sp)
					addi $sp, $sp, 24
					
					jr $ra
				
				return9:			
					jr $ra

CoordenadasEmMemoria:
		move $v0, $a0 			# Move coordenada x para v0
		lh $a0, Largura			
		multu $a0, $a1			# Obtem Posicao do y
		
		mflo $a0			# Resto da divisï¿½o
		addu $v0, $v0, $a0		# Soma x com o Resto da divisao
		sll $v0, $v0, 2			# Multiplica por 4 (bytes) 
		addu $v0, $v0, 0x10010000	# Adiciona-se o endereï¿½o a v0 para obter o endereï¿½o de memï¿½ria
		jr $ra				
		

CarregaMemoria:
		lh $a1, Largura			# Calcula posicao final
		lh $a2, Altura
		multu $a1, $a2			# Multiplica Largura pela Altura
		
		mflo $a2			# Resto da divisao
		sll $a2, $a2, 2			# Multiplica por 4 (bytes)
		add $a2, $a2,  0x10010000	# Adiciona o endereco a v0 para obter o endereco de memoria
		
		li  $a1, 0x10000000 		# Adiciona $a1
		jr $ra

Putcolor:
		sw $a0, ($a1)			# Coloca a cor
		jr $ra				

NaoEncontrou:
	li $v0,4        
	la $a0,text3    # "Nao encontrou a peca"
	syscall	

Fim: