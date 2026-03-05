<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/nestjs-E0234E?style=for-the-badge&logo=nestjs&logoColor=white" alt="NestJS" />
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL" />
  <img src="https://img.shields.io/badge/Prisma-3982CE?style=for-the-badge&logo=Prisma&logoColor=white" alt="Prisma" />
</p>

# 🎬 WishFlix

**WishFlix** é uma plataforma completa (Backend + Mobile) para o gerenciamento de filmes desejados. A aplicação permite aos usuários se cadastrarem, explorarem o catálogo do TMDb (The Movie Database), buscarem lançamentos, recomendações e salvarem seus filmes favoritos em sua wishlist pessoal.

---

## 🎯 Por que este projeto?

Este projeto foi desenvolvido com foco em aprimorar **boas práticas, novos conhecimentos em desenvolvimento mobile e integração de sistemas**. Ele demonstra de ponta a ponta o desenvolvimento de uma aplicação full-stack:

* **Arquitetura Backend Sólida (NestJS & Prisma):** API RESTful construída com NestJS (TypeScript), utilizando Prisma como ORM para gerenciar o banco de dados PostgreSQL. Segurança de rotas garantida através de autenticação por JWT.
* **Aplicativo Mobile Dinâmico (Flutter):** Interface rica e responsiva com Flutter. Comunicação eficiente utilizando o pacote `dio` com interceptors para injeção de tokens de autorização e tratamento global de erros.
* **Integração com APIs Externas (TMDb):** Consumo da API do _The Movie Database_ para consultar listagens de filmes, detalhes e sistema de recomendação (M2M / External API Integration).
* **Gestão de Perfil do Usuário:** Fluxo completo que vai desde o cadastro, login, gerenciamento de gêneros favoritos até a adição/remoção de itens em uma lista de desejos persistida.

---

## 📸 Capturas de Tela (Screenshots)

<div align="center">
  <img width="757" height="488" alt="image" src="https://github.com/user-attachments/assets/766590fc-7f7a-46b3-a9c7-c9e51f6bdc9c" />

  <img width="760" height="476" alt="image" src="https://github.com/user-attachments/assets/8f535ec7-0bec-4412-af3d-03b9123cec7c" />
</div>

---

## 🚀 Tecnologias Integradas

### ⚙️ Backend (API)
* **[NestJS](https://nestjs.com/):** Framework Node.js progressivo e escalável.
* **[Prisma ORM](https://www.prisma.io/):** Type-safe ORM para comunicação com o banco de dados.
* **[PostgreSQL](https://www.postgresql.org/):** Banco de dados relacional robusto.
* **TypeScript:** Tipagem estática para JavaScript, reduzindo erros em tempo de desenvolvimento.
* **JWT (JSON Web Token) & Passport:** Para autenticação e proteção de rotas (`JwtAuthGuard`).

### 📱 Mobile App
* **[Flutter](https://flutter.dev/):** Framework UI da Google para aplicações nativas a partir de uma base de código unificada (Dart).
* **[Dio](https://pub.dev/packages/dio):** Poderoso cliente HTTP para o Dart, lidando com autenticação e timeouts.
* **Integração com a API do TMDb:** Para dados atualizados de filmes.
* **Material Design 3:** Utilizando componentes modernos da Google para criação fluida de interfaces (`new_home_screen`, `movie_details_screen`).

---

## 🛠️ Como Clonar e Executar o Projeto Localmente

Se você é um desenvolvedor ou recrutador que quer testar o WishFlix localmente, siga o passo a passo abaixo:

### 1. Pré-requisitos
* Node.js (v18+)
* PostgreSQL rodando localmente (ou via Docker)
* Flutter SDK configurado
* Uma [chave de API do TMDb](https://developer.themoviedb.org/docs/getting-started) (Necessária para a listagem de filmes no Flutter).

### 2. Configurando e Rodando o Backend (API NestJS)

Navegue até o diretório da API e instale as dependências:
```bash
cd api
npm install
```

Configurando o ambiente:
1. Crie um arquivo `.env` na pasta `api` (baseado num `.env.example` caso exista) com a variável para o banco de dados e o JWT:
```env
DATABASE_URL="postgresql://usuario:senha@localhost:5432/wishflix?schema=public"
JWT_SECRET="sua_chave_super_secreta"
```
2. Rode as migrações do Prisma para criar as tabelas `users` (se necessário):
```bash
npx prisma generate
npx prisma migrate dev
```

Inicie o servidor local:
```bash
npm run start:dev
```
A API estará exposta em `http://localhost:3000`.

### 3. Configurando e Rodando o Mobile (Flutter)

Acesse a pasta do aplicativo e baixe as dependências do pubspec:
```bash
cd flutterapp
flutter pub get
```

Configurando o ambiente:
1. Você vai precisar inserir o seu `Bearer Token` do TMDb no arquivo `flutterapp/lib/core/constants/tmdb_constants.dart` (ou `.env` caso tenha abstraído).
2. Certifique-se de que a `_baseUrl` no arquivo `ApiService` (`flutterapp/lib/data/services/api_service.dart`) aponte para a sua máquina. 
*(Ao rodar em Emulador Android local, use `10.0.2.2:3000`. Ao rodar em dispositivo físico na mesma rede Wi-Fi, use o IP da sua máquina, ex: `192.168.1.XX:3000`).*

Execute o aplicativo:
```bash
flutter run
```

---

## 🗺️ Arquitetura e Fluxo de Dados

1. **Autenticação:** O usuário abre o app, cai no `login_screen`. Os dados são enviados via Dio (`ApiService`) para a rota `/auth/login` do NestJS. O backend valida (criptografia via `bcrypt`), gera um JWT e retorna.
2. **Navegação (Home):** Autenticado, o App intercepta o JWT para próximas chamadas. A `home_screen` bate diretamente no **TMDb API** para buscar Lançamentos e Populares.
3. **Wishlist:** Na tela `movie_details_screen`, o usuário pode favoritar um filme (ícone de coração). Isso detona a rota POST `/user/add-movie` (recebendo o ID do filme) que o Prisma ORM persiste numa array de `wishMovies` do PostgreSQL.
4. **Recomendações:** A plataforma usa as escolhas de gêneros favoritos registradas (rota Profile/Me) para trazer listagens mais afiadas.

