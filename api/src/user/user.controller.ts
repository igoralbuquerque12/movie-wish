import {
  Request,
  Query,
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';

import { UserService } from '@/user/user.service';
import { CreateUserDto } from '@/user/dto/create-user.dto';
import { UpdateUserDto } from '@/user/dto/update-user.dto';
import { FilterUserDto } from '@/user/dto/filter-user.dto';
import { AddMovieDto } from '@/user/dto/add-movie.dto';
import { RemoveMovieDto } from '@/user/dto/remove-movie.dto';

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() createUserDto: CreateUserDto) {
    return this.userService.create(createUserDto);
  }

  @Post('add-movie')
  @HttpCode(HttpStatus.CREATED)
  // Adicione o @Request() req ou @User() user dependendo da sua configuração de Auth
  addMovie(@Request() req, @Body() addMovie: AddMovieDto) {
    // O ID do usuário vem do token (req.user.id)
    return this.userService.addMovie(req.user.sub, addMovie);
  }

  @Post('remove-movie')
  @HttpCode(HttpStatus.CREATED)
  removeMovie(@Request() req, @Body() removeMovie: RemoveMovieDto) {
    // O ID do usuário vem do token (req.user.id)
    return this.userService.removeMovie(req.user.sub, removeMovie);
  }

  @Get()
  findAll(@Query() filters: FilterUserDto) {
    return this.userService.findAll(filters);
  }

  @Get('/me')
  findOne(@Request() req) {
    return this.userService.findOne(req.user.sub);
  }

  @Patch('/me')
  update(@Request() req, @Body() updateUserDto: UpdateUserDto) {
    return this.userService.update(req.user.sub, updateUserDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: number) {
    return this.userService.remove(id);
  }
}
