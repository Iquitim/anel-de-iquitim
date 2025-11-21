# 🎮 O ANEL DE IQUITIM

> Um jogo de ação-aventura 2D que mistura horror urbano de São Paulo com terror cósmico

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![Engine](https://img.shields.io/badge/engine-Godot%204.5.1-blue)
![Linguagem](https://img.shields.io/badge/linguagem-GDScript%202.0-green)

---

## 📖 Sobre o Projeto

**O Anel de Iquitim** é um jogo souls-like 2D top-down ambientado em São Paulo, 2005. O jogador alterna entre a fragilidade humana e o poder corruptor de uma entidade antiga, explorando um submundo surreal que mistura a estética urbana paulistana com horror cósmico.

### 🎯 Conceito Core

**Gerenciamento de Autocontrole** - O poder é um risco calculado:
- **Modo Humano:** Regenera vida, usa stealth, mas é fraco em combate
- **Modo Anel:** Forte em combate, mas consome humanidade e pode causar Game Over súbito

---

## 🚀 Como Executar

### Requisitos
- **Godot 4.5.1** ou superior
- Windows 10/11
- 2GB RAM mínimo
- 500MB espaço em disco

### Instalação
```bash
# Clone o repositório
git clone https://github.com/seu-usuario/anel-de-iquitim.git

# Abra o projeto no Godot
godot --path d:\anel-de-iquitim

# Ou clique duas vezes em project.godot
```

### Controles (Teclado)
- **WASD / Setas:** Movimento
- **TAB:** Ativar/Desativar Anel
- **Shift:** Dash
- **Mouse Esquerdo:** Ataque
- **1/2:** Usar itens (Café/Refrigerante)
- **E:** Interagir
- **ESC:** Pausar

---

## 📁 Estrutura do Projeto

```
anel-de-iquitim/
├── GDD.md                  # Game Design Document completo
├── DEV_REFERENCE.md        # Referência rápida para desenvolvimento
├── README.md               # Este arquivo
│
├── _core/                  # Sistemas globais (Singletons)
├── entities/               # Player, inimigos, projéteis
├── systems/                # Componentes reutilizáveis
├── world/                  # Mapas e setores
├── ui/                     # Interface e HUD
├── assets/                 # Sprites, áudio, fontes
└── data/                   # Dados estáticos (JSON, Resources)
```

---

## 🎨 Paleta de Cores

```
🟢 Verde Iquitim:  #2BFF81  (Corrupção, Magia)
🟣 Roxo Possessão: #B400FF  (Poder, Perigo)
⚫ Preto Profundo: #0B0B0B  (Sombras, Vazio)
```

---

## 🛠️ Tecnologias

- **Engine:** Godot 4.5.1
- **Linguagem:** GDScript 2.0 (tipagem estática)
- **IDE:** VS Code + godot-tools
- **Controle de Versão:** Git
- **Testes:** GdUnit4
- **Assets:** Pixel Art (32x32)
### ✅ Fase 1: Mecânica Core (CONCLUÍDO)
- [x] Movimentação Básica (Top-Down)
- [x] Toggle do Anel (TAB)
- [x] Feedback visual (verde quando ativo)
- [x] Ajuste de velocidade dinâmica (90→130 px/s)
- [x] Sistema de Possessão
- [x] Health Component
- [x] Dash com I-frames
- [x] Sprites Animados (AnimatedSprite2D)
- [x] Sistema de Projéteis (Fireball)
- [x] Background Sprites
- [x] Transformação Iquitim
- [x] Game Over por overflow
- [x] Barra de Possessão UI completa

### ⏳ Fase 2: Combate (EM PROGRESSO)
- [x] Ataque básico (Fireball)
- [ ] Magias do anel
- [ ] Sistema de hitbox/hurtbox (Refinar)
- [x] Primeiro inimigo (Zumbi)
- [x] Feedback de dano

### ⏳ Fase 3: Mundo
- [ ] Setor 0: Cemitério (hub)
- [ ] Setor 1: Minas Antigas
- [ ] Sistema de transição
- [ ] Save system (orelhões)
- [ ] Consumíveis

### ⏳ Fase 4: Boss & Progressão
- [ ] Guardião da Mente (Boss 1)
- [ ] Árvore de habilidades
- [ ] Sistema de drops
- [ ] Diálogos com Iquitim

### ⏳ Fase 5: Polish
- [ ] UI/HUD completo
- [ ] Áudio e música
- [ ] Partículas e efeitos
- [ ] Balanceamento
- [ ] Testes de QA

---

## 🎯 Mecânicas Principais

### Sistema de Possessão
- Barra de Possessão (Verde) sobrepõe Barra de Vida (Roxo)
- Ativar anel = +10% possessão | Desativar = -10% possessão
- Se Possessão > Vida durante cooldown = **MORTE INSTANTÂNEA**

### Transformação Iquitim
- Gatilho: Possessão > Vida
- Duração: 7 segundos
- Velocidade: 220 px/s (descontrolado)
- Cooldown: 15 segundos

### Stealth
- Apenas em modo humano
- Passos silenciosos
- Menor raio de detecção
- Quebra ao ativar anel

---

## 👥 Personagens

### O Protagonista
Jovem comum de São Paulo que coloca um anel amaldiçoado para salvar seus amigos.

### Iquitim
Entidade antiga aprisionada no anel. Sarcástico, cruel, sedento de vingança.

### Os Quatro Amigos
- **A Sabedoria** (Garota de Óculos)
- **O Medo** (Garoto Mais Novo)
- **A Paciência** (Pessoa Não-Binária)
- **O Respeito** (Garota Autista)

### As Quatro Bestas (Bosses)
- Guardião da Mente
- Guardião das Sombras
- Guardião do Caos
- Guardião do Mundo

---

## 🎵 Atmosfera

### Tom
Terror melancólico e urbano. Sem jumpscares. Foco em opressão atmosférica.

### Inspirações
- **Jogos:** Hyper Light Drifter, Blasphemous, Silent Hill
- **Estética:** São Paulo 2005 (orelhões, ônibus, MP3 players)
- **Horror:** Cósmico (geometria impossível, corrupção)

---

## 🤝 Contribuindo

Este é um projeto pessoal em desenvolvimento. Sugestões e feedback são bem-vindos!

### Como Contribuir
1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -m 'feat: Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

### Padrão de Commits
- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `refactor:` Refatoração de código
- `docs:` Documentação
- `test:` Testes
- `chore:` Tarefas gerais

---

## 📄 Licença

Este projeto está sob licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

---

## 📞 Contato

**Desenvolvedor:** Silvano Lima de Barros  
**Email:** [silvano.limadebarros@email.com]  
**GitHub:** [@Iquitim](https://github.com/Iquitim)

---

## 🙏 Agradecimentos

- **Godot Engine** - Engine incrível e open-source
- **Kenney.nl** - Assets placeholder
- **OpenGameArt** - Recursos CC0
- **Comunidade Godot Brasil** - Suporte e inspiração

---

<div align="center">

**🎮 Feito com ❤️ e Godot 4.5.1**

*"O poder corrompe. O anel consome. Você consegue resistir?"*

</div>
