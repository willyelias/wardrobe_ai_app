# 👔 Wardrobe AI - Virtual Closet & Personal Stylist

[![Download APK](https://img.shields.io/badge/Download_APK-Android_v1.1.0-brightgreen?style=for-the-badge&logo=android)](https://github.com/willyelias/wardrobe_ai_app/releases/download/v1.1.0/wardrobe_ai_v1.1.0.apk)
[![Acessar Web / iPhone](https://img.shields.io/badge/Acessar_Web-iPhone_%26_Safari-black?style=for-the-badge&logo=apple)](https://willyelias.github.io/wardrobe_ai_app/)
[![Release](https://img.shields.io/github/v/release/willyelias/wardrobe_ai_app?style=for-the-badge)](https://github.com/willyelias/wardrobe_ai_app/releases/tag/v1.1.0)

Aplicativo mobile de ponta a ponta desenvolvido em **Flutter**, focado em gestão inteligente de guarda-roupa virtual, provador virtual no próprio corpo do usuário com avatar personalizado, curadoria de looks ilimitados com Inteligência Artificial, pesquisa de peças similares em lojas online (Shop the Look) e planejamento de estilo através de um calendário integrado.

### 📲 Acessos Oficiais:
* 🤖 **Para Android:** [Baixar APK Oficial v1.1.0](https://github.com/willyelias/wardrobe_ai_app/releases/download/v1.1.0/wardrobe_ai_v1.1.0.apk)
* 🍏 **Para iPhone (iOS) / Navegadores:** [Acessar Wardrobe AI Web](https://willyelias.github.io/wardrobe_ai_app/) *(No iPhone: abra no Safari, toque no ícone de Compartilhar e selecione **"Adicionar à Tela de Início"** para instalar como app!)*

---

## 🚀 Arquitetura & Stack Tecnológico

| Camada | Tecnologia / Pacote | Descrição |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.x / Dart 3.x | Multiplataforma (iOS & Android) |
| **Gerenciamento de Estado** | `flutter_riverpod` (v2) | Arquitetura reativa, desacoplada e testável |
| **Banco de Dados Local** | `sqflite` / `sqflite_common_ffi` | Armazenamento SQLite offline e ultrarrápido |
| **Armazenamento de Mídia** | `path_provider` | Fotos salvas localmente no disco do dispositivo |
| **Remoção de Fundo** | `BackgroundRemovalService` | Suporte a API (remove.bg/Photoroom) + Fallback local com canal alfa |
| **IA Stylist Engine** | Google Gemini API + Motor Local | Combinação cromática e de silhuetas com curadoria de moda |
| **Calendário & Histórico** | `table_calendar` + `intl` | Planejamento diário e histórico de peças vestidas |
| **Monetização** | `google_mobile_ads` | Google AdMob (Rewarded Ads & Native Ads elegantes) |
| **Variáveis de Ambiente** | `flutter_dotenv` | Chaves de API e IDs de anúncios isolados em `.env` |

---

## 📱 As Três Abas do Aplicativo

### 1. Closet Virtual (Inventário & Câmera)
* **Grid Minimalista:** Visualização em grade elegante das roupas cadastradas com filtros rápidos por categoria (Todas, Superior, Inferior, Calçados, Casacos, Peça Única, Acessórios).
* **Captura Inteligente:** Botão Flutuante (FAB) com suporte para captura direta da Câmera ou Galeria.
* **Módulo de Remoção de Fundo (IA):**
  * Chamada de API genérica configurada para `remove.bg` ou `Photoroom`.
  * Fallback local automático em Dart que processa os cantos da imagem e extrai o objeto em **PNG transparente** sem depender de internet ou cobranças de API.

### 2. IA Stylist (Gerador de Looks Inteligentes)
* **Seleção de Ocasião:** Escolha rápida entre *Trabalho*, *Balada*, *Casual*, *Frio*, *Encontro* e *Esporte*.
* **Vibe Opcional:** Filtros de estilo como *Minimalista*, *Elegante*, *Confortável*, etc.
* **Curadoria do Stylist:** A IA analisa as peças disponíveis no SQLite e monta uma composição equilibrada (Top + Bottom + Calçado + Casaco/Acessório), gerando uma justificativa detalhada de moda e cores.
* **Monetização com Rewarded Ads:**
  * Limite diário de **3 gerações gratuitas**.
  * Ao esgotar, exibe modal convidando o usuário a assistir a um anúncio em vídeo para desbloquear gerações adicionais.
* **Native Ads Discretos:**
  * Logo abaixo do look sugerido, há um espaço de anúncio nativo projetado para parecer um cartão de *"Dica de Moda"* ou *"Compre peças parecidas"*, sem poluir a experiência.

### 3. Calendário (Histórico & Planejamento)
* **Visualização Mensal:** Calendário fluido com marcadores visuais nos dias em que há looks registrados.
* **Agendamento com Notas:** Atrele qualquer look gerado ou salvo a uma data específica (ex: "Reunião de Diretoria").
* **Miniaturas de Peças:** Exibição rápida das peças que compõem o visual daquele dia.

---

## 🛠️ Configuração e Execução

### 1. Clone do Repositório
```bash
git clone https://github.com/willyelias/wardrobe_ai_app.git
cd wardrobe_ai_app
```

### 2. Variáveis de Ambiente (`.env`)
Copie o arquivo de exemplo:
```bash
cp .env.example .env
```
O arquivo `.env` já vem pré-configurado com os IDs de teste oficiais do Google AdMob. Caso queira utilizar as APIs reais de IA e Remoção de Fundo, basta preencher:
* `GEMINI_API_KEY`: Chave da API Google Gemini ([Google AI Studio](https://aistudio.google.com/))
* `REMOVE_BG_API_KEY`: Chave da API remove.bg ([remove.bg API](https://www.remove.bg/api))

### 3. Instalar Dependências e Executar
```bash
flutter pub get
flutter run
```

---

## 🧪 Testes Automatizados

O projeto inclui suíte de testes unitários e de widgets:
```bash
flutter test
```

---

## 🏛️ Estrutura de Pastas

```
lib/
├── main.dart                          # Inicialização do app, Riverpod e AdMob
├── theme/
│   ├── app_colors.dart                # Paleta de cores Apple Minimalist
│   └── app_theme.dart                 # ThemeData com M3 e Cupertino
├── models/
│   ├── category.dart                  # Enum de categorias com ícones e nomes
│   ├── clothing_item.dart             # Modelo de peça individual (SQLite)
│   ├── outfit.dart                    # Modelo de look combinado
│   └── calendar_log.dart              # Mapeamento de look para data
├── services/
│   ├── database_service.dart          # CRUD SQLite com seed inicial de peças
│   ├── storage_service.dart           # Salvamento local de fotos no dispositivo
│   ├── background_removal_service.dart# API remove.bg + processador local PNG
│   ├── ai_stylist_service.dart        # Engine de IA (Gemini + Local)
│   ├── ad_manager.dart                # Gerenciador centralizado do Google AdMob
│   └── quota_service.dart             # Controle de cota diária de 3 usos
├── providers/
│   ├── wardrobe_provider.dart         # Estado do closet e filtros
│   ├── stylist_provider.dart          # Estado de geração de looks da IA
│   ├── calendar_provider.dart         # Estado de agendamentos no calendário
│   └── quota_provider.dart            # Estado da cota de anúncios
├── widgets/
│   ├── apple_card.dart                # Container no design system Apple
│   ├── custom_chip.dart               # Chips de filtro e seleção
│   ├── empty_state.dart               # Estado vazio minimalista
│   └── clothing_image_view.dart       # Renderizador de fotos e ilustrações
└── views/
    ├── main_scaffold.dart             # Bottom navigation bar com as 3 abas
    ├── closet/
    │   ├── closet_screen.dart         # Aba 1: Grid e câmera
    │   ├── add_item_sheet.dart        # Modal de cadastro de nova peça
    │   └── item_detail_dialog.dart    # Modal de detalhes e exclusão
    ├── stylist/
    │   ├── stylist_screen.dart        # Aba 2: Gerador de looks com IA
    │   ├── look_detail_card.dart      # Moodboard do look e dica do stylist
    │   ├── native_ad_fashion_card.dart# Anúncio Nativo disfarçado de dica de moda
    │   └── rewarded_ad_dialog.dart    # Modal de anúncio em vídeo recompensado
    └── calendar/
        ├── calendar_screen.dart       # Aba 3: Calendário mensal com eventos
        └── schedule_look_dialog.dart  # Modal de agendamento de look
```

---

## 📄 Licença
Desenvolvido sob a licença MIT. Sinta-se livre para customizar e expandir!
