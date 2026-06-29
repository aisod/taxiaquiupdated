import 'dart:math';
import '../models/game_state.dart';
import '../models/simulation_models.dart';

class QuestionsData {
  static List<Question> get allQuestions => [
    // Module 1: Impostos Fiscais
    Question(
      id: 1,
      module: 1,
      text: 'Maria compra produtos no supermercado por 15.000 Kz. Qual é a taxa de IVA aplicada em Angola?',
      options: ['10%', '14%', '18%', '20%'],
      correctAnswer: 1,
      explanation: 'A taxa de IVA padrão em Angola é de 14%, aplicada à maioria dos bens e serviços. Este imposto foi implementado em 2019 e substituiu o Imposto de Consumo.'
    ),
    Question(
      id: 2,
      module: 1,
      text: 'João recebe um salário de 80.000 Kz mensais. Sobre que valor incide o IRT?',
      options: ['Todo o salário (80.000 Kz)', 'Apenas sobre 10.000 Kz (80.000 - 70.000)', 'Nada, está isento', 'Apenas metade do salário'],
      correctAnswer: 1,
      explanation: 'O IRT tem isenção para rendimentos até 70.000 Kz mensais. Portanto, João paga IRT apenas sobre 10.000 Kz (80.000 - 70.000).'
    ),
    Question(
      id: 3,
      module: 1,
      text: 'Uma empresa tem lucros de 1.000.000 Kz. Qual a taxa máxima de IRT aplicável?',
      options: ['15%', '20%', '25%', '30%'],
      correctAnswer: 2,
      explanation: 'A taxa máxima de IRT em Angola é de 25%, aplicada sobre os lucros das empresas com taxas progressivas.'
    ),
    Question(
      id: 4,
      module: 1,
      text: 'O Imposto Predial incide sobre:',
      options: ['Apenas imóveis comerciais', 'Apenas imóveis residenciais', 'Imóveis urbanos e rústicos', 'Apenas terrenos vazios'],
      correctAnswer: 2,
      explanation: 'O Imposto Predial incide sobre todos os imóveis urbanos e rústicos, com taxas que variam de 0,1% a 0,5% do valor patrimonial.'
    ),
    Question(
      id: 5,
      module: 1,
      text: 'A declaração de IVA deve ser feita:',
      options: ['Mensalmente', 'Trimestralmente', 'Semestralmente', 'Anualmente'],
      correctAnswer: 0,
      explanation: 'A declaração de IVA em Angola deve ser feita mensalmente, até o dia 15 do mês seguinte ao período de apuração.'
    ),
    
    // Module 2: Direitos Aduaneiros
    Question(
      id: 6,
      module: 2,
      text: 'Os direitos aduaneiros são calculados sobre:',
      options: ['Valor FOB', 'Valor CIF', 'Apenas o valor da mercadoria', 'Valor da fatura comercial'],
      correctAnswer: 1,
      explanation: 'Os direitos aduaneiros são calculados sobre o valor CIF (Custo, Seguro e Frete), que inclui o valor da mercadoria, seguro e frete.'
    ),
    Question(
      id: 7,
      module: 2,
      text: 'As taxas de direitos aduaneiros em Angola variam de:',
      options: ['0% a 50%', '2% a 70%', '5% a 30%', '10% a 40%'],
      correctAnswer: 1,
      explanation: 'As taxas de direitos aduaneiros em Angola variam de 2% a 70%, dependendo do tipo de produto importado.'
    ),
    Question(
      id: 8,
      module: 2,
      text: 'Qual documento é essencial para o desembaraço aduaneiro?',
      options: ['Apenas a fatura', 'Conhecimento de embarque', 'Certificado de origem', 'Todos os anteriores'],
      correctAnswer: 3,
      explanation: 'Para o desembaraço aduaneiro são necessários: fatura comercial, conhecimento de embarque, certificado de origem e outros documentos conforme o caso.'
    ),
    Question(
      id: 9,
      module: 2,
      text: 'Produtos considerados essenciais podem ter:',
      options: ['Taxas normais', 'Taxas reduzidas ou isenções', 'Taxas mais altas', 'Proibição de importação'],
      correctAnswer: 1,
      explanation: 'Produtos considerados essenciais podem beneficiar de taxas reduzidas ou isenções de direitos aduaneiros para proteger o consumidor.'
    ),
    Question(
      id: 10,
      module: 2,
      text: 'A classificação correta das mercadorias é importante para:',
      options: ['Determinar a taxa aplicável', 'Evitar penalidades', 'Facilitar o desembaraço', 'Todas as anteriores'],
      correctAnswer: 3,
      explanation: 'A classificação correta é fundamental para determinar a taxa aplicável, evitar penalidades e facilitar o processo de desembaraço aduaneiro.'
    ),

    // Module 3: JUSTINHO E OS IMPOSTOS
    Question(
      id: 11,
      module: 3,
      text: 'Quem é o "Justinho" no contexto da AGT?',
      options: ['Um fiscal de fronteira', 'O mascote da educação fiscal', 'O Diretor da AGT', 'Um contribuinte faltoso'],
      correctAnswer: 1,
      explanation: 'O Justinho é o boneco oficial da AGT para campanhas de educação fiscal, ajudando a explicar a importância dos impostos de forma lúdica.'
    ),
    Question(
      id: 12,
      module: 3,
      text: 'Segundo as lições do Justinho, para onde vai o dinheiro dos impostos?',
      options: ['Para contas no exterior', 'Apenas para salários de políticos', 'Para escolas, hospitais e estradas', 'O dinheiro desaparece'],
      correctAnswer: 2,
      explanation: 'O Justinho ensina que os impostos são a base para o bem comum, financiando serviços públicos essenciais para todos os cidadãos.'
    ),
    Question(
      id: 13,
      module: 3,
      text: 'O que o Justinho define como "Cidadania Fiscal"?',
      options: ['Pagar o mínimo possível', 'Conhecer direitos e deveres fiscais', 'Não pedir fatura', 'Evitar passar pela alfândega'],
      correctAnswer: 1,
      explanation: 'Cidadania Fiscal é a consciência de que pagar impostos é um dever para garantir o funcionamento do Estado e o direito de exigir bons serviços.'
    ),
    Question(
      id: 14,
      module: 3,
      text: 'Qual destes conselhos o Justinho daria ao comprar um produto?',
      options: ['Não precisa de recibo', 'Peça sempre a fatura com NIF', 'Pague apenas em dinheiro vivo', 'Tente negociar sem IVA'],
      correctAnswer: 1,
      explanation: 'O Justinho incentiva sempre a exigência da fatura com o Número de Identificação Fiscal (NIF) para garantir que o imposto chegue ao Estado.'
    ),
    Question(
      id: 15,
      module: 3,
      text: 'Para o Justinho, quem ganha quando todos pagam impostos corretamente?',
      options: ['Apenas a AGT', 'Apenas os bancos', 'Toda a sociedade angolana', 'Ninguém ganha'],
      correctAnswer: 2,
      explanation: 'O lema da educação fiscal é que a contribuição correta de cada um resulta em benefícios coletivos para todo o país.'
    ),
  ];
  
  static Question getQuestionById(int id) {
    return allQuestions.firstWhere((q) => q.id == id);
  }
  
  static List<Question> getQuestionsByModule(int module, {bool shuffle = true}) {
    final questions = allQuestions.where((q) => q.module == module).toList();
    if (shuffle) {
      questions.shuffle(Random());
    }
    return questions;
  }
  
  static List<Question> getQuestionsByModuleOrdered(int module) {
    return allQuestions.where((q) => q.module == module).toList();
  }
  
  static final List<String> avatarOptions = [
    'assets/images/1.png',
    'assets/images/2.png', 
    'assets/images/3-2.png',
  ];
  
  static String getRandomAvatar() {
    return avatarOptions[Random().nextInt(avatarOptions.length)];
  }
}

class AchievementsData {
  static List<Achievement> get allAchievements => [
    Achievement(
      id: 'first_question',
      title: 'Primeiro Passo',
      description: 'Respondeu à sua primeira pergunta sobre impostos',
      icon: '🎯',
      xpBonus: 25,
    ),
    Achievement(
      id: 'first_quiz',
      title: 'Quiz Iniciante',
      description: 'Completou seu primeiro quiz sobre impostos',
      icon: '🏆',
      xpBonus: 50,
    ),
    Achievement(
      id: 'module_1_complete',
      title: 'Especialista Fiscal',
      description: 'Concluiu o módulo de Impostos Fiscais',
      icon: '📚',
      xpBonus: 100,
    ),
    Achievement(
      id: 'module_2_complete',
      title: 'Mestre Aduaneiro',
      description: 'Concluiu o módulo de Direitos Aduaneiros',
      icon: '🚢',
      xpBonus: 150,
    ),
    // Nova conquista para o Justinho:
    Achievement(
      id: 'module_3_complete',
      title: 'Amigo do Justinho',
      description: 'Concluiu o módulo de Educação Fiscal com o Justinho',
      icon: '🧒',
      xpBonus: 100,
    ),
    Achievement(
      id: 'level_10',
      title: 'Veterano dos Impostos',
      description: 'Alcançou o nível 10 no jogo',
      icon: '⭐',
      xpBonus: 200,
    ),
    Achievement(
      id: 'tax_legend',
      title: 'Lenda da AGT',
      description: 'Completou todos os módulos e alcançou o nível 20',
      icon: '👑',
      xpBonus: 500,
    ),
    Achievement(
      id: 'perfect_score',
      title: 'Perfeição Fiscal',
      description: 'Respondeu corretamente na primeira tentativa em 10 perguntas',
      icon: '💎',
      xpBonus: 300,
    ),
    Achievement(
      id: 'quick_learner',
      title: 'Aprendiz Rápido',
      description: 'Completou um quiz em menos de 5 minutos',
      icon: '⚡',
      xpBonus: 75,
    ),
  ];
}
class TaxSimulationData {
  static Map<String, String> get taxEducation => {
    'IVA': '''
O Imposto sobre o Valor Acrescentado (IVA) em Angola:

u2022 Taxa padrão: 14%
u2022 Introduzido em: Outubro de 2019
u2022 Substituiu: O Imposto de Consumo
u2022 Declaração: Mensal (até dia 15 do mês seguinte)
u2022 Isenções: Bens da cesta básica, medicamentos, serviços médicos

O IVA é um imposto indireto sobre o consumo, sendo cobrado no momento da venda. As empresas atuam como coletoras deste imposto, repassando-o ao governo. É importante manter registros detalhados de todas as transações sujeitas ao IVA para declarações precisas.''',
    
    'IRT': '''
O Imposto sobre os Rendimentos do Trabalho (IRT) em Angola:

u2022 Taxas: Progressivas de 0% a 25%
u2022 Aplicação: Rendimentos do trabalho e lucros empresariais
u2022 Isenção: Rendimentos até 70.000 Kz mensais
u2022 Declaração: Trimestral para empresas

Para empresas, o IRT incide sobre os lucros com taxas progressivas. É essencial calcular corretamente o lucro tributável, aplicando as deduções permitidas por lei. O não cumprimento pode resultar em multas significativas.''',
    
    'Imposto Predial': '''
O Imposto Predial em Angola:

u2022 Taxas: Variam de 0,1% a 0,5% do valor patrimonial
u2022 Incidência: Imóveis urbanos e rústicos
u2022 Declaração: Anual
u2022 Responsável: Proprietário do imóvel

Este imposto incide sobre o valor patrimonial dos imóveis. As taxas variam conforme o valor e a utilização do imóvel. Prédios recém-construídos podem beneficiar de isenções temporárias. O pagamento em atraso implica juros e multas.''',
    
    'Direitos Aduaneiros': '''
Direitos Aduaneiros em Angola:

u2022 Taxas: Variam de 2% a 70% dependendo do produto
u2022 Base de cálculo: Valor CIF (Custo, Seguro e Frete)
u2022 Declaração: No momento da importação
u2022 Documentos necessários: Fatura comercial, conhecimento de embarque, certificado de origem

Os direitos aduaneiros são aplicados à importação de mercadorias. Certos produtos considerados essenciais podem ter taxas reduzidas ou isenções. É fundamental classificar corretamente as mercadorias para determinar a taxa aplicável.''',
  };
  
  static Map<BusinessType, List<String>> get businessTaxTips => {
    BusinessType.retail: [
      'Empresas de varejo devem manter controle rigoroso do IVA coletado em cada venda.',
      'Verifique se produtos da cesta básica estão corretamente classificados para isenção de IVA.',
      'Mantenha inventário atualizado para justificar o IVA dedutível nas compras.',
    ],
    
    BusinessType.service: [
      'Empresas de serviços devem emitir faturas detalhando claramente os serviços prestados.',
      'Alguns serviços especializados podem ter tratamento fiscal diferenciado.',
      'Mantenha contratos de prestação de serviços bem documentados.',
    ],
    
    BusinessType.import: [
      'Importadores devem conhecer detalhadamente a Pauta Aduaneira de Angola.',
      'Custos de desembaraço aduaneiro devem ser incluídos nas despesas dedutíveis.',
      'Considere criar um fundo de reserva para flutuações nos direitos aduaneiros.',
    ],
    
    BusinessType.production: [
      'Empresas produtoras podem se beneficiar de incentivos fiscais para industrialização.',
      'Mantenha registro detalhado dos insumos para dedução correta do IVA.',
      'Investimentos em maquinário podem ter depreciação acelerada para fins fiscais.',
    ],
  };
}