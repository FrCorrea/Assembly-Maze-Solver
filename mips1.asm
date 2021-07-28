.data
arquivo: .asciiz "maze-1-2.pgm"           # Nome do arquivo a ser lido
nome_arquivo: .asciiz "Solucao.pgm"       # Nome do arquivo a ser escrito                
buffer: .space 128000                     # Quantidade de bits a ser utilizida

pula: .asciiz "\n"                        # Código do ASCII para nova linha
return: .asciiz "\r"                      # Código do ASCII para return
espaco: .asciiz " "                       # Código do ASCII para espaço
zero: .asciiz "0"                         # Código do ASCII para zero
dois: .asciiz "2"                         # Código do ASCII para dois

.text
abre_arquivo:
    li $v0, 13                            # Atribui 13 para $v0. Código para abrir arquivo
    la $a0, arquivo                       # Atribui o arquivo a ser lido para $a0, argumento do syscall
    li $a1, 0                             # Atribui 0 para $a1, argumento do syscall
    li $a2, 0                             # Atribui 0 para $a2, argumento do syscall
    syscall                               # Chama o sistema; o sistema atribui em $v0 o endereço do arquivo
    move $s0, $v0                         # Salva o endereço do arquivo em $s0
    
le_arquivo:
    li   $v0, 14                          # Atribui 14 para $v0. Codigo para ler arquivo
    move $a0, $s0                         # Atribui o endereço do arquivo (contido em $s0) para $a0, argumento do syscall
    la   $a1, buffer                      # Atribui o buffer para $a1, onde o conteúdo será guardado, argumento do syscall
    li   $a2, 128000                      # Atribui a quantidade de bits a ser lido para $a0, argumento do syscall
    syscall                               # Chama o sistema; o sistema atribui em $v0 o número de caracteres lidos
    move $t0, $v0                         # Guarda em $v0 o número de caracteres lidos
    
    li $v0, 16                            # Como o $a0 já tem o endereço do arquivo a ser fechado, só atribuimos 16 para $v0. Codigo para fechar arquivo
    syscall                               # Chama o sistema, que fecha o arquivo
    
    la $s0, buffer                        # Coloca o endereço do buffer no começo de $s0
       
    li $t2, 0                             # Contador auxiliar iniciado em 0 no $t2
    lb $t3, pula                          # Código do ASCII para nova linha no $t3
acha_proporcao: # Não sobrepor $t0

    lb $t1, 0($s0)                        # Pega o byte contido na posição atual do vetor
    beq $t1, $t3, conta1                  # Analisa se o byte contido na posição atual do vetor é igual ao código do ASCII para nova linha. Se for igual entra no conta1
    addi $s0, $s0, 1                      # Se não for igual, adiciona-se 1 na posição do vetor, para checar a próxima célula
    j acha_proporcao                      # E voltamos ao início do loop
    
    conta1:                               # Se o byte contido no vetor for igual ao código do ASCII para nova linha:
       addi $s0, $s0, 1                   # Adiciona-se 1 na posição do vetor, para checar a próxima célula
       addi $t2, $t2, 1                   # Adiciona-se 1 no vetor auxiliar para indicar que uma linha foi pulada
       bne $t2, 2, acha_proporcao         # Como a proporção se encontra na 3ª linha, se ainda não tivermos pulado de linha 2 vezes, voltamos ao início do loop 

    li $t2, 0                             # Quando tivermos pulado de linha duas vezes, resetamos o contador auxiliar, que será agora o registrador para largura
    lb $t3, espaco                        # E colocamos o código do ASCII para espaço no $t3
pega_largura: # Não sobrepor $t0 e $t1

    lb $t1, 0($s0)                        # Pega o byte contido na posição atual do vetor
    beq $t1, $t3, exit                    # Analisa se o byte contido na posição atual do vetor é um espaço. Se for igual, sai do loop
    mul $t2, $t2, 10                      # Se não for igual, multiplicamos por o valor contido no registrador da largura (aumentando a casa decimal)
    sub $t1, $t1, 48                      # Transformamos o byte, que está em ASCII, para decimal, diminuindo 48, que é a diferença dos valores
    add $t2, $t2, $t1                     # Somamos o valor no registrador da largura
    addi $s0, $s0, 1                      # Adiciona-se 1 na posição do vetor, para checar a próxima célula
    j pega_largura                        # E voltamos ao início do loop

exit: # Não sobrepor $t0 e $t1

    li $s1, 0                             # Reseta $s1
    move $s1, $t2                     	  # $s1 passa a ser o registrador da largura
    li $t2, 0                             # Ao sair do loop, resetamos $t2, que será o registrador para altura
    lb $t3, return                        # Colocamos o código do ASCII para return no $t3
    addi $s0, $s0, 1                      # Adiciona-se 1 na posição do vetor, para olhar a próxima célula (a célula atual é um espaço)

pega_altura: # Não sobrepor $t0, $t1 e $s1

    lb $t1, 0($s0)                        # Pega o byte contido na posição atual do vetor
    beq $t1, $t3, exit2                   # Analisa se o byte contido na posição atual do vetor é o código para nova linha. Se for igual, sai do loop
    mul $t2, $t2, 10                      # Se não for igual, multiplicamos por o valor contido no registrador da altura (aumentando a casa decimal)
    sub $t1, $t1, 48                      # Transformamos o byte, que está em ASCII, para decimal, diminuindo 48, que é a diferença dos valores
    add $t2, $t2, $t1                     # Somamos o valor no registrador da altura
    addi $s0, $s0, 1                      # Adiciona-se 1 na posição do vetor, para checar a próxima célula
    j pega_altura                         # E voltamos ao início do loop

exit2:

    li $s2, 0                             # Reseta $s2
    add $s2, $s2, $t2                     # $s2 passa a ser o registrador da altura
    lb $t3, zero                          # Colocamos o código do ASCII para zero no $t3
    lb $t4, dois                          # Colocamos o código do ASCII para dois no $t4
    
procura_labirinto: # Não sobrepor $t0, $t1, $s1 e $s2

    lb $t1, 0($s0)                        # Pega o byte contido na posição atual do vetor
    beq $t1, $t3, exit3                   # Analisa se o byte contido na posição atual do vetor é zero. Se for igual sai do loop
    addi $s0, $s0, 1                      # Se não for igual, adiciona-se 1 na posição do vetor, para checar a próxima célula
    j procura_labirinto                   # E voltamos ao início do loop

exit3:
   
    move $s3, $s0 # Guarda o inicio do labirinto
    li $t5, 1                             # Contador auxiliar de colunas
    li $t6, 1                             # Contador auxiliar de linhas
    li $t7, 0                             # Contador auxiliar de entradas

procura_entrada: # Não sobrepor $t0, $t1, $s1 e $s2

    lb $t1, 0($s0)                        # Pega o byte contido na posição atual do vetor
    beq $t1, $t3, verifica_entrada        # Caso $t1 for igual a 0,
    beq $t1, $t4, verifica_entrada        # Ou 2, precisamos contar que uma coluna foi encontrada, então vai para verifica_entrada
    addi $s0, $s0, 1                      # Se não for igual, adiciona-se 1 na posição do vetor, para checar a próxima célula
    j procura_entrada                     # E voltamos ao início do loop
    
    verifica_entrada:
        beq $t5, 1, entrada_check         # Caso o vetor esteja na primeira coluna do labirinto,
        beq $t5, $s1, entrada_check2      # Na última coluna,
        beq $t6, 1, entrada_check         # Na primeira linha do labirinto,
        beq $t6, $s2, entrada_check       # Ou na última linha, vai para entrada_check, se estiver na última coluna vai para entrada_check2
        addi $t5, $t5, 1                  # Caso nenhum destes casos seja satisfeito, adicionamos 1 no auxiliar de coluna, para contar a coluna encontrada
        addi $s0, $s0, 1                  # Adicionamos 1 na posição do vetor, para checar a próxima célula
        j procura_entrada                 # E voltamos ao início do loop
        
        entrada_check:
            addi $t5, $t5, 1              # Contamos que a coluna foi achada, pois não usaremos mais este auxiliar até voltarmos ao loop
            beq $t1, $t4, marca_entrada   # Se o byte contido na posição atual do vetor é dois (primeiro caractere de 255/branco) significa que é uma entrada, então vai para marca_entrada
            addi $s0, $s0, 1              # Se não for igual, adiciona-se 1 na posição do vetor, para checar a próxima célula
            j procura_entrada             # E voltamos ao início do loop 
            
        entrada_check2:                   # Se o byte contido na posição atual do vetor estiver na última coluna:
            li $t5, 1                     # Reiniciamos a contagem de colunas,
            addi $t6, $t6, 1              # E contamos mais uma linha
            beq $t1, $t4, marca_entrada   # Se o byte contido na posição atual do vetor é dois (primeiro caractere de 255/branco) significa que é uma entrada, então vai para marca_entrada
            addi $s0, $s0, 1              # Se não for igual, adiciona-se 1 na posição do vetor, para checar a próxima célula
            j procura_entrada             # E voltamos ao início do loop 
        
            marca_entrada:
                beq $t7, 1, marca_saida   # Antes de marcar a entrada, verificamos se uma entrada já foi encontrada. Se sim, vaipara marca_saida
                addi $t1, $t1, 1           # Para marcar a entrada adicionamos 1 ao byte contido na posição atual do vetor, ou seja, 255 passa a ser 355, deixando de ser branco para ser cinza
                sb $t1, 0($s0)            # E guardamos o novo valor na posição atual do vetor
                add $t7, $t7, 1           # Contamos que já encontramos uma entrada
                addi $s0, $s0, 1          # Adicionamos 1 na posição do vetor, para checar a próxima célula
                j procura_entrada         # E voltamos ao início do loop
                
            marca_saida:
                addi $t1, $t1, 1           # Para marcar a saída subtraimos 1 do byte contido na posição atual do vetor, ou seja, 255 passa a ser 155, deixando de ser branco para ser cinza
                sb $t1, 0($s0)            # E guardamos o novo valor na posição atual do vetor
                li $t5, 0                 # Contador auxiliar de colunas
    		li $t6, 0                 # Contador auxiliar de linhas
    		li $t7, 0                 # Contador auxiliar de entradas
                # Como já achamos a entrada e saída do labirinto, não voltamos ao início do loop e só deixamos o código seguir
                
# Não sobrepor $t0, $t1, $s1 e $s2
resolve_labirinto:    
	move $s0, $s3 # Retorna ao inicio do labirinto
	encontra_branco: # Encontra uma entidade branca
		li $s4, 0 # Inicia o Contador de celulas pretas vizinhas
		addi $s0, $s0, 1 # Iterador do conteudo
		move $s7, $s0 # Guarda a celula que estamos trabalhando
		lb $t1, 0($s0) # Conteudo do byte atual
		beq $t1, 0, cria_arquivo # verifica se chegou no fim do arquivo (EOF)
		bne $t1, $t4, encontra_branco # continua procurando
	olha_direita:
		addi $s0, $s0, 1 # Iterador do conteudo
		lb $t1, 0($s0) # Conteudo do byte atual
		beq $t1, 51, fim_olha_direita
		beq $t1, $t4, fim_olha_direita # a celula a direita é branca
		beq $t1, $t3, adiciona_viz_pd # a celula a direita é preta
		j olha_direita # não chegou no byte da proxima celula
    		adiciona_viz_pd:
			addi $s4, $s4, 1
	fim_olha_direita:
		move $s0, $s7 # Regenera o ponteiro para posição da celula que estamos trabalhando
		# -------------------------------------------------------------------------------- #
	olha_esquerda:
		subi $s0, $s0, 1 # Iterador do conteudo
		lb $t1, 0($s0) # Conteudo do byte atual
		beq $t1, 51, fim_olha_esquerda
		beq $t1, $t4, fim_olha_esquerda # a celula a esquerda é branca
		beq $t1, $t3, adiciona_viz_pe # a celula a esquerda é preta
		j olha_esquerda # não chegou no byte da proxima celula
        	adiciona_viz_pe:
			addi $s4, $s4, 1 # adiciona ao contador de vizinhos
	fim_olha_esquerda:
		move $s0, $s7 # Regenera o ponteiro para posição da celula que estamos trabalhando
		li $t9, 0 # Cria um contador de unidades
		# -------------------------------------------------------------------------------- #
	olha_cima:
		beq $t9, $s1, vizinho_cima_enc # vizinho de cima encontrado (baseado na largura do labirinto)
		subi $s0, $s0, 1 # Iterador do conteudo
		lb $t1, 0($s0) # Conteudo do byte atual
		beq $t1, 51, adiciona_cont_unidc
		beq $t1, $t4, adiciona_cont_unidc # encontrou celula a esquerda
		beq $t1, $t3, adiciona_cont_unidc # encontrou celula a esquerda
		j olha_cima # não chegou no byte da proxima celula
		adiciona_cont_unidc:
			addi $t9, $t9, 1 # adiciona ao contador de unidades, ou linhas
			j olha_cima
		vizinho_cima_enc:
			beq $t1, $t3, adiciona_viz_pc # encontrou celula a esquerda
			j fim_olha_cima
		adiciona_viz_pc:
			addi $s4, $s4, 1 # adiciona ao contador de vizinhos
	fim_olha_cima:
		move $s0, $s7 # Regenera o ponteiro para posição da celula que estamos trabalhando
		li $t9, 0 # Cria um contador de unidades
		# -------------------------------------------------------------------------------- #
	olha_baixo:
		beq $t9, $s1, vizinho_baixo_enc # vizinho de baixo encontrado (baseado na largura do labirinto)
		addi $s0, $s0, 1 # Iterador do conteudo
		lb $t1, 0($s0) # Conteudo do byte atual
		beq $t1, 51, adiciona_cont_unidb
		beq $t1, $t4, adiciona_cont_unidb # encontrou celula a direita
		beq $t1, $t3, adiciona_cont_unidb # encontrou celula a direita
		j olha_baixo # não chegou no byte da proxima celula
		adiciona_cont_unidb:
			addi $t9, $t9, 1 # adiciona ao contador de unidades, ou linhas
			j olha_baixo
		vizinho_baixo_enc:
			beq $t1, $t3, adiciona_viz_pb # encontrou celula a esquerda
			j fim_olha_baixo
		adiciona_viz_pb:
			addi $s4, $s4, 1 # adiciona ao contador de vizinhos
	fim_olha_baixo:
		move $s0, $s7 # Regenera o ponteiro para posição da celula que estamos trabalhando
		li $t9, 0 # Cria um contador de unidades
		# -------------------------------------------------------------------------------- #
	bne $s4, 3, encontra_branco # não tem 3 unidades vizinhas pretas, caso tenha continua
	lb $t1, 0($s0) # le o primeiro byte
	subi $t1, $t1, 2 # transforma o primeiro byte em 0
        sb $t1, 0($s0) # subistitui por 0
        j resolve_labirinto  
		
cria_arquivo: # Não sobrepor $t0

    li $v0, 13                            # Atribui 13 para $v0. Código para abrir arquivo
    la $a0, nome_arquivo                  # Atribui o nome do novo arquivo para $a0, argumento do syscall
    li $a1, 1                             # Atribui 1 para $a1, argumento do syscall
    li $a2, 0                             # Atribui 0 para $a2, argumento do syscall
    syscall                               # Chama o sistema; o sistema atribui em $v0 o endereço do arquivo criado
    
escreve_arquivo: 
    la $s0, buffer                        # Volta #s0 ao início
    
    move $a0, $v0                         # Move para $a0 o endereço do arquivo criado, argumento do syscall
    li $v0, 15                            # Atribui 15 para $v0. Codigo para escrever arquivo
    la $a1, 0($s0)                        # Atribui o conteúdo do buffer para $a1, argumento do syscall
    move $a2, $t0                         # Atribui o número de caracteres lidos guardado em St0 para $a2, argumento do syscall
    syscall                               # Chama o sistema; o sistema atribui em $v0 o número de caracteres escritos
    
    li $v0, 16                            # Como o $a0 já tem o endereço do arquivo a ser fechado, só atribuimos 16 para $v0. Codigo para fechar arquivo
    syscall                               # Chama o sistema, que fecha o arquivo criado
