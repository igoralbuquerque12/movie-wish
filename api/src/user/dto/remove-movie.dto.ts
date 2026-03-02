import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsNumber } from 'class-validator';

export class RemoveMovieDto {
  @ApiProperty({
    description: 'ID of movie',
    example: 123,
  })
  @IsNumber({}, { message: 'The movie ID is invalid.' })
  @IsNotEmpty({ message: 'The movie ID field cannot be empty.' })
  movieId: number;
}
