import {
  Injectable,
  NotFoundException,
  ConflictException,
  InternalServerErrorException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { Prisma, User } from '@prisma/client';

import { PrismaService } from '@/prisma/prisma.service';
import { CreateUserDto } from '@/user/dto/create-user.dto';
import { UpdateUserDto } from '@/user/dto/update-user.dto';
import { FilterUserDto } from '@/user/dto/filter-user.dto';
import { UserWithoutPassword } from '@/user/types/user-without-password.type';
import { PrismaClientKnownRequestError } from '@prisma/client/runtime/client';
import { RemoveMovieDto } from './dto/remove-movie.dto';
import { AddMovieDto } from './dto/add-movie.dto';

@Injectable()
export class UserService {
  constructor(private prisma: PrismaService) {}

  excludePassword(user: User): UserWithoutPassword {
    const { password: _password, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }

  async create(createUserDto: CreateUserDto, tx?: Prisma.TransactionClient) {
    const client = tx || this.prisma;

    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(
      createUserDto.password,
      saltRounds,
    );

    try {
      const user = await client.user.create({
        data: {
          ...createUserDto,
          password: hashedPassword,
        },
      });

      return this.excludePassword(user);
    } catch (error) {
      if (
        error instanceof PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw new ConflictException('A user with this email already exists.');
      }
      throw new InternalServerErrorException('Failed to create user.');
    }
  }

  async addMovie(userId: number, addMovieDto: AddMovieDto) {
    // 1. Busca o usuário para verificar se o filme já está na lista
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { wishMovies: true },
    });

    if (!user) {
      throw new NotFoundException(`User with ID '${userId}' not found.`);
    }

    // 2. Verifica se o filme já existe para evitar duplicatas
    if (user.wishMovies.includes(addMovieDto.movieId)) {
      // Se já existe, retorna o usuário atual sem alterações (idempotência)
      // Ou você pode lançar um erro: throw new ConflictException('Movie already in wishlist');
      const fullUser = await this.prisma.user.findUnique({
        where: { id: userId },
      });
      return this.excludePassword(fullUser!);
    }

    // 3. Atualiza adicionando o ID ao array (push)
    try {
      const updatedUser = await this.prisma.user.update({
        where: { id: userId },
        data: {
          wishMovies: {
            push: addMovieDto.movieId,
          },
        },
      });

      return this.excludePassword(updatedUser);
    } catch (error) {
      throw new InternalServerErrorException(
        'Failed to add movie to wishlist.',
      );
    }
  }

  async removeMovie(userId: number, removeMovieDto: RemoveMovieDto) {
    // 1. Busca o usuário atual para filtrar a lista
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { wishMovies: true },
    });

    if (!user) {
      throw new NotFoundException(`User with ID '${userId}' not found.`);
    }

    // 2. Filtra removendo o ID do filme
    const updatedWishMovies = user.wishMovies.filter(
      (id) => id !== removeMovieDto.movieId,
    );

    // 3. Atualiza o usuário com a nova lista (set)
    try {
      const updatedUser = await this.prisma.user.update({
        where: { id: userId },
        data: {
          wishMovies: {
            set: updatedWishMovies,
          },
        },
      });

      return this.excludePassword(updatedUser);
    } catch (error) {
      throw new InternalServerErrorException(
        'Failed to remove movie from wishlist.',
      );
    }
  }

  async findAll(filters: FilterUserDto) {
    const users = await this.prisma.user.findMany({
      where: {
        email: {
          contains: filters.email,
          mode: 'insensitive',
        },
      },
    });
    return users.map((user) => this.excludePassword(user));
  }

  async findOneByEmail(email: string) {
    const user = await this.prisma.user.findUnique({
      where: { email: email },
    });

    return user;
  }

  async findOne(id: number) {
    const user = await this.prisma.user.findUnique({
      where: { id },
    });

    if (!user) {
      throw new NotFoundException(`User with ID '${id}' not found.`);
    }

    return this.excludePassword(user);
  }

  async update(id: number, updateUserDto: UpdateUserDto) {
    if (updateUserDto.password) {
      const saltRounds = 10;
      updateUserDto.password = await bcrypt.hash(
        updateUserDto.password,
        saltRounds,
      );
    }

    try {
      const user = await this.prisma.user.update({
        where: { id },
        data: updateUserDto,
      });
      return this.excludePassword(user);
    } catch (error) {
      if (
        error instanceof PrismaClientKnownRequestError &&
        error.code === 'P2025'
      ) {
        throw new NotFoundException(`User with ID '${id}' not found.`);
      }
      throw new InternalServerErrorException('Failed to update user.');
    }
  }

  async remove(id: number) {
    try {
      await this.prisma.user.delete({
        where: { id },
      });
      return { message: `User with ID '${id}' successfully deleted.` };
    } catch (error) {
      console.error(error);
      throw new NotFoundException(`User with ID '${id}' not found.`);
    }
  }
}
