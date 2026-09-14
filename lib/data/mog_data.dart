class JobPost {
  final int id;
  final String title;
  final String company;
  final String salaryRange;
  final List<String> techStack;
  final String schedule;
  final String requirements;
  final String description;

  const JobPost({
    required this.id,
    required this.title,
    required this.company,
    required this.salaryRange,
    required this.techStack,
    required this.schedule,
    required this.requirements,
    required this.description,
  });
}

class Application {
  final int id;
  final int jobPostId;
  final int userId;
  final String cvUrl;
  final String message;
  final String status;

  const Application({
    required this.id,
    required this.jobPostId,
    required this.userId,
    required this.cvUrl,
    required this.message,
    required this.status,
  });
}

const mockJobs = [
  JobPost(
    id: 1,
    title: 'Junior Flutter Developer',
    company: 'PixelForge',
    salaryRange: '10 000–16 000 MDL',
    techStack: ['Flutter', 'Dart', 'REST API', 'Git'],
    schedule: 'Part-time · Hybrid',
    requirements: 'Базовые знания Dart и Flutter, понимание виджетов и state management, умение работать с REST API и Git.',
    description: 'Участие в разработке мобильного приложения: создание экранов, подключение API, исправление ошибок и работа с командой.',
  ),
  JobPost(
    id: 2,
    title: 'Frontend Developer Intern',
    company: 'NovaSoft',
    salaryRange: '8 000–12 000 MDL',
    techStack: ['JavaScript', 'React', 'HTML', 'CSS'],
    schedule: 'Internship · Remote',
    requirements: 'Знание основ JavaScript, HTML и CSS, понимание React-компонентов и hooks, наличие учебных проектов.',
    description: 'Разработка и доработка веб-интерфейсов на React, адаптивная вёрстка, подключение REST API и участие в код-ревью.',
  ),
  JobPost(
    id: 3,
    title: 'Junior QA Engineer',
    company: 'TestLab',
    salaryRange: '9 000–14 000 MDL',
    techStack: ['Manual QA', 'Postman', 'SQL', 'Jira'],
    schedule: 'Part-time · Office',
    requirements: 'Знание основ тестирования, умение составлять тест-кейсы и баг-репорты, базовые навыки Postman и SQL.',
    description: 'Ручное тестирование веб- и мобильных приложений, проверка API, ведение тестовой документации и регистрация дефектов.',
  ),
  JobPost(
    id: 4,
    title: 'Backend Developer Intern',
    company: 'CodeNest',
    salaryRange: '9 000–15 000 MDL',
    techStack: ['Java', 'Spring Boot', 'PostgreSQL', 'Git'],
    schedule: 'Internship · Hybrid',
    requirements: 'Знание Java и принципов ООП, понимание REST API, базовый опыт со Spring Boot, PostgreSQL и Git.',
    description: 'Разработка backend-сервисов под руководством наставника: REST-эндпоинты, бизнес-логика, работа с базой данных и тесты.',
  ),
  JobPost(
    id: 5,
    title: 'Python Developer Intern',
    company: 'DataPeak',
    salaryRange: '8 500–13 000 MDL',
    techStack: ['Python', 'FastAPI', 'SQL', 'Docker'],
    schedule: 'Internship · Remote',
    requirements: 'Уверенное знание основ Python, понимание REST API, базовый опыт с FastAPI, SQL и Docker.',
    description: 'Создание небольших API и сервисов на Python, интеграция источников данных, написание тестов и подготовка Docker-окружения.',
  ),
  JobPost(
    id: 6,
    title: 'Junior DevOps Assistant',
    company: 'CloudBridge',
    salaryRange: '11 000–17 000 MDL',
    techStack: ['Linux', 'Docker', 'Git', 'CI/CD'],
    schedule: 'Part-time · Hybrid',
    requirements: 'Умение работать в Linux и командной строке, знание Docker и Git, понимание основ CI/CD.',
    description: 'Помощь в поддержке инфраструктуры: работа с Docker-контейнерами, настройка CI/CD-пайплайнов, мониторинг и диагностика.',
  ),
  JobPost(
    id: 7,
    title: 'UI/UX Intern',
    company: 'BrightApps',
    salaryRange: '7 000–11 000 MDL',
    techStack: ['Figma', 'UI Design', 'Prototyping'],
    schedule: 'Internship · Office',
    requirements: 'Умение работать в Figma, создавать макеты и прототипы, понимание типографики и адаптивного дизайна.',
    description: 'Создание user flow, вайрфреймов и интерактивных прототипов, подготовка UI-макетов и развитие компонентов дизайн-системы.',
  ),
  JobPost(
    id: 8,
    title: 'Junior React Native Developer',
    company: 'MobileWorks',
    salaryRange: '10 000–15 000 MDL',
    techStack: ['React Native', 'JavaScript', 'REST API', 'Git'],
    schedule: 'Part-time · Remote',
    requirements: 'Знание JavaScript и основ React, опыт создания учебных приложений на React Native, работа с REST API и Git.',
    description: 'Разработка кроссплатформенного мобильного приложения, сборка экранов, интеграция REST API и исправление ошибок.',
  ),
];

const mockApplications = [
  Application(
    id: 1,
    jobPostId: 1,
    userId: 1,
    cvUrl: 'cv_alex.pdf',
    message: 'Хочу развиваться во Flutter и уже работал с REST API.',
    status: 'Отправлен',
  ),
  Application(
    id: 2,
    jobPostId: 2,
    userId: 1,
    cvUrl: 'cv_alex.pdf',
    message: 'Есть опыт учебных проектов на React.',
    status: 'Просмотрен',
  ),
  Application(
    id: 3,
    jobPostId: 3,
    userId: 1,
    cvUrl: 'cv_alex.pdf',
    message: 'Работал с Postman и тестировал API в учебных проектах.',
    status: 'Интервью',
  ),
  Application(
    id: 4,
    jobPostId: 5,
    userId: 1,
    cvUrl: 'cv_alex.pdf',
    message: 'Использую Python и SQL, хочу получить коммерческий опыт.',
    status: 'Отказ',
  ),
];
