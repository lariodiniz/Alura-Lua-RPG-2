-- title:  Fuga das Sombras
-- author: Jeferson Silva
-- desc:   RPG de acao 2d
-- script: lua


Constantes = {
	
    VISAO_DO_INIMIGO = 50,
    
    Direcao = {
      CIMA = 1,
            BAIXO = 2,
            ESQUERDA = 3,
            DIREITA = 4
    },
    Estados= {
        PARADO = "PARADO",
        PERSEGUINDO = "PERSEGUINDO"
        },

    LARGURA_DA_TELA = 240,
    ALTURA_DA_TELA = 138,
    VELOCIDADE_ANIMACAO_JOGADOR = 0.1,
    
    SPRITE_INIMIGO = 292,
    SPRITE_CHAVE = 364,
    SPRITE_PORTA = 366,
    SPRITE_SAIDA = 1,

    SPRITE_TITULO = 352,
    SPRITE_ALURA = 416,
    
    SPRITE_TITULO_LARGURA = 12,
    SPRITE_TITULO_ALTURA = 4,
    SPRITE_ALURA_LARGURA = 7,
    SPRITE_ALURA_ALTURA = 3,
    SPRITE_ESPADA = 328,
    
    ID_SFX_CHAVE = 0,
    ID_SFX_PORTA = 1,
    ID_SFX_INICIO = 2,
    ID_SFX_ESPADA = 3,		
    ID_SFX_FINA = 4,
    
 INIMIGO = "INIMIGO",
    JOGADOR = "JOGADOR",
    ESPADA = "ESPADA"		
}

objetos = {}

function temColisaoComMapa(ponto)
local blocoX = ponto.x / 8
local blocoY = ponto.y / 8 
local blocoId = mget(blocoX, blocoY)

return blocoId >= 128
end

function tentaMoverPara(personagem, delta, direcao)

local novaPosicao = {
            x = personagem.x + delta.deltaX,
            y = personagem.y + delta.deltaY
        }

if verificaColisaoComObjetos(personagem, novaPosicao) then
             return
        end

        local superiorEsquerdo = {
          x = personagem.x - 8 + delta.deltaX,
                y = personagem.y - 8 + delta.deltaY
        }
        local superiorDireito = {
          x = personagem.x + 7 + delta.deltaX,
                y = personagem.y - 8 + delta.deltaY
        }
local inferiorDireito = {
                x = personagem.x + 7 + delta.deltaX,
                y = personagem.y + 7 + delta.deltaY
        }
        local inferiorEsquerdo = {
          x = personagem.x - 8 + delta.deltaX,
                y = personagem.y + 7 + delta.deltaY
        }

        if not (temColisaoComMapa(inferiorDireito) or
           temColisaoComMapa(inferiorEsquerdo) or
                    temColisaoComMapa(superiorDireito) or
                    temColisaoComMapa(superiorEsquerdo)) then
            
            personagem.quadroDeAnimacao = personagem.quadroDeAnimacao + Constantes.VELOCIDADE_ANIMACAO_JOGADOR
      if personagem.quadroDeAnimacao >= 3 then
              personagem.quadroDeAnimacao = 1
            end
            
            personagem.y = personagem.y + delta.deltaY
            personagem.x = personagem.x + delta.deltaX
            personagem.direcao = direcao
        end
end

function distancia(inimigo, jogador)
local distanciaX = inimigo.x - jogador.x
local distanciaY = inimigo.y - jogador.y
        
local distancia = distanciaX *  distanciaX + distanciaY *  distanciaY
return math.sqrt(distancia)
end

function atualizaInimigo(inimigo)

    if distancia(inimigo, jogador) >=	Constantes.VISAO_DO_INIMIGO then
        inimigo.estado =Constantes.Estados.PARADO
    elseif  distancia(inimigo, jogador) < Constantes.VISAO_DO_INIMIGO then
        inimigo.estado =Constantes.Estados.PERSEGUINDO
    end

 if inimigo.estado ==Constantes.Estados.PERSEGUINDO then

        
  local delta = {
          deltaY = 0,
                deltaX = 0
        }
        if jogador.y > inimigo.y then
                delta.deltaY = 0.5
                inimigo.direcao = Constantes.Direcao.BAIXO
        elseif jogador.y < inimigo.y then
                delta.deltaY = -0.5
                inimigo.direcao = Constantes.Direcao.CIMA
     end
        tentaMoverPara(inimigo, delta, inimigo.direcao)

  delta = {
          deltaY = 0,
                deltaX = 0
        }
        if jogador.x > inimigo.x then
                delta.deltaX = 0.5
                inimigo.direcao = Constantes.Direcao.DIREITA
        elseif jogador.x < inimigo.x then
                delta.deltaX = -0.5
                inimigo.direcao = Constantes.Direcao.ESQUERDA
     end
        tentaMoverPara(inimigo, delta, inimigo.direcao)

        local AnimacaoInimigo = {
             {288,290},
                {292,294},
                {296,298},
                {300,302}
        }

        local quadros = AnimacaoInimigo[inimigo.direcao]
        local quadro = math.floor(inimigo.quadroDeAnimacao)
        inimigo.sprite = quadros[quadro]
end
end

function atualizaespada()

    local dadosDaEspada = {
        {x = 0, y = -16, sprite = 324},
        {x = 0, y = 16, sprite = 332},
        {x = -16, y = 0, sprite = 320},
        {x = 16, y = 0, sprite = 328}
    }
    

    if btn(4) and jogador.direcao then
            local dados = dadosDaEspada[jogador.direcao]
            jogador.espada.visivel = true				
            jogador.espada.sprite = dados.sprite
            jogador.espada.x = jogador.x + dados.x
            jogador.espada.y = jogador.y + dados.y
            jogador.espada.tempoParaDesaparecer = 5
            sfx(
                Constantes.ID_SFX_ESPADA,
                86,
                15,
                0,
                8,
                2)
    end		
 if jogador.espada.visivel == true then
            verificaColisaoComObjetos(jogador.espada, jogador.espada)
            jogador.espada.tempoParaDesaparecer = jogador.espada.tempoParaDesaparecer - 1
    end
    
    if jogador.espada.tempoParaDesaparecer == 0 then
        jogador.espada.visivel = false
    end
end

function atualizaOJogo()

    local AnimacaoJogador = {
            {256, 258}, 
            {260, 262},
            {264, 266},
            {268, 270}
    }
    
    local Direcao = {
      {deltaX = 0, deltaY = -1},
            {deltaX = 0, deltaY = 1},
            {deltaX = -1, deltaY = 0},
            {deltaX = 1, deltaY = 0}
    }
    
    for tecla = 0,3 do
      if btn(tecla) then
                    direcao = tecla + 1
              local quadros = AnimacaoJogador[direcao]
                    local quadro = math.floor(jogador.quadroDeAnimacao)
              jogador.sprite = quadros[quadro]
                    
                    tentaMoverPara(jogador, Direcao[direcao], direcao) 
            end
    end
    
    atualizaespada()
            
    verificaColisaoComObjetos(jogador, { x = jogador.x, y = jogador.y})
    
    for indice, objeto in pairs(objetos) do
if objeto.tipo == Constantes.INIMIGO then
  atualizaInimigo(objeto)
            end
    end
    
camera.x = (jogador.x // 240) * 240		
camera.y = (jogador.y // 136) * 136
            
end

camera = {
x = 0,
y = 0
}

function desenhaMapa()

local blocoX = camera.x / 8
local blocoY = camera.y / 8
map(blocoX, -- posicao x no mapa
                    blocoY, -- posicao y no mapa
                 Constantes.LARGURA_DA_TELA, -- quanto desenhar x
                    Constantes.ALTURA_DA_TELA, -- quanto desenhar y
                    0, -- em qual ponto colocar o x
                    0) -- em qual ponto colocar o y
end

function desenhaJogador()
spr(jogador.sprite,
                    jogador.x - 8 - camera.x,
                    jogador.y - 8 - camera.y,
                    jogador.corDeFundo,
                    1, -- escala
                    0, -- espelhar
                    0, -- rotacionar
                    2, -- quantos blocos para direita
                    2) -- quantos blocos para baixo
end

function desenhaObjetos()
for indice,objeto in pairs(objetos) do
        if objeto.visivel then
            spr(objeto.sprite,
                objeto.x - 8 - camera.x,
                            objeto.y - 8 - camera.y,
                            objeto.corDeFundo,
                            1,
                            0,
                            0,
                            2,
                            2)
        end
    end
end

function desenhaOJogo()
    cls()
    desenhaMapa()
    desenhaObjetos()					
    desenhaJogador()			
end

function fazColisaoDoJogadorComAChave(indice)
jogador.chaves = jogador.chaves + 1
table.remove(objetos, indice)
    sfx(Constantes.ID_SFX_CHAVE,
                    60,
                    32,
                    0,
                    8,
                    1)
    return false
end

function temColisao(objetoA, objetoB)
local esquerdaDeB = objetoB.x - 8
    local direitaDeB = objetoB.x + 7
    local baixoDeB = objetoB.y + 7
    local cimaDeB = objetoB.y - 8
    
    local direitaDeA = objetoA.x + 7
    local esquerdaDeA = objetoA.x - 8
    local baixoDeA = objetoA.y + 7
    local cimaDeA = objetoA.y - 8
    
if esquerdaDeB > direitaDeA or
       direitaDeB < esquerdaDeA or
 baixoDeA < cimaDeB or
 cimaDeA > baixoDeB then
      return false
end
    return true
end

function fazColisaoDoJogadorComAPorta(indice)
    if jogador.chaves > 0 then
            jogador.chaves = jogador.chaves - 1
            table.remove(objetos, indice)
            sfx(Constantes.ID_SFX_PORTA,
                            36,
                            32,
                            0,
                            8,
                            1)
            return false
    end
    return true
end

function fazColisaoDaEspadaComOInimigo(indice)
table.remove(objetos, indice)
return false
end

function fazColisaoDoJogadorComOInimigo(indice)
inicializa()
    return true
end

function verificaColisaoComObjetos(personagem, novaPosicao)

for indice, objeto in pairs(objetos) do

            if temColisao(novaPosicao, objeto) then
                 local funcaoDeColisao = objeto.colisoes[personagem.tipo]
                    return funcaoDeColisao(indice)
            end
    
    end
    
    return false
    
end

function desenhaATelaDeTitulo()
    cls()
    spr(Constantes.SPRITE_TITULO,
                    80,
                    12,
                    0,
                    1,
                    0,
                    0,
                    Constantes.SPRITE_TITULO_LARGURA,
                    Constantes.SPRITE_TITULO_ALTURA)
                    
 spr(Constantes.SPRITE_ALURA,
        94,
                    92,
                    0,
                    1,
                    0,
                    0,
                    Constantes.SPRITE_ALURA_LARGURA,
                    Constantes.SPRITE_ALURA_ALTURA)
                    
 print("www.alura.com.br", 78, 122, 15)
end

function atualizaATelaDeTitulo()
    if btn(4) then
            sfx(Constantes.ID_SFX_INICIO,
                72,
                            32,
                            0,
                            8,
                            0)
            tela = Tela.JOGO
    end
end

function TIC()
    tela.atualiza()
    tela.desenha()
end

function fazColisaoDoInimigoComAPorta(indice)
    return true
end

function criaPorta(coluna, linha)
local porta = {
        visivel = true,
      sprite = Constantes.SPRITE_PORTA,
            x = coluna * 8 + 8,
            y = linha * 8 + 8,
            corDeFundo = 6,
            colisoes = {
              ESPADA = deixaPassar,									
              INIMIGO = fazColisaoDoInimigoComAPorta,
                 JOGADOR = fazColisaoDoJogadorComAPorta
            }
    }
    return porta
end

function deixaPassar(indice)
return false
end

function criaChave(coluna, linha)
local chave = {
      sprite = Constantes.SPRITE_CHAVE, 
            x = coluna * 8 + 8,
            y = linha * 8 + 8,
            corDeFundo = 6,
            visivel = true,
            colisoes = {
                 INIMIGO = deixaPassar,
                    JOGADOR = fazColisaoDoJogadorComAChave,
                    ESPADA = deixaPassar				
            }
    }
    return chave
end

function criaInimigo(coluna, linha)
local inimigo = {

        tipo = Constantes.INIMIGO,
        estado = Constantes.Estados.PARADO,

        sprite = Constantes.SPRITE_INIMIGO,
        x = coluna * 8 + 8,
        y = linha * 8 + 8,
        corDeFundo = 14,
        visivel = true,
        quadroDeAnimacao = 1,
        colisoes = {
          INIMIGO = deixaPassar,
                ESPADA = fazColisaoDaEspadaComOInimigo,					
                JOGADOR = fazColisaoDoJogadorComOInimigo
        }
}
return inimigo
end

function atualizaFinal()
if btn(4) then
    inicializa()
end
end

function desenhaOFinal()
cls()
print("Voce conseguiu escapar!", 56, 40)
print("Precione z para reiniciar",48, 86)

end


Tela = {
INICIO = {
            atualiza =	atualizaATelaDeTitulo,
            desenha = desenhaATelaDeTitulo
    },
    JOGO = {
      atualiza = atualizaOJogo,
            desenha = desenhaOJogo
    },
    FINAL = {
      atualiza = atualizaFinal,
            desenha = desenhaOFinal
    }
}

function chegaNoFinal()

sfx (Constantes.ID_SFX_FINAL,
    36,
    32,
    0,
    8,
    0
    )
    
tela = Tela.FINAL
end

function inicializa()

    objetos = {}

    local chave = criaChave(3,3)
    table.insert(objetos, chave)
    
    local chave2 = criaChave(22,26)
    table.insert(objetos, chave2)		
    
    local porta2 = criaPorta(47,13)
    table.insert(objetos, porta2)

    local porta = criaPorta(17,7)
    table.insert(objetos, porta)
    
    local inimigo = criaInimigo(26,13)
table.insert(objetos, inimigo)

    local inimigo2 = criaInimigo(37,7)
table.insert(objetos, inimigo2)
    
    local espada = {
        tipo = Constantes.ESPADA,
        sprite = Constantes.SPRITE_ESPADA,
        visivel = false,
        x = 0 + 8,
        y = 0 + 8,
        corDeFundo = 0,
        tempoParaDesaparecer = 0,
        colisoes = {
          INIMIGO = deixaPassar,
                JOGADOR = deixaPassar,
                ESPADA = deixaPassar,					
        }			
        
    }
    
    table.insert(objetos, espada)

 jogador = {
    
  tipo = Constantes.JOGADOR,
        
        sprite = 260,
        x = 120,
        y = 68,
        corDeFundo = 6,
        quadroDeAnimacao = 1,
        
        chaves = 0,
        espada = espada
    }
    
    posicaoDaSaida = { 
        sprite = Constantes.SPRITE_SAIDA,
        x = 55 * 8 + 8,
        y = 8 * 8 + 8,
        corDeFundo = 6,
        visivel = true,
        colisoes = {
            INIMIGO = deixaPassar,
            JOGADOR = chegaNoFinal,
            ESPADA = deixaPassar						
        }			
    }
    
    table.insert(objetos, posicaoDaSaida)

 tela = Tela.INICIO

end

inicializa()
