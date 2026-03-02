import { ApiProperty } from '@nestjs/swagger';
import {
  IsArray,
  IsEmail,
  IsNotEmpty,
  IsString,
  MinLength,
} from 'class-validator';

export class CreateUserDto {
  @ApiProperty({
    description: 'User email address',
    example: 'user@example.com',
  })
  @IsEmail({}, { message: 'The provided email is invalid.' })
  @IsNotEmpty({ message: 'The email field cannot be empty.' })
  email: string;

  @ApiProperty({
    description: 'User password',
    example: 'StrongP@ssw0rd',
  })
  @IsString()
  @IsNotEmpty({ message: 'The password field cannot be empty.' })
  @MinLength(8, { message: 'The password must be at least 8 characters long.' })
  password: string;

  @ApiProperty({
    description: 'User name',
    example: 'User',
  })
  @IsString()
  @IsNotEmpty({ message: 'The name field cannot be empty.' })
  name: string;

  @ApiProperty({
    description: 'User favorite genres',
    example: '[4040. 4041]',
  })
  @IsArray()
  favoriteGenres: number[];

  @ApiProperty({
    description: 'User wish movies',
    example: '[123, 456]',
  })
  @IsArray()
  wishMovies: number[];
}
