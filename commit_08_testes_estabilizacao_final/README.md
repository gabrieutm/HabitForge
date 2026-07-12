# HabitForge

Rastreador de hábitos feito em Flutter, focado em resolver bem um problema
que parece simples e não é: **calcular streaks de forma correta** e
**disparar notificações locais recorrentes** mesmo com o app fechado.

Projeto pessoal de portfólio, feito nas horas vagas ao longo de
aproximadamente um mês (trabalhando/estudando em paralelo, então o ritmo
não foi constante — teve semana de dois commits e teve semana de nenhum).

## O que o app faz

- Criar hábitos com nome, dias da semana específicos (ex: seg/qua/sex) e
  horário de lembrete.
- Marcar como concluído no dia atual, ou retroativamente dentro do
  "grace period" (ver regra abaixo).
- Calcular streak atual e recorde (melhor streak) considerando os dias
  agendados, não dias corridos.
- Notificações locais recorrentes por hábito, individuais, editáveis e
  canceláveis.
- Histórico visual dos últimos 35 dias por hábito.
- Estatísticas simples agregadas.
- Tema claro/escuro.
- Tudo 100% local (Hive), sem backend, sem conta de usuário.

## Regra de streak (o motivo desse projeto existir)

Essa foi a parte que mais me interessava resolver bem, então vale explicar
a regra com calma:

Um hábito tem dias da semana agendados. Cada dia agendado é um "evento".
Se você marcar o evento no dia certo, ou depois — **desde que ainda não
tenha começado o próximo evento agendado** —, ele conta pra streak. Esse
é o "grace period": você pode esquecer de marcar a quarta-feira e ainda
salvar sua streak marcando ela retroativamente, contanto que a
sexta-feira (próximo evento) ainda não tenha começado. Se a sexta chegar
e a quarta continuar sem marcar, a streak quebra ali.

Isso é bem diferente de simplesmente "contar dias seguidos", e foi a
parte que mais me deu dor de cabeça — ver seção de bugs abaixo.

## Como rodar

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs # se mexer nos models do Hive
flutter run
```

Rodar os testes:

```bash
flutter test
```

> As pastas nativas (`android/`, `ios/`) não fazem parte deste repositório
> de exemplo — são geradas por `flutter create .` e, num projeto real,
> seriam commitadas junto. No `commit_06` deixei um arquivo de referência
> (`android_manifest_reference/AndroidManifest_snippet.xml`) com as
> permissões que precisam existir no `AndroidManifest.xml` pra notificação
> funcionar (alarme exato, boot receiver, etc).

## A história (erros, decisões e o que faria diferente)

### O bug que mais me pegou: comparar string de data em vez de `DateTime`

Na primeira tentativa da lógica de streak (que nem sobreviveu até o
commit final, foi reescrita no `commit_04`), eu estava salvando as datas
como string `"2026-01-31"` e comparando ordenação de string pra saber
"qual data vem depois". Funcionava certinho até eu testar virada de mês
— tipo `"2026-01-31"` vs `"2026-02-01"`, o que por acaso até ordena certo
como string, mas o problema real apareceu quando comecei a fazer
aritmética de datas (somar dias) misturando `DateTime` com comparação de
string em pontos diferentes do código. Resultado: streak quebrando sem
motivo perto da virada do mês. Passei uma noite inteira achando que era
bug na regra de negócio, quando na real era inconsistência de tipo. A
solução final foi centralizar tudo num `DateUtils2` com normalização
(`DateTime` sem hora) e nunca mais comparar string de data diretamente —
os testes em `streak_service_test.dart` existem basicamente pra eu nunca
mais cair nisso.

### Débito técnico proposital: streak "ingênua" no MVP (commit 3)

Sabendo que ia reescrever a lógica de streak depois, no commit 3 eu
deixei uma versão propositalmente simples (só incrementa um contador a
cada marcação, sem considerar dias agendados nem furos). Isso foi uma
decisão consciente pra conseguir ter uma versão "clicável" rápido e
validar o resto do fluxo (criar hábito, marcar, ver lista) antes de
investir tempo na parte mais complexa. Rotulei com `TODO` no código e
reescrevi completo no commit seguinte.

### Notificações: a parte que mais gerou frustração

Isso foi de longe a parte mais dolorida do projeto, e não por falta de
tentativa:

- **Alarmes exatos no Android 12+** exigem uma permissão separada
  (`SCHEDULE_EXACT_ALARM`), e sem ela o sistema pode atrasar a notificação
  por causa de agrupamento de bateria — ou seja, o "horário exato
  escolhido pelo usuário" nem sempre é tão exato assim, dependendo do
  aparelho.
- **Fabricantes com gerenciamento agressivo de bateria** (Xiaomi, alguns
  Samsung) podem matar o processo ou impedir o alarme de disparar mesmo
  com tudo configurado certo. Isso é uma limitação do Android, não do
  app — não tem solução 100% garantida do lado do código, só orientar o
  usuário a liberar a otimização de bateria manualmente.
- **Cancelar a notificação do dia quando o hábito já foi concluído**: eu
  queria fazer isso (se você já bebeu água às 8h, não faz sentido tocar o
  lembrete às 20h), mas cada dia da semana agendado é uma notificação
  recorrente separada no plugin — não dá pra simplesmente "pular hoje"
  sem reagendar tudo toda vez que o usuário marca ou desmarca. Decidi não
  implementar isso agora. **Ficou documentado como limitação conhecida**
  no `notification_service.dart`, não como bug escondido.
- **Fuso horário fixo**: o app usa o fuso horário atual do sistema no
  momento do agendamento, mas não tenta acompanhar o usuário se ele viajar
  de fuso (o horário local seria recalculado errado). Pra um app de
  hábitos diários isso raramente importa na prática, mas é uma limitação
  real que prefiro deixar clara aqui do que fingir que não existe.

### Bug tardio encontrado no fechamento do projeto

Perto do final, testando manualmente perto da meia-noite (sim, literalmente
fiquei acordado até tarde só pra testar isso), percebi que
`canToggle()` no `HabitProvider` comparava uma data com `DateTime.now()`
sem normalizar os dois lados direito — o que podia liberar ou bloquear a
marcação de um dia de forma inconsistente dependendo da hora exata em
que a tela fosse aberta. Corrigido no commit final (`commit_08`), com
comentário no código explicando o que mudou e por quê.

### O que ficaria pra uma "v2" se eu continuasse

- Trocar Provider por Riverpod — hoje eu escolheria Riverpod desde o
  início, mas na época o objetivo era entregar rápido sem gastar tempo
  estudando uma arquitetura nova.
- Detectar o fuso horário real do aparelho (`flutter_timezone`) em vez do
  valor fixo que deixei como placeholder.
- Resolver de verdade o cancelamento de notificação quando o hábito já
  foi concluído no dia.
- Calendário "de verdade" (mês a mês) na tela de detalhe, em vez da grade
  linear dos últimos 35 dias.
- Mais testes de widget, principalmente dos fluxos de edição e exclusão
  (hoje só cobri o essencial da tela inicial).
- Sincronização opcional em nuvem — decidi conscientemente deixar de fora
  pra não precisar de backend, mas seria o próximo passo natural se o app
  fosse além do portfólio.

## Estrutura do projeto

```
lib/
  models/       # Habit (Hive) + adapter
  data/         # HabitRepository (CRUD sobre o Hive)
  services/     # StreakService (core do app) e NotificationService
  providers/    # HabitProvider, ThemeProvider (Provider)
  screens/      # Home, criar/editar, detalhe, stats, settings
  widgets/      # componentes reutilizáveis
  theme/        # cores e ThemeData claro/escuro
  utils/        # normalização de datas
test/
  streak_service_test.dart      # o mais importante do projeto
  habit_repository_test.dart
  widget_home_screen_test.dart
```

## Stack

- Flutter / Dart
- Provider (state management)
- Hive (persistência local)
- flutter_local_notifications + timezone (notificações recorrentes)
- permission_handler (permissões Android/iOS)
