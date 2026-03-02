import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsNumber,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator';

export class RegisterUserDto {
  @ApiProperty({
    description: 'User name to register',
    example: 'User',
  })
  @IsString()
  name: string;

  @ApiProperty({
    description: 'IDs of user`s favorite genres',
    example: '[0403, 0404]',
  })
  @IsNumber()
  @IsOptional()
  favoriteGenres: number[];

  @ApiProperty({
    description: 'User email address to register',
    example: 'newuser@example.com',
  })
  @IsEmail()
  email: string;

  @ApiProperty({
    description: 'Account password (min 8 chars)',
    example: 'MyN3wP@ss',
  })
  @IsString()
  @MinLength(8)
  password: string;
}
